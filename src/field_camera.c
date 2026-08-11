#include <stdlib.h>
#include "global.h"
#include "berry.h"
#include "bike.h"
#include "bg.h"
#include "field_camera.h"
#include "field_player_avatar.h"
#include "fieldmap.h"
#include "platform/framedraw.h"
#include "event_object_movement.h"
#include "gpu_regs.h"
#include "menu.h"
#include "overworld.h"
#include "rotating_gate.h"
#include "sprite.h"
#include "text.h"

EWRAM_DATA bool8 gUnusedBikeCameraAheadPanback = FALSE;

struct FieldCameraOffset
{
    u16 xPixelOffset;
    u16 yPixelOffset;
    u8 xTileOffset;
    u8 yTileOffset;
    bool8 copyBGToVRAM;
};

static s32 MapPosToBgTilemapOffset(struct FieldCameraOffset *, s32, s32);
static void RedrawMapSliceNorth(struct FieldCameraOffset *, const struct MapLayout *);
static void RedrawMapSliceSouth(struct FieldCameraOffset *, const struct MapLayout *);
static void RedrawMapSliceEast(struct FieldCameraOffset *, const struct MapLayout *);
static void RedrawMapSliceWest(struct FieldCameraOffset *, const struct MapLayout *);
static void DrawWholeMapViewInternal(int, int, const struct MapLayout *);
static void DrawMetatileAt(const struct MapLayout *, u32, int, int);
static void DrawMetatile(s32, const u16 *, u32, u8);
static void CameraPanningCB_PanAhead(void);

static struct FieldCameraOffset sFieldCameraOffset;
static s16 sHorizontalCameraPan;
static s16 sVerticalCameraPan;
static bool8 sBikeCameraPanFlag;
static void (*sFieldCameraPanningCallback)(void);

COMMON_DATA struct CameraObject gFieldCamera = {0};
COMMON_DATA u16 gTotalCameraPixelOffsetY = 0;
COMMON_DATA u16 gTotalCameraPixelOffsetX = 0;

// The field's tilemap is sized to the window rather than to one of the GBA's
// four fixed BG sizes. It is a flat row-major buffer on the heap that the
// renderer reads directly (see struct BgExtMap), so it is bounded only by
// memory -- not by screenSize's 2 bits, mapBaseIndex's 6, or VRAM.
//
// The screen is placed near the middle of that window by drawing it sPadMt*
// metatiles up and left of the camera and compensating the BG scroll by the
// same amount, so the visible image is unchanged and only the off-screen slack
// moves. Sizes are powers of two in tiles so wrapping is a mask.
static u16 sTilesW = 32;
static u16 sTilesH = 32;
static u16 sPadMtX = 0;
static u16 sPadMtY = 0;

// Which tileset bank each tilemap entry belongs to, parallel to all three
// layers' buffers. Only the renderer reads it; see struct BgExtMap.
static u8 *sFieldTilemapBanks = NULL;

#define FIELD_PAD_X       (sPadMtX * 16)
#define FIELD_PAD_Y       (sPadMtY * 16)
#define FIELD_WINDOW_MT_W (sTilesW / 2)
#define FIELD_WINDOW_MT_H (sTilesH / 2)
#define FIELD_ORIGIN_X    (gSaveBlock1Ptr->pos.x - sPadMtX)
#define FIELD_ORIGIN_Y    (gSaveBlock1Ptr->pos.y - sPadMtY)

static u32 TilemapOffset(u32 tx, u32 ty)
{
    return ty * sTilesW + tx;
}

static void ResetCameraOffset(struct FieldCameraOffset *cameraOffset)
{
    cameraOffset->xTileOffset = 0;
    cameraOffset->yTileOffset = 0;
    cameraOffset->xPixelOffset = 0;
    cameraOffset->yPixelOffset = 0;
    cameraOffset->copyBGToVRAM = TRUE;
}

static void AddCameraTileOffset(struct FieldCameraOffset *cameraOffset, u32 xOffset, u32 yOffset)
{
    cameraOffset->xTileOffset += xOffset;
    cameraOffset->xTileOffset %= sTilesW;
    cameraOffset->yTileOffset += yOffset;
    cameraOffset->yTileOffset %= sTilesH;
}

