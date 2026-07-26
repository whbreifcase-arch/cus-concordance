"""
STUDY — factorial clash sweep. Builds a few hundred matchups by crossing the
levers that matter, slams each a couple thousand times, aggregates, and reports
the marginal effect of every factor. Uses the clash_sim engine (all signed rules).

Run:  python study.py [seeds]        # default 2000 seeds per config
"""
import sys, math, itertools, statistics, time
from multiprocessing import Pool, cpu_count
from clash_sim import Fig, Clash, UNITS, find, R

# ---- pick representative real units by capability -------------------------- #
def pick(pred, name=None):
    if name:
        u=find(lambda u:u["name"]==name and pred(u))
        if u: return u
    return find(pred)
U = {
 "sword" : pick(lambda u:u["shape"]=="Square" and not u["w"]["shield"] and not u["w"]["impact"] and u["w"]["reach"]==0 and u["armour"]=="Medium","Warrior"),
 "spear" : pick(lambda u:u["w"]["reach"]>0 and not u["w"]["impact"] and u["shape"]=="Square","Spearman"),
 "shield": pick(lambda u:u["w"]["shield"] and u["shape"]=="Square","Shield-Bearer"),
 "impact": pick(lambda u:u["w"]["impact"]),
}

# ---- geometry helpers ------------------------------------------------------ #
def rotate(figs, deg):
    if not deg: return
    rad=math.radians(deg); cs,sn=math.cos(rad),math.sin(rad)
    cx=sum(f.x for f in figs)/len(figs); cy=sum(f.y for f in figs)/len(figs)
    for f in figs:
        x,y=f.x-cx,f.y-cy
        f.x=cx+x*cs-y*sn; f.y=cy+x*sn+y*cs
        fx,fy=f.face; f.face=[fx*cs-fy*sn, fx*sn+fy*cs]

def make_chargers(shape, unit, count, runup, sp=1.4):
    figs=[]; r=R.get(unit["size"],0.55); lead=-(runup+r)
    if shape=="column":
        for i in range(count): figs.append(Fig("C",0,lead-i*sp,unit,0))
    elif shape=="line":
        off=(count-1)*sp/2
        for i in range(count): figs.append(Fig("C",i*sp-off,lead,unit,0))
    else:  # wedge
        placed=0; row=1; y=lead
        while placed<count:
            w=min(row,count-placed); off=(w-1)*sp/2
            for i in range(w): figs.append(Fig("C",i*sp-off,y,unit,0)); placed+=1
            y-=sp; row+=1
    return figs

def make_defenders(unit, width, depth, front_shield, approach, sp=1.25):
    figs=[]
    for d in range(depth):
        off=(width-1)*sp/2
        for i in range(width):
            u = U["shield"] if (d==0 and front_shield) else unit
            figs.append(Fig("D",i*sp-off, d*sp, u, 180))
    rotate(figs, {"front":0,"flank":90,"rear":180}[approach])
    return figs

# ---- one config = a dict of factor choices --------------------------------- #
def build(cfg):
    chg=make_chargers(cfg["cshape"], U[cfg["ctype"]], cfg["ccount"], cfg["runup"])
    dfn=make_defenders(U[cfg["dtype"]], 6, cfg["depth"], cfg["fshield"], cfg["approach"])
    return chg, dfn

def run_one(cfg, seed):
    Fig._n=0
    chg,dfn=build(cfg)
    max_def_y=max(f.y for f in dfn)
    cl=Clash(chg,dfn,seed=seed).run()
    nC=len(chg); nD=len(dfn)
    cAlive=sum(1 for f in chg if f.alive); dAlive=sum(1 for f in dfn if f.alive)
    broke=any(f.alive and f.y>max_def_y+0.4 for f in chg)
    return (nC-cAlive, nD-dAlive, nC, nD, 1 if broke else 0,
            1 if cl.m["halt"]>0 else 0, cl.m["reach"], cl.m["crush"],
            cl.m["flank"]+cl.m["rear"], cl.m["intercept"])

