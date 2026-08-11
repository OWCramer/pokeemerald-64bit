# Native 64-bit host build (SDL3). This tree builds host binaries only:
#   - Linux / macOS  against the system SDL3
#   - iOS            against a static SDL3 (make ios)
#   - Android        as libmain.so (make android)
# The GBA ROM (agbcc / arm-none-eabi), 32-bit Windows (mingw), and SDL2 build
# paths have been removed -- this project never ships a GBA ROM or a Windows exe.
# See PORTING.md and docs/POINTER_MIGRATION.md.

NATIVE64        := 1
PORTABLE        := 1
MODERN          := 1
SDL3            := 1
TARGET_PLATFORM := PLATFORM_SDL3
TILE_RENDERER   := RENDERER_FAST_DRAW

# iOS is arm64 Mach-O with mandatory PIE, exactly like macOS/arm64, so it reuses
# the whole native path -- the anchor-offset pointer scheme, mach_o_symbols.py
# and the alias-list link all apply unchanged. Only the target triple, sysroot
# and SDL flags differ.
ifneq (,$(filter ios,$(MAKECMDGOALS)))
  IOS := 1
endif
IOS ?= 0
ifeq ($(IOS),1)
  IOS_SDK_NAME ?= iphonesimulator
  IOS_MIN ?= 15.0
  IOS_SYSROOT := $(shell xcrun --sdk $(IOS_SDK_NAME) --show-sdk-path)
  ifeq ($(IOS_SDK_NAME),iphonesimulator)
    IOS_TRIPLE := arm64-apple-ios$(IOS_MIN)-simulator
  else
    IOS_TRIPLE := arm64-apple-ios$(IOS_MIN)
  endif
  # Both the compiler and the assembler need this; the data assembly is a large
  # part of the build and silently lands on the host target otherwise.
  IOS_TARGET_FLAGS := -target $(IOS_TRIPLE) -isysroot $(IOS_SYSROOT)
endif
# Android is ELF/arm64 or x86_64 with mandatory PIE. It uses the same uniform
# self-relative pointer scheme as every other 64-bit target: 4-byte script
# pointers are emitted as `.long (target - .)` (an offset from their own slot,
# see docs/POINTER_MIGRATION.md), folded to a constant under -Bsymbolic with no
# dynamic relocation and no post-link patcher. It differs from iOS/macOS only in
# object format (ELF vs Mach-O) and link mode (.so vs alias-list).
ifneq (,$(filter android,$(MAKECMDGOALS)))
  ANDROID := 1
endif
ANDROID ?= 0
ifeq ($(ANDROID),1)
  ANDROID_ABI  ?= x86_64
  ANDROID_API  ?= 21
  ANDROID_NDK  ?= $(HOME)/Android/Sdk/ndk/30.0.15729638
  NDK_BIN      := $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin
  ifeq ($(ANDROID_ABI),arm64-v8a)
    ANDROID_TRIPLE := aarch64-linux-android
  else
    ANDROID_TRIPLE := $(ANDROID_ABI)-linux-android
  endif
  ANDROID_CC   := $(NDK_BIN)/$(ANDROID_TRIPLE)$(ANDROID_API)-clang
  ANDROID_SDL  ?= build-android/SDL
  ANDROID_JNILIBS := android/app/src/main/jniLibs/$(ANDROID_ABI)
endif

# `File name` for the built binary.
FILE_NAME := pokeemerald
BUILD_DIR := build

# Default make rule
all: rom

EXE :=

