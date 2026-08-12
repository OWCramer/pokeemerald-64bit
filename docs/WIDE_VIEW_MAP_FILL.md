# Wide view: what fills the space beyond the map

**Status: partially solved, parked.** What is in the tree now is a large
improvement and worth keeping, but the last piece — what to draw where the game
has no data at all — is unresolved. This file is the handover.

Companion to [WIDE_VIEW_TILESET_BANKS.md](WIDE_VIEW_TILESET_BANKS.md), which
covers *how* a neighbouring map's tiles get drawn. This one covers *what* is
there to draw in the first place.

## The problem

Vanilla shows about seven metatiles past the edge of the map you are standing
on. Two things follow from that, and the whole vanilla design leans on both:

1. Everything you can see is either your map or one of its direct connections.
2. The scrap past the edge is filled with **your** map's border metatiles, and
   since you are never far from your own map, that is always locally right.

The expanded viewport carries `MAP_BORDER_EXTRA` = 64 metatiles of margin on
every side. Both assumptions break, and they break visibly.

### Measured

| quantity | value |
|---|---|
| margin each side | 64 metatiles |
| route width | median 40, min 1, max 140 |
| route height | median 22, min 1, max 140 |

So the viewport spans roughly **1.6 maps horizontally and 3 maps vertically**.
Anything that assumes "one map away" is wrong by construction.

Border metatiles, for reference — these are the values that turn up in the
symptoms below:

| map | border | looks like |
|---|---|---|
| Route 110, Mauville, Slateport, Route 109, Route 134 | 368 | water |
| Route 117 | 198 | trees |
| Route 111 | 113 | dirt / rock |
| Route 103, Oldale, Route 101, Littleroot | 468–477 (2x2) | trees |

## Symptoms this produced, in order

Each was a separate bug with a separate cause. Listing them because the *shape*
of the reasoning matters more than the individual fixes.

1. **Ocean through the middle of Mauville.** Standing on Route 110, Route 111 is
   not a connection *of Route 110*, so nothing filled it and the region past
   Mauville fell back to Route 110's border — 368, water. Fixed by filling
   further than direct connections.
2. **Dirt through Route 110.** The mirror image from Route 111, whose border is
   113. Same fix.
3. **Water turning to trees when entering a house.** Border came from the map
   the player was on. Stand in Mauville, the region past Route 117 is Mauville's
   ocean; walk through a door in Route 117 and it is Route 117's trees. The same
   piece of world changing as you walk is the tell that you are looking at
   filler rather than terrain. Fixed by taking the border from the map the cell
   sits next to, which does not depend on where the player is.
4. **A diagonal staircase of trees cutting into rock.** Self-inflicted: see the
   rule history below.
5. **Littleroot's trees in the ocean west of Slateport.** Also self-inflicted,
   opposite cause. Also below.

## What is implemented now

* **`FillReachableMaps`** walks the connection graph outward from the current
  map and fills every map whose rectangle intersects the layout, at any depth.
  Geometry is the bound, not a hop count — that is also what makes it terminate.
  Maps reached twice are filled once; the graph has cycles (A joins B joins A)
  and a second fill would land on data the player can walk on.
* **`FindBorderOwner`** gives a cell with no map data the border of the nearest
  filled map, measured to its rectangle as `dx + dy`.
* **`sFilledMapRects`** records where every filled map landed. The tileset bank
  follows the border, so a border metatile belonging to another map's tileset
  decodes against that tileset.
* Border **parity stays global** (`(x + 1) & 1`), which is what vanilla indexes
  a 2x2 border pattern by. Making it map-relative would shift the current map's
  own border by one.

## Border-selection rules tried, and why each failed

This is the part worth reading before trying again. Three rules, each of which
looked right and broke differently.

**1. The current map's border everywhere** (vanilla). Position-dependent: the
same world region changes terrain when the player crosses a seam or walks
through a door. Symptom 3.

**2. Nearest map along whichever single axis matches.** For each candidate,
distance was measured vertically if the cell shared its column range,
horizontally if it shared its row range, and the map was skipped if neither.
Two candidates then compete on *different axes*, and the winner flips along the
line where those distances trade off — a 45° boundary. Symptom 4, the staircase.

**3. Axis priority: directly above or below wins, then beside.** Fixes the
staircase, since every seam becomes straight. But it lets a far map on the
"right" axis beat a near one on the "wrong" axis. West of Slateport:

| candidate | why it matched | distance |
|---|---|---|
| Route 103 (border 468, trees) | shares Slateport's column range | 42 |
| Slateport (border 368, water) | shares the cell's row range | 27 |

Vertical-wins picked Route 103 and drew trees in the ocean. Symptom 5.

**4. Current: `dx + dy` to the rectangle.** A cell directly off a map's edge has
zero distance on the other axis, so that map wins outright; only a genuine
corner is settled by the sum. Verified on the real Slateport coordinates:
(-20, 30) and (-5, 50) both resolve to Slateport → water.

## What is still wrong

* **Border projects without limit.** Go far enough west of Slateport (~40+
  metatiles, near the edge of the margin) and Route 101/Littleroot become the
  nearest map, so you get a treeline where open ocean belongs. The connection
  graph genuinely places them there — it is the game's own geometry — but nobody
  ever checked that geometry for plausibility because nobody could see it.
