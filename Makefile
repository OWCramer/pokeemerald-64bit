# GBA rom header
TITLE       := POKEMON EMER
GAME_CODE   := BPEE
MAKER_CODE  := 01
REVISION    := 0
MODERN      ?= 0
KEEP_TEMPS  ?= 0
PORTABLE    ?= 1
# Build a native 64-bit host binary with clang (macOS/arm64) instead of
# cross-compiling a 32-bit Windows exe with mingw-gcc.
NATIVE64    ?= 0
TARGET_PLATFORM := PLATFORM_SDL2
TILE_RENDERER   := RENDERER_FAST_DRAW

ifneq (,$(filter native,$(MAKECMDGOALS)))
  NATIVE64 := 1
endif
# iOS is arm64 Mach-O with mandatory PIE, exactly like macOS/arm64, so it reuses
# the whole NATIVE64 path -- the anchor-offset pointer scheme, mach_o_symbols.py
# and the alias-list link all apply unchanged. Only the target triple, sysroot
# and SDL flags differ.
ifneq (,$(filter ios,$(MAKECMDGOALS)))
  NATIVE64 := 1
  IOS := 1
  SDL3 := 1
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
ifeq ($(NATIVE64),1)
  PORTABLE := 1
endif

# `File name`.gba ('_modern' will be appended to the modern builds)
FILE_NAME := pokeemerald
BUILD_DIR := build

# Builds the ROM using a modern compiler
MODERN      ?= 0
# Compares the ROM to a checksum of the original - only makes sense using when non-modern
COMPARE     ?= 0

ifeq (modern,$(MAKECMDGOALS))
  MODERN := 1
endif
ifeq (compare,$(MAKECMDGOALS))
  COMPARE := 1
endif
ifeq (gba,$(MAKECMDGOALS))
  PORTABLE := 0
endif
#Enable MODERN if compiling portable version
ifeq ($(PORTABLE), 1)
  MODERN := 1
endif

# Default make rule
all: rom

# Toolchain selection
TOOLCHAIN := $(DEVKITARM)
# don't use dkP's base_tools anymore
# because the redefinition of $(CC) conflicts
# with when we want to use $(CC) to preprocess files
# thus, manually create the variables for the bin
# files, or use arm-none-eabi binaries on the system
# if dkP is not installed on this system
ifneq (,$(TOOLCHAIN))
  ifneq ($(wildcard $(TOOLCHAIN)/bin),)
    export PATH := $(TOOLCHAIN)/bin:$(PATH)
  endif
endif

ifeq ($(NATIVE64),1)
  PREFIX :=
else ifeq ($(PORTABLE),1)
  PREFIX := i686-w64-mingw32-
else
  PREFIX := arm-none-eabi-
endif

OBJCOPY := $(PREFIX)objcopy
OBJDUMP := $(PREFIX)objdump
AS := $(PREFIX)as
LD := $(PREFIX)ld

EXE :=
ifeq ($(OS),Windows_NT)
  EXE := .exe
endif

# The project is SDL3 only; src/platform/sdl2.c is retained for reference but
# is not maintained. Build with SDL3=0 only if you specifically want it.
SDL3 ?= 1
ifneq (,$(filter native3,$(MAKECMDGOALS)))
  NATIVE64 := 1
  SDL3 := 1
endif

ifeq ($(NATIVE64),1)
  # Native 64-bit host build. Pointers are 8 bytes, so every pointer-sized
  # pseudo-op in the hand-written data scripts has to widen to .quad.
  # sdl2-config points at .../include/SDL2, but the sources use <SDL2/SDL.h>,
  # so the parent include dir has to be on the search path too.
ifeq ($(SDL3),1)
  # SDL3 uses <SDL3/SDL.h>, and pkg-config already points at the parent dir.
  TARGET_PLATFORM := PLATFORM_SDL3
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
  else
  SDL_CFLAGS := $(shell pkg-config --cflags sdl3)
  SDL_LDFLAGS := $(shell pkg-config --libs sdl3)
  endif
