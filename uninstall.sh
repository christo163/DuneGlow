#!/usr/bin/env bash
# Duneglow: remove everything (per-user). Restores your earlier settings where they were saved.
# Usage:  ./uninstall.sh            (login screen: run  sudo ./sddm/uninstall.sh  separately)
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# order matters: stop the auto-switcher first, then the pieces, then icons/kvantum last
for s in mode/uninstall.sh launcher/uninstall.sh dock/uninstall.sh desktop/uninstall.sh \
         plasma/uninstall.sh backgrounds/uninstall.sh dolphin/uninstall.sh cursors/uninstall.sh \
         deco/uninstall.sh icons/uninstall.sh kvantum/uninstall.sh colors/uninstall.sh; do
  if [ -x "$HERE/$s" ]; then echo "=== $s"; "$HERE/$s" || echo "!! failed: $s"; fi
done
rm -f "$HOME/.local/bin/duneglow-background" "$HOME/.local/share/duneglow/set-login-background.sh"
rmdir "$HOME/.local/share/duneglow" 2>/dev/null || true
echo; echo "Done. Login screen (if installed):  sudo $HERE/sddm/uninstall.sh"
echo "Settings backups are kept in ~/.cache/duneglow (safe to delete after you are happy)."
