# Duneglow handover (read this first in a new chat)

## What this project is
A custom desktop theme called **Duneglow** for the user's own computer: **Fedora Linux 44, KDE Plasma 6.7.5, SDDM**, a real machine (not a VM). Original design (not a macOS clone, no copied artwork). Layout and mood follow a concept video the user likes ("DreamOS 2025 concept"): frosted glass panels, warm orange dunes and slate mountains, a big clock, a floating dock, a launcher "home screen", a tabbed file manager, light and dark modes. Work is done one step at a time; the user tests each step on their machine and reports back with pasted terminal output and screenshots.

## User preferences and decisions (keep following these)
- Name: **Duneglow**. Licenses: code GPL-3.0-or-later, artwork CC BY-SA 4.0. Inter font under SIL OFL.
- **Original artwork only.** Do not copy the video's logo or wallpapers, Basic Apple Guy's "Edna / Rancho Cucamonga" wallpaper (personal-use only), or any brand logos. Users may add their own background locally (`sddm/set-background.sh`, `desktop`: `duneglow-wallpaper off`); it is never shipped.
- **Logo: cube** (`assets/step0/logos/dream-logo-d-cube.svg/.png`, made by `tools/make_logo.py`). May ask for tweaks later.
- **Clock colour = a mountain shade**: day `#7F95AE`, night `#7C93B8`.
- **Look:** real glass (background blur), tint, 1px edge light, soft shadow. Buttons: style A "pearl glass" (round, white icons, **no black**; a dark/3D dome style was rejected).
- **Light/dark modes:** auto (dark 18:00-05:59), manual toggle, `theme.conf` `mode=auto|light|dark`.
- **Working style:** short, direct answers; exact terminal commands with full paths; one step at a time. The user often cannot judge technical questions ("I don't know") and sends small screenshots, so give simple yes/no questions and read-only diagnostic commands, and ask for full-width screenshots over the bare wallpaper. Do not ask the user to guess.
- Every deliverable is a full project zip (`duneglow-project-*.zip`) plus the exact unzip/install commands.

## Status
| Step | What | Status |
|---|---|---|
| 0 | Foundations: palettes, tokens, original wallpapers, logo options | Done |
| 1 | SDDM login theme | Done, user confirmed (preview and real login). `sudo ./install.sh` in `sddm/` |
| 2 | Cube logo + post-login splash (Look and Feel package `org.duneglow.desktop`) | Done, user confirmed |
| 2b | Lock screen | **Dropped by the user.** Custom lock screen removed; only a custom lock *picture* on Plasma's own lock screen (`duneglow-background lock`) |
| 3 | Desktop: day/night wallpaper switcher + clock widget | Done, user confirmed. Desktop icons moved to Step 6 |
| 4 | Floating dock + glass Plasma theme + Overview widget | **Done, user confirmed** (clean dark glass dock, tint 35%) |
| 5 | Home screen launcher: centred liquid-glass panel, search, Recent, apps by category, lock/log out/restart/shut down buttons; dock restyled to the same glass | **Done, user confirmed** (`launcher/`, `./install.sh`, `./add-to-dock.sh`) |
| 6 | System-wide look | **Mostly done** (see Step 6 notes). Open: desktop icons, confirm Home/Desktop folder icons are orange |
| 7 | File manager styling (Dolphin) | In progress: 7a layout script sent (not reported), 7b glass app icons + 7c glass folders **confirmed** |
| 8 | One switch for light/dark | 8a `mode/` (duneglow-mode light/dark/auto + timer) **confirmed working**; 8b light dock/popups (Plasma theme `Duneglow-Light`, `dock/install-light.sh`) + light launcher (reads `~/.cache/duneglow/mode-state`) **sent, not yet reported** |
| 9 | App support | In progress: `apps/install.sh` = Bottles as a user Flatpak + Flatpak overrides (sent). Discover/Flatpak/Flathub already work on the user's machine. Waydroid deliberately skipped (system-level, risky) unless the user asks |
| 10 | One installer, uninstaller, packaging (GitHub, KDE Store, Copr) | Not started |
Optional, last: Plymouth boot splash (rebuilds the initramfs, higher risk).

