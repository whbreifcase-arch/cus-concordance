"""
CUS v0.6 — pricing + parallel balance harness.

  * price(unit): a transparent, auditable points value from the unit's real
    expected output (binomial over its PACKET Grades, Model-2 discrete) plus
    durability, mobility, command and trait value.
  * A "Banner" = Champion + line + specialists, assembled to a points budget.
  * play_match(): N games, alternating which side deploys/activates first and
    varying terrain, so first-mover and map bias cancel. rate0 = 0.50 is balanced.
  * Parallel over all cores with multiprocessing.

Run:  python balance.py           (price table + a 150-pt banner match)
      python balance.py rr 600    (600-game round-robin, parallel)
"""
from __future__ import annotations
import sys, math, random, statistics
from math import comb
from multiprocessing import Pool, cpu_count
from engine import Board, Wall, Platform, LowCover, Figure, Metrics
from game import Game
from loader import load_all

PACKETS, FACS = load_all()
TMP = FACS["Order of the Argent Templar"]
MOR = FACS["The Iron Horde of Mordor"]
ALL = {}
for _u in FACS.values(): ALL.update(_u)

def find_faction(sub):
    sub = sub.lower()
    for name, units in FACS.items():
        hay = name.lower() + " " + " ".join(
            (u.archetype + " " + u.name + " " + u.definition_id) for u in units.values()).lower()
        if sub in hay:
            return name, units
    raise SystemExit(f"no faction matching '{sub}' — have: " + ", ".join(FACS))

# --------------------------------------------------------------------------- #
#  PRICING
# --------------------------------------------------------------------------- #
ARM_PTS   = {"None": 0.0, "Light": 2.0, "Medium": 6.0, "Heavy": 12.0}
EFFECT_VAL = {"Push": 0.5, "Pull": 0.6, "Knockdown": 1.1, "Guard": 0.8,
              "Cleave": 1.4, "Execute": 1.6, "Terror": 0.7, "ignore Armour": 0.0}

def _wounds_in(effects):
    for e in effects:
        if e.endswith("Wound") or e.endswith("Wounds"):
            return int(e.split()[0])
    return 0

def exp_output(p):
    """Expected per-ACTION value of a PACKET (Model-2 discrete over its Grades)."""
    if p.dice == 0: return 0.0
    q = (7 - p.success) / 6.0
    def resolved(k):
        w, eff = 0, ()
        for g in p.grades:
            if k >= g.successes: w, eff = _wounds_in(g.effects), g.effects
        return w, eff
    total = 0.0
    for k in range(0, p.dice + 1):
        pk = comb(p.dice, k) * q**k * (1-q)**(p.dice-k)
        w, eff = resolved(k)
        wv = w * (1.55 if "ignore Armour" in eff else 1.0)      # armour-pierce premium
        total += pk * wv
        total += pk * sum(EFFECT_VAL.get(e, 0) for e in eff)
    return total

def price(u):
    best_atk = max((exp_output(p) for p in (u.melee_packets + u.ranged_packets)), default=0.0)
    pts  = 3.0
    pts += 2.1 * u.max_wounds
    pts += 1.4 * max(0, u.max_wounds - 4) ** 1.5   # monster durability is premium (compounds w/ armour)
    pts += ARM_PTS[u.armour]
    pts += 3.0 * max(0, u.max_ap - 2)
    pts += 0.45 * max(0.0, u.speed - 6)
    pts += 10.5 * best_atk
    if u.ranged_packets:                   pts += 3.5
    if u.has_trait("reach"):               pts += 2.0
    if u.has_trait("mounted"):             pts += 3.0
    if u.has_trait("flying"):              pts += 5.0   # over walls (boss is fielded solo, so its price is moot)
    if u.has_trait("unstoppable"):         pts += 4.0
    if u.has_trait("large"):               pts += 2.5
    if u.has_trait("scaled"):              pts += 2.5
    if u.has_trait("beast"):               pts += 1.0
    if u.has_trait("radiant"):             pts += 3.0
    if u.has_trait("leader"):              pts += 6.0
    if u.has_trait("champion"):            pts += 4.0
    if u.has_trait("fearless") or u.has_trait("consecrated"): pts += 2.5
    if u.has_trait("zealous"):             pts += 1.5
    if u.has_trait("sacred_banner"):       pts += 3.0
    if u.has_trait("shield"):              pts += 6.5   # the intercept reaction (brace priced here, not as a util packet)
    # utility packets (heal/rally/curse/command) each add a flat value
    util = [p for p in u.packets if p.dice == 0 and p.packet_id not in ("brace","berserk_frenzy","skulk")]
    pts += 3.0 * len(util)
    # bravery: a low Nerve number (Square) is worth a little
    if u.shape == "Square" and u.nerve <= 2:  pts += 1.0
    if u.shape == "Square" and u.nerve >= 5:  pts -= 1.5
    return max(3, round(pts))

