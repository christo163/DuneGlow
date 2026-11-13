#!/usr/bin/env python3
"""Generates the Duneglow Plasma theme frame SVGs (glass dock/panel + popup, for light text).

Layout copied from the structure of Plasma's own translucent panel frame (numbers read from the user's machine),
artwork is ours:
  svg  (113 + 2c + 32) x 64
  frame : nine cells, origin (0,10): corners c x c, edges 32 long, centre 32 x 32
  mask  : same nine cells (opaque shapes), left column at x=113  -> KWin uses it to shape the blur region
  hints : hint-tile-center, content margins
Plasma picks widgets/, translucent/widgets/ or opaque/widgets/ (same for dialogs/) by opacity setting.

Liquid glass (dock only): the top row (c px) gets a white sheen gradient and a brighter edge line, the bottom row a
warm dune glow. Edges and the centre are tiled by Plasma, so they stay flat (a vertical gradient there would repeat)."""
import os, sys

OY, INNER, MX = 10, 32, 113

DEFS = '''<defs>
    <linearGradient id="sheenT" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFFFFF" stop-opacity="0.22"/><stop offset="1" stop-color="#FFFFFF" stop-opacity="0"/></linearGradient>
    <linearGradient id="glowB" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#F59A4A" stop-opacity="0"/><stop offset="1" stop-color="#F59A4A" stop-opacity="0.26"/></linearGradient>
  </defs>'''

def frame(c, margin, fill_op, edge_op, path, tint="#1F2740", glass=False, top_op=None):
    top_op = edge_op if top_op is None else top_op
    fill = f'fill="{tint}" fill-opacity="{fill_op}" stroke="none"'
    edge = f'fill="none" stroke="#FFFFFF" stroke-opacity="{edge_op}" stroke-width="1"'
    edge_top = f'fill="none" stroke="#FFFFFF" stroke-opacity="{top_op}" stroke-width="1"'
    bar = f'fill="#FFFFFF" fill-opacity="{edge_op}" stroke="none"'
    bar_top = f'fill="#FFFFFF" fill-opacity="{top_op}" stroke="none"'
    r = c - .5
    S = INNER
    gl = lambda shape, grad: (shape + f' fill="url(#{grad})" stroke="none"/>') if glass else ""
    el = []
    g = lambda i, x, y, body: f'<g id="{i}" transform="translate({x},{y})">{body}</g>'
    p_tl = f'M{c},{c} L0,{c} A{c},{c} 0 0 1 {c},0 Z'
    p_tr = f'M0,{c} L0,0 A{c},{c} 0 0 1 {c},{c} Z'
    p_bl = f'M{c},0 L{c},{c} A{c},{c} 0 0 1 0,0 Z'
    p_br = f'M0,0 L{c},0 A{c},{c} 0 0 1 0,{c} Z'
    el.append(g("topleft", 0, OY, f'<path d="{p_tl}" {fill}/>' + gl(f'<path d="{p_tl}"', "sheenT") + f'<path d="M0.5,{c} A{r},{r} 0 0 1 {c},0.5" {edge_top}/>'))
    el.append(g("topright", c+S, OY, f'<path d="{p_tr}" {fill}/>' + gl(f'<path d="{p_tr}"', "sheenT") + f'<path d="M0,0.5 A{r},{r} 0 0 1 {c-.5},{c}" {edge_top}/>'))
    el.append(g("bottomleft", 0, OY+c+S, f'<path d="{p_bl}" {fill}/>' + gl(f'<path d="{p_bl}"', "glowB") + f'<path d="M0.5,0 A{r},{r} 0 0 0 {c},{c-.5}" {edge}/>'))
    el.append(g("bottomright", c+S, OY+c+S, f'<path d="{p_br}" {fill}/>' + gl(f'<path d="{p_br}"', "glowB") + f'<path d="M{c-.5},0 A{r},{r} 0 0 1 0,{c-.5}" {edge}/>'))
    el.append(g("top", c, OY, f'<rect x="0" y="0" width="{S}" height="{c}" {fill}/>' + gl(f'<rect x="0" y="0" width="{S}" height="{c}"', "sheenT") + f'<rect x="0" y="0" width="{S}" height="1" {bar_top}/>'))
    el.append(g("bottom", c, OY+c+S, f'<rect x="0" y="0" width="{S}" height="{c}" {fill}/>' + gl(f'<rect x="0" y="0" width="{S}" height="{c}"', "glowB") + f'<rect x="0" y="{c-1}" width="{S}" height="1" {bar}/>'))
    el.append(g("left", 0, OY+c, f'<rect x="0" y="0" width="{c}" height="{S}" {fill}/><rect x="0" y="0" width="1" height="{S}" {bar}/>'))
    el.append(g("right", c+S, OY+c, f'<rect x="0" y="0" width="{c}" height="{S}" {fill}/><rect x="{c-1}" y="0" width="1" height="{S}" {bar}/>'))
    el.append(g("center", c, OY+c, f'<rect x="0" y="0" width="{S}" height="{S}" {fill}/>'))

    # blur mask, same cells, left column at x = MX
    m = 'fill="#000000" stroke="none"'
    mx0, mx1, mx2 = MX, MX + c, MX + c + S
    el.append(f'<path id="mask-topleft" transform="translate({mx0},{OY})" d="{p_tl}" {m}/>')
    el.append(f'<path id="mask-topright" transform="translate({mx2},{OY})" d="{p_tr}" {m}/>')
    el.append(f'<path id="mask-bottomleft" transform="translate({mx0},{OY+c+S})" d="{p_bl}" {m}/>')
    el.append(f'<path id="mask-bottomright" transform="translate({mx2},{OY+c+S})" d="{p_br}" {m}/>')
    el.append(f'<rect id="mask-top" x="{mx1}" y="{OY}" width="{S}" height="{c}" {m}/>')
    el.append(f'<rect id="mask-bottom" x="{mx1}" y="{OY+c+S}" width="{S}" height="{c}" {m}/>')
    el.append(f'<rect id="mask-left" x="{mx0}" y="{OY+c}" width="{c}" height="{S}" {m}/>')
    el.append(f'<rect id="mask-right" x="{mx2}" y="{OY+c}" width="{c}" height="{S}" {m}/>')
    el.append(f'<rect id="mask-center" x="{mx1}" y="{OY+c}" width="{S}" height="{S}" {m}/>')

    # hints: tile centre, content margins (rect sizes carry the values)
    T = 2 * c + S
    h = lambda i, x, y, w, hh: f'<rect id="{i}" x="{x}" y="{y}" width="{w}" height="{hh}" fill="none"/>'
    el.append(h("hint-tile-center", 0, 0, 5, 5))
    el.append(h("hint-top-margin", 20, OY, 4, margin))
    el.append(h("hint-bottom-margin", 20, OY + T - margin, 4, margin))
    el.append(h("hint-left-margin", 0, OY + c + 4, margin, 4))
    el.append(h("hint-right-margin", T - margin, OY + c + 4, margin, 4))
    w = MX + T
    svg = (f'<?xml version="1.0" encoding="UTF-8"?>\n'
           f'<!-- Duneglow glass frame. CC BY-SA 4.0. Generated by tools/make_theme.py -->\n'
           f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="64" viewBox="0 0 {w} 64">\n  '
           + (DEFS + "\n  " if glass else "") + "\n  ".join(el) + "\n</svg>\n")
    open(path, "w").write(svg)

