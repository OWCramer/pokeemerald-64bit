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

Two things, kept apart:

* A **tileset slot** holds one tileset's 512 tiles. There are 74 tilesets in the
  game, and **every one is loaded at boot** -- 1.2 MB, decompressed once. No map
  load decompresses anything, and no slot is ever written again.
* A **bank** is a tileset *pair*: the middle man. A map cell names its bank, and
  the bank resolves to the two slots the cell's ids and palettes are read
  against. Keying on the pair rather than the secondary means a connection whose
  primary differs decodes its terrain correctly too.

Storing tiles per tileset rather than per bank matters because almost every map
shares `gTileset_General`: per bank it would be held seventy-odd times over.

Banks are permanent -- a pair keeps its bank for the session. **Nothing about a
bank changes while the game runs**, which is the property the whole design rests
on: a bank id under a tilemap can never come to mean a different tileset than it
did when it was written.

Bank 0 is not a bank. It means "no bank", and decodes against the stock VRAM and
palette layout, which is what every menu and text box does, and the fallback for
a pair that could not be assigned one.

**The map the player is standing on also draws from the stock layout**, even
though it has a bank: its bank is published with a zero tile delta and zero
palette base. Only the *other* maps on screen resolve through a slot. This is
load-bearing -- see below.

A metatile id keeps its vanilla meaning throughout: below
`NUM_METATILES_IN_PRIMARY` it names the pair's primary, at or above it the
secondary. The renderer picks the half with the same split, through a per-bank
delta indexed by the top bit of the 10-bit tile id, so its inner loop gains a
table lookup rather than a branch.

| stage | commit | what |
|---|---|---|
| 1 | `57dd8bd2d` | `sBackupMapBank[]`, a `u8` parallel to `sBackupMapData`, records the owning bank per cell. `FillConnection` is the single point where foreign map data enters the layout, so tagging there covers all four directions. |
| 2 | `da2ed4dfa` | `LoadTilesetBanks()` loads each registered bank's tiles and palettes. |
| 3 | `f2a41a536` | The renderer carries a bank per tilemap entry and adds that bank's tile and palette bases when decoding. |
| 4 | `9256abc92` | `DrawMetatileAt` takes the metatile out of the cell's own bank and tags the tilemap; the layer type follows the cell's tileset too. |
| 5 | `bfe0d0a93` | Bank palettes fade, blend and weather with everything else. |
| 6 | `385e8387b` | Tileset animations reach every bank that shares the animated tileset. |
| 7 | `836408d2c` | Translated tags across a seam, back when banks were renumbered per map. Superseded. |
| 8 | `2c9e8ceef` | Banks made permanent, removing the renumbering and the reload -- and with them stage 7. |
| 9 | `33e1dc374` | Tiles split out into a slot per tileset, all loaded at boot. |
| 10 | `086b60fb2` | Current map pointed back at the stock layout, so runtime effects keep working. |

### Why a separate bank plane rather than a wider tilemap entry

The obvious design is to widen `gOverworldTilemapBuffer_Bg1/2/3` to `u32` and
give the entry more tile and palette bits. The field tilemaps are handed to
`bg.c` through `SetBgTilemapBuffer`, though, and anything there that wrote a
plain 16-bit GBA entry into a `u32` buffer would corrupt it silently. A separate
`u8` plane cannot be mistaken for a tilemap by code that does not know about it,
and it costs one byte load per tile fetch in the renderer.

### Why permanent, and what it replaced

Banks were originally per-map: the map being entered took bank 0, the one being
left became a connection, every bank was reloaded, and every tag already in a
tilemap was translated in step (stage 7). That is three pieces of choreography
that all have to land inside one frame, and a single frame of a neighbouring
house drawn in the wrong tileset survived all of it -- caught on video, one
frame in sixty, self-correcting.

Making banks permanent deletes all three. Nothing renumbers, so no translation
is needed; nothing reloads, so no bank's contents change under a tilemap that
refers to it. The stock VRAM region is then unused by the field, and stays only
as the fallback for a bank that could not be assigned.

Two things had to be true for permanence to hold:

* **`VRAM_SIZE` means the stock region**, with `VRAM_TOTAL_SIZE` covering the
  slots above it. Three dozen screens clear VRAM with `VRAM_SIZE` on their way
  in, and would otherwise wipe tiles nothing ever reloads.
* **Palettes are rewritten on every map load**, because they get no such
  protection -- as many screens clear PLTT, and the palette buffers have to stay
  one contiguous range for fades and weather to reach a bank at all. Rewriting
  identical data is idempotent, so unlike a reload of the tiles it cannot open a
  window.

### Why the current map stays on the stock layout

Briefly it did not, and two bugs came straight out of that:

* Doors animated into a black hole. `field_door.c` copies its frames into the
  stock layout, so the field was reading tiles nothing had written.
* Outdoor water and flowers turned up baked into the floor of every building.
  A tileset animation callback outlives the map that installed it, so for one
  frame `gTileset_General`'s animation was redirected to whatever the new map's
  primary was -- `gTileset_Building`, shared by all 179 interiors. Slots are
  permanent, so that one frame poisoned every interior for the rest of the
  session.

Everything that changes the field at runtime writes to the stock layout: door
animations, tileset animations, the cave-entry flash recolouring BG palette 0,
Mirage Tower crumbling, field move streaks. Redirecting each one means finding
all of them, and a miss is either invisible or permanent. Pointing the current
map back at the stock layout makes all of it work unchanged, and leaves banks
doing only the job they exist for.

The animation redirect is still needed -- a neighbour sharing the animated
tileset reads its slot -- so `tileset_anims.c` records which tileset each
callback belongs to when it is installed, rather than inferring it from
`gMapHeader`, which is what went wrong.

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

The metatile **behaviour** lookup is deliberately *not* bank-aware: it reads the
current map's tilesets, the way it always did. Behaviours drive movement, and the
camera transition makes a connected map current before the player can stand on
any of its cells, so every cell consulted for movement belongs to the current map
and already resolves to the same tileset its bank holds. Leaving it alone also
means none of this can change what the player can walk on.

## Known limits

* `MAX_TILESET_BANKS` distinct tileset pairs per session (80, against 76 in the
  game). A pair that will not fit falls back to bank 0 -- the stock layout, i.e.
  the old wrong-but-harmless behaviour rather than an out-of-range bank.
* A connected map whose *own secondary* animates -- a town fountain, a flag --
  shows its first frame. Only the current map's animation callbacks run, so this
  needs a set of callbacks and counters per tileset, not just somewhere to put
  the result. All of the outdoor animation is unaffected, because water,
  waterfalls, shorelines and flowers live in `gTileset_General`, the primary
  every Hoenn overworld map shares -- and one tileset is one slot, so every map
  using it animates in step for free.
* `MAX_TILESET_SLOTS` distinct tilesets (80, against 74 in the game).

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
* **`LoadBgTiles` cannot reach a slot.** It computes its destination as a `u16`
  byte offset, which 0x20000 overflows to zero. `CopyTilesetToVramDirect` writes
  VRAM directly instead.
* **`LAYOUT_UNUSED_OUTDOOR_AREA` has a literal `0` for its secondary tileset.**
  The 64-bit builds widen `.4byte` *symbols* to `.quad`; a bare `0` is
  indistinguishable from an integer field, so it stayed four bytes and left that
  layout short, its last field reading into whatever followed. Walking all 441
  layouts at boot is the first thing that ever read it. `mapjson` emits `NULL`
  there now -- the symbol it already used for a map with no connections, and the
  same four zero bytes on the GBA. Any new pointer field that can be null needs
  the same treatment.
