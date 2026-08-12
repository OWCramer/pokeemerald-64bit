#include "global.h"
#include "battle_pyramid.h"
#include "bg.h"
#include "fieldmap.h"
#include "fldeff.h"
#include "fldeff_misc.h"
#include "frontier_util.h"
#include "malloc.h"
#include "menu.h"
#include "mirage_tower.h"
#include "overworld.h"
#include "palette.h"
#include "pokenav.h"
#include "script.h"
#include "secret_base.h"
#include "trainer_hill.h"
#include "tv.h"
#include "platform/framedraw.h"
#include "constants/layouts.h"
#include "constants/rgb.h"
#include "constants/metatile_behaviors.h"

struct ConnectionFlags
{
    u8 south:1;
    u8 north:1;
    u8 west:1;
    u8 east:1;
};

EWRAM_DATA static u16 ALIGNED(4) sBackupMapData[MAX_MAP_DATA_SIZE] = {0};

// Which tileset bank each cell's metatile id should be decoded against.
//
// A map cell is 16 bits with no room to spare (10 metatile id, 2 collision,
// 4 elevation), so the bank cannot live in the cell itself. Every cell starts
// tagged with the current map's bank; connections write their own map's bank
// over the cells they fill.
//
// Without this, a neighbouring map's metatile id >= NUM_METATILES_IN_PRIMARY
// was decoded against the *current* map's secondary tileset -- correct data
// drawn with the wrong tiles, which is why Route 110 rendered as garbage from
// Route 103 (Mauville vs Petalburg) while collision stayed right.
EWRAM_DATA static u8 sBackupMapBank[MAX_MAP_DATA_SIZE] = {0};

// Every tileset in the game gets a slot of its own, holding the 512 tiles a
// primary or a secondary occupies. There are 74 of them against 76 pairs, so
// storing tiles per tileset rather than per pair means gTileset_General -- the
// primary all but a handful of maps share -- is held once instead of seventy
// times, and the whole game's tiles come to 1.2 MB.
static const struct Tileset *sTilesetSlots[MAX_TILESET_SLOTS];
static u8 sTilesetSlotCount;

// A bank is a tileset *pair*, because that is what a metatile id is meaningful
// against: below NUM_METATILES_IN_PRIMARY it names the primary, above it the
// secondary. The bank is the middle man -- a cell says which pair it belongs
// to, and the pair says which two slots to resolve its ids and palettes
// against.
//
// Both banks and slots are permanent. An earlier version rebuilt them on every
// map load -- the map being entered took bank 0, the one being left became a
// connection, tiles were reloaded and every tag already in a tilemap was
// translated to match -- and a frame of a neighbouring map drawn against the
// wrong tileset still got through that choreography. Nothing is renumbered or
// reloaded now, so a bank id under a tilemap cannot come to mean anything
// different from one frame to the next.
//
// Bank 0 means "no bank": the stock VRAM and palette layout, which is what
// every menu and text box decodes against, and the fallback for a pair that
// could not be assigned one.
struct TilesetBank
{
    const struct Tileset *primary;
    const struct Tileset *secondary;
    u8 primarySlot;
    u8 secondarySlot;
};

// Where each map that got filled ended up, so a cell with no map data can take
// the border of the map it actually sits next to.
//
// Border metatiles used to come from whichever map the player was standing on,
// which was right when vanilla showed seven of them past your own map's edge.
// Across a viewport that sees two maps out it meant the filler beyond Route 117
// was Mauville's ocean while you stood in Mauville and Route 117's trees once
// you stood in Route 117 -- the same piece of world changing as you walked, on
// top of simply being the wrong terrain.
struct FilledMapRect
{
    s16 x;
    s16 y;
    s16 width;
    s16 height;
    const u16 *border;
    u8 bank;
};

#define MAX_FILLED_MAP_RECTS 32
static struct FilledMapRect sFilledMapRects[MAX_FILLED_MAP_RECTS];
static u8 sFilledMapRectCount;

static struct TilesetBank sTilesetBanks[MAX_TILESET_BANKS];
static u8 sTilesetBankCount = 1;
static u8 sCurrentTilesetBank;
EWRAM_DATA struct MapHeader gMapHeader = {0};
EWRAM_DATA struct Camera gCamera = {0};
EWRAM_DATA static struct ConnectionFlags sMapConnectionFlags = {0};
EWRAM_DATA static u32 UNUSED sFiller = 0; // without this, the next file won't align properly

COMMON_DATA struct BackupMapLayout gBackupMapLayout = {0};

static const struct ConnectionFlags sDummyConnectionFlags = {0};

extern const struct MapLayout *const gMapLayouts[];

static void CopyTilesetToVramDirect(struct Tileset const *tileset, u16 numTiles, u32 tileOffset);
static void LoadTilesetPalette(struct Tileset const *tileset, u16 destOffset, u16 size);
static void FillConnection(s32 x, s32 y, const struct MapHeader *connectedMapHeader, s32 x2, s32 y2, s32 width, s32 height);
static u16 GetBorderBlockAt(s32 x, s32 y);
static u8 GetBorderBankAt(s32 x, s32 y);
static void ResetTilesetBanks(void);
static void InitMapLayoutData(const struct MapHeader *mapHeader);
static void InitBackupMapLayoutData(const u16 *map, u16 width, u16 height);
static void FillSouthConnection(struct MapHeader const *mapHeader, struct MapHeader const *connectedMapHeader, s32 offset);
static void FillNorthConnection(struct MapHeader const *mapHeader, struct MapHeader const *connectedMapHeader, s32 offset);
static void FillWestConnection(struct MapHeader const *mapHeader, struct MapHeader const *connectedMapHeader, s32 offset);
static void FillEastConnection(struct MapHeader const *mapHeader, struct MapHeader const *connectedMapHeader, s32 offset);
static void InitBackupMapLayoutConnections(const struct MapHeader *mapHeader);
static void LoadSavedMapView(void);
static bool8 SkipCopyingMetatileFromSavedMap(u16 *mapBlock, u16 mapWidth, u8 yMode);
static const struct MapConnection *GetIncomingConnection(u8 direction, s32 x, s32 y);
static bool8 IsPosInIncomingConnectingMap(u8 direction, s32 x, s32 y, const struct MapConnection *connection);
static bool8 IsCoordInIncomingConnectingMap(s32 coord, s32 srcMax, s32 destMax, s32 offset);


// Map coordinates are offset by MAP_BORDER_EXTRA to reach a layout index; the
// coordinate space itself is unchanged.
#define MapGridIndex(x, y) (((x) + MAP_BORDER_EXTRA) + gBackupMapLayout.width * ((y) + MAP_BORDER_EXTRA))

#define AreCoordsWithinMapGridBounds(x, y) ((x) + MAP_BORDER_EXTRA >= 0 && (x) + MAP_BORDER_EXTRA < gBackupMapLayout.width && (y) + MAP_BORDER_EXTRA >= 0 && (y) + MAP_BORDER_EXTRA < gBackupMapLayout.height)

