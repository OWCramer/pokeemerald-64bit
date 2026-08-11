// SDL3 platform layer.
//
// This replaces src/platform/sdl2.c rather than sitting alongside it: the SDL2
// file stays as the reference desktop build, and this one is written for iOS
// from the start so the port is not done twice. Three things SDL3 gives us that
// SDL2 did not:
//
//   - SDL_AudioStream, which survives device changes (headphones unplugged, a
//     phone call arriving). The SDL2 SDL_QueueAudio path handles those badly.
//   - SDL_Gamepad, which picks up MFi controllers with no extra work.
//   - A touch API that reports render-space coordinates, so the on-screen pad
//     can be laid out in the same 240x160 space as the game.
//
// The threading model is unchanged from the SDL2 build because it is known to
// work: the main thread owns events and rendering, AgbMain runs on a worker,
// and the two rendezvous through a semaphore once per emulated V-blank.
#ifdef PLATFORM_SDL3
#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <setjmp.h>

#include <SDL3/SDL.h>
// Must be included in the translation unit defining main(). On iOS this hands
// the entry point to SDL so UIKit owns the run loop; on desktop it is inert.
#include <SDL3/SDL_main.h>

#include "global.h"
#include "field_camera.h"
#include "platform.h"
#include "rtc.h"
#include "gba/defines.h"
#include "gba/m4a_internal.h"
#include "cgb_audio.h"
#include "gba/flash_internal.h"
#include "platform/dma.h"
#include "platform/framedraw.h"

extern void (*const gIntrTable[])(void);

#if defined(SDL_PLATFORM_IOS) || defined(SDL_PLATFORM_ANDROID)
#define MOBILE 1
#else
#define MOBILE 0
#endif

// The mixer emits 701 samples per V-blank at 60Hz; see PORTING.md.
#define AUDIO_RATE        42060
#define AUDIO_FRAME_BYTES (701 * 2 * (int)sizeof(float))

SDL_Thread *mainLoopThread;
SDL_Window *sdlWindow;
SDL_Renderer *sdlRenderer;
SDL_Texture *sdlTexture;
SDL_Semaphore *vBlankSemaphore;
SDL_AtomicInt isFrameAvailable;
static SDL_AudioStream *sAudioStream;
// Soft reset. Ctrl+R only raises this flag; the reset itself must happen on the
// AgbMain worker thread, because DoSoftReset touches game state and the longjmp
// below is only valid on the thread that ran setjmp. Doing either from the
// event loop is a data race at best.
static jmp_buf sResetJmp;
static SDL_AtomicInt sResetRequested;
static SDL_Gamepad *sGamepad;
#if MOBILE
// The on-screen touch overlay is exposed to SDL as a virtual gamepad, so a tap
// arrives as an ordinary SDL_EVENT_GAMEPAD_BUTTON that the whole input path
// already understands: it flows through the rebindable binding table
// (GamepadKeys), the game sees a controller present, and the controls menu can
// capture it during a rebind -- none of which a raw finger event does.
// sTouchPadJoy sets the virtual buttons; sTouchPad is the gamepad view read for
// held input; sTouchPadId tells its events apart from a real controller's.
static SDL_JoystickID sTouchPadId;
static SDL_Joystick *sTouchPadJoy;
static SDL_Gamepad *sTouchPad;
#endif
// The framebuffer is ABGR1555 -- the GBA's own BGR555 order. No hardware
// renderer on iOS accepts it: Metal and GLES take ARGB1555 (R and B swapped)
// but not this. When the native format is refused we upload through a swizzle
// instead, via a table so it costs one lookup per pixel rather than shifts.
static bool sSwizzle1555;
static u16 sSwizzleLut[0x10000];
static u16 *sSwizzleBuf;

// Ask the renderer what it accepts rather than trying and catching the
// failure: SDL builds the Metal texture descriptor before its own format
// guard, so an unsupported format aborts the process inside Metal validation
// instead of returning an error we could recover from.
static bool RendererSupportsFormat(SDL_PixelFormat want)
{
    SDL_PropertiesID props = SDL_GetRendererProperties(sdlRenderer);
    const SDL_PixelFormat *fmts = (const SDL_PixelFormat *)
        SDL_GetPointerProperty(props, SDL_PROP_RENDERER_TEXTURE_FORMATS_POINTER, NULL);

    if (fmts == NULL)
        return false;
    for (int i = 0; fmts[i] != SDL_PIXELFORMAT_UNKNOWN; i++)
    {
        if (fmts[i] == want)
            return true;
    }
    return false;
}

static SDL_Texture *CreateFrameTexture(int w, int h)
{
    SDL_Texture *tex = NULL;

    if (RendererSupportsFormat(SDL_PIXELFORMAT_ABGR1555))
        tex = SDL_CreateTexture(sdlRenderer, SDL_PIXELFORMAT_ABGR1555,
                                SDL_TEXTUREACCESS_STREAMING, w, h);
    if (tex == NULL)
    {
        tex = SDL_CreateTexture(sdlRenderer, SDL_PIXELFORMAT_ARGB1555,
                                SDL_TEXTUREACCESS_STREAMING, w, h);
        if (tex == NULL)
            return NULL;
        if (!sSwizzle1555)
        {
            for (int i = 0; i < 0x10000; i++)
                sSwizzleLut[i] = (u16)((i & 0x8000) | ((i & 0x1F) << 10)
                                       | (i & 0x03E0) | ((i >> 10) & 0x1F));
            sSwizzle1555 = true;
        }
    }
    SDL_SetTextureScaleMode(tex, SDL_SCALEMODE_NEAREST);
    SDL_SetTextureBlendMode(tex, SDL_BLENDMODE_NONE);
    return tex;
}

static int sTextureW, sTextureH;

// Pixels are always drawn at a whole multiple of their true size, so nothing is
// ever stretched. A bigger window buys a bigger viewport, not bigger pixels.
// Scale is capped so the viewport can never be smaller than the vanilla
// 240x160 -- you get the vanilla view or more of the world, never less.

static void UpdateViewport(void)
{
    int winW = 0, winH = 0;
    SDL_GetWindowSizeInPixels(sdlWindow, &winW, &winH);
    if (winW <= 0 || winH <= 0)
        return;

    int maxScale = winW / DISPLAY_WIDTH;
    int vMax = winH / DISPLAY_HEIGHT;
    if (vMax < maxScale) maxScale = vMax;
    if (maxScale < 1) maxScale = 1;

    // Vanilla pixel size is whatever integer scale fits 240x160 in the window;
    // the space that would have been letterboxed is filled with more map.
    int scale = maxScale;

    // Round UP, and up to a whole tile of overscan. Rounding down left the
    // render short of the window by up to scale-1 px on each axis -- and up to
    // a whole tile across, since backgrounds are fetched in 8px units -- which
    // showed as black edges. Covering the window and cropping is better than
    // falling short and letterboxing.
    int wantW = (((winW + scale - 1) / scale) + 7) & ~7;
    int wantH = (winH + scale - 1) / scale;

    SetRenderSize(wantW, wantH);

    if (gRenderWidth != sTextureW || gRenderHeight != sTextureH)
    {
        SDL_Texture *tex = CreateFrameTexture(gRenderWidth, gRenderHeight);
        if (tex != NULL)
        {
            if (sdlTexture)
                SDL_DestroyTexture(sdlTexture);
            sdlTexture = tex;
            sTextureW = gRenderWidth;
            sTextureH = gRenderHeight;
        }
    }

    // Present 1:1 at an integer scale. When the render covers the window, crop
    // the overscan; when the field's tilemap could not back the full request,
    // fall back to letterboxing rather than scaling up off-integer and
    // blurring every pixel.
    bool covers = (gRenderWidth * scale >= winW && gRenderHeight * scale >= winH);

    SDL_SetRenderLogicalPresentation(sdlRenderer, gRenderWidth * scale,
                                     gRenderHeight * scale,
                                     covers ? SDL_LOGICAL_PRESENTATION_OVERSCAN
                                            : SDL_LOGICAL_PRESENTATION_LETTERBOX);
}


bool speedUp = false;
unsigned int videoScale = 1;
bool videoScaleChanged = false;
bool isRunning = true;
bool paused = false;
double simTime = 0;
double lastGameTime = 0;
double curGameTime = 0;
double fixedTimestep = 1.0 / 60.0;
double timeScale = 1.0;
struct SiiRtcInfo internalClock;

