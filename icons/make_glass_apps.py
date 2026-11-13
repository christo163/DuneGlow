#!/usr/bin/env python3
"""Duneglow glass tiles for app icons (Step 7b). For every Icon= named in your .desktop files, writes a wrapped
scalable SVG (glass rounded tile + the original icon) into Duneglow-Dark / Duneglow-Light under glass/apps.
Usage: make_glass_apps.py on|off [icons-root]. Code GPL-3.0-or-later."""
import os, re, sys, glob, base64, shutil
mode = sys.argv[1] if len(sys.argv) > 1 else 'on'
root = os.path.expanduser(sys.argv[2] if len(sys.argv) > 2 else '~/.local/share/icons')
THEMES = ['Duneglow-Dark', 'Duneglow-Light']
SEC = "\n[glass/apps]\nSize=64\nContext=Applications\nType=Scalable\nMinSize=8\nMaxSize=1024\n"
DESK = ['/usr/share/applications', '~/.local/share/applications', '/var/lib/flatpak/exports/share/applications',
        '~/.local/share/flatpak/exports/share/applications']
SRC = ['~/.local/share/icons/Fluent-dark', '~/.local/share/icons/hicolor', '/usr/share/icons/hicolor', '/usr/share/icons/breeze',
       '/usr/share/pixmaps', '/var/lib/flatpak/exports/share/icons', '~/.local/share/flatpak/exports/share/icons']
TILE = """<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"{ns} width="128" height="128" viewBox="0 0 128 128">
<defs>
<linearGradient id="dgFill" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ffffff" stop-opacity="0.34"/><stop offset="0.55" stop-color="#c9d6f0" stop-opacity="0.14"/><stop offset="1" stop-color="#1f2740" stop-opacity="0.34"/></linearGradient>
<linearGradient id="dgEdge" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ffffff" stop-opacity="0.85"/><stop offset="0.45" stop-color="#ffffff" stop-opacity="0.12"/><stop offset="1" stop-color="#f59a4a" stop-opacity="0.55"/></linearGradient>
<linearGradient id="dgSheen" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ffffff" stop-opacity="0.55"/><stop offset="1" stop-color="#ffffff" stop-opacity="0"/></linearGradient>
<linearGradient id="dgGlow" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#f59a4a" stop-opacity="0"/><stop offset="1" stop-color="#f59a4a" stop-opacity="0.30"/></linearGradient>

</defs>
<rect x="6" y="6" width="116" height="116" rx="30" fill="url(#dgFill)"/>
<rect x="10" y="9" width="108" height="54" rx="26" fill="url(#dgSheen)"/><rect x="10" y="78" width="108" height="40" rx="26" fill="url(#dgGlow)"/>
<rect x="6.5" y="6.5" width="115" height="115" rx="29.5" fill="none" stroke="url(#dgEdge)" stroke-width="1.5"/>
{inner}
</svg>
"""
TILE_LIGHT = (TILE
  .replace('<stop offset="0" stop-color="#ffffff" stop-opacity="0.34"/><stop offset="0.55" stop-color="#c9d6f0" stop-opacity="0.14"/><stop offset="1" stop-color="#1f2740" stop-opacity="0.34"/>',
           '<stop offset="0" stop-color="#ffffff" stop-opacity="0.78"/><stop offset="0.55" stop-color="#f6f2e8" stop-opacity="0.50"/><stop offset="1" stop-color="#e3d6c0" stop-opacity="0.55"/>')
  .replace('<rect x="6.5" y="6.5"', '<rect x="5.5" y="5.5" width="117" height="117" rx="30.5" fill="none" stroke="#33405e" stroke-opacity="0.22" stroke-width="1"/>\n<rect x="6.5" y="6.5"'))
def exp(p): return os.path.expanduser(p)

def desktop_icons():
    names = set()
    for d in DESK:
        for f in glob.glob(os.path.join(exp(d), '*.desktop')):
            try:
                for line in open(f, encoding='utf-8', errors='ignore'):
                    if line.startswith('Icon='):
                        n = line[5:].strip()
                        if n and not n.startswith('/'): names.add(n)
                        break
            except OSError: pass
    return names