## Files
```
HANDOVER.md                      this file
DESIGN-NOTES.md                  design rules
tools/make_step0.py              logos A-C, wallpapers, tokens
tools/make_logo.py               cube logo
tools/make_theme.py              Plasma theme frames: make_theme.py <dir> <panel-tint-percent>
assets/step0/                    logos, wallpapers (SVG + 4K PNG), tokens/dream-tokens.json
sddm/duneglow/                   SDDM theme (Main.qml, GlassPanel.qml, Frost.qml, OrbButton.qml, Avatar.qml, theme.conf, assets, fonts)
sddm/                            install.sh uninstall.sh test.sh set-background.sh set-mode.sh
plasma/org.duneglow.desktop/     Look and Feel package (splash)
plasma/                          org.duneglow.desktop (splash), install.sh uninstall.sh test-splash.sh
desktop/                         wallpapers/Duneglow (day+night), duneglow-wallpaper, systemd/ (user timer), org.duneglow.clock (plasmoid), install.sh, uninstall.sh
dock/                            theme/Duneglow (Plasma theme), org.duneglow.overview (plasmoid), lib.sh, create-panel.sh, remove-panel.sh, set-transparency.sh, install.sh, uninstall.sh
launcher/                        org.duneglow.launcher (plasmoid: cube button + DashboardWindow panel), install.sh uninstall.sh test.sh add-to-dock.sh remove-from-dock.sh
previews/                        design mockups (not real screenshots)
```

## How the user runs things
Unzip into `~/Downloads` (creates/updates `~/Downloads/duneglow-project`), then per step:
```
cd ~/Downloads/duneglow-project/sddm    && chmod +x *.sh && ./test.sh --light   # preview login
cd ~/Downloads/duneglow-project/sddm    && sudo ./install.sh                     # real login theme
cd ~/Downloads/duneglow-project/plasma  && chmod +x *.sh && ./install.sh && ./test-splash.sh
cd ~/Downloads/duneglow-project/desktop && chmod +x *.sh duneglow-wallpaper && ./install.sh
cd ~/Downloads/duneglow-project/dock    && chmod +x *.sh && ./install.sh && systemctl --user restart plasma-plasmashell && ./create-panel.sh
~/Downloads/duneglow-project/dock/set-transparency.sh 35     # 5-95, lower = more see-through
```
Plasma needs `systemctl --user restart plasma-plasmashell` once before a NEW plasmoid appears (user confirmed for clock and overview). Undo scripts: each folder has `uninstall.sh` (dock: `remove-panel.sh` removes only the dock, `uninstall.sh` also restores the previous Plasma theme). Login recovery: `Ctrl+Alt+F3`, log in, `sudo rm -f /etc/sddm.conf.d/zz-duneglow.conf && sudo systemctl restart sddm`.

## State on the user's machine (as of the end of this chat)
- Installed (all per-user under `~/.local`, plus SDDM theme system-wide): SDDM theme; Look and Feel `org.duneglow.desktop` (splash set in `ksplashrc`); wallpapers `Duneglow`; `~/.local/bin/duneglow-wallpaper` + user timer `duneglow-wallpaper.timer`; plasmoids `org.duneglow.clock` and `org.duneglow.overview`; Plasma theme `Duneglow` (current Plasma Style).
- The user's panels: the Duneglow dock (floating, centred, bottom, height 52: kickoff, icon tasks, Overview, system tray, digital clock) and the old Fedora panel was removed by the user. Weather widget is NOT in the dock (needs `sudo dnf install kdeplasma-addons`, then add it by hand or re-run create-panel after removing the dock).
- The user's own Look and Feel is a personal package called "Edna". Colour scheme has light text. Opera, Firefox, Chrome, terminal etc. are pinned by the user.
- Project zip downloads and `~/Downloads/duneglow-project` can be kept; the install scripts live there (the uninstall scripts need it).

