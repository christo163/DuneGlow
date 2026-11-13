#!/usr/bin/env bash
# Replaces the Kickoff button in the Duneglow dock with the Duneglow Launcher (same place, first position).
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/../dock/lib.sh"
read -r -d '' JS <<'JSEOF' || true
panels().forEach(function (p) {
    var ov = false, pager = false, kick = null;
    p.widgetIds.forEach(function (i) {
        var t = p.widgetById(i).type;
        if (t == "org.duneglow.overview") ov = true;
        if (t == "org.kde.plasma.pager") pager = true;
        if (t == "org.kde.plasma.kickoff") kick = i;
    });
    if (ov && !pager) {
        if (kick !== null) { p.widgetById(kick).remove(); }
        p.addWidget("org.duneglow.launcher");
        print("Launcher added to the dock (it may appear at the end; drag it in Edit Mode if you like).");
    }
});
JSEOF
plasma_eval "$JS"
