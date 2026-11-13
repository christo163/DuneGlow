# Duneglow

A liquid-glass KDE Plasma 6 desktop theme: warm dunes, slate mountains, light and dark modes.
Made for Fedora 44 / Plasma 6.7 (Wayland). Per-user install, no sudo (except the optional login screen).

## Requirements
Kvantum, Qogir-kde (Kvantum + Aurorae, dark and light), Fluent icon theme, Sweet cursors, Inter font.

## Install
    ./install.sh dark          # or: light
    ./dock/create-panel.sh     # builds the dock
    ./launcher/add-to-dock.sh  # cube launcher
    sudo ./sddm/install.sh     # optional login screen
    ./verify.sh                # read-only checkup

## Use
    duneglow-mode light | dark | auto | status
    duneglow-wallpaper auto | day | night | own | off | status
    duneglow-background lock|login|desktop|all  FILE | --current | --reset

## Uninstall
    ./uninstall.sh
    sudo ./sddm/uninstall.sh   # if the login screen was installed

## Licence
Code GPL-3.0-or-later (`LICENSE`), artwork CC BY-SA 4.0, Inter SIL OFL. See `LICENSE-ARTWORK.md`.
