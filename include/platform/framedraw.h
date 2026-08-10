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
void SetRenderSize(int w, int h);
void SetRenderExpansionAllowed(bool32 allowed);
extern bool32 gRenderExpansionAllowed;

#endif