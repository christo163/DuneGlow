#!/usr/bin/env bash
# Duneglow checkup (read-only). Prints OK / MISSING for each part. Changes nothing.
# Usage: ./verify.sh
H="$HOME"; P="$H/.local/share"; pass=0; fail=0
chk() {  # label, command...
  local label="$1"; shift
  if "$@" >/dev/null 2>&1; then printf "  [OK]      %s\n" "$label"; pass=$((pass+1)); else printf "  [MISSING] %s\n" "$label"; fail=$((fail+1)); fi
}
val() { kreadconfig6 --file "$1" --group "$2" --key "$3" 2>/dev/null; }
is()  { [ "$(val "$1" "$2" "$3")" = "$4" ]; }
has() { [ "$(val "$1" "$2" "$3")" != "" ] && case "$(val "$1" "$2" "$3")" in *"$4"*) true;; *) false;; esac; }
cnt() { [ "$(ls "$1" 2>/dev/null | wc -l)" -ge "$2" ]; }

echo "Step 1  Login screen (SDDM)"
chk "theme installed" test -f /usr/share/sddm/themes/duneglow/Main.qml
chk "theme selected"  grep -q duneglow /etc/sddm.conf.d/zz-duneglow.conf
echo "Step 2  Splash"
chk "Look and Feel package"   test -d "$P/plasma/look-and-feel/org.duneglow.desktop"
chk "splash selected"         is ksplashrc KSplash Theme org.duneglow.desktop
echo "Step 3  Desktop wallpaper and clock"
chk "wallpapers"              test -d "$P/wallpapers/Duneglow"
chk "wallpaper switcher"      test -x "$H/.local/bin/duneglow-wallpaper"
chk "wallpaper timer running" systemctl --user is-active --quiet duneglow-wallpaper.timer
chk "clock widget"            test -d "$P/plasma/plasmoids/org.duneglow.clock"
echo "Step 4  Dock and Plasma theme"
chk "Overview widget"         test -d "$P/plasma/plasmoids/org.duneglow.overview"
chk "Plasma theme (dark)"     test -d "$P/plasma/desktoptheme/Duneglow"
chk "Plasma theme (light)"    test -d "$P/plasma/desktoptheme/Duneglow-Light"
chk "Plasma style in use is a Duneglow one" has plasmarc Theme name Duneglow
chk "dock contains the launcher" grep -q org.duneglow.launcher "$H/.config/plasma-org.kde.plasma.desktop-appletsrc"
echo "Step 5  Launcher"
chk "launcher widget"         test -d "$P/plasma/plasmoids/org.duneglow.launcher"
chk "background command"      test -x "$H/.local/bin/duneglow-background"
echo "Step 6  System look"
chk "colour schemes"          test -f "$P/color-schemes/DuneglowDark.colors" -a -f "$P/color-schemes/DuneglowLight.colors"
chk "colour scheme in use"    has kdeglobals General ColorScheme Duneglow
chk "Kvantum themes"          test -f "$H/.config/Kvantum/Duneglow-Dark/Duneglow-Dark.kvconfig" -a -f "$H/.config/Kvantum/Duneglow-Light/Duneglow-Light.kvconfig"
chk "app style = kvantum"     is kdeglobals KDE widgetStyle kvantum
chk "icon themes"             test -d "$P/icons/Duneglow-Dark" -a -d "$P/icons/Duneglow-Light"
chk "icon theme in use"       has kdeglobals Icons Theme Duneglow
chk "glass folders (dark)"    test -f "$P/icons/Duneglow-Dark/places/64/folder.svg"
chk "glass app tiles"         cnt "$P/icons/Duneglow-Dark/glass/apps" 5
chk "title bar themes"        test -d "$P/aurorae/themes/Duneglow-Dark" -a -d "$P/aurorae/themes/Duneglow-Light"
chk "title bar in use"        has kwinrc org.kde.kdecoration2 theme Duneglow
chk "cursor = Sweet"          is kcminputrc Mouse cursorTheme Sweet-cursors
echo "Step 7  Dolphin"
chk "icon size set"           test -n "$(val dolphinrc IconsMode IconSize)"
echo "Step 8  Light/dark switch"
chk "duneglow-mode installed" test -x "$H/.local/bin/duneglow-mode"
chk "mode timer running"      systemctl --user is-active --quiet duneglow-mode.timer
[ -x "$H/.local/bin/duneglow-mode" ] && echo "         now: $("$H/.local/bin/duneglow-mode" status)"
echo
echo "Result: $pass OK, $fail missing."
echo "Items for the mode you are not using can show as missing or 'not in use'; that is normal."
