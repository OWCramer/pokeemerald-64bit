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
struct BgExtMap
{
    u16 *map;
    u16 widthTiles;
    u16 heightTiles;
};
extern struct BgExtMap gBgExt[4];

void SetRenderSize(int w, int h);
void SetRenderExpansionAllowed(bool32 allowed);
void GetRequestedRenderSize(int *w, int *h);
void SetRenderFieldLimits(int maxW, int maxH);
extern bool32 gRenderExpansionAllowed;

#endif