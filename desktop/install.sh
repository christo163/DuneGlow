#!/usr/bin/env bash
# Duneglow desktop (Step 3), per-user, no sudo:
#  - Duneglow wallpaper package (day + night)
#  - duneglow-wallpaper switcher + systemd user timer (dark 18:00-05:59)
#  - Duneglow Clock widget (add it from Add Widgets)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

# 1. wallpapers
mkdir -p "$HOME/.local/share/wallpapers"
rm -rf "$HOME/.local/share/wallpapers/Duneglow"
cp -r "$HERE/wallpapers/Duneglow" "$HOME/.local/share/wallpapers/Duneglow"
echo "Wallpapers installed."

# 2. switcher + timer
mkdir -p "$HOME/.local/bin" "$HOME/.config/systemd/user"
install -m 755 "$HERE/duneglow-wallpaper" "$HOME/.local/bin/duneglow-wallpaper"
install -m 644 "$HERE/systemd/duneglow-wallpaper.service" "$HERE/systemd/duneglow-wallpaper.timer" "$HOME/.config/systemd/user/"
systemctl --user daemon-reload
systemctl --user enable --now duneglow-wallpaper.timer
echo "Wallpaper timer enabled."
"$HOME/.local/bin/duneglow-wallpaper" auto || echo "(Wallpaper not applied yet; the timer will retry.)"

# 3. clock widget
if command -v kpackagetool6 >/dev/null; then
  kpackagetool6 --type Plasma/Applet --upgrade "$HERE/org.duneglow.clock" \
    || kpackagetool6 --type Plasma/Applet --install "$HERE/org.duneglow.clock"
  echo "Clock widget installed: right-click the desktop > Add or Manage Widgets > Duneglow Clock."
else
  echo "kpackagetool6 not found; clock widget not installed."
fi

echo
echo "Wallpaper control:  duneglow-wallpaper auto|day|night|off|status   (~/.local/bin)"
echo "Undo everything:    $HERE/uninstall.sh"
echo
echo "Your own wallpaper:"
echo "  keep the one you choose in System Settings :  ~/.local/bin/duneglow-wallpaper own"
echo "  or use YOUR pictures for day and night      :  ~/.local/bin/duneglow-wallpaper set-day ~/Pictures/day.jpg"
echo "                                                  ~/.local/bin/duneglow-wallpaper set-night ~/Pictures/night.jpg"
echo "  back to the Duneglow pictures               :  ~/.local/bin/duneglow-wallpaper auto   (and reset-pictures)"