# SDL3 include/link flags per platform.
ifeq ($(IOS),1)
  # Built by: cmake -DCMAKE_SYSTEM_NAME=iOS -DSDL_STATIC=ON ... (see PORTING.md)
  ifeq ($(IOS_SDK_NAME),iphoneos)
    IOS_SDL ?= $(CURDIR)/../SDL/install-iosdev
  else
    IOS_SDL ?= $(CURDIR)/../SDL/install-iossim
  endif
  SDL_CFLAGS := -I$(IOS_SDL)/include
  SDL_LDFLAGS := -L$(IOS_SDL)/lib -lSDL3 \
      -Wl,-framework,CoreMedia -Wl,-framework,CoreVideo -Wl,-framework,CoreAudio \
      -Wl,-framework,AudioToolbox -Wl,-framework,AVFoundation -Wl,-framework,CoreBluetooth \
      -Wl,-framework,CoreGraphics -Wl,-framework,CoreMotion -Wl,-framework,Foundation \
      -Wl,-framework,GameController -Wl,-framework,Metal -Wl,-framework,OpenGLES \
      -Wl,-framework,QuartzCore -Wl,-framework,UIKit -Wl,-weak_framework,CoreHaptics
else ifeq ($(ANDROID),1)
  # SDL3 built for Android by tools/build (see android/build/SDL/b-<abi>).
  SDL_CFLAGS := -I$(ANDROID_SDL)/include
  SDL_LDFLAGS := -L$(ANDROID_SDL)/b-$(ANDROID_ABI) -lSDL3
else
  SDL_CFLAGS := $(shell pkg-config --cflags sdl3)
  SDL_LDFLAGS := $(shell pkg-config --libs sdl3)
endif

# Data-script pipeline. Pointers are 8 bytes on a 64-bit host, so every
# pointer-sized pseudo-op in the hand-written data scripts widens to .quad, and
# 4-byte packed "pointers" in byte streams become self-relative offsets. Widening
# and 8-byte realignment apply to any object format; retargeting sections at
# Mach-O and the leading underscore on gScriptBase do not -- so the pipeline
# forks by object format here.
ELF_BUILD := 0
ifneq ($(shell uname -s),Darwin)
  ELF_BUILD := 1
  CPPFLAGS += -D PORTABLE_ELF
endif
ifeq ($(shell uname -s),Darwin)
# Mach-O only: sound goto/loop targets stay gScriptBase-relative, NOT self-
# relative. gScriptBase is external to the song .s, so `target - _gScriptBase`
# forces a SUBTRACTOR relocation ld64 resolves after final layout. A same-file
# self-relative `target - .` folds to an assembly-time constant that ld64's
# subsections_via_symbols layout then shifts out from under -- which sent
# cmdPtr into unmapped memory once a byte-packed track hit its loop point
# (EXC_BAD_ACCESS in MP2KPlayerMain). ELF folds the difference safely, so
# Linux/Android keep the uniform self-relative form below. See MP2K_event_goto.
ASM_PSEUDO_OP_CONV := sed \
	-e 's/^[[:blank:]][[:blank:]]\.4byte[[:space:]]\{1,\}\([A-Za-z_][A-Za-z0-9_]*\)/\t.long (\1 - _gScriptBase)/' \
	-e 's/\.4byte[[:space:]]\{1,\}\([A-Za-z_][A-Za-z0-9_]*\)/.quad \1/g' \
	-e 's/\.4byte/.long/g;s/\.2byte/\.short/g' \
	-e 's/\.int[[:space:]]\{1,\}\([A-Za-z_][A-Za-z0-9_]*\)/.quad \1/g' \
	-e 's/\.section script_data, "aw"/.section __DATA,__const/' \
	-e 's/\.section \.rodata/.section __DATA,__const/' \
	-e 's/[[:space:]][[:space:]]*@[^"]*$$//;s/^@.*//' \
	-e '/^[[:space:]]*\.size[[:space:]]/d' \
	-e 's/^\([[:space:]]*\)\.align[[:space:]]\{1,\}2[[:space:]]*$$/\1.balign 8/'
