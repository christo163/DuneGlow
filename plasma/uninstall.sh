#!/usr/bin/env bash
# Removes the Duneglow splash screen and returns to your default splash.
set -euo pipefail
rm -rf "$HOME/.local/share/plasma/look-and-feel/org.duneglow.desktop"
if command -v kwriteconfig6 >/dev/null; then
  kwriteconfig6 --file ksplashrc --group KSplash --key Theme --delete || true
  kwriteconfig6 --file ksplashrc --group KSplash --key Engine --delete || true
fi
echo "Duneglow splash removed. Your default splash screen returns at the next login."
