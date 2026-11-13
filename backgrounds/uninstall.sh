#!/usr/bin/env bash
set -uo pipefail
"$HOME/.local/bin/duneglow-background" all --reset 2>/dev/null || true
rm -f "$HOME/.local/bin/duneglow-background" "$HOME/.local/share/duneglow/set-login-background.sh"
rm -rf "$HOME/.local/share/duneglow/backgrounds"
echo "Backgrounds tool removed."
