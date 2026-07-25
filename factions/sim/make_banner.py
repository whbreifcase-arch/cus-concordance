"""Generate a self-contained faction BANNER (whole-warband sheet) from the v0.6 data.
Reads data/*.json, emits ../BANNER.html — one page, both factions, grouped
Champion / Fireteams / Specialists, each unit a card with its v0.6 profile,
weapon Grade ladders (Model-2 discrete), abilities and traits. No dependencies."""
import json, os, html
HERE = os.path.dirname(__file__); DATA = os.path.join(HERE, "..", "data")
def J(f):
    with open(os.path.join(DATA, f), encoding="utf-8") as fh: return json.load(fh)

import glob as _glob
PK   = {}
for _pf in sorted(_glob.glob(os.path.join(DATA, "packets*.json"))):
    with open(_pf, encoding="utf-8") as _fh:
        for _p in json.load(_fh)["packets"]: PK[_p["packet_id"]] = _p
IDX  = J("packet_index.json")["index"]
TRA  = {t["trait_id"]: t for t in J("traits.json")["traits"]}
ARMS = {"None":"—","Light":"6+","Medium":"5+","Heavy":"4+"}
ROLE_C = {"Pressure":"#e0564a","Anchor":"#5a9bd4","Utility":"#c9a23f"}

def price(u):  # mirror balance.py so the banner shows the same points
    from math import comb
    ARM={"None":0,"Light":2,"Medium":6,"Heavy":12}
    EFF={"Push":.5,"Pull":.6,"Knockdown":1.1,"Guard":.8,"Cleave":1.4,"Execute":1.6,"Terror":.7,"ignore Armour":0}
    def win(e):
        for x in e:
            if x.endswith("Wound") or x.endswith("Wounds"): return int(x.split()[0])
        return 0
    def out(p):
        if p.get("dice",0)==0: return 0.0
        q=(7-p["success"])/6; tot=0
        for k in range(p["dice"]+1):
            pk=comb(p["dice"],k)*q**k*(1-q)**(p["dice"]-k)
            w,eff=0,()
            for g in p["grades"]:
                if k>=g["successes"]: w,eff=win(g["effects"]),g["effects"]
            wv=w*(1.55 if "ignore Armour" in eff else 1); tot+=pk*wv+pk*sum(EFF.get(e,0) for e in eff)
        return tot
    s=u["stats"]; b=u["base"]; tr=u.get("traits",[])
    best=max([out(PK[i]) for i in u["packets"]]+[0])
    p=3+2.1*s["max_wounds"]+ARM[s["armour"]]+3*max(0,s["max_ap"]-2)+.45*max(0,s["speed"]-6)+10.5*best
    if any(PK[i]["range"]>0 and PK[i]["dice"]>0 for i in u["packets"]): p+=3.5
    for t,v in (("reach",2),("mounted",3),("unstoppable",4),("flying",5),("large",2.5),("scaled",2.5),("radiant",3),("leader",6),("champion",4),("zealous",1.5),("sacred_banner",3),("shield",6.5)):
        if t in tr: p+=v
    if "fearless" in tr or "consecrated" in tr: p+=2.5
    p+=3*len([i for i in u["packets"] if PK[i]["dice"]==0 and i not in("brace","berserk_frenzy","skulk")])
    if b["shape"]=="Square" and s["nerve"]<=2: p+=1
    if b["shape"]=="Square" and s["nerve"]>=5: p-=1.5
    return max(3,round(p))

# --- per-unit export JSON (self-contained: packets + traits expanded) for TTS ---
UNIT_JSON = {}
def unit_json(u, fac_name):
    return {
        "schema": "cus-0.6-unit",
        "definition_id": u["definition_id"], "name": u["name"], "faction": fac_name,
        "role": u["role"], "tempo": u.get("tempo",">>"), "tool": u["tool"],
        "temperament": u["temperament"], "creature_type": u["creature_type"],
        "archetype": u.get("archetype",""), "rank": u.get("rank","I"),
        "tier": u.get("tier"), "slot": u.get("slot"),
        "base": u["base"], "stats": u["stats"], "points": price(u),
        "traits": [ {"trait_id": t, "name": TRA.get(t,{}).get("name",t),
                     "note": TRA.get(t,{}).get("note","")} for t in u.get("traits",[]) ],
        "packets": [ PK[pid] for pid in u["packets"] ],
    }

def grade_str(p):
    if p.get("dice",0)==0:
        g=p["grades"][0]; return " · ".join(html.escape(e) for e in g["effects"])
    rows=[]
    for g in p["grades"]:
        rows.append(f'<span class="gr"><b>G{g["grade"]}</b> {html.escape(", ".join(g["effects"]))}</span>')
    return "".join(rows)

