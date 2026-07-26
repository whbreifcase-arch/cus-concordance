"""ANGLE — best lance charge into the shielded spear hedge at varying approach
angles (0=head-on ... 90=pure flank). Answers 'what if we come in at 45?'"""
import sys, statistics
from multiprocessing import Pool, cpu_count
from clash_sim import Fig, Clash, R
from study import rotate, make_chargers, make_defenders, U

def one(args):
    deg, seed = args
    Fig._n=0
    chg=make_chargers("wedge", U["impact"], 6, 6.0)
    de=make_defenders(U["spear"], 6, 3, True, "front")   # shielded spear hedge, then rotate:
    rotate(de, deg)
    maxy=max(f.y for f in de)
    cl=Clash(chg,de,seed=seed).run()
    chg_l=sum(1 for f in chg if not f.alive)
    de_l =sum(1 for f in de  if not f.alive)
    broke=any(f.alive and f.y>maxy+0.4 for f in chg)
    held = de_l<=len(de)*0.25 and not broke
    return (chg_l, de_l, 1 if broke else 0, 1 if held else 0, cl.m["flank"]+cl.m["rear"], 1 if cl.m["halt"]>0 else 0)

def main():
    seeds=int(sys.argv[1]) if len(sys.argv)>1 else 3000
    print("LANCE wedge (full run-up) into shielded spear hedge x3, by approach angle:")
    print("angle | line HOLDS | broke thru | flank/rear hits | you kill | you lose | halt")
    print("-"*80)
    with Pool(max(1,cpu_count()-2)) as p:
        for deg in (0,22,45,67,90):
            res=p.map(one,[(deg,9000+s) for s in range(seeds)],chunksize=64)
            f=lambda i:statistics.mean(r[i] for r in res)
            print(f" {deg:3d}° |   {f(3):5.0%}   |   {f(2):5.0%}    |     {f(4):4.2f}       |  {f(1):4.2f}   |  {f(0):4.2f}   | {f(5):4.0%}")

if __name__=="__main__":
    main()
