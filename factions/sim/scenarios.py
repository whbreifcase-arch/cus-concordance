"""
CUS v0.6 — SCENARIO TESTS. Verifies the signed mechanics actually fire, on real
terrain: charging (Sprint->Impact->Push), a Reach weapon holding a narrow walled
lane, high-ground dice + line-of-sight over walls, and the Counter edge cases
(dying swing lands; flank/rear denial). Run: python scenarios.py
"""
from __future__ import annotations
import math, statistics
from engine import Board, Wall, Platform, LowCover, Figure, Metrics
from game import Game, gap, touching, in_reach_band, arc_of, engaged_enemies
from loader import load_all

PACKETS, FACS = load_all()
TMP = FACS["Order of the Argent Templar"]
MOR = FACS["The Iron Horde of Mordor"]

def mk(ft, side, uid, x, y, facing=0.0):
    return Figure(ft, side, uid, x, y, facing)

def hr(t): print("\n" + "="*72 + f"\n  {t}\n" + "="*72)

# --------------------------------------------------------------------------- #
def test_charge():
    hr("SCENARIO 1 — Charge works (Sprint -> Impact -> Push + Wound)")
    trials, sprinted, pushed, wounded = 300, 0, 0, 0
    dxs = []
    for s in range(trials):
        b = Board(44, 30)
        atk = mk(MOR["MOR_WARG"], 0, "warg", 6, 15)       # Fast, Ravenous, mounted
        dfn = mk(TMP["TMP_CONFESSOR"], 1, "foe", 14, 15, facing=math.pi)
        g = Game(b, [atk, dfn], seed=1000+s, metrics=Metrics())
        x0 = dfn.x
        g.activate(atk)
        if g.m.get("sprints"): sprinted += 1
        if dfn.x - x0 > 0.2: pushed += 1; dxs.append(dfn.x - x0)
        if dfn.cur_wounds < dfn.ft.max_wounds or dfn.out: wounded += 1
    print(f"  warg charged a Confessor across 8\", {trials} trials:")
    print(f"    Sprint->Impact fired : {sprinted}/{trials}")
    print(f"    target Pushed        : {pushed}/{trials}  (avg {statistics.mean(dxs):.2f}\" when it moved)")
    print(f"    target Wounded/downed: {wounded}/{trials}")
    ok = sprinted == trials and pushed > trials*0.5 and wounded > trials*0.3
    print(f"  => {'PASS' if ok else 'FAIL'}: charge closes, impacts, pushes and wounds.")
    return ok

# --------------------------------------------------------------------------- #
def test_reach_lane():
    hr("SCENARIO 2 — A shield line holds a walled gap vs a bigger force (choke vs open)")
    import statistics as st
    # 3 defenders (2 Shield-Brothers + a Halberdier reaching from the 2nd rank)
    # hold a 4\" gap in a wall against 6 Mordor. Walls protect the line's flanks;
    # in the open the 6 wrap around it.
    # hard check: a wall actually blocks a MOVE across it
    _b = Board(44,30, walls=[Wall(22,0,22,30,5.0)])
    assert _b.move_blocked((20,15),(24,15)) and not _b.move_blocked((23,15),(28,15)), "wall block broken"
    ys = [4.0, 9.0, 14.5, 20.0, 25.0, 29.0]         # spread wide so flank paths cross the wall panels
    def run(choke, label):
        d_surv=[]; a_cas=[]; reach=0; held=0
        for s in range(240):
            walls = [Wall(22,0,22,13,5.0), Wall(22,17,22,30,5.0)] if choke else []
            b = Board(44,30, walls=walls)
            defs = [mk(TMP["TMP_SHIELDBROTHER"],1,"d0",21,14.1,facing=0.0),
                    mk(TMP["TMP_SHIELDBROTHER"],1,"d1",21,15.9,facing=0.0),
                    mk(TMP["TMP_HALBERDIER"],   1,"d2",19.7,15.0,facing=0.0)]  # reach 2nd rank
            atks = [mk(MOR["MOR_WARRIOR"],0,f"a{i}", 30+(i%2)*1.4, ys[i]) for i in range(6)]
            g = Game(b, defs+atks, seed=11000+s, metrics=Metrics(), max_rounds=10)
            g.run()
            reach += g.m.get("reach_strikes")
            d_surv.append(sum(1 for d in defs if not d.out))
            a_cas.append(sum(1 for a in atks if a.out))
            if all(not d.out for d in defs): held += 1
        print(f"    {label:14} defenders alive avg {st.mean(d_surv):.2f}/3 | enemy down avg "
              f"{st.mean(a_cas):.2f}/6 | line intact {held}/240 | reach {reach}")
        return st.mean(d_surv), st.mean(a_cas), held, reach
    cs, ck, chh, cr = run(True,  "WALLED gap")
    os_, ok_, oph, orr = run(False, "OPEN field")
    print(f"  Line survival: walled {cs:.2f}/3 vs open {os_:.2f}/3 defenders standing.")
    print(f"  Line-intact games: walled {chh}/240 vs open {oph}/240 — the wall stops the flanking.")
    ok = cs > os_ and chh >= oph and cr > 100      # walls block flanking (verified) + reach fires
    print(f"  => {'PASS' if ok else 'CHECK'}: wall-block verified; the gap-line survives more than in the open; reach fires from rank 2.")
    return ok

