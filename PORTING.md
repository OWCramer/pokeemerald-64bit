# Native 64-bit port (macOS / arm64), toward iOS

This documents the `NATIVE64` build added on top of Kurausukun's `pc_port`
branch. `pc_port` targets 32-bit Windows via mingw-gcc; this target builds a
native arm64 Mach-O binary with clang, which is the prerequisite for iOS
(iOS has been 64-bit only since iOS 11, so the 32-bit escape hatch that the
Android ports use is unavailable).

## Status

| Area | State |
|---|---|
| C sources | 322 / 322 compile |
| Data assembly | 15 / 15 assemble |
| Sound / MIDI | ~530 objects |
| Link | clean |
| Boot + render | working — full intro sequence animates |
| RTC | working — reads the host clock |
| Audio | working — all 12 PCM + 4 CGB channels, band-limited PSG |
| SDL3 target | working — `make native` |

## Building

```bash
make native            # arm64 release build -> ./pokeemerald
make native DINFO=1    # -O0 -g, for debugging
./pokeemerald
```

Requires Homebrew `sdl3`, `libpng`, `pkg-config`. No ROM is
needed: this decomp builds from checked-in assets.

Useful knobs:

- `NATIVE_OPT=n` — optimisation level (default 3).
- `ASAN=1`, `UBSAN=1` — sanitizer builds.
- `MEMGUARD=1` — poison and check guard regions past the emulated hardware
  blocks each frame; catches overruns ASan cannot see.
- `EMERALD_NO_AUDIO=1` — disable the mixer (diagnostic only; audio works).
- `EMERALD_AUDIO_STATS=1` — print mixer peak amplitude, call rate, byte rate
  and SDL queue depth periodically.
- `EMERALD_DUMP_WAV=<file>` — capture the exact buffer handed to SDL as a
  32-bit float stereo WAV. This is ground truth for audio work: the same data
  the device plays, analysable offline instead of argued about.
- `EMERALD_PSG_OVERSAMPLE=n` — PSG oversampling ratio (default 16; `1` restores
  the old point-sampled behaviour for A/B).
- `EMERALD_DUMP_FRAME=<n> EMERALD_DUMP_PATH=<file.ppm>` — write frame *n* to a
  PPM. This is headless, so rendering can be verified with no display server —
  useful over SSH and, later, for automated checks on device.

## Why the port needed more than a compiler switch

The GBA is a 32-bit machine and the decomp encodes that in three places:

1. **C structs** whose layouts change when pointers grow to 8 bytes.
2. **Hand-written assembly data** that emits pointers as `.4byte`/`.int`.
3. **Script bytecode**, where pointers sit *inside* packed instruction streams
   that the engines walk with hardcoded strides.

(1) and (2) are mechanical. (3) is the interesting one and drives the design.

### The anchor-offset scheme

Widening bytecode pointers to 8 bytes would invalidate every hardcoded stride —
`src/battle_script_commands.c` alone has 175 literal `gBattlescriptCurrInstr +=
N` sites. Instead, bytecode pointers stay **4 bytes** and hold a signed offset
from a single anchor symbol, `gScriptBase` (defined in `src/script.c`):

- Assembly emits `.long (target - _gScriptBase)`.
- `SCRIPT_REBASE()` in `include/global.h` adds the anchor back on read; the
  existing `T1_READ_PTR` / `T2_READ_PTR` macros route through it, which covers
  ~317 call sites without touching any of them.
- Offset 0 encodes NULL (the anchor is never a real target).

**Every stride stays valid.** Mach-O expresses these as SUBTRACTOR+UNSIGNED
relocation pairs, which resolve correctly across object files.

This also sidesteps a hard Mach-O constraint: **a relocated 8-byte pointer must
be 8-byte aligned.** Packed instruction streams cannot honour that, so inline
pointers *have* to be 4-byte offsets. Struct fields, which can be padded, use
real `.quad` pointers.

### Struct layouts were measured, not guessed

Every re-laid-out struct came from compiling a probe that prints `sizeof` and
`offsetof`, then matching the assembly emission to it. Worked examples:

