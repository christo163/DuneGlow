#!/usr/bin/env python3
"""Generates Dream Step 0 assets: logos, wallpapers, design tokens.
All artwork here is original to the Dream project."""
import json, math, os, random, sys

out = sys.argv[1]
for d in ("logos", "wallpapers", "tokens"):
    os.makedirs(os.path.join(out, d), exist_ok=True)

# ---------------------------------------------------------------- tokens
tokens = {
    "name": "Dream",
    "day": {
        "bg": "#E8E5DC", "surface": "#F4F2EC", "glass": "rgba(255,255,255,0.55)",
        "text": "#262B33", "text_muted": "#5D6672",
        "slate": "#5F7E9B", "slate_deep": "#3E5670",
        "clock": "#7F95AE",  # a mountain ridge shade from the day wallpaper
        "ember": "#F08A1C", "sunset": "#C8503C", "plum": "#8E3F6E",
        "accent_from": "#F2A15A", "accent_to": "#B05CC8",
    },
    "night": {
        "bg": "#161C2E", "surface": "#1F2740", "glass": "rgba(38,48,78,0.55)",
        "text": "#E7EBF4", "text_muted": "#9AA7C0",
        "slate": "#7C93B8", "slate_deep": "#2A3654",
        "clock": "#7C93B8",  # night slate, lightened mountain hue for contrast
        "ember": "#F2A15A", "sunset": "#D9705F", "plum": "#A5629A",
        "accent_from": "#E89A62", "accent_to": "#A86BD0",
    },
    "type": {
        "ui": "Inter", "clock": "Lexend",
        "clock_weight": 700, "ui_weights": [400, 500, 600],
        "license": "SIL Open Font License 1.1 (both)",
    },
    "shape": {"radius_window": 18, "radius_control": 12, "radius_dock": 26,
              "blur_px": 28, "glass_border_alpha": 0.35},
}
with open(os.path.join(out, "tokens", "dream-tokens.json"), "w") as f:
    json.dump(tokens, f, indent=2)

# ----------------------------------------------------------------- logos
GRAD = ('<linearGradient id="g" x1="0" y1="0" x2="1" y2="1">'
        '<stop offset="0" stop-color="#5E8FC4"/><stop offset="1" stop-color="#7A56B0"/>'
        '</linearGradient>')

logo_a = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256">
<defs>{GRAD}<clipPath id="c"><circle cx="128" cy="128" r="104"/></clipPath></defs>
<circle cx="128" cy="128" r="104" fill="url(#g)"/>
<g clip-path="url(#c)">
<circle cx="170" cy="92" r="17" fill="#FFFFFF" fill-opacity="0.92"/>
<path d="M14 176 C62 120 104 160 138 132 S204 104 246 150 V250 H14Z" fill="#FFFFFF" fill-opacity="0.30"/>
<path d="M14 204 C66 164 110 196 150 172 S210 160 246 188 V250 H14Z" fill="#FFFFFF" fill-opacity="0.55"/>
</g></svg>'''

logo_b = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256">
<defs>{GRAD}
<mask id="m"><rect width="256" height="256" fill="#fff"/>
<circle cx="126" cy="128" r="44" fill="#000"/>
<circle cx="144" cy="120" r="38" fill="#fff"/></mask></defs>
<path d="M64 40 H122 A88 88 0 0 1 122 216 H64 Z" fill="url(#g)" mask="url(#m)"/>
<circle cx="150" cy="170" r="9" fill="#5E8FC4"/>
</svg>'''

