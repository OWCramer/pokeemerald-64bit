#!/bin/bash
# Package the Linux native build as an AppImage.
#
# Bundles libSDL3 and its non-base dependencies. Bundling only libSDL3 is not
# enough: distro SDL builds link optional backends the target may not have --
# Ubuntu's pulls in libsndio, which most systems do not ship, and the AppImage
# then dies with 'libsndio.so.7: cannot open shared object file'.
#
# The excluded set is the usual AppImage one: the C/C++ runtime, the graphics
# stack, and the display-server client libraries. Those must come from the host
# because they are tied to its kernel, drivers and display server -- bundling
# them causes worse breakage than it prevents. ALSA is excluded on the same
# grounds; it is effectively always present.
set -euo pipefail
cd "$(dirname "$0")/.."

BIN="${1:-pokeemerald-sdl3}"
APPDIR="dist/AppDir"
OUT="${2:-dist/pokeemerald-$(uname -m).AppImage}"

[ -f "$BIN" ] || { echo "error: $BIN not built -- run 'make native' first" >&2; exit 1; }

rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib"
cp "$BIN" "$APPDIR/usr/bin/pokeemerald"

# ldd is transitive, so this reaches SDL's own dependencies too. -L copies the
# real file rather than the version symlink.
ldd "$BIN" | awk '/=>/ {print $3}' | grep -v '^$' | sort -u | while read -r lib; do
    [ -f "$lib" ] || continue
    case "$(basename "$lib")" in
        ld-linux*|libc.so*|libm.so*|libdl.so*|libpthread.so*|librt.so*) continue ;;
        libstdc++.so*|libgcc_s.so*) continue ;;
        libGL*|libEGL*|libGLX*|libGLdispatch*|libdrm*|libgbm*|libglapi*) continue ;;
        libX11*|libxcb*|libXext*|libXrandr*|libXi*|libXcursor*|libXfixes*) continue ;;
        libXrender*|libXss*|libXxf86vm*|libXau*|libXdmcp*) continue ;;
        libwayland*|libasound.so*) continue ;;
    esac
    cp -Ln "$lib" "$APPDIR/usr/lib/" 2>/dev/null || true
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
