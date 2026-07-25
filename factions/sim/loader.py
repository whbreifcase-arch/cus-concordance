"""Load the v0.6 JSON (packets.json + faction_*.json) into engine Definitions.
The engine consumes v0.6 DATA DIRECTLY — no Module-K, no migration adapter."""
from __future__ import annotations
import json, os
from engine import PacketDef, Grade, FigureType

DATA = os.path.join(os.path.dirname(__file__), "..", "data")
REACH_PACKETS = {"consecrated_halberd", "uruk_pike", "barbed_whip"}

def _mk_packet(p):
    grades = tuple(Grade(g["successes"], tuple(g["effects"])) for g in p["grades"])
    rng = float(p.get("range", 0))
    dice = int(p.get("dice", 0))
    is_ranged = rng > 0 and dice > 0
    return PacketDef(
        packet_id=p["packet_id"], name=p["name"], verb=p["verb"],
        dice=dice, success=int(p.get("success", 0)), rng=rng,
        cost_ap=int(p.get("cost_ap", 1)), grades=grades,
        reach=bool(p.get("reach", p["packet_id"] in REACH_PACKETS)), is_ranged=is_ranged,
        trigger=p.get("trigger", ""))

def load_packets(path=None):
    import glob
    files = [path] if path else sorted(glob.glob(os.path.join(DATA, "packets*.json")))
    out = {}
    for fp in files:
        with open(fp, encoding="utf-8") as f:
            raw = json.load(f)
        for p in raw["packets"]:
            out[p["packet_id"]] = _mk_packet(p)
    return out

def load_faction(path, packets):
    with open(path, encoding="utf-8") as f:
        raw = json.load(f)
    fac = raw["faction"]
    units = []
    for u in raw["units"]:
        b = u["base"]; s = u["stats"]
        pk = tuple(packets[pid] for pid in u["packets"])
        units.append(FigureType(
            definition_id=u["definition_id"], name=u["name"], faction=fac,
            role=u["role"], tempo=u.get("tempo", ">>"), tool=u["tool"],
            temperament=u["temperament"], creature_type=u["creature_type"],
            archetype=u.get("archetype", ""), rank=u.get("rank", "I"),
            shape=b["shape"], size=b["size"], mounted=bool(b.get("mounted", False)),
            max_wounds=int(s["max_wounds"]), armour=s["armour"], nerve=int(s.get("nerve", 3)),
            speed=float(s["speed"]), max_ap=int(s["max_ap"]),
            traits=tuple(u.get("traits", [])), packets=pk, points=int(u.get("points", 0))))
    return fac, units

def load_all():
    import glob
    packets = load_packets()
    facs = {}
    for fn in sorted(glob.glob(os.path.join(DATA, "faction_*.json"))):
        name, units = load_faction(fn, packets)
        facs[name] = {u.definition_id: u for u in units}
    return packets, facs

if __name__ == "__main__":
    pks, facs = load_all()
    print(f"packets: {len(pks)}")
    for fac, units in facs.items():
        print(f"\n{fac} — {len(units)} units")
        for u in units.values():
            print(f"  {u.name:22} {u.role:8} {u.tool:6} {u.shape}/{u.size:6} "
                  f"W{u.max_wounds} {u.armour:6} AP{u.max_ap} nerve{u.nerve} "
                  f"[{','.join(p.packet_id for p in u.packets)}]")
