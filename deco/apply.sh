#!/usr/bin/env bash
# Usage: apply.sh light|dark
set -euo pipefail
case "${1:-}" in light) T=Duneglow-Light;; dark) T=Duneglow-Dark;; *) echo "Usage: $0 light|dark"; exit 1;; esac
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme "__aurorae__svg__$T"
gdbus call --session --dest org.kde.KWin --object-path /KWin --method org.kde.KWin.reconfigure >/dev/null
echo "Title bar: $T"
