#!/usr/bin/env bash
# Use your own picture as the Duneglow login background.
#   sudo ./set-background.sh /path/to/picture.jpg     set it
#   sudo ./set-background.sh --current                use the wallpaper you have on your desktop right now
#   sudo ./set-background.sh --reset                  back to the built-in wallpapers
# The picture is copied into the theme folder because the login screen cannot read your home folder.
# You keep the picture; it is never part of the shared Duneglow package.
set -euo pipefail

DIR="${THEME_DIR:-/usr/share/sddm/themes/duneglow}"
if [ -z "${THEME_DIR:-}" ] && [ "$(id -u)" -ne 0 ]; then echo "Run as root: sudo $0 $*"; exit 1; fi
[ -f "$DIR/theme.conf" ] || { echo "Theme not found at $DIR. Run install.sh first."; exit 1; }

rm -f "$DIR"/assets/custom-background.*
if [ "${1:-}" = "--reset" ] || [ $# -eq 0 ]; then
  sed -i '/^background=/d' "$DIR/theme.conf"
  echo "Back to the built-in wallpapers."; exit 0
fi

if [ "$1" = "--current" ]; then
  U="${SUDO_USER:-${USER:-}}"; UH="$(getent passwd "$U" | cut -d: -f6)"
  P="$(grep -m1 -E '^Image=' "$UH/.config/plasma-org.kde.plasma.desktop-appletsrc" 2>/dev/null | cut -d= -f2- || true)"
  P="$(python3 -c 'import sys,urllib.parse;print(urllib.parse.unquote(sys.argv[1].removeprefix("file://")))' "$P")"
  if [ -d "$P" ]; then P="$(find "$P" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -printf '%s %p\n' | sort -rn | head -1 | cut -d' ' -f2-)"; fi
  [ -f "$P" ] || { echo "Could not find your current wallpaper. Give the picture path instead."; exit 1; }
  echo "Using: $P"
  set -- "$P"
fi
IMG="$1"
[ -f "$IMG" ] || { echo "File not found: $IMG"; exit 1; }
case "$(file -b --mime-type "$IMG")" in
  image/jpeg) EXT=jpg ;;
  image/png)  EXT=png ;;
  image/webp) EXT=webp ;;
  *) echo "Use a JPG, PNG or WebP picture."; exit 1 ;;
esac
SIZE=$(stat -c %s "$IMG")
[ "$SIZE" -le 31457280 ] || { echo "Picture is over 30 MB. Use a smaller one (a 4K JPG is usually 1-5 MB)."; exit 1; }

cp "$IMG" "$DIR/assets/custom-background.$EXT"
chmod a+r "$DIR/assets/custom-background.$EXT"
command -v restorecon >/dev/null && restorecon -R "$DIR" || true
sed -i '/^background=/d' "$DIR/theme.conf"
echo "background=assets/custom-background.$EXT" >> "$DIR/theme.conf"
echo "Background set. Text switches to the light-on-dark style over your picture."
