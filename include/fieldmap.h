#ifndef GUARD_FIELDMAP_H
#define GUARD_FIELDMAP_H

#define NUM_TILES_IN_PRIMARY 512
#define NUM_TILES_TOTAL 1024
#define NUM_METATILES_IN_PRIMARY 512
#define NUM_METATILES_TOTAL 1024
#define NUM_PALS_IN_PRIMARY 6
#define NUM_PALS_TOTAL 13
// The backup layout carries this much border around the map, on top of
// MAP_OFFSET, so the expanded viewport has real map (and connected-map) data to
// show instead of falling back to border metatiles. This is buffer margin only:
// MAP_OFFSET still defines the coordinate space that object events, warps and
// gSaveBlock1Ptr->pos live in, so saves are unaffected.
#define MAP_BORDER_EXTRA 64
#define MAP_BORDER_TOTAL (MAP_OFFSET + MAP_BORDER_EXTRA)

// The layout carries MAP_BORDER_EXTRA of spare margin on every side; these are
// the dimensions the map itself occupies, which is what edge tests and
// whole-map scans want rather than the padded buffer size.
#define MAP_GRID_VANILLA_WIDTH  (gBackupMapLayout.width  - MAP_BORDER_EXTRA * 2)
#define MAP_GRID_VANILLA_HEIGHT (gBackupMapLayout.height - MAP_BORDER_EXTRA * 2)

#define MAX_MAP_DATA_SIZE 131072

// MAX_TILESET_BANKS -- how many distinct tileset pairs can be on screen at
// once -- lives in include/gba/defines.h, next to the VRAM and palette sizes
// it decides.

#define NUM_TILES_PER_METATILE 8

// Map coordinates are offset by 7 when using the map
// buffer because it needs to load sufficient border
// metatiles to fill the player's view (the player has
// 7 metatiles of view horizontally in either direction).
// Do NOT retune this to widen the drawn window. Object events, warps and
// script triggers all have their map-data coordinates shifted into a space
// offset by MAP_OFFSET, and gSaveBlock1Ptr->pos is stored in that space too --
// so changing it desynchronises the player from every object on the map and
// invalidates existing saves. Reading past the backup layout is already
// handled: MapGridGetMetatileIdAt returns the map's border metatiles, which is
// what vanilla draws beyond a map edge anyway.
#define MAP_OFFSET 7
#define MAP_OFFSET_W (MAP_OFFSET * 2 + 1)
#define MAP_OFFSET_H (MAP_OFFSET * 2)

#include "main.h"

extern struct BackupMapLayout gBackupMapLayout;

s32 MapGridGetMetatileIdAt(s32 x, s32 y);
u8 MapGridGetTilesetBankAt(s32 x, s32 y);
const struct Tileset *GetTilesetBankPrimary(u8 bank);
const struct Tileset *GetTilesetBankSecondary(u8 bank);
u8 GetTilesetBankCount(void);
void LoadTilesetBanks(void);
const u8 *GetTilesetBankRemap(void);
s32 MapGridGetMetatileBehaviorAt(s32 x, s32 y);
void MapGridSetMetatileIdAt(s32 x, s32 y, u16 metatile);
void MapGridSetMetatileEntryAt(s32 x, s32 y, u16 metatile);
void GetCameraCoords(u16 *x, u16 *y);
u8 MapGridGetCollisionAt(s32 x, s32 y);
s32 GetMapBorderIdAt(s32 x, s32 y);
bool32 CanCameraMoveInDirection(s32 direction);
u16 GetMetatileAttributesById(u16 metatile);
void GetCameraFocusCoords(u16 *x, u16 *y);
u8 MapGridGetMetatileLayerTypeAt(s32 x, s32 y);
u8 MapGridGetElevationAt(s32 x, s32 y);
bool8 CameraMove(s32 x, s32 y);
void SaveMapView(void);
void SetCameraFocusCoords(u16 x, u16 y);
void InitMap(void);
void InitMapFromSavedGame(void);
void InitTrainerHillMap(void);
void InitBattlePyramidMap(bool8 setPlayerPosition);
void CopyMapTilesetsToVram(struct MapLayout const *mapLayout);
void LoadMapTilesetPalettes(struct MapLayout const *mapLayout);
void LoadSecondaryTilesetPalette(struct MapLayout const *mapLayout);
void CopySecondaryTilesetToVramUsingHeap(struct MapLayout const *mapLayout);
void CopyPrimaryTilesetToVram(struct MapLayout const *mapLayout);
void CopySecondaryTilesetToVram(struct MapLayout const *mapLayout);
const struct MapHeader *const GetMapHeaderFromConnection(const struct MapConnection *connection);
const struct MapConnection *GetMapConnectionAtPos(s16 x, s16 y);
void MapGridSetMetatileImpassabilityAt(s32 x, s32 y, bool32 impassable);

// field_region_map.c
void FieldInitRegionMap(MainCallback callback);

#endif //GUARD_FIELDMAP_H