MACHO_SYMS := | python3 tools/mach_o_symbols.py
else ifeq ($(ANDROID),1)
# Android is PIE ELF. Same self-relative pointers as everyone else: 4-byte
# script pointers become `.long (target - .)`, which folds to a constant under
# -Bsymbolic with no dynamic relocation. The only Android-specific rule is
# redirecting .rodata to .data.rel.ro so the 8-byte .quad pointers' RELATIVE
# relocations don't create text relocations, which Android's loader rejects.
ASM_PSEUDO_OP_CONV := sed \
	-e 's/^[[:blank:]][[:blank:]]\.4byte[[:space:]]\{1,\}\([A-Za-z_][A-Za-z0-9_]*\)/\t.long (\1 - .)/' \
	-e 's/\.4byte[[:space:]]\{1,\}\([A-Za-z_][A-Za-z0-9_]*\)/.quad \1/g' \
	-e 's/\.4byte/.long/g;s/\.2byte/\.short/g' \
	-e 's/\.int[[:space:]]\{1,\}\([A-Za-z_][A-Za-z0-9_]*\)/.quad \1/g' \
	-e 's/\.section \.rodata/.section .data.rel.ro/' \
	-e 's/[[:space:]][[:space:]]*@[^"]*$$//;s/^@.*//' \
	-e '/^[[:space:]]*\.size[[:space:]]/d' \
	-e 's/^\([[:space:]]*\)\.align[[:space:]]\{1,\}2[[:space:]]*$$/\1.balign 8/'
MACHO_SYMS := | python3 tools/mach_o_symbols.py --elf
else
# ELF keeps its own section names, and C symbols carry no underscore.
ASM_PSEUDO_OP_CONV := sed \
	-e 's/^[[:blank:]][[:blank:]]\.4byte[[:space:]]\{1,\}\([A-Za-z_][A-Za-z0-9_]*\)/\t.long (\1 - .)/' \
	-e 's/\.4byte[[:space:]]\{1,\}\([A-Za-z_][A-Za-z0-9_]*\)/.quad \1/g' \
	-e 's/\.4byte/.long/g;s/\.2byte/\.short/g' \
	-e 's/\.int[[:space:]]\{1,\}\([A-Za-z_][A-Za-z0-9_]*\)/.quad \1/g' \
	-e 's/[[:space:]][[:space:]]*@[^"]*$$//;s/^@.*//' \
	-e '/^[[:space:]]*\.size[[:space:]]/d' \
	-e 's/^\([[:space:]]*\)\.align[[:space:]]\{1,\}2[[:space:]]*$$/\1.balign 8/'
MACHO_SYMS := | python3 tools/mach_o_symbols.py --elf
endif
# Emulates GNU as --defsym, which clang's integrated assembler lacks.
# STR_VAR_1..3 are charmap entries, not constants. Passed as macro arguments
# they arrive as literal text, so `.if STR_VAR_1 == STR_VAR_1` compares an
# undefined symbol to itself. GNU as folds X-X to 0; clang requires an
# absolute. Give them their charmap byte pairs as values -- distinct, and
# above the 0..255 range the macro's .else branch emits directly.
ASM_DEFSYMS := printf '\t.set PORTABLE_ASM, 1\n\t.set PORTABLE, 1\n\t.set MODERN, 1\n\t.set UBFIX, 1\n\t.set ELF_BUILD, $(ELF_BUILD)\n\t.set STR_VAR_1, 0xFD02\n\t.set STR_VAR_2, 0xFD03\n\t.set STR_VAR_3, 0xFD04\n';
FIX_UNDERSCORE := true
PLATFORM_INCLUDES :=
# clang's integrated assembler replaces GNU as.
AS := clang

# use clang's preprocessor for the C and data-script stages.
CPP := clang -E
# Cross-compiling: the preprocess stage must be the NDK compiler too, or
# __ANDROID__/SDL_PLATFORM_ANDROID are undefined while CC1 defines them --
# SDL_main.h would then skip renaming main() to the exported SDL_main() that
# SDLActivity dlsym's, and any other Android #ifdef would be mis-evaluated.
ifeq ($(ANDROID),1)
  CPP := $(ANDROID_CC) -E
