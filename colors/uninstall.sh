#!/usr/bin/env bash
# Restores your previous colour scheme and removes the Duneglow ones.
prev="$(cat "$HOME/.cache/duneglow/previous-colorscheme" 2>/dev/null || echo BreezeLight)"
plasma-apply-colorscheme "${prev:-BreezeLight}" || true
rm -f "$HOME/.local/share/color-schemes/DuneglowLight.colors" "$HOME/.local/share/color-schemes/DuneglowDark.colors"
echo "Restored: ${prev:-BreezeLight}"