static FILE *sSaveFile = NULL;
static char sSavePath[1024];

extern void AgbMain(void);
extern void DoSoftReset(void);

int DoMain(void *param);
void ProcessEvents(void);
void VDraw(SDL_Texture *texture);

static void ResolveSavePath(void);
static void ReadSaveFile(const char *path);
static void StoreSaveFile(void);
static void CloseSaveFile(void);
static void UpdateInternalClock(void);
static void OpenAudio(void);
static void OpenFirstGamepad(void);
static void DrawTouchOverlay(void);
static u16 GamepadKeys(void);
#if MOBILE
static void AttachTouchPad(void);
static void DetachTouchPad(void);
#endif

int main(int argc, char **argv)
{
    ResolveSavePath();
    ReadSaveFile(sSavePath);

    // Desktop metadata, set before SDL_Init so the video backend can use it.
    // SDL uses the identifier as the Wayland xdg app_id (and the X11 WM class),
    // which is how KDE and GNOME associate the window with its installed
    // .desktop file and therefore its icon -- Wayland has no per-window pixel
    // icon protocol, so this is the only way the taskbar/dock icon appears
    // instead of the generic placeholder. The identifier MUST match the
    // installed .desktop basename and its StartupWMClass (see tools/packaging).
    SDL_SetAppMetadata("Pok\xC3\xA9mon Emerald", "1.0.0", "pokeemerald");

    if (!SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_GAMEPAD))
    {
        DBGPRINTF("SDL could not initialize! SDL_Error: %s\n", SDL_GetError());
        return 1;
    }

#if MOBILE
    // Allow both orientations. The expanded field viewport fills whatever aspect
    // the window is (UpdateViewport), so portrait shows more of the map vertically
    // rather than wasting the display, and the touch pad has a portrait layout
    // (see sTouchButtons / DrawTouchOverlay). The window follows the device; the
    // per-frame OutputSize() read keeps the render and pad in step on rotation.
    SDL_SetHint(SDL_HINT_ORIENTATIONS,
                "LandscapeLeft LandscapeRight Portrait PortraitUpsideDown");
#endif

    SDL_WindowFlags flags = SDL_WINDOW_RESIZABLE;
#if MOBILE
    // Without HIGH_PIXEL_DENSITY the drawable is the window's size in *points*,
    // so on a 3x phone the game renders at a third of the panel's resolution and
    // iOS upscales the result -- 912x420 on a 2736x1260 screen. Asking for the
    // native drawable makes the pixel-exact scaling actually land on real
    // pixels, and gives the expanded viewport far more to work with.
    flags |= SDL_WINDOW_FULLSCREEN | SDL_WINDOW_HIGH_PIXEL_DENSITY;
#endif
    sdlWindow = SDL_CreateWindow("Pok\xC3\xA9mon Emerald",
                                 DISPLAY_WIDTH * 3, DISPLAY_HEIGHT * 3, flags);
    if (sdlWindow == NULL)
    {
        DBGPRINTF("Window could not be created! SDL_Error: %s\n", SDL_GetError());
        return 1;
    }

    sdlRenderer = SDL_CreateRenderer(sdlWindow, NULL);
    if (sdlRenderer == NULL)
    {
        DBGPRINTF("Renderer could not be created! SDL_Error: %s\n", SDL_GetError());
        return 1;
    }
    SDL_SetRenderVSync(sdlRenderer, 1);

    // Letterbox rather than stretch: every iPhone is wider than 3:2, and
    // stretching a pixel-art game to fill looks worse than black bars.
    SDL_SetRenderLogicalPresentation(sdlRenderer, DISPLAY_WIDTH, DISPLAY_HEIGHT,
                                     SDL_LOGICAL_PRESENTATION_LETTERBOX);
    SDL_SetRenderDrawBlendMode(sdlRenderer, SDL_BLENDMODE_BLEND);
    SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, 255);
    SDL_RenderClear(sdlRenderer);

    sdlTexture = CreateFrameTexture(DISPLAY_WIDTH, DISPLAY_HEIGHT);
    if (sdlTexture == NULL)
    {
        DBGPRINTF("Texture could not be created! SDL_Error: %s\n", SDL_GetError());
        return 1;
    }
    SDL_SetTextureScaleMode(sdlTexture, SDL_SCALEMODE_NEAREST);
    // The framebuffer is opaque by definition, so never blend it. The format is
    // ABGR1555 and SDL3 defaults alpha-bearing textures to SDL_BLENDMODE_BLEND;
    // the software renderer ORs 0x8000 into every pixel it draws but fills the
    // backdrop straight from palette entry 0, whose alpha bit is 0. Blending
    // therefore made the backdrop transparent and showed the clear colour
    // through it -- a black main-menu background where SDL2 drew it correctly.
    SDL_SetTextureBlendMode(sdlTexture, SDL_BLENDMODE_NONE);
    sTextureW = DISPLAY_WIDTH;
    sTextureH = DISPLAY_HEIGHT;

    simTime = curGameTime = lastGameTime = SDL_GetPerformanceCounter();

    SDL_SetAtomicInt(&isFrameAvailable, 0);
    vBlankSemaphore = SDL_CreateSemaphore(0);

    UpdateViewport();
    OpenAudio();
#if MOBILE
    // Register the on-screen pad as a virtual controller before scanning for a
    // real one, so OpenFirstGamepad can tell them apart.
    AttachTouchPad();
#endif
    OpenFirstGamepad();

    VDraw(sdlTexture);
    mainLoopThread = SDL_CreateThread(DoMain, "AgbMain", NULL);

    double accumulator = 0.0;

    memset(&internalClock, 0, sizeof(internalClock));
    internalClock.status = SIIRTCINFO_24HOUR;
    UpdateInternalClock();

    while (isRunning)
    {
        ProcessEvents();

        bool32 didRender = FALSE;

        if (!paused)
        {
            double dt = fixedTimestep / timeScale;

            curGameTime = SDL_GetPerformanceCounter();
            double deltaTime = (double)((curGameTime - lastGameTime) / (double)SDL_GetPerformanceFrequency());
            if (deltaTime > (dt * 5))
                deltaTime = dt;
            lastGameTime = curGameTime;

            accumulator += deltaTime;

            while (accumulator >= dt)
            {
                if (SDL_GetAtomicInt(&isFrameAvailable))
                {
                    VDraw(sdlTexture);
                    SDL_RenderClear(sdlRenderer);
                    SDL_RenderTexture(sdlRenderer, sdlTexture, NULL, NULL);
                    DrawTouchOverlay();
                    didRender = TRUE;
                    SDL_SetAtomicInt(&isFrameAvailable, 0);

                    REG_DISPSTAT |= INTR_FLAG_VBLANK;

                    RunDMAs(DMA_HBLANK);

                    if (REG_DISPSTAT & DISPSTAT_VBLANK_INTR)
                        gIntrTable[4]();
                    REG_DISPSTAT &= ~INTR_FLAG_VBLANK;

                    SDL_SignalSemaphore(vBlankSemaphore);

                    accumulator -= dt;
                }
            }
        }

        // Only present frames that were actually drawn. This loop spins faster
        // than the emulated 60Hz, and presenting on an iteration where nothing
        // was copied swaps in an undrawn back buffer -- a black flicker every
        // few frames.
        if (didRender)
            SDL_RenderPresent(sdlRenderer);
        else
            SDL_Delay(1);
    }

    StoreSaveFile();
    CloseSaveFile();

    if (sGamepad)
        SDL_CloseGamepad(sGamepad);
#if MOBILE
    DetachTouchPad();
#endif
    SDL_DestroyWindow(sdlWindow);
    SDL_Quit();
    return 0;
}

// ---------------------------------------------------------------- audio

static void OpenAudio(void)
{
    SDL_AudioSpec spec;
    SDL_zero(spec);
    spec.freq = AUDIO_RATE;
    spec.format = SDL_AUDIO_F32;
    spec.channels = 2;

    cgb_audio_init(AUDIO_RATE);

    // A NULL callback means we push with SDL_PutAudioStreamData. SDL owns the
    // resampling to whatever the device actually runs at, and re-binds the
    // stream itself when the default device changes -- which on iOS happens
    // whenever headphones are connected or a call interrupts playback.
    sAudioStream = SDL_OpenAudioDeviceStream(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK,
                                             &spec, NULL, NULL);
    if (sAudioStream == NULL)
    {
        DBGPRINTF("Failed to open audio: %s\n", SDL_GetError());
        return;
    }
    SDL_ResumeAudioStreamDevice(sAudioStream);
}