def run_config(args):
    cfg, seeds = args
    agg=[0]*10
    for s in range(seeds):
        r=run_one(cfg, 7000+s)
        for i in range(10): agg[i]+=r[i]
    n=seeds
    cLoss,dLoss,nC,nD,broke,halt,reach,crush,flank,inter = agg   # nC,nD are SUMS over n games
    chg_loss=cLoss/nC; def_loss=dLoss/nD                          # total killed / total present = mean fraction
    return {**cfg,
        "chg_loss": chg_loss, "def_loss": def_loss,
        "net": def_loss-chg_loss,                 # + = chargers winning the trade (kill more of them than they lose)
        "def_kill_pg": dLoss/n, "chg_loss_pg": cLoss/n,           # absolute per-game
        "breakthrough": broke/n, "halt": halt/n,
        "reach": reach/n, "crush": crush/n, "flank_rear": flank/n, "intercept": inter/n}

# ---- factor grid ----------------------------------------------------------- #
FACTORS = dict(
    cshape  = ["line","wedge","column"],
    ctype   = ["sword","impact","spear"],
    ccount  = [6],
    dtype   = ["sword","spear","shield"],
    depth   = [1,2,3],
    fshield = [False,True],
    approach= ["front","flank"],
    runup   = [2.0,6.0],
)
def all_configs():
    keys=list(FACTORS); out=[]
    for combo in itertools.product(*[FACTORS[k] for k in keys]):
        out.append(dict(zip(keys,combo)))
    return out

# ---- marginal analysis ----------------------------------------------------- #
def marginal(rows, factor, metric):
    lv={}
    for r in rows: lv.setdefault(r[factor],[]).append(r[metric])
    return {k:statistics.mean(v) for k,v in sorted(lv.items(), key=lambda kv:str(kv[0]))}

def main():
    seeds = int(sys.argv[1]) if len(sys.argv)>1 else 2000
    print("Units:", {k:(v["name"] if v else None) for k,v in U.items()})
    cfgs=all_configs()
    print(f"{len(cfgs)} configurations × {seeds} seeds = {len(cfgs)*seeds:,} games")
    t0=time.time()
    with Pool(max(1,cpu_count()-2)) as p:
        rows=p.map(run_config, [(c,seeds) for c in cfgs], chunksize=4)
    print(f"done in {time.time()-t0:.1f}s\n")

    # save raw
    import json, os
    out=os.path.join(os.path.dirname(__file__),"..","study_results.json")
    with open(out,"w") as f: json.dump(rows,f)
    print("raw ->", os.path.basename(out))

    def show(factor):
        print(f"\n== {factor} ==")
        for metric in ("net","breakthrough","def_kill_pg","chg_loss_pg","halt","reach","flank_rear"):
            m=marginal(rows,factor,metric)
            print(f"  {metric:13s}", "  ".join(f"{k}: {v:+.3f}" if isinstance(v,float) else f"{k}:{v}" for k,v in m.items()))
    for fac in ("ctype","cshape","dtype","depth","fshield","approach","runup"):
        show(fac)

    # a few targeted cross-tabs
    print("\n== reach defender depth (spear dtype, no front shield) — net to charger ==")
    for approach in ("front","flank"):
        for depth in (1,2,3):
            sub=[r for r in rows if r["dtype"]=="spear" and not r["fshield"] and r["depth"]==depth and r["approach"]==approach]
            print(f"  {approach:5s} depth {depth}: net {statistics.mean(r['net'] for r in sub):+.2f} · breakthrough {statistics.mean(r['breakthrough'] for r in sub):.0%}")

    print("\n== best & worst charger setups (by net kill trade) ==")
    rows2=sorted(rows,key=lambda r:r["net"])
    def tag(r): return f"{r['ctype']}/{r['cshape']} vs {'sh+' if r['fshield'] else ''}{r['dtype']}x{r['depth']} {r['approach']} run{r['runup']:g}"
    for r in rows2[-8:][::-1]: print(f"  net {r['net']:+.3f}  (kill {r['def_kill_pg']:.2f}/lose {r['chg_loss_pg']:.2f})  brk {r['breakthrough']:.0%}  {tag(r)}")
    print("  ---")
    for r in rows2[:8]: print(f"  net {r['net']:+.3f}  (kill {r['def_kill_pg']:.2f}/lose {r['chg_loss_pg']:.2f})  brk {r['breakthrough']:.0%}  {tag(r)}")

if __name__=="__main__":
    main()
