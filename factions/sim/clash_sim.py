"""
CLASH_SIM — headless Python port of the Charge Lab engine (Continuous Clash
Resolution). Faithful to the signed rules: 1 reaction/figure, lateral-first push
cascade, 3" run-up to charge, 3" push cap, Square facing (flank +1d / rear +2d,
no counter), Circles faceless, NO-TURN, and symmetric shield interception (a
shield protects an adjacent SAME-SIDE ally from an incoming hit — this is what
lets an escort work).

Used to actually TEST setups across many seeds (the "you build, I eat the data"
side). Run:  python clash_sim.py            # runs the wizard-escort breakthrough
"""
import math, random, statistics, sys
from make_lab_units import build_units

R={"Small":0.40,"Medium":0.55,"Large":0.90}
SAVE={"None":None,"Light":6,"Medium":5,"Heavy":4}
CONTACT=0.05; CRUSH_DICE=2; WALL_T=0.2
CHARGE_MIN=3.0; PUSH_MAX=3.0; SHOVE=1.0; EPS=1e-4

UNITS={u["id"]:u for u in build_units()}
def find(pred):
    return next((u for u in UNITS.values() if pred(u)), None)

def has_shield(f): return f.w["shield"]
def reach_of(f):   return f.w["reach"] or 0.0

class Fig:
    _n=0
    def __init__(self, side, x, y, unit, face_deg=None):
        Fig._n+=1; self.id=f"{side}{Fig._n}"
        self.side=side; self.x=x; self.y=y; self.unit=unit
        self.r=R.get(unit["size"],0.55); self.shape=unit["shape"]
        self.armour=unit["armour"]; self.w=type("W",(),unit["w"])  # attr access
        self.w=unit["w"]
        self.wounds=unit["wounds"]; self.cw=unit["wounds"]
        self.alive=True; self.prone=False; self.reacted=False
        self.impacted=set(); self.sprinted=0.0; self.contacted=False
        self.budget=PUSH_MAX; self.stopped=False; self.crush_on=None; self.travel=40.0
        if face_deg is None: face_deg = 0 if side=="C" else 180
        rad=math.radians(face_deg); self.face=[math.sin(rad),math.cos(rad)]

