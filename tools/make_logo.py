#!/usr/bin/env python3
"""Duneglow cube logo (original). Closed isometric cube, three faces in the dune palette,
rounded corners, thin gaps between faces. Writes SVG to the given path."""
import math, sys

R = 9.0       # corner radius
GAP = 0.955   # faces shrink toward their centre to leave a thin gap

def rounded(pts, r):
    n = len(pts); d = ""
    for i in range(n):
        p0, p1, p2 = pts[i - 1], pts[i], pts[(i + 1) % n]
        def toward(a, b, dist):
            dx, dy = b[0] - a[0], b[1] - a[1]; L = math.hypot(dx, dy)
            return (a[0] + dx / L * dist, a[1] + dy / L * dist)
        a = toward(p1, p0, r); b = toward(p1, p2, r)
        d += (f"M{a[0]:.2f} {a[1]:.2f}" if i == 0 else f"L{a[0]:.2f} {a[1]:.2f}")
        d += f"Q{p1[0]:.2f} {p1[1]:.2f} {b[0]:.2f} {b[1]:.2f}"
    return d + "Z"

def shrink(pts, k):
    cx = sum(p[0] for p in pts) / len(pts); cy = sum(p[1] for p in pts) / len(pts)
    return [(cx + (x - cx) * k, cy + (y - cy) * k) for x, y in pts]

top = [(45, 80), (128, 32), (211, 80), (128, 128)]
left = [(45, 80), (128, 128), (128, 224), (45, 176)]
right = [(128, 128), (211, 80), (211, 176), (128, 224)]

svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256">
<defs>
<linearGradient id="t" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FFF1DC"/><stop offset="1" stop-color="#F7C58F"/></linearGradient>
<linearGradient id="l" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#F59A2E"/><stop offset="1" stop-color="#C8503C"/></linearGradient>
<linearGradient id="r" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#7F95AE"/><stop offset="1" stop-color="#8E3F6E"/></linearGradient>
<radialGradient id="glow" cx=".5" cy=".5" r=".5"><stop offset="0" stop-color="#FFFFFF" stop-opacity=".75"/><stop offset="1" stop-color="#FFFFFF" stop-opacity="0"/></radialGradient>
</defs>
<path d="{rounded(shrink(top, GAP), R)}" fill="url(#t)"/>
<ellipse cx="128" cy="80" rx="40" ry="20" fill="url(#glow)"/>
<path d="{rounded(shrink(left, GAP), R)}" fill="url(#l)"/>
<path d="{rounded(shrink(right, GAP), R)}" fill="url(#r)"/>
</svg>'''
open(sys.argv[1], "w").write(svg)
