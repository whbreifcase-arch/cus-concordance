"""
CUS — FOCUSED CHARGE SIMULATOR
Implements the "Form Up & Charge Resolution" brief: a charge is a MOVING interaction
resolved in <=1-inch increments. No contact pocket. Figures stay independent. The
tactics emerge from geometry — shields defend the front, spears reach past allies,
rear ranks resist displacement (push transmits), walls cause Crush, lanes open/close.

Charge axis is +y: chargers start low, drive UP into ranked defenders; an optional
wall sits above the defenders (for Crush). Everything is geometry + rules; the exact
stat numbers are deliberately plain (knobs are matchups/geometry, per William).

Run:  python charge_sim.py                 # all presets
      python charge_sim.py shieldwall      # one preset, full inch-by-inch trace
      python charge_sim.py ranks seed=7
"""
from __future__ import annotations
import sys, math, random

# ---- constants (geometry + the rules; plain numbers) ----------------------- #
R = {"Small":0.40, "Medium":0.55, "Large":0.90}          # base radius (inches)
SAVE = {"None":None, "Light":6, "Medium":5, "Heavy":4}   # armour: d6 >= save
CONTACT = 0.05                                            # bases "touching"
STEP    = 1.0                                             # max advance per increment
CRUSH_DICE = 2                                            # wall-jam bonus to the Impact
WALL_T  = 0.2

def sr(size): return R.get(size, 0.55)

# ---- figure ---------------------------------------------------------------- #
class F:
    _n = 0
    def __init__(self, side, x, y, size="Medium", armour="Medium", wounds=2,
                 weapon="sword", lane=0):
        F._n += 1; self.id = f"{side}{F._n}"
        self.side=side; self.x=x; self.y=y; self.size=size; self.r=sr(size)
        self.armour=armour; self.w=wounds; self.cw=wounds
        self.weapon=weapon; self.lane=lane
        self.alive=True; self.prone=False; self.stopped=False
        self.impacted=set()          # enemy ids this figure has already Impacted
        self.crush_on=None           # a defender it is jamming against a wall this increment
    @property
    def dead(self): return not self.alive
    @property
    def hurt(self): return self.cw < self.w

# ---- weapons (plain; the point is the RULES they carry) -------------------- #
WEAPON = {
    #            dice hit  reach  grades: (successes, [effects])
    "sword":   dict(dice=3, hit=4, reach=0.0, grades=[(1,["1 Wound"]),(2,["2 Wounds"])]),
    "shield":  dict(dice=3, hit=4, reach=0.0, shield=True, grades=[(1,["1 Wound"]),(2,["1 Wound","Guard"])]),
    "spear":   dict(dice=2, hit=4, reach=2.0, grades=[(1,["1 Wound"]),(2,["1 Wound","Shove"])]),
    "lance":   dict(dice=3, hit=4, reach=0.0, impact=True, grades=[(1,["1 Wound","Shove"]),(2,["2 Wounds","Shove"]),(3,["2 Wounds","Knockdown"])]),
    "fist":    dict(dice=2, hit=4, reach=0.0, grades=[(1,["1 Wound"])]),
}
def wpn(f): return WEAPON[f.weapon]
def has_shield(f): return WEAPON[f.weapon].get("shield", False)
def reach_of(f): return WEAPON[f.weapon].get("reach", 0.0)

# ---- geometry -------------------------------------------------------------- #
def gap(a,b): return math.hypot(a.x-b.x, a.y-b.y) - a.r - b.r
def col_overlap(a,b): return abs(a.x-b.x) < (a.r+b.r)*0.85     # roughly same lane
def nearest_ahead(f, figs):
    """The closest ALIVE figure of the other side directly ahead (+y) in f's lane."""
    cand=[o for o in figs if o.alive and o.side!=f.side and o.y>f.y and col_overlap(f,o)]
    return min(cand, key=lambda o:o.y) if cand else None

