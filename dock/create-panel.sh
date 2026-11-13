#!/usr/bin/env bash
# Creates the Duneglow dock: a NEW floating, centred, icons-only panel at the bottom.
# Your existing panel is left alone (remove it yourself: right-click it > Enter Edit Mode > Remove Panel).
set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"

read -r -d '' JS <<'JSEOF' || true
var ids = ["org.kde.plasma.kickoff", "org.kde.plasma.icontasks", "org.duneglow.overview",
           "org.kde.plasma.weather", "org.kde.plasma.systemtray", "org.kde.plasma.digitalclock"];
// A Duneglow dock = a panel with the Overview button and no Pager (the old Fedora panel has a Pager).
var exists = false;
panels().forEach(function (p) {
    var ov = false, pager = false;
    p.widgetIds.forEach(function (i) {
        var t = p.widgetById(i).type;
        if (t == "org.duneglow.overview") ov = true;
        if (t == "org.kde.plasma.pager") pager = true;
    });
    if (ov && !pager) exists = true;
});
if (exists) { print("Duneglow dock already exists; nothing created."); }
else {
    var p = new Panel;
    p.location = "bottom";
    p.height = 52;
    try { p.alignment = "center"; } catch (e) {}
    try { p.lengthMode = "fit"; } catch (e) {}
    try { p.floating = true; } catch (e) {}
    try { p.hiding = "none"; } catch (e) {}
    ids.forEach(function (id) { try { p.addWidget(id); } catch (e) { print("skipped " + id); } });
    print("Duneglow dock created.");
}
JSEOF

# Weather is optional: skip it if the Weather Report widget is not installed.
if [ ! -d /usr/share/plasma/plasmoids/org.kde.plasma.weather ] && [ ! -d "$HOME/.local/share/plasma/plasmoids/org.kde.plasma.weather" ]; then
  JS="${JS//\"org.kde.plasma.weather\", /}"
  echo "Note: Weather Report widget not found, dock created without it (Fedora: sudo dnf install kdeplasma-addons)."
fi

plasma_eval "$JS"
echo "Done. Pin your apps: right-click an app's icon > Pin to Task Manager."
echo "Remove the dock again with: $(cd "$(dirname "$0")" && pwd)/remove-panel.sh"