void Platform_QueueAudio(float *audioBuffer, s32 samplesPerFrame)
{
    if (sAudioStream == NULL)
        return;

    // EMERALD_DUMP_WAV=<file> captures the exact buffer handed to the device as
    // 32-bit float stereo. Ground truth for audio work -- this is what found the
    // PSG aliasing.
    {
        extern char *getenv(const char *);
        static int checked; static FILE *wav; static unsigned long dataBytes;
        if (!checked) {
            checked = 1;
            const char *path = getenv("EMERALD_DUMP_WAV");
            if (path && (wav = fopen(path, "wb"))) {
                unsigned char h[44] = {0};
                memcpy(h, "RIFF", 4); memcpy(h + 8, "WAVEfmt ", 8);
                h[16] = 16; h[20] = 3; h[22] = 2;
                unsigned rate = AUDIO_RATE, bps = rate * 2 * 4;
                memcpy(h + 24, &rate, 4); memcpy(h + 28, &bps, 4);
                h[32] = 8; h[34] = 32;
                memcpy(h + 36, "data", 4);
                fwrite(h, 1, 44, wav);
            }
        }
        if (wav) {
            fwrite(audioBuffer, 1, (size_t)samplesPerFrame, wav);
            dataBytes += (unsigned long)samplesPerFrame;
            unsigned d = (unsigned)dataBytes, r = d + 36;
            fseek(wav, 4, SEEK_SET);  fwrite(&r, 4, 1, wav);
            fseek(wav, 40, SEEK_SET); fwrite(&d, 4, 1, wav);
            fseek(wav, 0, SEEK_END);
            fflush(wav);
        }
    }

    // EMERALD_AUDIO_STATS=1 reports rate and queue depth, which is how clock
    // drift between the frame clock and the device clock was caught.
    {
        extern char *getenv(const char *);
        static int checked, on; static unsigned n; static float peak;
        static Uint64 t0; static unsigned calls; static unsigned long bytesOut;
        if (!checked) { checked = 1; on = getenv("EMERALD_AUDIO_STATS") != NULL; }
        if (on) {
            int count = samplesPerFrame / (int)sizeof(float);
            for (int k = 0; k < count; k++) {
                float a = audioBuffer[k] < 0 ? -audioBuffer[k] : audioBuffer[k];
                if (a > peak) peak = a;
            }
            calls++; bytesOut += (unsigned long)samplesPerFrame;
            if (t0 == 0) t0 = SDL_GetTicks();
            if (++n % 60 == 0) {
                Uint64 now = SDL_GetTicks();
                double secs = (now - t0) / 1000.0;
                printf("audio: peak=%.3f | %.1f calls/s %.0f B/s (need %d) | queued=%d B\n",
                       peak, calls / secs, bytesOut / secs,
                       AUDIO_RATE * 2 * 4, SDL_GetAudioStreamQueued(sAudioStream));
                fflush(stdout);
                peak = 0; calls = 0; bytesOut = 0; t0 = now;
            }
        }
    }

    // The game's frame clock and the audio device clock are independent, so the
    // queue drifts -- measured ~0.15% on the SDL2 build, which is ~0.9s of added
    // latency over ten minutes. Correct it by varying the frame length by a
    // single stereo sample (1/701 = 0.14%, inaudible) rather than dropping whole
    // frames, which clicks.
    int bytes = samplesPerFrame;
    int queued = SDL_GetAudioStreamQueued(sAudioStream);

    // Fast-forward generates ~5x the audio the device consumes. The SDL2 build
    // muted outright; keep playing instead, discarding frames once the queue is
    // past a bound so it speeds up rather than falling behind.
    if (speedUp)
    {
        if (queued > 2 * AUDIO_FRAME_BYTES)
            return;
        SDL_PutAudioStreamData(sAudioStream, audioBuffer, samplesPerFrame);
        return;
    }
    const int target = 3 * AUDIO_FRAME_BYTES;   // ~50ms
    const int oneSample = 2 * (int)sizeof(float);

    if (queued > target + AUDIO_FRAME_BYTES / 2 && bytes >= oneSample)
        bytes -= oneSample;
    else if (queued < target - AUDIO_FRAME_BYTES / 2)
        SDL_PutAudioStreamData(sAudioStream, audioBuffer, oneSample);

    SDL_PutAudioStreamData(sAudioStream, audioBuffer, bytes);
}

// ---------------------------------------------------------------- input

// ---- rebindable input -------------------------------------------------
//
// Bindings live in a runtime table rather than #defines so they can be changed
// from the in-game options menu, and are persisted to a small text file beside
// the save. Deliberately NOT in the save block: that would change the save
// format, and keeping .sav files interchangeable with real hardware is a goal
// of this port.
// Emulator functions live in the same table as the GBA buttons so they are
// rebindable through the same UI, persistence and conflict handling. gbaKey is
// 0 for these, and `host` says which one.
enum
{
    HOST_NONE = 0,
    HOST_FASTFORWARD,
    HOST_SOFTRESET,
    HOST_PAUSE,
};

struct GbaBinding
{
    u16 gbaKey;         // 0 for an emulator function
    u8 host;            // HOST_* when gbaKey is 0
    const char *name;   // shown in the options UI
    SDL_Keycode key;    // keyboard binding, SDLK_UNKNOWN if unbound
    SDL_Keymod mod;     // required modifiers, 0 for none
    int pad;            // SDL_GamepadButton, -1 if unbound
};

#define DEFAULT_BINDINGS { \
    { A_BUTTON, HOST_NONE,      "A",      SDLK_Z, 0,         SDL_GAMEPAD_BUTTON_SOUTH }, \
    { B_BUTTON, HOST_NONE,      "B",      SDLK_X, 0,         SDL_GAMEPAD_BUTTON_EAST }, \
    { START_BUTTON, HOST_NONE,  "START",  SDLK_RETURN, 0,    SDL_GAMEPAD_BUTTON_START }, \
    { SELECT_BUTTON, HOST_NONE, "SELECT", SDLK_BACKSLASH, 0, SDL_GAMEPAD_BUTTON_BACK }, \
    { L_BUTTON, HOST_NONE,      "L",      SDLK_A, 0,         SDL_GAMEPAD_BUTTON_LEFT_SHOULDER }, \
    { R_BUTTON, HOST_NONE,      "R",      SDLK_S, 0,         SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER }, \
    { DPAD_UP, HOST_NONE,       "UP",     SDLK_UP, 0,        SDL_GAMEPAD_BUTTON_DPAD_UP }, \
    { DPAD_DOWN, HOST_NONE,     "DOWN",   SDLK_DOWN, 0,      SDL_GAMEPAD_BUTTON_DPAD_DOWN }, \
    { DPAD_LEFT, HOST_NONE,     "LEFT",   SDLK_LEFT, 0,      SDL_GAMEPAD_BUTTON_DPAD_LEFT }, \
    { DPAD_RIGHT, HOST_NONE,    "RIGHT",  SDLK_RIGHT, 0,     SDL_GAMEPAD_BUTTON_DPAD_RIGHT }, \
    { 0, HOST_FASTFORWARD,      "FAST FWD", SDLK_SPACE, 0,              SDL_GAMEPAD_BUTTON_RIGHT_STICK }, \
    { 0, HOST_SOFTRESET,        "RESET",    SDLK_R,     SDL_KMOD_LCTRL, -1 }, \
    { 0, HOST_PAUSE,            "PAUSE",    SDLK_P,     SDL_KMOD_LCTRL, SDL_GAMEPAD_BUTTON_LEFT_STICK }, \
}

static struct GbaBinding sBindings[] = DEFAULT_BINDINGS;
#define NUM_BINDINGS ((int)(sizeof(sBindings) / sizeof(sBindings[0])))

// Left and right modifiers are treated as the same key, so a binding made with
// left shift also answers to right shift. Only these four are considered; caps
// lock and num lock are states rather than chords.
static SDL_Keymod NormalizeMods(SDL_Keymod m)
{
    SDL_Keymod out = 0;
    if (m & SDL_KMOD_SHIFT) out |= SDL_KMOD_LSHIFT;
    if (m & SDL_KMOD_CTRL)  out |= SDL_KMOD_LCTRL;
    if (m & SDL_KMOD_ALT)   out |= SDL_KMOD_LALT;
    if (m & SDL_KMOD_GUI)   out |= SDL_KMOD_LGUI;
    return out;
}

