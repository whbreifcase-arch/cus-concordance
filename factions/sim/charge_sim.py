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
        self.reacted=False           # spent its ONE reaction (reach-strike / intercept) this charge
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
    def __init__(self, chargers, defenders, wall_y=None, sprint=10.0, seed=0, record=True):
        self.figs = chargers + defenders
        self.allfigs = list(chargers + defenders)          # full roster, keeps the dead for rendering
        self.chargers=chargers; self.defenders=defenders
        self.wall_y=wall_y; self.remaining=sprint
        self.rng=random.Random(seed)
        self.log=[]; self.round=0
        self.record=record; self.frames=[]; self._events=[]
        self.m={"reach_strikes":0,"impacts":0,"counters":0,"pushes":0,"crush":0,
                "intercepts":0,"knockdowns":0,"charger_kills":0,"defender_kills":0}

    def ev(self,s): self.log.append(f"  {s}")

    def snap(self, label):
        """Capture a keyframe: every figure's position + this step's attack events."""
        if not self.record: return
        self.frames.append({
            "label": label,
            "figs": [{"id":f.id,"s":f.side,"x":round(f.x,3),"y":round(f.y,3),"r":f.r,
                      "cw":max(0,f.cw),"w":f.w,"dead":(not f.alive),"prone":f.prone,
                      "shield":has_shield(f),"reach":(reach_of(f)>0)} for f in self.allfigs],
            "events": self._events[:]})
        self._events=[]

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
        ty={"IMPACTS":"impact","REACH-strikes":"reach","counters":"counter"}.get(label,"hit")
        if not eff:
            self.ev(f"{atk.id} {label} {dfn.id}: {succ} succ (on {dice}d) -> miss")
            self._events.append({"f":atk.id,"t":dfn.id,"k":ty,"miss":True,"crush":False,"kill":False})
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
        killed = (dfn.cw<=0 and dfn.alive)
        if killed:
            dfn.alive=False
            self.m["defender_kills" if dfn.side=="D" else "charger_kills"]+=1
            self.ev(f"    >>> {dfn.id} falls")
        self._events.append({"f":atk.id,"t":dfn.id,"k":ty,"miss":False,
                             "crush":bool(bonus_dice),"kill":killed})
        return killed

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
            if d.dead or d.reacted or reach_of(d)<=0: continue   # ONE reaction per charge
            band=[c for c in self.chargers if c.alive and CONTACT < gap(d,c) <= reach_of(d) and c.y<d.y]
            if band:
                tgt=min(band, key=lambda c:gap(d,c))
                d.reacted=True                                   # reach-strike spends the reaction
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
        guards=[g for g in self.defenders if g.alive and not g.reacted and has_shield(g)
                and gap(g,dfn)<=1.0 and g is not dfn]        # a spent shield can't intercept again
        if guards:
            guards[0].reacted=True                            # intercept spends the reaction
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
        self.snap("deploy")
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
        self.snap("first contact")
        # the increment cycle
        while self.remaining>0.05 and any(c.alive and not c.stopped for c in self.chargers):
            self.round+=1
            self.log.append(f"--- inch {self.round} (advance up to {min(STEP,self.remaining):.2f}\") ---")
            self.reach_phase()                          # spears strike as chargers sit in the band
            self.cleanup(); self.snap(f"reach · inch {self.round}")
            step=min(STEP, self.remaining)
            adv=0.0
            for c in sorted([c for c in self.chargers if c.alive and not c.stopped], key=lambda c:-c.y):
                a=self.advance_one(c, step); adv=max(adv,a)
                if a < step-1e-6: c.stopped=True        # jammed (wall/crush) -> this lane stops
            self.remaining-=adv
            self.snap(f"advance · inch {self.round}")
            self.contact_phase()
            self.cleanup(); self.snap(f"clash · inch {self.round}")
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