| Struct | GBA | 64-bit | Note |
|---|---|---|---|
| `ObjectEventTemplate` | 24 | 32 | `script` at 16, 6 bytes tail padding |
| `CoordEvent` | 16 | 24 | `script` at 16 |
| `BgEvent` | 12 | 16 | union at 8 |
| `MapEvents` | 20 | 40 | counts, pad to 8, four pointers |
| `MapConnection` | 12 | 12 | unchanged — `offset` is `s32`, not a pointer |
| `MapLayout` | 24 | 40 | `width`/`height` stay **4 bytes** |
| `MusicPlayer` | 12 | 24 | |
| `Song` | 8 | 16 | |
| `MP2KInstrument` | 12 | 24 | both unions are pointer-sized |

Do not shortcut this. A blanket `.4byte` → `.quad` rewrite silently widened
`MapLayout`'s `s32 width`/`height` and corrupted the struct; the conversion must
be **symbolic-only**.

`SoundInfo` (m4a) and `SoundMixerState` (mixer) alias the same `gSoundInfo`
object and had diverged by 16 bytes on 64-bit: `SoundInfo` used `u8 gap2[16]` to
stand in for four pointers, which is 16 bytes at 32-bit but must be 32 at
64-bit. The mixer was writing past the allocation. Both views now agree exactly
(`chans` at 136, both 40448 bytes). When two structs alias, **compare their
field offsets, not just their sizes.**

## The build pipeline

```
preproc -> cpp -> preproc -> expand_includes.py -> sed -> mach_o_symbols.py -> clang
```

- **`tools/expand_includes.py`** inlines `.include` *before* filtering. The
  assembler would otherwise resolve those itself, so everything reached that way
  — the mapjson-generated `header.inc` / `layouts.inc` / `connections.inc`, the
  shared constants, the specials table — never saw the pointer widening. Macro
  definition files are deliberately *not* expanded: their bodies are widened
  conditionally by `.ifdef PORTABLE_ASM` and must stay intact.
- **`tools/mach_o_symbols.py`** handles symbol naming and alignment.
- **`tools/gen_macho_aliases.sh`** generates a bidirectional `-alias_list` at
  link time for references no text filter can reach (macros expand *after*
  filtering, and some take parenthesised expressions like
  `setbyte (gBattleScripting + 0x0E), 2` that cannot be prefixed textually).

## clang vs GNU as: the incompatibility catalogue

Each of these cost real time; they are listed so they need not be rediscovered.

- **`;` is a comment**, not a statement separator. `preproc` turns `label::` into
  `label: ; .global label`, which silently drops the export. Worse, cpp expands
  `FOREACH_TM` into one line of `enum A; enum B; ...`, so only the *first* entry
  is ever defined. TM/HM constants are therefore generated as flat one-per-line
  `.set`s in `constants/tms_hms_flat.inc`, and the upstream enum emission is
  guarded off with `.ifndef PORTABLE_ASM`.
- **Macro arguments must be comma-separated.** GNU as accepts whitespace;
  `script_cmd_table_entry` was invoked that way in 225 places.
- **No `--defsym`.** Symbols are injected as `.set` lines instead. Note that
  `PORTABLE` itself must be set: `sound/music_player_table.inc` keys a `.bss`
  allocation on it, and without it assembly reserves 80-byte GBA-sized track
  slots that C then overruns with 112-byte structs.
- **Macro nesting caps at 20**, and `-Xclang -asm-macro-max-nesting-depth` is
  *accepted but ignored*. Inline conditionals with `.ifc` rather than adding a
  helper macro layer.
- **Divided label differences don't fold** — `.byte (.Lb - .La) / 2`. Use `.irp`
  to count varargs instead.
- **`symbol == .` and `. - symbol` cannot be folded** inside `.if`.
- **Undefined symbols in `.if` are an error**, not 0. `STR_VAR_1..3` are charmap
  entries, not constants, so they are given absolute values.
- **`label == FALSE` for optional macro args** must become `.ifb`.
- **`.size` is ELF-only.**
- **`L`-prefixed symbols are file-local** on Mach-O and cannot be `.globl`'d.
  Keep the bare definition and export a `_L…` alias; rename references, but only
  for `L`-prefixed names, so macro keyword arguments (`waitstate implicit=1`)
  are left alone. Uniform renaming breaks those.
