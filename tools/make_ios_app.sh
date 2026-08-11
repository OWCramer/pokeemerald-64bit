#!/bin/bash
# Assemble the iOS build into a .app for the Simulator.
#
# SDL3 is linked statically, so there is nothing to bundle -- unlike the macOS
# and Linux packaging, this is just the executable plus an Info.plist.
set -euo pipefail
cd "$(dirname "$0")/.."

BIN="pokeemerald-ios"
APP="dist/pokeemerald.app"
[ -f "$BIN" ] || { echo "error: $BIN not built -- run 'make ios' first" >&2; exit 1; }

rm -rf "$APP"; mkdir -p "$APP"
cp "$BIN" "$APP/pokeemerald"

cat > "$APP/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>pokeemerald</string>
    <key>CFBundleIdentifier</key><string>com.ocramer.pokeemerald</string>
    <key>CFBundleName</key><string>pokeemerald</string>
    <key>CFBundleDisplayName</key><string>Emerald</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>MinimumOSVersion</key><string>15.0</string>
    <key>LSRequiresIPhoneOS</key><true/>
    <!-- Without a launch screen iOS runs the app letterboxed in a compatibility
         mode at a fraction of the real screen size. -->
    <key>UILaunchScreen</key><dict/>
    <key>UIDeviceFamily</key><array><integer>1</integer><integer>2</integer></array>
    <key>UIRequiredDeviceCapabilities</key><array><string>arm64</string></array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP" >/dev/null 2>&1 || true
echo "built $APP"
