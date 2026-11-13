#!/usr/bin/env python3
"""Duneglow icon themes (Step 6c). Builds Duneglow-Dark / Duneglow-Light that inherit Fluent-dark / Fluent-light
and override only the folder icons: blue hues are shifted to ember, everything else is kept.
Usage: make_icons.py <icons-root> ; e.g. ~/.local/share/icons.  Code GPL-3.0-or-later."""
import os, re, sys, colorsys, shutil
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'glass-folder'))
from folder_glass import folder_svg
root = os.path.expanduser(sys.argv[1])
HEX = re.compile(r'#([0-9a-fA-F]{6})\b')
TARGET_H = 28/360.0          # ember
NAME = re.compile(r'^(folder|inode-directory|user-home|user-desktop)')
BREEZE = os.environ.get('DUNEGLOW_BREEZE', '/usr/share/icons/breeze')

def shift(m):
    r,g,b = [int(m.group(1)[i:i+2],16)/255 for i in (0,2,4)]
    h,l,s = colorsys.rgb_to_hls(r,g,b)
    if s < 0.15 or not (180/360 <= h <= 260/360):
        return m.group(0)
    h2 = TARGET_H + (h - 205/360)*0.15      # keep a little of the original hue spread
    s2 = min(1.0, s*1.05)
    r2,g2,b2 = colorsys.hls_to_rgb(h2,l,s2)
    return '#%02x%02x%02x' % (round(r2*255),round(g2*255),round(b2*255))

RANGES = {48: (33, 48), 64: (49, 64), 96: (65, 512)}
def dirsec(d):
    n = int(d)
    if n in RANGES:
        lo, hi = RANGES[n]
        return f'\n[places/{d}]\nSize={d}\nContext=Places\nType=Scalable\nMinSize={lo}\nMaxSize={hi}\n'
    return f'\n[places/{d}]\nSize={d}\nContext=Places\nType=Fixed\n'

GLASS_NAMES = {'folder', 'inode-directory', 'user-home', 'user-desktop'} | {'folder-' + n for n in (
    'documents', 'download', 'downloads', 'music', 'pictures', 'videos', 'publicshare', 'public', 'templates',
    'favorites', 'recent', 'remote', 'network', 'cloud', 'development', 'games')}
SHAPES = re.compile(r'<(?:path|rect|circle|ellipse)\b[^>]*?>', re.S)
def _d(tag):
    m = re.search(r'\sd="([^"]*)"', tag)
    return re.sub(r'\s+', ' ', m.group(1)).strip() if m else None
def plain_paths(txt):
    return {d for d in (_d(t) for t in SHAPES.findall(txt)) if d}
def glass_icon(name, txt, plain_ds, variant):
    """Our original glass folder, with the Breeze symbol (everything that is not the plain folder's own shapes) on top."""
    base = name[:-4]
    if base not in GLASS_NAMES: return None
    if base in ('folder', 'inode-directory'): return folder_svg(variant)
    vb = re.search(r'viewBox="[-\d.]+[ ,]+[-\d.]+[ ,]+([\d.]+)', txt)
    f = 64.0 / float(vb.group(1)) if vb else 1.0
    keep = []
    for t in SHAPES.findall(txt):
        d = _d(t)
        if (d and d in plain_ds) or 'ColorScheme-Accent' in t or 'ColorScheme-Highlight' in t: continue
        keep.append(re.sub(r'ColorScheme-\w+', 'DuneglowGlyph', t if t.rstrip().endswith('/>') else t.rstrip()[:-1] + '/>'))
    if len(keep) > 8: return None                       # different body (not a plain folder with a symbol): keep recolour fallback
    glyph = f'<g transform="translate(6.4 12.6) scale({1.8 * f:.4f})">' + ''.join(keep) + '</g>' if keep else None
    return folder_svg(variant, glyph=glyph)

