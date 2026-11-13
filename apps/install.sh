#!/usr/bin/env bash
# Duneglow app support (Step 9), per-user, no sudo:
#  - Bottles (runs Windows apps; it brings its own Wine) from Flathub, as a USER Flatpak
#  - lets Flatpak apps see your Duneglow icon theme and colour scheme
# Discover (the app store) already works with your Flathub.
set -euo pipefail
command -v flatpak >/dev/null || { echo "flatpak is not installed."; exit 1; }
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
echo "Installing Bottles (about 500 MB with its runtime; this can take a few minutes)..."
flatpak install --user -y flathub com.usebottles.bottles
# Flatpak apps can read your icon themes and KDE colours (read-only)
flatpak override --user --filesystem=xdg-data/icons:ro --filesystem=~/.config/kdeglobals:ro
echo
echo "Done. Bottles is in your launcher (search 'Bottles'). Windows apps you install there appear in the launcher too."
echo "How to run a Windows .exe: open Bottles > Create new bottle (type: Application) > Run executable."
echo "Undo: $(cd "$(dirname "$0")" && pwd)/uninstall.sh"