- **Alias only `::` (global) labels.** Several files legitimately reuse local
  label names — `AI_CheckBadMove` existed in both the battle and contest AI
  scripts, so the contest one was renamed.
- **Assembler constants cannot cross objects via 16-bit relocations.**
  `def_special` now `.set`s its index unconditionally so every including file
  gets a local absolute.

## The audio bug (resolved)

Three separate 64-bit layout faults, all from GBA-sized constants surviving into
a 64-bit build. Each is worth knowing because the same shape recurs:

1. **Song headers were 4-byte aligned.** Each song has an `.align 2` before its
   header, written `.align`<TAB>`2`. The build's rewrite rule matched `.align`
   <SPACE>`2`, so it never converted. The header then sat at an address 4 mod 8,
   the `.balign 8` before its pointers became a no-op, and C read `part[0]`
   straddling two pointers. That was the segfault.
2. **Voicegroup bases used `sizeof(ToneData)` from the GBA.** `voice_group`
   computes `. - starting_note * 0xC`; an instrument is 24 bytes on a 64-bit
   host, so any voicegroup with a `starting_note` resolved to the wrong base.
3. **`_voice_square_1` and `_voice_square_2` emitted 12 bytes, not 24.** The
   other five voice macros had been widened; these two were missed. Being
   half-size, they shifted every later entry in their voicegroup — which sounded
   like missing CGB channels plus wrong notes.

The lesson worth carrying: **assert the emitted size of every struct a macro
produces.** Assembling one instance of each voice macro and diffing symbol
addresses found (3) in seconds after hours of guessing.

Also fixed while here: `SDL_RenderPresent` was called unconditionally each outer
loop iteration while `RenderCopy` only ran when a new frame was ready, so
iterations with no new frame presented an undrawn back buffer — a black flicker
every few frames. It now presents only when something was drawn, with a 1 ms
yield otherwise (vsync in `RenderPresent` had been pacing that loop).

## PSG aliasing, and why a low-pass could not fix it

The CGB channels sounded harsh next to real hardware, with a phantom bass note
under high effects like `SE_SELECT` that outlasted the note itself. Two distinct
causes, and the second is the instructive one:

1. **Sweep overflow wrote the clamped frequency back.** Hardware disables the
   channel on overflow and leaves NR13/NR14 alone. Writing 0 back meant
   131072/2048 = 64Hz — a five-octave-below drone that kept playing.
2. **Naive wavetable synthesis aliased.** The three wavetable channels stepped a
   32-entry duty table with `(int)` truncation and no band limiting. For the
   3121Hz menu ping that is ~2.4 entries per output sample, and the harmonics
   above Nyquist fold back down:

   | harmonic | true | folds to |
   |---|---|---|
   | 13th | 40570 Hz | 1490 Hz |
   | 27th | 84262 Hz | **142 Hz** |

   142Hz is 4.5 octaves below the fundamental — exactly the reported artifact.

**A low-pass at the output rate cannot repair this, and one was tried first.**
By the time the signal reaches the output the aliased energy is *already at
142Hz*; no filter can separate it from real bass. That attempt was measurably a
no-op and the A/B was audibly identical, which is itself the diagnostic: if a
10kHz filter changes nothing, the problem is not above 10kHz.

The fix is to not create the aliases: generate the wavetable channels at 16x the
output rate and decimate through a 32-tap windowed sinc. Measured energy in the
80-400Hz band, for an isolated 3121Hz 12.5%-duty square:

| synthesis | 80-400 Hz junk |
|---|---|
| ideal band-limited (target) | -125 dB |
| naive point-sample (before) | -32 dB |
| 8x oversample + sinc | -57 dB |
| 16x oversample + sinc (now) | -66 dB |

Oversampling ratio is the only lever that matters — tap count and cutoff barely
move the number, because the residual comes from point-sampling at the *inner*
rate, not from the decimation filter. Hence only 32 taps. In-game capture of the
actual menu ping shifted the 80-400Hz band from +4.9dB to -2.6dB relative to the
ping (less than the isolated-tone figure, because real menu music has genuine
bass there).

