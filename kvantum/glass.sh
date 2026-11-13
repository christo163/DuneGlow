#!/usr/bin/env bash
# Usage: glass.sh N   (0-90, higher = more see-through). Restart apps afterwards.
set -euo pipefail
N="${1:?usage: glass.sh 0-90}"
case "$N" in (*[!0-9]*|'') echo "number 0-90 please"; exit 1;; esac
[ "$N" -le 90 ] || { echo "max 90"; exit 1; }
for T in Dark Light; do F="$HOME/.config/Kvantum/Duneglow-$T/Duneglow-$T.kvconfig"; [ -f "$F" ] || continue
sed -i -E "s/^reduce_window_opacity=.*/reduce_window_opacity=$N/" "$F"
M=$(( N > 10 ? N - 5 : N ))
sed -i -E "s/^reduce_menu_opacity=.*/reduce_menu_opacity=$M/" "$F"
done
echo "Glass level $N. Restart apps: pkill dolphin; dolphin &"
