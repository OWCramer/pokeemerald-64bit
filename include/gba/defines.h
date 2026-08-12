#ifndef GUARD_GBA_DEFINES_H
#define GUARD_GBA_DEFINES_H

#include <stddef.h>

#define TRUE  1
#define FALSE 0

#ifdef PORTABLE
#define IWRAM_DATA
#define EWRAM_DATA
#define COMMON_DATA
#else
#define IWRAM_DATA __attribute__((section("iwram_data")))
#define EWRAM_DATA __attribute__((section("ewram_data")))
#define COMMON_DATA __attribute__((section("common_data")))
#endif
#define UNUSED __attribute__((unused))

#if MODERN
#define NOINLINE __attribute__((noinline))
#else
#define NOINLINE
#endif

#define ALIGNED(n) __attribute__((aligned(n)))

// Tileset banks. The expanded viewport shows whole neighbouring maps, but a
// map's metatile ids only mean anything against its own tileset pair, so every
// pair gets a bank: a full 1024-tile, 16-palette copy of the tileset space the
// GBA can address at once. See docs/WIDE_VIEW_TILESET_BANKS.md.
//
// Banks are stacked above the stock VRAM and palette layout rather than carved
// out of it, so every address the rest of the game already uses is untouched.
// Bank 0 is not a bank: it means "no bank", and decodes against the stock
// layout, which is what every menu and text box does.
//
// There are 76 distinct tileset pairs in the whole game, so a bank per pair is
// 2.4 MB of tiles -- nothing on a host, and the reason banks are permanent.
// Once a pair is assigned a bank it keeps it for the rest of the session and
// its tiles are never reloaded, so a bank id can never go stale under a tilemap
// that still refers to it.
#define MAX_TILESET_BANKS        80
#define TILESET_BANK_NUM_TILES   1024
#define TILESET_BANK_NUM_PALS    16
#define TILESET_BANK_VRAM_SIZE   (TILESET_BANK_NUM_TILES * 32) // 4bpp
#define TILESET_BANK_PLTT_SIZE   (TILESET_BANK_NUM_PALS * 32)  // 16 colours, 2 bytes each
#define TILESET_BANK_VRAM_START  0x20000
#define TILESET_BANK_PLTT_START  32 // in palettes, i.e. just past the OBJ palettes

#define TILESET_BANK_TILE_BASE(n) ((n) == 0 ? 0 : (TILESET_BANK_VRAM_START / 32) + ((n) - 1) * TILESET_BANK_NUM_TILES)
#define TILESET_BANK_PAL_BASE(n)  ((n) == 0 ? 0 : TILESET_BANK_PLTT_START + ((n) - 1) * TILESET_BANK_NUM_PALS)

#define BG_PLTT_SIZE  0x200
#define OBJ_PLTT      (PLTT + BG_PLTT_SIZE)
#define OBJ_PLTT_SIZE 0x200
#define PLTT_SIZE     (BG_PLTT_SIZE + OBJ_PLTT_SIZE + (MAX_TILESET_BANKS - 1) * TILESET_BANK_PLTT_SIZE)

#ifndef PORTABLE
#define SOUND_INFO_PTR (*(struct SoundInfo **)0x3007FF0)
#define INTR_CHECK     (*(u16 *)0x3007FF8)
#define INTR_VECTOR    (*(void **)0x3007FFC)

#define EWRAM_START 0x02000000
#define EWRAM_END   (EWRAM_START + 0x40000)
#define IWRAM_START 0x03000000
#define IWRAM_END   (IWRAM_START + 0x8000)

#define PLTT      0x5000000
#else
extern struct SoundInfo * SOUND_INFO_PTR;
extern unsigned short INTR_CHECK;
extern void * INTR_VECTOR;

extern unsigned char PLTT[PLTT_SIZE] __attribute__ ((aligned (4)));
#endif

#define BG_PLTT       PLTT

// Extended past the GBA's 96K: the field BGs are 512x512, which needs four
// 2K screenblocks each. They are placed at 0x18000+, above OBJ VRAM, so the
// stock BG (0x0000-0xFFFF) and OBJ (0x10000-0x17FFF) layout is untouched.
// Above all of that, at TILESET_BANK_VRAM_START, sit the extra tileset banks.
#define VRAM_SIZE (TILESET_BANK_VRAM_START + (MAX_TILESET_BANKS - 1) * TILESET_BANK_VRAM_SIZE)
#ifndef PORTABLE
#define VRAM      0x6000000
#else
extern unsigned char VRAM_[VRAM_SIZE] __attribute__ ((aligned (4)));
#ifdef NATIVE_BUILD
// A u32 cast truncates the address on a 64-bit host. u8 * keeps the byte
// arithmetic these macros rely on (VRAM + 0x10000) and still passes to void *.
#define VRAM ((u8 *)VRAM_)
#else
#define VRAM (u32)VRAM_
#endif
#endif

#define BG_VRAM           VRAM
#define BG_VRAM_SIZE      0x10000
#define BG_CHAR_SIZE      0x4000
#define BG_SCREEN_SIZE    0x800
#define BG_CHAR_ADDR(n)   (BG_VRAM + (BG_CHAR_SIZE * (n)))
#define BG_SCREEN_ADDR(n) (BG_VRAM + (BG_SCREEN_SIZE * (n)))

#define BG_TILE_H_FLIP(n) (0x400 + (n))
#define BG_TILE_V_FLIP(n) (0x800 + (n))

#define NUM_BACKGROUNDS 4

// text-mode BG
#define OBJ_VRAM0      (VRAM + 0x10000)
#define OBJ_VRAM0_SIZE 0x8000

// bitmap-mode BG
#define OBJ_VRAM1      (VRAM + 0x14000)
#define OBJ_VRAM1_SIZE 0x4000

// 128 entries of the widened struct OamData (12 bytes each) rather than the
// hardware's 8.
#define OAM_SIZE (128 * 12)
#ifndef PORTABLE
#define OAM      0x7000000
#else
extern unsigned char OAM[OAM_SIZE] __attribute__ ((aligned (4)));
#endif

#define ROM_HEADER_SIZE   0xC0

// Dimensions of a tile in pixels
#define TILE_WIDTH  8
#define TILE_HEIGHT 8

// Dimensions of the GBA screen in pixels
#define DISPLAY_WIDTH  240
#define DISPLAY_HEIGHT 160

// Dimensions of the GBA screen in tiles
#define DISPLAY_TILE_WIDTH  (DISPLAY_WIDTH / TILE_WIDTH)
#define DISPLAY_TILE_HEIGHT (DISPLAY_HEIGHT / TILE_HEIGHT)

// Size of different tile formats in bytes
#define TILE_SIZE(bpp) ((bpp) * TILE_WIDTH * TILE_HEIGHT / 8)
#define TILE_SIZE_1BPP TILE_SIZE(1) // 8
#define TILE_SIZE_4BPP TILE_SIZE(4) // 32
#define TILE_SIZE_8BPP TILE_SIZE(8) // 64

#define TILE_OFFSET_4BPP(n) ((n) * TILE_SIZE_4BPP)
#define TILE_OFFSET_8BPP(n) ((n) * TILE_SIZE_8BPP)

#define TOTAL_OBJ_TILE_COUNT 1024

#define PLTT_SIZEOF(n) ((n) * sizeof(u16))
#define PLTT_SIZE_4BPP PLTT_SIZEOF(16)
#define PLTT_SIZE_8BPP PLTT_SIZEOF(256)

#define PLTT_OFFSET_4BPP(n) ((n) * PLTT_SIZE_4BPP)

#endif // GUARD_GBA_DEFINES_H