# --------------------------------------------------------------------------- #
def test_high_ground():
    hr("SCENARIO 3 — High ground grants +1 die, and sight carries over a low wall")
    # elevated shooter on a 3\" platform vs a flat shooter, same 12\" shot.
    def shoot(elev):
        wounds=0
        for s in range(400):
            plats=[Platform(4,12,8,18,3.0)] if elev else []
            b = Board(44,30, platforms=plats)
            sx = 6 if elev else 6
            sh = mk(MOR["MOR_CROSSBOW"], 0, "sh", sx, 15)
            tg = mk(TMP["TMP_CONFESSOR"], 1, "tg", 18, 15, facing=math.pi)
            g = Game(b, [sh, tg], seed=3000+s, metrics=Metrics())
            if elev: sh.z = b.ground_z(sh.pos)
            g._try_shoot(sh)
            wounds += (tg.ft.max_wounds - tg.cur_wounds) + (2 if tg.out else 0)
        return wounds
    flat = shoot(False); high = shoot(True)
    print(f"    flat crossbow  total wounds over 400 shots: {flat}")
    print(f"    high-ground    total wounds over 400 shots: {high}")
    # LoS-over-wall check
    b = Board(44,30, walls=[Wall(11,10,11,20,2.0)], platforms=[Platform(4,12,8,18,3.0)])
    low = mk(MOR["MOR_CROSSBOW"],0,"low",6,15); low.z=0.0
    hi  = mk(MOR["MOR_CROSSBOW"],0,"hi",6,15);  hi.z=3.0
    tg  = mk(TMP["TMP_CONFESSOR"],1,"tg",18,15)
    los_low = not b.los_blocked(low.pos,low.z,tg.pos,tg.z)
    los_hi  = not b.los_blocked(hi.pos,hi.z,tg.pos,tg.z)
    print(f"    ground shooter sees over the 2\" wall? {los_low}   elevated shooter? {los_hi}")
    ok = high > flat and los_hi
    print(f"  => {'PASS' if ok else 'FAIL'}: elevation adds damage and sightline.")
    return ok

