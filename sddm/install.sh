#!/usr/bin/env bash
# Duneglow SDDM theme installer for Fedora KDE Plasma. Run from this folder: sudo ./install.sh
set -euo pipefail

THEME=duneglow
SRC="$(cd "$(dirname "$0")" && pwd)/$THEME"
DEST="/usr/share/sddm/themes/$THEME"
CONF="/etc/sddm.conf.d/zz-duneglow.conf"

[ "$(id -u)" -eq 0 ] || { echo "Run as root: sudo $0"; exit 1; }
[ -f "$SRC/Main.qml" ] || { echo "Cannot find $SRC/Main.qml"; exit 1; }
command -v sddm >/dev/null || { echo "SDDM is not installed. Stopping."; exit 1; }
systemctl is-enabled sddm.service >/dev/null 2>&1 || echo "Note: sddm.service is not enabled. The theme installs but may not be used."

case "${LANG:-C}" in
  *UTF-8*|*utf8*) ;;
  *) echo "Note: your locale is '${LANG:-C}', not UTF-8. The login screen still works, but you can fix it with: sudo localectl set-locale LANG=en_US.UTF-8" ;;
esac

BG_IMG=""
[ "${1:-}" = "--background" ] && [ -n "${2:-}" ] && BG_IMG="$2"
KEEP="$(mktemp -d)"
if [ -d "$DEST/assets" ]; then cp "$DEST"/assets/custom-background.* "$KEEP"/ 2>/dev/null || true; fi
KEEP_LINE="$(grep -h '^background=' "$DEST/theme.conf" 2>/dev/null || true)"
KEEP_MODE="$(grep -h '^mode=' "$DEST/theme.conf" 2>/dev/null || true)"

echo "Installing theme to $DEST"
rm -rf "$DEST"
mkdir -p "$DEST"
cp -r "$SRC"/. "$DEST"/
chmod -R a+rX "$DEST"
if ls "$KEEP"/custom-background.* >/dev/null 2>&1 && [ -n "$KEEP_LINE" ]; then
  cp "$KEEP"/custom-background.* "$DEST/assets/"
  echo "$KEEP_LINE" >> "$DEST/theme.conf"
  echo "Kept your custom background."
fi
if [ -n "$KEEP_MODE" ]; then sed -i '/^mode=/d' "$DEST/theme.conf"; echo "$KEEP_MODE" >> "$DEST/theme.conf"; echo "Kept your light/dark mode setting."; fi
rm -rf "$KEEP"
command -v restorecon >/dev/null && restorecon -R "$DEST" || true
[ -n "$BG_IMG" ] && THEME_DIR="$DEST" "$(dirname "$0")/set-background.sh" "$BG_IMG"

echo "Writing $CONF"
mkdir -p /etc/sddm.conf.d
cat > "$CONF" <<CFG
[Theme]
Current=$THEME
CFG

echo
echo "Installed. Nothing has changed on screen yet."
echo "1. Preview it in a window first:   ./test.sh"
echo "2. See it for real:                log out (do not reboot yet) and look at the login screen."
echo "3. Undo it any time:               sudo ./uninstall.sh"
echo "   If the screen is broken: Ctrl+Alt+F3, log in, then run:  sudo rm -f $CONF && sudo systemctl restart sddm"