def build(src, dst, label):
    sdir = os.path.join(root, src)
    if not os.path.isdir(sdir):
        print(f"skip {label}: {sdir} not found"); return
    ddir = os.path.join(root, dst)
    variant = 'B' if dst.endswith('Dark') else 'A'      # dark: clear frost, light: amber glass (user's choice)
    shutil.rmtree(ddir, ignore_errors=True)
    changed = skipped_png = 0
    for dp, dn, fn in os.walk(sdir):
        if os.path.basename(dp) != 'places' or 'symbolic' in dp: continue
        rel = os.path.relpath(dp, sdir)
        for f in fn:
            if not NAME.match(f) or 'public' in f: continue   # Fluent's public-share glyph clashes with Breeze folders
            p = os.path.join(dp, f)
            if not f.endswith('.svg'):
                skipped_png += 1; continue
            try: txt = open(p, encoding='utf-8').read()     # follows symlinks
            except Exception: continue
            if '<image' in txt: continue                       # embedded PNG body: cannot be recoloured by hex
            new = HEX.sub(shift, txt)
            if new == txt: continue
            os.makedirs(os.path.join(ddir, rel), exist_ok=True)
            open(os.path.join(ddir, rel, f), 'w', encoding='utf-8').write(new)
            changed += 1
    # Breeze folders (the large 48/64/96 px ones Dolphin uses): places/<size>/
    bdirs = []
    bplaces = os.path.join(BREEZE, 'places')
    if os.path.isdir(bplaces):
        for size in sorted(os.listdir(bplaces)):
            bp = os.path.join(bplaces, size)
            if not size.isdigit() or not os.path.isdir(bp): continue
            n = 0
            try: plain_ds = plain_paths(open(os.path.join(bp, 'folder.svg'), encoding='utf-8').read())
            except Exception: plain_ds = set()
            for f in os.listdir(bp):
                if not NAME.match(f) or not f.endswith('.svg'): continue
                try: txt = open(os.path.join(bp, f), encoding='utf-8').read()
                except Exception: continue
                g = glass_icon(f, txt, plain_ds, variant)
                t2 = txt
                if g is None and ('ColorScheme-Highlight' in t2 or 'ColorScheme-Accent' in t2):
                    # KDE rewrites the stylesheet that defines ColorScheme-*; our own extra <style> survives it
                    t2 = t2.replace('ColorScheme-Highlight', 'DuneglowEmber').replace('ColorScheme-Accent', 'DuneglowEmber')
                    t2 = re.sub(r'(<svg\b[^>]*>)', r'\1<style type="text/css">.DuneglowEmber{color:#E8873A}</style>', t2, count=1)
                new = g if g is not None else HEX.sub(shift, t2)
                if new == txt: continue
                os.makedirs(os.path.join(ddir, 'places', size), exist_ok=True)
                names = [f] + (['inode-directory.svg'] if f == 'folder.svg' else [])
                for nm in names:
                    open(os.path.join(ddir, 'places', size, nm), 'w', encoding='utf-8').write(new)
                    n += 1; changed += 1
            if n: bdirs.append(size)
    idx = open(os.path.join(sdir, 'index.theme'), encoding='utf-8').read()
    if bdirs:
        idx = re.sub(r'^Directories=(.*)$', lambda m: m.group(0) + ''.join(f',places/{d}' for d in bdirs), idx, count=1, flags=re.M)
        idx = idx.rstrip('\n') + '\n' + ''.join(dirsec(d) for d in bdirs)
    idx = re.sub(r'^Name=.*$', f'Name={label}', idx, count=1, flags=re.M)
    idx = re.sub(r'^Comment=.*$', 'Comment=Duneglow folders (ember) over ' + src, idx, count=1, flags=re.M)
    if re.search(r'^Inherits=', idx, re.M):
        idx = re.sub(r'^Inherits=.*$', f'Inherits={src},hicolor', idx, count=1, flags=re.M)
    else:
        idx = idx.replace('[Icon Theme]', f'[Icon Theme]\nInherits={src},hicolor', 1)
    os.makedirs(ddir, exist_ok=True)
    open(os.path.join(ddir, 'index.theme'), 'w', encoding='utf-8').write(idx)
    print(f"{label}: {changed} folder icons recoloured ({skipped_png} non-SVG folder files left as they are)")

build('Fluent-dark',  'Duneglow-Dark',  'Duneglow Dark')
build('Fluent-light', 'Duneglow-Light', 'Duneglow Light')