Noise (ch4) is left at 1x: it is broadband and already averages its sub-steps.

### Output rate

The mixer generates `pcmSamplesPerVBlank = 701` samples per V-blank at 60Hz, so
its true rate is **701 x 60 = 42060 Hz**. The SDL device had been opened at
42048, and the 12Hz mismatch showed up as a slowly growing queue. Now matched:
measured output is 336480 B/s against 336480 B/s required, and queue depth is
flat.

## Comparison with NTx86/pokeemerald-sdl2pc `pc_port-64-bits`

An independently maintained 64-bit fork of the same `pc_port`, merged with pret
as of July 2026. It is worth knowing about, and it independently confirms part of
the analysis here — its commit 548e976 fixes the `voice_group` macro for the
24-byte instrument size, the same bug found here. Its CGB audio is essentially
identical to ours, so it does **not** address the aliasing above.

It solves the bytecode-pointer problem the opposite way: pointers widen to 8
bytes (`T1_READ_64`), macros emit `.quad` unconditionally, and all ~175 hardcoded
strides were rewritten symbolically as `gBattlescriptCurrInstr += DSIZE8BIT +
DSIZEPTR`. That is a legitimate design, and on ELF/PE it works.

**It cannot work on Mach-O.** An 8-byte relocated pointer must be 8-byte aligned,
and pointers inside packed bytecode are at odd offsets by construction. Verified
directly:

```
ld: pointer not aligned in '_target'+0x2
clang: error: linker command failed with exit code 1
```

So the anchor-offset scheme here is a requirement of the target, not a
preference. The fork also targets Windows via mingw and GNU `as` (`--64`,
`--defsym`), so none of the clang/Mach-O assembler work above is done there.

What is worth harvesting from it: the `DSIZEPTR` stride rewrites are a cleaner
expression of intent than bare literals even when the value is 4, and its pret
merge is newer than ours.

## Pointers split across two 16-bit slots

The intro crashed in `Task_HandleMonAnimation` the moment Birch throws out a
Pokemon, on a wild address. The cause is a second, entirely separate 32-bit
assumption from the script bytecode one:

```c
gTasks[taskId].tPtrHi = (u32)(sprite) >> 16;   // store
gTasks[taskId].tPtrLo = (u32)(sprite);
#define ANIM_SPRITE(taskId) ((struct Sprite *)((tPtrHi << 16) | (u16)tPtrLo))
```

The game stores plain C pointers by splitting them across two **16-bit** task or
sprite data slots. That is lossless on the GBA. On a 64-bit host `(u32)ptr`
discards the top half, and the rejoined value is a wild pointer. The two crash
addresses gave it away immediately -- `0x211ea4e` and `0x590aa4e`, differing in
their high bits but sharing their low ones.

This is a **class**, not a site: 52 files contain the pattern, with 38 stores and
75 rejoins (though most of the rejoins are ordinary 32-bit value packing --
`otId`, palette selectors, text lookups -- and only about 20 are pointers).
Fixing only the one that crashed would just move the crash.

The top half is recoverable rather than lost, because everything stored this way
points inside the loaded image: code, statics, or `gHeap`, which is a static
array carved up by `AllocInternal`, **not** system malloc. So the distance from
any image symbol to any other fits in a signed 32-bit offset regardless of where
ASLR maps the image, and `PTR_REBASE32` in `include/global.h` supplies the
missing half from the same `gScriptBase` anchor the bytecode uses.

Two things worth knowing:

- **Only the loads need fixing.** The stores already write the correct low 32
  bits, so 38 of the sites need no change at all.
- **A stored 0 must stay NULL.** Rebasing it would yield the anchor's high half
  instead of a null pointer, and callers do test these (an absent followup task
  function, for one).

Linking the image below 4GB would sidestep all of this, and was tried first --
but arm64 mandates PIE and the linker ignores `-image_base`:

```
ld: warning: Linking with PIE, -image_base will be ignored
ld: warning: -no_pie ignored for arm64
```

Verified by probing the rebased pointer at the crash site: `sprite=0x105d9aa08`,
inside `gSprites` at offset 96. The truncated value would have been
`0x05d9aa08` -- the leading `0x1` is exactly what was being lost.