def price_table():
    print(f"{'UNIT':24}{'FAC':4}{'ROLE':9}{'W':>2}{'ARM':>7}{'AP':>3}{'SPD':>4}{'NRV':>4}{'  PTS':>6}")
    for fac_short, units in (("TMP", TMP), ("MOR", MOR)):
        for u in units.values():
            print(f"{u.name:24}{fac_short:4}{u.role:9}{u.max_wounds:>2}{u.armour:>7}"
                  f"{u.max_ap:>3}{u.speed:>4.0f}{u.nerve:>4}{price(u):>6}")

# --------------------------------------------------------------------------- #
#  BANNERS  (Champion + line + specialists to a budget)
# --------------------------------------------------------------------------- #
TEMPLAR_BANNER = [   # ~ a themed 150-ish pt warband
    "TMP_GRANDMASTER", "TMP_CHAPLAIN",
    "TMP_SWORDBROTHER", "TMP_SHIELDBROTHER", "TMP_SHIELDBROTHER",
    "TMP_HALBERDIER", "TMP_CONFESSOR", "TMP_ARBALEST", "TMP_LANCER",
]
MORDOR_BANNER = [
    "MOR_CAPTAIN", "MOR_SHAMAN",
    "MOR_BERSERKER", "MOR_WARRIOR", "MOR_WARRIOR", "MOR_PIKEMAN",
    "MOR_CROSSBOW", "MOR_ORC", "MOR_ORC", "MOR_ARCHER", "MOR_WARG", "MOR_TROLL",
]

def banner_points(ids): return sum(price(ALL[i]) for i in ids)

def auto_banner(units, budget, max_copies=3):
    """Build a themed banner from a whole faction roster up to a points budget:
    the Champion, then one of each unit cheapest-first, then extra copies of the
    cheap line to fill the remaining points."""
    ids = list(units)
    champ = [i for i in ids if units[i].has_trait("champion")]
    banner = champ[:1]
    rest = sorted([i for i in ids if i not in banner], key=lambda i: price(units[i]))
    for i in rest:
        if banner_points(banner) + price(units[i]) <= budget:
            banner.append(i)
    counts = {i: banner.count(i) for i in banner}
    fillers = [i for i in rest if not units[i].has_trait("champion")]
    gi = 0
    while gi < 800 and fillers:
        i = fillers[gi % len(fillers)]
        if counts.get(i, 0) < max_copies and banner_points(banner) + price(units[i]) <= budget:
            banner.append(i); counts[i] = counts.get(i, 0) + 1
        gi += 1
        if banner_points(banner) >= budget - 6: break
    return banner

def make_banner_to_budget(base_ids, pool_ids, budget):
    """Trim/extend a banner toward a points budget (greedy)."""
    ids = list(base_ids)
    # trim if over
    while banner_points(ids) > budget and len(ids) > 4:
        # drop the cheapest non-champion
        cand = sorted([i for i in ids if not ALL[i].has_trait("champion")], key=lambda i: price(ALL[i]))
        ids.remove(cand[0])
    # extend if well under
    filler = sorted(pool_ids, key=lambda i: price(ALL[i]))
    gi = 0
    while banner_points(ids) < budget - 6 and gi < 400:
        add = filler[gi % len(filler)]
        if banner_points(ids) + price(ALL[add]) <= budget:
            ids.append(add)
        gi += 1
    return ids

# --------------------------------------------------------------------------- #
#  DEPLOYMENT + MATCH
# --------------------------------------------------------------------------- #
def _terrain(seed):
    r = random.Random(seed)
    kind = seed % 3
    if kind == 0:      # central gate/choke + flanking ridges
        return Board(44, 30,
            walls=[Wall(22,3,22,12,5), Wall(22,18,22,27,5)],
            platforms=[Platform(2,2,7,28,3), Platform(37,2,42,28,3)],
            covers=[LowCover(18,13,20,17), LowCover(24,13,26,17)])
    if kind == 1:      # scattered cover, one big hill center
        return Board(44, 30,
            walls=[Wall(14,8,18,8,4), Wall(26,22,30,22,4)],
            platforms=[Platform(18,10,26,20,3)],
            covers=[LowCover(8,6,12,10), LowCover(32,20,36,24)])
    return Board(44, 30,    # open field with light cover
            covers=[LowCover(15,12,19,16), LowCover(25,14,29,18), LowCover(20,4,24,8)])

