#!/usr/bin/env bash
# Duneglow cursors (Step 6f): uses the Sweet-cursors theme you already have. Usage: ./install.sh [size]   (default 24; try 28 or 32)
set -euo pipefail
SIZE="${1:-24}"
case "$SIZE" in ''|*[!0-9]*) echo "Usage: $0 [size]"; exit 1;; esac
mkdir -p "$HOME/.cache/duneglow"
[ -f "$HOME/.cache/duneglow/previous-cursor" ] || kreadconfig6 --file kcminputrc --group Mouse --key cursorTheme > "$HOME/.cache/duneglow/previous-cursor" || true
plasma-apply-cursortheme --size "$SIZE" Sweet-cursors
echo "Cursor: Sweet-cursors, size $SIZE. Already-open apps may keep the old cursor until restarted."
echo "Undo: $(dirname "$0")/uninstall.sh"
