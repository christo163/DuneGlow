#!/usr/bin/env bash
# Restores Fedora's default login screen. Run: sudo ./uninstall.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run as root: sudo $0"; exit 1; }
rm -f /etc/sddm.conf.d/zz-duneglow.conf
rm -rf /usr/share/sddm/themes/duneglow
echo "Duneglow removed. The default login screen returns at your next logout or reboot."