class Clash:
    def __init__(self, chargers, defenders, wall_y=None, x_min=None, x_max=None, seed=1, step=1.0):
        self.figs=chargers+defenders; self.chargers=chargers; self.defenders=defenders
        self.wall_y=wall_y; self.x_min=x_min; self.x_max=x_max; self.step=step
        self.rng=random.Random(seed)
        self.m={k:0 for k in ("reach","impact","counter","push","crush","intercept",
                              "knock","halt","flank","rear","ckill","dkill")}
        self.center_x=sum(f.x for f in self.figs)/max(1,len(self.figs))
    # dice
    def d6(self): return self.rng.randint(1,6)
    def roll(self,n,hit): return sum(1 for _ in range(max(1,n)) if self.d6()>=hit)
    def grade(self,w,su):
        g=None
        for need,eff in w["grades"]:
            if su>=need: g=eff
        return g
    def wounds_in(self,eff):
        for e in eff:
            if e.split()[0].isdigit() and "Wound" in e: return int(e.split()[0])
        return 0
    def classify(self, atk, dfn):
        if dfn.shape=="Circle": return "front"
        dx=atk.x-dfn.x; dy=atk.y-dfn.y; L=math.hypot(dx,dy) or 1
        dot=(dx/L)*dfn.face[0]+(dy/L)*dfn.face[1]
        return "front" if dot>0.5 else ("rear" if dot<-0.5 else "flank")
    def packet(self, atk, dfn, bonus, label, side):
        w=atk.w; dice=w["dice"]+bonus; su=self.roll(dice,w["hit"]); eff=self.grade(w,su)
        if not eff: return False
        n=self.wounds_in(eff); sv=SAVE[dfn.armour]
        for _ in range(n):
            if not dfn.alive: break
            if sv is not None and self.d6()>=sv: continue
            dfn.cw-=1
            if dfn.cw<=0: break
        if "Knockdown" in eff and dfn.alive: dfn.prone=True; self.m["knock"]+=1
        if "Shove" in eff and dfn.alive: self.shove_lat(dfn, self.side_bias(dfn), SHOVE, set())
        killed = dfn.cw<=0 and dfn.alive
        if killed:
            dfn.alive=False
            self.m["dkill" if dfn.side=="D" else "ckill"]+=1
        return killed
    # geometry
    def col_overlap(self,a,b): return abs(a.x-b.x)<(a.r+b.r)*0.85
    def gap(self,a,b): return math.hypot(a.x-b.x,a.y-b.y)-a.r-b.r
    def nearest_ahead(self,f):
        best=None; bd=1e9
        for o in self.figs:
            if not o.alive or o.side==f.side: continue
            if o.y>f.y and self.col_overlap(f,o) and o.y<bd: bd=o.y; best=o
        return best
    def side_bias(self,f): return -1 if f.x<self.center_x else 1
    def fwd_gap(self,c,ahead):
        """Distance c can advance in +y before its base touches ahead's base,
        accounting for lateral (x) offset. inf if it can't collide head-on."""
        dx=ahead.x-c.x; sr=c.r+ahead.r; dy=ahead.y-c.y
        if abs(dx)>=sr: return math.inf
        return dy - math.sqrt(sr*sr - dx*dx)
    def shove_lat(self, fig, side, need, vis):
        if need<=EPS or id(fig) in vis: return 0.0
        vis.add(id(fig)); bound=math.inf
        if self.x_min is not None and side<0: bound=(fig.x-fig.r)-self.x_min
        if self.x_max is not None and side>0: bound=self.x_max-(fig.x+fig.r)
        nb=None; av=math.inf
        for o in self.figs:
            if o is fig or not o.alive: continue
            if abs(o.y-fig.y)>=(fig.r+o.r): continue
            dx=(o.x-fig.x)*side
            if dx<=0: continue
            cl=dx-(fig.r+o.r)
            if cl<av: av=cl; nb=o
        cap=min(bound, 0 if av<0 else av)
        if cap>=need-EPS:
            fig.x+=side*need; self.m["push"]+=1; return need
        mv=max(0,cap); fig.x+=side*mv
        if mv>EPS: self.m["push"]+=1
        more=0.0
        if nb is not None and bound>cap+EPS:
            more=self.shove_lat(nb, side, need-mv, vis); fig.x+=side*more
        return mv+more
    def wall_jam(self,f):
        return self.wall_y is not None and (self.wall_y-WALL_T)-(f.y+f.r)<EPS
    def shove_fwd(self, fig, need, vis):
        if need<=EPS or id(fig) in vis: return 0.0
        vis.add(id(fig))
        if self.wall_jam(fig): return 0.0
        room=(self.wall_y-WALL_T)-(fig.y+fig.r) if self.wall_y is not None else math.inf
        ah=None; ad=1e9
        for o in self.figs:
            if o is fig or not o.alive: continue
            if o.y>fig.y and self.col_overlap(fig,o) and o.y<ad: ad=o.y; ah=o
        ga=(ah.y-fig.y-(fig.r+ah.r)) if ah else math.inf
        cap=min(need, room, 0 if ga<0 else ga)
        if cap>=need-EPS: fig.y+=need; self.m["push"]+=1; return need
        mv=max(0,cap); fig.y+=mv
        if mv>EPS: self.m["push"]+=1
        more=self.shove_fwd(ah,need-mv,vis) if ah else 0.0
        fig.y+=more; return mv+more
    def advance_one(self,c):
        if c.stopped: return
        base=self.step; step=min(base,c.budget) if c.contacted else base
        if step<=EPS: c.stopped=True; return
        ahead=self.nearest_ahead(c)
        if ahead is None:
            c.y+=step
            if not c.contacted:
                c.sprinted+=step; c.travel-=step
                if c.travel<=0: c.stopped=True
            else: c.budget-=step
            return
        g=self.fwd_gap(c,ahead)
        if g>=step:
            c.y+=step
            if not c.contacted: c.sprinted+=step; c.travel-=step
            else: c.budget-=step
            return
        c.y+=max(0,g)
        if not c.contacted: c.sprinted+=max(0,g)
        if not c.contacted: return
        res=step-max(0,g)
        self.shove_lat(ahead, self.side_bias(ahead), res, set())
        if not self.col_overlap(c,ahead): c.y+=res; c.budget-=res; return
        if self.wall_jam(ahead): c.crush_on=ahead; c.stopped=True; return
        fwd=self.shove_fwd(ahead,res,set()); c.y+=fwd; c.budget-=fwd
        if fwd<res-EPS: c.stopped=True
    def redirect(self, target):
        """Symmetric shield interception: an adjacent unspent shield ally of the
        target's OWN side takes the hit (spends its reaction)."""
        if has_shield(target): return target
        allies=[a for a in self.figs if a.side==target.side and a.alive and not a.reacted
                and has_shield(a) and a is not target and self.gap(a,target)<=1.0]
        if allies:
            a=min(allies, key=lambda a:self.gap(a,target))
            a.reacted=True; self.m["intercept"]+=1; return a
        return target
    def reach_phase(self):  # no-turn: only strikes FRONT-arc targets
        for d in self.defenders:
            if not d.alive or d.reacted or reach_of(d)<=0: continue
            t=None; td=1e9
            for c in self.chargers:
                if not c.alive: continue
                gp=self.gap(d,c)
                if CONTACT<gp<=reach_of(d) and c.y<d.y and gp<td and self.classify(d,c)=="front":
                    td=gp; t=c
            if t is not None:
                d.reacted=True; self.m["reach"]+=1
                tgt=self.redirect(t)                 # a shield may soak it for the ally
                self.packet(d,tgt,0,"REACH","front")
    def contact_phase(self):
        for c in self.chargers:
            if not c.alive: continue
            if c.stopped and not c.contacted: continue
            hits=sorted([d for d in self.defenders if d.alive and self.gap(c,d)<=CONTACT
                         and d.id not in c.impacted], key=lambda d:self.gap(c,d))
            for d in hits:
                c.impacted.add(d.id)
                if not c.contacted:
                    if c.sprinted<CHARGE_MIN:
                        c.stopped=True; self.m["halt"]+=1; continue
                    c.contacted=True; c.budget=PUSH_MAX
                tgt=self.redirect(d)
                side=self.classify(c,tgt)
                if side=="flank": self.m["flank"]+=1
                if side=="rear": self.m["rear"]+=1
                bonus=(CRUSH_DICE if c.crush_on is tgt else 0)+(1 if side=="flank" else 2 if side=="rear" else 0)
                if c.crush_on is tgt: self.m["crush"]+=1
                self.m["impact"]+=1
                self.packet(c,tgt,bonus,"IMPACT",side)
                if tgt.alive and not tgt.prone and reach_of(c)==0 and side=="front":
                    self.m["counter"]+=1
                    ctgt=self.redirect(c)            # a shield may soak the counter for the charger
                    self.packet(tgt,ctgt,0,"COUNTER","front")
            c.crush_on=None
    def run(self):
        max_inch=math.ceil(max([c.travel for c in self.chargers]+[1]))+math.ceil(PUSH_MAX)+4
        i=0
        while i<max_inch/self.step:
            i+=1
            act=[c for c in self.chargers if c.alive and not c.stopped]
            if not act: break
            for c in act: self.advance_one(c)
            self.reach_phase(); self.contact_phase()
            if not any(c.alive and not c.stopped for c in self.chargers): break
        return self

