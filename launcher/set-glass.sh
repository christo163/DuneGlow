#!/usr/bin/env bash
# Sets how see-through the Duneglow launcher panel is. Usage: ./set-glass.sh 50
# Percent of the approved tint: 100 = approved level, 50 = half as dark, 0 = clear glass. Max 200.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PCT="${1:-}"
case "$PCT" in ''|*[!0-9]*) echo "Usage: $0 <0-200>   e.g. $0 50"; exit 1 ;; esac
[ "$PCT" -le 200 ] || { echo "max 200"; exit 1; }
python3 - "$HERE/org.duneglow.launcher/contents/ui/main.qml" "$PCT" <<'PY'
import re, sys
p, pct = sys.argv[1], int(sys.argv[2]) / 100.0
s = open(p, encoding='utf-8').read()
base = {"0.80, 0.86, 0.95": 0.18, "0.40, 0.46, 0.60": 0.26, "0.20, 0.22, 0.34": 0.42}
n = 0
for rgb, a in base.items():
    s, k = re.subn(r'Qt\.rgba\(' + re.escape(rgb) + r', [0-9.]+\)', 'Qt.rgba(%s, %.3f)' % (rgb, min(1.0, a * pct)), s)
    n += k
if n != 3: sys.exit("Expected 3 glass stops, found %d: file was edited by hand?" % n)
open(p, 'w', encoding='utf-8').write(s)
print("Launcher tint set to %d%% of the approved level." % int(pct * 100))
PY
"$HERE/install.sh"
echo "Restarting the Plasma shell to apply (windows stay open)..."
systemctl --user restart plasma-plasmashell