static void AddCameraPixelOffset(struct FieldCameraOffset *cameraOffset, u32 xOffset, u32 yOffset)
{
    // Wraps with the 512px window rather than the old 256px one.
    cameraOffset->xPixelOffset = (cameraOffset->xPixelOffset + xOffset) & (sTilesW * 8 - 1);
    cameraOffset->yPixelOffset = (cameraOffset->yPixelOffset + yOffset) & (sTilesH * 8 - 1);
}

// Powers of two in tiles, floor 256px (vanilla), ceiling 2048px.
static u16 TilesForPixels(int px)
{
    u16 t = 32;

    while ((int)t * 8 < px && t < 256)
        t *= 2;
    return t;
}

// What the current tilemap can back, given the screen sits sPadMt* into it and
// the outermost ring is deliberately stale. Verified against the 256px case,
// where this yields the 24px measured by instrumenting the camera.
static void PublishFieldLimits(void)
{
    int px = sTilesW * 8;
    int py = sTilesH * 8;
    int ex = sPadMtX * 16;
    int ey = 24 + sPadMtY * 16;
    int farX = px - 288 - sPadMtX * 16;
    int farY = py - 232 - sPadMtY * 16;

    if (farX < ex)
        ex = farX;
    if (farY < ey)
        ey = farY;
    if (ex < 0)
        ex = 0;
    if (ey < 0)
        ey = 0;
    SetRenderFieldLimits(DISPLAY_WIDTH + 2 * ex, DISPLAY_HEIGHT + 2 * ey);
}

static bool32 AllocFieldTilemaps(u16 tw, u16 th)
{
    u32 n = (u32)tw * th;
    u16 *b1 = calloc(n, sizeof(u16));
    u16 *b2 = calloc(n, sizeof(u16));
    u16 *b3 = calloc(n, sizeof(u16));
    u8 *bank = calloc(n, sizeof(u8));
    u32 i;

    if (b1 == NULL || b2 == NULL || b3 == NULL || bank == NULL)
    {
        free(b1);
        free(b2);
        free(b3);
        free(bank);
        return FALSE;
    }

    free(gOverworldTilemapBuffer_Bg1);
    free(gOverworldTilemapBuffer_Bg2);
    free(gOverworldTilemapBuffer_Bg3);
    free(sFieldTilemapBanks);
    gOverworldTilemapBuffer_Bg1 = b1;
    gOverworldTilemapBuffer_Bg2 = b2;
    gOverworldTilemapBuffer_Bg3 = b3;
    sFieldTilemapBanks = bank;
    SetBgTilemapBuffer(1, b1);
    SetBgTilemapBuffer(2, b2);
    SetBgTilemapBuffer(3, b3);
    for (i = 1; i <= 3; i++)
    {
        gBgExt[i].map = (i == 1) ? b1 : (i == 2) ? b2 : b3;
        // The three layers are drawn from the same metatile at the same offset,
        // so one plane serves all of them.
        gBgExt[i].bank = bank;
        gBgExt[i].widthTiles = tw;
        gBgExt[i].heightTiles = th;
    }

    sTilesW = tw;
    sTilesH = th;
    // Centre the screen in the window; the pad is whole metatiles because the
    // draw is metatile-aligned.
    sPadMtX = (tw * 8 >= 288) ? (tw * 8 - 288) / 32 : 0;
    sPadMtY = (th * 8 >= 256) ? (th * 8 - 256) / 32 : 0;
    // The tile and pixel offsets stay in lockstep: both only shrink modulo a
    // larger power of two, so the congruence between them survives.
    sFieldCameraOffset.xTileOffset %= tw;
    sFieldCameraOffset.yTileOffset %= th;
    return TRUE;
}

void InitFieldTilemaps(void)
{
    int reqW, reqH;

    GetRequestedRenderSize(&reqW, &reqH);
    sTilesW = 32;
    sTilesH = 32;
    AllocFieldTilemaps(TilesForPixels(reqW + 48), TilesForPixels(reqH + 48));
    PublishFieldLimits();
}

