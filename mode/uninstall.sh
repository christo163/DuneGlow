#!/usr/bin/env bash
systemctl --user disable --now duneglow-mode.timer 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/duneglow-mode.service" "$HOME/.config/systemd/user/duneglow-mode.timer" "$HOME/.local/bin/duneglow-mode"
systemctl --user daemon-reload
echo "Removed the switch and its timer. Your current look stays as it is."