else
  SDL_CFLAGS := $(shell sdl2-config --cflags) $(foreach d,$(shell sdl2-config --cflags),$(if $(filter -I%,$d),-I$(patsubst -I%,%,$d)/..))
  SDL_LDFLAGS := $(shell sdl2-config --libs)
endif
  # Widening pointer-sized pseudo-ops and realigning to 8 bytes are 64-bit
  # concerns and apply to any object format. Retargeting sections at Mach-O,
  # and the leading underscore on gScriptBase, are not -- so the pipeline
  # forks here.
  ELF_BUILD := 0
  ifneq ($(shell uname -s),Darwin)
    ELF_BUILD := 1
    CPPFLAGS += -D PORTABLE_ELF
  endif
  ifeq ($(shell uname -s),Darwin)
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
  else
  # ELF keeps its own section names, and C symbols carry no underscore.
  ASM_PSEUDO_OP_CONV := sed \
	-e 's/^[[:blank:]][[:blank:]]\.4byte[[:space:]]\{1,\}\([A-Za-z_][A-Za-z0-9_]*\)/\t.long \1/' \
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
else ifeq ($(PORTABLE),1)
  SDL_DIR := /home/pokeemerald/SDL2-2.0.14/i686-w64-mingw32
  ASM_PSEUDO_OP_CONV := sed -e 's/\.4byte/\.int/g;s/\.2byte/\.short/g'
  #FIX_UNDERSCORE is required for 32 bit windows
  FIX_UNDERSCORE := $(OBJCOPY) --prefix-symbol _
  PLATFORM_INCLUDES :=

  #Windows only
  ifneq ($(NO_STD_LIB),1)
    PLATFORM_INCLUDES += -lmingw32
  endif

  ifeq ($(TARGET_PLATFORM), PLATFORM_SDL2)
    PLATFORM_INCLUDES += -lSDL2main -lSDL2.dll
  endif

  ifeq ($(TARGET_PLATFORM), PLATFORM_WIN32)
    ifeq ($(NO_STD_LIB),1)
      PLATFORM_INCLUDES += -Wl,-e__main -nostdlib
      CPPFLAGS += -D NO_STD_LIB_ENABLED
    endif
    PLATFORM_INCLUDES += -lkernel32 -luser32 -lgdi32
  endif
else
  ASM_PSEUDO_OP_CONV := cat
  FIX_UNDERSCORE := $(OBJCOPY)
endif

# use arm-none-eabi-cpp for macOS
# as macOS's default compiler is clang
# and clang's preprocessor will warn on \u
# when preprocessing asm files, expecting a unicode literal
# we can't unconditionally use arm-none-eabi-cpp
# as installations which install binutils-arm-none-eabi
# don't come with it
ifeq ($(NATIVE64),1)
  CPP := clang -E
else ifneq ($(MODERN),1)
  ifeq ($(shell uname -s),Darwin)
    CPP := $(PREFIX)cpp
  else
    CPP := $(CC) -E
  endif
else
  CPP := $(PREFIX)cpp
endif

ROM_NAME := $(FILE_NAME).gba

OBJ_DIR_NAME := $(BUILD_DIR)/emerald
MODERN_ROM_NAME := $(FILE_NAME)_modern.gba
MODERN_OBJ_DIR_NAME := $(BUILD_DIR)/modern
ifeq ($(NATIVE64),1)
# SDL2 and SDL3 builds must not share an object directory: the platform files
# are gated by TARGET_PLATFORM, so a stale sdl2.o from the other configuration
# links in and fails on removed SDL2 symbols.
ifeq ($(SDL3),1)
ifeq ($(IOS),1)
PORTABLE_ROM_NAME := $(FILE_NAME)-ios
PORTABLE_OBJ_DIR_NAME := $(BUILD_DIR)/ios
else
PORTABLE_ROM_NAME := $(FILE_NAME)-sdl3
PORTABLE_OBJ_DIR_NAME := $(BUILD_DIR)/native-sdl3
endif
else
PORTABLE_ROM_NAME := $(FILE_NAME)
PORTABLE_OBJ_DIR_NAME := $(BUILD_DIR)/native
endif
else
PORTABLE_ROM_NAME := $(FILE_NAME).exe
PORTABLE_OBJ_DIR_NAME := $(BUILD_DIR)/pc
endif
ASSETS_DIR_NAME := $(BUILD_DIR)/assets

