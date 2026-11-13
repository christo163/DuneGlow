#!/usr/bin/env bash
# Removes the Duneglow desktop pieces. Your current wallpaper stays as it is; pick another in System Settings.
set -uo pipefail
systemctl --user disable --now duneglow-wallpaper.timer 2>/dev/null
rm -f "$HOME/.config/systemd/user/duneglow-wallpaper.service" "$HOME/.config/systemd/user/duneglow-wallpaper.timer"
systemctl --user daemon-reload
rm -f "$HOME/.local/bin/duneglow-wallpaper"
rm -rf "$HOME/.local/share/wallpapers/Duneglow" "$HOME/.cache/duneglow/wallpaper-state"
command -v kpackagetool6 >/dev/null && kpackagetool6 --type Plasma/Applet --remove org.duneglow.clock
echo "Removed. If the Duneglow Clock is on your desktop, delete it there (right-click > Remove)."
echo "Pick a different wallpaper in System Settings > Appearance > Wallpaper."