endif

# Output binary + object dir, one per target.
ifeq ($(IOS),1)
ROM := $(FILE_NAME)-ios
OBJ_DIR := $(BUILD_DIR)/ios
else ifeq ($(ANDROID),1)
# Output straight into the per-ABI jniLibs dir so x86_64 and arm64-v8a do not
# share one output path (which would make the second ABI look up-to-date).
ROM := $(ANDROID_JNILIBS)/libmain.so
OBJ_DIR := $(BUILD_DIR)/android-$(ANDROID_ABI)
else
ROM := $(FILE_NAME)64
OBJ_DIR := $(BUILD_DIR)/native64
endif

# Commonly used directories
C_SUBDIR = src
ASM_SUBDIR = asm
DATA_SRC_SUBDIR = src/data
DATA_ASM_SUBDIR = data
MID_SUBDIR = sound/songs/midi

C_BUILDDIR = $(OBJ_DIR)/$(C_SUBDIR)
ASM_BUILDDIR = $(OBJ_DIR)/$(ASM_SUBDIR)
DATA_ASM_BUILDDIR = $(OBJ_DIR)/$(DATA_ASM_SUBDIR)
MID_BUILDDIR = $(OBJ_DIR)/$(MID_SUBDIR)

SHELL := bash -o pipefail

# Set flags for tools.
# Symbols normally passed via --defsym are injected as .set lines instead.
# The scriptptr helper adds a nesting level on top of already-deep map/script
# macro chains, past clang's default limit of 20.
ASFLAGS := -arch arm64 -x assembler -c -Xclang -asm-macro-max-nesting-depth=200 $(IOS_TARGET_FLAGS)
# Android assembles the data scripts with the NDK clang for the target ABI; the
# wrapper supplies the triple/sysroot, so drop the macOS-only -arch flag.
ifeq ($(ANDROID),1)
  AS := $(ANDROID_CC)
  ASFLAGS := -x assembler -c -Xclang -asm-macro-max-nesting-depth=200 -fPIC
endif

INCLUDE_DIRS := include
INCLUDE_CPP_ARGS := $(INCLUDE_DIRS:%=-iquote %)
INCLUDE_SCANINC_ARGS := $(INCLUDE_DIRS:%=-I %)

O_LEVEL ?= 2
CPPFLAGS := $(INCLUDE_CPP_ARGS) -Wno-trigraphs -DMODERN=$(MODERN)
CPPFLAGS += -D NONMATCHING -D PORTABLE -D $(TARGET_PLATFORM) -D $(TILE_RENDERER) -D UBFIX -D NATIVE_BUILD $(SDL_CFLAGS)
# PORTABLE_ELF is added to CPPFLAGS up near ELF_BUILD, but the `CPPFLAGS :=`
# reset above wipes it (NATIVE_BUILD survives only because it is re-added on
# the line above, after the reset). Re-add it here so the ELF pointer path in
# global.h and the Linux CpuSet path in bios.c actually compile in. ELF_BUILD
# is a make variable, so it is unaffected by the CPPFLAGS reset. Android is ELF
# but PIE, so it keeps the uniform self-relative pointer path, not PORTABLE_ELF.
ifeq ($(ELF_BUILD),1)
ifneq ($(ANDROID),1)
  CPPFLAGS += -D PORTABLE_ELF
endif
endif
MODERNCC := clang
PATH_MODERNCC := $(MODERNCC)
# clang compiles the preprocessed C directly; there is no cc1/as split.
CC1 := clang
# The Android NDK clang wrapper bakes in --target/--sysroot for the ABI.
ifeq ($(ANDROID),1)
  MODERNCC := $(ANDROID_CC)
  PATH_MODERNCC := $(ANDROID_CC)
  CC1 := $(ANDROID_CC)
