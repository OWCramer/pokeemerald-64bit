#!/bin/bash
# Package the native build as a self-contained macOS .app.
#
# The binary links Homebrew's libSDL3, which a recipient will not have, so the
# dylib is copied into the bundle and the load path rewritten to
# @executable_path. SDL3 itself only needs system frameworks, so that is the
# only library to carry.
#
# Apple Silicon refuses to run unsigned binaries at all, hence the ad-hoc
# signature. Ad-hoc is not notarised: a downloaded copy is quarantined and the
# recipient must right-click > Open once, or strip the attribute (see below).
set -euo pipefail
cd "$(dirname "$0")/.."

APP_NAME="pokeemerald"
BIN="pokeemerald-sdl3"
SDL_LIB="$(otool -L "$BIN" | awk '/libSDL3/ {print $1; exit}')"
DEST="dist/${APP_NAME}.app"

[ -f "$BIN" ] || { echo "error: $BIN not built -- run 'make native' first" >&2; exit 1; }
[ -f "$SDL_LIB" ] || { echo "error: cannot find $SDL_LIB" >&2; exit 1; }

# Declare exactly what the binary was built for, so the two cannot drift.
MIN_OS="$(otool -l "$BIN" | awk '/LC_BUILD_VERSION/{f=1} f&&/minos/{print $2; exit}')"
MIN_OS="${MIN_OS:-11.0}"

rm -rf "$DEST"
mkdir -p "$DEST/Contents/MacOS" "$DEST/Contents/Frameworks" "$DEST/Contents/Resources"

cp "$BIN" "$DEST/Contents/MacOS/$APP_NAME"
SDL_BASE="$(basename "$SDL_LIB")"
cp "$SDL_LIB" "$DEST/Contents/Frameworks/$SDL_BASE"
chmod u+w "$DEST/Contents/Frameworks/$SDL_BASE"

install_name_tool -id "@executable_path/../Frameworks/$SDL_BASE" \
    "$DEST/Contents/Frameworks/$SDL_BASE"
install_name_tool -change "$SDL_LIB" "@executable_path/../Frameworks/$SDL_BASE" \
    "$DEST/Contents/MacOS/$APP_NAME"

# Icon, built from the title screen logo if the tools are present.
if [ -f graphics/title_screen/pokemon_logo.png ] && command -v iconutil >/dev/null; then
    ICONSET="$(mktemp -d)/AppIcon.iconset"
    mkdir -p "$ICONSET"
    for SZ in 16 32 64 128 256 512; do
        sips -s format png -z $SZ $SZ graphics/title_screen/pokemon_logo.png \
             --out "$ICONSET/icon_${SZ}x${SZ}.png" >/dev/null 2>&1 || true
        sips -s format png -z $((SZ*2)) $((SZ*2)) graphics/title_screen/pokemon_logo.png \
             --out "$ICONSET/icon_${SZ}x${SZ}@2x.png" >/dev/null 2>&1 || true
    done
    iconutil -c icns "$ICONSET" -o "$DEST/Contents/Resources/AppIcon.icns" 2>/dev/null \
        && ICON_KEY='<key>CFBundleIconFile</key><string>AppIcon</string>' || ICON_KEY=''
    rm -rf "$(dirname "$ICONSET")"
else
    ICON_KEY=''
fi

cat > "$DEST/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>${APP_NAME}</string>
    <key>CFBundleExecutable</key><string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key><string>com.owcramer.${APP_NAME}</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1.0</string>
    <key>LSMinimumSystemVersion</key><string>${MIN_OS}</string>
    <key>NSHighResolutionCapable</key><true/>
    ${ICON_KEY}
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$DEST" >/dev/null 2>&1 \
    && echo "signed (ad-hoc)" || echo "warning: codesign failed; the app may not launch"

echo "built $DEST"
du -sh "$DEST" | awk '{print "size: " $1}'