static bool8 IsModifierKey(SDL_Keycode k)
{
    switch (k)
    {
    case SDLK_LSHIFT: case SDLK_RSHIFT:
    case SDLK_LCTRL:  case SDLK_RCTRL:
    case SDLK_LALT:   case SDLK_RALT:
    case SDLK_LGUI:   case SDLK_RGUI:
        return TRUE;
    default:
        return FALSE;
    }
}

// Written by the game thread (Platform_BeginRebind) and read by the main
// thread's event loop, so it must be atomic: as a plain int the event loop
// never observed the request and the "PRESS INPUT" prompt hung forever.
static SDL_AtomicInt sRebindIndex;   // -1 unless capturing

// A captured input that already belongs to another action is held here rather
// than applied, so the game can ask before stealing it. Silently unbinding the
// other action loses a binding with no indication it happened.
static SDL_AtomicInt sConflictIndex; // action currently holding it, -1 if none
static int sPendingTarget;           // action being rebound
static SDL_Keymod sPendingMod;
static SDL_Keycode sPendingKey;
static int sPendingPad;
static char sBindPath[1024];

static u16 keys;

static void SaveBindings(void)
{
    FILE *f = fopen(sBindPath, "w");
    if (f == NULL)
        return;
    for (int i = 0; i < NUM_BINDINGS; i++)
        fprintf(f, "%s %d %d %d\n", sBindings[i].name, (int)sBindings[i].key,
                (int)sBindings[i].mod, sBindings[i].pad);
    fclose(f);
}

static void LoadBindings(void)
{
    FILE *f = fopen(sBindPath, "r");
    if (f == NULL)
        return;
    char line[128];
    char name[32];
    int key, mod, pad;
    while (fgets(line, sizeof(line), f))
    {
        // Accept the older three-field format (no modifier) as well.
        if (sscanf(line, "%31s %d %d %d", name, &key, &mod, &pad) != 4)
        {
            if (sscanf(line, "%31s %d %d", name, &key, &pad) != 3)
                continue;
            mod = 0;
        }
        for (int i = 0; i < NUM_BINDINGS; i++)
        {
            if (strcmp(sBindings[i].name, name) == 0)
            {
                sBindings[i].key = (SDL_Keycode)key;
                sBindings[i].mod = (SDL_Keymod)mod;
                sBindings[i].pad = pad;
                break;
            }
        }
    }
    fclose(f);
}

// Assign captured input, clearing it from every other action first so two GBA
// buttons can never share one input -- otherwise a rebind silently makes an
// earlier binding unreachable.
static void CommitRebind(int idx, SDL_Keycode key, SDL_Keymod mod, int pad)
{
    for (int i = 0; i < NUM_BINDINGS; i++)
    {
        // Only an identical chord clashes: Shift+L and plain L can coexist.
        if (key != SDLK_UNKNOWN && sBindings[i].key == key && sBindings[i].mod == mod)
            sBindings[i].key = SDLK_UNKNOWN;
        if (pad >= 0 && sBindings[i].pad == pad)
            sBindings[i].pad = -1;
    }
    if (key != SDLK_UNKNOWN)
    {
        sBindings[idx].key = key;
        sBindings[idx].mod = mod;
    }
    if (pad >= 0)
        sBindings[idx].pad = pad;
    keys = 0;
    SaveBindings();
}

// Fast-forward is held; reset and pause fire on press only.
static void RunHostAction(u8 host, bool8 pressed)
{
    switch (host)
    {
    case HOST_FASTFORWARD:
        if (pressed && !speedUp)      { speedUp = true;  timeScale = 5.0; }
        else if (!pressed && speedUp) { speedUp = false; timeScale = 1.0; }
        break;
    case HOST_SOFTRESET:
        if (pressed)
            SDL_SetAtomicInt(&sResetRequested, 1);
        break;
    case HOST_PAUSE:
        if (pressed)
            paused = !paused;
        break;
    default:
        break;
    }
}

static void ApplyRebind(SDL_Keycode key, SDL_Keymod mod, int pad)
{
    int idx = SDL_GetAtomicInt(&sRebindIndex);
    if (idx < 0)
        return;
    SDL_SetAtomicInt(&sRebindIndex, -1);

    // Already held by a different action? Hold it pending confirmation.
    for (int i = 0; i < NUM_BINDINGS; i++)
    {
        if (i == idx)
            continue;
        if ((key != SDLK_UNKNOWN && sBindings[i].key == key && sBindings[i].mod == mod)
         || (pad >= 0 && sBindings[i].pad == pad))
        {
            sPendingTarget = idx;
            sPendingKey = key;
            sPendingMod = mod;
            sPendingPad = pad;
            SDL_SetAtomicInt(&sConflictIndex, i);
            keys = 0;
            return;
        }
    }
    CommitRebind(idx, key, mod, pad);
}

// ---- API for the in-game options screen ----
u8 Platform_GetBindCount(void) { return (u8)NUM_BINDINGS; }
const char *Platform_GetBindName(u8 i) { return i < NUM_BINDINGS ? sBindings[i].name : ""; }
void Platform_BeginRebind(u8 i) { if (i < NUM_BINDINGS) SDL_SetAtomicInt(&sRebindIndex, (int)i); }
bool8 Platform_IsRebinding(void) { return SDL_GetAtomicInt(&sRebindIndex) >= 0; }
void Platform_CancelRebind(void) { SDL_SetAtomicInt(&sRebindIndex, -1); }
void Platform_SaveBindings(void) { SaveBindings(); }
bool8 Platform_HasBindConflict(void) { return SDL_GetAtomicInt(&sConflictIndex) >= 0; }

// The conflict is with A, which cannot be given away: without it the player
// cannot operate the menu that would undo the change.
bool8 Platform_ConflictIsProtected(void)
{
    int c = SDL_GetAtomicInt(&sConflictIndex);
    return c >= 0 && sBindings[c].gbaKey == A_BUTTON;
}

// The GBA font has no glyph for most punctuation, so SDL's one-character key
// names would render as "?" (which is what SELECT, bound to backslash, showed).
// Spell those out instead; anything not listed keeps SDL's name.
// "SHIFT+L", "CTRL+ALT+Q" -- appended before the key name.
static void AppendMods(SDL_Keymod m, char *out, int outSize)
{
    out[0] = '\0';
    if (m & SDL_KMOD_SHIFT) strncat(out, "SHIFT+", outSize - strlen(out) - 1);
    if (m & SDL_KMOD_CTRL)  strncat(out, "CTRL+",  outSize - strlen(out) - 1);
    if (m & SDL_KMOD_ALT)   strncat(out, "ALT+",   outSize - strlen(out) - 1);
    if (m & SDL_KMOD_GUI)   strncat(out, "GUI+",   outSize - strlen(out) - 1);
}

static const char *KeyDisplayName(SDL_Keycode k)
{
    switch (k)
    {
    case SDLK_BACKSLASH:    return "BACKSLASH";
    case SDLK_LEFTBRACKET:  return "LBRACKET";
    case SDLK_RIGHTBRACKET: return "RBRACKET";
    case SDLK_SEMICOLON:    return "SEMICOLON";
    case SDLK_APOSTROPHE:   return "QUOTE";
    case SDLK_GRAVE:        return "BACKTICK";
    case SDLK_EQUALS:       return "EQUALS";
    case SDLK_COMMA:        return "COMMA";
    case SDLK_MINUS:        return "MINUS";
    case SDLK_PERIOD:       return "PERIOD";
    case SDLK_SLASH:        return "SLASH";
    default:                return SDL_GetKeyName(k);
    }
}

// "Z IS USED BY L. OVERRIDE?" -- what the pending input is and who holds it.
void Platform_GetConflictText(char *out, int outSize)
{
    int c = SDL_GetAtomicInt(&sConflictIndex);
    if (c < 0 || outSize <= 0)
        return;
    char mods[24];
    AppendMods(sPendingKey != SDLK_UNKNOWN ? sPendingMod : 0, mods, sizeof(mods));
    const char *what = sPendingKey != SDLK_UNKNOWN
                     ? KeyDisplayName(sPendingKey)
                     : SDL_GetGamepadStringForButton((SDL_GamepadButton)sPendingPad);
    if (sBindings[c].gbaKey == A_BUTTON)
        snprintf(out, outSize, "%s%s IS ALREADY BOUND TO %s.\nREBIND %s FIRST.",
                 mods, what ? what : "?", sBindings[c].name, sBindings[c].name);
    else
        snprintf(out, outSize, "%s%s IS USED BY %s.\nOVERRIDE?", mods, what ? what : "?", sBindings[c].name);
}