endif
# -fsigned-char: the decompiled source relies on `char` being signed (as it is
# on x86_64 and on Apple's arm64 ABI, the platforms this has run on). Linux and
# Android arm64 default `char` to UNSIGNED, which silently breaks signed-char
# comparisons -- e.g. the renderer hung on the first frame on an Android phone,
# black screen. Pin it signed everywhere so every target matches.
override CFLAGS += -Wno-trigraphs -Wparentheses -std=gnu99 -fno-builtin -Wno-unused-function \
                   -fsigned-char \
                   -DPORTABLE -DNONMATCHING -D UBFIX -DMODERN=$(MODERN) $(SDL_CFLAGS)
ifeq ($(ANDROID),1)
  override CFLAGS += -fPIC
endif
LIB :=

# Enable debug info if set
ifeq ($(DINFO),1)
  override CFLAGS += -g
endif

# Pin the deployment target instead of inheriting whatever SDK is installed:
# a beta SDK stamps minos with its own version and the build then refuses to
# launch on anything older.
#
# The floor is whatever the libSDL3 we link and bundle was built for --
# targeting lower gains nothing while that dylib is carried along, and
# targeting higher than the host SDK fails outright, which is what a CI
# runner on an older macOS would hit. Derived rather than hardcoded so it is
# correct on any host. The native link reuses CFLAGS, so this covers both
# compile and link.
ifeq ($(IOS),1)
  # Both halves: this build preprocesses with CPPFLAGS and only then compiles
  # the result with CFLAGS, so the target has to reach the preprocessor too.
  # Without it every system header is evaluated against the macOS SDK --
  # SDL_PLATFORM_IOS is never defined, so SDL_main.h does not rename main and
  # the app dies at startup with "did you include SDL_main.h?".
  CPPFLAGS += $(IOS_TARGET_FLAGS)
  override CFLAGS += $(IOS_TARGET_FLAGS)
else ifeq ($(shell uname -s),Darwin)
  SDL3_LIBDIR := $(shell pkg-config --variable=libdir sdl3 2>/dev/null)
  MACOS_MIN ?= $(shell otool -l $(SDL3_LIBDIR)/libSDL3.dylib 2>/dev/null | \
                       awk '/LC_BUILD_VERSION/{f=1} f&&/minos/{print $$2; exit}')
  ifeq ($(strip $(MACOS_MIN)),)
    MACOS_MIN := 11.0
  endif
  override CFLAGS += -mmacosx-version-min=$(MACOS_MIN)
else
  # Modern mainline clang/gcc (Arch ships clang 22) promote several C
  # type-safety diagnostics from warnings to *default errors*, independently
  # of -Werror: incompatible pointer/function-pointer types, int<->pointer
  # conversions and implicit declarations. This decompiled source relies on
  # the historically-permissive behaviour, and Apple clang still warns rather
  # than errors, so macOS builds clean. Downgrade them back to warnings on
  # Linux so the same source compiles -- this changes no game logic, only how
  # strictly the compiler reacts to pre-existing GBA-era type punning.
  override CFLAGS += -Wno-error=incompatible-pointer-types \
                     -Wno-error=incompatible-function-pointer-types \
                     -Wno-error=int-conversion \
                     -Wno-error=implicit-function-declaration \
                     -Wno-error=implicit-int
endif

ifeq ($(DINFO),1)
  override CFLAGS += -O0
else
  # The MP2K mixer segfaults intermittently at every optimisation level,
  # including -O0, so the level is not the trigger. Run with EMERALD_NO_AUDIO=1
  # for a stable game while that is chased. See PORTING notes.
  NATIVE_OPT ?= 3
  override CFLAGS += -O$(NATIVE_OPT)
endif
# Diagnostic switches apply at any optimisation level, including DINFO=1.
# NOTE: -D defines must reach CPPFLAGS. The build preprocesses with CPPFLAGS
# and only then compiles the result with CFLAGS, so a define added to CFLAGS
# alone is evaluated too late and every #ifdef silently stays false.
ifeq ($(AUDIT),1)
  CPPFLAGS += -DAUDIO_AUDIT
  override CFLAGS += -DAUDIO_AUDIT -g
