#!/usr/bin/env bash
# Duneglow dock (Step 4), per-user, no sudo:
#  - Duneglow Plasma theme (glass panels and popups)
#  - Duneglow Overview widget
# Then run ./create-panel.sh to build the dock itself.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$HOME/.cache/duneglow" "$HOME/.local/share/plasma/desktoptheme"

# remember the current Plasma theme so uninstall can restore it (only the first time)
if [ ! -f "$HOME/.cache/duneglow/previous-plasma-theme" ]; then
  kreadconfig6 --file plasmarc --group Theme --key name > "$HOME/.cache/duneglow/previous-plasma-theme" || true
fi

rm -rf "$HOME/.local/share/plasma/desktoptheme/Duneglow"
cp -r "$HERE/theme/Duneglow" "$HOME/.local/share/plasma/desktoptheme/Duneglow"
echo "Plasma theme installed."

kpackagetool6 --type Plasma/Applet --upgrade "$HERE/org.duneglow.overview" \
  || kpackagetool6 --type Plasma/Applet --install "$HERE/org.duneglow.overview"
echo "Overview widget installed."

if command -v plasma-apply-desktoptheme >/dev/null; then
  plasma-apply-desktoptheme Duneglow || echo "Could not apply the theme; choose it in System Settings > Appearance > Plasma Style."
fi

echo
echo "Plasma must restart its shell once to see the new widget (your windows stay open):"
echo "    systemctl --user restart plasma-plasmashell"
echo "Then build the dock:"
echo "    $HERE/create-panel.sh"
echo "Undo everything:  $HERE/uninstall.sh"