def packet_card(pid):
    p=PK[pid]; idx=IDX.get(pid,{})
    head=f'{p["name"]}'
    if p.get("dice",0)>0:
        rng = f'{int(p["range"])}"' if p["range"]>0 else "melee"
        meta=f'{p["dice"]}d · {p["success"]}+ · {rng}'
    else:
        meta=f'{p["verb"]}'+ (f' · trigger: {html.escape(p.get("trigger",""))}' if p.get("trigger") else '')
    tags="".join(f'<i>{html.escape(t)}</i>' for t in idx.get("tags",[]))
    return f'<div class="pk"><div class="pkh"><b>{html.escape(head)}</b><span>{meta}</span></div><div class="grades">{grade_str(p)}</div><div class="tags">{tags}</div></div>'

def unit_card(u, fac_name=""):
    UNIT_JSON[u["definition_id"]] = unit_json(u, fac_name)
    s=u["stats"]; b=u["base"]; role=u["role"]; col=ROLE_C.get(role,"#888")
    traits="".join(f'<span class="trait" title="{html.escape(TRA.get(t,{}).get("note",""))}">{html.escape(TRA.get(t,{}).get("name",t))}</span>' for t in u.get("traits",[]))
    packets="".join(packet_card(i) for i in u["packets"])
    stat=lambda lbl,val:f'<div class="st"><span>{lbl}</span><b>{val}</b></div>'
    nerve = "—" if b["shape"]=="Circle" else s["nerve"]
    if u.get("tier"):   # library profile → show SLOT instead of PTS
        sl = u.get("slot", 1)
        slot_str = "—" if sl == 0 else ("½" if sl == 0.5 else str(int(sl)))
        last = stat("SLOT", slot_str)
    else:
        last = stat("PTS", price(u))
    stats=(stat("W",s["max_wounds"])+stat("ARM",ARMS[s["armour"]])+stat("AP",s["max_ap"])
           +stat("SPD",f'{s["speed"]:g}"')+stat("NRV",nerve)+last)
    tier_badge = f' · <b>{html.escape(u["tier"])}</b>' if u.get("tier") else ''
    return f'''<div class="card" style="--role:{col}">
      <div class="chead"><div><h3>{html.escape(u["name"])}</h3>
        <div class="arch">{html.escape(u["archetype"])} · rank {u["rank"]}{tier_badge}</div></div>
        <div class="chead-r"><div class="rolebadge">{role}</div>
          <button class="copyjson" onclick="copyJSON('{u["definition_id"]}',this)" title="Copy this unit as JSON (for Tabletop Simulator)">⧉ JSON</button></div></div>
      <div class="axes">{b["shape"]} / {b["size"]}{' · mounted' if b['mounted'] else ''}
        · {u["tool"]} · Tempo {u["tempo"]} · {u["temperament"]} · {u["creature_type"]}</div>
      <div class="stats">{stats}</div>
      <div class="traits">{traits}</div>
      <div class="packets">{packets}</div></div>'''

def group(units, pred):
    return [u for u in units if pred(u)]

def faction_section(fac):
    units=fac["units"]
    def band(title, us):
        if not us: return ""
        return f'<h2 class="band">{title} <span>{len(us)}</span></h2><div class="grid">'+"".join(unit_card(u, fac["faction"]) for u in us)+'</div>'
    if fac.get("is_library") or any("tier" in u for u in units):
        # LIBRARY / BESTIARY: group by tier, in first-appearance order
        tiers = []
        for u in units:
            t = u.get("tier","Other")
            if t not in tiers: tiers.append(t)
        bands = "".join(band(t, [u for u in units if u.get("tier")==t]) for t in tiers)
        meta = f'{len(units)} ' + ("enemies" if fac.get("is_enemy") else "generic profiles")
    else:
        champ=group(units, lambda u:"champion" in u.get("traits",[]))
        leaders=group(units, lambda u:"leader" in u.get("traits",[]) and "champion" not in u.get("traits",[]))
        util=group(units, lambda u:u["role"]=="Utility" and "leader" not in u.get("traits",[]))
        line=group(units, lambda u:u["rank"]=="I" and u["role"]!="Utility")
        spec=[u for u in units if u not in champ+leaders+util+line]
        bands = band("Champion",champ)+band("Command",leaders)+band("Fireteam Line",line)+band("Specialists",spec)+band("Utility",util)
        meta = f'{len(units)} definitions · {sum(price(u) for u in units)} pts roster'
    return f'''<section class="fac">
      <div class="fachead"><div style="display:flex;justify-content:space-between;align-items:baseline;gap:12px;flex-wrap:wrap"><h1>{html.escape(fac["faction"])}</h1>
        <button class="copyall" onclick="copyFaction('{html.escape(fac["faction"])}',this)" title="Copy the whole faction as JSON">⧉ Copy whole faction</button></div>
        <div class="prefix">{fac["prefix"]} · {meta}</div>
        <p class="doctrine">{html.escape(fac.get("doctrine",""))}</p></div>
      {bands}
    </section>'''