logo_c = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256">
<defs>
<linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
<stop offset="0" stop-color="#E3E8F4"/><stop offset="1" stop-color="#F3E7DE"/></linearGradient>
<clipPath id="r"><rect x="16" y="16" width="224" height="224" rx="60"/></clipPath></defs>
<rect x="16" y="16" width="224" height="224" rx="60" fill="url(#sky)"/>
<g clip-path="url(#r)">
<path d="M0 150 C60 108 120 140 180 110 S240 118 256 100 V256 H0Z" fill="#8E7DCB"/>
<path d="M0 186 C50 150 112 182 170 152 S235 160 256 140 V256 H0Z" fill="#5B83B5"/>
<path d="M0 222 C60 196 120 216 180 196 S240 206 256 190 V256 H0Z" fill="#2F4A6E"/>
</g></svg>'''

for name, svg in (("dream-logo-a-horizon", logo_a),
                  ("dream-logo-b-crescent-d", logo_b),
                  ("dream-logo-c-dunes", logo_c)):
    with open(os.path.join(out, "logos", name + ".svg"), "w") as f:
        f.write(svg)

# ------------------------------------------------------------ wallpapers
W, H = 3840, 2160

def ridge(seed, base, amp, rough, n=14):
    """Smooth ridge line as an SVG path, original procedural shape."""
    rnd = random.Random(seed)
    pts = []
    for i in range(n + 1):
        x = W * i / n
        y = base + amp * math.sin(i * rough + seed) + rnd.uniform(-amp, amp) * 0.55
        pts.append((x, y))
    d = f"M0 {H} L0 {pts[0][1]:.1f} "
    for i in range(1, len(pts)):
        px, py = pts[i - 1]
        x, y = pts[i]
        cx = (px + x) / 2
        d += f"C{cx:.1f} {py:.1f} {cx:.1f} {y:.1f} {x:.1f} {y:.1f} "
    d += f"L{W} {H}Z"
    return d

def wallpaper(mode):
    day = mode == "day"
    if day:
        sky = ("#C9D3DF", "#E6E3DA", "#F1E7D8")
        sun = ('<circle cx="1000" cy="900" r="190" fill="#F8D9B4" fill-opacity="0.85"/>'
               '<circle cx="1000" cy="900" r="330" fill="#F8D9B4" fill-opacity="0.22"/>')
        mts = [("#9FB0C4", 0.55, 1080, 70, 0.8, 11), ("#7F95AE", 0.75, 1300, 90, 0.9, 23),
               ("#5F7E9B", 0.95, 1500, 110, 0.7, 37)]
        dune = ("#F5A02A", "#D2602F", "#7E3C5E")
        stars = ""
    else:
        sky = ("#10162A", "#1A2340", "#2C3558")
        sun = ('<mask id="cres"><rect width="3840" height="2160" fill="#fff"/><circle cx="1050" cy="730" r="104" fill="#000"/></mask>'
               '<circle cx="1000" cy="760" r="300" fill="#8FA2D0" fill-opacity="0.10"/>'
               '<circle cx="1000" cy="760" r="118" fill="#E9EDF7" mask="url(#cres)"/>')
        mts = [("#2D3A5C", 0.6, 1080, 70, 0.8, 11), ("#232F4F", 0.8, 1300, 90, 0.9, 23),
               ("#1B2540", 1.0, 1500, 110, 0.7, 37)]
        dune = ("#59658C", "#3A4670", "#232B4A")
        rnd = random.Random(7)
        stars = "".join(
            f'<circle cx="{rnd.uniform(0, W):.0f}" cy="{rnd.uniform(0, 1150):.0f}" '
            f'r="{rnd.choice([1.6, 2.2, 3.0]):.1f}" fill="#FFFFFF" fill-opacity="{rnd.uniform(.25, .9):.2f}"/>'
            for _ in range(220))
    leaf = "#5F7A3C" if day else "#141B30"
    trunk = "#4A3426" if day else "#10162A"
    tree = (f'<g transform="translate(2890 1512)">'
            f'<path d="M-7 4 L-5 -70 L-12 -112 L-3 -78 L3 -78 L12 -118 L6 -66 L8 4Z" fill="{trunk}"/>'
            f'<circle cx="0" cy="-150" r="70" fill="{leaf}"/><circle cx="-62" cy="-118" r="48" fill="{leaf}"/>'
            f'<circle cx="64" cy="-122" r="50" fill="{leaf}"/><circle cx="-26" cy="-196" r="42" fill="{leaf}"/>'
            f'<circle cx="34" cy="-190" r="40" fill="{leaf}"/></g>')
    layers = "".join(
        f'<path d="{ridge(s, b, a, r)}" fill="{c}" fill-opacity="{o}"/>'
        for c, o, b, a, r, s in mts)
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">
<defs>
<linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
<stop offset="0" stop-color="{sky[0]}"/><stop offset=".55" stop-color="{sky[1]}"/><stop offset="1" stop-color="{sky[2]}"/></linearGradient>
<linearGradient id="dune" x1="0" y1="0" x2="0" y2="1">
<stop offset="0" stop-color="{dune[0]}"/><stop offset=".55" stop-color="{dune[1]}"/><stop offset="1" stop-color="{dune[2]}"/></linearGradient>
<linearGradient id="haze" x1="0" y1="0" x2="0" y2="1">
<stop offset="0" stop-color="{sky[2]}" stop-opacity="0"/><stop offset="1" stop-color="{sky[2]}" stop-opacity="{'.55' if day else '.35'}"/></linearGradient>
<filter id="soft"><feGaussianBlur stdDeviation="3"/></filter>
</defs>
<rect width="{W}" height="{H}" fill="url(#sky)"/>
{stars}{sun}
{layers}
<rect y="1250" width="{W}" height="420" fill="url(#haze)"/>
<path d="M0 {H} L0 1640 C600 1500 1200 1700 1900 1590 S3200 1480 {W} 1600 V{H}Z" fill="url(#dune)"/>
{tree}
<path d="M0 {H} L0 1900 C700 1790 1500 1930 2300 1850 S3300 1800 {W} 1880 V{H}Z" fill="#000" fill-opacity="{'.18' if day else '.28'}" filter="url(#soft)"/>
</svg>'''

for mode in ("day", "night"):
    with open(os.path.join(out, "wallpapers", f"dream-{mode}.svg"), "w") as f:
        f.write(wallpaper(mode))
print("ok")
