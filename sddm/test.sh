#!/usr/bin/env bash
# Previews the theme in a window. Nothing is installed and no real login happens.
#   ./test.sh                      preview the theme
#   ./test.sh --light | --dark     force light or dark (you can also click the sun/moon button)
#   ./test.sh ~/Pictures/pic.jpg   preview with your own background picture
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
DIR="$TMP/duneglow"
cp -r "$HERE/duneglow" "$DIR"
sed -i '/^demo=/d' "$DIR/theme.conf"
echo "demo=true" >> "$DIR/theme.conf"       # preview mode: any password counts as wrong, so you can see the shake
for arg in "$@"; do
  case "$arg" in
    --light) sed -i '/^mode=/d' "$DIR/theme.conf"; echo "mode=light" >> "$DIR/theme.conf" ;;
    --dark)  sed -i '/^mode=/d' "$DIR/theme.conf"; echo "mode=dark"  >> "$DIR/theme.conf" ;;
    *)       THEME_DIR="$DIR" "$HERE/set-background.sh" "$arg" ;;
  esac
done
for g in sddm-greeter-qt6 sddm-greeter; do
  if command -v "$g" >/dev/null; then
    echo "Using $g. Click the user pill, type anything, press Enter: you should see the wrong-password shake."
    echo "Close the window to exit. (Messages about QLocalSocket are normal in preview mode.)"
    "$g" --test-mode --theme "$DIR"
    exit 0
  fi
done
echo "No sddm greeter found. Install it with: sudo dnf install sddm"; exit 1
