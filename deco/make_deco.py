#!/usr/bin/env python3
"""Duneglow Aurorae title bars, derived from Qogir-dark / Qogir-light (GPL-3.0), rule-based recolour.
Usage: make_deco.py dark|light <src theme dir> <dst theme dir>"""
import re, sys, os, shutil, colorsys
mode, src, dst = sys.argv[1], *map(os.path.expanduser, sys.argv[2:4])
dark = mode == 'dark'
NAME = 'Duneglow-Dark' if dark else 'Duneglow-Light'
ALPHA = '0.55' if dark else '0.62'
EMBER = '#E8873A'
HEX = re.compile(r'#([0-9a-fA-F]{6})\b')
def hls(h): 
    r,g,b = [int(h[i:i+2],16)/255 for i in (0,2,4)]; return colorsys.rgb_to_hls(r,g,b)
def hx(r,g,b): return '#%02x%02x%02x' % (round(r*255),round(g*255),round(b*255))
def is_body(h):
    _,l,s = hls(h)
    return s < 0.25 and ((0.03 < l < 0.3) if dark else (0.85 <= l < 0.97))
def mapc(m):
    h_, l, s = hls(m.group(1))
    if s >= 0.25 and 170/360 <= h_ <= 270/360: return EMBER
    if s < 0.25 and 0.03 < l < 0.97:
        if dark and l < 0.5: return hx(*colorsys.hls_to_rgb(226/360, l, 0.35))
        if not dark and l >= 0.5: return hx(*colorsys.hls_to_rgb(42/360, l, 0.18))
        if not dark and l < 0.5: return hx(*colorsys.hls_to_rgb(215/360, l, 0.15))
    return '#' + m.group(1)
def glass(tag):      # solid title-bar body fills become see-through
    mm = re.search(r'fill:(#[0-9a-fA-F]{6})', tag)
    if not mm or not is_body(mm.group(1)[1:]): return tag
    if 'fill-opacity:' in tag: return re.sub(r'fill-opacity:1(?![0-9.])', 'fill-opacity:' + ALPHA, tag)
    return tag.replace(mm.group(0), mm.group(0) + ';fill-opacity:' + ALPHA, 1)
shutil.rmtree(dst, ignore_errors=True); os.makedirs(dst)
srcname = os.path.basename(src.rstrip('/'))
for f in os.listdir(src):
    p = os.path.join(src, f)
    if f.endswith('.svg'):
        t = open(p, encoding='utf-8').read()
        if f == 'decoration.svg': t = re.sub(r'<(?:path|rect|circle|ellipse)\b[^>]*>', lambda m: glass(m.group(0)), t)
        t = HEX.sub(mapc, t)
        open(os.path.join(dst, f), 'w', encoding='utf-8').write(t)
    elif f.endswith('rc'):
        t = open(p, encoding='utf-8').read()
        act, ina = ('231,235,244', '154,167,192') if dark else ('38,43,51', '93,102,114')
        tab = '31,39,64' if dark else '232,229,220'
        t = re.sub(r'^ActiveTextColor=.*', f'ActiveTextColor={act},255', t, flags=re.M)
        t = re.sub(r'^InactiveTextColor=.*', f'InactiveTextColor={ina},255', t, flags=re.M)
        t = re.sub(r'^(Active|Inactive)(Focused|Unfocused)TabColor=.*', lambda m: f'{m.group(1)}{m.group(2)}TabColor={tab}', t, flags=re.M)
        t = re.sub(r'^UseTextShadow=.*', 'UseTextShadow=false', t, flags=re.M)
        open(os.path.join(dst, NAME + 'rc'), 'w', encoding='utf-8').write(t)
    elif f == 'metadata.desktop':
        t = open(p, encoding='utf-8').read().replace(srcname, NAME)
        t = re.sub(r'^X-KDE-PluginInfo-Name=.*', f'X-KDE-PluginInfo-Name={NAME}', t, flags=re.M)
        open(os.path.join(dst, f), 'w', encoding='utf-8').write(t)
    elif os.path.isfile(p): shutil.copy(p, dst)
print('Built', dst)
