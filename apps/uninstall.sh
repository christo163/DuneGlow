#!/usr/bin/env bash
# Removes Bottles (user install) and the Flatpak overrides added by install.sh. Your Bottles data is asked about first.
set -uo pipefail
flatpak uninstall --user -y com.usebottles.bottles 2>/dev/null || true
flatpak override --user --reset 2>/dev/null || true
echo "Bottles removed. Your Windows apps' data (if any) is still in ~/.var/app/com.usebottles.bottles ; delete it yourself if you want the space back."