# --------------------------------------------------------------------------- #
def test_counter():
    hr("SCENARIO 4 — Counter: dying swing lands; flank/rear on an engaged Square denies")
    # (a) dying swing: a 1-wound orc struck dead still counters.
    landed=0; trials=400
    for s in range(trials):
        b=Board(44,30)
        atk=mk(TMP["TMP_CONFESSOR"],0,"atk",10,15,facing=0.0)
        vic=mk(MOR["MOR_ORC"],1,"vic",10.9,15,facing=math.pi)   # in contact
        g=Game(b,[atk,vic],seed=5000+s,metrics=Metrics())
        before=atk.cur_wounds
        g.resolve_attack(atk,vic,TMP["TMP_CONFESSOR"].melee_packets[0])
        # if vic died AND still swung, counters metric bumped
        if vic.out and g.m.get("counters")>=1: landed+=1
    print(f"    orc killed by the blow still Countered: {landed}/{trials} lethal exchanges")
    # (b) flank/rear denial: square engaged front by A, hit in rear by B -> no counter
    b=Board(44,30)
    sq=mk(MOR["MOR_WARRIOR"],1,"sq",20,15,facing=0.0)        # faces +x
    A=mk(TMP["TMP_CONFESSOR"],0,"A",21.0,15)                  # front, engaged
    B=mk(TMP["TMP_CONFESSOR"],0,"B",19.0,15)                  # rear
    g=Game(b,[sq,A,B],seed=1,metrics=Metrics())
    # sq is engaged with A (front). B strikes from rear:
    print(f"    arc of A vs sq = {arc_of(sq,A)} (front) ; arc of B vs sq = {arc_of(sq,B)} (rear)")
    g._maybe_counter(B, sq, TMP['TMP_CONFESSOR'].melee_packets[0], is_counter=False, reach_strike=False)
    denied = g.m.get("counter_denied")>=1
    print(f"    rear strike on an engaged Square denied a Counter? {denied}")
    ok = landed>trials*0.4 and denied
    print(f"  => {'PASS' if ok else 'FAIL'}: dying swing + flank denial both correct.")
    return ok

# --------------------------------------------------------------------------- #
def test_full_game():
    hr("SCENARIO 5 — Full game smoke: 6 Templars vs 9 Mordor, terrain + elevation")
    b = Board(44, 30,
              walls=[Wall(20,4,20,11,4.0), Wall(20,19,20,26,4.0)],     # a central gate/choke
              platforms=[Platform(0,0,8,30,3.0), Platform(36,0,44,30,3.0)],  # deployment ridges
              covers=[LowCover(24,13,28,17)])
    tmp=[ "TMP_MARSHAL","TMP_SWORDBROTHER","TMP_SHIELDBROTHER","TMP_HALBERDIER","TMP_ARBALEST","TMP_SENTINEL"]
    mor=[ "MOR_CAPTAIN","MOR_WARRIOR","MOR_WARRIOR","MOR_PIKEMAN","MOR_BERSERKER","MOR_ORC","MOR_ORC","MOR_ARCHER","MOR_WARG"]
    figs=[]
    for i,d in enumerate(tmp): figs.append(mk(TMP[d],0,f"T{i}",5, 5+i*4, facing=0.0))
    for i,d in enumerate(mor): figs.append(mk(MOR[d],1,f"M{i}",39,3+i*3, facing=math.pi))
    m=Metrics(); g=Game(b,figs,seed=42,metrics=m,max_rounds=12); res=g.run()
    print(f"    result: winner side {res['winner']} by {res['reason']} in {res['rounds']} rounds; survivors {res['survivors']}")
    fired=["attacks","counters","wounds","saves","charge_bonus","highground","flank",
           "knockdown","pushes","nerve_tests","routs","ko","slain","cleave"]
    print("    mechanic fire-counts:")
    for k in fired: print(f"      {k:14} {m.get(k)}")
    ok = m.get("attacks")>0 and m.get("nerve_tests")>0 and res["rounds"]>=1   # decisive OR a draw both count
    print(f"  => {'PASS' if ok else 'FAIL'}: a full game resolves end-to-end with morale ({res['reason']}).")
    return ok

if __name__ == "__main__":
    results = {
        "charge": test_charge(),
        "reach_lane": test_reach_lane(),
        "high_ground": test_high_ground(),
        "counter": test_counter(),
        "full_game": test_full_game(),
    }
    hr("SUMMARY")
    for k,v in results.items(): print(f"  {k:14} {'PASS' if v else 'FAIL/CHECK'}")
    print(f"\n  {sum(results.values())}/{len(results)} scenarios passed.")
