#!/usr/bin/env bash
# Duneglow Kvantum theme (Step 6b, dark), per-user, no sudo.
# Builds ~/.config/Kvantum/Duneglow-Dark from your installed Qogir-dark (GPL-3.0) with Duneglow colours.
set -euo pipefail
SRC="$HOME/.config/Kvantum/Qogir-dark"
DST="$HOME/.config/Kvantum/Duneglow-Dark"
[ -f "$SRC/Qogir-dark.svg" ] || { echo "Qogir-dark not found in $SRC"; exit 1; }
mkdir -p "$HOME/.cache/duneglow"
[ -f "$HOME/.cache/duneglow/previous-widgetstyle" ] || kreadconfig6 --file kdeglobals --group KDE --key widgetStyle > "$HOME/.cache/duneglow/previous-widgetstyle" || true
[ -f "$HOME/.cache/duneglow/previous-kvantum" ] || { grep -m1 '^theme=' "$HOME/.config/Kvantum/kvantum.kvconfig" | cut -d= -f2 > "$HOME/.cache/duneglow/previous-kvantum" 2>/dev/null || true; }

rm -rf "$DST"; mkdir -p "$DST"
recolor() {  # case-insensitive hex swaps
  sed -E \
   -e 's/#5294e2/#E8873A/Ig' \
   -e 's/#32343d/#1F2740/Ig' -e 's/#2e303a/#26304E/Ig' -e 's/#282a33/#1B2238/Ig' \
   -e 's/#474d5d/#3A4568/Ig' -e 's/#abb9b6/#9AA7C0/Ig' \
   -e 's/#c8cfd8/#C9D2E6/Ig' -e 's/#c9cfdb/#C9D2E6/Ig' \
   -e 's/#e0e5eb/#E7EBF4/Ig' -e 's/#333333/#1F2740/Ig' \
   -e 's/^highlight\.text\.color=.*/highlight.text.color=#1B2238/' \
   -e 's/^progress\.indicator\.text\.color=.*/progress.indicator.text.color=#1B2238/' \
   -e 's/^reduce_window_opacity=.*/reduce_window_opacity=35/' \
   -e 's/^reduce_menu_opacity=.*/reduce_menu_opacity=30/' \
   -e 's/^menu_blur_radius=.*/menu_blur_radius=10/' \
   -e 's/^tooltip_blur_radius=.*/tooltip_blur_radius=6/'
}
recolor < "$SRC/Qogir-dark.kvconfig" > "$DST/Duneglow-Dark.kvconfig"
recolor < "$SRC/Qogir-dark.svg"      > "$DST/Duneglow-Dark.svg"
python3 "$(dirname "$0")/selection.py" "$DST/Duneglow-Dark.svg"
echo "Built $DST"

# Light variant (needs Qogir-light)
if [ -d "$HOME/.config/Kvantum/Qogir-light" ]; then
  python3 "$(dirname "$0")/make_light.py" "$HOME/.config/Kvantum/Qogir-light" "$HOME/.config/Kvantum/Duneglow-Light"
  python3 "$(dirname "$0")/selection.py" "$HOME/.config/Kvantum/Duneglow-Light/Duneglow-Light.svg"
else
  echo "Qogir-light not found: Light variant skipped."
fi

kvantummanager --set Duneglow-Dark
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum
echo
echo "Applied. Restart apps to see it (e.g. pkill dolphin; dolphin &)."
echo "Glass level:  $(dirname "$0")/glass.sh 35   (0-90, higher = more see-through)"
echo "Undo:         $(dirname "$0")/uninstall.sh"