# ============================ THE ESCORT TEST ============================ #
def escort_scene(enemy_ranks, enemy_id, seed, step=1.0):
    Fig._n=0
    wiz   = find(lambda u:u["shape"]=="Circle" and ("Mystic" in u["name"] or "Wizard" in u["name"] or "Priest" in u["name"])) \
            or find(lambda u:u["shape"]=="Circle")
    shield= find(lambda u:u["w"]["shield"])
    enemy = UNITS.get(enemy_id) or find(lambda u:u["w"]["reach"]>0)
    # CHARGERS: a shield arrowhead wrapped around a wizard, driving up (+y)
    ch=[]
    ch.append(Fig("C", 0.0, -8.0, wiz, 0))          # the wizard, tucked behind
    ch.append(Fig("C", 0.0, -6.8, shield, 0))       # point shield (contacts first)
    ch.append(Fig("C",-1.15,-7.4, shield, 0))       # left-front shield
    ch.append(Fig("C", 1.15,-7.4, shield, 0))       # right-front shield
    ch.append(Fig("C",-1.25,-8.5, shield, 0))       # left flank shield
    ch.append(Fig("C", 1.25,-8.5, shield, 0))       # right flank shield
    # DEFENDERS: an enemy line, `enemy_ranks` deep, facing down (180)
    de=[]; width=6; sp=1.25
    for rnk in range(enemy_ranks):
        for i in range(width):
            de.append(Fig("D",(i-(width-1)/2)*sp, rnk*sp, enemy, 180))
    return Clash(ch, de, seed=seed, step=step)

