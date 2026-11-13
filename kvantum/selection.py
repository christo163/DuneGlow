#!/usr/bin/env python3
"""Duneglow Kvantum: selected items in item views become frosted slate glass instead of solid ember.
Usage: selection.py <theme.svg>. Code GPL-3.0-or-later."""
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
SLATE, ALPHA = '#6A88B8', '0.55'
def fix(m):
    tag = m.group(0)
    if not re.search(r'id="itemview-(?:pressed|toggled)[^"]*"', tag):
        return tag
    tag = re.sub(r'fill:#E8873A;fill-opacity:[0-9.]+', f'fill:{SLATE};fill-opacity:{ALPHA}', tag, flags=re.I)
    tag = re.sub(r'fill:#E8873A(?!;fill-opacity)', f'fill:{SLATE};fill-opacity:{ALPHA}', tag, flags=re.I)
    return tag
s = re.sub(r'<path\b[^>]*>', fix, s)
s = re.sub(r'#5096e1', '#E8873A', s, flags=re.I)     # leftover blue in focus/hover pieces
open(p, 'w', encoding='utf-8').write(s)