void Platform_ResolveBindConflict(bool8 replace)
{
    if (SDL_GetAtomicInt(&sConflictIndex) < 0)
        return;
    // Never honour a "replace" that would strip A of its input.
    if (replace && !Platform_ConflictIsProtected())
        CommitRebind(sPendingTarget, sPendingKey, sPendingMod, sPendingPad);
    SDL_SetAtomicInt(&sConflictIndex, -1);
    keys = 0;
}

void Platform_ResetBindings(void)
{
    static const struct GbaBinding defaults[] = DEFAULT_BINDINGS;
    memcpy(sBindings, defaults, sizeof(sBindings));
    keys = 0;
    SaveBindings();
}


// ASCII description of what `i` is currently bound to, e.g. "Z / A".
void Platform_GetBindLabel(u8 i, char *out, int outSize)
{
    if (i >= NUM_BINDINGS || outSize <= 0)
        return;
    char mods[24];
    AppendMods(sBindings[i].mod, mods, sizeof(mods));
    const char *k = sBindings[i].key != SDLK_UNKNOWN ? KeyDisplayName(sBindings[i].key) : "-";
    const char *p = sBindings[i].pad >= 0
                  ? SDL_GetGamepadStringForButton((SDL_GamepadButton)sBindings[i].pad) : NULL;
    if (p != NULL)
        snprintf(out, outSize, "%s%s / %s", mods, k, p);
    else
        snprintf(out, outSize, "%s%s", mods, k);
}

// On-screen pad, as fractions of the renderer's logical extent.
//
// That is the space SDL reports touches in: with a logical presentation active
// it transforms finger events into render units, so a tap arrives as e.g.
// (267, 124) -- and negative in the letterbox, not 0..1 and not window pixels.
// Laying the pad out anywhere else means the hit boxes and the drawn buttons
// live in different spaces. `half` is a fraction of the logical *height* for
// both axes so buttons stay square; the presentation preserves aspect, so
// square here is square on screen.
// `key` is the GBA button this pad is drawn for (0 for an emulator function);
// `pad` is the SDL_GamepadButton it presses on the virtual controller (see
// AttachTouchPad). The pad values mirror the default bindings, so out of the box
// a tap resolves through the ordinary binding table -- to a GBA key, or, for the
// two top buttons, to the HOST_PAUSE / HOST_FASTFORWARD emulator actions. `icon`
// draws a glyph on the emulator-function buttons since they have no GBA label.
enum { TB_ICON_NONE, TB_ICON_PAUSE, TB_ICON_FF };
// cx/cy are the landscape centre (fractions of the window); pcx/pcy the portrait
// centre. Portrait puts the pad in the lower half (thumbs reach the bottom) with
// the game filling above it. `half` is a fraction of the SHORT window side, so a
// button is the same physical size in either orientation. See DrawTouchOverlay.
struct TouchButton { float cx, cy, pcx, pcy, half; u16 key; int pad; int icon; };
static const struct TouchButton sTouchButtons[] = {
    //  landscape        portrait        half    key            pad                                icon
    { 0.080f, 0.55f,  0.140f, 0.800f, 0.060f, DPAD_LEFT,     SDL_GAMEPAD_BUTTON_DPAD_LEFT,      TB_ICON_NONE  },
    { 0.200f, 0.55f,  0.320f, 0.800f, 0.060f, DPAD_RIGHT,    SDL_GAMEPAD_BUTTON_DPAD_RIGHT,     TB_ICON_NONE  },
    { 0.140f, 0.38f,  0.230f, 0.720f, 0.060f, DPAD_UP,       SDL_GAMEPAD_BUTTON_DPAD_UP,        TB_ICON_NONE  },
    { 0.140f, 0.72f,  0.230f, 0.880f, 0.060f, DPAD_DOWN,     SDL_GAMEPAD_BUTTON_DPAD_DOWN,      TB_ICON_NONE  },
    { 0.930f, 0.52f,  0.860f, 0.780f, 0.070f, A_BUTTON,      SDL_GAMEPAD_BUTTON_SOUTH,          TB_ICON_NONE  },
    { 0.820f, 0.70f,  0.680f, 0.870f, 0.070f, B_BUTTON,      SDL_GAMEPAD_BUTTON_EAST,           TB_ICON_NONE  },
    { 0.560f, 0.90f,  0.580f, 0.955f, 0.048f, START_BUTTON,  SDL_GAMEPAD_BUTTON_START,          TB_ICON_NONE  },
    { 0.440f, 0.90f,  0.420f, 0.955f, 0.048f, SELECT_BUTTON, SDL_GAMEPAD_BUTTON_BACK,           TB_ICON_NONE  },
    { 0.070f, 0.10f,  0.120f, 0.630f, 0.055f, L_BUTTON,      SDL_GAMEPAD_BUTTON_LEFT_SHOULDER,  TB_ICON_NONE  },
    { 0.930f, 0.10f,  0.880f, 0.630f, 0.055f, R_BUTTON,      SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER, TB_ICON_NONE  },
    // Emulator functions, top of screen. key = 0 (not a GBA button); they resolve
    // through the binding table to HOST_PAUSE / HOST_FASTFORWARD.
    { 0.430f, 0.075f, 0.400f, 0.045f, 0.045f, 0, SDL_GAMEPAD_BUTTON_LEFT_STICK,  TB_ICON_PAUSE },
    { 0.570f, 0.075f, 0.600f, 0.045f, 0.045f, 0, SDL_GAMEPAD_BUTTON_RIGHT_STICK, TB_ICON_FF    },
};
#define NUM_TOUCH_BUTTONS ((int)(sizeof(sTouchButtons) / sizeof(sTouchButtons[0])))

// SDL reports up to this many simultaneous fingers; the pad needs at most a
// direction plus two buttons at once.
#define MAX_FINGERS 8
struct Finger { SDL_FingerID id; float x, y; bool active; };
static struct Finger sFingers[MAX_FINGERS];

// Whether a controller is *connected* is the wrong question: one can sit
// paired and idle while the game is played by touch, and the simulator exposes
// a phantom pad that would hide the controls outright. Track which input was
// used last instead -- press a controller and the pad goes away, touch the
// screen and it comes back.
static bool sPadActive;

static bool ShowTouchOverlay(void)
{
    return MOBILE && !sPadActive;
}

static void SetFinger(SDL_FingerID id, float x, float y, bool down)
{
    int free = -1;
    for (int i = 0; i < MAX_FINGERS; i++)
    {
        if (sFingers[i].active && sFingers[i].id == id)
        {
            if (down) { sFingers[i].x = x; sFingers[i].y = y; }
            else      { sFingers[i].active = false; }
            return;
        }
        if (!sFingers[i].active && free < 0)
            free = i;
    }
    if (down && free >= 0)
    {
        sFingers[free].id = id;
        sFingers[free].x = x;
        sFingers[free].y = y;
        sFingers[free].active = true;
    }
}

// Physical output size in pixels. The pad is laid out and hit-tested against
// this, NOT the renderer's logical presentation. The game re-sets the
// presentation every frame (UpdateViewport) to gRenderWidth*scale, which is the
// expanded viewport in the overworld but only 240x160 in menus -- so anchoring
// the pad to it dragged the buttons inward whenever a menu opened. The window
// drawable never moves, so the pad stays fixed on screen. Finger events already
// arrive normalized [0,1] to this same window, so the two spaces line up.
static bool OutputSize(float *w, float *h)
{
    int pw = 0, ph = 0;

    if (sdlWindow == NULL ||
        !SDL_GetWindowSizeInPixels(sdlWindow, &pw, &ph) ||
        pw <= 0 || ph <= 0)
        return false;

    *w = (float)pw;
    *h = (float)ph;
    return true;
}

