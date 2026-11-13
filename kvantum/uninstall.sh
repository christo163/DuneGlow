#!/usr/bin/env bash
# Restores your previous widget style and Kvantum theme, removes Duneglow-Dark.
ws="$(cat "$HOME/.cache/duneglow/previous-widgetstyle" 2>/dev/null)"; ws="${ws:-Breeze}"
kv="$(cat "$HOME/.cache/duneglow/previous-kvantum" 2>/dev/null)"
[ -n "$kv" ] && kvantummanager --set "$kv" || true
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle "$ws"
rm -rf "$HOME/.config/Kvantum/Duneglow-Dark" "$HOME/.config/Kvantum/Duneglow-Light"
echo "Restored widget style: $ws. Restart apps."