# =========================================================================== #
#  TOP-DOWN REPLAY (watch the collision slide, inch by inch)
# =========================================================================== #
REPLAY_HTML = r"""<!doctype html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>CUS · Charge Replay</title>
<style>
:root{--bg:#0e1013;--pane:#181b21;--ink:#e8ecf2;--dim:#8a93a3;--line:#2a2f38;--red:#d9563f;--blue:#4d8fd6;--gold:#d8b45a}
@media(prefers-color-scheme:light){:root{--bg:#e9ebf0;--pane:#fff;--ink:#1a1d24;--dim:#5a6270;--line:#d5dae2}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:14px system-ui,sans-serif;overflow:hidden}
#bar{position:fixed;top:0;left:0;right:0;z-index:5;display:flex;gap:12px;align-items:center;padding:9px 14px;background:linear-gradient(var(--bg),transparent)}
#bar b{color:var(--gold);letter-spacing:1px}select,button{background:var(--pane);color:var(--ink);border:1px solid var(--line);border-radius:7px;padding:6px 11px;font:600 13px system-ui;cursor:pointer}
#lab{min-width:150px;color:var(--dim);font-weight:600}#desc{color:var(--dim);font-size:12.5px;flex:1;text-align:right}
input[type=range]{accent-color:var(--gold)}#scrub{width:min(42vw,520px)}
canvas{display:block}
.leg{position:fixed;bottom:8px;left:14px;color:var(--dim);font-size:12px}
</style></head><body>
<div id="bar"><b>⚔ CHARGE</b>
  <select id="pick"></select>
  <button id="pp">▶ Play</button><button id="rw">⟲</button>
  <span id="lab">—</span>
  <input id="scrub" type="range" min="0" value="0" step="0.01">
  speed <input id="spd" type="range" min="0.3" max="2.5" step="0.1" value="1" style="width:90px">
  <span id="desc"></span>
</div>
<canvas id="cv"></canvas>
<div class="leg">red = chargers · blue = defenders · ◎ shield · ▸ reach · pips = wounds · grey = fallen · line = attack (orange impact · gold reach · thick+CRUSH)</div>
<script>
const DATA=__DATA__; const names=Object.keys(DATA);
const cv=document.getElementById('cv'), cx=cv.getContext('2d');
let cur, frames, wall, B, i=0, t=0, playing=false, spd=1, DUR=780;
function resize(){cv.width=innerWidth;cv.height=innerHeight;} addEventListener('resize',()=>{resize();draw();}); resize();
function bounds(){let a=1e9,b=-1e9,c=1e9,d=-1e9;
  frames.forEach(fr=>fr.figs.forEach(f=>{a=Math.min(a,f.x-f.r);b=Math.max(b,f.x+f.r);c=Math.min(c,f.y-f.r);d=Math.max(d,f.y+f.r);}));
  if(wall!=null)d=Math.max(d,wall+0.4); a-=0.6;b+=0.6;c-=0.6;d+=0.6; return {a,b,c,d};}
function load(n){cur=n; frames=DATA[n].frames; wall=DATA[n].wall; document.getElementById('desc').textContent=DATA[n].desc;
  B=bounds(); i=0;t=0; document.getElementById('scrub').max=frames.length-1; draw(); setlab();}
function view(){const pad=54,topPad=64; const W=cv.width-pad*2,H=cv.height-pad-topPad;
  const sc=Math.min(W/(B.b-B.a),H/(B.d-B.c)); const ox=pad+(W-sc*(B.b-B.a))/2, oy=topPad+(H-sc*(B.d-B.c))/2;
  return {sc,X:x=>ox+(x-B.a)*sc, Y:y=>oy+(B.d-y)*sc};}   // flip Y so +y drives UP
function lerp(a,b,t){return a+(b-a)*t;}
function map(fr){const m={};fr.figs.forEach(f=>m[f.id]=f);return m;}
function draw(){cx.clearRect(0,0,cv.width,cv.height); if(!frames)return; const v=view();
  // ground + wall
  const A=frames[i], Bf=frames[Math.min(i+1,frames.length-1)]; const ma=map(A), mb=map(Bf);
  cx.strokeStyle=getComputedStyle(document.body).getPropertyValue('--line');cx.lineWidth=1;
  for(let gx=Math.ceil(B.a);gx<=B.b;gx+=2){cx.globalAlpha=.4;cx.beginPath();cx.moveTo(v.X(gx),v.Y(B.c));cx.lineTo(v.X(gx),v.Y(B.d));cx.stroke();}
  for(let gy=Math.ceil(B.c);gy<=B.d;gy+=2){cx.globalAlpha=.4;cx.beginPath();cx.moveTo(v.X(B.a),v.Y(gy));cx.lineTo(v.X(B.b),v.Y(gy));cx.stroke();}
  cx.globalAlpha=1;
  if(wall!=null){cx.fillStyle='#6a5a3a';cx.fillRect(v.X(B.a),v.Y(wall)-6,v.X(B.b)-v.X(B.a),12);
    cx.fillStyle='var(--dim)';}
  // figures (tweened A->B)
  const ids=new Set([...Object.keys(ma),...Object.keys(mb)]);
  ids.forEach(id=>{const fa=ma[id],fb=mb[id]||fa; const f=fb;
    const x=v.X(lerp((fa||fb).x,fb.x,t)), y=v.Y(lerp((fa||fb).y,fb.y,t));
    const deadNow=fb.dead, deadPrev=fa?fa.dead:false;
    let al = deadNow&&!deadPrev? lerp(1,.4,t) : (deadNow?.4:1);
    const col = f.s==='C'?getCol('--red'):getCol('--blue'); const r=f.r*v.sc;
    cx.globalAlpha=al;
    cx.beginPath();cx.arc(x,y,r,0,7);cx.fillStyle=deadNow?'#555':col;cx.fill();
    if(f.shield){cx.lineWidth=3;cx.strokeStyle='#e9e2c8';cx.beginPath();cx.arc(x,y,r+2,0,7);cx.stroke();}
    if(f.reach){cx.strokeStyle=getCol('--gold');cx.lineWidth=2;cx.beginPath();cx.moveTo(x,y-r);cx.lineTo(x,y-r-8);cx.stroke();}
    if(deadNow){cx.strokeStyle='#000';cx.lineWidth=2;cx.beginPath();cx.moveTo(x-r*.5,y-r*.5);cx.lineTo(x+r*.5,y+r*.5);cx.moveTo(x+r*.5,y-r*.5);cx.lineTo(x-r*.5,y+r*.5);cx.stroke();}
    else{for(let k=0;k<f.w;k++){cx.fillStyle=k<f.cw?'#8f6':'#622';cx.fillRect(x-f.w*3+k*6,y-r-8,4,4);}}
    cx.globalAlpha=1;});
  // event flashes (belong to frame B, entering)
  const fl=Math.sin(Math.min(1,t)*Math.PI);
  (Bf.events||[]).forEach(e=>{const A2=mb[e.f]||ma[e.f], T=mb[e.t]||ma[e.t]; if(!A2||!T)return;
    const x1=v.X(A2.x),y1=v.Y(A2.y),x2=v.X(T.x),y2=v.Y(T.y);
    cx.globalAlpha=fl*(e.miss?.4:.95);
    cx.strokeStyle=e.k==='reach'?getCol('--gold'):e.k==='counter'?getCol('--blue'):e.k==='impact'?'#ff8c3a':'#eee';
    cx.lineWidth=e.crush?6:2.5;cx.beginPath();cx.moveTo(x1,y1);cx.lineTo(x2,y2);cx.stroke();
    if(e.kill){cx.strokeStyle='#ff4a4a';cx.lineWidth=3;cx.beginPath();cx.arc(x2,y2,14*fl+6,0,7);cx.stroke();}
    if(e.crush){cx.fillStyle='#ffb84a';cx.font='bold 13px system-ui';cx.fillText('CRUSH',(x1+x2)/2,(y1+y2)/2-6);}
    cx.globalAlpha=1;});}
function getCol(v){return getComputedStyle(document.body).getPropertyValue(v).trim()||'#888';}
function setlab(){document.getElementById('lab').textContent=frames[i].label; document.getElementById('scrub').value=i+t;}
let last=performance.now();
function tick(now){const dt=now-last;last=now;
  if(playing&&frames){t+=dt/(DUR/spd); if(t>=1){t=0;i++; if(i>=frames.length-1){i=frames.length-1;t=0;playing=false;document.getElementById('pp').textContent='▶ Play';}} setlab(); draw();}
  requestAnimationFrame(tick);} requestAnimationFrame(tick);
document.getElementById('pp').onclick=function(){if(i>=frames.length-1){i=0;t=0;} playing=!playing;this.textContent=playing?'❚❚ Pause':'▶ Play';};
document.getElementById('rw').onclick=()=>{i=0;t=0;playing=false;document.getElementById('pp').textContent='▶ Play';setlab();draw();};
document.getElementById('scrub').oninput=e=>{const v=+e.target.value;i=Math.min(frames.length-1,Math.floor(v));t=v-i;if(i>=frames.length-1)t=0;playing=false;document.getElementById('pp').textContent='▶ Play';setlab();draw();};
document.getElementById('spd').oninput=e=>{spd=+e.target.value;};
const pick=document.getElementById('pick'); names.forEach(n=>{const o=document.createElement('option');o.value=n;o.textContent=DATA[n].title;pick.appendChild(o);});
pick.onchange=e=>{load(e.target.value);}; load(names[0]);
</script></body></html>"""