#define GetMapGridBlockAt(x, y) (AreCoordsWithinMapGridBounds(x, y) ? gBackupMapLayout.map[MapGridIndex(x, y)] : GetBorderBlockAt(x, y))

const struct MapHeader *const GetMapHeaderFromConnection(const struct MapConnection *connection)
{
    return Overworld_GetMapHeaderByGroupAndId(connection->mapGroup, connection->mapNum);
}

void InitMap(void)
{
    InitMapLayoutData(&gMapHeader);
    SetOccupiedSecretBaseEntranceMetatiles(gMapHeader.events);
    RunOnLoadMapScript();
}

void InitMapFromSavedGame(void)
{
    InitMapLayoutData(&gMapHeader);
    InitSecretBaseAppearance(FALSE);
    SetOccupiedSecretBaseEntranceMetatiles(gMapHeader.events);
    LoadSavedMapView();
    RunOnLoadMapScript();
    UpdateTVScreensOnMap(MAP_GRID_VANILLA_WIDTH, MAP_GRID_VANILLA_HEIGHT);
}

void InitBattlePyramidMap(bool8 setPlayerPosition)
{
    CpuFastFill16(MAPGRID_UNDEFINED, sBackupMapData, sizeof(sBackupMapData));
    ResetTilesetBanks();
    GenerateBattlePyramidFloorLayout(sBackupMapData, setPlayerPosition);
}

void InitTrainerHillMap(void)
{
    CpuFastFill16(MAPGRID_UNDEFINED, sBackupMapData, sizeof(sBackupMapData));
    ResetTilesetBanks();
    GenerateTrainerHillFloorLayout(sBackupMapData);
}

// Returns the slot holding a tileset's tiles, claiming and filling one the
// first time the tileset is seen. Returns -1 if there is no room, which leaves
// the caller to fall back to bank 0.
static s32 RegisterTilesetSlot(const struct Tileset *tileset)
{
    u8 i;

    if (tileset == NULL)
        return -1;

    for (i = 0; i < sTilesetSlotCount; i++)
    {
        if (sTilesetSlots[i] == tileset)
            return i;
    }

    if (sTilesetSlotCount >= MAX_TILESET_SLOTS)
        return -1;

    i = sTilesetSlotCount++;
    sTilesetSlots[i] = tileset;
    CopyTilesetToVramDirect(tileset, TILESET_SLOT_NUM_TILES, TILESET_SLOT_TILE_BASE(i));
    return i;
}

// Returns the bank for a tileset pair, assigning one if the pair has not been
// seen before. A pair that will not fit -- more distinct pairs than there are
// banks, or a tileset that could not claim a slot -- falls back to bank 0,
// which is the old wrong-but-harmless behaviour rather than an out-of-range
// bank.
static u8 RegisterTilesetBank(const struct Tileset *primary, const struct Tileset *secondary)
{
    s32 primarySlot, secondarySlot;
    u8 i;

    for (i = 1; i < sTilesetBankCount; i++)
    {
        if (sTilesetBanks[i].primary == primary && sTilesetBanks[i].secondary == secondary)
            return i;
    }

    if (sTilesetBankCount >= MAX_TILESET_BANKS)
        return 0;

    primarySlot = RegisterTilesetSlot(primary);
    secondarySlot = RegisterTilesetSlot(secondary);
    if (primarySlot < 0 || secondarySlot < 0)
        return 0;

    i = sTilesetBankCount++;
    sTilesetBanks[i].primary = primary;
    sTilesetBanks[i].secondary = secondary;
    sTilesetBanks[i].primarySlot = primarySlot;
    sTilesetBanks[i].secondarySlot = secondarySlot;
    return i;
}

// Assigns a bank to every tileset pair the game has and loads all their tiles,
// once, at startup. 76 pairs over 74 tilesets, 1.2 MB. Doing it here rather
// than as maps are entered means no map load ever decompresses a tileset, and
// nothing about a bank changes while the game is running.
void InitTilesetBanks(void)
{
    u32 i;

    for (i = 0; i < LAYOUTS_COUNT; i++)
    {
        const struct MapLayout *layout = gMapLayouts[i];

        if (layout != NULL)
            RegisterTilesetBank(layout->primaryTileset, layout->secondaryTileset);
    }
}

// Tells the renderer where each bank's tiles and palettes are -- except the
// current map's, which is pointed back at the stock VRAM and palette layout.
//
// This is the one thing that keeps the rest of the game working. Door
// animations, the cave-entry flash, Mirage Tower crumbling, field move streaks:
// everything that changes the field's tiles or palettes at runtime writes to
// the stock layout, and has since long before any of this existed. Redirecting
// each of them to a slot means finding all of them, and a miss is either
// invisible or -- because slots are permanent -- corruption that outlives the
// map. Only *other* maps on screen go through a bank, which is all a bank was
// ever for.
static void PublishTilesetBankBases(void)
{
    u8 bank;

    for (bank = 1; bank < sTilesetBankCount; bank++)
    {
        if (bank == sCurrentTilesetBank)
        {
            gTilesetBankTileDelta[bank][0] = 0;
            gTilesetBankTileDelta[bank][1] = 0;
            gTilesetBankPalBase[bank] = 0;
        }
        else
        {
            // A secondary's ids start at NUM_TILES_IN_PRIMARY but its slot
            // starts at 0, so its delta carries that back off.
            gTilesetBankTileDelta[bank][0] = TILESET_SLOT_TILE_BASE(sTilesetBanks[bank].primarySlot);
            gTilesetBankTileDelta[bank][1] = TILESET_SLOT_TILE_BASE(sTilesetBanks[bank].secondarySlot)
                                           - NUM_TILES_IN_PRIMARY;
            gTilesetBankPalBase[bank] = TILESET_BANK_PAL_BASE(bank);
        }
    }
}

// Tags every cell with the current map's bank. Connections overwrite the cells
// they fill; the Battle Pyramid and Trainer Hill generate their floors without
// going through InitMapLayoutData and call this directly.
static void ResetTilesetBanks(void)
{
    sCurrentTilesetBank = 0;
    if (gMapHeader.mapLayout != NULL)
        sCurrentTilesetBank = RegisterTilesetBank(gMapHeader.mapLayout->primaryTileset,
                                                  gMapHeader.mapLayout->secondaryTileset);
    memset(sBackupMapBank, sCurrentTilesetBank, sizeof(sBackupMapBank));
    sFilledMapRectCount = 0;
    PublishTilesetBankBases();
}

u8 GetCurrentTilesetBank(void)
{
    return sCurrentTilesetBank;
}

