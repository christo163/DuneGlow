#!/usr/bin/env bash
# Duneglow one-switch light/dark (Step 8a), per-user, no sudo.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.local/bin" "$HOME/.config/systemd/user"
install -m 755 "$HERE/duneglow-mode" "$HOME/.local/bin/duneglow-mode"
cp "$HERE/systemd/duneglow-mode.service" "$HERE/systemd/duneglow-mode.timer" "$HOME/.config/systemd/user/"
systemctl --user daemon-reload
systemctl --user enable --now duneglow-mode.timer
echo "Installed. Use:  duneglow-mode light | dark | auto | status"
echo "(If 'duneglow-mode' is not found, log out and in once, or use ~/.local/bin/duneglow-mode.)"
echo "Undo: $HERE/uninstall.sh"
