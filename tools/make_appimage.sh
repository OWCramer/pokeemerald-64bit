#!/bin/bash
# Package the Linux native build as an AppImage.
#
# Only libSDL3 is bundled: everything else the binary needs is base-system
# (glibc, X11/Wayland client libs) and bundling those causes more portability
# problems than it solves. AppRun points the loader at the bundled copy.
set -euo pipefail
cd "$(dirname "$0")/.."

BIN="${1:-pokeemerald-sdl3}"
APPDIR="dist/AppDir"
OUT="${2:-dist/pokeemerald-$(uname -m).AppImage}"

[ -f "$BIN" ] || { echo "error: $BIN not built -- run 'make native' first" >&2; exit 1; }

rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib"
cp "$BIN" "$APPDIR/usr/bin/pokeemerald"

# -L to copy the real file rather than the version symlink.
ldd "$BIN" | awk '/=>/ {print $3}' | grep -E 'libSDL3' | while read -r lib; do
    [ -f "$lib" ] && cp -L "$lib" "$APPDIR/usr/lib/"
done

cat > "$APPDIR/AppRun" <<'APPRUN'
#!/bin/bash
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$HERE/usr/lib:${LD_LIBRARY_PATH:-}"
exec "$HERE/usr/bin/pokeemerald" "$@"
APPRUN
chmod +x "$APPDIR/AppRun"

cat > "$APPDIR/pokeemerald.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=pokeemerald
Exec=pokeemerald
Icon=pokeemerald
Categories=Game;
Terminal=false
DESKTOP

cp graphics/title_screen/pokemon_logo.png "$APPDIR/pokeemerald.png" 2>/dev/null \
    || printf '' > "$APPDIR/pokeemerald.png"

mkdir -p dist
# --appimage-extract-and-run: FUSE is usually unavailable in CI containers.
ARCH="$(uname -m)" appimagetool --appimage-extract-and-run "$APPDIR" "$OUT" >/dev/null 2>&1 \
    || ARCH="$(uname -m)" appimagetool "$APPDIR" "$OUT"

echo "built $OUT"
du -h "$OUT" | awk '{print "size: " $1}'
