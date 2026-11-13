#!/usr/bin/env bash
# Builds a clean release zip of the project (+ sha256) in the parent folder.
# Usage: ./package.sh [version]
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; NAME="$(basename "$HERE")"; VER="${1:-$(date +%Y%m%d)}"
OUT="$(dirname "$HERE")/duneglow-$VER.zip"
cd "$(dirname "$HERE")"; rm -f "$OUT"
zip -qr "$OUT" "$NAME" -x '*/__pycache__/*' '*.pyc' '*.zip' '*/.cache/*'
( cd "$(dirname "$OUT")" && sha256sum "$(basename "$OUT")" > "$OUT.sha256" )
echo "Built $OUT"; cat "$OUT.sha256"
