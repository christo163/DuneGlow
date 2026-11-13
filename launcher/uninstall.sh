#!/usr/bin/env bash
set -uo pipefail
"$(cd "$(dirname "$0")" && pwd)/remove-from-dock.sh" 2>/dev/null || true
kpackagetool6 --type Plasma/Applet --remove org.duneglow.launcher
echo "Removed. If the widget still shows somewhere: systemctl --user restart plasma-plasmashell"