// First tile of the slot holding this tileset, or 0 if it has no slot. Every
// bank whose pair includes this tileset resolves to the same slot, so a caller
// that writes here reaches every map using it at once.
u32 GetTilesetSlotTileBase(const struct Tileset *tileset)
{
    u8 i;

    for (i = 0; i < sTilesetSlotCount; i++)
    {
        if (sTilesetSlots[i] == tileset)
            return TILESET_SLOT_TILE_BASE(i);
    }
    return 0;
}

const struct Tileset *GetTilesetBankPrimary(u8 bank)
{
    if (bank >= sTilesetBankCount)
        return NULL;
    return sTilesetBanks[bank].primary;
}

const struct Tileset *GetTilesetBankSecondary(u8 bank)
{
    if (bank >= sTilesetBankCount)
        return NULL;
    return sTilesetBanks[bank].secondary;
}

u8 GetTilesetBankCount(void)
{
    return sTilesetBankCount;
}

u8 MapGridGetTilesetBankAt(s32 x, s32 y)
{
    // A cell with no map data draws a border metatile, so it has to be decoded
    // against the tileset of whichever map that border came from.
    if (!AreCoordsWithinMapGridBounds(x, y))
        return GetBorderBankAt(x, y);
    if (gBackupMapLayout.map[MapGridIndex(x, y)] == MAPGRID_UNDEFINED)
        return GetBorderBankAt(x, y);
    return sBackupMapBank[MapGridIndex(x, y)];
}

static void RecordFilledMapRect(s32 x, s32 y, s32 width, s32 height, const u16 *border, u8 bank)
{
    struct FilledMapRect *rect;

    if (sFilledMapRectCount >= MAX_FILLED_MAP_RECTS || border == NULL)
        return;

    rect = &sFilledMapRects[sFilledMapRectCount++];
    rect->x = x;
    rect->y = y;
    rect->width = width;
    rect->height = height;
    rect->border = border;
    rect->bank = bank;
}

// The filled map a cell with no data of its own belongs to: the nearest one it
// sits directly above, below, or beside. A cell diagonally off every map
// belongs to none of them and falls back to the map the player is on, which is
// the old behaviour and only ever shows in a far corner.
static const struct FilledMapRect *FindBorderOwner(s32 x, s32 y)
{
    const struct FilledMapRect *best = NULL;
    s32 bestDistance = 0x7FFF;
    u32 i;

    for (i = 0; i < sFilledMapRectCount; i++)
    {
        const struct FilledMapRect *rect = &sFilledMapRects[i];
        s32 distance;

        if (x >= rect->x && x < rect->x + rect->width)
        {
            if (y < rect->y)
                distance = rect->y - y;
            else if (y >= rect->y + rect->height)
                distance = y - (rect->y + rect->height) + 1;
            else
                distance = 0;
        }
        else if (y >= rect->y && y < rect->y + rect->height)
        {
            if (x < rect->x)
                distance = rect->x - x;
            else
                distance = x - (rect->x + rect->width) + 1;
        }
        else
        {
            continue;
        }

        if (distance < bestDistance)
        {
            bestDistance = distance;
            best = rect;
        }
    }

    return best;
}

// Parity stays global rather than relative to the owning map: it is what vanilla
// indexes a border's 2x2 pattern by, and making it map-relative would shift the
// current map's own border by one.
static u16 GetBorderBlockAt(s32 x, s32 y)
{
    const struct FilledMapRect *owner = FindBorderOwner(x, y);
    const u16 *border = owner != NULL ? owner->border : gMapHeader.mapLayout->border;

    return border[((x + 1) & 1) + (((y + 1) & 1) << 1)] | MAPGRID_IMPASSABLE;
}

static u8 GetBorderBankAt(s32 x, s32 y)
{
    const struct FilledMapRect *owner = FindBorderOwner(x, y);

    return owner != NULL ? owner->bank : sCurrentTilesetBank;
}

static void InitMapLayoutData(const struct MapHeader *mapHeader)
{
    const struct MapLayout *mapLayout = mapHeader->mapLayout;
    CpuFastFill16(MAPGRID_UNDEFINED, sBackupMapData, sizeof(sBackupMapData));

    // Everything defaults to the current map's bank; connections overwrite the
    // cells they fill.
    ResetTilesetBanks();

    gBackupMapLayout.map = sBackupMapData;
    gBackupMapLayout.width = mapLayout->width + MAP_OFFSET_W + MAP_BORDER_EXTRA * 2;
    gBackupMapLayout.height = mapLayout->height + MAP_OFFSET_H + MAP_BORDER_EXTRA * 2;

    if (gBackupMapLayout.width * gBackupMapLayout.height > MAX_MAP_DATA_SIZE)
        return;

    InitBackupMapLayoutData(mapLayout->map, mapLayout->width, mapLayout->height);
    InitBackupMapLayoutConnections(mapHeader);
}

static void InitBackupMapLayoutData(const u16 *map, u16 width, u16 height)
{
    u16 *dest;
    s32 y;

    RecordFilledMapRect(MAP_BORDER_TOTAL - MAP_BORDER_EXTRA, MAP_BORDER_TOTAL - MAP_BORDER_EXTRA,
                        width, height, gMapHeader.mapLayout->border, sCurrentTilesetBank);

    dest = gBackupMapLayout.map;
    dest += gBackupMapLayout.width * MAP_BORDER_TOTAL + MAP_BORDER_TOTAL;
    for (y = 0; y < height; y++)
    {
        CpuCopy16(map, dest, width * 2);
        dest += gBackupMapLayout.width;
        map += width;
    }
}

// Where a connected map's (0, 0) lands in the layout, given where the map it
// hangs off starts.
static bool32 GetConnectionOrigin(const struct MapHeader *mapHeader, const struct MapConnection *connection,
                                  const struct MapHeader *cMap, s32 originX, s32 originY, s32 *outX, s32 *outY)
{
    switch (connection->direction)
    {
    case CONNECTION_NORTH:
        *outX = originX + connection->offset;
        *outY = originY - cMap->mapLayout->height;
        return TRUE;
    case CONNECTION_SOUTH:
        *outX = originX + connection->offset;
        *outY = originY + mapHeader->mapLayout->height;
        return TRUE;
    case CONNECTION_WEST:
        *outX = originX - cMap->mapLayout->width;
        *outY = originY + connection->offset;
        return TRUE;
    case CONNECTION_EAST:
        *outX = originX + mapHeader->mapLayout->width;
        *outY = originY + connection->offset;
        return TRUE;
    }
    return FALSE; // dive and emerge are not places on this layout
}

// Fills a whole map at an arbitrary position, clipped to the layout.
static void FillMapRegion(const struct MapHeader *mapHeader, s32 x, s32 y)
{
    s32 srcX = 0, srcY = 0;
    s32 width = mapHeader->mapLayout->width;
    s32 height = mapHeader->mapLayout->height;

    if (x < 0)
    {
        srcX = -x;
        width += x;
        x = 0;
    }
    if (y < 0)
    {
        srcY = -y;
        height += y;
        y = 0;
    }
    if (x + width > gBackupMapLayout.width)
        width = gBackupMapLayout.width - x;
    if (y + height > gBackupMapLayout.height)
        height = gBackupMapLayout.height - y;

    if (width > 0 && height > 0)
        FillConnection(x, y, mapHeader, srcX, srcY, width, height);
}