// True if any active finger falls within button t's hit box. Positions are
// fractions of the window (fingers arrive normalized; buttons are laid out that
// way); w/h are the output pixel size. Buttons are square and sized by the short
// side, so their half-extent differs per axis in normalized space. The box is
// padded outward: thumbs are imprecise and missing a d-pad is far more annoying
// than an occasional overlap.
static bool FingerOnButton(const struct TouchButton *t, float w, float h)
{
    bool portrait = h > w;
    float shortSide = w < h ? w : h;
    float halfPx = (t->half + 0.015f) * shortSide;
    float hx = halfPx / w, hy = halfPx / h;
    float cx = portrait ? t->pcx : t->cx;
    float cy = portrait ? t->pcy : t->cy;

    for (int f = 0; f < MAX_FINGERS; f++)
    {
        if (sFingers[f].active &&
            SDL_fabsf(sFingers[f].x - cx) <= hx &&
            SDL_fabsf(sFingers[f].y - cy) <= hy)
            return true;
    }
    return false;
}

#if MOBILE
// Push the current finger-hit state into the virtual gamepad once per frame.
// SDL turns the changes into ordinary gamepad button events on the next pump,
// so held input, rebind capture and controller detection all treat touch as a
// controller. Buttons only count while the overlay is actually shown.
static void SyncTouchPad(void)
{
    float w, h;
    bool live;

    if (sTouchPadJoy == NULL)
        return;

    live = ShowTouchOverlay() && OutputSize(&w, &h);
    for (int b = 0; b < NUM_TOUCH_BUTTONS; b++)
    {
        const struct TouchButton *t = &sTouchButtons[b];
        bool down = live && FingerOnButton(t, w, h);
        SDL_SetJoystickVirtualButton(sTouchPadJoy, t->pad, down);
    }
}
#endif

// A single flat-shaded triangle (SDL has no fill-triangle call). Used for the
// fast-forward glyph; colour is the same translucent black as the pause bars.
static void FillTri(float x0, float y0, float x1, float y1, float x2, float y2)
{
    SDL_FColor c = { 0.0f, 0.0f, 0.0f, 200.0f / 255.0f };
    SDL_Vertex v[3] = {
        { { x0, y0 }, c, { 0, 0 } },
        { { x1, y1 }, c, { 0, 0 } },
        { { x2, y2 }, c, { 0, 0 } },
    };
    SDL_RenderGeometry(sdlRenderer, NULL, v, 3, NULL, 0);
}

static void DrawTouchOverlay(void)
{
    // Shown whenever there is no controller, rather than waiting for a first
    // touch: a pad nobody can see is a pad nobody knows to use.
    float outW, outH;

    if (!ShowTouchOverlay() || !OutputSize(&outW, &outH))
        return;

    // Draw in raw output pixels, independent of the game's logical presentation
    // (which shrinks to 240x160 in menus and would drag the pad inward). Disable
    // the presentation for the overlay, then restore it -- the next frame's
    // game render re-applies its own via UpdateViewport regardless.
    int lw, lh;
    SDL_RendererLogicalPresentation mode;
    SDL_GetRenderLogicalPresentation(sdlRenderer, &lw, &lh, &mode);
    SDL_SetRenderLogicalPresentation(sdlRenderer, 0, 0, SDL_LOGICAL_PRESENTATION_DISABLED);

    bool portrait = outH > outW;
    float shortSide = outW < outH ? outW : outH;

    for (int b = 0; b < NUM_TOUCH_BUTTONS; b++)
    {
        const struct TouchButton *t = &sTouchButtons[b];
        float h = t->half * shortSide;
        float cx = (portrait ? t->pcx : t->cx) * outW;
        float cy = (portrait ? t->pcy : t->cy) * outH;
        SDL_FRect r = { cx - h, cy - h, h * 2, h * 2 };
        bool on = FingerOnButton(t, outW, outH);

        SDL_SetRenderDrawColor(sdlRenderer, 255, 255, 255, on ? 150 : 55);
        SDL_RenderFillRect(sdlRenderer, &r);
        SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, 110);
        SDL_RenderRect(sdlRenderer, &r);

        // The GBA buttons are identified by position; the two emulator-function
        // buttons get a glyph so they are readable.
        if (t->icon == TB_ICON_PAUSE)
        {
            float bw = h * 0.22f, bh = h * 0.85f, gap = h * 0.14f;
            SDL_FRect p1 = { cx - gap - bw, cy - bh * 0.5f, bw, bh };
            SDL_FRect p2 = { cx + gap,       cy - bh * 0.5f, bw, bh };
            SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, 200);
            SDL_RenderFillRect(sdlRenderer, &p1);
            SDL_RenderFillRect(sdlRenderer, &p2);
        }
        else if (t->icon == TB_ICON_FF)
        {
            float tw = h * 0.55f, th = h * 0.80f;
            float top = cy - th * 0.5f, bot = cy + th * 0.5f;
            float bx = cx - tw * 0.75f;
            FillTri(bx, top, bx, bot, bx + tw, cy);       // first  >
            bx += tw * 0.7f;
            FillTri(bx, top, bx, bot, bx + tw, cy);       // second >
        }
    }

    SDL_SetRenderLogicalPresentation(sdlRenderer, lw, lh, mode);
    SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, 255);
}

static void OpenFirstGamepad(void)
{
    int count = 0;
    SDL_JoystickID *ids = SDL_GetGamepads(&count);
    if (ids)
    {
        for (int i = 0; i < count && sGamepad == NULL; i++)
        {
#if MOBILE
            // The on-screen pad is a gamepad too; never adopt it as the "real"
            // controller, or GamepadKeys would read it twice and touching it
            // would hide its own overlay.
            if (ids[i] == sTouchPadId)
                continue;
#endif
            sGamepad = SDL_OpenGamepad(ids[i]);
        }
        SDL_free(ids);
    }
}

#if MOBILE
static void AttachTouchPad(void)
{
    SDL_VirtualJoystickDesc desc;
    SDL_INIT_INTERFACE(&desc);
    desc.type = SDL_JOYSTICK_TYPE_GAMEPAD;
    // Buttons 0..DPAD_RIGHT, all present and contiguous from zero. SDL maps the
    // Nth set mask bit to raw virtual-button N, so a contiguous-from-zero mask
    // keeps a virtual-button index equal to its SDL_GamepadButton value -- which
    // is what SyncTouchPad relies on when it passes t->pad straight through.
    desc.nbuttons = SDL_GAMEPAD_BUTTON_DPAD_RIGHT + 1;
    desc.button_mask = (1u << (SDL_GAMEPAD_BUTTON_DPAD_RIGHT + 1)) - 1;
    desc.name = "On-Screen Touch Controls";

    sTouchPadId = SDL_AttachVirtualJoystick(&desc);
    if (sTouchPadId == 0)
        return;
    // Open both views now rather than waiting for SDL_EVENT_GAMEPAD_ADDED: the
    // joystick handle sets the virtual buttons, the gamepad handle is read by
    // GamepadKeys, and opening here keeps OpenFirstGamepad from grabbing it.
    sTouchPadJoy = SDL_OpenJoystick(sTouchPadId);
    sTouchPad = SDL_OpenGamepad(sTouchPadId);
}

static void DetachTouchPad(void)
{
    if (sTouchPad) { SDL_CloseGamepad(sTouchPad); sTouchPad = NULL; }
    if (sTouchPadJoy) { SDL_CloseJoystick(sTouchPadJoy); sTouchPadJoy = NULL; }
    if (sTouchPadId) { SDL_DetachVirtualJoystick(sTouchPadId); sTouchPadId = 0; }
}
#endif

static u16 ReadGamepad(SDL_Gamepad *gp)
{
    if (gp == NULL)
        return 0;

    u16 out = 0;
    for (int i = 0; i < NUM_BINDINGS; i++)
    {
        if (sBindings[i].gbaKey != 0 && sBindings[i].pad >= 0
         && SDL_GetGamepadButton(gp, (SDL_GamepadButton)sBindings[i].pad))
            out |= sBindings[i].gbaKey;
    }

    // Analog stick as a d-pad, always on: MFi d-pads vary in quality and the
    // small clip-on controllers are much easier to use on stick. (The virtual
    // touch pad has no axes, so this is a no-op for it.)
    const Sint16 dead = 12000;
    Sint16 ax = SDL_GetGamepadAxis(gp, SDL_GAMEPAD_AXIS_LEFTX);
    Sint16 ay = SDL_GetGamepadAxis(gp, SDL_GAMEPAD_AXIS_LEFTY);
    if (ax < -dead) out |= DPAD_LEFT;
    if (ax >  dead) out |= DPAD_RIGHT;
    if (ay < -dead) out |= DPAD_UP;
    if (ay >  dead) out |= DPAD_DOWN;

    return out;
}

