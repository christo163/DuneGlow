#!/usr/bin/env bash
prev="$(cat "$HOME/.cache/duneglow/previous-icons" 2>/dev/null)"; prev="${prev:-Fluent-dark}"
kwriteconfig6 --file kdeglobals --group Icons --key Theme "$prev"
rm -rf "$HOME/.local/share/icons/Duneglow-Dark" "$HOME/.local/share/icons/Duneglow-Light"
echo "Restored icon theme: $prev. Restart apps."
