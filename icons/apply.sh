#!/usr/bin/env bash
# Usage: apply.sh light|dark
set -euo pipefail
case "${1:-}" in light) T=Duneglow-Light;; dark) T=Duneglow-Dark;; *) echo "Usage: $0 light|dark"; exit 1;; esac
kwriteconfig6 --file kdeglobals --group Icons --key Theme "$T"
for h in /usr/libexec/plasma-changeicons /usr/lib64/libexec/plasma-changeicons /usr/lib/libexec/plasma-changeicons; do
  [ -x "$h" ] && { "$h" "$T" || true; break; }
done
echo "Icon theme: $T. Restart apps (pkill dolphin; dolphin &) and, if the dock icons did not change: systemctl --user restart plasma-plasmashell"