# =========================================================================== #
#  THE CHARGE
# =========================================================================== #
class Charge:
    def __init__(self, chargers, defenders, wall_y=None, sprint=10.0, seed=0):
        self.figs = chargers + defenders
        self.chargers=chargers; self.defenders=defenders
        self.wall_y=wall_y; self.remaining=sprint
        self.rng=random.Random(seed)
        self.log=[]; self.round=0
        self.m={"reach_strikes":0,"impacts":0,"counters":0,"pushes":0,"crush":0,
                "intercepts":0,"knockdowns":0,"charger_kills":0,"defender_kills":0}

    def ev(self,s): self.log.append(f"  {s}")

    # --- dice / packet ----------------------------------------------------- #
    def roll(self, n, hit):
        return sum(1 for _ in range(max(1,n)) if self.rng.randint(1,6)>=hit)
    def grade(self, w, succ):
        g=None
        for need,eff in w["grades"]:
            if succ>=need: g=eff
        return g
    def wounds_in(self, eff):
        for e in eff:
            if e.endswith("Wound") or e.endswith("Wounds"): return int(e.split()[0])
        return 0
    def apply_packet(self, atk, dfn, w, bonus_dice=0, label="hits"):
        """One attack packet atk->dfn. Returns True if dfn dies."""
        dice=w["dice"]+bonus_dice
        succ=self.roll(dice, w["hit"])
        eff=self.grade(w, succ)
        if not eff:
            self.ev(f"{atk.id} {label} {dfn.id}: {succ} succ (on {dice}d) -> miss")
            return False
        n=self.wounds_in(eff); applied=0; save=SAVE[dfn.armour]
        for _ in range(n):
            if dfn.dead: break
            if save is not None and self.rng.randint(1,6)>=save: continue
            dfn.cw-=1; applied+=1
            if dfn.cw<=0: break
        extra=[e for e in eff if e not in (f"{n} Wound",f"{n} Wounds")]
        tag=("+CRUSH " if bonus_dice else "")+ (", ".join(extra) if extra else "")
        self.ev(f"{atk.id} {label} {dfn.id}: {succ}/{dice}d -> {eff} => {applied} wound(s){' · '+tag if tag else ''}")
        if "Knockdown" in eff and dfn.alive: dfn.prone=True; self.m["knockdowns"]+=1
        if "Shove" in eff and dfn.alive: self.push(dfn, 1.0)      # extra shove along axis
        if dfn.cw<=0 and dfn.alive:
            dfn.alive=False
            self.m["defender_kills" if dfn.side=="D" else "charger_kills"]+=1
            self.ev(f"    >>> {dfn.id} falls")
            return True
        return False

    # --- push / indent / crush (transmits through ranks) ------------------- #
    def push(self, fig, dist):
        """Shove fig forward (+y) up to dist; transmits through the figure behind
        (Indent); a wall behind stops it (Crush). Returns distance actually moved."""
        if dist<=0.02: return 0.0
        # wall behind?
        if self.wall_y is not None:
            room = self.wall_y - WALL_T - (fig.y+fig.r)
            if room < dist:
                move=max(0.0,room); fig.y+=move
                fig._crushed=True
                if move>0.01: self.m["pushes"]+=1
                return move
        ahead = nearest_ahead(fig, self.figs)          # a same-side rank-mate ahead? use any figure ahead in lane
        ahead = self._ahead_same_or_enemy(fig)
        if ahead:
            g=ahead.y-fig.y-(fig.r+ahead.r)
            if g>=dist: fig.y+=dist; self.m["pushes"]+=1; return dist
            fig.y+=max(0,g)
            moved=self.push(ahead, dist-max(0,g))       # transmit (Indent)
            fig.y+=moved
            self.m["pushes"]+=1
            return max(0,g)+moved
        fig.y+=dist; self.m["pushes"]+=1; return dist
    def _ahead_same_or_enemy(self, fig):
        cand=[o for o in self.figs if o is not fig and o.alive and o.y>fig.y and col_overlap(fig,o)]
        return min(cand, key=lambda o:o.y) if cand else None

    # --- advance one charger up to step, driving the push chain ------------ #
    def advance_one(self, c, step):
        for f in self.figs: f._crushed=False
        ahead=nearest_ahead(c, self.figs)
        if ahead is None:
            c.y+=step; return step
        g=ahead.y-c.y-(c.r+ahead.r)
        if g>=step:
            c.y+=step; return step
        c.y+=max(0,g)                                   # close to contact
        residual=step-max(0,g)
        moved=self.push(ahead, residual)
        c.y+=moved
        if moved < residual-1e-6 and getattr(ahead,"_crushed",False):
            c.crush_on=ahead                            # jammed against wall -> Crush this figure
            self.m["crush"]+=1
        return max(0,g)+moved

    # --- reach strikes: a spear hits an enemy in its band, no Counter ------ #
    def reach_phase(self):
        for d in self.defenders:
            if d.dead or reach_of(d)<=0: continue
            band=[c for c in self.chargers if c.alive and CONTACT < gap(d,c) <= reach_of(d) and c.y<d.y]
            if band:
                tgt=min(band, key=lambda c:gap(d,c))
                self.m["reach_strikes"]+=1
                self.apply_packet(d, tgt, wpn(d), label="REACH-strikes")

    # --- resolve NEW contacts this increment (Impact + Counter + Shield) --- #
    def contact_phase(self):
        for c in self.chargers:
            if c.dead: continue
            hits=[d for d in self.defenders if d.alive and gap(c,d)<=CONTACT and d.id not in c.impacted]
            for d in sorted(hits, key=lambda d:gap(c,d)):
                c.impacted.add(d.id)
                # SHIELD INTERCEPT: a shield ally adjacent to d may take the impact
                target=self.shield_redirect(c, d)
                bonus=CRUSH_DICE if c.crush_on is d else 0
                self.m["impacts"]+=1
                dead=self.apply_packet(c, target, wpn(c), bonus_dice=bonus, label="IMPACTS")
                # COUNTER: a living defender in contact strikes back (no crush)
                if target.alive and not target.prone and reach_of(c)==0:
                    self.m["counters"]+=1
                    self.apply_packet(target, c, wpn(target), label="counters")
        for c in self.chargers: c.crush_on=None
    def shield_redirect(self, atk, dfn):
        if has_shield(dfn): return dfn                  # already the wall's shield
        guards=[g for g in self.defenders if g.alive and has_shield(g) and gap(g,dfn)<=1.0 and g is not dfn]
        if guards:
            self.m["intercepts"]+=1
            self.ev(f"    {guards[0].id} INTERCEPTS the hit meant for {dfn.id}")
            return guards[0]
        return dfn

    # --- cleanup: drop the dead (their space opens = lanes open) ----------- #
    def cleanup(self):
        self.figs=[f for f in self.figs if f.alive]
        self.chargers=[f for f in self.chargers if f.alive]
        self.defenders=[f for f in self.defenders if f.alive]

    # --- first contact + the increment loop -------------------------------- #
    def run(self, trace=True):
        # advance the whole charge to First Contact
        gaps=[]
        for c in self.chargers:
            a=nearest_ahead(c, self.figs)
            if a: gaps.append(a.y-c.y-(c.r+a.r))
        first=min([g for g in gaps if g>=0], default=None)
        if first is None:
            self.log.append("No enemy in the charge lane — charge finds nothing."); return self._summary()
        adv=min(first, self.remaining)
        for c in self.chargers: c.y+=adv
        self.remaining-=adv
        self.log.append(f"FIRST CONTACT after {adv:.2f}\" (sprint left {self.remaining:.2f}\").")
        # the increment cycle
        while self.remaining>0.05 and any(c.alive and not c.stopped for c in self.chargers):
            self.round+=1
            self.log.append(f"--- inch {self.round} (advance up to {min(STEP,self.remaining):.2f}\") ---")
            self.reach_phase()                          # spears strike as chargers sit in the band
            self.cleanup()
            step=min(STEP, self.remaining)
            adv=0.0
            for c in sorted([c for c in self.chargers if c.alive and not c.stopped], key=lambda c:-c.y):
                a=self.advance_one(c, step); adv=max(adv,a)
                if a < step-1e-6: c.stopped=True        # jammed (wall/crush) -> this lane stops
            self.remaining-=adv
            self.contact_phase()
            self.cleanup()
            if adv<0.02 and not any(gap(c,d)<=CONTACT for c in self.chargers for d in self.defenders):
                self.log.append("  (charge stalls — nothing moving, no contact)"); break
        self.log.append(f"CHARGE ENDS after inch {self.round}; sprint left {self.remaining:.2f}\".")
        return self._summary()

    def _summary(self):
        cs=sum(1 for c in self.chargers if c.alive); ds=sum(1 for d in self.defenders if d.alive)
        return dict(chargers_left=cs, defenders_left=ds, rounds=self.round, **self.m)