// The expanded viewport sees further than the maps this one is joined to:
// standing on Route 110 you can see clear past Mauville into Route 111. Those
// are not connections of the current map, so nothing filled them and they fell
// back to border metatiles -- which is why Route 110's ocean was drawn through
// the middle of Mauville, and Route 111's dirt through Route 110. It also meant
// the same piece of world changed appearance depending on which map the player
// happened to be standing on.
//
// One more level of connections covers what the margin can show. Deeper would
// need a visited set and cycle handling to buy very little more on screen.
static void FillConnectionsOfConnection(const struct MapHeader *mapHeader, const struct MapHeader *from,
                                        s32 originX, s32 originY)
{
    s32 count, i, x, y;
    const struct MapConnection *connection;
    const struct MapHeader *cMap;

    if (mapHeader->connections == NULL || mapHeader->connections->connections == NULL)
        return;

    count = mapHeader->connections->count;
    connection = mapHeader->connections->connections;
    for (i = 0; i < count; i++, connection++)
    {
        cMap = GetMapHeaderFromConnection(connection);
        // Skip the way we came: already filled, and at the same place.
        if (cMap == NULL || cMap == from)
            continue;
        if (GetConnectionOrigin(mapHeader, connection, cMap, originX, originY, &x, &y))
            FillMapRegion(cMap, x, y);
    }
}

static void InitBackupMapLayoutConnections(const struct MapHeader *mapHeader)
{
    s32 count, i, offset, x, y;
    const struct MapConnection *connection;
    const struct MapHeader *cMap;

    if (!mapHeader->connections)
        return;

    count = mapHeader->connections->count;
    connection = mapHeader->connections->connections;
    sMapConnectionFlags = sDummyConnectionFlags;
    for (i = 0; i < count; i++, connection++)
    {
        cMap = GetMapHeaderFromConnection(connection);
        offset = connection->offset;
        switch (connection->direction)
        {
        case CONNECTION_SOUTH:
            FillSouthConnection(mapHeader, cMap, offset);
            sMapConnectionFlags.south = TRUE;
            break;
        case CONNECTION_NORTH:
            FillNorthConnection(mapHeader, cMap, offset);
            sMapConnectionFlags.north = TRUE;
            break;
        case CONNECTION_WEST:
            FillWestConnection(mapHeader, cMap, offset);
            sMapConnectionFlags.west = TRUE;
            break;
        case CONNECTION_EAST:
            FillEastConnection(mapHeader, cMap, offset);
            sMapConnectionFlags.east = TRUE;
            break;
        }
    }

    // Second pass, so a map two hops away can never land on top of one the
    // player can actually walk to.
    connection = mapHeader->connections->connections;
    for (i = 0; i < count; i++, connection++)
    {
        cMap = GetMapHeaderFromConnection(connection);
        if (cMap != NULL
         && GetConnectionOrigin(mapHeader, connection, cMap, MAP_BORDER_TOTAL, MAP_BORDER_TOTAL, &x, &y))
            FillConnectionsOfConnection(cMap, mapHeader, x, y);
    }
}

static void FillConnection(s32 x, s32 y, const struct MapHeader *connectedMapHeader, s32 x2, s32 y2, s32 width, s32 height)
{
    s32 i;
    const u16 *src;
    u16 *dest;
    u8 *bankDest;
    s32 mapWidth;
    u8 bank;

    mapWidth = connectedMapHeader->mapLayout->width;
    src = &connectedMapHeader->mapLayout->map[mapWidth * y2 + x2];
    dest = &gBackupMapLayout.map[gBackupMapLayout.width * y + x];

    // Tag these cells so they are later decoded against the connected map's
    // tileset rather than ours.
    bank = RegisterTilesetBank(connectedMapHeader->mapLayout->primaryTileset,
                               connectedMapHeader->mapLayout->secondaryTileset);
    RecordFilledMapRect(x - MAP_BORDER_EXTRA, y - MAP_BORDER_EXTRA, width, height,
                        connectedMapHeader->mapLayout->border, bank);
    bankDest = &sBackupMapBank[gBackupMapLayout.width * y + x];

    for (i = 0; i < height; i++)
    {
        CpuCopy16(src, dest, width * 2);
        memset(bankDest, bank, width);
        dest += gBackupMapLayout.width;
        bankDest += gBackupMapLayout.width;
        src += mapWidth;
    }
}

static void FillSouthConnection(const struct MapHeader *mapHeader, const struct MapHeader *connectedMapHeader, s32 offset)
{
    s32 fillHeight;
    s32 x, y;
    s32 x2;
    s32 width;
    s32 cWidth;

    if (!connectedMapHeader)
        return;

    cWidth = connectedMapHeader->mapLayout->width;
    x = offset + MAP_BORDER_TOTAL;
    y = mapHeader->mapLayout->height + MAP_BORDER_TOTAL;
    if (x < 0)
    {
        x2 = -x;
        x += cWidth;
        if (x < gBackupMapLayout.width)
            width = x;
        else
            width = gBackupMapLayout.width;
        x = 0;
    }
    else
    {
        x2 = 0;
        if (x + cWidth < gBackupMapLayout.width)
            width = cWidth;
        else
            width = gBackupMapLayout.width - x;
    }

    fillHeight = MAP_BORDER_TOTAL;
    if (fillHeight > connectedMapHeader->mapLayout->height)
        fillHeight = connectedMapHeader->mapLayout->height;
    if (y + fillHeight > gBackupMapLayout.height)
        fillHeight = gBackupMapLayout.height - y;
    FillConnection(x, y, connectedMapHeader, x2, /*y2*/ 0, width, fillHeight);
}

static void FillNorthConnection(const struct MapHeader *mapHeader, const struct MapHeader *connectedMapHeader, s32 offset)
{
    s32 fillHeight;
    s32 x;
    s32 x2, y2;
    s32 width;
    s32 cWidth, cHeight;

    if (!connectedMapHeader)
        return;

    cWidth = connectedMapHeader->mapLayout->width;
    cHeight = connectedMapHeader->mapLayout->height;
    x = offset + MAP_BORDER_TOTAL;
    fillHeight = (cHeight < MAP_BORDER_TOTAL) ? cHeight : MAP_BORDER_TOTAL;
    y2 = cHeight - fillHeight;
    if (x < 0)
    {
        x2 = -x;
        x += cWidth;
        if (x < gBackupMapLayout.width)
            width = x;
        else
            width = gBackupMapLayout.width;
        x = 0;
    }
    else
    {
        x2 = 0;
        if (x + cWidth < gBackupMapLayout.width)
            width = cWidth;
        else
            width = gBackupMapLayout.width - x;
    }

    FillConnection(x, MAP_BORDER_TOTAL - fillHeight, connectedMapHeader, x2, y2, width, fillHeight);
}