def index_sources():
    best = {}                      # name -> (rank, path)
    for r in SRC:
        r = exp(r)
        for dp, dn, fn in os.walk(r):
            if 'symbolic' in dp or ('/apps' not in dp and 'pixmaps' not in dp and not dp.endswith('apps')): continue
            for f in fn:
                base, ext = os.path.splitext(f)
                if ext not in ('.svg', '.png'): continue
                m = re.search(r'(\d+)(?:x\d+)?', dp.split('icons')[-1])
                size = 1000 if 'scalable' in dp else (int(m.group(1)) if m else 48)
                rank = (1 if ext == '.svg' else 0, size)
                if base not in best or rank > best[base][0]: best[base] = (rank, os.path.join(dp, f))
    return best

def wrap_svg(path):
    t = open(path, encoding='utf-8', errors='ignore').read()
    t = re.sub(r'<\?xml[^>]*\?>|<!DOCTYPE[^>]*>', '', t)
    m = re.search(r'<svg\b([^>]*)>', t, re.S)
    if not m: return None
    attrs = m.group(1); body = t[m.end():t.rfind('</svg>')]
    ns = ''.join(' ' + a for a in re.findall(r'xmlns:\w+="[^"]*"', attrs) if 'xmlns:xlink' not in a)
    vb = re.search(r'viewBox="\s*([-\d.]+)[ ,]+([-\d.]+)[ ,]+([\d.]+)[ ,]+([\d.]+)\s*"', attrs)
    if vb: x0, y0, w, h = map(float, vb.groups())
    else:
        w = re.search(r'\bwidth="([\d.]+)', attrs); h = re.search(r'\bheight="([\d.]+)', attrs)
        if not (w and h): return None
        x0 = y0 = 0; w, h = float(w.group(1)), float(h.group(1))
    s = 88.0 / max(w, h)
    tx, ty = 64 - (x0 + w / 2) * s, 64 - (y0 + h / 2) * s
    return ns, f'<g transform="translate({tx:.3f} {ty:.3f}) scale({s:.5f})">{body}</g>'

def wrap_png(path):
    b = base64.b64encode(open(path, 'rb').read()).decode()
    return '', f'<image x="20" y="20" width="88" height="88" preserveAspectRatio="xMidYMid meet" xlink:href="data:image/png;base64,{b}"/>'

def patch_index(theme, on):
    p = os.path.join(root, theme, 'index.theme')
    if not os.path.isfile(p): return False
    t = open(p, encoding='utf-8').read()
    t = t.replace(SEC, '').replace(',glass/apps', '')
    if on:
        t = re.sub(r'^Directories=(.*)$', lambda m: m.group(0) + ',glass/apps', t, count=1, flags=re.M)
        t = t.rstrip('\n') + '\n' + SEC
    open(p, 'w', encoding='utf-8').write(t)
    return True

if mode == 'off':
    for th in THEMES:
        shutil.rmtree(os.path.join(root, th, 'glass'), ignore_errors=True); patch_index(th, False)
    print('Glass app icons removed.'); sys.exit(0)

names = desktop_icons(); idx = index_sources()
done = skipped = 0
for th in THEMES:
    if not patch_index(th, True): print('skip', th, '(not installed)'); continue
    out = os.path.join(root, th, 'glass', 'apps'); shutil.rmtree(os.path.join(root, th, 'glass'), ignore_errors=True); os.makedirs(out)
    for n in sorted(names):
        if n not in idx: skipped += 1; continue
        p = idx[n][1]
        try: r = wrap_svg(p) if p.endswith('.svg') else wrap_png(p)
        except Exception: r = None
        if not r: skipped += 1; continue
        open(os.path.join(out, n + '.svg'), 'w', encoding='utf-8').write((TILE_LIGHT if th.endswith('Light') else TILE).format(ns=r[0], inner=r[1]))
        done += 1
print(f'Glass tiles: {done // max(1, len([t for t in THEMES if os.path.isdir(os.path.join(root, t, "glass"))]))} app icons wrapped, {skipped // 2 if skipped else 0} not found (they keep their normal look).')
