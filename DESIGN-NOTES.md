# Duneglow design notes

## Rules decided so far
- **Clock colour = a mountain shade.** Day: `#7F95AE` (mid ridge of the day wallpaper). Night: `#7C93B8`
  (slate, the night mountain hue lightened for contrast). Over a user's own picture the clock turns near-white.
  Source of truth: `assets/step0/tokens/dream-tokens.json` (`day.clock`, `night.clock`).
- **Login is two stages.** Landing = clock, date, user pill at bottom centre. Clicking the pill or pressing
  any key opens the password card. Esc or a click on the background returns to the landing screen.
- **Glass look.** Real background blur (Qt 6.5+ `MultiEffect`), a light tint, a 1px edge light, a top sheen and a
  soft shadow. If blur is unavailable the panels fall back to a plain tinted look.
- **Day/night.** Night wallpaper and palette from 18:00 to 05:59.
- **Logo: cube (option D, original).** Closed isometric cube: cream top, ember left, slate-to-plum right. Made by `tools/make_logo.py`. The user may want tweaks later.
- **Buttons: style A (pearl glass).** Same frosted material as the pill and card, white icons, no black.
- **Wallpapers are original.** Users can add their own picture locally (`set-background.sh`); it is never shipped.
- **Licences.** Code GPL-3.0-or-later. Artwork CC BY-SA 4.0. Inter font under the SIL OFL.

## Open items
- Lexend for the clock (could not be downloaded in the build environment; Inter Display Bold is used).
- Wallpaper softness: the reference is hazier and more painterly than the flat vector scenes.
- User switcher and session picker.
