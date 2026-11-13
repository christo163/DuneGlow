#!/usr/bin/env bash
# Duneglow launcher (Step 5), per-user, no sudo. Installs the widget only; does not touch your dock.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
kpackagetool6 --type Plasma/Applet --upgrade "$HERE/org.duneglow.launcher" \
  || kpackagetool6 --type Plasma/Applet --install "$HERE/org.duneglow.launcher"
echo
echo "Installed. Try it WITHOUT changing your dock:  $HERE/test.sh"
echo "Undo:  $HERE/uninstall.sh"