static void FillWestConnection(const struct MapHeader *mapHeader, const struct MapHeader *connectedMapHeader, s32 offset)
{
    s32 fillWidth;
    s32 y;
    s32 x2, y2;
    s32 height;
    s32 cWidth, cHeight;

    if (!connectedMapHeader)
        return;

    cWidth = connectedMapHeader->mapLayout->width;
    cHeight = connectedMapHeader->mapLayout->height;
    y = offset + MAP_BORDER_TOTAL;
    fillWidth = (cWidth < MAP_BORDER_TOTAL) ? cWidth : MAP_BORDER_TOTAL;
    x2 = cWidth - fillWidth;
    if (y < 0)
    {
        y2 = -y;
        if (y + cHeight < gBackupMapLayout.height)
            height = y + cHeight;
        else
            height = gBackupMapLayout.height;
        y = 0;
    }
    else
    {
        y2 = 0;
        if (y + cHeight < gBackupMapLayout.height)
            height = cHeight;
        else
            height = gBackupMapLayout.height - y;
    }

    FillConnection(MAP_BORDER_TOTAL - fillWidth, y, connectedMapHeader, x2, y2, fillWidth, height);
}

static void FillEastConnection(const struct MapHeader *mapHeader, const struct MapHeader *connectedMapHeader, s32 offset)
{
    s32 fillWidth;
    s32 x, y;
    s32 y2;
    s32 height;
    s32 cHeight;
    if (!connectedMapHeader)
        return;

    cHeight = connectedMapHeader->mapLayout->height;
    x = mapHeader->mapLayout->width + MAP_BORDER_TOTAL;
    y = offset + MAP_BORDER_TOTAL;
    if (y < 0)
    {
        y2 = -y;
        if (y + cHeight < gBackupMapLayout.height)
            height = y + cHeight;
        else
            height = gBackupMapLayout.height;
        y = 0;
    }
    else
    {
        y2 = 0;
        if (y + cHeight < gBackupMapLayout.height)
            height = cHeight;
        else
            height = gBackupMapLayout.height - y;
    }

    fillWidth = MAP_BORDER_TOTAL + 1;
    if (fillWidth > connectedMapHeader->mapLayout->width)
        fillWidth = connectedMapHeader->mapLayout->width;
    if (x + fillWidth > gBackupMapLayout.width)
        fillWidth = gBackupMapLayout.width - x;
    FillConnection(x, y, connectedMapHeader, /*x2*/ 0, y2, fillWidth, height);
}

u8 MapGridGetElevationAt(s32 x, s32 y)
{
    u16 block = GetMapGridBlockAt(x, y);

    if (block == MAPGRID_UNDEFINED)
        return 0;

    return UNPACK_ELEVATION(block);
}

u8 MapGridGetCollisionAt(s32 x, s32 y)
{
    u16 block = GetMapGridBlockAt(x, y);

    if (block == MAPGRID_UNDEFINED)
        return 1;

    return UNPACK_COLLISION(block);
}

s32 MapGridGetMetatileIdAt(s32 x, s32 y)
{
    s32 block = GetMapGridBlockAt(x, y);

    if (block == MAPGRID_UNDEFINED)
        return UNPACK_METATILE(GetBorderBlockAt(x, y));

    return UNPACK_METATILE(block);
}

s32 MapGridGetMetatileBehaviorAt(s32 x, s32 y)
{
    return UNPACK_BEHAVIOR(GetMetatileAttributesById(MapGridGetMetatileIdAt(x, y)));
}

// Attributes for a metatile that belongs to `bank` rather than to the map the
// player is on. A bank with no tileset registered falls back to the current
// map, which is what every lookup did before banks existed.
static u16 GetMetatileAttributesByIdAndBank(u16 metatile, u8 bank)
{
    const struct Tileset *tileset;

    if (metatile >= NUM_METATILES_TOTAL)
        return MB_INVALID;

    if (metatile < NUM_METATILES_IN_PRIMARY)
        tileset = GetTilesetBankPrimary(bank);
    else
        tileset = GetTilesetBankSecondary(bank);

    if (tileset == NULL)
        return GetMetatileAttributesById(metatile);

    if (metatile >= NUM_METATILES_IN_PRIMARY)
        metatile -= NUM_METATILES_IN_PRIMARY;

    return tileset->metatileAttributes[metatile];
}

// Which background layer a metatile's two halves are drawn to. This has to
// follow the cell's own tileset like the metatile itself does, or a
// neighbouring map's rooftops end up behind the layer that covers sprites.
//
// The behaviour lookup below deliberately does not do this. Behaviours drive
// movement, and by the time the player can stand on a connected map's cells the
// camera transition has already made that map the current one, so every cell
// consulted for movement is bank 0 -- and leaving it alone keeps this change
// unable to affect what the player can walk on.
u8 MapGridGetMetatileLayerTypeAt(s32 x, s32 y)
{
    return UNPACK_LAYER_TYPE(GetMetatileAttributesByIdAndBank(MapGridGetMetatileIdAt(x, y),
                                                              MapGridGetTilesetBankAt(x, y)));
}

void MapGridSetMetatileIdAt(s32 x, s32 y, u16 metatile)
{
    if (AreCoordsWithinMapGridBounds(x, y))
    {
        // Elevation is ignored in the argument, but copy metatile ID and collision
        gBackupMapLayout.map[MapGridIndex(x, y)] &= MAPGRID_ELEVATION_MASK;
        gBackupMapLayout.map[MapGridIndex(x, y)] |= metatile & ~MAPGRID_ELEVATION_MASK;
    }
}

void MapGridSetMetatileEntryAt(s32 x, s32 y, u16 metatile)
{
    if (AreCoordsWithinMapGridBounds(x, y))
    {
        gBackupMapLayout.map[MapGridIndex(x, y)] = metatile;
    }
}

u16 GetMetatileAttributesById(u16 metatile)
{
    if (metatile < NUM_METATILES_IN_PRIMARY)
    {
        return gMapHeader.mapLayout->primaryTileset->metatileAttributes[metatile];
    }
    else if (metatile < NUM_METATILES_TOTAL)
    {
        return gMapHeader.mapLayout->secondaryTileset->metatileAttributes[metatile - NUM_METATILES_IN_PRIMARY];
    }
    else
    {
        return MB_INVALID;
    }
}

void SaveMapView(void)
{
    s32 i, j;
    s32 x, y;
    u16 *mapView;
    s32 width;
    mapView = gSaveBlock1Ptr->mapView;
    width = gBackupMapLayout.width;
    x = gSaveBlock1Ptr->pos.x;
    y = gSaveBlock1Ptr->pos.y;
    for (i = y; i < y + MAP_OFFSET_H; i++)
    {
        for (j = x; j < x + MAP_OFFSET_W; j++)
            *mapView++ = sBackupMapData[width * (i + MAP_BORDER_EXTRA) + (j + MAP_BORDER_EXTRA)];
    }
}

