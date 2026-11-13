#!/usr/bin/env python3
"""Duneglow spinning cube: renders N frames of the cube logo turning about its vertical axis (orthographic, isometric tilt),
same palette as tools/make_logo.py, and packs them into one sprite sheet for QML's AnimatedSprite.
Opposite faces share a colour, so 180 degrees of turn loops seamlessly.
Usage: make_cube_spin.py <out.png> [frames=48] [cell=224] [cols=8]   (needs rsvg-convert and Pillow). Code GPL-3.0-or-later."""
import math, os, subprocess, sys, tempfile
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
out = sys.argv[1]; N = int(sys.argv[2]) if len(sys.argv) > 2 else 48
CELL = int(sys.argv[3]) if len(sys.argv) > 3 else 224; COLS = int(sys.argv[4]) if len(sys.argv) > 4 else 8
E = math.radians(35.264)                      # isometric elevation
V = 256                                       # svg canvas
R, GAP = 9.0, 0.955

def rounded(pts, r):
    n = len(pts); d = ""
    for i in range(n):
        p0, p1, p2 = pts[i - 1], pts[i], pts[(i + 1) % n]
        def toward(a, b, dist):
            dx, dy = b[0] - a[0], b[1] - a[1]; L = math.hypot(dx, dy) or 1
            return (a[0] + dx / L * dist, a[1] + dy / L * dist)
        a = toward(p1, p0, r); b = toward(p1, p2, r)
        d += (f"M{a[0]:.2f} {a[1]:.2f}" if i == 0 else f"L{a[0]:.2f} {a[1]:.2f}") + f"Q{p1[0]:.2f} {p1[1]:.2f} {b[0]:.2f} {b[1]:.2f}"
    return d + "Z"
def shrink(pts, k):
    cx = sum(p[0] for p in pts) / len(pts); cy = sum(p[1] for p in pts) / len(pts)
    return [(cx + (x - cx) * k, cy + (y - cy) * k) for x, y in pts]

# normalise the scale so the cube fits the cell at every angle
def proj(x, y, z, yaw):
    c, s = math.cos(yaw), math.sin(yaw)
    xr, zr = x * c + z * s, -x * s + z * c
    return xr, y * math.cos(E) - zr * math.sin(E), zr
ext = max(max(abs(proj(x, y, z, math.radians(a))[0]) for x in (-1, 1) for y in (-1, 1) for z in (-1, 1) for a in range(0, 91, 5)) ,
          max(abs(proj(x, y, z, math.radians(45))[1]) for x in (-1, 1) for y in (-1, 1) for z in (-1, 1)))
SC = 0.5 * V * 0.80 / ext

GRADS = {
 'top':  ('#FFF1DC', '#F7C58F', 'diag'),
 'amber': ('#F59A2E', '#C8503C', 'v'),
 'slate': ('#7F95AE', '#8E3F6E', 'v'),
}
FACES = [  # normal, four corners (ccw seen from outside), grad
 ((0, 0, 1),  [(-1, 1, 1), (1, 1, 1), (1, -1, 1), (-1, -1, 1)], 'amber'),
 ((0, 0, -1), [(1, 1, -1), (-1, 1, -1), (-1, -1, -1), (1, -1, -1)], 'amber'),
 ((1, 0, 0),  [(1, 1, 1), (1, 1, -1), (1, -1, -1), (1, -1, 1)], 'slate'),
 ((-1, 0, 0), [(-1, 1, -1), (-1, 1, 1), (-1, -1, 1), (-1, -1, -1)], 'slate'),
]
TOP = [(-1, 1, -1), (1, 1, -1), (1, 1, 1), (-1, 1, 1)]

def frame_svg(deg):
    yaw = math.radians(45 + deg)
    P = lambda v: (V / 2 + SC * proj(*v, yaw)[0], V / 2 - SC * proj(*v, yaw)[1])
    defs, body = [], []
    for k, (a, b, kind) in GRADS.items():
        xy = 'x1="0" y1="0" x2="1" y2="1"' if kind == 'diag' else 'x1="0" y1="0" x2="0" y2="1"'
        defs.append(f'<linearGradient id="{k}" {xy}><stop offset="0" stop-color="{a}"/><stop offset="1" stop-color="{b}"/></linearGradient>')
    c, s = math.cos(yaw), math.sin(yaw)
    for n, quad, g in FACES:
        nz = -n[0] * s + n[2] * c
        if nz <= 1e-6: continue                                # faces away from the camera
        pts = shrink([P(v) for v in quad], GAP); d = rounded(pts, R)
        shade = 0.30 * (1 - nz) ** 1.2                          # turned away from the viewer = a little darker
        body.append(f'<path d="{d}" fill="url(#{g})"/>')
        if shade > 0.01: body.append(f'<path d="{d}" fill="#1a1230" fill-opacity="{shade:.3f}"/>')
    tp = shrink([P(v) for v in TOP], GAP)
    body.append(f'<path d="{rounded(tp, R)}" fill="url(#top)"/>')
    cx = sum(p[0] for p in tp) / 4; cy = sum(p[1] for p in tp) / 4
    defs.append('<radialGradient id="glow" cx=".5" cy=".5" r=".5"><stop offset="0" stop-color="#FFFFFF" stop-opacity=".75"/><stop offset="1" stop-color="#FFFFFF" stop-opacity="0"/></radialGradient>')
    body.append(f'<ellipse cx="{cx:.1f}" cy="{cy:.1f}" rx="{SC*0.95:.1f}" ry="{SC*0.5:.1f}" fill="url(#glow)"/>')
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {V} {V}"><defs>{"".join(defs)}</defs>{"".join(body)}</svg>'

rows = math.ceil(N / COLS); sheet = Image.new('RGBA', (COLS * CELL, rows * CELL), (0, 0, 0, 0))
tmp = tempfile.mkdtemp()
for i in range(N):
    deg = 90.0 + 180.0 * i / N                                         # 0..180 (exclusive): loops because opposite faces match
    sv = os.path.join(tmp, f'f{i}.svg'); pn = os.path.join(tmp, f'f{i}.png')
    open(sv, 'w').write(frame_svg(deg))
    subprocess.run(['rsvg-convert', '-w', str(CELL), '-h', str(CELL), sv, '-o', pn], check=True)
    sheet.paste(Image.open(pn).convert('RGBA'), ((i % COLS) * CELL, (i // COLS) * CELL))
sheet.save(out, optimize=True)
print('sheet', sheet.size, 'frames', N)