CSS = """
:root{--bg:#12141a;--pane:#1b1e27;--card:#20242f;--ink:#e8ecf5;--dim:#9aa3b5;--line:#2c3140;--gold:#c9a23f;}
@media(prefers-color-scheme:light){:root{--bg:#eceef3;--pane:#fff;--card:#fbfbfd;--ink:#1a1d26;--dim:#5a6273;--line:#dde1ea;}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:14px/1.5 'Segoe UI',system-ui,sans-serif}
.wrap{max-width:1180px;margin:0 auto;padding:28px 20px 80px}
.top{display:flex;justify-content:space-between;align-items:baseline;border-bottom:2px solid var(--gold);padding-bottom:12px;margin-bottom:8px;flex-wrap:wrap;gap:8px}
.top h1{margin:0;font-size:22px;letter-spacing:.5px}.top .v{color:var(--dim);font-size:13px}
.tabs{display:flex;gap:8px;margin:18px 0 6px}
.tab{cursor:pointer;padding:8px 16px;border:1px solid var(--line);border-radius:8px;background:var(--pane);color:var(--dim);font-weight:600}
.tab.on{color:var(--ink);border-color:var(--gold);box-shadow:inset 0 -2px 0 var(--gold)}
.fac{display:none}.fac.on{display:block}
.fachead h1{font-size:26px;margin:14px 0 2px}.prefix{color:var(--dim);font-size:13px}
.doctrine{color:var(--dim);max-width:70ch;font-style:italic;margin:8px 0 4px}
.band{font-size:14px;letter-spacing:2px;text-transform:uppercase;color:var(--gold);margin:26px 0 10px;border-bottom:1px solid var(--line);padding-bottom:6px}
.band span{color:var(--dim);font-size:12px}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(320px,1fr));gap:14px}
.card{background:var(--card);border:1px solid var(--line);border-left:4px solid var(--role);border-radius:10px;padding:14px}
.chead{display:flex;justify-content:space-between;align-items:flex-start;gap:8px}
.chead h3{margin:0;font-size:17px}.arch{color:var(--dim);font-size:12px;margin-top:2px}
.rolebadge{background:var(--role);color:#0d0f14;font-weight:700;font-size:11px;padding:3px 9px;border-radius:20px;white-space:nowrap}
.axes{color:var(--dim);font-size:12px;margin:8px 0 10px}
.stats{display:grid;grid-template-columns:repeat(6,1fr);gap:4px;margin-bottom:10px}
.st{background:var(--pane);border-radius:6px;text-align:center;padding:5px 2px}
.st span{display:block;color:var(--dim);font-size:10px;letter-spacing:.5px}.st b{font-size:15px}
.traits{display:flex;flex-wrap:wrap;gap:5px;margin-bottom:10px}
.trait{background:transparent;border:1px solid var(--gold);color:var(--gold);font-size:11px;padding:2px 8px;border-radius:20px;cursor:help}
.packets{display:flex;flex-direction:column;gap:7px}
.pk{background:var(--pane);border:1px solid var(--line);border-radius:8px;padding:8px 10px}
.pkh{display:flex;justify-content:space-between;gap:8px;font-size:13px}.pkh span{color:var(--dim);font-size:12px;white-space:nowrap}
.grades{display:flex;flex-direction:column;gap:2px;margin-top:5px}
.gr{font-size:12px;color:var(--ink)}.gr b{color:var(--gold);margin-right:4px}
.tags{margin-top:5px;display:flex;flex-wrap:wrap;gap:4px}.tags i{font-style:normal;font-size:10px;color:var(--dim);background:var(--card);border:1px solid var(--line);padding:1px 6px;border-radius:10px}
.legend{color:var(--dim);font-size:12px;margin-top:6px}
.chead-r{display:flex;flex-direction:column;align-items:flex-end;gap:6px}
.copyjson{cursor:pointer;font:600 10px/1 'Segoe UI',system-ui,sans-serif;color:var(--dim);background:var(--pane);border:1px solid var(--line);border-radius:6px;padding:4px 8px;white-space:nowrap;transition:all .12s}
.copyjson:hover{color:var(--ink);border-color:var(--gold)}
.copyjson.ok{color:#3a3;border-color:#3a3}
.copyall{cursor:pointer;font:600 11px/1 'Segoe UI',system-ui,sans-serif;color:var(--ink);background:var(--pane);border:1px solid var(--gold);border-radius:7px;padding:7px 12px;margin-left:auto}
.copyall.ok{color:#3a3;border-color:#3a3}
"""

