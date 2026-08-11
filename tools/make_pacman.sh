#!/bin/bash
# Package the Linux native build as an Arch package (.pkg.tar.zst) via makepkg.
#
# Depends on the system `sdl3` rather than bundling it (see tools/packaging/
# PKGBUILD). makepkg refuses to run as root, so in CI run this as a normal user
# with passwordless sudo for its dep checks (or pass --nodeps below).
set -euo pipefail
cd "$(dirname "$0")/.."

BIN="${1:-pokeemerald64}"
OUTDIR="${2:-dist}"
PKGVER="${PKGVER:-1.0.0}"

[ -f "$BIN" ] || { echo "error: $BIN not built -- run 'make native' first" >&2; exit 1; }
command -v makepkg >/dev/null || { echo "error: makepkg not found (Arch/pacman only)" >&2; exit 1; }

STAGE="dist/pacman"
rm -rf "$STAGE"
mkdir -p "$STAGE" "$OUTDIR"
DEST="$(cd "$OUTDIR" && pwd)"   # absolute, so makepkg drops the pkg here

# makepkg's package() installs these from $startdir (the staging dir).
cp "$BIN" "$STAGE/pokeemerald"
cp tools/packaging/pokeemerald.desktop "$STAGE/pokeemerald.desktop"
cp graphics/app_icon.png "$STAGE/pokeemerald.png"
sed "s/^pkgver=.*/pkgver=$PKGVER/" tools/packaging/PKGBUILD > "$STAGE/PKGBUILD"

# --nodeps: we are packaging a pre-built binary; sdl3 need not be installed in
# the build environment, only declared as a runtime dependency. -f overwrites.
( cd "$STAGE" && PKGDEST="$DEST" PKGEXT='.pkg.tar.zst' makepkg -f --nodeps )

PKG=$(ls -t "$DEST"/pokeemerald-*.pkg.tar.zst 2>/dev/null | head -1)
rm -rf "$STAGE"

echo "built ${PKG:-<pkg>}"
[ -n "${PKG:-}" ] && du -h "$PKG" | awk '{print "size: " $1}'
