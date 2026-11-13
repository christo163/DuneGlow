#!/usr/bin/env bash
# Duneglow title bars (Step 6e), per-user, no sudo. Builds Duneglow-Dark/-Light from Qogir-dark/-light (Aurorae).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; A="$HOME/.local/share/aurorae/themes"
mkdir -p "$HOME/.cache/duneglow"
if [ ! -f "$HOME/.cache/duneglow/previous-deco" ]; then
  { kreadconfig6 --file kwinrc --group org.kde.kdecoration2 --key library; kreadconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme; } > "$HOME/.cache/duneglow/previous-deco" || true
fi
for m in dark light; do
  [ -d "$A/Qogir-$m" ] || { echo "Qogir-$m not found in $A: skipped"; continue; }
  python3 "$HERE/make_deco.py" "$m" "$A/Qogir-$m" "$A/Duneglow-$(echo ${m:0:1} | tr a-z A-Z)${m:1}"
done
echo "Apply:  $HERE/apply.sh dark   or   $HERE/apply.sh light"
echo "Undo:   $HERE/uninstall.sh"
