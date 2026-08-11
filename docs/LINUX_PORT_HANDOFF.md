# Linux port: handoff for debugging on real hardware

**Repo:** `OWCramer/pokeemerald-ios` · **Branch:** `native-arm64` · **Commit:** `e28203236`
**Broken artifact:** [v1.0.0 `pokeemerald-x86_64.AppImage`](https://github.com/OWCramer/pokeemerald-64bit/releases/tag/v1.0.0)

The Linux build compiles, links and packages. It does **not** run correctly. There are two
distinct failures, and they almost certainly have different causes. macOS is unaffected and
must stay that way — every ELF change is guarded by `uname`.

The core problem with the work so far: it was only ever tested in Docker on Apple Silicon
(aarch64), and never actually **played**. Linking cleanly was mistaken for working.

---

## The two failures

### 1. Segfault at startup — cause confirmed, fix known

```
[E] pw.loop [loop.c:69 pw_loop_new()] 0x158250c0: can't make support.system handle: No such file or directory
Segmentation fault (core dumped)
```

Ubuntu's `libSDL3` **hard-links** its audio backends instead of dlopening them:

```console
$ readelf -d /usr/lib/x86_64-linux-gnu/libSDL3.so.0 | grep NEEDED
  libasound.so.2   libpipewire-0.3.so.0   libpulse.so.0   libsndio.so.7
```

SDL upstream dlopens all four (`SDL_PIPEWIRE_SHARED=ON` etc.); Ubuntu forced them on. So
`tools/make_appimage.sh` had to bundle them, and bundling `libpipewire` copies the client
library **without its SPA plugin modules** (`/usr/lib/*/spa-0.2/`). That is exactly the
`can't make support.system handle` error, and the segfault follows it.

Bundling more libraries is the wrong direction — the fix is below.

### 2. Graphics corruption before the crash — cause unknown

The GAME FREAK intro renders as black blobs (see the release thread screenshots). Audio
cannot cause this, so it is a second, independent bug.

**Not reproduced** headless on aarch64 (`SDL_VIDEODRIVER=dummy`, 120 s, no crash). It may be
x86_64-specific, or it may need real video. This is the part that needs real hardware.

---

## How the Linux build differs from macOS

Worth understanding before touching anything — the pointer strategy is *deliberately
different per platform*.

GBA data assembly stores 4-byte pointers. On 64-bit hosts those must become real addresses:

- **macOS/arm64** cannot use absolute addresses: PIE is mandatory and `-image_base` is
  ignored. So pointers are stored as **32-bit offsets from an anchor** (`gScriptBase`) and
  rebased at runtime by `SCRIPT_REBASE` / `PTR_REBASE32` (`include/global.h`). This relies on
  Mach-O's `SUBTRACTOR` relocation, which ELF has no equivalent of.
- **Linux** links **`-no-pie`**, so the image sits low, every address fits in 32 bits, and a
  stored pointer is simply absolute. `PORTABLE_ELF` turns `SCRIPT_REBASE`, `PTR_REBASE32`,
  `T1_READ_PTR` and `T2_READ_PTR` into plain casts.

Mechanics:

| Piece | Purpose |
|---|---|
| `ELF_BUILD` defsym | Injected by `ASM_DEFSYMS` ([Makefile](../Makefile)). Selects the branch at **377** pointer sites in `asm/macros/*.inc` (`.if ELF_BUILD` → bare symbol, `.else` → `- _gScriptBase`). |
| `tools/mach_o_symbols.py --elf` | Keeps the 8-byte alignment work (real 64-bit requirement); disables underscore aliasing, `L`-renaming and external prefixing. Exports labels under their own name, including `name::`. |
| `ASM_PSEUDO_OP_CONV` | Forked by `uname`. ELF keeps its own sections and drops the `_` on `gScriptBase`. |
| Link rule | No `-alias_list` (Mach-O only); adds `-no-pie -lm`. |

**Sanity check before anything else** — the binary must be a plain executable, not PIE:

```console
$ file pokeemerald-sdl3
ELF 64-bit LSB executable, x86-64 ... dynamically linked
#                 ^^^^^^^^^^ NOT "pie executable"
```

If it says `pie executable`, `-no-pie` was dropped and **every** stored pointer is truncated
garbage — which would explain corruption comfortably. Check this first on x86_64; it has only
ever been verified on aarch64.

---

## Recommended fix for failure 1: build SDL3 from source

Stop bundling distro audio libraries. Build SDL3 with the backends dlopen'd, so the AppImage
carries only `libSDL3` and SDL loads whatever the host has, degrading gracefully.

```bash
git clone --depth 1 --branch release-3.2.x https://github.com/libsdl-org/SDL
cmake -S SDL -B SDL/build -DCMAKE_BUILD_TYPE=Release \
      -DSDL_PIPEWIRE_SHARED=ON -DSDL_PULSEAUDIO_SHARED=ON \
      -DSDL_ALSA_SHARED=ON -DSDL_SNDIO=OFF -DSDL_STATIC=OFF
cmake --build SDL/build -j"$(nproc)" && cmake --install SDL/build --prefix /usr/local
```

Then `pkg-config` finds it, and the bundling loop in `tools/make_appimage.sh` can go back to
copying `libSDL3` alone. Verify with `readelf -d` that the built `libSDL3.so.0` has **no**
`NEEDED` entry for pipewire/pulse/sndio.

This also fixes macOS: its `26.0` deployment floor exists only because Homebrew's SDL3 was
built there. A from-source build with `-DCMAKE_OSX_DEPLOYMENT_TARGET=11.0` drops it to the
arm64 minimum. See `MACOS_MIN` in the Makefile — it is *derived* from the linked dylib, so it
will follow automatically.

---

## Attacking failure 2 (graphics) on real hardware

In rough order of expected value:

1. **Confirm non-PIE** on x86_64 (above). Cheapest possible check, largest possible cause.
2. **Dump a frame** and compare against the same frame on macOS:
   ```bash
   EMERALD_DUMP_FRAME=400 EMERALD_DUMP_PATH=/tmp/f.ppm ./pokeemerald-sdl3
   ```
3. **Check `PTR_REBASE32`.** On ELF it is a plain cast, so any pointer stored in a pair of
   16-bit task/sprite slots must fit in 32 bits. `gHeap` is static (low) and fine, but a
   `malloc` that lands above 4 GB would be silently truncated. Add a temporary assert in the
   `PORTABLE_ELF` branch of `include/global.h`.
4. **Check struct alignment.** `mach_o_symbols.py` inserts `.balign 8` both ahead of a label
   block and before each `.quad`. Getting this wrong previously produced exactly this class of
   symptom on macOS — a struct field read four bytes off. See the comments in that file; the
   history there is worth reading before changing it.
5. **Bisect the renderer** with `EMERALD_NO_AUDIO=1` to remove the audio thread from the
   picture entirely.

### Diagnostics already in the tree

| Variable | Effect |
|---|---|
| `EMERALD_DUMP_FRAME=<n>` / `EMERALD_DUMP_PATH=<file>` | Write frame *n* as PPM |
| `EMERALD_NO_AUDIO=1` | Disable audio entirely |
| `EMERALD_TRACE_SCRIPTS=1` | Log script bytecode execution |
| `EMERALD_CGB_TRACE=1` | Log CGB channel activity |

`EmeraldLog()` (`src/platform/debug_log.c`) writes `emerald_debug.log` in the working
directory, flushed per line so a segfault cannot eat the last entry. **Inside an AppImage the
working directory may not be writable** — it falls back to `~/Library/Logs` on macOS only, so
add a Linux fallback (`$XDG_STATE_HOME` or `/tmp`) if you need logs from the packaged build.

---

## Building and testing

```bash
# Ubuntu 25.04+ (24.04 does not package libsdl3-dev)
apt-get install -y clang g++ make python3 pkg-config libpng-dev libsdl3-dev
make native -j"$(nproc)"          # -> ./pokeemerald-sdl3
./tools/make_appimage.sh          # -> dist/pokeemerald-<arch>.AppImage
```

CI: [`.github/workflows/build.yml`](../.github/workflows/build.yml) — the Linux job runs in an
`ubuntu:25.04` container and installs `git` *before* checkout, since the container has none.

### Two traps that cost real time

1. **`tools/` binaries are per-platform.** They live in the source tree, not under
   `BUILD_DIR`. Building in a container over a mounted macOS checkout leaves ELF binaries
   where the host expects Mach-O (`cannot execute binary file`). Run `make clean-tools` when
   switching hosts, or copy the tree instead of mounting it.

2. **The Makefile does not track `tools/mach_o_symbols.py` as a prerequisite.** Editing it does
   **not** invalidate the `.o` files. Several conclusions during this work were drawn from
   stale objects. `rm -rf build*` after touching that script, or add it as a dependency of the
   assembly rule.

Use separate outputs so the two platforms cannot clobber each other:

```bash
make native BUILD_DIR=build-linux FILE_NAME=pokeemerald-linux
```

---

## What is known good

- macOS `.app` (arm64) builds, runs and is released. Do not regress it — check `make native`
  on macOS after any shared change.
- Linux compiles, links, and produces a non-PIE ELF with no missing shared libraries.
- The AppImage's bundled libraries resolve on a clean `ubuntu:24.04` with neither SDL3 nor
  sndio installed; the only unresolved ones are the host-provided display stack and ALSA.
- CI is green for both platforms and publishes to a release on a `v*` tag.

None of that establishes that the game *plays* on Linux. That is the open question.
