# Migration: per-OS pointer schemes → one self-relative scheme

## The problem this removes

The game stores "pointers" as **4 bytes packed inside byte streams** (script bytecode,
battle/AI scripts, MP2K sound data) — a GBA-era design where a pointer was 32 bits. On a
64-bit host a real pointer is 8 bytes, so each 4-byte slot needs a trick, and today there are
**three different ones plus an anchor**:

| Target | How a 4-byte packed pointer works today |
|---|---|
| macOS / iOS | `target - gScriptBase` via Mach-O SUBTRACTOR; rebased at read (`gScriptBase + v`) |
| Linux | 4-byte **absolute** (works only because the build is `-no-pie`, image < 4 GB) |
| Android | PC-relative offset + a `.emerald_sptr` side table + a **post-link patcher** that rewrites ~32k slots to `gScriptBase`-relative |

That is the single biggest source of fragility in the port (the cry crash, the Android
patcher, the `-no-pie`/`-z notext`/`CpuSet` guards all descend from it), and every new 64-bit
OS needs its own relocation model figured out from scratch.

## The scheme it moves to: self-relative (PC-relative)

Store `target - slot`; read `slot + storedOffset`. The reader already has the slot address
(`T1_READ_PTR(streamPtr + n)`, `ScriptReadPtr(ctx)` off `ctx->scriptPtr`, `MP2K_event_goto`
off `track->cmdPtr`, …), so no anchor is needed. It is exactly what the Android `sptr` already
stores — **minus the patcher**.

**Emit — one rule for every OS.** `target - .` (`.` = the slot) is a link-time constant on
every target because the slot and the target move together:
* Mach-O: SUBTRACTOR (already in use), resolved at link, no rebase.
* ELF `.so` (Android): `R_*_PC32`, folds under `-Wl,-Bsymbolic`, no dynamic reloc, **no patcher**.
* ELF exe (Linux): folds at link; `-no-pie` no longer required (can ship a normal PIE).

**Read — uniform.** `PTR = slot ? slot + (s32)offset : NULL`. `0` stays the NULL sentinel
(a real pointer never targets its own storage slot, so offset 0 is unambiguous).

**Why 4-byte self-relative rather than native 8-byte.** ~300 battle/AI/contest reads use
hardcoded offsets and strides (`T1_READ_PTR(p + 1); p += 5;`). Self-relative keeps pointers
4 bytes, so those strides never move — a single macro change covers all 300. Native 8-byte
would shift every one and force alignment padding. Self-relative reaches the same
uniform, hack-free end state for a fraction of the churn.

## What stays per-OS (legitimately, not hacks)

Object-format cosmetics only: Mach-O symbol underscores / section names, and exe vs `.so`
vs `.dylib` link mode. No pointer scheme is per-OS anymore.

## Saves are untouched

This is ROM-bytecode only. Save files are a raw byte image of the `SaveBlock*` structs, which
contain no host pointers and are pinned to GBA layout by `STATIC_ASSERT`s. Full backward
compatibility with real-hardware saves is unaffected, and those asserts are a build-time
tripwire if anything ever drifts into the save path.

## Migration phases (each is one commit, compiles, and is independently correct)

Each interpreter migrates its **emit and read together**, isolated from the others, so any
commit is a safe revert point. The old anchor macros stay until the last user is gone.

| Phase | Scope |
|---|---|
| 0 | This document. |
| 1 | **Field-effect scripts** — smallest, self-contained dialect. Proves the mechanism. |
| 2 | **Overworld scripts** (`script.c`/`scrcmd.c`, `ScriptReadPtr`, `event.inc`). Handles the few `msgbox` value-only fallbacks. |
| 3 | **Sound / MP2K** (`music_player.c`/`m4a.c`, `MP2K_event_goto`). |
| 4 | **Battle family** — battle scripts, battle AI, contest AI, battle anim (`T1/T2_READ_PTR`). ~300 reads, one macro change. |
| 5 | **Delete the machinery** — `gScriptBase` + rebase layer, the 3-way emit fork and `.if ELF_BUILD` macro forks → one form, Android `sptr`/`.emerald_sptr`/`elf_script_rebase.py`, `-z notext`/`-no-pie`/`CpuSet` <4 GB guard, GBA-only reader branches. |
| 6 (optional) | **`PtrRebase32`** — the separate task/sprite `data[]` split-pointer problem (~15 files). Not bytecode; can keep a minimal anchor if not worth converting. |

## Validation

* Linux + Android: built/run locally (Android build deferred during this work).
* macOS / iOS: CI builds on every push; runtime confirmation on device.
* Whole-game runtime pass (overworld scripts, battles, AI, sound, field moves) after Phase 4/5,
  plus loading a real-hardware save to confirm saves are byte-identical.

## Status

Phases 0–5 are complete: every bytecode dialect (field effects, overworld
scripts, MP2K sound, battle/AI/contest/anim) reads pointers self-relative, all
`.inc` macros and the sed emit one uniform `.long (target - .)`, and the anchor
read path, the Android `sptr`/`.emerald_sptr`/`elf_script_rebase.py` patcher, and
`-z notext` are deleted. Verified on Linux: clean build, links, boots, title
renders. macOS/iOS/Android are untested during this work and need a build + run.

Phase 6 (`PtrRebase32`) is deferred: it is a separate runtime split-pointer
problem (not bytecode), invasive and collision-prone, and would not remove
`gScriptBase` anyway (`ScriptDataToPtr` keeps it as a runtime base). Not worth
its risk until the phases above are validated on all platforms.

## End state

One emit rule, one read rule, no anchor, no patcher, no `-no-pie`/`-z notext`. A new 64-bit
target becomes "does it link a normal PIE? then pointers work" — no scheme to invent.
