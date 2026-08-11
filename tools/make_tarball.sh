#!/bin/bash
# Package the Linux native build as a portable .tar.gz for any distro that is
# not served by the AppImage or the Arch package.
#
# Self-contained like the AppImage: it bundles libSDL3 and SDL's own non-base
# dependencies (see make_appimage.sh for why that set and not more), so it runs
# on a machine with no SDL3 installed. Extract it anywhere and run
# ./pokeemerald.sh, or run ./install.sh for a menu entry and icon.
set -euo pipefail
cd "$(dirname "$0")/.."

BIN="${1:-pokeemerald-sdl3}"
ARCH="${3:-$(uname -m)}"
OUT="${2:-dist/pokeemerald-linux-$ARCH.tar.gz}"
NAME="pokeemerald-linux-$ARCH"
STAGE="dist/$NAME"

[ -f "$BIN" ] || { echo "error: $BIN not built -- run 'make native' first" >&2; exit 1; }

rm -rf "$STAGE"
mkdir -p "$STAGE/lib" \
         "$STAGE/share/applications" \
         "$STAGE/share/icons/hicolor/256x256/apps"

cp "$BIN" "$STAGE/pokeemerald"
cp tools/packaging/pokeemerald.desktop "$STAGE/share/applications/pokeemerald.desktop"
cp graphics/app_icon.png "$STAGE/share/icons/hicolor/256x256/apps/pokeemerald.png"

# Same bundling policy as the AppImage: transitive libs minus the runtime,
# graphics stack and display-server client libraries, which must come from host.
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
    cp -Ln "$lib" "$STAGE/lib/" 2>/dev/null || true
done

# Launcher: bundled libs first, then exec the game. readlink -f so it works via
# a symlink from ~/.local/bin.
cat > "$STAGE/pokeemerald.sh" <<'RUN'
#!/bin/bash
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$HERE/lib:${LD_LIBRARY_PATH:-}"
exec "$HERE/pokeemerald" "$@"
RUN
chmod +x "$STAGE/pokeemerald.sh"

# Optional integration into the user's session (no root): the launcher goes on
# PATH and the .desktop/icon into XDG dirs so KDE/GNOME show "Pokémon Emerald"
# with its icon -- on Wayland this is the only way the icon appears, since the
# compositor matches the window app_id to this installed .desktop.
cat > "$STAGE/install.sh" <<'INSTALL'
#!/bin/bash
set -euo pipefail
HERE="$(dirname "$(readlink -f "$0")")"
DATADIR="${XDG_DATA_HOME:-$HOME/.local/share}"
BINDIR="$HOME/.local/bin"
mkdir -p "$BINDIR" "$DATADIR/applications" "$DATADIR/icons/hicolor/256x256/apps"
ln -sf "$HERE/pokeemerald.sh" "$BINDIR/pokeemerald"
cp -f "$HERE/share/icons/hicolor/256x256/apps/pokeemerald.png" \
      "$DATADIR/icons/hicolor/256x256/apps/pokeemerald.png"
# Exec by absolute path to the launcher, so a menu launch finds the bundle even
# if ~/.local/bin is not on the session PATH.
sed "s|^Exec=.*|Exec=$HERE/pokeemerald.sh|" \
    "$HERE/share/applications/pokeemerald.desktop" \
    > "$DATADIR/applications/pokeemerald.desktop"
update-desktop-database "$DATADIR/applications" >/dev/null 2>&1 || true
gtk-update-icon-cache -f "$DATADIR/icons/hicolor" >/dev/null 2>&1 || true
echo "Installed. Launch 'Pokémon Emerald' from your menu, or run: pokeemerald"
echo "(ensure $BINDIR is on your PATH for the command-line launcher)"
INSTALL
chmod +x "$STAGE/install.sh"

cat > "$STAGE/uninstall.sh" <<'UNINSTALL'
#!/bin/bash
DATADIR="${XDG_DATA_HOME:-$HOME/.local/share}"
rm -f "$HOME/.local/bin/pokeemerald" \
      "$DATADIR/applications/pokeemerald.desktop" \
      "$DATADIR/icons/hicolor/256x256/apps/pokeemerald.png"
update-desktop-database "$DATADIR/applications" >/dev/null 2>&1 || true
echo "Uninstalled the menu entry and launcher (the extracted folder is untouched)."
UNINSTALL
chmod +x "$STAGE/uninstall.sh"

cat > "$STAGE/README.txt" <<README
Pokémon Emerald -- native Linux build ($ARCH)

Run it:
    ./pokeemerald.sh

Add it to your applications menu with an icon (no root needed):
    ./install.sh
Remove that again with:
    ./uninstall.sh

This folder is self-contained: it bundles libSDL3, and audio backends
(PipeWire/PulseAudio/ALSA) are loaded from your system at runtime if present.
Saves are written next to the binary as pokeemerald.sav.
README

mkdir -p dist
tar -C dist -czf "$OUT" "$NAME"
rm -rf "$STAGE"

echo "built $OUT"
du -h "$OUT" | awk '{print "size: " $1}'
