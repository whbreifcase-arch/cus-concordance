"""
Convert the real CUS profiles (generic library + every faction + bestiary) into
the Charge Lab's unit model, and inject them into CHARGE_LAB.html between the
markers  /*UNITS_START*/  ...  /*UNITS_END*/ .

Run:  python make_lab_units.py
"""
import json, os, glob, re

HERE = os.path.dirname(__file__)
DATA = os.path.join(HERE, "..", "data")
HTML = os.path.join(HERE, "..", "CHARGE_LAB.html")

def load(name):
    p = os.path.join(DATA, name)
    if not os.path.exists(p): return None
    with open(p, encoding="utf-8") as f: return json.load(f)

# ---- merge every packet file into one id->packet map ----------------------- #
PACKETS = {}
for pf in ["packets.json", "packets_generic.json", "packets_bestiary.json",
           "packets_family.json"]:
    d = load(pf)
    if not d: continue
    for pk in d.get("packets", []):
        PACKETS[pk["packet_id"]] = pk

REACH_NAME = re.compile(r"REACH|SPEAR|PIKE|HALBERD|POLEARM|GLAIVE", re.I)  # NOT lance (that's impact)
SHIELD_NAME = re.compile(r"SHIELD", re.I)
LANCE_NAME  = re.compile(r"LANCE|CHARGE|IMPACT", re.I)
SPELLY = re.compile(r"WAND|STAFF|BREATH|BOLT|CURSE|DRAIN|RAISE|HEX|FLAME|SUMMON", re.I)

def melee_weapon(unit):
    """Pick the profile's primary melee packet; convert to the sim weapon model."""
    best = None
    for pid in unit.get("packets", []):
        pk = PACKETS.get(pid)
        if not pk: continue
        rng = pk.get("range", 0) or 0
        reach_flag = bool(pk.get("reach", False))
        # skip pure ranged / spell packets for the COLLISION weapon
        if rng and not reach_flag: continue
        if SPELLY.search(pk.get("name","")): continue
        best = pk; break
    if best is None:  # fall back to first packet or a fist
        best = PACKETS.get((unit.get("packets") or [None])[0]) or \
               {"name":"UNARMED","dice":2,"success":4,"range":0,
                "grades":[{"successes":1,"effects":["1 Wound"]}]}
    name = best.get("name","WEAPON")
    reach = 2.0 if (best.get("reach") or REACH_NAME.search(name)) else 0.0
    grades = [[g["successes"], g["effects"]] for g in best.get("grades", [])] \
             or [[1, ["1 Wound"]]]
    traits = unit.get("traits", []) or []
    shield = ("shield" in [t.lower() for t in traits]) or bool(SHIELD_NAME.search(name))
    mounted = bool(unit.get("base", {}).get("mounted"))
    impact = mounted or bool(LANCE_NAME.search(name))
    return {"name": name, "dice": best.get("dice",3), "hit": best.get("success",4),
            "reach": reach, "shield": shield, "impact": impact, "grades": grades}

def convert(unit, src):
    base = unit.get("base", {}); st = unit.get("stats", {})
    return {
        "id": unit.get("definition_id") or unit.get("name"),
        "name": unit.get("name","?"),
        "src": src,
        "tier": unit.get("tier") or unit.get("rank") or "Unit",
        "role": unit.get("role",""),
        "slot": unit.get("slot", 1),
        "shape": base.get("shape","Square"),
        "size": base.get("size","Medium"),
        "mounted": bool(base.get("mounted")),
        "wounds": st.get("max_wounds", 2),
        "armour": st.get("armour","Medium"),
        "nerve": st.get("nerve", 3),
        "temper": unit.get("temperament",""),
        "traits": unit.get("traits", []) or [],
        "w": melee_weapon(unit),
    }

SOURCES = [
    ("library_generic.json", "Generic Library"),
    ("faction_templar.json", "Templar"),
    ("faction_mordor.json",  "Mordor"),
    ("faction_militia.json", "Militia"),
    ("faction_goblin.json",  "Goblin"),
    ("faction_pony.json",    "Pony"),
    ("faction_lizardfolk.json","Lizardfolk"),
    ("faction_dragon.json",  "Dragon"),
    ("faction_bestiary.json","Bestiary"),
]
def build_units():
    units = []
    for fname, label in SOURCES:
        d = load(fname)
        if not d: continue
        for u in d.get("units", []):
            units.append(convert(u, label))
    return units

def main():
    units = build_units()
    blob = json.dumps(units, separators=(",", ":"), ensure_ascii=False)
    print(f"converted {len(units)} units from {len(SOURCES)} sources")
    with open(HTML, encoding="utf-8") as f: html = f.read()
    new = re.sub(r"/\*UNITS_START\*/.*?/\*UNITS_END\*/",
                 f"/*UNITS_START*/{blob}/*UNITS_END*/", html, flags=re.S)
    if new == html:
        print("!! markers /*UNITS_START*/.../*UNITS_END*/ not found in CHARGE_LAB.html")
    else:
        with open(HTML, "w", encoding="utf-8") as f: f.write(new)
        print(f"injected into {os.path.basename(HTML)} ({len(blob)} bytes)")

if __name__ == "__main__":
    main()
