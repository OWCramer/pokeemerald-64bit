#!/bin/bash
# Assemble the iOS build into a .app.
#
#   ./tools/make_ios_app.sh            # simulator (unsigned)
#   ./tools/make_ios_app.sh device     # device, signed for installation
#
# SDL3 is linked statically, so unlike the macOS and Linux packaging there is
# nothing to bundle beyond the icon.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-sim}"
BIN="pokeemerald-ios"
APP="dist/pokeemerald.app"
BUNDLE_ID="com.ocramer.pokeemerald"
TEAM_ID="63LV533T6V"

[ -f "$BIN" ] || { echo "error: $BIN not built -- run 'make ios' first" >&2; exit 1; }
if [ "$MODE" = device ]; then PLATFORM=iphoneos; else PLATFORM=iphonesimulator; fi

rm -rf "$APP"; mkdir -p "$APP"
cp "$BIN" "$APP/pokeemerald"

# The Icon Composer bundle compiles straight to an asset catalog; iOS finds it
# by name through CFBundleIconName rather than by filename.
if [ -d appicons/appicon.icon ]; then
    xcrun actool appicons/appicon.icon --compile "$APP" --platform "$PLATFORM" \
        --minimum-deployment-target 15.0 \
        --output-partial-info-plist /tmp/icon-partial.plist >/dev/null 2>&1 \
        && ICON_KEYS='<key>CFBundleIconName</key><string>appicon</string>
    <key>CFBundleIcons</key>
    <dict><key>CFBundlePrimaryIcon</key>
    <dict><key>CFBundleIconName</key><string>appicon</string></dict></dict>
    <key>CFBundleIcons~ipad</key>
    <dict><key>CFBundlePrimaryIcon</key>
    <dict><key>CFBundleIconName</key><string>appicon</string></dict></dict>' \
        || ICON_KEYS=''
else
    ICON_KEYS=''
fi

cat > "$APP/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>pokeemerald</string>
    <key>CFBundleIdentifier</key><string>${BUNDLE_ID}</string>
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
    </array>
    ${ICON_KEYS}
</dict>
</plist>
PLIST

if [ "$MODE" = device ]; then
    # Any profile whose app id is the team wildcard will do; it covers every
    # bundle id on the team, so no per-app profile has to be provisioned.
    PROFILE=$(for f in ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/*.mobileprovision; do
        security cms -D -i "$f" 2>/dev/null | python3 -c "
import sys,plistlib
p=plistlib.loads(sys.stdin.buffer.read())
if p.get('Entitlements',{}).get('application-identifier','') == '${TEAM_ID}.*': print('$f')
" ; done | head -1)
    [ -n "$PROFILE" ] || { echo "error: no ${TEAM_ID}.* wildcard provisioning profile found" >&2; exit 1; }
    cp "$PROFILE" "$APP/embedded.mobileprovision"

    cat > /tmp/ios-ent.plist <<ENT
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>application-identifier</key><string>${TEAM_ID}.${BUNDLE_ID}</string>
    <key>com.apple.developer.team-identifier</key><string>${TEAM_ID}</string>
    <key>get-task-allow</key><true/>
</dict>
</plist>
ENT
    IDENTITY=$(security find-identity -v -p codesigning | grep -m1 "Apple Development" | sed 's/.*") *//;s/.*"\(.*\)"/\1/')
    [ -n "$IDENTITY" ] || { echo "error: no Apple Development signing identity" >&2; exit 1; }
    codesign --force --sign "$IDENTITY" --entitlements /tmp/ios-ent.plist --timestamp=none "$APP"
    echo "signed with: $IDENTITY"
else
    codesign --force --sign - "$APP" >/dev/null 2>&1 || true
fi

echo "built $APP ($MODE)"