## Plasma 6.7 / Fedora 44 lessons learned (verified on the user's machine unless noted)
- **No `qdbus6` on Fedora.** Use `gdbus` (`dock/lib.sh` has `plasma_eval`). Panel scripting through `org.kde.PlasmaShell.evaluateScript` works; `floating`, `lengthMode`, `alignment` are accepted.
- **Plasma theme frames** (`dock/theme/Duneglow`): Plasma picks `widgets/`, `translucent/widgets/`, `opaque/widgets/` (panel-background.svg) and `dialogs/`, `translucent/dialogs/`, `opaque/dialogs/`, `solid/dialogs/` (background.svg) by the panel opacity setting, so every variant must exist. The frame must copy the default theme's structure: 157x64 svg, nine cells with origin (0,10), 6px corners, 32px edge pieces, `mask-*` cells at x=113 (KWin uses them to shape the blur; without them the blur is a rectangle), `hint-tile-center`, groups positioned with `translate(...)`. Do **not** add `hint-stretch-borders` (it brought back crimson untinted corner patches). Draw edge highlights as solid 1px rects, not stroked lines (stroked lines left tick marks at tile seams). Light glass over a light-text colour scheme was unreadable, so the dock is dark slate (`#1F2740`) at 35%. Corner radius is 6px; rounding further must be done step by step and checked.
- Tools in the sandbox: `rsvg-convert --export-id` can slice and recompose a frame to check it; no Qt/QML runtime, so QML is untested until the user runs it.
- Sandbox network allowlist blocks most sites; KDE source pages work through WebSearch/WebFetch only sometimes (lxr.kde.org and invent.kde.org MRs worked, sources.debian.org did not).

## Step 5 lessons (verified on the user's machine)
- `org.kde.plasma.kickerdash` has only metadata.json; its QML is compiled into the plugin, so it cannot be restyled. We built our own plasmoid on `org.kde.plasma.private.kicker` (AppsModel, RecentUsageModel, RunnerModel, DashboardWindow; types read from `kickerplugin.qmltypes`).
- Enum properties need the names (`Kicker.RecentUsageModel.OnlyApps`, `.Recent`), not numbers. `RunnerModel` has no `labelForRow`; use the child model's `description`.
- `compactRepresentation` AND `fullRepresentation` must both be set (the same Component) or `plasmawindowed` shows an empty window.
- `MultiEffect` needs `autoPaddingEnabled: false` when masked, or the blurred layer grows ~50px past the panel.
- The widget inside the dock runs in plasmashell: after `./install.sh` run `systemctl --user restart plasma-plasmashell` or the old code stays. `./test.sh` (plasmawindowed) always runs the newest files.
- Plasma theme needs its own `colors` file (white text on dark) or panel text follows the system scheme and becomes unreadable on a light scheme.
- Power buttons use `gdbus ... org.kde.LogoutPrompt` (KDE confirmation) and `loginctl lock-session`, run through the plasma5support `executable` engine.
- **The approved glass level** (user: "perfect", dock must match): launcher panel gradient alpha 0.10 / 0.14 / 0.26 (light slate) over a blurred copy of the Duneglow wallpaper; dock tint `#33405E` at 16% (`make_theme.py` default, `dock/set-transparency.sh 16`). Launcher blur is a fake (wallpaper copy), only matches while the Duneglow wallpaper is in use.
- Dock frames are tiled, so only the top/bottom 6px rows carry the sheen and warm glow.

