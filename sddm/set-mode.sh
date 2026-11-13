#!/usr/bin/env bash
# Choose the login screen look. Run: sudo ./set-mode.sh light | dark | auto
set -euo pipefail
DIR="${THEME_DIR:-/usr/share/sddm/themes/duneglow}"
if [ -z "${THEME_DIR:-}" ] && [ "$(id -u)" -ne 0 ]; then echo "Run as root: sudo $0 $*"; exit 1; fi
case "${1:-}" in light|dark|auto) ;; *) echo "Usage: sudo $0 light|dark|auto"; exit 1 ;; esac
[ -f "$DIR/theme.conf" ] || { echo "Theme not found at $DIR. Run install.sh first."; exit 1; }
sed -i '/^mode=/d' "$DIR/theme.conf"
echo "mode=$1" >> "$DIR/theme.conf"
echo "Login screen mode set to: $1"
