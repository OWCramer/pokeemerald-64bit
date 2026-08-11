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
        SDL_Texture *tex = SDL_CreateTexture(sdlRenderer, SDL_PIXELFORMAT_ABGR1555,
                                             SDL_TEXTUREACCESS_STREAMING,
                                             gRenderWidth, gRenderHeight);
        if (tex != NULL)
        {
            SDL_SetTextureScaleMode(tex, SDL_SCALEMODE_NEAREST);
            SDL_SetTextureBlendMode(tex, SDL_BLENDMODE_NONE);
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
static u16 TouchKeys(void);
static u16 GamepadKeys(void);

int main(int argc, char **argv)
{
    ResolveSavePath();
    ReadSaveFile(sSavePath);

    if (!SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_GAMEPAD))
    {
        DBGPRINTF("SDL could not initialize! SDL_Error: %s\n", SDL_GetError());
        return 1;
    }

#if MOBILE
    // The GBA screen is 3:2 landscape; portrait would waste most of the display.
    SDL_SetHint(SDL_HINT_ORIENTATIONS, "LandscapeLeft LandscapeRight");
#endif

    SDL_WindowFlags flags = SDL_WINDOW_RESIZABLE;
#if MOBILE
    flags |= SDL_WINDOW_FULLSCREEN;
#endif
    sdlWindow = SDL_CreateWindow("pokeemerald",
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

    sdlTexture = SDL_CreateTexture(sdlRenderer,
                                   SDL_PIXELFORMAT_ABGR1555,
                                   SDL_TEXTUREACCESS_STREAMING,
                                   DISPLAY_WIDTH, DISPLAY_HEIGHT);
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
    { 0, HOST_FASTFORWARD,      "FAST FWD", SDLK_SPACE, 0,              -1 }, \
    { 0, HOST_SOFTRESET,        "RESET",    SDLK_R,     SDL_KMOD_LCTRL, -1 }, \
    { 0, HOST_PAUSE,            "PAUSE",    SDLK_P,     SDL_KMOD_LCTRL, -1 }, \
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

// On-screen pad, laid out in the same 240x160 logical space the game renders
// into so the hit boxes and the drawn buttons cannot drift apart. Only shown on
// mobile, and hidden while a controller is attached.
struct TouchButton { float x, y, w, h; u16 key; };
static const struct TouchButton sTouchButtons[] = {
    { 10,  86, 22, 22, DPAD_LEFT  },
    { 54,  86, 22, 22, DPAD_RIGHT },
    { 32,  64, 22, 22, DPAD_UP    },
    { 32, 108, 22, 22, DPAD_DOWN  },
    { 206, 92, 24, 24, A_BUTTON   },
    { 176,106, 24, 24, B_BUTTON   },
    { 132,138, 32, 14, START_BUTTON  },
    {  76,138, 32, 14, SELECT_BUTTON },
    {  10,  8, 26, 14, L_BUTTON   },
    { 204,  8, 26, 14, R_BUTTON   },
};
#define NUM_TOUCH_BUTTONS ((int)(sizeof(sTouchButtons) / sizeof(sTouchButtons[0])))

// SDL reports up to this many simultaneous fingers; the pad needs at most a
// direction plus two buttons at once.
#define MAX_FINGERS 8
struct Finger { SDL_FingerID id; float x, y; bool active; };
static struct Finger sFingers[MAX_FINGERS];
static bool sTouchUsed;   // hide the overlay until the screen is actually touched

static bool ShowTouchOverlay(void)
{
    return MOBILE && sGamepad == NULL;
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

static u16 TouchKeys(void)
{
    u16 out = 0;
    if (!ShowTouchOverlay())
        return 0;
    for (int f = 0; f < MAX_FINGERS; f++)
    {
        if (!sFingers[f].active)
            continue;
        for (int b = 0; b < NUM_TOUCH_BUTTONS; b++)
        {
            const struct TouchButton *t = &sTouchButtons[b];
            // Hit boxes are padded outward; thumbs are imprecise and a miss on
            // a d-pad is far more annoying than an occasional overlap.
            if (sFingers[f].x >= t->x - 4 && sFingers[f].x <= t->x + t->w + 4 &&
                sFingers[f].y >= t->y - 4 && sFingers[f].y <= t->y + t->h + 4)
                out |= t->key;
        }
    }
    return out;
}

static void DrawTouchOverlay(void)
{
    if (!ShowTouchOverlay() || !sTouchUsed)
        return;

    u16 held = TouchKeys();
    for (int b = 0; b < NUM_TOUCH_BUTTONS; b++)
    {
        const struct TouchButton *t = &sTouchButtons[b];
        SDL_FRect r = { t->x, t->y, t->w, t->h };
        bool on = (held & t->key) != 0;
        SDL_SetRenderDrawColor(sdlRenderer, 255, 255, 255, on ? 140 : 60);
        SDL_RenderFillRect(sdlRenderer, &r);
        SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, 120);
        SDL_RenderRect(sdlRenderer, &r);
    }
    SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, 255);
}

static void OpenFirstGamepad(void)
{
    int count = 0;
    SDL_JoystickID *ids = SDL_GetGamepads(&count);
    if (ids)
    {
        if (count > 0 && sGamepad == NULL)
            sGamepad = SDL_OpenGamepad(ids[0]);
        SDL_free(ids);
    }
}

static u16 GamepadKeys(void)
{
    if (sGamepad == NULL)
        return 0;

    u16 out = 0;
    for (int i = 0; i < NUM_BINDINGS; i++)
    {
        if (sBindings[i].gbaKey != 0 && sBindings[i].pad >= 0
         && SDL_GetGamepadButton(sGamepad, (SDL_GamepadButton)sBindings[i].pad))
            out |= sBindings[i].gbaKey;
    }

    // Analog stick as a d-pad, always on: MFi d-pads vary in quality and the
    // small clip-on controllers are much easier to use on stick.
    const Sint16 dead = 12000;
    Sint16 ax = SDL_GetGamepadAxis(sGamepad, SDL_GAMEPAD_AXIS_LEFTX);
    Sint16 ay = SDL_GetGamepadAxis(sGamepad, SDL_GAMEPAD_AXIS_LEFTY);
    if (ax < -dead) out |= DPAD_LEFT;
    if (ax >  dead) out |= DPAD_RIGHT;
    if (ay < -dead) out |= DPAD_UP;
    if (ay >  dead) out |= DPAD_DOWN;

    return out;
}

u16 Platform_GetKeyInput(void)
{
    // Freeze input while capturing, so the key being bound does not also act.
    if (SDL_GetAtomicInt(&sRebindIndex) >= 0)
        return 0;
    // While the conflict prompt is up the game still needs A/B, so input is
    // NOT frozen here -- only during capture itself.
    return keys | GamepadKeys() | TouchKeys();
}

void ProcessEvents(void)
{
    SDL_Event event;

    while (SDL_PollEvent(&event))
    {
        // Touch and mouse arrive in window coordinates; this rewrites them into
        // the 240x160 logical space, which is where the pad is laid out.
        SDL_ConvertEventToRenderCoordinates(sdlRenderer, &event);

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
        case SDL_EVENT_GAMEPAD_BUTTON_DOWN:
        case SDL_EVENT_GAMEPAD_BUTTON_UP:
        {
            bool8 down = (event.type == SDL_EVENT_GAMEPAD_BUTTON_DOWN);
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

        case SDL_EVENT_FINGER_DOWN:
        case SDL_EVENT_FINGER_MOTION:
            sTouchUsed = true;
            SetFinger(event.tfinger.fingerID, event.tfinger.x, event.tfinger.y, true);
            break;
        case SDL_EVENT_FINGER_UP:
        case SDL_EVENT_FINGER_CANCELED:
            SetFinger(event.tfinger.fingerID, event.tfinger.x, event.tfinger.y, false);
            break;

        case SDL_EVENT_GAMEPAD_ADDED:
            if (sGamepad == NULL)
                sGamepad = SDL_OpenGamepad(event.gdevice.which);
            break;
        case SDL_EVENT_GAMEPAD_REMOVED:
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
    char *pref = SDL_GetPrefPath("pokeemerald", "pokeemerald-ios");

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

    // SetRenderExpansionAllowed() runs on the game thread, so the render size
    // can change between frames without a window event.
    if (gRenderWidth != sTextureW || gRenderHeight != sTextureH)
        UpdateViewport();

    SDL_UpdateTexture(texture, NULL, image, gRenderWidth * sizeof(Uint16));
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
