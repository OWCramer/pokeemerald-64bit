#ifndef GUARD_FIELD_CAMERA_H
#define GUARD_FIELD_CAMERA_H

#include "platform/framedraw.h"

struct CameraObject
{
    void (*callback)(struct CameraObject *);
    u32 spriteId;
    s32 movementSpeedX;
    s32 movementSpeedY;
    s32 x;
    s32 y;
};

extern struct CameraObject gFieldCamera;
extern u16 gTotalCameraPixelOffsetX;
extern u16 gTotalCameraPixelOffsetY;

void DrawWholeMapView(void);
void CurrentMapDrawMetatileAt(int x, int y);
// Metatiles of map beyond the vanilla view that the viewport is *currently*
// showing, plus two of margin so objects come into existence before they
// scroll in rather than popping in at the edge. Derived from the live render
// size: pinning this to the maximum expansion makes NPCs appear exactly on the
// visible boundary once the window is large, and wastes object slots on a
// small one.
#define FIELD_VIEW_EXTRA_X_MT ((gRenderOffsetX + 15) / 16 + 2)
#define FIELD_VIEW_EXTRA_Y_MT ((gRenderOffsetY + 15) / 16 + 2)

void InitFieldTilemaps(void);
void FreeFieldTilemaps(void);
void GetCameraOffsetWithPan(s16 *x, s16 *y);
void DrawDoorMetatileAt(int x, int y, u16 *tiles);
void ResetFieldCamera(void);
void ResetCameraUpdateInfo(void);
u32 InitCameraUpdateCallback(u8 trackedSpriteId);
void CameraUpdate(void);
void SetCameraPanningCallback(void (*callback)(void));
void SetCameraPanning(s16 horizontal, s16 vertical);
void InstallCameraPanAheadCallback(void);
void UpdateCameraPanning(void);
void FieldUpdateBgTilemapScroll(void);

#endif //GUARD_FIELD_CAMERA_H
