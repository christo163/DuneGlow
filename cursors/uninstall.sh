#!/usr/bin/env bash
prev="$(cat "$HOME/.cache/duneglow/previous-cursor" 2>/dev/null)"; prev="${prev:-breeze_cursors}"
plasma-apply-cursortheme "$prev"
echo "Cursor restored: $prev"