static bool32 SavedMapViewIsEmpty(void)
{
    u16 i;
    u32 marker = 0;

#ifndef UBFIX
    for (i = 0; i < sizeof(gSaveBlock1Ptr->mapView); i++)
        marker |= gSaveBlock1Ptr->mapView[i];
#else
    for (i = 0; i < ARRAY_COUNT(gSaveBlock1Ptr->mapView); i++)
        marker |= gSaveBlock1Ptr->mapView[i];
#endif


    if (marker == 0)
        return TRUE;
    else
        return FALSE;
}

static void ClearSavedMapView(void)
{
    CpuFill16(0, gSaveBlock1Ptr->mapView, sizeof(gSaveBlock1Ptr->mapView));
}

static void LoadSavedMapView(void)
{
    u8 yMode;
    s32 i, j;
    s32 x, y;
    u16 *mapView;
    s32 width;
    mapView = gSaveBlock1Ptr->mapView;
    if (SavedMapViewIsEmpty())
        return;

    width = gBackupMapLayout.width;
    x = gSaveBlock1Ptr->pos.x;
    y = gSaveBlock1Ptr->pos.y;
    for (i = y; i < y + MAP_OFFSET_H; i++)
    {
        if (i == y && i != 0)
            yMode = 0;
        else if (i == y + MAP_OFFSET_H - 1 && i != gMapHeader.mapLayout->height - 1)
            yMode = 1;
        else
            yMode = 0xFF;

        for (j = x; j < x + MAP_OFFSET_W; j++)
        {
            if (!SkipCopyingMetatileFromSavedMap(&sBackupMapData[(j + MAP_BORDER_EXTRA) + width * (i + MAP_BORDER_EXTRA)], width, yMode))
                sBackupMapData[(j + MAP_BORDER_EXTRA) + width * (i + MAP_BORDER_EXTRA)] = *mapView;
            mapView++;
        }
    }
    for (j = x; j < x + MAP_OFFSET_W; j++)
    {
        if (y != 0)
            FixLongGrassMetatilesWindowTop(j, y - 1);
        if (i < gMapHeader.mapLayout->height - 1)
            FixLongGrassMetatilesWindowBottom(j, y + MAP_OFFSET_H - 1);
    }
    ClearSavedMapView();
}

static void MoveMapViewToBackup(u8 direction)
{
    s32 width;
    s32 x0, y0;
    s32 x2, y2;
    s32 x, y;
    s32 i, j;

    u16 *mapView = gSaveBlock1Ptr->mapView;
    
    width = gBackupMapLayout.width;
    i = 0;
    j = 0;
    x0 = gSaveBlock1Ptr->pos.x;
    y0 = gSaveBlock1Ptr->pos.y;
    x2 = MAP_OFFSET_W;
    y2 = MAP_OFFSET_H;

    switch (direction)
    {
    case CONNECTION_NORTH:
        y0++;
        y2 = MAP_OFFSET_H - 1;
        break;
    case CONNECTION_SOUTH:
        j = 1;
        y2 = MAP_OFFSET_H - 1;
        break;
    case CONNECTION_WEST:
        x0++;
        x2 = MAP_OFFSET_W - 1;
        break;
    case CONNECTION_EAST:
        i = 1;
        x2 = MAP_OFFSET_W - 1;
        break;
    }

    for (y = 0; y < y2; y++)
    {
        for (x = 0; x < x2; x++)
        {
            sBackupMapData[(x + x0 + MAP_BORDER_EXTRA) + width * (y + y0 + MAP_BORDER_EXTRA)] = mapView[i + x + MAP_OFFSET_W * (j + y)];
        }
    }

    ClearSavedMapView();
}

s32 GetMapBorderIdAt(s32 x, s32 y)
{
    if (GetMapGridBlockAt(x, y) == MAPGRID_UNDEFINED)
        return CONNECTION_INVALID;

    if (x >= (MAP_GRID_VANILLA_WIDTH - (MAP_OFFSET + 1)))
    {
        if (!sMapConnectionFlags.east)
            return CONNECTION_INVALID;

        return CONNECTION_EAST;
    }
    else if (x < MAP_OFFSET)
    {
        if (!sMapConnectionFlags.west)
            return CONNECTION_INVALID;

        return CONNECTION_WEST;
    }
    else if (y >= (MAP_GRID_VANILLA_HEIGHT - MAP_OFFSET))
    {
        if (!sMapConnectionFlags.south)
            return CONNECTION_INVALID;

        return CONNECTION_SOUTH;
    }
    else if (y < MAP_OFFSET)
    {
        if (!sMapConnectionFlags.north)
            return CONNECTION_INVALID;

        return CONNECTION_NORTH;
    }
    else
    {
        return CONNECTION_NONE;
    }
}

s32 GetPostCameraMoveMapBorderId(s32 x, s32 y)
{
    return GetMapBorderIdAt(gSaveBlock1Ptr->pos.x + MAP_OFFSET + x, gSaveBlock1Ptr->pos.y + MAP_OFFSET + y);
}

bool32 CanCameraMoveInDirection(s32 direction)
{
    s32 x, y;
    x = gSaveBlock1Ptr->pos.x + MAP_OFFSET + gDirectionToVectors[direction].x;
    y = gSaveBlock1Ptr->pos.y + MAP_OFFSET + gDirectionToVectors[direction].y;

    if (GetMapBorderIdAt(x, y) == CONNECTION_INVALID)
        return FALSE;

    return TRUE;
}

static void SetPositionFromConnection(const struct MapConnection *connection, s32 direction, s32 x, s32 y)
{
    struct MapHeader const *mapHeader;
    mapHeader = GetMapHeaderFromConnection(connection);
    switch (direction)
    {
    case CONNECTION_EAST:
        gSaveBlock1Ptr->pos.x = -x;
        gSaveBlock1Ptr->pos.y -= connection->offset;
        break;
    case CONNECTION_WEST:
        gSaveBlock1Ptr->pos.x = mapHeader->mapLayout->width;
        gSaveBlock1Ptr->pos.y -= connection->offset;
        break;
    case CONNECTION_SOUTH:
        gSaveBlock1Ptr->pos.x -= connection->offset;
        gSaveBlock1Ptr->pos.y = -y;
        break;
    case CONNECTION_NORTH:
        gSaveBlock1Ptr->pos.x -= connection->offset;
        gSaveBlock1Ptr->pos.y = mapHeader->mapLayout->height;
        break;
    }
}