void FreeFieldTilemaps(void)
{
    u32 i;

    for (i = 1; i <= 3; i++)
    {
        gBgExt[i].map = NULL;
        gBgExt[i].bank = NULL;
    }
    free(gOverworldTilemapBuffer_Bg1);
    free(gOverworldTilemapBuffer_Bg2);
    free(gOverworldTilemapBuffer_Bg3);
    free(sFieldTilemapBanks);
    gOverworldTilemapBuffer_Bg1 = NULL;
    gOverworldTilemapBuffer_Bg2 = NULL;
    gOverworldTilemapBuffer_Bg3 = NULL;
    sFieldTilemapBanks = NULL;
    sTilesW = 32;
    sTilesH = 32;
    SetRenderFieldLimits(DISPLAY_WIDTH, DISPLAY_HEIGHT);
}

// Grow the tilemap to whatever the window now wants. Grow-only: shrinking would
// reallocate and force a full redraw every time a menu pins the view back to
// 240x160.
static void FieldUpdateTilemapSize(void)
{
    int reqW, reqH;
    u16 tw, th;

    if (gOverworldTilemapBuffer_Bg1 == NULL)
        return;

    GetRequestedRenderSize(&reqW, &reqH);
    // The window holds the vanilla view, up to 32px of camera phase jitter, the
    // stale outer ring, and the expansion on both sides.
    tw = TilesForPixels(reqW + 48);
    th = TilesForPixels(reqH + 48);
    if (tw < sTilesW)
        tw = sTilesW;
    if (th < sTilesH)
        th = sTilesH;

    if ((tw != sTilesW || th != sTilesH) && AllocFieldTilemaps(tw, th))
        DrawWholeMapView();
    PublishFieldLimits();
}

void ResetFieldCamera(void)
{
    ResetCameraOffset(&sFieldCameraOffset);
}

void FieldUpdateBgTilemapScroll(void)
{
    u32 r4, r5;

    FieldUpdateTilemapSize();
    r5 = (sFieldCameraOffset.xPixelOffset + sHorizontalCameraPan + FIELD_PAD_X) & (sTilesW * 8 - 1);
    r4 = (sVerticalCameraPan + sFieldCameraOffset.yPixelOffset + 8 + FIELD_PAD_Y) & (sTilesH * 8 - 1);

    SetGpuReg(REG_OFFSET_BG1HOFS, r5);
    SetGpuReg(REG_OFFSET_BG1VOFS, r4);
    SetGpuReg(REG_OFFSET_BG2HOFS, r5);
    SetGpuReg(REG_OFFSET_BG2VOFS, r4);
    SetGpuReg(REG_OFFSET_BG3HOFS, r5);
    SetGpuReg(REG_OFFSET_BG3VOFS, r4);
}

void GetCameraOffsetWithPan(s16 *x, s16 *y)
{
    *x = sFieldCameraOffset.xPixelOffset + sHorizontalCameraPan;
    *y = sFieldCameraOffset.yPixelOffset + sVerticalCameraPan + 8;
}

void DrawWholeMapView(void)
{
    DrawWholeMapViewInternal(FIELD_ORIGIN_X, FIELD_ORIGIN_Y, gMapHeader.mapLayout);
    sFieldCameraOffset.copyBGToVRAM = TRUE;

}

static void DrawWholeMapViewInternal(int x, int y, const struct MapLayout *mapLayout)
{
    u16 i;
    u16 j;
    u16 ty;
    u16 tx;

    for (i = 0; i < sTilesH; i += 2)
    {
        ty = (sFieldCameraOffset.yTileOffset + i) % sTilesH;
        for (j = 0; j < sTilesW; j += 2)
        {
            tx = (sFieldCameraOffset.xTileOffset + j) % sTilesW;
            DrawMetatileAt(mapLayout, TilemapOffset(tx, ty), x + j / 2, y + i / 2);
        }
    }
}