JS = """
function show(n){document.querySelectorAll('.fac').forEach((f,i)=>f.classList.toggle('on',i==n));
document.querySelectorAll('.tab').forEach((t,i)=>t.classList.toggle('on',i==n));}
function flash(btn,txt){var o=btn.textContent;btn.textContent=txt;btn.classList.add('ok');setTimeout(function(){btn.textContent=o;btn.classList.remove('ok')},1200);}
function copyText(t,btn){if(navigator.clipboard&&navigator.clipboard.writeText){navigator.clipboard.writeText(t).then(function(){flash(btn,'\\u2713 Copied')}).catch(function(){window.prompt('Copy this JSON:',t)});}else{window.prompt('Copy this JSON:',t);}}
function copyJSON(id,btn){copyText(JSON.stringify(UNIT_JSON[id],null,2),btn);}
function copyFaction(n,btn){var ids=FACTION_UNITS[n]||[];var arr=ids.map(function(i){return UNIT_JSON[i]});copyText(JSON.stringify({faction:n,units:arr},null,2),btn);}
show(0);
"""

FACTION_FILES = [
    ("faction_templar.json",   "⚔", "Argent Templar"),
    ("faction_mordor.json",    "☠", "Iron Horde of Mordor"),
    ("faction_militia.json",   "🛡", "Freeholt Militia"),
    ("faction_goblin.json",    "🗡", "Rustfang Goblins"),
    ("faction_lizardfolk.json","🦎", "Scaled Legion"),
    ("faction_pony.json",      "🦄", "Harmony Guard"),
    ("faction_dragon.json",    "🐉", "The Dragon (Boss)"),
    ("library_generic.json",   "⚙", "Generic Library"),
    ("faction_bestiary.json",  "🧟", "Bestiary (Enemies)"),
]

def build():
    tabs, secs = [], []
    for idx, (fn, emoji, short) in enumerate(FACTION_FILES):
        path = os.path.join(DATA, fn)
        if not os.path.exists(path): continue
        fac = J(fn)
        on = " on" if idx == 0 else ""
        tabs.append(f'<div class="tab{on}" onclick="show({idx})">{emoji} {html.escape(short)}</div>')
        sec = faction_section(fac)
        if idx == 0:
            sec = sec.replace('<section class="fac">', '<section class="fac on">', 1)
        secs.append(sec)
    body=f'''<div class="wrap">
      <div class="top"><h1>CUS · FACTION BANNERS</h1>
        <div class="v">v0.6 Kernel · Success Grades (Model-2 discrete) · Roles = Pressure · Anchor · Utility</div></div>
      <div class="legend">Each card is a Figure Definition: base shape/size, Tool, Tempo (&gt;/&gt;&gt;/&gt;&gt;&gt;), Temperament, Creature Type; its stat line (Wounds · Armour save · AP · Speed · Nerve · Points); Traits; and every referenced PACKET with its Grade ladder — resolve the highest Grade reached, that line only.</div>
      <div class="legend" style="margin-top:4px">Each card has a <b>⧉ JSON</b> button — copies that unit's full v0.6 definition (packets &amp; traits expanded, self-contained) to your clipboard for Tabletop Simulator. Each faction header has a <b>⧉ Copy whole faction</b> button too.</div>
      <div class="tabs">{''.join(tabs)}</div>
      {''.join(secs)}
    </div>'''
    fac_units = {}
    for did, uj in UNIT_JSON.items():
        fac_units.setdefault(uj["faction"], []).append(did)
    data_script = f'<script>const UNIT_JSON={json.dumps(UNIT_JSON,ensure_ascii=False)};const FACTION_UNITS={json.dumps(fac_units,ensure_ascii=False)};</script>'
    page=f'<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>CUS Faction Banners</title><style>{CSS}</style></head><body>{body}{data_script}<script>{JS}</script></body></html>'
    out=os.path.join(HERE,"..","BANNER.html")
    with open(out,"w",encoding="utf-8") as f: f.write(page)
    print("wrote", os.path.abspath(out), f"({len(page)} bytes) — {len(secs)} factions")

if __name__=="__main__": build()