// A real controller and the on-screen touch pad are read the same way and OR'd
// together, so both work at once and both honour the rebindable binding table.
static u16 GamepadKeys(void)
{
    u16 out = ReadGamepad(sGamepad);
#if MOBILE
    out |= ReadGamepad(sTouchPad);
#endif
    return out;
}

u16 Platform_GetKeyInput(void)
{
    // Freeze input while capturing, so the key being bound does not also act.
    if (SDL_GetAtomicInt(&sRebindIndex) >= 0)
        return 0;
    // While the conflict prompt is up the game still needs A/B, so input is
    // NOT frozen here -- only during capture itself. Touch is folded into
    // GamepadKeys via the virtual pad, so it needs no separate term here.
    return keys | GamepadKeys();
}

void ProcessEvents(void)
{
    SDL_Event event;

    while (SDL_PollEvent(&event))
    {
        switch (event.type)
        {
        case SDL_EVENT_QUIT:
            isRunning = false;
            break;

        case SDL_EVENT_WINDOW_RESIZED:
        case SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED:
            UpdateViewport();
            break;

        case SDL_EVENT_KEY_UP:
            // Release ignores modifiers: shift is often let go first, and a
            // button that never clears would stick down.
            for (int i = 0; i < NUM_BINDINGS; i++)
            {
                if (sBindings[i].key == SDLK_UNKNOWN || event.key.key != sBindings[i].key)
                    continue;
                if (sBindings[i].gbaKey != 0)
                    keys &= ~sBindings[i].gbaKey;
                else
                    RunHostAction(sBindings[i].host, FALSE);
            }
            break;

        case SDL_EVENT_KEY_DOWN:
            // While capturing, the next press is bound rather than played.
            if (SDL_GetAtomicInt(&sRebindIndex) >= 0)
            {
                if (event.key.key == SDLK_ESCAPE)
                    Platform_CancelRebind();
                else if (event.key.key == SDLK_F1)
                    Platform_CancelRebind();   // reserved, never bindable
                else if (!IsModifierKey(event.key.key))
                    // Wait for a real key: a bare modifier is half a chord.
                    ApplyRebind(event.key.key, NormalizeMods(event.key.mod), -1);
                break;
            }
            // Press requires the exact chord, so Shift+L does not also fire a
            // plain-L binding and vice versa.
            for (int i = 0; i < NUM_BINDINGS; i++)
            {
                if (sBindings[i].key == SDLK_UNKNOWN || event.key.key != sBindings[i].key
                 || sBindings[i].mod != NormalizeMods(event.key.mod))
                    continue;
                if (sBindings[i].gbaKey != 0)
                    keys |= sBindings[i].gbaKey;
                else
                    RunHostAction(sBindings[i].host, TRUE);
            }
            // Emergency escape hatch: F1 is deliberately not bindable, so a set
            // of bindings that has left the game unplayable -- unbinding A, say
            // -- can always be undone without editing files.
            if (event.key.key == SDLK_F1)
            {
                Platform_ResetBindings();
                break;
            }
            break;

        // Capture pad presses too, so a controller can be rebound from itself.
        case SDL_EVENT_GAMEPAD_AXIS_MOTION:
            // Deadzone: a resting stick drifts, and drift must not count as use.
            if (event.gaxis.value > 8000 || event.gaxis.value < -8000)
                sPadActive = true;
            break;

        case SDL_EVENT_GAMEPAD_BUTTON_DOWN:
        case SDL_EVENT_GAMEPAD_BUTTON_UP:
        {
            bool8 down = (event.type == SDL_EVENT_GAMEPAD_BUTTON_DOWN);
#if MOBILE
            // A press on the virtual pad IS a touch: it must not flip sPadActive
            // (that would hide the overlay being pressed), but it still drives
            // rebind capture and edge-triggered actions below.
            bool8 isTouch = (event.gbutton.which == sTouchPadId);
#else
            bool8 isTouch = FALSE;
#endif
            if (down && !isTouch)
                sPadActive = true;
            if (down && SDL_GetAtomicInt(&sRebindIndex) >= 0)
            {
                ApplyRebind(SDLK_UNKNOWN, 0, event.gbutton.button);
                break;
            }
            // Emulator functions on a pad are edge-triggered here, since
            // GamepadKeys only reports held GBA buttons.
            for (int i = 0; i < NUM_BINDINGS; i++)
            {
                if (sBindings[i].gbaKey == 0 && sBindings[i].pad == event.gbutton.button)
                    RunHostAction(sBindings[i].host, down);
            }
            break;
        }

        // Already converted to logical render coordinates above; the layout is
        // in fractions of that extent, so divide by it on the way in.
        case SDL_EVENT_FINGER_DOWN:
            sPadActive = false;
            SDL_FALLTHROUGH;
        case SDL_EVENT_FINGER_MOTION:
        case SDL_EVENT_FINGER_UP:
        case SDL_EVENT_FINGER_CANCELED:
        {
            bool down = (event.type == SDL_EVENT_FINGER_DOWN ||
                         event.type == SDL_EVENT_FINGER_MOTION);

            // tfinger.x/y are normalized [0,1] to the window -- a stable space
            // that does not move with the game's logical presentation, and the
            // same space the pad is laid out in. Store them directly.
            SetFinger(event.tfinger.fingerID, event.tfinger.x, event.tfinger.y, down);
            break;
        }

        case SDL_EVENT_GAMEPAD_ADDED:
#if MOBILE
            // The virtual touch pad is opened explicitly in AttachTouchPad.
            if (event.gdevice.which == sTouchPadId)
                break;
#endif
            if (sGamepad == NULL)
                sGamepad = SDL_OpenGamepad(event.gdevice.which);
            break;
        case SDL_EVENT_GAMEPAD_REMOVED:
            sPadActive = false;
            if (sGamepad && event.gdevice.which == SDL_GetGamepadID(sGamepad))
            {
                SDL_CloseGamepad(sGamepad);
                sGamepad = NULL;
                OpenFirstGamepad();
            }
            break;

        // iOS terminates suspended apps without warning and without another
        // chance to run, so the save has to be on disk before we return from
        // this handler -- not queued for an exit path that may never execute.
        case SDL_EVENT_WILL_ENTER_BACKGROUND:
            StoreSaveFile();
            if (sAudioStream)
                SDL_PauseAudioStreamDevice(sAudioStream);
            break;
        case SDL_EVENT_DID_ENTER_FOREGROUND:
            if (sAudioStream)
            {
                SDL_ClearAudioStream(sAudioStream);
                SDL_ResumeAudioStreamDevice(sAudioStream);
            }
            break;
        case SDL_EVENT_LOW_MEMORY:
            StoreSaveFile();
            break;
        }
    }

#if MOBILE
    // Reflect this frame's finger state onto the virtual pad; SDL turns the
    // changes into gamepad button events on the next pump.
    SyncTouchPad();
#endif
}

// ---------------------------------------------------------------- saves

static void ResolveSavePath(void)
{
    // On desktop, keep using a save sitting next to the binary if one is already
    // there, so existing saves are not orphaned. Otherwise (and always on iOS,
    // where the bundle is read-only) use the writable preferences directory.
    //
    // This used to return early in the local-save case, which skipped setting
    // sBindPath and skipped LoadBindings entirely: fopen("") then failed on
    // every save, so bindings silently never persisted. Both paths now fall
    // through to the same tail.
    bool8 useLocal = FALSE;
    char *pref = SDL_GetPrefPath("pokeemerald", "pokeemerald64");

#if !MOBILE
    {
        FILE *local = fopen("pokeemerald.sav", "rb");
        if (local != NULL)
        {
            fclose(local);
            useLocal = TRUE;
        }
    }
#endif

    if (useLocal || pref == NULL)
    {
        // controls.cfg always sits beside whichever save is in use
        snprintf(sSavePath, sizeof(sSavePath), "pokeemerald.sav");
        snprintf(sBindPath, sizeof(sBindPath), "controls.cfg");
    }
    else
    {
        snprintf(sSavePath, sizeof(sSavePath), "%spokeemerald.sav", pref);
        snprintf(sBindPath, sizeof(sBindPath), "%scontrols.cfg", pref);
    }

    if (pref != NULL)
        SDL_free(pref);

    SDL_SetAtomicInt(&sRebindIndex, -1);
    SDL_SetAtomicInt(&sConflictIndex, -1);
    LoadBindings();
}