bool8 CameraMove(s32 x, s32 y)
{
    s32 direction;
    const struct MapConnection *connection;
    s32 old_x, old_y;
    gCamera.active = FALSE;
    direction = GetPostCameraMoveMapBorderId(x, y);
    if (direction == CONNECTION_NONE || direction == CONNECTION_INVALID)
    {
        gSaveBlock1Ptr->pos.x += x;
        gSaveBlock1Ptr->pos.y += y;
    }
    else
    {
        SaveMapView();
        ClearMirageTowerPulseBlendEffect();
        old_x = gSaveBlock1Ptr->pos.x;
        old_y = gSaveBlock1Ptr->pos.y;
        connection = GetIncomingConnection(direction, gSaveBlock1Ptr->pos.x, gSaveBlock1Ptr->pos.y);
        SetPositionFromConnection(connection, direction, x, y);
        LoadMapFromCameraTransition(connection->mapGroup, connection->mapNum);
        gCamera.active = TRUE;
        gCamera.x = old_x - gSaveBlock1Ptr->pos.x;
        gCamera.y = old_y - gSaveBlock1Ptr->pos.y;
        gSaveBlock1Ptr->pos.x += x;
        gSaveBlock1Ptr->pos.y += y;
        MoveMapViewToBackup(direction);
    }
    return gCamera.active;
}

static const struct MapConnection *GetIncomingConnection(u8 direction, s32 x, s32 y)
{
    s32 count;
    s32 i;
    const struct MapConnection *connection;
    const struct MapConnections *connections = gMapHeader.connections;

#ifdef UBFIX // UB: Multiple possible null dereferences
    if (connections == NULL || connections->connections == NULL)
        return NULL;
#endif
    count = connections->count;
    connection = connections->connections;
    for (i = 0; i < count; i++, connection++)
    {
        if (connection->direction == direction && IsPosInIncomingConnectingMap(direction, x, y, connection) == TRUE)
            return connection;
    }
    return NULL;
}

static bool8 IsPosInIncomingConnectingMap(u8 direction, s32 x, s32 y, const struct MapConnection *connection)
{
    struct MapHeader const *mapHeader;
    mapHeader = GetMapHeaderFromConnection(connection);
    switch (direction)
    {
    case CONNECTION_SOUTH:
    case CONNECTION_NORTH:
        return IsCoordInIncomingConnectingMap(x, gMapHeader.mapLayout->width, mapHeader->mapLayout->width, connection->offset);
    case CONNECTION_WEST:
    case CONNECTION_EAST:
        return IsCoordInIncomingConnectingMap(y, gMapHeader.mapLayout->height, mapHeader->mapLayout->height, connection->offset);
    }
    return FALSE;
}

static bool8 IsCoordInIncomingConnectingMap(s32 coord, s32 srcMax, s32 destMax, s32 offset)
{
    s32 min, max;

    if (offset < 0)
        min = 0;
    else
        min = offset;

    if (destMax + offset < srcMax)
        max = destMax + offset;
    else
        max = srcMax;

    if (min <= coord && coord <= max)
        return TRUE;

    return FALSE;
}

static s32 IsCoordInConnectingMap(s32 coord, s32 max)
{
    if (coord >= 0 && coord < max)
        return TRUE;

    return FALSE;
}

static s32 IsPosInConnectingMap(const struct MapConnection *connection, s32 x, s32 y)
{
    struct MapHeader const *mapHeader;
    mapHeader = GetMapHeaderFromConnection(connection);
    switch (connection->direction)
    {
    case CONNECTION_SOUTH:
    case CONNECTION_NORTH:
        return IsCoordInConnectingMap(x - connection->offset, mapHeader->mapLayout->width);
    case CONNECTION_WEST:
    case CONNECTION_EAST:
        return IsCoordInConnectingMap(y - connection->offset, mapHeader->mapLayout->height);
    }
    return FALSE;
}

const struct MapConnection *GetMapConnectionAtPos(s16 x, s16 y)
{
    s32 count;
    const struct MapConnection *connection;
    s32 i;
    u8 direction;
    if (!gMapHeader.connections)
    {
        return NULL;
    }

    count = gMapHeader.connections->count;
    connection = gMapHeader.connections->connections;
    for (i = 0; i < count; i++, connection++)
    {
        direction = connection->direction;
        if (direction == CONNECTION_DIVE || direction == CONNECTION_EMERGE)
            continue;
        else if (direction == CONNECTION_NORTH && y > MAP_OFFSET - 1)
            continue;
        else if (direction == CONNECTION_SOUTH && y < gMapHeader.mapLayout->height + MAP_OFFSET)
            continue;
        else if (direction == CONNECTION_WEST && x > MAP_OFFSET - 1)
            continue;
        else if (direction == CONNECTION_EAST && x < gMapHeader.mapLayout->width + MAP_OFFSET)
            continue;

        if (IsPosInConnectingMap(connection, x - MAP_OFFSET, y - MAP_OFFSET) == TRUE)
            return connection;
    }
    return NULL;
}

void SetCameraFocusCoords(u16 x, u16 y)
{
    gSaveBlock1Ptr->pos.x = x - MAP_OFFSET;
    gSaveBlock1Ptr->pos.y = y - MAP_OFFSET;
}

void GetCameraFocusCoords(u16 *x, u16 *y)
{
    *x = gSaveBlock1Ptr->pos.x + MAP_OFFSET;
    *y = gSaveBlock1Ptr->pos.y + MAP_OFFSET;
}

static void UNUSED SetCameraCoords(u16 x, u16 y)
{
    gSaveBlock1Ptr->pos.x = x;
    gSaveBlock1Ptr->pos.y = y;
}

void GetCameraCoords(u16 *x, u16 *y)
{
    *x = gSaveBlock1Ptr->pos.x;
    *y = gSaveBlock1Ptr->pos.y;
}

void MapGridSetMetatileImpassabilityAt(s32 x, s32 y, bool32 impassable)
{
    if (AreCoordsWithinMapGridBounds(x, y))
    {
        if (impassable)
            gBackupMapLayout.map[MapGridIndex(x, y)] |= MAPGRID_COLLISION_MASK;
        else
            gBackupMapLayout.map[MapGridIndex(x, y)] &= ~MAPGRID_COLLISION_MASK;
    }
}

static bool8 SkipCopyingMetatileFromSavedMap(u16 *mapBlock, u16 mapWidth, u8 yMode)
{
    if (yMode == 0xFF)
        return FALSE;

    if (yMode == 0)
        mapBlock -= mapWidth;
    else
        mapBlock += mapWidth;

    if (IsLargeBreakableDecoration(UNPACK_METATILE(*mapBlock), yMode) == TRUE)
        return TRUE;
    return FALSE;
}

static void CopyTilesetToVram(struct Tileset const *tileset, u16 numTiles, u16 offset)
{
    if (tileset)
    {
        if (!tileset->isCompressed)
            LoadBgTiles(2, tileset->tiles, numTiles * 32, offset);
        else
            DecompressAndCopyTileDataToVram(2, tileset->tiles, numTiles * 32, offset, 0);
    }
}

