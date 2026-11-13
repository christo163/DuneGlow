#!/usr/bin/env python3
"""Duneglow Kvantum Light, derived from Qogir-light (GPL-3.0). Rule-based recolour, no exact colour table.
Usage: make_light.py <Qogir-light dir> <Duneglow-Light dir>"""
import re, sys, os, colorsys, shutil
src, dst = map(os.path.expanduser, sys.argv[1:3])
HEX = re.compile(r'#([0-9a-fA-F]{6})([0-9a-fA-F]{2})?\b')   # optional alpha suffix is kept
EMBER = '#E8873A'
def mapc(m):
    out = mapc6(m)
    return out + (m.group(2) or '') if out != m.group(0) or not m.group(2) else m.group(0)
def mapc6(m):
    r,g,b = [int(m.group(1)[i:i+2],16)/255 for i in (0,2,4)]
    h,l,s = colorsys.rgb_to_hls(r,g,b)
    if s >= 0.25 and 170/360 <= h <= 270/360:            # saturated blue/teal accent -> ember
        return EMBER
    if s < 0.25:                                           # neutrals
        if l >= 0.97 or l <= 0.03: return '#'+m.group(1)        # keep pure white / black (highlights, shadows)
        if l >= 0.5:                                        # light greys -> warm cream (#E8E5DC family)
            r2,g2,b2 = colorsys.hls_to_rgb(42/360, l, 0.18)
        else:                                               # dark greys -> slate ink (#262B33 family)
            r2,g2,b2 = colorsys.hls_to_rgb(215/360, l, 0.15)
        return '#%02x%02x%02x' % (round(r2*255),round(g2*255),round(b2*255))
    return '#'+m.group(1)
def conv(t): return HEX.sub(mapc, t)
rules = [
 (r'^window\.color=.*', 'window.color=#E8E5DCcc'),
 (r'^base\.color=.*', 'base.color=#F4F2EC'),
 (r'^alt\.base\.color=.*', 'alt.base.color=#ECE9E0'),
 (r'^button\.color=.*', 'button.color=#F1EEE6'),
 (r'^(text|window\.text|button\.text)\.color=.*', r'\1.color=#262B33'),
 (r'^highlight\.text\.color=.*', 'highlight.text.color=#262B33'),
 (r'^progress\.indicator\.text\.color=.*', 'progress.indicator.text.color=#262B33'),
 (r'^reduce_window_opacity=.*', 'reduce_window_opacity=35'),
 (r'^reduce_menu_opacity=.*', 'reduce_menu_opacity=30'),
 (r'^menu_blur_radius=.*', 'menu_blur_radius=10'),
 (r'^tooltip_blur_radius=.*', 'tooltip_blur_radius=6'),
]
kv = [f for f in os.listdir(src) if f.endswith('.kvconfig')][0]
sv = [f for f in os.listdir(src) if f.endswith('.svg')][0]
shutil.rmtree(dst, ignore_errors=True); os.makedirs(dst)
t = conv(open(os.path.join(src, kv), encoding='utf-8').read())
for pat, rep in rules: t = re.sub(pat, rep, t, flags=re.M)
open(os.path.join(dst, 'Duneglow-Light.kvconfig'), 'w', encoding='utf-8').write(t)
open(os.path.join(dst, 'Duneglow-Light.svg'), 'w', encoding='utf-8').write(conv(open(os.path.join(src, sv), encoding='utf-8').read()))
print('Built', dst)