static void RedrawMapSlicesForCameraUpdate(struct FieldCameraOffset *cameraOffset, int x, int y)
{
    const struct MapLayout *mapLayout = gMapHeader.mapLayout;

    // Only the edge slice that scrolled in is redrawn, which leaves the ring's
    // outermost row/column holding the one that just scrolled off. That is not
    // an oversight to fix: yTileOffset/xTileOffset jump a whole metatile at the
    // crossing while the pixel offset only catches up at the end of
    // CameraUpdate, so for that one frame the ring's far edge is displayed at
    // the NEAR edge of the screen -- and the scrolled-off row/column is exactly
    // what belongs there. Redrawing the whole window instead makes the far side
    // of the map flash on the near side for a frame.
    if (x > 0)
        RedrawMapSliceWest(cameraOffset, mapLayout);
    if (x < 0)
        RedrawMapSliceEast(cameraOffset, mapLayout);
    if (y > 0)
        RedrawMapSliceNorth(cameraOffset, mapLayout);
    if (y < 0)
        RedrawMapSliceSouth(cameraOffset, mapLayout);
    cameraOffset->copyBGToVRAM = TRUE;
}

static void RedrawMapSliceNorth(struct FieldCameraOffset *cameraOffset, const struct MapLayout *mapLayout)
{
    u16 i;
    u16 tx;
    u16 ty = (cameraOffset->yTileOffset + sTilesH - 4) % sTilesH;

    for (i = 0; i < sTilesW; i += 2)
    {
        tx = (cameraOffset->xTileOffset + i) % sTilesW;
        DrawMetatileAt(mapLayout, TilemapOffset(tx, ty), FIELD_ORIGIN_X + i / 2, FIELD_ORIGIN_Y + FIELD_WINDOW_MT_H - 2);
    }
}

static void RedrawMapSliceSouth(struct FieldCameraOffset *cameraOffset, const struct MapLayout *mapLayout)
{
    u16 i;
    u16 tx;
    u16 ty = cameraOffset->yTileOffset;

    for (i = 0; i < sTilesW; i += 2)
    {
        tx = (cameraOffset->xTileOffset + i) % sTilesW;
        DrawMetatileAt(mapLayout, TilemapOffset(tx, ty), FIELD_ORIGIN_X + i / 2, FIELD_ORIGIN_Y);
    }
}

static void RedrawMapSliceEast(struct FieldCameraOffset *cameraOffset, const struct MapLayout *mapLayout)
{
    u16 i;
    u16 ty;
    u16 tx = cameraOffset->xTileOffset;

    for (i = 0; i < sTilesH; i += 2)
    {
        ty = (cameraOffset->yTileOffset + i) % sTilesH;
        DrawMetatileAt(mapLayout, TilemapOffset(tx, ty), FIELD_ORIGIN_X, FIELD_ORIGIN_Y + i / 2);
    }
}

static void RedrawMapSliceWest(struct FieldCameraOffset *cameraOffset, const struct MapLayout *mapLayout)
{
    u16 i;
    u16 ty;
    u16 tx = (cameraOffset->xTileOffset + sTilesW - 4) % sTilesW;

    for (i = 0; i < sTilesH; i += 2)
    {
        ty = (cameraOffset->yTileOffset + i) % sTilesH;
        DrawMetatileAt(mapLayout, TilemapOffset(tx, ty), FIELD_ORIGIN_X + FIELD_WINDOW_MT_W - 2, FIELD_ORIGIN_Y + i / 2);
    }
}

void CurrentMapDrawMetatileAt(int x, int y)
{
    int offset = MapPosToBgTilemapOffset(&sFieldCameraOffset, x, y);

    if (offset >= 0)
    {
        DrawMetatileAt(gMapHeader.mapLayout, offset, x, y);
        sFieldCameraOffset.copyBGToVRAM = TRUE;
    }
}

void DrawDoorMetatileAt(int x, int y, u16 *tiles)
{
    int offset = MapPosToBgTilemapOffset(&sFieldCameraOffset, x, y);

    if (offset >= 0)
    {
        // Doors only ever belong to the map the player is on.
        DrawMetatile(METATILE_LAYER_TYPE_COVERED, tiles, offset, 0);
        sFieldCameraOffset.copyBGToVRAM = TRUE;
    }
}