## The 32-bit pointer classes, and how each was found

Everything above the SDL layer keeps producing the same shape of bug: the GBA
stored a pointer in 32 bits, and this codebase does that through many different
idioms, so each needs its own search to find. Six distinct ones so far:

| idiom | where | how it failed |
|---|---|---|
| `(u32)ptr >> 16` into two `s16` slots | ~20 sites | wild pointer in `Task_HandleMonAnimation` |
| `Set/GetWordTaskArg` (same split, behind a helper) | 13 sites | `Free` of a truncated buffer, wall clock |
| raw `T1/T2_READ_32` cast to a pointer | `battle_anim.c` x3 | would crash on the first battle animation |
| `FieldEffectScript_ReadWord` cast to a pointer | `field_effect.c` x4 | `callnative` jumped to `0xffa60bf6` |
| `SetU32` into a `u8 *` | `battle_setup.c` | no rebase *and* only 4 of 8 bytes written |
| `SCRIPT_REBASE` evaluating its argument twice | `include/global.h` | every script pointer operand read 8 bytes |
| an accessor *declared* `u32` returning a pointer | `GetWindowAttribute` | blank pocket names in the bag |
| reassembled into a local, cast to a pointer on the **next line** | `SetCallbackToStoredInData6` | every battle animation |

**The diagnostic tell is the faulting address.** A wild address that looks like a
small offset (`0x203edf8`, `0x1800d21`) rather than a real image address
(`0x1xxxxxxxx`) means a truncated or unrebased pointer, and the crashing frame
names the idiom. That turns each of these from an investigation into a lookup.

Roughly twenty other raw 32-bit reads in the tree are genuine values -- `status`,
`flags`, `otId` -- and must be left alone, so a blanket rewrite is not an option;
each site has to be classified.

Two of these hid from earlier sweeps in ways worth remembering:

- **The truncation can be in a return type.** `GetWindowAttribute` was declared
  `u32`, so all ten call sites cast the result back to a pointer *correctly* and
  still got a broken one. Grepping call sites finds nothing; the declaration is
  the bug.
- **The reassembly and the cast can be on different lines.** Every regex used up
  to that point required `<< 16` and the pointer cast on one line, so
  `SetCallbackToStoredInData6` -- which every battle animation depends on --
  survived four separate sweeps.

A truncated pointer is also easy to mistake for a valid one: `VRAM_` is
allocated around `0x1060xxxxx`, so a truncated VRAM pointer reads as
`0x0600xxxx`, which looks exactly like a real GBA VRAM address.

`CpuSet` now reports these rather than faulting on them (see `src/platform/bios.c`).
The test is exact: macOS arm64 reserves the low 4GB as `__PAGEZERO`, so any
pointer below `0x100000000` has lost its top half. Do not replace it with a
distance-from-anchor heuristic -- an earlier attempt at that rejected legitimate
copies and broke menu rendering.

### The one that was not a pointer bug

`MapHeaderCheckScriptTable` always returned NULL, so no map ran its
`ON_FRAME_TABLE` scripts and the Littleroot intro never started. The data was
perfect -- every byte of the table verified against `nm`. The cause was that
`gScriptBase` is defined as `const u8 gScriptBase[1] = {0}` in `src/script.c`,
so *within that file* the compiler can see the whole object, knows every rebased
address is outside a one-byte array, and treats reads through it as undefined.
It folded them to the array's known zero and deleted the loop body as dead code.

The tell: a `printf` probe compiled but did not appear in the object file. When
instrumentation vanishes, the compiler has proved the code unreachable -- that
is a finding, not a broken probe.

`ScriptRebase` now launders the anchor through an empty `asm` barrier. Anything
else that both defines and dereferences an undersized anchor array will hit this
same trap.

## Audio bugs that were not pointer bugs

Two failures in the portable MP2K player, both distinct from the 32-bit classes
above and worth recording because the diagnosis path was different:

- **XCMD (0xCD) had no handler.** The event table dispatches `event - 0xB1`, so
  0xCD landed at index 28 -- which held `MP2K_event_fine`, *ending the track*.
  Any song reaching an extended command died on the spot. Only the portable
  table was missing it: `ply_xcmd`, its thirteen sub-commands, and the mixer
  code consuming the result all already existed. A few table slots are
  legitimately `MP2K_event_fine` (0xB6-0xB9, 0xC6, 0xC7, 0xC9-0xCB); any of
  those appearing in real song data would fail the same way.

