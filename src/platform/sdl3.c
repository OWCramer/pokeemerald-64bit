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

    simTime = curGameTime = lastGameTime = SDL_GetPerformanceCounter();

    SDL_SetAtomicInt(&isFrameAvailable, 0);
    vBlankSemaphore = SDL_CreateSemaphore(0);

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

// Key mappings
#define KEY_A_BUTTON      SDLK_Z
#define KEY_B_BUTTON      SDLK_X
#define KEY_START_BUTTON  SDLK_RETURN
#define KEY_SELECT_BUTTON SDLK_BACKSLASH
#define KEY_L_BUTTON      SDLK_A
#define KEY_R_BUTTON      SDLK_S
#define KEY_DPAD_UP       SDLK_UP
#define KEY_DPAD_DOWN     SDLK_DOWN
#define KEY_DPAD_LEFT     SDLK_LEFT
#define KEY_DPAD_RIGHT    SDLK_RIGHT

#define HANDLE_KEYUP(key) \
case KEY_##key:  keys &= ~key; break;

#define HANDLE_KEYDOWN(key) \
case KEY_##key:  keys |= key; break;

static u16 keys;

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
    if (SDL_GetGamepadButton(sGamepad, SDL_GAMEPAD_BUTTON_SOUTH))         out |= A_BUTTON;
    if (SDL_GetGamepadButton(sGamepad, SDL_GAMEPAD_BUTTON_EAST))          out |= B_BUTTON;
    if (SDL_GetGamepadButton(sGamepad, SDL_GAMEPAD_BUTTON_START))         out |= START_BUTTON;
    if (SDL_GetGamepadButton(sGamepad, SDL_GAMEPAD_BUTTON_BACK))          out |= SELECT_BUTTON;
    if (SDL_GetGamepadButton(sGamepad, SDL_GAMEPAD_BUTTON_LEFT_SHOULDER)) out |= L_BUTTON;
    if (SDL_GetGamepadButton(sGamepad, SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER))out |= R_BUTTON;
    if (SDL_GetGamepadButton(sGamepad, SDL_GAMEPAD_BUTTON_DPAD_UP))       out |= DPAD_UP;
    if (SDL_GetGamepadButton(sGamepad, SDL_GAMEPAD_BUTTON_DPAD_DOWN))     out |= DPAD_DOWN;
    if (SDL_GetGamepadButton(sGamepad, SDL_GAMEPAD_BUTTON_DPAD_LEFT))     out |= DPAD_LEFT;
    if (SDL_GetGamepadButton(sGamepad, SDL_GAMEPAD_BUTTON_DPAD_RIGHT))    out |= DPAD_RIGHT;

    // Analog stick as a d-pad. MFi controllers vary in how good their d-pads
    // are, and some (the smaller clip-on ones) are much easier to use on stick.
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

        case SDL_EVENT_KEY_UP:
            switch (event.key.key)
            {
            HANDLE_KEYUP(A_BUTTON)
            HANDLE_KEYUP(B_BUTTON)
            HANDLE_KEYUP(START_BUTTON)
            HANDLE_KEYUP(SELECT_BUTTON)
            HANDLE_KEYUP(L_BUTTON)
            HANDLE_KEYUP(R_BUTTON)
            HANDLE_KEYUP(DPAD_UP)
            HANDLE_KEYUP(DPAD_DOWN)
            HANDLE_KEYUP(DPAD_LEFT)
            HANDLE_KEYUP(DPAD_RIGHT)
            case SDLK_SPACE:
                if (speedUp)
                {
                    speedUp = false;
                    timeScale = 1.0;
                }
                break;
            }
            break;

        case SDL_EVENT_KEY_DOWN:
            switch (event.key.key)
            {
            HANDLE_KEYDOWN(A_BUTTON)
            HANDLE_KEYDOWN(B_BUTTON)
            HANDLE_KEYDOWN(START_BUTTON)
            HANDLE_KEYDOWN(SELECT_BUTTON)
            HANDLE_KEYDOWN(L_BUTTON)
            HANDLE_KEYDOWN(R_BUTTON)
            HANDLE_KEYDOWN(DPAD_UP)
            HANDLE_KEYDOWN(DPAD_DOWN)
            HANDLE_KEYDOWN(DPAD_LEFT)
            HANDLE_KEYDOWN(DPAD_RIGHT)
            case SDLK_R:
                if (event.key.mod & SDL_KMOD_CTRL)
                    SDL_SetAtomicInt(&sResetRequested, 1);
                break;
            case SDLK_P:
                if (event.key.mod & SDL_KMOD_CTRL)
                    paused = !paused;
                break;
            case SDLK_SPACE:
                if (!speedUp)
                {
                    speedUp = true;
                    timeScale = 5.0;
                }
                break;
            }
            break;

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
    // there, so existing saves are not orphaned by this change. Otherwise (and
    // always on iOS, where the bundle is read-only) use the platform's writable
    // preferences directory.
#if !MOBILE
    FILE *local = fopen("pokeemerald.sav", "rb");
    if (local)
    {
        fclose(local);
        snprintf(sSavePath, sizeof(sSavePath), "pokeemerald.sav");
        return;
    }
#endif
    char *pref = SDL_GetPrefPath("pokeemerald", "pokeemerald-ios");
    if (pref)
    {
        snprintf(sSavePath, sizeof(sSavePath), "%spokeemerald.sav", pref);
        SDL_free(pref);
    }
    else
    {
        snprintf(sSavePath, sizeof(sSavePath), "pokeemerald.sav");
    }
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
    static uint16_t image[DISPLAY_WIDTH * DISPLAY_HEIGHT];

    memset(image, 0, sizeof(image));
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

    SDL_UpdateTexture(texture, NULL, image, DISPLAY_WIDTH * sizeof(Uint16));
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
    if (sAudioStream)
        SDL_ClearAudioStream(sAudioStream);
    longjmp(sResetJmp, 1);
}

#endif // PLATFORM_SDL3