static void DrawMetatileAt(const struct MapLayout *mapLayout, u32 offset, int x, int y)
{
    u16 metatileId = MapGridGetMetatileIdAt(x, y);
    u8 bank = MapGridGetTilesetBankAt(x, y);
    const struct Tileset *tileset;

    if (metatileId > NUM_METATILES_TOTAL)
        metatileId = 0;

    // Bank 0 is the map this layout describes. A cell filled in from a
    // connection carries its own map's bank instead, so its metatile id is read
    // out of that map's tileset -- the id means nothing against ours, which is
    // what drew a neighbouring town as rubble in the expanded viewport.
    if (metatileId < NUM_METATILES_IN_PRIMARY)
        tileset = bank != 0 ? GetTilesetBankPrimary(bank) : mapLayout->primaryTileset;
    else
        tileset = bank != 0 ? GetTilesetBankSecondary(bank) : mapLayout->secondaryTileset;

    // A bank with no tileset registered means the layout was built without one
    // (the Battle Pyramid and Trainer Hill generate their floors directly).
    // Drawing against this map is what happened before banks existed.
    if (tileset == NULL)
    {
        tileset = metatileId < NUM_METATILES_IN_PRIMARY ? mapLayout->primaryTileset
                                                        : mapLayout->secondaryTileset;
        bank = 0;
    }

    if (metatileId >= NUM_METATILES_IN_PRIMARY)
        metatileId -= NUM_METATILES_IN_PRIMARY;

    DrawMetatile(MapGridGetMetatileLayerTypeAt(x, y),
                 tileset->metatiles + metatileId * NUM_TILES_PER_METATILE, offset, bank);
}

static void DrawMetatile(s32 metatileLayerType, const u16 *tiles, u32 offset, u8 bank)
{
    // All three layers take their tiles from the same metatile, so one plane
    // records the bank for the whole 2x2 block. The renderer reads it; nothing
    // else does.
    if (sFieldTilemapBanks != NULL)
    {
        sFieldTilemapBanks[offset] = bank;
        sFieldTilemapBanks[offset + 1] = bank;
        sFieldTilemapBanks[offset + sTilesW] = bank;
        sFieldTilemapBanks[offset + sTilesW + 1] = bank;
    }

    switch (metatileLayerType)
    {
    case METATILE_LAYER_TYPE_SPLIT:
        // Draw metatile's bottom layer to the bottom background layer.
        gOverworldTilemapBuffer_Bg3[offset] = tiles[0];
        gOverworldTilemapBuffer_Bg3[offset + 1] = tiles[1];
        gOverworldTilemapBuffer_Bg3[offset + sTilesW] = tiles[2];
        gOverworldTilemapBuffer_Bg3[offset + sTilesW + 1] = tiles[3];

        // Draw transparent tiles to the middle background layer.
        gOverworldTilemapBuffer_Bg2[offset] = 0;
        gOverworldTilemapBuffer_Bg2[offset + 1] = 0;
        gOverworldTilemapBuffer_Bg2[offset + sTilesW] = 0;
        gOverworldTilemapBuffer_Bg2[offset + sTilesW + 1] = 0;

        // Draw metatile's top layer to the top background layer.
        gOverworldTilemapBuffer_Bg1[offset] = tiles[4];
        gOverworldTilemapBuffer_Bg1[offset + 1] = tiles[5];
        gOverworldTilemapBuffer_Bg1[offset + sTilesW] = tiles[6];
        gOverworldTilemapBuffer_Bg1[offset + sTilesW + 1] = tiles[7];
        break;
    case METATILE_LAYER_TYPE_COVERED:
        // Draw metatile's bottom layer to the bottom background layer.
        gOverworldTilemapBuffer_Bg3[offset] = tiles[0];
        gOverworldTilemapBuffer_Bg3[offset + 1] = tiles[1];
        gOverworldTilemapBuffer_Bg3[offset + sTilesW] = tiles[2];
        gOverworldTilemapBuffer_Bg3[offset + sTilesW + 1] = tiles[3];

        // Draw metatile's top layer to the middle background layer.
        gOverworldTilemapBuffer_Bg2[offset] = tiles[4];
        gOverworldTilemapBuffer_Bg2[offset + 1] = tiles[5];
        gOverworldTilemapBuffer_Bg2[offset + sTilesW] = tiles[6];
        gOverworldTilemapBuffer_Bg2[offset + sTilesW + 1] = tiles[7];

        // Draw transparent tiles to the top background layer.
        gOverworldTilemapBuffer_Bg1[offset] = 0;
        gOverworldTilemapBuffer_Bg1[offset + 1] = 0;
        gOverworldTilemapBuffer_Bg1[offset + sTilesW] = 0;
        gOverworldTilemapBuffer_Bg1[offset + sTilesW + 1] = 0;
        break;
    case METATILE_LAYER_TYPE_NORMAL:
        // Draw garbage to the bottom background layer.
        gOverworldTilemapBuffer_Bg3[offset] = 0x3014;
        gOverworldTilemapBuffer_Bg3[offset + 1] = 0x3014;
        gOverworldTilemapBuffer_Bg3[offset + sTilesW] = 0x3014;
        gOverworldTilemapBuffer_Bg3[offset + sTilesW + 1] = 0x3014;

        // Draw metatile's bottom layer to the middle background layer.
        gOverworldTilemapBuffer_Bg2[offset] = tiles[0];
        gOverworldTilemapBuffer_Bg2[offset + 1] = tiles[1];
        gOverworldTilemapBuffer_Bg2[offset + sTilesW] = tiles[2];
        gOverworldTilemapBuffer_Bg2[offset + sTilesW + 1] = tiles[3];

        // Draw metatile's top layer to the top background layer, which covers object event sprites.
        gOverworldTilemapBuffer_Bg1[offset] = tiles[4];
        gOverworldTilemapBuffer_Bg1[offset + 1] = tiles[5];
        gOverworldTilemapBuffer_Bg1[offset + sTilesW] = tiles[6];
        gOverworldTilemapBuffer_Bg1[offset + sTilesW + 1] = tiles[7];
        break;
    }
    ScheduleBgCopyTilemapToVram(1);
    ScheduleBgCopyTilemapToVram(2);
    ScheduleBgCopyTilemapToVram(3);
}

