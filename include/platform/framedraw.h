#ifndef GUARD_FRAMEDRAW_H
#define GUARD_FRAMEDRAW_H

#include "global.h"

void DrawFrame(uint16_t *pixels);

// Render viewport, see src/platform/gba_fast_draw.c. Game logic still runs at
// DISPLAY_WIDTH x DISPLAY_HEIGHT; only the drawn area changes.
extern int gRenderWidth;
extern int gRenderHeight;
extern int gRenderOffsetX;
extern int gRenderOffsetY;
// Port extension: a BG whose tilemap lives in a heap buffer, flat row-major,
// at an arbitrary power-of-two size in tiles. map == NULL means the BG uses the
// normal GBA VRAM screenblock layout.
//
// `bank` is a parallel plane of the same dimensions naming the tileset bank
// each entry is to be decoded against, or NULL for none. It is separate from
// the tilemap rather than packed into a widened entry because the tilemap is
// also handed to bg.c, which writes plain 16-bit GBA entries into it.
struct BgExtMap
{
    u16 *map;
    const u8 *bank;
    u16 widthTiles;
    u16 heightTiles;
};
extern struct BgExtMap gBgExt[4];

// What to add to a tilemap entry's 10-bit tile id to reach the tileset slot it
// really lives in, indexed by [bank][id >= NUM_TILES_IN_PRIMARY]. Filled in by
// fieldmap.c when a bank is assigned; bank 0 stays zero, which is the stock
// VRAM layout. See docs/WIDE_VIEW_TILESET_BANKS.md.
extern u32 gTilesetBankTileDelta[MAX_TILESET_BANKS][2];

void SetRenderSize(int w, int h);
void SetRenderExpansionAllowed(bool32 allowed);
void GetRequestedRenderSize(int *w, int *h);
void SetRenderFieldLimits(int maxW, int maxH);
extern bool32 gRenderExpansionAllowed;

#endif