ELF_NAME := $(ROM_NAME:.gba=.elf)
MAP_NAME := $(ROM_NAME:.gba=.map)
MODERN_ELF_NAME := $(MODERN_ROM_NAME:.gba=.elf)
MODERN_MAP_NAME := $(MODERN_ROM_NAME:.gba=.map)

# Pick our active variables
ifeq ($(MODERN),0)
  ROM := $(ROM_NAME)
  OBJ_DIR := $(OBJ_DIR_NAME)
else ifeq ($(PORTABLE),1)
  ROM := $(PORTABLE_ROM_NAME)
  OBJ_DIR := $(PORTABLE_OBJ_DIR_NAME)
else
  ROM := $(MODERN_ROM_NAME)
  OBJ_DIR := $(MODERN_OBJ_DIR_NAME)
endif
ELF := $(ROM:.gba=.elf)
MAP := $(ROM:.gba=.map)
SYM := $(ROM:.gba=.sym)

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

# Set flags for tools
ifeq ($(NATIVE64),1)
  # Symbols normally passed via --defsym are injected as .set lines instead.
  # The scriptptr helper adds a nesting level on top of already-deep map/script
  # macro chains, past clang's default limit of 20.
  ASFLAGS := -arch arm64 -x assembler -c -Xclang -asm-macro-max-nesting-depth=200 $(IOS_TARGET_FLAGS)
else ifeq ($(PORTABLE),1)
  ASFLAGS := --32 --defsym MODERN=$(MODERN) --defsym PORTABLE=1 --defsym UBFIX=1
else
  ASFLAGS := -mcpu=arm7tdmi --defsym MODERN=$(MODERN)
endif

INCLUDE_DIRS := include
INCLUDE_CPP_ARGS := $(INCLUDE_DIRS:%=-iquote %)
INCLUDE_SCANINC_ARGS := $(INCLUDE_DIRS:%=-I %)

O_LEVEL ?= 2
CPPFLAGS := $(INCLUDE_CPP_ARGS) -Wno-trigraphs -DMODERN=$(MODERN)
ifeq ($(MODERN),0)
  CPPFLAGS += -I tools/agbcc/include -I tools/agbcc -nostdinc -undef -std=gnu89
  CC1 := tools/agbcc/bin/agbcc$(EXE)
  override CFLAGS += -mthumb-interwork -Wimplicit -Wparentheses -Werror -O$(O_LEVEL) -fhex-asm -g
  LIBPATH := -L ../../tools/agbcc/lib
  LIB := $(LIBPATH) -lgcc -lc -L../../libagbsyscall -lagbsyscall
else ifeq ($(NATIVE64),1)
  CPPFLAGS += -D NONMATCHING -D PORTABLE -D $(TARGET_PLATFORM) -D $(TILE_RENDERER) -D UBFIX -D NATIVE_BUILD $(SDL_CFLAGS)
  MODERNCC := clang
  PATH_MODERNCC := $(MODERNCC)
  # clang compiles the preprocessed C directly; there is no cc1/as split.
  CC1 := clang
  override CFLAGS += -Wno-trigraphs -Wparentheses -std=gnu99 -fno-builtin -Wno-unused-function \
                     -DPORTABLE -DNONMATCHING -D UBFIX -DMODERN=$(MODERN) $(SDL_CFLAGS)
  LIB :=