root = sys.argv[1] if len(sys.argv) > 1 else "dock/theme/Duneglow"
# Dock/panel tint opacity in percent: 3rd argument, default 16 (lower = more transparent). Popups are left readable.
PANEL_PCT = max(5, min(95, int(sys.argv[2]))) if len(sys.argv) > 2 else 16
# 3rd argument "light": cream glass for the light Plasma theme (needs a bit more tint to stay visible on a light picture).
LIGHT = len(sys.argv) > 3 and sys.argv[3] == "light"
if LIGHT: PANEL_PCT = min(95, round(PANEL_PCT * 1.75))
PANEL_TINT = "#F4F2EC" if LIGHT else "#33405E"
DIALOG_TINT = "#F1EEE6" if LIGHT else "#1F2740"
PANEL = {"widgets": PANEL_PCT / 100, "translucent/widgets": PANEL_PCT / 100, "opaque/widgets": 0.96}
DIALOG = {"dialogs": 0.90, "translucent/dialogs": 0.90, "opaque/dialogs": 0.97, "solid/dialogs": 0.97}
for d, op in PANEL.items():
    os.makedirs(f"{root}/{d}", exist_ok=True)
    frame(6, 6, op, 0.30, f"{root}/{d}/panel-background.svg", tint=PANEL_TINT, glass=True, top_op=0.55)
for d, op in DIALOG.items():
    os.makedirs(f"{root}/{d}", exist_ok=True)
    frame(12, 10, op, 0.25, f"{root}/{d}/background.svg", tint=DIALOG_TINT)
print("theme frames written to", root)
