#!/usr/bin/env bash
# Duneglow Dolphin layout (Step 7a), per-user. Close Dolphin first (it rewrites its settings on exit).
# Usage: ./install.sh [icon-size]   (default 80; try 64 or 96)
set -euo pipefail
SIZE="${1:-80}"
case "$SIZE" in ''|*[!0-9]*) echo "Usage: $0 [icon-size]"; exit 1;; esac
pkill dolphin 2>/dev/null || true; sleep 1
mkdir -p "$HOME/.cache/duneglow"
[ -f "$HOME/.cache/duneglow/dolphinrc.backup" ] || cp -f "$HOME/.config/dolphinrc" "$HOME/.cache/duneglow/dolphinrc.backup" 2>/dev/null || touch "$HOME/.cache/duneglow/dolphinrc.backup"
w() { kwriteconfig6 --file dolphinrc --group "$1" --key "$2" "$3"; }
w IconsMode IconSize "$SIZE"
w IconsMode PreviewSize "$SIZE"
w General RememberOpenedTabs true
w General OpenExternallyCalledFolderInNewTab true
w General ShowFullPath false
echo "Dolphin: icon size $SIZE, tabs remembered, folders from other apps open in a new tab."
echo "Undo: $(dirname "$0")/uninstall.sh"