else ifeq ($(PORTABLE),1)
  CPPFLAGS += -D NONMATCHING -D PORTABLE -D $(TARGET_PLATFORM) -D $(TILE_RENDERER) -D UBFIX -I$(SDL_DIR)/include -L$(SDL_DIR)/lib
  MODERNCC := $(PREFIX)gcc
  PATH_MODERNCC := PATH="$(PATH)" $(MODERNCC)
  CC1 	:= $(shell $(PREFIX)gcc --print-prog-name=cc1) -quiet
  override CFLAGS += -Wno-trigraphs -Wimplicit -Wparentheses -Wunused -m32 -std=gnu99 -fleading-underscore -fno-dce -fno-builtin -Wno-unused-function -DPORTABLE -DNONMATCHING -D UBFIX -DMODERN=$(MODERN)
  LIB := $(LIBPATH) -lgcc -lc
else
  # Note: The makefile must be set up to not call these if modern == 0
  MODERNCC := $(PREFIX)gcc
  PATH_MODERNCC := PATH="$(PATH)" $(MODERNCC)
  CC1 := $(shell $(PATH_MODERNCC) --print-prog-name=cc1) -quiet
  override CFLAGS += -mthumb -mthumb-interwork -O$(O_LEVEL) -mabi=apcs-gnu -mtune=arm7tdmi -march=armv4t -fno-toplevel-reorder -Wno-pointer-to-int-cast
  LIBPATH := -L "$(dir $(shell $(PATH_MODERNCC) -mthumb -print-file-name=libgcc.a))" -L "$(dir $(shell $(PATH_MODERNCC) -mthumb -print-file-name=libnosys.a))" -L "$(dir $(shell $(PATH_MODERNCC) -mthumb -print-file-name=libc.a))"
  LIB := $(LIBPATH) -lc -lnosys -lgcc -L../../libagbsyscall -lagbsyscall
endif
# Enable debug info if set
ifeq ($(DINFO),1)
  override CFLAGS += -g
endif

ifeq ($(PORTABLE),1)
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
RAMSCRGEN := $(TOOLS_DIR)/ramscrgen/ramscrgen$(EXE)
FIX       := $(TOOLS_DIR)/gbafix/gbafix$(EXE)
MAPJSON   := $(TOOLS_DIR)/mapjson/mapjson$(EXE)
JSONPROC  := $(TOOLS_DIR)/jsonproc/jsonproc$(EXE)

PERL := perl
SHA1 := $(shell { command -v sha1sum || command -v shasum; } 2>/dev/null) -c

MAKEFLAGS += --no-print-directory

# Clear the default suffixes
.SUFFIXES:
# Don't delete intermediate files
.SECONDARY:
# Delete files that weren't built properly
.DELETE_ON_ERROR:

RULES_NO_SCAN += libagbsyscall clean clean-assets tidy tidymodern tidynonmodern generated clean-generated
.PHONY: all rom modern compare gba native ios
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

C_ASM_SRCS := $(wildcard $(C_SUBDIR)/*.s $(C_SUBDIR)/*/*.s $(C_SUBDIR)/*/*/*.s)
C_ASM_OBJS := $(patsubst $(C_SUBDIR)/%.s,$(C_BUILDDIR)/%.o,$(C_ASM_SRCS))