endif
ifeq ($(MEMGUARD),1)
  CPPFLAGS += -DEMULATED_MEM_GUARDS
  override CFLAGS += -DEMULATED_MEM_GUARDS
endif
ifeq ($(ASAN),1)
  override CFLAGS += -fsanitize=address -fno-omit-frame-pointer -g
endif
ifeq ($(UBSAN),1)
  override CFLAGS += -fsanitize=undefined -fno-omit-frame-pointer -g
endif

# Variable filled out in other make files
AUTO_GEN_TARGETS :=
include make_tools.mk
# Tool executables
GFX       := $(TOOLS_DIR)/gbagfx/gbagfx$(EXE)
WAV2AGB   := $(TOOLS_DIR)/wav2agb/wav2agb$(EXE)
MID       := $(TOOLS_DIR)/mid2agb/mid2agb$(EXE)
SCANINC   := $(TOOLS_DIR)/scaninc/scaninc$(EXE)
PREPROC   := $(TOOLS_DIR)/preproc/preproc$(EXE)
MAPJSON   := $(TOOLS_DIR)/mapjson/mapjson$(EXE)
JSONPROC  := $(TOOLS_DIR)/jsonproc/jsonproc$(EXE)

PERL := perl

MAKEFLAGS += --no-print-directory

# Clear the default suffixes
.SUFFIXES:
# Don't delete intermediate files
.SECONDARY:
# Delete files that weren't built properly
.DELETE_ON_ERROR:

RULES_NO_SCAN += clean clean-assets tidy tidyportable generated clean-generated
.PHONY: all rom native ios android
.PHONY: $(RULES_NO_SCAN)

infoshell = $(foreach line, $(shell $1 | sed "s/ /__SPACE__/g"), $(info $(subst __SPACE__, ,$(line))))

# Check if we need to scan dependencies based on the chosen rule OR user preference
NODEP ?= 0
# Check if we need to pre-build tools and generate assets based on the chosen rule.
SETUP_PREREQS ?= 1
# Disable dependency scanning for rules that don't need it.
ifneq (,$(MAKECMDGOALS))
  ifeq (,$(filter-out $(RULES_NO_SCAN),$(MAKECMDGOALS)))
    NODEP := 1
    SETUP_PREREQS := 0
  endif
endif

.SHELLSTATUS ?= 0

ifeq ($(SETUP_PREREQS),1)
  # If set on: Default target or a rule requiring a scan
  # Forcibly execute `make tools` since we need them for what we are doing.
  $(foreach line, $(shell $(MAKE) -f make_tools.mk | sed "s/ /__SPACE__/g"), $(info $(subst __SPACE__, ,$(line))))
  ifneq ($(.SHELLSTATUS),0)
    $(error Errors occurred while building tools. See error messages above for more details)
  endif
  # Oh and also generate mapjson sources before we use `SCANINC`.
  $(foreach line, $(shell $(MAKE) generated | sed "s/ /__SPACE__/g"), $(info $(subst __SPACE__, ,$(line))))
  ifneq ($(.SHELLSTATUS),0)
    $(error Errors occurred while generating map-related sources. See error messages above for more details)
  endif
endif

# Collect sources
C_SRCS_IN := $(wildcard $(C_SUBDIR)/*.c $(C_SUBDIR)/*/*.c $(C_SUBDIR)/*/*/*.c)
C_SRCS := $(foreach src,$(C_SRCS_IN),$(if $(findstring .inc.c,$(src)),,$(src)))
C_OBJS := $(patsubst $(C_SUBDIR)/%.c,$(C_BUILDDIR)/%.o,$(C_SRCS))

