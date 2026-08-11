# Wide view: rendering neighbouring maps with their own tilesets

**Branch:** `bugfixes` · **Stage 1 landed:** `57dd8bd2d`

## The bug

Hoenn's outdoor maps share a primary tileset but each has its own secondary, and
only one pair is addressable at a time:

| map | primary | secondary |
|---|---|---|
| Route 103 | `gTileset_General` | `gTileset_Petalburg` |
| Route 110 | `gTileset_General` | `gTileset_Mauville` |
| Route 104 | `gTileset_General` | `gTileset_Rustboro` |

Vanilla shows ~7 tiles of a neighbour, authored as plain terrain, so it never
mattered. The expanded viewport shows up to 64, so a neighbour's metatile id
>= `NUM_METATILES_IN_PRIMARY` is decoded against *our* secondary tileset.

Symptoms, all confirmed in play: terrain correct everywhere (shared primary),
buildings garbled, **collision and warps correct** (map data is fine, only the
decode is wrong), the map you stand on always right, walking onto the bad map
fixes it with no reload.

## Verified constraints

1. **No spare bits in a map cell.** 10 metatile id + 2 collision + 4 elevation
   = 16/16 (`include/global.fieldmap.h`). The bank cannot live in the cell.
2. **`DrawMetatileAt` decodes against the current map only** — it picks
   `mapLayout->secondaryTileset` unconditionally (`src/field_camera.c`).
3. **The tilemap entry is the ceiling.** `DrawMetatile` writes raw GBA BG
   entries and `gba_fast_draw.c` decodes `entry & 0x3FF` (1024 tiles) and
   `(entry >> 12) & 0xF` (16 palettes). Primary+secondary already consume both
   ranges exactly, so a second secondary is unaddressable without widening.
4. Tiles load via `CopyTilesetToVramUsingHeap(tileset, numTiles, tileOffset)`;
   palettes via `LoadTilesetPalette(tileset, BG_PLTT_ID(n), size)`. Primary
   occupies tiles 0-511 / pals 0-5, secondary 512-1023 / pals 6-12.
5. `VRAM_SIZE` is `0x20000` and `PLTT_SIZE` is `BG_PLTT_SIZE + OBJ_PLTT_SIZE`
   (`include/gba/defines.h`) -- both plain host arrays in `src/platform/bios.c`,
   so both can grow.

## Stage 1 (done)

`sBackupMapBank[]`, a `u8` parallel to `sBackupMapData`, records the owning
tileset bank per cell. Bank 0 is the current map. `FillConnection` is the single
point where foreign map data enters the layout, so registering the connected
map's secondary tileset and tagging there covers all four directions.

Accessors: `MapGridGetTilesetBankAt(x, y)`, `GetTilesetBank(bank)`,
`GetTilesetBankCount()`. Inert -- nothing reads the bank yet.

## Stages 2-4 (remaining)

**2. Load every bank's tileset.** After connections are filled, walk banks
1..`GetTilesetBankCount()-1` and load each secondary's tiles and palettes into
its own region. Suggested layout, extending rather than reusing:

    tiles bank N   = NUM_TILES_TOTAL + (N-1) * (NUM_TILES_TOTAL - NUM_TILES_IN_PRIMARY)
    pals  bank N   = NUM_PALS_TOTAL  + (N-1) * (NUM_PALS_TOTAL  - NUM_PALS_IN_PRIMARY)

Requires growing `VRAM_SIZE` (16 KB per extra bank) and BG palette space
(~224 B per extra bank). `LoadBgTiles` may bound-check against the BG char
base; writing into the extended region may need a direct VRAM write instead.

**3. Widen the tilemap entry.** `gOverworldTilemapBuffer_Bg1/2/3` become `u32`,
`struct BgExtMap` gains a wide flag, and `FetchBgEntry` reads `u32` for wide
flat maps. Decode becomes a wider tile index and palette field. This is the
renderer hot loop -- the one piece worth benchmarking after.

**4. Decode per bank.** `DrawMetatileAt` uses `GetTilesetBank(MapGridGetTilesetBankAt(x, y))`
for the metatile table, and adds that bank's tile and palette bases when
stamping the entry.

## Dead ends (do not retry)

* **Tileset mismatch is not the whole story for every pair** -- Oldale, Route
  101, 102, 103 and Littleroot all share `gTileset_Petalburg`, so a test between
  those will show nothing. Reproduce across Route 103 <-> Route 110.
* **The border margin is not stale.** `InitMapLayoutData` already clears the
  whole buffer to `MAPGRID_UNDEFINED` every map load; adding a fill in
  `InitBackupMapLayoutData` is dead code.
* **Connections are filled to full `MAP_BORDER_TOTAL` depth** already; the fill
  offsets are correct.