def run_batch(enemy_ranks, enemy_id, n=300, step=1.0):
    surv=brk=0; shield_loss=[]; enemy_loss=[]; wy=[]
    for s in range(n):
        cl=escort_scene(enemy_ranks, enemy_id, seed=1000+s, step=step).run()
        wiz=cl.chargers[0]
        shields=[f for f in cl.chargers if f is not wiz]
        surv += 1 if wiz.alive else 0
        # broke through = wizard emerged past the (original) line front, still alive
        if wiz.alive and wiz.y>0.6: brk+=1
        shield_loss.append(sum(1 for f in shields if not f.alive))
        enemy_loss.append(sum(1 for f in cl.defenders if not f.alive))
        wy.append(wiz.y)
    return dict(n=n, surv=surv, brk=brk,
                shield_loss=statistics.mean(shield_loss), enemy_loss=statistics.mean(enemy_loss),
                wy=statistics.mean(wy),
                enemy=UNITS.get(enemy_id,{}).get("name","?"))

if __name__=="__main__":
    print(f"Loaded {len(UNITS)} units.")
    wiz=find(lambda u:u['shape']=='Circle' and ('Mystic' in u['name'] or 'Wizard' in u['name'] or 'Priest' in u['name'])) or find(lambda u:u['shape']=='Circle')
    shield=find(lambda u:u['w']['shield'])
    print(f"Escort: wizard = {wiz['name']} ({wiz['wounds']}W, {wiz['shape']}), shields = {shield['name']} ({shield['armour']})")
    print("5 shields wrapped around 1 wizard, charging UP into a 6-wide enemy line.\n")
    for enemy_id,label in [("RET_SPEAR","spear line (reach)"),
                           ("RET_WARRIOR","sword line")]:
        for ranks in (1,2,3):
            r=run_batch(ranks, enemy_id, n=300)
            print(f"  vs {ranks}-rank {label:22s}: "
                  f"wizard survives {100*r['surv']/r['n']:5.1f}% · "
                  f"BREAKS THROUGH {100*r['brk']/r['n']:5.1f}% · "
                  f"shields lost {r['shield_loss']:.1f}/5 · "
                  f"enemy lost {r['enemy_loss']:.1f} · wiz final y {r['wy']:+.1f}")
        print()