ASM_SRCS := $(wildcard $(ASM_SUBDIR)/*.s)
ASM_OBJS := $(patsubst $(ASM_SUBDIR)/%.s,$(ASM_BUILDDIR)/%.o,$(ASM_SRCS))

DATA_ASM_SRCS := $(wildcard $(DATA_ASM_SUBDIR)/*.s)
DATA_ASM_OBJS := $(patsubst $(DATA_ASM_SUBDIR)/%.s,$(DATA_ASM_BUILDDIR)/%.o,$(DATA_ASM_SRCS))

MID_SRCS := $(wildcard $(MID_SUBDIR)/*.mid)
MID_OBJS := $(patsubst $(MID_SUBDIR)/%.mid,$(MID_BUILDDIR)/%.o,$(MID_SRCS))

ifeq ($(PORTABLE),1)
  OBJS     := $(C_OBJS) $(ASM_OBJS) $(DATA_ASM_OBJS) $(MID_OBJS)
else
  OBJS     := $(C_OBJS) $(C_ASM_OBJS) $(ASM_OBJS) $(DATA_ASM_OBJS) $(MID_OBJS)
endif

OBJS_REL := $(patsubst $(OBJ_DIR)/%,%,$(OBJS))

SUBDIRS  := $(sort $(dir $(OBJS)))
$(shell mkdir -p $(SUBDIRS))

# Pretend rules that are actually flags defer to `make all`
modern: all
compare: all
gba: all
native: all

ios: all
native3: all

# Other rules
rom: $(ROM)
ifeq ($(COMPARE),1)
	@$(SHA1) rom.sha1
endif

syms: $(SYM)

clean: tidy clean-tools clean-generated clean-assets
	@$(MAKE) clean -C libagbsyscall

clean-assets:
	rm -rf $(ASSETS_DIR_NAME)
	rm -f $(MID_SUBDIR)/*.s
	rm -f $(DATA_ASM_SUBDIR)/layouts/layouts.inc $(DATA_ASM_SUBDIR)/layouts/layouts_table.inc
	rm -f $(DATA_ASM_SUBDIR)/maps/connections.inc $(DATA_ASM_SUBDIR)/maps/events.inc $(DATA_ASM_SUBDIR)/maps/groups.inc $(DATA_ASM_SUBDIR)/maps/headers.inc
	find sound -iname '*.bin' -exec rm {} +
	find . \( -iname '*.1bpp' -o -iname '*.4bpp' -o -iname '*.8bpp' -o -iname '*.gbapal' -o -iname '*.lz' -o -iname '*.rl' -o -iname '*.latfont' -o -iname '*.hwjpnfont' -o -iname '*.fwjpnfont' \) -exec rm {} +
	find $(DATA_ASM_SUBDIR)/maps \( -iname 'connections.inc' -o -iname 'events.inc' -o -iname 'header.inc' \) -exec rm {} +

tidy: tidynonmodern tidymodern tidyportable

tidynonmodern:
	rm -f $(ROM_NAME) $(ELF_NAME) $(MAP_NAME)
	rm -rf $(OBJ_DIR_NAME)

tidymodern:
	rm -f $(MODERN_ROM_NAME) $(MODERN_ELF_NAME) $(MODERN_MAP_NAME)
	rm -rf $(MODERN_OBJ_DIR_NAME)

tidyportable:
	rm -f $(PORTABLE_ROM_NAME)
	rm -rf $(PORTABLE_OBJ_DIR_NAME)

clean-platform:
	rm -f $(PORTABLE_ROM_NAME)
	rm -rf $(PORTABLE_OBJ_DIR_NAME)/src/platform

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

ifeq ($(MODERN),0)
$(C_BUILDDIR)/libc.o: CC1 := $(TOOLS_DIR)/agbcc/bin/old_agbcc$(EXE)
$(C_BUILDDIR)/libc.o: CFLAGS := -O2
$(C_BUILDDIR)/siirtc.o: CFLAGS := -mthumb-interwork
$(C_BUILDDIR)/agb_flash.o: CFLAGS := -O -mthumb-interwork
$(C_BUILDDIR)/agb_flash_1m.o: CFLAGS := -O -mthumb-interwork
$(C_BUILDDIR)/agb_flash_mx.o: CFLAGS := -O -mthumb-interwork
$(C_BUILDDIR)/m4a.o: CC1 := tools/agbcc/bin/old_agbcc$(EXE)
$(C_BUILDDIR)/record_mixing.o: CFLAGS += -ffreestanding
$(C_BUILDDIR)/librfu_intr.o: CC1 := $(TOOLS_DIR)/agbcc/bin/agbcc_arm$(EXE)
$(C_BUILDDIR)/librfu_intr.o: CFLAGS := -O2 -mthumb-interwork -quiet
else ifneq ($(PORTABLE),1)
$(C_BUILDDIR)/librfu_intr.o: CFLAGS := -mthumb-interwork -O2 -mabi=apcs-gnu -mtune=arm7tdmi -march=armv4t -fno-toplevel-reorder -Wno-pointer-to-int-cast
$(C_BUILDDIR)/berry_crush.o: override CFLAGS += -Wno-address-of-packed-member
endif

# Dependency rules (for the *.c & *.s sources to .o files)
# Have to be explicit or else missing files won't be reported.

# As a side effect, they're evaluated immediately instead of when the rule is invoked.
# It doesn't look like $(shell) can be deferred so there might not be a better way (Icedude_907: there is soon).

$(C_BUILDDIR)/%.o: $(C_SUBDIR)/%.c
ifeq ($(NATIVE64),1)
	@echo "clang <flags> -o $@ $<"
	@$(CPP) $(CPPFLAGS) $< | $(PREPROC) -i -g $(ASSETS_DIR_NAME) $< charmap.txt | $(CC1) $(CFLAGS) -c -x c - -o $@
else ifneq ($(KEEP_TEMPS),1)
	@echo "$(CC1) <flags> -o $@ $<"
	@$(CPP) $(CPPFLAGS) $< | $(PREPROC) -i -g $(ASSETS_DIR_NAME) $< charmap.txt | $(CC1) $(CFLAGS) -o - - | cat - <(echo -e ".text\n\t.align\t2, 0") | $(AS) $(ASFLAGS) -o $@ -
else
	@$(CPP) $(CPPFLAGS) $< -o $(C_BUILDDIR)/$*.i
	@$(PREPROC) -g $(ASSETS_DIR_NAME) $(C_BUILDDIR)/$*.i charmap.txt | $(CC1) $(CFLAGS) -o $(C_BUILDDIR)/$*.s
	@echo -e ".text\n\t.align\t2, 0\n" >> $(C_BUILDDIR)/$*.s
	$(AS) $(ASFLAGS) -o $@ $(C_BUILDDIR)/$*.s
endif

$(C_BUILDDIR)/%.d: $(C_SUBDIR)/%.c
	$(SCANINC) -M $@ -g $(ASSETS_DIR_NAME) $(INCLUDE_SCANINC_ARGS) -I tools/agbcc/include $<

ifneq ($(NODEP),1)
-include $(addprefix $(OBJ_DIR)/,$(C_SRCS:.c=.d))
endif

$(ASM_BUILDDIR)/%.o: $(ASM_SUBDIR)/%.s
	$(AS) $(ASFLAGS) -o $@ $<
	$(FIX_UNDERSCORE) $@

$(ASM_BUILDDIR)/%.d: $(ASM_SUBDIR)/%.s
	$(SCANINC) -M $@ -g $(ASSETS_DIR_NAME) $(INCLUDE_SCANINC_ARGS) -I "" $<

ifneq ($(NODEP),1)
-include $(addprefix $(OBJ_DIR)/,$(ASM_SRCS:.s=.d))
endif

$(C_BUILDDIR)/%.o: $(C_SUBDIR)/%.s
	$(PREPROC) $< charmap.txt | $(CPP) $(INCLUDE_SCANINC_ARGS) - | $(PREPROC) -ie $< charmap.txt | $(AS) $(ASFLAGS) -o $@

$(C_BUILDDIR)/%.d: $(C_SUBDIR)/%.s
	$(SCANINC) -M $@ -g $(ASSETS_DIR_NAME) $(INCLUDE_SCANINC_ARGS) -I "" $<

ifneq ($(NODEP),1)
-include $(addprefix $(OBJ_DIR)/,$(C_ASM_SRCS:.s=.d))
endif

ifeq ($(NATIVE64),1)
$(DATA_ASM_BUILDDIR)/%.o: $(DATA_ASM_SUBDIR)/%.s
	{ $(ASM_DEFSYMS) $(PREPROC) $< charmap.txt | $(CPP) $(INCLUDE_SCANINC_ARGS) - | $(PREPROC) -ie $< charmap.txt; } $(EXPAND_INC) | $(ASM_PSEUDO_OP_CONV) $(MACHO_SYMS) | $(AS) $(ASFLAGS) -o $@ -
else
$(DATA_ASM_BUILDDIR)/%.o: $(DATA_ASM_SUBDIR)/%.s
	$(PREPROC) $< charmap.txt | $(CPP) $(INCLUDE_SCANINC_ARGS) - | $(PREPROC) -ie $< charmap.txt | $(ASM_PSEUDO_OP_CONV) | $(AS) $(ASFLAGS) -o $@
	$(FIX_UNDERSCORE) $@
endif

$(DATA_ASM_BUILDDIR)/%.d: $(DATA_ASM_SUBDIR)/%.s
	$(SCANINC) -M $@ -g $(ASSETS_DIR_NAME) $(INCLUDE_SCANINC_ARGS) -I "" $<

ifneq ($(NODEP),1)
-include $(addprefix $(OBJ_DIR)/,$(DATA_ASM_SRCS:.s=.d))
endif

$(OBJ_DIR)/sym_bss.ld: sym_bss.txt
	$(RAMSCRGEN) .bss $< ENGLISH > $@

$(OBJ_DIR)/sym_common.ld: sym_common.txt $(C_OBJS) $(wildcard common_syms/*.txt)
	$(RAMSCRGEN) COMMON $< ENGLISH -c $(C_BUILDDIR),common_syms > $@

$(OBJ_DIR)/sym_ewram.ld: sym_ewram.txt
	$(RAMSCRGEN) ewram_data $< ENGLISH > $@

# Linker script
ifeq ($(MODERN),0)
LD_SCRIPT := ld_script.ld
LD_SCRIPT_DEPS := $(OBJ_DIR)/sym_bss.ld $(OBJ_DIR)/sym_common.ld $(OBJ_DIR)/sym_ewram.ld
else
LD_SCRIPT := ld_script_modern.ld
LD_SCRIPT_DEPS :=
endif

# Final rules

libagbsyscall:
	@$(MAKE) -C libagbsyscall TOOLCHAIN=$(TOOLCHAIN) MODERN=$(MODERN)

ifneq ($(PORTABLE),1)
# Elf from object files
LDFLAGS = -Map ../../$(MAP)
$(ELF): $(LD_SCRIPT) $(LD_SCRIPT_DEPS) $(OBJS) libagbsyscall
	@cd $(OBJ_DIR) && $(LD) $(LDFLAGS) -T ../../$< --print-memory-usage -o ../../$@ $(OBJS_REL) $(LIB) | cat
	@echo "cd $(OBJ_DIR) && $(LD) $(LDFLAGS) -T ../../$< --print-memory-usage -o ../../$@ <objs> <libs> | cat"
	$(FIX) $@ -t"$(TITLE)" -c$(GAME_CODE) -m$(MAKER_CODE) -r$(REVISION) --silent

# Builds the rom from the elf file
$(ROM): $(ELF)
	$(OBJCOPY) -O binary $< $@
	$(FIX) $@ -p --silent

# Symbol file (`make syms`)
$(SYM): $(ELF)
	$(OBJDUMP) -t $< | sort -u | grep -E "^0[2389]" | $(PERL) -p -e 's/^(\w{8}) (\w).{6} \S+\t(\w{8}) (\S+)$$/\1 \2 \3 \4/g' > $@
else
ifeq ($(NATIVE64),1)
ifeq ($(shell uname -s),Darwin)
$(ROM): $(OBJS)
	@bash tools/gen_macho_aliases.sh $(OBJ_DIR)/macho_aliases.txt $^
	$(MODERNCC) $(CFLAGS) $^ $(SDL_LDFLAGS) -Wl,-alias_list,$(OBJ_DIR)/macho_aliases.txt -o $@
else
# No alias list: on ELF the bare names the assembly uses are the names C
# produces, so there is nothing to map.
$(ROM): $(OBJS)
	$(MODERNCC) $(CFLAGS) -no-pie $^ $(SDL_LDFLAGS) -lm -o $@
endif
else
$(ROM): $(OBJS)
	$(MODERNCC) $(CFLAGS) -Wl,--demangle $^ -static-libgcc -L$(SDL_DIR)/lib $(PLATFORM_INCLUDES) -lwinmm -lxinput -o $@
endif
endif