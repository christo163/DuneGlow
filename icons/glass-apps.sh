#!/usr/bin/env bash
# Liquid-glass tiles behind app icons (dock, launcher). Usage: ./glass-apps.sh on | off
# Needs ./install.sh to have been run (it builds the Duneglow icon themes). Re-run "on" after every ./install.sh.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
case "${1:-}" in on|off) ;; *) echo "Usage: $0 on|off"; exit 1;; esac
python3 "$HERE/make_glass_apps.py" "$1" "$HOME/.local/share/icons"
rm -f "$HOME/.cache/icon-cache.kcache"
echo "Now restart the shell so the dock and launcher reload icons:  systemctl --user restart plasma-plasmashell"