def _deploy(board, ids, side, seed):
    r = random.Random(seed*7+side)
    figs = []
    x = 5.0 if side == 0 else 39.0
    face = 0.0 if side == 0 else math.pi
    n = len(ids)
    ys = [3.0 + i*(24.0/max(1, n-1)) for i in range(n)]
    for i, did in enumerate(ids):
        jx = x + r.uniform(-1.5, 1.5)
        f = Figure(ALL[did], side, f"{'AB'[side]}{i}", jx, ys[i]+r.uniform(-0.6,0.6), facing=face)
        figs.append(f)
    return figs

def one_game(args):
    ids0, ids1, seed, swap = args
    board = _terrain(seed)
    a_ids, b_ids = (ids1, ids0) if swap else (ids0, ids1)   # swap seats
    figs = _deploy(board, a_ids, 0, seed) + _deploy(board, b_ids, 1, seed)
    m = Metrics()
    res = Game(board, figs, seed=seed, metrics=m, max_rounds=12).run()
    w = res["winner"]
    # normalize winner back to faction-0 / faction-1 frame
    if swap:
        w = None if w is None else (1 - w)
    return (w, res["reason"], res["rounds"],
            {k: m.get(k) for k in ("counters","charge_bonus","highground","flank",
             "knockdown","cleave","execute","routs","reach_strikes","nerve_tests","pushes","slain")})

def round_robin(ids0, ids1, games=600, seed0=20000, workers=None):
    workers = workers or max(1, cpu_count()-2)
    tasks = [(ids0, ids1, seed0+g, (g % 2 == 1)) for g in range(games)]
    with Pool(workers) as pool:
        out = pool.map(one_game, tasks, chunksize=8)
    w0 = sum(1 for w,_,_,_ in out if w == 0)
    w1 = sum(1 for w,_,_,_ in out if w == 1)
    draw = sum(1 for w,_,_,_ in out if w is None)
    rounds = statistics.mean(r for _,_,r,_ in out)
    agg = {}
    for _,_,_,mm in out:
        for k,v in mm.items(): agg[k] = agg.get(k,0)+v
    rate0 = (w0 + 0.5*draw)/games
    return {"games":games,"w0":w0,"w1":w1,"draws":draw,"rate0":rate0,
            "mean_rounds":round(rounds,1),"fires":agg,"workers":workers}

# --------------------------------------------------------------------------- #
if __name__ == "__main__":
    if len(sys.argv) >= 4 and sys.argv[1] == "vs":
        na, ua = find_faction(sys.argv[2]); nb, ub = find_faction(sys.argv[3])
        games  = int(sys.argv[4]) if len(sys.argv) > 4 else 1000
        budget = int(sys.argv[5]) if len(sys.argv) > 5 else 360
        budgetB= int(sys.argv[6]) if len(sys.argv) > 6 else budget
        ba, bb = auto_banner(ua, budget), auto_banner(ub, budgetB)
        print(f"A · {na}  {banner_points(ba)} pts, {len(ba)} figs")
        print(f"B · {nb}  {banner_points(bb)} pts, {len(bb)} figs")
        print(f"Running {games} games on {max(1,cpu_count()-2)} cores...")
        res = round_robin(ba, bb, games=games)
        print(f"\n  A ({na.split()[-1]}) win-rate: {res['rate0']*100:.1f}%   "
              f"(W {res['w0']} / L {res['w1']} / D {res['draws']})   mean {res['mean_rounds']} rounds")
    elif len(sys.argv) >= 2 and sys.argv[1] == "rr":
        games = int(sys.argv[2]) if len(sys.argv) > 2 else 600
        budget = int(sys.argv[3]) if len(sys.argv) > 3 else 360
        t = make_banner_to_budget(TEMPLAR_BANNER, list(TMP), budget)
        m = make_banner_to_budget(MORDOR_BANNER, list(MOR), budget)
        print(f"Templar Banner  {banner_points(t)} pts, {len(t)} figs: {[ALL[i].name for i in t]}")
        print(f"Mordor  Banner  {banner_points(m)} pts, {len(m)} figs: {[ALL[i].name for i in m]}")
        print(f"\nRunning {games} games on {max(1,cpu_count()-2)} cores (swapped seats, varied terrain)...")
        res = round_robin(t, m, games=games)
        print(f"\n  Templar win-rate (rate0): {res['rate0']*100:.1f}%   "
              f"(W {res['w0']} / L {res['w1']} / D {res['draws']})")
        print(f"  mean rounds: {res['mean_rounds']}")
        print("  mechanic fire-counts across all games:")
        for k,v in sorted(res["fires"].items()): print(f"    {k:14} {v}")
    else:
        price_table()
        print(f"\nTemplar Banner base: {banner_points(TEMPLAR_BANNER)} pts")
        print(f"Mordor  Banner base: {banner_points(MORDOR_BANNER)} pts")