static void ReadSaveFile(const char *path)
{
    sSaveFile = fopen(path, "r+b");
    if (sSaveFile == NULL)
        sSaveFile = fopen(path, "w+b");
    if (sSaveFile == NULL)
        return;

    fseek(sSaveFile, 0, SEEK_END);
    int fileSize = ftell(sSaveFile);
    fseek(sSaveFile, 0, SEEK_SET);

    int bytesToRead = (fileSize < (int)sizeof(FLASH_BASE)) ? fileSize : (int)sizeof(FLASH_BASE);
    int bytesRead = fread(FLASH_BASE, 1, bytesToRead, sSaveFile);

    for (int i = bytesRead; i < (int)sizeof(FLASH_BASE); i++)
        FLASH_BASE[i] = 0xFF;
}

static void StoreSaveFile(void)
{
    if (sSaveFile != NULL)
    {
        fseek(sSaveFile, 0, SEEK_SET);
        fwrite(FLASH_BASE, 1, sizeof(FLASH_BASE), sSaveFile);
        fflush(sSaveFile);
    }
}

void Platform_StoreSaveFile(void)
{
    StoreSaveFile();
}

static void CloseSaveFile(void)
{
    if (sSaveFile != NULL)
    {
        fclose(sSaveFile);
        sSaveFile = NULL;
    }
}

void Platform_ReadFlash(u16 sectorNum, u32 offset, u8 *dest, u32 size)
{
    FILE *savefile = fopen(sSavePath, "r+b");
    if (savefile == NULL)
        return;
    if (fseek(savefile, (sectorNum << gFlash->sector.shift) + offset, SEEK_SET))
    {
        fclose(savefile);
        return;
    }
    if (fread(dest, 1, size, savefile) != size)
    {
        fclose(savefile);
        return;
    }
    fclose(savefile);
}

// ---------------------------------------------------------------- video

void VDraw(SDL_Texture *texture)
{
    // Sized for the largest viewport; only gRenderWidth x gRenderHeight of it
    // is used on any given frame.
    static uint16_t image[2048 * 2048];   // RENDER_MAX_WIDTH/HEIGHT

    memset(image, 0, (size_t)gRenderWidth * gRenderHeight * sizeof(uint16_t));
    DrawFrame(image);

    // Headless verification: EMERALD_DUMP_FRAME=<n> writes frame n to
    // EMERALD_DUMP_PATH as a PPM, so rendering can be checked with no display
    // server. This is how the SDL2 build was validated and how the iOS build
    // will be checked on device.
    {
        extern char *getenv(const char *);
        extern int atoi(const char *);
        static long frame = 0;
        static int want = -2;
        if (want == -2) { const char *e = getenv("EMERALD_DUMP_FRAME"); want = e ? atoi(e) : -1; }
        if (want >= 0 && frame == want) {
            const char *path = getenv("EMERALD_DUMP_PATH");
            FILE *f = fopen(path ? path : "frame.ppm", "wb");
            if (f) {
                fprintf(f, "P6\n%d %d\n255\n", DISPLAY_WIDTH, DISPLAY_HEIGHT);
                for (int i = 0; i < DISPLAY_WIDTH * DISPLAY_HEIGHT; i++) {
                    uint16_t v = image[i];            // ABGR1555: R low, B high
                    unsigned char rgb[3] = {
                        (unsigned char)((v & 0x1F) << 3),
                        (unsigned char)(((v >> 5) & 0x1F) << 3),
                        (unsigned char)(((v >> 10) & 0x1F) << 3) };
                    fwrite(rgb, 1, 3, f);
                }
                fclose(f);
                printf("dumped frame %ld\n", frame);
                fflush(stdout);
            }
        }
        frame++;
    }

    // Unconditionally, not just when the render size changed: that test could
    // only ever fire as a *result* of this call, so it never re-ran. On iOS the
    // real drawable size is not known until the scene lays out, well after the
    // window is created, and the stale size was being stretched over the whole
    // screen -- a non-integer upscale that blurred the game and everything
    // composited with it. Cheap enough to do every frame.
    UpdateViewport();

    if (sSwizzle1555)
    {
        size_t n = (size_t)gRenderWidth * gRenderHeight;
        if (sSwizzleBuf == NULL)
            sSwizzleBuf = SDL_malloc(sizeof(uint16_t) * 2048 * 2048   /* matches image[] above */);
        if (sSwizzleBuf != NULL)
        {
            for (size_t i = 0; i < n; i++)
                sSwizzleBuf[i] = sSwizzleLut[image[i]];
            SDL_UpdateTexture(texture, NULL, sSwizzleBuf, gRenderWidth * sizeof(Uint16));
        }
    }
    else
    {
        SDL_UpdateTexture(texture, NULL, image, gRenderWidth * sizeof(Uint16));
    }
    REG_VCOUNT = 161; // prep for being in VBlank period
}

int DoMain(void *data)
{
    // A soft reset longjmps back here and re-enters AgbMain, which reinitialises
    // the GPU registers, keys, interrupt handlers, sound, RTC and flash. This is
    // not the hardware behaviour of clearing all RAM first -- EWRAM_DATA and
    // IWRAM_DATA are ordinary statics in this build, with no section to zero --
    // but returning to the title screen is far closer than exiting the process.
    setjmp(sResetJmp);
    AgbMain();
    return 0;
}

void VBlankIntrWait(void)
{
    SDL_SetAtomicInt(&isFrameAvailable, 1);
    SDL_WaitSemaphore(vBlankSemaphore);

    // Service a pending soft reset here: this runs on the worker thread, which
    // is the only place DoSoftReset and the longjmp are safe.
    if (SDL_GetAtomicInt(&sResetRequested))
    {
        SDL_SetAtomicInt(&sResetRequested, 0);
        DoSoftReset();
    }
}

// ---------------------------------------------------------------- RTC

u8 BinToBcd(u8 bin)
{
    int placeCounter = 1;
    u8 out = 0;
    do
    {
        out |= (bin % 10) * placeCounter;
        placeCounter *= 16;
    }
    while ((bin /= 10) > 0);

    return out;
}

void Platform_GetStatus(struct SiiRtcInfo *rtc)
{
    rtc->status = internalClock.status;
}

void Platform_SetStatus(struct SiiRtcInfo *rtc)
{
    internalClock.status = rtc->status;
}

static void UpdateInternalClock(void)
{
    time_t rawTime = time(NULL);
    struct tm *time = localtime(&rawTime);

    internalClock.year = BinToBcd(time->tm_year - 100);
    internalClock.month = BinToBcd(time->tm_mon + 1);
    internalClock.day = BinToBcd(time->tm_mday);
    internalClock.dayOfWeek = BinToBcd(time->tm_wday);
    internalClock.hour = BinToBcd(time->tm_hour);
    internalClock.minute = BinToBcd(time->tm_min);
    internalClock.second = BinToBcd(time->tm_sec);
}

void Platform_GetDateTime(struct SiiRtcInfo *rtc)
{
    UpdateInternalClock();

    rtc->year = internalClock.year;
    rtc->month = internalClock.month;
    rtc->day = internalClock.day;
    rtc->dayOfWeek = internalClock.dayOfWeek;
    rtc->hour = internalClock.hour;
    rtc->minute = internalClock.minute;
    rtc->second = internalClock.second;
}

void Platform_SetDateTime(struct SiiRtcInfo *rtc)
{
    internalClock.month = rtc->month;
    internalClock.day = rtc->day;
    internalClock.dayOfWeek = rtc->dayOfWeek;
    internalClock.hour = rtc->hour;
    internalClock.minute = rtc->minute;
    internalClock.second = rtc->second;
}

void Platform_GetTime(struct SiiRtcInfo *rtc)
{
    UpdateInternalClock();

    rtc->hour = internalClock.hour;
    rtc->minute = internalClock.minute;
    rtc->second = internalClock.second;
}

void Platform_SetTime(struct SiiRtcInfo *rtc)
{
    internalClock.hour = rtc->hour;
    internalClock.minute = rtc->minute;
    internalClock.second = rtc->second;
}

void Platform_SetAlarm(u8 *alarmData)
{
    // TODO
}

void SoftReset(u32 resetFlags)
{
    StoreSaveFile();
    // The field's tilemaps are heap-allocated and survive the longjmp, so drop
    // them here or the restarted game leaks them and starts with stale pointers.
    FreeFieldTilemaps();
    if (sAudioStream)
        SDL_ClearAudioStream(sAudioStream);
    longjmp(sResetJmp, 1);
}

#endif // PLATFORM_SDL3