static s32 MapPosToBgTilemapOffset(struct FieldCameraOffset *cameraOffset, s32 x, s32 y)
{
    x = (x - FIELD_ORIGIN_X) * 2;
    if (x >= sTilesW || x < 0)
        return -1;
    x = (x + cameraOffset->xTileOffset) % sTilesW;

    y = (y - FIELD_ORIGIN_Y) * 2;
    if (y >= sTilesH || y < 0)
        return -1;
    y = (y + cameraOffset->yTileOffset) % sTilesH;

    return TilemapOffset(x, y);
}

static void CameraUpdateCallback(struct CameraObject *fieldCamera)
{
    if (fieldCamera->spriteId != 0)
    {
        fieldCamera->movementSpeedX = gSprites[fieldCamera->spriteId].sCamera_MoveX;
        fieldCamera->movementSpeedY = gSprites[fieldCamera->spriteId].sCamera_MoveY;
    }
}

void ResetCameraUpdateInfo(void)
{
    gFieldCamera.movementSpeedX = 0;
    gFieldCamera.movementSpeedY = 0;
    gFieldCamera.x = 0;
    gFieldCamera.y = 0;
    gFieldCamera.spriteId = 0;
    gFieldCamera.callback = NULL;
}

u32 InitCameraUpdateCallback(u8 trackedSpriteId)
{
    if (gFieldCamera.spriteId != 0)
        DestroySprite(&gSprites[gFieldCamera.spriteId]);
    gFieldCamera.spriteId = AddCameraObject(trackedSpriteId);
    gFieldCamera.callback = CameraUpdateCallback;
    return 0;
}

