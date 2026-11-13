#!/usr/bin/env bash
lib="$(sed -n 1p "$HOME/.cache/duneglow/previous-deco" 2>/dev/null)"; th="$(sed -n 2p "$HOME/.cache/duneglow/previous-deco" 2>/dev/null)"
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library "${lib:-org.kde.breeze}"
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme "${th:-Breeze}"
gdbus call --session --dest org.kde.KWin --object-path /KWin --method org.kde.KWin.reconfigure >/dev/null
rm -rf "$HOME/.local/share/aurorae/themes/Duneglow-Dark" "$HOME/.local/share/aurorae/themes/Duneglow-Light"
echo "Restored: ${lib:-org.kde.breeze} / ${th:-Breeze}"