* **Diagonal corners.** A cell diagonally off every map is settled by `dx + dy`,
  which can still put a seam on a diagonal. Less of it than rule 2 produced, but
  it has not gone away.
* **Border is not terrain.** Even when the right map wins, a border metatile is
  a repeating 1x1 or 2x2 pattern. It reads as filler at this scale no matter
  which map it came from.

## Ideas not yet tried

Roughly in order of how much they promise per unit of work.

1. **Cap the projection distance.** Let a map's border reach ~16 metatiles past
   its edge, and beyond that fall back to a single fixed choice (ocean).
   Directly targets the Slateport treeline, small change, no new data.
2. **A world-level default.** Hoenn is an island: almost everything genuinely
   unreachable is sea. A constant "outside the world" metatile beyond the capped
   projection would be right nearly everywhere, and wrong in a bounded and
   predictable way inland.
3. **Vignette or fade past the filled maps.** Do not pretend there is terrain —
   darken or desaturate beyond real data so the eye reads it as out of bounds.
   This is what several wide-view mods do. A stylistic call, so it needs the
   user's say-so.
4. **Hand-authored outer border per region.** Most faithful, most work, and it
   is new content rather than a port.

Rejected: **blending or dithering between two borders.** Tile graphics do not
blend; the result is dithered noise, which looks worse than a straight seam.

## Investigating this offline

The fill can be simulated from the JSON without running the game, which is how
the Slateport table above was produced. Do this before theorising — every wrong
diagnosis in this area came from reasoning about geometry instead of computing
it.

```python
import json, os, struct

layouts = {l['id']: l for l in json.load(open('data/layouts/layouts.json'))['layouts'] if l}
maps = {}
for d in os.listdir('data/maps'):
    p = 'data/maps/%s/map.json' % d
    if os.path.isfile(p):
        m = json.load(open(p)); maps[m['name']] = m
byconst = {'MAP_' + ''.join('_' + c if c.isupper() else c.upper() for c in n).strip('_'): n
           for n in maps}

def lay(m):    return layouts[maps[m]['layout']]
def border(m): return struct.unpack('<4H', open('data/layouts/%s/border.bin'
                                    % lay(m)['name'].replace('_Layout', ''), 'rb').read()[:8])

MAP_OFFSET, EXTRA, TOTAL = 7, 64, 71
cur = 'SlateportCity'                      # <-- the map to inspect
L = lay(cur)
bw = L['width']  + MAP_OFFSET * 2 + 1 + EXTRA * 2
bh = L['height'] + MAP_OFFSET * 2     + EXTRA * 2

def origin(parent, conn, child, ox, oy):
    pl, cl, d = lay(parent), lay(child), conn['direction']
    if d == 'up':    return ox + conn['offset'], oy - cl['height']
    if d == 'down':  return ox + conn['offset'], oy + pl['height']
    if d == 'left':  return ox - cl['width'],    oy + conn['offset']
    if d == 'right': return ox + pl['width'],    oy + conn['offset']

visited, queue, rects, head = {cur}, [(cur, TOTAL, TOTAL)], \
                              [(cur, TOTAL, TOTAL, L['width'], L['height'])], 0
while head < len(queue):
    name, ox, oy = queue[head]; head += 1
    for c in maps[name].get('connections') or []:
        ch = byconst.get(c['map'])
        if not ch or ch in visited: continue
        o = origin(name, c, ch, ox, oy)
        if not o: continue
        x, y = o; cl = lay(ch)
        if x >= bw or y >= bh or x + cl['width'] <= 0 or y + cl['height'] <= 0: continue
        visited.add(ch); queue.append((ch, x, y))
        rects.append((ch, x, y, cl['width'], cl['height']))

for n, x, y, w, h in rects:
    print("%-22s mapgrid x[%4d,%4d) y[%4d,%4d)  border=%s"
          % (n, x - EXTRA, x - EXTRA + w, y - EXTRA, y - EXTRA + h, border(n)[0]))
```

## Reproduction cases

* **Slateport**, looking west — should be open ocean.
* **Mauville**, looking west (Route 117) and east (Route 118); walk through a
  door and back to check the filler does not change.
* **Route 110 → Mauville → Route 111 → Mauville**, which is where symptoms 1
  and 2 were found.
* Note that **Oldale, Routes 101/102/103 and Littleroot all share
  `gTileset_Petalburg`**, so a test among those shows nothing about tilesets
  either way.

## Dead ends

* **Filling the border into the layout buffer** instead of resolving it at draw
  time. `GetMapBorderIdAt` returns `CONNECTION_INVALID` for `MAPGRID_UNDEFINED`,
  and that is what stops the camera walking off the edge of the world. Writing
  real blocks there is a movement bug, not a rendering change.
* **Map-relative border parity.** Shifts the current map's own border by one
  versus vanilla.
* **Reasoning about where maps are.** Route 103 being west of Route 110, and
  therefore Littleroot being west of Slateport, is not something to work out
  from the overworld map in your head. Run the simulation.
