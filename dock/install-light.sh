#!/usr/bin/env bash
# Duneglow-Light Plasma theme (Step 8b): cream glass for the dock, panels and popups, with dark text.
# Per-user, no sudo. Does not apply itself: "duneglow-mode light" does. Re-run set-transparency.sh to change the glass level.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HOME/.local/share/plasma/desktoptheme/Duneglow"; DST="$HOME/.local/share/plasma/desktoptheme/Duneglow-Light"
[ -d "$SRC" ] || { echo "Run ./install.sh first (it installs the dark theme)."; exit 1; }
PCT="${1:-16}"
rm -rf "$DST"; cp -r "$HERE/theme/Duneglow" "$DST"
python3 "$HERE/../tools/make_theme.py" "$DST" "$PCT" light
sed -i 's/"Id": "Duneglow"/"Id": "Duneglow-Light"/; s/"Name": "Duneglow"/"Name": "Duneglow Light"/' "$DST/metadata.json"
python3 - "$DST/colors" <<'PY'
import sys, re
p = sys.argv[1]; t = open(p).read()
swap = {"BackgroundNormal=31,39,64": "BackgroundNormal=244,242,236", "BackgroundAlternate=42,52,82": "BackgroundAlternate=232,229,220",
        "ForegroundNormal=255,255,255": "ForegroundNormal=38,43,51", "ForegroundInactive=200,208,224": "ForegroundInactive=93,102,114",
        "ForegroundActive=255,200,150": "ForegroundActive=200,99,26", "ForegroundLink=150,190,255": "ForegroundLink=47,106,168",
        "ForegroundVisited=190,160,255": "ForegroundVisited=122,78,158", "ForegroundNegative=255,120,120": "ForegroundNegative=192,57,43",
        "ForegroundNeutral=255,190,90": "ForegroundNeutral=184,110,12", "ForegroundPositive=130,220,150": "ForegroundPositive=46,139,87"}
for a, b in swap.items(): t = t.replace(a, b)
t = t.replace("light text on dark glass", "dark text on cream glass")
open(p, "w").write(t)
PY
echo "Duneglow-Light Plasma theme installed. Switch with: duneglow-mode light"