void CameraUpdate(void)
{
    int deltaX;
    int deltaY;
    int curMovementOffsetY;
    int curMovementOffsetX;
    int movementSpeedX;
    int movementSpeedY;

    if (gFieldCamera.callback != NULL)
        gFieldCamera.callback(&gFieldCamera);
    movementSpeedX = gFieldCamera.movementSpeedX;
    movementSpeedY = gFieldCamera.movementSpeedY;
    deltaX = 0;
    deltaY = 0;
    curMovementOffsetX = gFieldCamera.x;
    curMovementOffsetY = gFieldCamera.y;


    if (curMovementOffsetX == 0 && movementSpeedX != 0)
    {
        if (movementSpeedX > 0)
            deltaX = 1;
        else
            deltaX = -1;
    }
    if (curMovementOffsetY == 0 && movementSpeedY != 0)
    {
        if (movementSpeedY > 0)
            deltaY = 1;
        else
            deltaY = -1;
    }
    if (curMovementOffsetX != 0 && curMovementOffsetX == -movementSpeedX)
    {
        if (movementSpeedX > 0)
            deltaX = 1;
        else
            deltaX = -1;
    }
    if (curMovementOffsetY != 0 && curMovementOffsetY == -movementSpeedY)
    {
        if (movementSpeedY > 0)
            deltaX = 1;
        else
            deltaX = -1;
    }

    gFieldCamera.x += movementSpeedX;
    gFieldCamera.x %= 16;
    gFieldCamera.y += movementSpeedY;
    gFieldCamera.y %= 16;

    if (deltaX != 0 || deltaY != 0)
    {
        CameraMove(deltaX, deltaY);
        UpdateObjectEventsForCameraUpdate(deltaX, deltaY);
        RotatingGatePuzzleCameraUpdate(deltaX, deltaY);
        SetBerryTreesSeen();
        AddCameraTileOffset(&sFieldCameraOffset, deltaX * 2, deltaY * 2);
        RedrawMapSlicesForCameraUpdate(&sFieldCameraOffset, deltaX * 2, deltaY * 2);
    }

    AddCameraPixelOffset(&sFieldCameraOffset, movementSpeedX, movementSpeedY);
    gTotalCameraPixelOffsetX -= movementSpeedX;
    gTotalCameraPixelOffsetY -= movementSpeedY;
}

void MoveCameraAndRedrawMap(int deltaX, int deltaY) //unused
{
    CameraMove(deltaX, deltaY);
    UpdateObjectEventsForCameraUpdate(deltaX, deltaY);
    DrawWholeMapView();
    gTotalCameraPixelOffsetX -= deltaX * 16;
    gTotalCameraPixelOffsetY -= deltaY * 16;
}

void SetCameraPanningCallback(void (*callback)(void))
{
    sFieldCameraPanningCallback = callback;
}

void SetCameraPanning(s16 horizontal, s16 vertical)
{
    sHorizontalCameraPan = horizontal;
    sVerticalCameraPan = vertical + 32;
}

void InstallCameraPanAheadCallback(void)
{
    sFieldCameraPanningCallback = CameraPanningCB_PanAhead;
    sBikeCameraPanFlag = FALSE;
    sHorizontalCameraPan = 0;
    sVerticalCameraPan = 32;
}

void UpdateCameraPanning(void)
{
    if (sFieldCameraPanningCallback != NULL)
        sFieldCameraPanningCallback();
    //Update sprite offset of overworld objects
    gSpriteCoordOffsetX = gTotalCameraPixelOffsetX - sHorizontalCameraPan;
    gSpriteCoordOffsetY = gTotalCameraPixelOffsetY - sVerticalCameraPan - 8;
}

static void CameraPanningCB_PanAhead(void)
{
    u8 var;

    if (gUnusedBikeCameraAheadPanback == FALSE)
    {
        InstallCameraPanAheadCallback();
    }
    else
    {
        // this code is never reached
        if (gPlayerAvatar.tileTransitionState == T_TILE_TRANSITION)
        {
            sBikeCameraPanFlag ^= 1;
            if (sBikeCameraPanFlag == FALSE)
                return;
        }
        else
        {
            sBikeCameraPanFlag = FALSE;
        }

        var = GetPlayerMovementDirection();
        if (var == 2)
        {
            if (sVerticalCameraPan > -8)
                sVerticalCameraPan -= 2;
        }
        else if (var == 1)
        {
            if (sVerticalCameraPan < 72)
                sVerticalCameraPan += 2;
        }
        else if (sVerticalCameraPan < 32)
        {
            sVerticalCameraPan += 2;
        }
        else if (sVerticalCameraPan > 32)
        {
            sVerticalCameraPan -= 2;
        }
    }
}