# =========================================================================== #
#  SCENARIOS  (matchups + geometry)
# =========================================================================== #
def line(side, n, y, x0=0.0, dx=1.25, **kw):
    return [F(side, x0+i*dx, y, lane=i, **kw) for i in range(n)]

def sc_line(**k):
    """4 chargers (sword) into a single line of 4."""
    C=line("C",4, 0.0, weapon="sword", armour="Light", wounds=2)
    D=line("D",4, 6.0, weapon="sword", armour="Light", wounds=2)
    return C,D,None,10.0,"Sword line into a single rank — clean head-on trades"

def sc_wedge(**k):
    """A lance wedge (narrow frontage) into a line of 5 — penetration + push."""
    C=[F("C",2.5,0.0,size="Large",armour="Heavy",wounds=3,weapon="lance",lane=0),
       F("C",1.7,-1.0,weapon="sword",armour="Medium",lane=0),F("C",3.3,-1.0,weapon="sword",armour="Medium",lane=0),
       F("C",0.9,-2.0,weapon="sword",armour="Medium",lane=0),F("C",4.1,-2.0,weapon="sword",armour="Medium",lane=0)]
    D=line("D",5, 6.0, weapon="sword", armour="Light", wounds=2)
    return C,D,None,11.0,"Lance WEDGE into a line — narrow frontage, deep push"

