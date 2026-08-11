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

# Desktop integration so the icon shows in KDE/GNOME -- and on Wayland in
# particular. Wayland has no protocol to attach a pixel icon to a window; the
# compositor finds the icon only by matching the window's app_id
# ("pokeemerald", set via SDL_SetAppMetadata) to an installed .desktop of the
# same basename. An un-integrated AppImage has none, so we self-install one
# (and the themed icon) into the user's data dir on first run, with Exec
# pointing back at this AppImage so the menu entry launches it too. Idempotent
# and best-effort: never fail the game over desktop bookkeeping.
APPIMAGE_PATH="${APPIMAGE:-$0}"
DATADIR="${XDG_DATA_HOME:-$HOME/.local/share}"
DFILE="$DATADIR/applications/pokeemerald.desktop"
IFILE="$DATADIR/icons/hicolor/256x256/apps/pokeemerald.png"
if [ -w "${DATADIR%/*}" ] 2>/dev/null || mkdir -p "$DATADIR" 2>/dev/null; then
    if [ ! -f "$DFILE" ] || ! grep -qF "Exec=$APPIMAGE_PATH" "$DFILE" 2>/dev/null; then
        mkdir -p "${DFILE%/*}" "${IFILE%/*}" 2>/dev/null || true
        cp -f "$HERE/pokeemerald.png" "$IFILE" 2>/dev/null || true
        sed "s|^Exec=.*|Exec=$APPIMAGE_PATH|" "$HERE/pokeemerald.desktop" \
            > "$DFILE" 2>/dev/null || true
        update-desktop-database "$DATADIR/applications" >/dev/null 2>&1 || true
        gtk-update-icon-cache -f "$DATADIR/icons/hicolor" >/dev/null 2>&1 || true
    fi
fi

exec "$HERE/usr/bin/pokeemerald" "$@"
APPRUN
chmod +x "$APPDIR/AppRun"

# Shared .desktop (Name=Pokémon Emerald, StartupWMClass=pokeemerald matching the
# SDL app_id) drives the window<->icon association on both X11 and Wayland.
cp tools/packaging/pokeemerald.desktop "$APPDIR/pokeemerald.desktop"

# AppImages want the icon both at the AppDir root (for appimagetool) and in the
# hicolor theme (so the self-install and integration daemons resolve Icon=).
cp graphics/app_icon.png "$APPDIR/pokeemerald.png"
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps" \
         "$APPDIR/usr/share/applications"
cp graphics/app_icon.png "$APPDIR/usr/share/icons/hicolor/256x256/apps/pokeemerald.png"
cp tools/packaging/pokeemerald.desktop "$APPDIR/usr/share/applications/pokeemerald.desktop"

mkdir -p dist
# --appimage-extract-and-run: FUSE is usually unavailable in CI containers.
ARCH="$(uname -m)" appimagetool --appimage-extract-and-run "$APPDIR" "$OUT" >/dev/null 2>&1 \
    || ARCH="$(uname -m)" appimagetool "$APPDIR" "$OUT"

echo "built $OUT"
du -h "$OUT" | awk '{print "size: " $1}'
