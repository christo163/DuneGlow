#!/usr/bin/env python3
"""Original Duneglow glass folder artwork (no clipPath, so Plasma's renderer draws it correctly). CC BY-SA 4.0 / GPL-3.0-or-later.
folder_svg(variant, paper=False, glyph=None, uid='a') -> svg text (viewBox 0 0 128 128)."""
V = {
 # name: (back top, back bottom, back opacity, front top, front bottom, front opacity top/bottom, edge colour)
 'A': dict(label='A  Amber glass', back=('#F2A15A', '#C8631A', 0.96), front=('#FFC48A', '#E8873A', 0.84, 0.95), glow='#F59A4A', rim=0.9),
 'B': dict(label='B  Clear frost', back=('#F2A15A', '#C8631A', 0.50), front=('#FFFFFF', '#F2A15A', 0.34, 0.30), glow='#F59A4A', rim=1.0),
 'C': dict(label='C  Deep ember', back=('#D9731A', '#8E3F1A', 0.90), front=('#F2A15A', '#C8631A', 0.60, 0.85), glow='#FFB070', rim=0.8),
}
NOTE = '<path d="M66 70 v26 a8 8 0 1 1 -5 -7.4 V66 l22 -6 v22 a8 8 0 1 1 -5 -7.4 V60 z" fill="#ffffff" fill-opacity="0.92"/>'
def folder_svg(v='A', paper=False, glyph=None, uid='a'):
    c = V[v]; i = lambda n: f'dg{uid}{n}'
    paper_svg = ('<g transform="rotate(-5 64 70)"><rect x="30" y="30" width="62" height="64" rx="5" fill="#ffffff" fill-opacity="0.94"/>'
                 '<rect x="38" y="42" width="40" height="4" rx="2" fill="#9aa7c0" fill-opacity="0.6"/><rect x="38" y="52" width="30" height="4" rx="2" fill="#9aa7c0" fill-opacity="0.45"/></g>') if paper else ''
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
<defs>
<linearGradient id="{i('Bk')}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{c['back'][0]}" stop-opacity="{c['back'][2]}"/><stop offset="1" stop-color="{c['back'][1]}" stop-opacity="{c['back'][2]}"/></linearGradient>
<linearGradient id="{i('Fr')}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{c['front'][0]}" stop-opacity="{c['front'][2]}"/><stop offset="1" stop-color="{c['front'][1]}" stop-opacity="{c['front'][3]}"/></linearGradient>
<linearGradient id="{i('Sh')}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ffffff" stop-opacity="0.60"/><stop offset="1" stop-color="#ffffff" stop-opacity="0"/></linearGradient>
<linearGradient id="{i('Gl')}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{c['glow']}" stop-opacity="0"/><stop offset="1" stop-color="{c['glow']}" stop-opacity="0.45"/></linearGradient>
<linearGradient id="{i('Ed')}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ffffff" stop-opacity="{c['rim']}"/><stop offset="0.5" stop-color="#ffffff" stop-opacity="0.16"/><stop offset="1" stop-color="{c['glow']}" stop-opacity="0.7"/></linearGradient>
<linearGradient id="{i('Tp')}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ffffff" stop-opacity="0.55"/><stop offset="1" stop-color="#ffffff" stop-opacity="0.05"/></linearGradient>
<radialGradient id="{i('Sd')}" cx="0.5" cy="0.5" r="0.5"><stop offset="0" stop-color="#000000" stop-opacity="0.30"/><stop offset="1" stop-color="#000000" stop-opacity="0"/></radialGradient>
<style type="text/css">.DuneglowGlyph{{color:#ffffff;fill:currentColor}}</style>
</defs>
<ellipse cx="64" cy="118" rx="52" ry="7" fill="url(#{i('Sd')})"/>
<path d="M10 30 a8 8 0 0 1 8 -8 H44 a8 8 0 0 1 6.4 3.2 L55 32 H110 a8 8 0 0 1 8 8 V100 a8 8 0 0 1 -8 8 H18 a8 8 0 0 1 -8 -8 Z" fill="url(#{i('Bk')})"/>
<path d="M10 30 a8 8 0 0 1 8 -8 H44 a8 8 0 0 1 6.4 3.2 L55 32 H110 a8 8 0 0 1 8 8 v3 H10 Z" fill="url(#{i('Tp')})" fill-opacity="0.8"/>
{paper_svg}
<rect x="8" y="46" width="112" height="70" rx="14" fill="url(#{i('Fr')})"/>
<rect x="11" y="48" width="106" height="30" rx="12" fill="url(#{i('Sh')})"/>
<rect x="11" y="92" width="106" height="21" rx="10" fill="url(#{i('Gl')})"/>
<rect x="8.6" y="46.6" width="110.8" height="68.8" rx="13.4" fill="none" stroke="url(#{i('Ed')})" stroke-width="1.6"/>
{glyph or ''}
</svg>'''
if __name__ == '__main__':
    import sys
    # preview sheet
    bgs = [('dark', '''<linearGradient id="bgd" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#161c2e"/><stop offset="0.6" stop-color="#2b3458"/><stop offset="1" stop-color="#6a4a6e"/></linearGradient>''', 'url(#bgd)', '#e7ebf4'),
           ('light', '''<linearGradient id="bgl" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#ece8dc"/><stop offset="0.5" stop-color="#cfd8e8"/><stop offset="1" stop-color="#f1d9c4"/></linearGradient>''', 'url(#bgl)', '#262b33')]
    W, H = 1200, 700; out = [f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{W}" height="{H}" viewBox="0 0 {W} {H}"><defs>']
    out += [b[1] for b in bgs]; out.append('</defs>')
    n = 0
    for r, (bn, _, fill, tc) in enumerate(bgs):
        y0 = r * 350
        out.append(f'<rect x="0" y="{y0}" width="{W}" height="350" fill="{fill}"/>')
        out.append(f'<circle cx="{150 + r*700}" cy="{y0+90}" r="70" fill="#f2a15a" fill-opacity="0.35"/><circle cx="{1000 - r*300}" cy="{y0+250}" r="90" fill="#7aa0e0" fill-opacity="0.30"/>')
        for k, v in enumerate('ABC'):
            x0 = 30 + k * 390
            out.append(f'<rect x="{x0}" y="{y0+20}" width="360" height="310" rx="26" fill="#ffffff" fill-opacity="0.07" stroke="#ffffff" stroke-opacity="0.25"/>')
            out.append(f'<text x="{x0+180}" y="{y0+58}" text-anchor="middle" font-family="sans-serif" font-size="20" fill="{tc}">{V[v]["label"]}</text>')
            for j, (paper, glyph) in enumerate([(False, None), (True, None)]):
                n += 1
                s = folder_svg(v, paper, glyph, uid=str(n))
                inner = s[s.index('>', s.index('<svg')) + 1: s.rindex('</svg>')]
                out.append(f'<g transform="translate({x0+20+j*165} {y0+85}) scale(1.25)">{inner}</g>')
            out.append(f'<g transform="translate({x0+100} {y0+245}) scale(0.5)">{folder_svg(v, False, NOTE, uid="n"+str(n)).split(">",1)[1].rsplit("</svg>",1)[0]}</g>')
            out.append(f'<g transform="translate({x0+190} {y0+255}) scale(0.28)">{folder_svg(v, False, None, uid="s"+str(n)).split(">",1)[1].rsplit("</svg>",1)[0]}</g>')
            out.append(f'<g transform="translate({x0+235} {y0+262}) scale(0.18)">{folder_svg(v, False, None, uid="t"+str(n)).split(">",1)[1].rsplit("</svg>",1)[0]}</g>')
    out.append('</svg>'); open(sys.argv[1] if len(sys.argv) > 1 else 'preview.svg', 'w').write('\n'.join(out))
