#!/usr/bin/env bash
# Usage: apply.sh light|dark   (sets the Kvantum glass theme; restart apps afterwards)
set -euo pipefail
case "${1:-}" in light) T=Duneglow-Light;; dark) T=Duneglow-Dark;; *) echo "Usage: $0 light|dark"; exit 1;; esac
kvantummanager --set "$T"
echo "Kvantum theme: $T. Restart apps (pkill dolphin; dolphin &)."
