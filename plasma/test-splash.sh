#!/usr/bin/env bash
# Previews the splash in a window. Run ./install.sh first.
set -euo pipefail
[ -d "$HOME/.local/share/plasma/look-and-feel/org.duneglow.desktop" ] || { echo "Run ./install.sh first."; exit 1; }
if command -v ksplashqml >/dev/null; then
  echo "Opening the splash in test mode. Close the window or press Ctrl+C to stop."
  ksplashqml --test --window org.duneglow.desktop || echo "Test mode failed. Use System Settings > Appearance > Splash Screen and press the test button on Duneglow."
else
  echo "ksplashqml not found. Use System Settings > Appearance > Splash Screen and press the test button on Duneglow."
fi
