#!/usr/bin/env bash
# Removes only the Duneglow dock (a panel with the Duneglow Overview widget and no Pager).
set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"
read -r -d '' JS <<'JSEOF' || true
panels().forEach(function (p) {
    var ov = false, pager = false;
    p.widgetIds.forEach(function (i) {
        var t = p.widgetById(i).type;
        if (t == "org.duneglow.overview") ov = true;
        if (t == "org.kde.plasma.pager") pager = true;
    });
    if (ov && !pager) { p.remove(); print("Duneglow dock removed."); }
});
JSEOF
plasma_eval "$JS"
