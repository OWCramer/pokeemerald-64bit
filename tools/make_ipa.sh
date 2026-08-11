#!/bin/bash
# Wrap the iOS .app in the Payload/ layout that defines an .ipa.
#
#   ./tools/make_ipa.sh [app] [out.ipa]
#
# An .ipa is just a zip with the bundle under Payload/. Build the app first
# with ./tools/make_ios_app.sh (device or unsigned).
set -euo pipefail
cd "$(dirname "$0")/.."

APP="${1:-dist/pokeemerald.app}"
OUT="${2:-dist/pokeemerald-ios.ipa}"

[ -d "$APP" ] || { echo "error: $APP not found -- run tools/make_ios_app.sh first" >&2; exit 1; }

mkdir -p "$(dirname "$OUT")"
# Resolve before cd'ing away, so a relative OUT still lands where asked.
OUT_ABS="$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT")"

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/Payload"

# ditto to stage, because it preserves the executable bit; plain zip to
# archive, because that is what an .ipa is (and what Xcode itself emits).
# Not `ditto -c -k`: even with --sequesterRsrc it writes AppleDouble metadata
# into a __MACOSX/ tree beside Payload/, which does not belong in an .ipa.
ditto "$APP" "$STAGE/Payload/$(basename "$APP")"
rm -f "$OUT_ABS"
( cd "$STAGE" && zip -qry "$OUT_ABS" Payload -x '*.DS_Store' )

echo "built $OUT ($(du -h "$OUT_ABS" | cut -f1))"
