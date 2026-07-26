"""
HOLDTEST — can a defense actually STOP the best charge? Throws the strongest
charger setup (lance wedge, full run-up) at escalating defenses, incl. a chaff
SCREEN, and measures whether the MAIN line holds. Tests William's meta claim.

Run:  python holdtest.py [seeds]
"""
import sys, math, statistics
from multiprocessing import Pool, cpu_count
from clash_sim import Fig, Clash, UNITS, find, R

def pick(pred,name=None):
    if name:
        u=find(lambda u:u["name"]==name and pred(u))
        if u: return u
    return find(pred)
LANCE = pick(lambda u:u["w"]["impact"])
SWORD = pick(lambda u:u["shape"]=="Square" and not u["w"]["shield"] and not u["w"]["impact"] and u["w"]["reach"]==0,"Warrior")
SPEAR = pick(lambda u:u["w"]["reach"]>0 and not u["w"]["impact"],"Spearman")
SHIELD= pick(lambda u:u["w"]["shield"],"Shield-Bearer")
CHAFF = pick(lambda u:u["wounds"]<=1 and u["armour"] in ("None","Light")) or pick(lambda u:u["wounds"]<=1) or SWORD

def wedge(unit,count,runup,sp=1.4):
    figs=[]; r=R.get(unit["size"],.55); lead=-(runup+r); placed=0;row=1;y=lead
    while placed<count:
        w=min(row,count-placed); off=(w-1)*sp/2
        for i in range(w): figs.append(Fig("C",i*sp-off,y,unit,0)); placed+=1
        y-=sp;row+=1
    return figs

def rank(unit,width,depth,y0,sp=1.25,shield_front=False,tag="main"):
    figs=[]
    for d in range(depth):
        off=(width-1)*sp/2
        for i in range(width):
            u=SHIELD if (d==0 and shield_front) else unit
            f=Fig("D",i*sp-off,y0+d*sp,u,180); f.tag=tag; figs.append(f)
    return figs

def scene(defense, seed):
    Fig._n=0
    chg=wedge(LANCE,6,6.0)                                  # the best charge
    if defense=="thin":        de=rank(SWORD,6,1,0)
    elif defense=="deep":      de=rank(SWORD,6,3,0)
    elif defense=="hedge":     de=rank(SPEAR,6,3,0,shield_front=True)
    elif defense=="hedge+screen":
        de=rank(SPEAR,6,3,0,shield_front=True)+rank(CHAFF,6,1,-1.4,tag="screen")
    elif defense=="deny-runup": # main line, but chargers start only 2" out
        Fig._n=0; chg=wedge(LANCE,6,2.0); de=rank(SPEAR,6,3,0,shield_front=True)
    for f in chg: f.tag="chg"
    for f in de:
        if not hasattr(f,"tag"): f.tag="main"
    return Clash(chg,de,seed=seed).run(), chg, de

def one(args):
    defense, seed = args
    cl,chg,de = scene(defense,seed)
    main=[f for f in de if f.tag=="main"]
    chg_lost=sum(1 for f in chg if not f.alive)
    main_lost=sum(1 for f in main if not f.alive)
    maxy=max(f.y for f in main)
    broke=any(f.alive and f.y>maxy+0.4 for f in chg)
    held = main_lost<=len(main)*0.25 and not broke     # line intact & nobody got through
    return (chg_lost, main_lost, len(chg), len(main), 1 if broke else 0, 1 if held else 0, cl.m["halt"])

def main():
    seeds=int(sys.argv[1]) if len(sys.argv)>1 else 3000
    print("charge = LANCE wedge (6), full 6\" run-up.  Chaff screen =", CHAFF["name"])
    print(f"defense                | line HOLDS | broke thru | you kill (main/6) | you lose (/6) | halt")
    print("-"*92)
    order=["thin","deep","hedge","hedge+screen","deny-runup"]
    with Pool(max(1,cpu_count()-2)) as p:
        for d in order:
            res=p.map(one,[(d,9000+s) for s in range(seeds)],chunksize=64)
            n=len(res)
            chg_l=statistics.mean(r[0] for r in res); main_l=statistics.mean(r[1] for r in res)
            broke=statistics.mean(r[4] for r in res); held=statistics.mean(r[5] for r in res)
            halt=statistics.mean(1 if r[6]>0 else 0 for r in res)
            print(f"{d:22s} |   {held:5.0%}    |   {broke:5.0%}    |      {main_l:4.2f}         |     {chg_l:4.2f}      | {halt:4.0%}")

if __name__=="__main__":
    main()
