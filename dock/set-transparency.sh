#!/usr/bin/env bash
# Sets how see-through the Duneglow dock is. Usage: ./set-transparency.sh 35
# Percent of dark tint: 5 = almost clear glass, 16 = default (matches the launcher), 62 = the earlier darker look, 95 = nearly solid.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PCT="${1:-}"
case "$PCT" in ''|*[!0-9]*) echo "Usage: $0 <5-95>   e.g. $0 25"; exit 1 ;; esac
THEME="$HOME/.local/share/plasma/desktoptheme/Duneglow"
[ -d "$THEME" ] || { echo "Run ./install.sh first."; exit 1; }
python3 "$HERE/../tools/make_theme.py" "$THEME" "$PCT"
LT="$HOME/.local/share/plasma/desktoptheme/Duneglow-Light"
[ -d "$LT" ] && python3 "$HERE/../tools/make_theme.py" "$LT" "$PCT" light
echo "Dock tint set to ${PCT}%. Restarting the Plasma shell to apply (windows stay open)..."
systemctl --user restart plasma-plasmashell
