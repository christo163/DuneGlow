#!/usr/bin/env bash
# Duneglow colours (Step 6a), per-user, no sudo. Installs Duneglow Light and Duneglow Dark.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.cache/duneglow" "$HOME/.local/share/color-schemes"
if [ ! -f "$HOME/.cache/duneglow/previous-colorscheme" ]; then
  kreadconfig6 --file kdeglobals --group General --key ColorScheme > "$HOME/.cache/duneglow/previous-colorscheme" || true
fi
cp "$HERE"/schemes/*.colors "$HOME/.local/share/color-schemes/"
echo "Installed: DuneglowLight, DuneglowDark"
echo "Apply:  $HERE/apply.sh dark    or    $HERE/apply.sh light"
