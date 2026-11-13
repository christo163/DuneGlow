#!/usr/bin/env python3
"""Generate Duneglow Light/Dark KDE colour schemes. Usage: make_colors.py <outdir>. CC BY-SA 4.0"""
import sys, os
def rgb(h): h=h.lstrip('#'); return ",".join(str(int(h[i:i+2],16)) for i in (0,2,4))
def sect(name, bg, alt, fg, inact, focus, hover, act="#F08A1C", link="#3E6FA8", vis="#7A4E9E", neg="#C0392B", neu="#C97A10", pos="#2E8B57"):
    return f"""[Colors:{name}]
BackgroundAlternate={rgb(alt)}
BackgroundNormal={rgb(bg)}
DecorationFocus={rgb(focus)}
DecorationHover={rgb(hover)}
ForegroundActive={rgb(act)}
ForegroundInactive={rgb(inact)}
ForegroundLink={rgb(link)}
ForegroundNegative={rgb(neg)}
ForegroundNeutral={rgb(neu)}
ForegroundNormal={rgb(fg)}
ForegroundPositive={rgb(pos)}
ForegroundVisited={rgb(vis)}
"""
def scheme(name, P):
    s=""
    s+=sect("Button",P['button'],P['button_alt'],P['text'],P['muted'],P['ember'],P['ember'],**P['sem'])
    s+="\n"+sect("Complementary",P['comp'],P['comp_alt'],"#E7EBF4","#9AA7C0",P['ember_n'],P['ember_n'],act="#F2A15A",link="#96BEFF",vis="#BEA0FF",neg="#FF7878",neu="#FFBE5A",pos="#82DC96")
    s+="\n"+sect("Header",P['window'],P['window_alt'],P['text'],P['muted'],P['ember'],P['ember'],**P['sem'])
    s+="\n"+sect("Selection",P['sel'],P['sel_alt'],"#FFFFFF","#D6DEEC",P['ember'],P['ember'],act="#FFFFFF",link="#FFFFFF",vis="#FFFFFF",neg="#FFD0D0",neu="#FFE2A8",pos="#CFF5D8")
    s+="\n"+sect("Tooltip","#1F2740","#2A3654","#E7EBF4","#9AA7C0",P['ember_n'],P['ember_n'],act="#F2A15A",link="#96BEFF",vis="#BEA0FF",neg="#FF7878",neu="#FFBE5A",pos="#82DC96")
    s+="\n"+sect("View",P['view'],P['view_alt'],P['text'],P['muted'],P['ember'],P['ember'],**P['sem'])
    s+="\n"+sect("Window",P['window'],P['window_alt'],P['text'],P['muted'],P['ember'],P['ember'],**P['sem'])
    s+=f"""
[ColorEffects:Disabled]
Color={rgb(P['window'])}
ColorAmount=0.2
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=1
IntensityAmount=0
IntensityEffect=0

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color={rgb(P['window_alt'])}
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[General]
ColorScheme={name.replace(' ','')}
Name={name}
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground={rgb(P['title'])}
activeBlend={rgb(P['title'])}
activeForeground={rgb(P['text'])}
inactiveBackground={rgb(P['title_in'])}
inactiveBlend={rgb(P['title_in'])}
inactiveForeground={rgb(P['muted'])}
"""
    return s
SEM_L=dict(act="#C8631A",link="#2F6AA8",vis="#7A4E9E",neg="#C0392B",neu="#B86E0C",pos="#2E8B57")
SEM_D=dict(act="#F2A15A",link="#96BEFF",vis="#BEA0FF",neg="#FF7878",neu="#FFBE5A",pos="#82DC96")
LIGHT=dict(window="#E8E5DC",window_alt="#DDD9CE",view="#F4F2EC",view_alt="#ECE9E0",button="#F1EEE6",button_alt="#E6E2D8",
  text="#262B33",muted="#5D6672",ember="#D9731A",ember_n="#F2A15A",sel="#3E5670",sel_alt="#4A6684",comp="#1F2740",comp_alt="#2A3654",
  title="#DDD9CE",title_in="#E8E5DC",sem=SEM_L)
DARK=dict(window="#1F2740",window_alt="#26304E",view="#161C2E",view_alt="#1B2238",button="#2A3452",button_alt="#323E60",
  text="#E7EBF4",muted="#9AA7C0",ember="#F2A15A",ember_n="#F2A15A",sel="#4A6490",sel_alt="#58739F",comp="#161C2E",comp_alt="#1B2238",
  title="#161C2E",title_in="#1F2740",sem=SEM_D)
out=sys.argv[1]; os.makedirs(out,exist_ok=True)
for n,P in (("Duneglow Light",LIGHT),("Duneglow Dark",DARK)):
    open(os.path.join(out,n.replace(' ','')+".colors"),"w").write(scheme(n,P))
