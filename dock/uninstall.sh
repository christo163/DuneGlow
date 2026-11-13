#!/usr/bin/env bash
# Removes the Duneglow dock, widget and Plasma theme, and restores your previous Plasma theme.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
"$HERE/remove-panel.sh" 2>/dev/null || true
PREV="$(cat "$HOME/.cache/duneglow/previous-plasma-theme" 2>/dev/null || true)"
if command -v plasma-apply-desktoptheme >/dev/null; then
  plasma-apply-desktoptheme "${PREV:-default}" || true
fi
command -v kpackagetool6 >/dev/null && kpackagetool6 --type Plasma/Applet --remove org.duneglow.overview
rm -rf "$HOME/.local/share/plasma/desktoptheme/Duneglow" "$HOME/.cache/duneglow/previous-plasma-theme"
echo "Removed. Plasma theme restored to: ${PREV:-default}."
echo "If the Overview widget still shows somewhere, run: systemctl --user restart plasma-plasmashell"
