#!/usr/bin/env bash
# Duneglow icons (Step 6c), per-user, no sudo. Needs Fluent-dark / Fluent-light in ~/.local/share/icons.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.cache/duneglow"
[ -f "$HOME/.cache/duneglow/previous-icons" ] || kreadconfig6 --file kdeglobals --group Icons --key Theme > "$HOME/.cache/duneglow/previous-icons" || true
python3 "$HERE/make_icons.py" "$HOME/.local/share/icons"
for t in Duneglow-Dark Duneglow-Light; do gtk-update-icon-cache -q -f "$HOME/.local/share/icons/$t" 2>/dev/null || true; done
echo "Apply:  $HERE/apply.sh dark   or   $HERE/apply.sh light"
echo "Undo:   $HERE/uninstall.sh"