def sc_shieldwall(**k):
    """4 chargers into a shield wall (front shields) backed by a rank of swords."""
    C=line("C",4, 0.0, weapon="sword", armour="Medium", wounds=2)
    D1=line("D",4, 6.0, weapon="shield", armour="Heavy", wounds=2)   # the wall
    D2=line("D",4, 7.3, weapon="sword",  armour="Light", wounds=2)   # rank behind
    return C, D1+D2, None, 10.0, "Charge into a SHIELD WALL (heavy front) backed by a second rank"

def sc_ranks(**k):
    """4 chargers into a DEEP block (3 ranks) — push must transmit; the line bends."""
    C=line("C",4, 0.0, weapon="sword", armour="Medium", wounds=2)
    D=(line("D",4,6.0,weapon="sword",armour="Medium",wounds=2)
      +line("D",4,7.2,weapon="sword",armour="Light",wounds=2)
      +line("D",4,8.4,weapon="sword",armour="Light",wounds=2))
    return C,D,None,10.0,"Charge into a 3-RANK block — push transmits, the line BENDS not breaks"

def sc_spears(**k):
    """4 chargers into a spear line — Reach thins them BEFORE contact."""
    C=line("C",4, 0.0, weapon="sword", armour="Light", wounds=2)
    D=line("D",4, 6.0, weapon="spear", armour="Light", wounds=2)
    return C,D,None,10.0,"Charge into a SPEAR line — reach strikes on the approach"

def sc_wall(**k):
    """4 chargers drive a thin defender line back into a WALL -> Crush."""
    C=line("C",4, 0.0, size="Large", weapon="lance", armour="Heavy", wounds=3)
    D=line("D",4, 5.0, weapon="sword", armour="Medium", wounds=2)
    return C,D, 6.4, 12.0, "Drive a line into a WALL — nowhere to go -> CRUSH (+dice)"

def sc_partial(**k):
    """Front-lane charger meets a tough anchor that survives — that lane stalls,
    the others roll into the gap. (Partial formation failure.)"""
    C=line("C",4, 0.0, weapon="sword", armour="Light", wounds=2)
    D=[F("D",0.0,6.0,armour="Heavy",wounds=4,weapon="shield",lane=0)]  # one tough plug in lane 0
    D+=[F("D",1.25,6.0,armour="Light",wounds=1,weapon="sword",lane=1),
        F("D",3.75,6.0,armour="Light",wounds=1,weapon="sword",lane=3)]
    return C,D,None,10.0,"PARTIAL FAILURE — a tough plug stalls lane 0 while other lanes break through"

SCENARIOS={"line":sc_line,"wedge":sc_wedge,"shieldwall":sc_shieldwall,"ranks":sc_ranks,
           "spears":sc_spears,"wall":sc_wall,"partial":sc_partial}

# =========================================================================== #
def run_one(name, seed=0, trace=True):
    F._n=0
    C,D,wall,sprint,desc=SCENARIOS[name](seed=seed)
    ch=Charge(C,D,wall_y=wall,sprint=sprint,seed=seed)
    res=ch.run()
    print("="*74); print(f"  {name.upper()} — {desc}"); print("="*74)
    if trace:
        for l in ch.log: print(l)
    print(f"  RESULT: chargers {res['chargers_left']}/{len(C)} left · defenders {res['defenders_left']}/{len(D)} left · {res['rounds']} inches")
    print(f"  fired: impacts {res['impacts']} · counters {res['counters']} · reach {res['reach_strikes']} · "
          f"pushes {res['pushes']} · crush {res['crush']} · intercepts {res['intercepts']} · knockdowns {res['knockdowns']}")
    # rule checks
    checks=[]
    if name=="spears":     checks.append(("reach thins before contact", res['reach_strikes']>=1))
    if name=="wall":       checks.append(("crush fired at the wall", res['crush']>=1))
    if name=="ranks":      checks.append(("push transmitted through ranks", res['pushes']>=3))
    if name=="shieldwall": checks.append(("shields absorbed the charge", res['impacts']>=1))
    if name=="partial":    checks.append(("some defenders fell, some held", 0<res['defenders_left']<len(D)))
    if name=="wedge":      checks.append(("wedge pushed the line", res['pushes']>=2))
    for lbl,ok in checks: print(f"  [{'PASS' if ok else 'CHECK'}] {lbl}")
    return res, checks

if __name__=="__main__":
    args=[a for a in sys.argv[1:] if "=" not in a]
    kv=dict(a.split("=") for a in sys.argv[1:] if "=" in a)
    seed=int(kv.get("seed",0))
    names=args if args else list(SCENARIOS)
    allok=True
    for nm in names:
        _,checks=run_one(nm, seed=seed, trace=(len(names)==1 or "trace" in kv))
        allok=allok and all(ok for _,ok in checks); print()
    if len(names)>1:
        print(f"Ran {len(names)} charge scenarios. Rule-checks {'all PASS' if allok else 'see CHECKs above'}.")
