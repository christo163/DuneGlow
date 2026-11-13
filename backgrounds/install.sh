#!/usr/bin/env bash
# Installs the `duneglow-background` command (per-user) and the helper it uses for the login screen.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/duneglow"
install -m 755 "$HERE/duneglow-background" "$HOME/.local/bin/duneglow-background"
install -m 755 "$HERE/../sddm/set-background.sh" "$HOME/.local/share/duneglow/set-login-background.sh"
echo "Installed. Examples:"
echo "  duneglow-background lock  ~/Pictures/photo.jpg"
echo "  duneglow-background login ~/Pictures/photo.jpg      (asks for your password once)"
echo "  duneglow-background desktop ~/Pictures/photo.jpg"
echo "  duneglow-background all   --current                  (everything uses your current wallpaper)"
echo "  duneglow-background all   --reset                    (back to the built-in Duneglow pictures)"
echo "(If the command is not found, use ~/.local/bin/duneglow-background.)"
