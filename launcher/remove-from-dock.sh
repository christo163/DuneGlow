#!/usr/bin/env bash
# Removes the Duneglow Launcher from the dock and puts Kickoff back.
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/../dock/lib.sh"
read -r -d '' JS <<'JSEOF' || true
panels().forEach(function (p) {
    var ov = false, pager = false, l = null;
    p.widgetIds.forEach(function (i) {
        var t = p.widgetById(i).type;
        if (t == "org.duneglow.overview") ov = true;
        if (t == "org.kde.plasma.pager") pager = true;
        if (t == "org.duneglow.launcher") l = i;
    });
    if (ov && !pager && l !== null) { p.widgetById(l).remove(); p.addWidget("org.kde.plasma.kickoff"); print("Kickoff restored."); }
});
JSEOF
plasma_eval "$JS"