ASM_SRCS := $(wildcard $(ASM_SUBDIR)/*.s)
ASM_OBJS := $(patsubst $(ASM_SUBDIR)/%.s,$(ASM_BUILDDIR)/%.o,$(ASM_SRCS))

DATA_ASM_SRCS := $(wildcard $(DATA_ASM_SUBDIR)/*.s)
DATA_ASM_OBJS := $(patsubst $(DATA_ASM_SUBDIR)/%.s,$(DATA_ASM_BUILDDIR)/%.o,$(DATA_ASM_SRCS))

MID_SRCS := $(wildcard $(MID_SUBDIR)/*.mid)
MID_OBJS := $(patsubst $(MID_SUBDIR)/%.mid,$(MID_BUILDDIR)/%.o,$(MID_SRCS))

# The GBA hand-written src/*.s files are not part of the host build.
OBJS     := $(C_OBJS) $(ASM_OBJS) $(DATA_ASM_OBJS) $(MID_OBJS)

OBJS_REL := $(patsubst $(OBJ_DIR)/%,%,$(OBJS))

SUBDIRS  := $(sort $(dir $(OBJS)))
$(shell mkdir -p $(SUBDIRS))

# Pretend rules that are actually flags defer to `make all`
native: all
ios: all
android: all

# Other rules
rom: $(ROM)

clean: tidy clean-tools clean-generated clean-assets

clean-assets:
	rm -rf $(BUILD_DIR)/assets
	rm -f $(MID_SUBDIR)/*.s
	rm -f $(DATA_ASM_SUBDIR)/layouts/layouts.inc $(DATA_ASM_SUBDIR)/layouts/layouts_table.inc
	rm -f $(DATA_ASM_SUBDIR)/maps/connections.inc $(DATA_ASM_SUBDIR)/maps/events.inc $(DATA_ASM_SUBDIR)/maps/groups.inc $(DATA_ASM_SUBDIR)/maps/headers.inc
	find sound -iname '*.bin' -exec rm {} +
	find . \( -iname '*.1bpp' -o -iname '*.4bpp' -o -iname '*.8bpp' -o -iname '*.gbapal' -o -iname '*.lz' -o -iname '*.rl' -o -iname '*.latfont' -o -iname '*.hwjpnfont' -o -iname '*.fwjpnfont' \) -exec rm {} +
	find $(DATA_ASM_SUBDIR)/maps \( -iname 'connections.inc' -o -iname 'events.inc' -o -iname 'header.inc' \) -exec rm {} +

tidy: tidyportable

tidyportable:
	rm -f $(FILE_NAME)64 $(FILE_NAME)-ios
	rm -rf $(BUILD_DIR)

clean-platform:
	rm -f $(ROM)
	rm -rf $(OBJ_DIR)/src/platform

# Other rules
include graphics_file_rules.mk
include map_data_rules.mk
include json_data_rules.mk
include audio_rules.mk

# NOTE: Tools must have been built prior (FIXME)
# so you can't really call this rule directly
generated: $(AUTO_GEN_TARGETS)
	@: # Silence the "Nothing to be done for `generated'" message, which some people were confusing for an error.


%.s:   ;
%.png: ;
%.pal: ;
%.wav: ;

%.1bpp:   %.png  ; $(GFX) $< $@
%.4bpp:   %.png  ; $(GFX) $< $@
%.8bpp:   %.png  ; $(GFX) $< $@
%.gbapal: %.pal  ; $(GFX) $< $@
%.gbapal: %.png  ; $(GFX) $< $@
%.lz:     %      ; $(GFX) $< $@
%.rl:     %      ; $(GFX) $< $@

clean-generated:
	@rm -f $(AUTO_GEN_TARGETS)
	@echo "rm -f <AUTO_GEN_TARGETS>"

# Dependency rules (for the *.c & *.s sources to .o files)
# Have to be explicit or else missing files won't be reported.

# As a side effect, they're evaluated immediately instead of when the rule is invoked.
# It doesn't look like $(shell) can be deferred so there might not be a better way (Icedude_907: there is soon).

$(C_BUILDDIR)/%.o: $(C_SUBDIR)/%.c
	@echo "clang <flags> -o $@ $<"
	@$(CPP) $(CPPFLAGS) $< | $(PREPROC) -i -g $(BUILD_DIR)/assets $< charmap.txt | $(CC1) $(CFLAGS) -c -x c - -o $@

$(C_BUILDDIR)/%.d: $(C_SUBDIR)/%.c
	$(SCANINC) -M $@ -g $(BUILD_DIR)/assets $(INCLUDE_SCANINC_ARGS) -I tools/agbcc/include $<

ifneq ($(NODEP),1)
-include $(addprefix $(OBJ_DIR)/,$(C_SRCS:.c=.d))
endif

$(ASM_BUILDDIR)/%.o: $(ASM_SUBDIR)/%.s
	$(AS) $(ASFLAGS) -o $@ $<
	$(FIX_UNDERSCORE) $@

$(ASM_BUILDDIR)/%.d: $(ASM_SUBDIR)/%.s
	$(SCANINC) -M $@ -g $(BUILD_DIR)/assets $(INCLUDE_SCANINC_ARGS) -I "" $<

ifneq ($(NODEP),1)
-include $(addprefix $(OBJ_DIR)/,$(ASM_SRCS:.s=.d))
endif

$(DATA_ASM_BUILDDIR)/%.o: $(DATA_ASM_SUBDIR)/%.s
	{ $(ASM_DEFSYMS) $(PREPROC) $< charmap.txt | $(CPP) $(INCLUDE_SCANINC_ARGS) - | $(PREPROC) -ie $< charmap.txt; } $(EXPAND_INC) | $(ASM_PSEUDO_OP_CONV) $(MACHO_SYMS) | $(AS) $(ASFLAGS) -o $@ -

$(DATA_ASM_BUILDDIR)/%.d: $(DATA_ASM_SUBDIR)/%.s
	$(SCANINC) -M $@ -g $(BUILD_DIR)/assets $(INCLUDE_SCANINC_ARGS) -I "" $<

ifneq ($(NODEP),1)
-include $(addprefix $(OBJ_DIR)/,$(DATA_ASM_SRCS:.s=.d))
endif

# Final link. One binary per target: macOS uses an alias list to reconcile the
# assembly's bare names with C's underscored ones, Android links a PIE .so, and
# every other ELF host (Linux) links a -no-pie executable.
ifeq ($(shell uname -s),Darwin)
$(ROM): $(OBJS)
	@bash tools/gen_macho_aliases.sh $(OBJ_DIR)/macho_aliases.txt $^
	$(MODERNCC) $(CFLAGS) $^ $(SDL_LDFLAGS) -Wl,-alias_list,$(OBJ_DIR)/macho_aliases.txt -o $@
else ifeq ($(ANDROID),1)
# Android: link the game as libmain.so (SDLActivity dlopen's it). -Bsymbolic lets
# the self-relative `target - .` references to global symbols fold to constants
# at link time (no dynamic relocation, no post-link patcher). Stage both libs
# into jniLibs for Gradle.
$(ROM): $(OBJS)
	@mkdir -p $(ANDROID_JNILIBS)
	$(ANDROID_CC) $(CFLAGS) -shared -fPIC $^ $(SDL_LDFLAGS) -Wl,-Bsymbolic -o $@
	cp -f $(ANDROID_SDL)/b-$(ANDROID_ABI)/libSDL3.so $(ANDROID_JNILIBS)/libSDL3.so
else
# No alias list: on ELF the bare names the assembly uses are the names C
# produces, so there is nothing to map.
$(ROM): $(OBJS)
	$(MODERNCC) $(CFLAGS) -no-pie $^ $(SDL_LDFLAGS) -lm -o $@
endif
