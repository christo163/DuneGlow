#!/usr/bin/env bash
pkill dolphin 2>/dev/null || true; sleep 1
B="$HOME/.cache/duneglow/dolphinrc.backup"
if [ -f "$B" ]; then cp -f "$B" "$HOME/.config/dolphinrc"; echo "Dolphin settings restored."; else echo "No backup found."; fi
