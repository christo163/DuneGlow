#!/usr/bin/env bash
# Installs the Duneglow splash screen for your user only. No sudo needed.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.local/share/plasma/look-and-feel/org.duneglow.desktop"
mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -r "$HERE/org.duneglow.desktop" "$DEST"
echo "Installed to $DEST"
if command -v kwriteconfig6 >/dev/null; then
  kwriteconfig6 --file ksplashrc --group KSplash --key Engine KSplashQML
  kwriteconfig6 --file ksplashrc --group KSplash --key Theme org.duneglow.desktop
  echo "Splash screen set to Duneglow. You will see it the next time you log in."
else
  echo "Now choose it: System Settings > Appearance > Splash Screen > Duneglow > Apply."
fi
echo "Preview first with:  ./test-splash.sh"
echo "Undo with:           ./uninstall.sh"