## Step 6 notes (system-wide look)
User asked for **see-through (liquid glass) windows**; confirmed working: Dolphin body, title bar, dock, launcher ("perfect").
| Part | Folder | How | Status |
|---|---|---|---|
| 6a Colours | `colors/` | `tools/make_colors.py` -> DuneglowLight/Dark `.colors`; `apply.sh light\|dark` (plasma-apply-colorscheme) | applied |
| 6b App style | `kvantum/` | Kvantum (already installed). `install.sh` derives `Duneglow-Dark` from the user's `~/.config/Kvantum/Qogir-dark` (sed colour swaps, translucent_windows/blurring on, `reduce_window_opacity=35`), `make_light.py` derives `Duneglow-Light` from Qogir-light by rule; `selection.py` makes selected items slate glass (#6A88B8 @0.55) because ember-on-ember folders vanished; `glass.sh N` (0-90) sets see-through level; `apply.sh light\|dark`. widgetStyle=kvantum | dark confirmed; light confirmed readable |
| 6c Icons | `icons/` | `make_icons.py` builds `Duneglow-Dark/-Light` inheriting Fluent-dark/-light. Overrides only folder icons | confirmed orange (Home/Desktop fix sent, not yet reported) |
| 6d Title bars | `deco/` | Aurorae: `make_deco.py` derives `Duneglow-Dark/-Light` from Qogir-dark/-light (body fills alpha 0.55/0.62, navy/cream, text colours). `apply.sh` sets kwinrc `library=org.kde.kwin.aurorae`, `theme=__aurorae__svg__Duneglow-X` | user: "perfect" |
| 6e Cursors | `cursors/` | uses installed `Sweet-cursors` (user's choice), `install.sh [size]` | sent, not yet reported |
Transparency knobs: Kvantum `kvantum/glass.sh N`; title bar `ALPHA` in `deco/make_deco.py`; dock `dock/set-transparency.sh N` (5-95, approved 16); launcher `launcher/set-glass.sh N` (percent of approved level, 0-200).
Lessons (verified on the user's machine):
- Fluent only has small folder icons (16/22/24). The big ones in Dolphin come from **Breeze** (`/usr/share/icons/breeze/places/<size>/`, sizes 16,22,24,32,48,64,96). Dolphin asks for `inode-directory`, not `folder`, so both names must be overridden.
- Fluent's `folder.svg` -> `default-folder.svg` has an **embedded base64 PNG** body; hex recolouring cannot touch it. Those files are skipped; Breeze versions are used instead.
- Breeze 6 folders are coloured by `.ColorScheme-Accent` (older: `ColorScheme-Highlight`). KDE rewrites the stylesheet with `id="current-color-scheme"` at draw time, so the class is renamed `DuneglowEmber` and an extra `<style>` (no id) defines it. Size ranges: 48/64/96 dirs are `Type=Scalable` with Min/Max so Fluent's scalable folder cannot win at 128/256.
- Fluent's `folder-publicshare` is a broadcast glyph; skipped (names containing "public").
- `rm -f ~/.cache/icon-cache.kcache` then restart the app after icon changes.
- Aurorae `decoration.svg` body fills are solid `#282a33/#32343d`; KWin blurs behind the translucent title bar (confirmed).
- No light/dark one-switch yet: apply `colors/`, `kvantum/`, `icons/`, `deco/` `apply.sh light|dark` together (Step 8 will combine them with the Plasma theme/dock).
- Known leftovers: Qogir link colour maps to ember in light; Fluent bitmap icons other than folders keep their colours.
Step 6 is **done**: the user's desktop has no icons (desktop icons skipped); Home/Desktop folder icons confirmed orange; the top bar on the user's desktop is theirs (leave it, style in Step 8). Cursor: Sweet-cursors via `cursors/install.sh [size]` (sent, size not reported).

## Step 7 notes (Dolphin, glass icons)
- `dolphin/install.sh [size]` / `uninstall.sh`: dolphinrc IconSize/PreviewSize, RememberOpenedTabs, OpenExternallyCalledFolderInNewTab; backup in `~/.cache/duneglow/dolphinrc.backup`. Dolphin is 26.08.2. User has not reported the result yet.
- **Glass app icons** (`icons/glass-apps.sh on|off`, `make_glass_apps.py`): for every `Icon=` in .desktop files, writes a wrapped scalable SVG (glass tile + original icon, inner icon 88/128) into `Duneglow-*/glass/apps` (index.theme gets `glass/apps` Scalable dir). **Plasma's SVG renderer ignores `clip-path`**: the first version drew a square box behind each tile (sheen/glow spilling out). Never use clipPath in our icons; use shapes that already fit. Re-run `glass-apps.sh on` after every `icons/install.sh`. Dock icons are only as big as the dock: `dock/set-height.sh N` (40-96, panels with location 'bottom' only; the user's own top bar is untouched; user used 68).
- **Glass folders** (`icons/glass-folder/folder_glass.py`, original artwork, 3 variants A amber / B clear frost / C deep ember): user chose **B for dark, A for light**. `make_icons.py` writes them for `folder`, `inode-directory`, `user-home`, `user-desktop` and the XDG special folders (GLASS_NAMES); the Breeze symbol = every shape in the special folder SVG whose `d` is not one of the plain folder.svg's shapes (class renamed `DuneglowGlyph`, forced white), placed with `translate(6.4 12.6) scale(1.8*64/viewBox)`. If a special folder has more than 8 leftover shapes (different body) it falls back to the older ember recolour. User confirmed "good".
- Preview images: render SVGs with `rsvg-convert` in the sandbox, but remember rsvg honours clipPath and Plasma does not.


## Honest limits and open items
- **None of the QML has been executed by the assistant.** The user's runs are the only test. `previews/` are HTML mockups.
- Glass blur in QML uses `QtQuick.Effects` (Qt 6.5+) in `Frost.qml` with a tinted fallback. The dock's blur depends on KWin's Blur effect being on (user never confirmed; the dock works either way).
- Lexend font not available in the sandbox; clock uses Inter Display Bold (`theme.conf` `clockFontFile` can point to `fonts/Lexend-Bold.ttf`).
- Wallpapers are flat vector scenes; the reference is hazier and more painterly. Could be softened later.
- Login theme: no user switcher or session picker; the on-screen light/dark toggle does not persist (use `sddm/set-mode.sh`).
- Dock: corners 6px (video has a rounder pill); no weather widget unless `kdeplasma-addons` is installed; Overview button: whether it opens Overview was never reported.
- Wallpaper switcher overrides manual wallpaper changes at the next 06:00/18:00 switch in `auto` mode (`duneglow-wallpaper off` stops it).

## (Done) Step 5 notes, kept for reference
- Goal (from the video): full-screen frosted glass launcher: search box on top, grouped app grid, recent list, big clock optional, opened from the dock's first button.
- Ask the user at the start (AskUserQuestion) whether to base it on a restyled **Kicker Dashboard** (`org.kde.plasma.kickerdash`, KDE's existing full-screen launcher, uses the Plasma app models and survives updates) or a fully custom QML plasmoid/app. Recommended: restyle/derive from the dashboard, because app models, search (KRunner) and recents come for free. Check the exact module names on the user's Plasma 6.7 (read-only commands: `ls /usr/share/plasma/plasmoids | grep -i kicker`, then ask the user to paste a few lines of its `main.qml`) before writing code, as the lock screen showed that 6.7 differs from the docs.
- Fonts: Inter (Regular/SemiBold, InterDisplay-Bold) are in `sddm/duneglow/fonts`. Glass look: reuse `GlassPanel.qml`/`Frost.qml` ideas and the dock's dark slate tint for readability.
- Deliver as `launcher/` with install.sh/uninstall.sh and an undo, per-user only, no system files.

## Starter message for the new chat
> I'm continuing a Duneglow desktop theme project for Fedora 44 / KDE Plasma 6.7.5. I've attached `duneglow-project-final.zip` and HANDOVER.md. Please read HANDOVER.md and DESIGN-NOTES.md first. Steps 0 to 4 are done and confirmed working (login theme, splash, lock screen preview, desktop wallpaper + clock, floating glass dock). Steps 0 to 5 are done. Start Step 6, the system-wide look (colours, window decorations, icons, cursors, desktop icons). Follow the working style in the handover: short answers, exact commands, simple questions, read-only diagnostics before guessing.


## Round of fixes after the user's full review (2026-11-13)
User feedback per step -> what was done (all sent in `duneglow-project-fixes2.zip`, NOT yet confirmed by the user):
- **Login avatar** was a square photo on a round background: `sddm/duneglow/Avatar.qml` now masks the photo to a circle (MultiEffect, same pattern as the launcher). Own login background: `sudo sddm/set-background.sh /path.jpg`, new `--current` = use the desktop wallpaper, `--reset` = built-in.
- **Splash**: the cube now spins (`tools/make_cube_spin.py` renders 48 frames of a 3D cube over 180 degrees, opposite faces share a colour so it loops; sprite sheet `plasma/org.duneglow.desktop/contents/splash/images/cube-spin.png`, 1792x1344, played by `AnimatedSprite`). The Duneglow wallpaper was removed from the splash (plain gradient) because it clashed with the user's own wallpaper right after. Untested QML.
- **Own wallpaper**: `duneglow-wallpaper own|off` (never touch it; `duneglow-mode` already respects `mode=off`), `set-day FILE`, `set-night FILE`, `reset-pictures`. Config keys `day=`/`night=` live in `~/.config/duneglow/desktop.conf`; copies in `~/.local/share/duneglow/wallpapers/`.
- **Launcher**: the blurred copy of the Duneglow wallpaper inside the panel is gone (it did not fit the user's own wallpaper); the panel is plain glass over the live desktop. Tint raised because nothing blurred sits behind it (dark stops 0.18/0.26/0.42, light 0.50/0.46/0.52; `launcher/set-glass.sh` base values updated). **Live blur is NOT achieved**: Kicker.DashboardWindow gives no blur; if the user wants it, try `PlasmaCore.Dialog` with a Duneglow Plasma-theme frame (KWin blurs behind theme frames via the mask cells) at the cost of coupling to popup transparency. Ask the user whether the see-through part looks sharp or blurred.
- **Launcher cube**: `launcher/add-to-dock.sh` adds it at the END of the dock (small orange cube right of the Overview dots), which is why the user could not find it. The user's own top bar has a blue Windows-style kickoff button, not ours.
- **Light-mode app tiles**: `icons/make_glass_apps.py` now writes a brighter cream tile into Duneglow-Light (the dark-tinted one looked muddy on the light dock).
- User said steps 6 and 7 need "No change"; 8b screenshot looked good (light dock with tiles).

## Round 3 (2026-11-13): launcher transition + custom backgrounds (sent as `duneglow-project-fixes3.zip`, not yet confirmed)
- **Launcher transition**: `main.qml` has `reveal` (0..1) driving the panel's opacity, scale (0.94->1) and a 26 px rise; open 320 ms OutCubic, close 200 ms InCubic then `home.visible = false` (all former `home.visible = false` calls go through `root.closeHome()`). Window itself still appears instantly (DashboardWindow); only the panel animates.
- **`duneglow-background`** (`backgrounds/`, installed to `~/.local/bin`): `lock|login|desktop|all  FILE | --current | --reset`.
  - lock: copies the picture to `~/.local/share/duneglow/backgrounds/lock.<ext>` and sets Plasma's own lock screen picture via `kscreenlockerrc` (`[Greeter] WallpaperPlugin=org.kde.image`, `[Greeter][Wallpaper][org.kde.image][General] Image=`).
  - login: uses a copy of `sddm/set-background.sh` (`~/.local/share/duneglow/set-login-background.sh`) through sudo.
  - desktop: `duneglow-wallpaper set-day/set-night`.
- The lock screen is Plasma's own; Duneglow does not replace it (user decision, Step 10).


## Step 10 (done): packaging
- Top level: `install.sh [dark|light]`, `uninstall.sh`, `verify.sh`, `package.sh [--bundle]`, `LICENSE`, `README.md`. Login screen stays separate (`sudo sddm/install.sh`).
- Removed: custom lock screen (`plasma/org.duneglow.shell`, `plasma/lock.sh`), Bottles (`apps/`), `previews/`.
- Still open for a public release: Kvantum/Aurorae themes are built from the user's Qogir themes and icons need Fluent + Breeze; `package.sh --bundle` is meant to vendor prebuilt copies. Live blur behind the launcher is not done.
