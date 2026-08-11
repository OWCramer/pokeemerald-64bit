# Wide view: rendering neighbouring maps with their own tilesets

## The bug

Hoenn's outdoor maps share a primary tileset but each has its own secondary, and
the GBA can only address one pair at a time:

| map | primary | secondary |
|---|---|---|
| Route 103 | `gTileset_General` | `gTileset_Petalburg` |
| Route 110 | `gTileset_General` | `gTileset_Mauville` |
| Route 104 | `gTileset_General` | `gTileset_Rustboro` |

Vanilla shows ~7 tiles of a neighbour, authored as plain terrain, so it never
mattered. The expanded viewport shows up to 64, so a neighbour's metatile id
>= `NUM_METATILES_IN_PRIMARY` was decoded against *our* secondary tileset.

Symptoms, all confirmed in play: terrain correct everywhere (shared primary),
buildings garbled, collision and warps correct (the map data is fine, only the
decode was wrong), the map you stand on always right, and walking onto the bad
map fixing it with no reload.

## The fix

A **tileset bank** is a full 1024-tile, 16-palette copy of the tileset space the
GBA can address at once. Bank 0 is the map the player is standing on and keeps
the vanilla tile 0 / palette 0 bases, so nothing but a connected map's cells
pays for any of this. Banks 1+ are stacked above the stock VRAM and palette
layout (`include/gba/defines.h`) rather than carved out of it, so every address
the rest of the game already uses is unchanged -- OBJ palettes in particular
stay exactly where sprite rendering expects them.

A bank is keyed on the whole tileset *pair*, not just the secondary, so a
connection whose primary differs decodes its terrain correctly too, and the
renderer needs no special case for which half a tile came from.

| stage | commit | what |
|---|---|---|
| 1 | `57dd8bd2d` | `sBackupMapBank[]`, a `u8` parallel to `sBackupMapData`, records the owning bank per cell. `FillConnection` is the single point where foreign map data enters the layout, so tagging there covers all four directions. |
| 2 | `da2ed4dfa` | `LoadTilesetBanks()` loads each registered bank's tiles and palettes. |
| 3 | `f2a41a536` | The renderer carries a bank per tilemap entry and adds that bank's tile and palette bases when decoding. |
| 4 | `9256abc92` | `DrawMetatileAt` takes the metatile out of the cell's own bank and tags the tilemap; the layer type follows the cell's tileset too. |
| 5 | `bfe0d0a93` | Bank palettes fade, blend and weather with everything else. |
| 6 | `385e8387b` | Tileset animations reach every bank that shares the animated tileset. |

### Why a separate bank plane rather than a wider tilemap entry

The obvious design is to widen `gOverworldTilemapBuffer_Bg1/2/3` to `u32` and
give the entry more tile and palette bits. The field tilemaps are handed to
`bg.c` through `SetBgTilemapBuffer`, though, and anything there that wrote a
plain 16-bit GBA entry into a `u32` buffer would corrupt it silently. A separate
`u8` plane cannot be mistaken for a tilemap by code that does not know about it,
and it costs one byte load per tile fetch in the renderer.

### Things that had to follow the bank

Loading tiles and palettes is the easy half. Everything that processes a
palette or a tile *after* it is loaded had to learn about banks as well, and
missing any one of them is individually visible:

* **Fades and blends** are driven by a 32-bit palette selection mask that cannot
  reach a bank. Left alone, a connected map kept full daylight colours while the
  screen faded to black on every warp and battle.
* **Weather** works in contiguous palette ranges, so it only needed the ranges
  widened -- except its colour-map table, which is indexed by palette number and
  only describes the real 32. A bank palette takes the entry of the BG palette
  it mirrors.
* **Tileset animations** write frames into the current map's tiles. Each bank
  holds its own copy, so without mirroring, the same stretch of water animates on
  one side of a map seam and stands still on the other.
* **Metatile layer type** decides which background layer each half of a metatile
  is drawn to, so leaving it on the current map put a connected town's rooftops
  behind the layer that covers sprites.

The metatile **behaviour** lookup is deliberately *not* bank-aware. Behaviours
drive movement, and the camera transition makes a connected map current before
the player can stand on any of its cells, so every cell consulted for movement
is bank 0 -- which also means none of this can change what the player can walk
on.

## Known limits

* `MAX_TILESET_BANKS` distinct tileset pairs on screen at once (8). A pair that
  will not fit falls back to bank 0, i.e. the old wrong-but-harmless behaviour
  rather than an out-of-range bank.
* A connected map whose *own secondary* animates -- a town fountain, a flag --
  shows its first frame. Running those needs a second set of animation callbacks
  and counters per bank. All of the outdoor animation is unaffected, because
  water, waterfalls, shorelines and flowers live in `gTileset_General`, the
  primary every Hoenn overworld map shares.
* Both halves of a bank's pair are decompressed on every map load even when the
  primary matches the current map's. Copying the already-decompressed tiles out
  of VRAM would be cheaper but would depend on the primary having finished its
  asynchronous load, which is not true at every call site.

## Dead ends (do not retry)

* **Oldale, Route 101, 102, 103 and Littleroot all share `gTileset_Petalburg`**,
  so a test between those shows nothing either way. Reproduce across
  Route 103 <-> Route 110.
* **The border margin is not stale.** `InitMapLayoutData` already clears the
  whole buffer to `MAPGRID_UNDEFINED` on every map load; adding a fill in
  `InitBackupMapLayoutData` is dead code.
* **Connections are filled to full `MAP_BORDER_TOTAL` depth** already; the fill
  offsets are correct.
* **There are no spare bits in a map cell.** 10 metatile id + 2 collision + 4
  elevation = 16/16 (`include/global.fieldmap.h`), which is why the bank lives
  in a parallel array rather than in the cell.
* **`LoadBgTiles` cannot reach a bank.** It computes its destination as a `u16`
  byte offset, which `TILESET_BANK_VRAM_START` (0x20000) overflows to zero.
  `CopyTilesetToVramBank` writes VRAM directly instead.
