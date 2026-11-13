#!/usr/bin/env bash
# Sets the height of the Duneglow dock (the bottom panel); bigger = bigger icons. Usage: ./set-height.sh 64   (40-96, default was 52)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; . "$HERE/lib.sh"
H="${1:-}"; case "$H" in ''|*[!0-9]*) echo "Usage: $0 <40-96>"; exit 1;; esac
[ "$H" -ge 40 ] && [ "$H" -le 96 ] || { echo "40-96 please"; exit 1; }
plasma_eval "var ps = panels(); for (var i = 0; i < ps.length; i++) { if (ps[i].location == 'bottom') { ps[i].height = $H; } }" >/dev/null
echo "Dock height set to $H."