def make_replay(all_data, out):
    import json as _json
    page=REPLAY_HTML.replace("__DATA__", _json.dumps(all_data))
    with open(out,"w",encoding="utf-8") as f: f.write(page)
    print("wrote", out, f"({len(page)} bytes) —", len(all_data), "scenarios")

if __name__=="__main__":
    args=[a for a in sys.argv[1:] if "=" not in a]
    kv=dict(a.split("=") for a in sys.argv[1:] if "=" in a)
    seed=int(kv.get("seed",0))
    if args and args[0]=="render":
        import os
        want=args[1:] or list(SCENARIOS)
        data={}
        for nm in want:
            F._n=0; C,D,wall,sprint,desc=SCENARIOS[nm](seed=seed)
            ch=Charge(C,D,wall_y=wall,sprint=sprint,seed=seed,record=True); ch.run()
            data[nm]={"title":nm.upper(),"desc":desc,"wall":wall,"frames":ch.frames}
            print(f"  {nm}: {len(ch.frames)} keyframes")
        out=os.path.join(os.path.dirname(__file__),"..","CHARGE_REPLAY.html")
        make_replay(data, out)
    else:
        names=args if args else list(SCENARIOS)
        allok=True
        for nm in names:
            _,checks=run_one(nm, seed=seed, trace=(len(names)==1 or "trace" in kv))
            allok=allok and all(ok for _,ok in checks); print()
        if len(names)>1:
            print(f"Ran {len(names)} charge scenarios. Rule-checks {'all PASS' if allok else 'see CHECKs above'}.")