static void CopyTilesetToVramUsingHeap(struct Tileset const *tileset, u16 numTiles, u16 offset)
{
    if (tileset)
    {
        if (!tileset->isCompressed)
            LoadBgTiles(2, tileset->tiles, numTiles * 32, offset);
        else
            DecompressAndLoadBgGfxUsingHeap(2, tileset->tiles, numTiles * 32, offset, 0);
    }
}

// Below two are dummied functions from FRLG, used to tint the overworld palettes for the Quest Log
static void ApplyGlobalTintToPaletteEntries(u16 offset, u16 size)
{

}

static void UNUSED ApplyGlobalTintToPaletteSlot(u8 slot, u8 count)
{

}

static void LoadTilesetPalette(struct Tileset const *tileset, u16 destOffset, u16 size)
{
    u16 black = RGB_BLACK;

    if (tileset)
    {
        if (tileset->isSecondary == FALSE)
        {
            LoadPalette(&black, destOffset, PLTT_SIZEOF(1));
            LoadPalette(tileset->palettes[0] + 1, destOffset + 1, size - PLTT_SIZEOF(1));
            ApplyGlobalTintToPaletteEntries(destOffset + 1, (size - PLTT_SIZEOF(1)) >> 1);
        }
        else if (tileset->isSecondary == TRUE)
        {
            LoadPalette(tileset->palettes[NUM_PALS_IN_PRIMARY], destOffset, size);
            ApplyGlobalTintToPaletteEntries(destOffset, size >> 1);
        }
        else
        {
            LoadCompressedPalette((const u32 *)tileset->palettes, destOffset, size);
            ApplyGlobalTintToPaletteEntries(destOffset, size >> 1);
        }
    }
}

void CopyPrimaryTilesetToVram(struct MapLayout const *mapLayout)
{
    CopyTilesetToVram(mapLayout->primaryTileset, NUM_TILES_IN_PRIMARY, 0);
}

void CopySecondaryTilesetToVram(struct MapLayout const *mapLayout)
{
    CopyTilesetToVram(mapLayout->secondaryTileset, NUM_TILES_TOTAL - NUM_TILES_IN_PRIMARY, NUM_TILES_IN_PRIMARY);
}

void CopySecondaryTilesetToVramUsingHeap(struct MapLayout const *mapLayout)
{
    CopyTilesetToVramUsingHeap(mapLayout->secondaryTileset, NUM_TILES_TOTAL - NUM_TILES_IN_PRIMARY, NUM_TILES_IN_PRIMARY);
}

static void LoadPrimaryTilesetPalette(struct MapLayout const *mapLayout)
{
    LoadTilesetPalette(mapLayout->primaryTileset, BG_PLTT_ID(0), NUM_PALS_IN_PRIMARY * PLTT_SIZE_4BPP);
}

void LoadSecondaryTilesetPalette(struct MapLayout const *mapLayout)
{
    LoadTilesetPalette(mapLayout->secondaryTileset, BG_PLTT_ID(NUM_PALS_IN_PRIMARY), (NUM_PALS_TOTAL - NUM_PALS_IN_PRIMARY) * PLTT_SIZE_4BPP);
}

// Writes tiles straight into VRAM, decompressing on the spot.
//
// An extra bank's tiles land above TILESET_BANK_VRAM_START, and LoadBgTiles
// cannot reach there: it computes its destination as a u16 byte offset, which
// 0x20000 overflows to zero. Nothing about a bank needs the BG plumbing anyway
// -- no tile allocator, no DMA queue -- and being synchronous means the caller
// does not have to wait on a temp buffer the way CopySecondaryTilesetToVram
// does, which is useful below the bank region too.
static void CopyTilesetToVramDirect(struct Tileset const *tileset, u16 numTiles, u32 tileOffset)
{
    u8 *dest = (u8 *)VRAM + tileOffset * TILE_SIZE_4BPP;
    u32 size = numTiles * TILE_SIZE_4BPP;

    if (tileset == NULL || tileset->tiles == NULL)
        return;

    if (!tileset->isCompressed)
    {
        CpuFastCopy(tileset->tiles, dest, size);
    }
    else
    {
        u32 decompressedSize;
        void *buffer = malloc_and_decompress(tileset->tiles, &decompressedSize);

        if (buffer != NULL)
        {
            if (decompressedSize < size)
                size = decompressedSize;
            CpuFastCopy(buffer, dest, size);
            Free(buffer);
        }
    }
}

// Tiles are loaded once at boot and live above VRAM_SIZE, out of reach of the
// three dozen screens that clear VRAM on their way in. Palettes get no such
// protection -- as many screens clear PLTT, and the palette buffers have to
// stay one contiguous range so fades and weather reach a bank at all -- so
// they are simply rewritten on every map load. It is a few hundred CpuCopy16s
// of identical data, and being idempotent it cannot open the kind of window a
// reload of the tiles could.
void LoadTilesetBankPalettes(void)
{
    u8 bank;

    for (bank = 1; bank < sTilesetBankCount; bank++)
    {
        u16 palBase = PLTT_ID(TILESET_BANK_PAL_BASE(bank));

        LoadTilesetPalette(sTilesetBanks[bank].primary, palBase,
                           NUM_PALS_IN_PRIMARY * PLTT_SIZE_4BPP);
        LoadTilesetPalette(sTilesetBanks[bank].secondary, palBase + PLTT_ID(NUM_PALS_IN_PRIMARY),
                           (NUM_PALS_TOTAL - NUM_PALS_IN_PRIMARY) * PLTT_SIZE_4BPP);
    }
}

// Same tiles as CopySecondaryTilesetToVramUsingHeap, but in this frame rather
// than over the next several. A camera transition swaps the map's secondary
// tileset while the screen is live: the palettes land immediately, but the
// queued load's tiles arrive over the following frames, so the map would be
// drawn with the tileset it is replacing under the palettes of the one
// replacing it. Vanilla showed seven tiles past a map edge and never noticed.
void CopySecondaryTilesetToVramNow(struct MapLayout const *mapLayout)
{
    CopyTilesetToVramDirect(mapLayout->secondaryTileset, NUM_TILES_TOTAL - NUM_TILES_IN_PRIMARY, NUM_TILES_IN_PRIMARY);
}

void CopyMapTilesetsToVram(struct MapLayout const *mapLayout)
{
    if (mapLayout)
    {
        CopyTilesetToVramUsingHeap(mapLayout->primaryTileset, NUM_TILES_IN_PRIMARY, 0);
        CopyTilesetToVramUsingHeap(mapLayout->secondaryTileset, NUM_TILES_TOTAL - NUM_TILES_IN_PRIMARY, NUM_TILES_IN_PRIMARY);
    }
}

void LoadMapTilesetPalettes(struct MapLayout const *mapLayout)
{
    if (mapLayout)
    {
        LoadPrimaryTilesetPalette(mapLayout);
        LoadSecondaryTilesetPalette(mapLayout);
    }
}
