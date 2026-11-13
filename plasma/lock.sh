#!/usr/bin/env bash
# Duneglow lock screen (Plasma 6.7: lives in a shell package, not Look and Feel).
# Usage: ./lock.sh install | test | uninstall
set -euo pipefail
ID="org.duneglow.shell"
HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.local/share/plasma/shells/$ID"

find_greeter() {
  for p in /usr/libexec/kscreenlocker_greet /usr/lib64/libexec/kscreenlocker_greet \
           /usr/lib/kscreenlocker_greet; do
    [ -x "$p" ] && { echo "$p"; return; }
  done
  find /usr/lib /usr/lib64 /usr/libexec -name kscreenlocker_greet -type f 2>/dev/null | head -n1
}

case "${1:-}" in
  install)
    mkdir -p "$(dirname "$DEST")"
    rm -rf "$DEST"
    cp -r "$HERE/$ID" "$DEST"
    [ -x "$HOME/.local/bin/duneglow-background" ] && "$HOME/.local/bin/duneglow-background" --reapply || true
    echo "Installed to $DEST (preview only; it does not replace your real lock screen)."
    echo "Next: $HERE/lock.sh test"
    ;;
  test)
    G="$(find_greeter)"
    [ -n "$G" ] || { echo "kscreenlocker_greet not found"; exit 1; }
    [ -d "$DEST" ] || { echo "Run ./lock.sh install first"; exit 1; }
    echo "Preview in testing mode (cannot lock you out). Press a key, type your real password."
    "$G" --testing --shell "$DEST" 2>&1 | grep -v "has no notify signal" || true
    ;;
  uninstall)
    rm -rf "$DEST"
    echo "Removed $DEST."
    ;;
  *) echo "Usage: $0 install|test|uninstall"; exit 1 ;;
esac
