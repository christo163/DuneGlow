#!/usr/bin/env bash
# Usage: apply.sh light|dark
set -euo pipefail
case "${1:-}" in
  light) plasma-apply-colorscheme DuneglowLight ;;
  dark)  plasma-apply-colorscheme DuneglowDark ;;
  *) echo "Usage: $0 light|dark"; exit 1 ;;
esac
