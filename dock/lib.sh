# Shared helper: run a Plasma shell script via D-Bus. Uses gdbus (always present on Fedora),
# falls back to qdbus6 / qdbus-qt6.
plasma_eval() {
  local js="$1"
  if command -v gdbus >/dev/null; then
    gdbus call --session --dest org.kde.plasmashell --object-path /PlasmaShell \
      --method org.kde.PlasmaShell.evaluateScript "$js"
  elif command -v qdbus6 >/dev/null; then
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$js"
  elif command -v qdbus-qt6 >/dev/null; then
    qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$js"
  else
    echo "No D-Bus tool found (need gdbus, from the glib2 package)."; return 1
  fi
}
