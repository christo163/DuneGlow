#!/usr/bin/env bash
# Duneglow: install everything (per-user, no sudo). Login screen needs sudo and is separate.
# Usage:  ./install.sh [dark|light]     (default: dark)
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
START="${1:-dark}"
case "$START" in dark|light) ;; *) echo "Usage: $0 [dark|light]"; exit 1;; esac

for c in kwriteconfig6 kreadconfig6 kpackagetool6 python3; do
  command -v "$c" >/dev/null || { echo "Missing required command: $c"; exit 1; }
done

step() { echo; echo "=== $1"; shift; "$@" || echo "!! step failed (continuing): $*"; }

step "Colours"            "$HERE/colors/install.sh"
step "Kvantum glass"      "$HERE/kvantum/install.sh"
step "Icons"              "$HERE/icons/install.sh"
step "Title bars"         "$HERE/deco/install.sh"
step "Cursors"            "$HERE/cursors/install.sh"
step "Dolphin"            "$HERE/dolphin/install.sh"
step "Dock theme+widget"  "$HERE/dock/install.sh"
step "Dock (light)"       "$HERE/dock/install-light.sh"
step "Launcher"           "$HERE/launcher/install.sh"
step "Desktop + clock"    "$HERE/desktop/install.sh"
step "Splash"             "$HERE/plasma/install.sh"
step "Backgrounds tool"   "$HERE/backgrounds/install.sh"
step "Light/dark switch"  "$HERE/mode/install.sh"

echo; echo "=== Glass app icons"
"$HERE/icons/glass-apps.sh" on || true

echo; echo "=== Applying $START"
"$HOME/.local/bin/duneglow-mode" "$START" || echo "Run:  ~/.local/bin/duneglow-mode $START"

cat <<MSG

Done. Optional next steps:
  Dock:            $HERE/dock/create-panel.sh        (builds the dock)
                   $HERE/launcher/add-to-dock.sh     (adds the cube launcher)
  Login screen:    sudo $HERE/sddm/install.sh        (needs sudo)
  Check all:       $HERE/verify.sh
  Switch mode:     duneglow-mode light | dark | auto
  Own backgrounds: duneglow-background --help
Log out and in once so the splash and cursor are fully applied.
MSG