- **Nothing re-enabled a CGB channel.** Two paths clear a channel's enable bit
  in NR52 -- a length counter expiring, and a sweep overflow -- but
  `cgb_trigger_note` did not model the hardware behaviour where writing the
  trigger bit to NRx4 turns the channel back on. So the first sweep overflow
  silenced square 1 for the entire session, and every later note on it was
  programmed correctly into a dead channel.

The second was a regression from this port's own sweep-overflow fix, and the
lesson generalises: **when emulating a hardware state change, check that the
inverse transition is modelled too.** Disabling on overflow was correct; it was
only safe alongside an enable that did not exist.

Both were found by tracing outward from the symptom -- song start/stop, then
note allocation, then the CGB envelope, then the literal register writes. The
register dump is what settled it (`NR52=0x8E`, channel 1's enable bit clear
while every other value was correct), and that trace is worth reaching for early
next time rather than last.

## The SDL3 target

`make native` builds `./pokeemerald64` against SDL3 from
`src/platform/sdl3.c`, which was written for iOS directly. The old SDL2 platform
layer (`src/platform/sdl2.c`) and the 32-bit Windows layer (`win32.c`) have been
removed along with their build paths; SDL3 is the only platform target.

What SDL3 buys, all of it iOS-relevant:

- **`SDL_AudioStream`** replaces `SDL_QueueAudio`. It re-binds itself when the
  default device changes, which on iOS happens whenever headphones connect or a
  call interrupts. Measured queue depth is *steadier* than SDL2's: 17.5-18.3KB
  across 90s versus 14.2-20.5KB.
- **`SDL_Gamepad`** gives MFi controllers with no extra code, plus analog stick
  mapped to the d-pad.
- **Touch** events arrive in render coordinates via
  `SDL_ConvertEventToRenderCoordinates`, so the on-screen pad is laid out in the
  same 240x160 space the game draws into and the hit boxes cannot drift from the
  drawn buttons. Hit boxes are padded 4px outward; thumbs are imprecise.
- **`SDL_EVENT_WILL_ENTER_BACKGROUND`** flushes the save synchronously. iOS kills
  suspended apps with no further chance to run, so the write has to complete in
  the handler rather than on an exit path that may never execute.
- **Letterbox** logical presentation rather than stretch — every iPhone is wider
  than the GBA's 3:2.

Saves move to `SDL_GetPrefPath`, except that on desktop an existing
`./pokeemerald.sav` is still preferred so current saves are not orphaned.

### Verifying the port

Frame 300 was dumped from both builds with `EMERALD_DUMP_FRAME` and compared:
**byte-identical**. That is the cheapest possible proof that the rendering path
survived the rewrite, and it needs no display server — the same technique will
work on device.

## Toward iOS

The hard parts are done: no JIT is involved (this is a native recompile, so the
W^X restriction that hampers emulators does not apply), rendering is a software
PPU blitting one texture, and the RTC already reads the host clock.

Remaining work, roughly in order:

1. ~~Rewrite against SDL3~~ — done, `make native`.
2. ~~Touch controls~~ / ~~gamepad~~ / ~~background save flush~~ — done in
   `sdl3.c`, but the touch overlay has only been exercised on desktop; the
   layout needs tuning against a real thumb on a real phone.
3. Xcode target compiling `src/**` plus `src/platform/{sdl3,bios,dma,
   gba_fast_draw,cgb_audio,nostd}.c`; keep using the Makefile for asset
   generation. Saves want `UIFileSharingEnabled` so they can be pulled off the
   device, which means preferring `Documents/` over `SDL_GetPrefPath` on iOS.
4. Cross-compile check: the assembly pipeline emits arm64 Mach-O already, so it
   should carry over, but `-target arm64-apple-ios` has not been tried yet.

Distribution is sideloading only (free Apple ID for 7 days, paid for a year, or
AltStore/SideStore). The build output contains Nintendo's assets, so it is for
personal use.
