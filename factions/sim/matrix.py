"""All-vs-all balance matrix at equal points. Shows which factions are fair together.
Run: python matrix.py [budget] [games]"""
import sys
from balance import find_faction, auto_banner, round_robin, banner_points

ARMIES = ["templar","mordor","militia","goblin","scaled","harmony"]  # Dragon = solo boss (excluded)
LABEL  = {"templar":"Templar","mordor":"Mordor","militia":"Militia","goblin":"Goblin","scaled":"Lizard","harmony":"Pony"}

def main():
    budget = int(sys.argv[1]) if len(sys.argv)>1 else 300
    games  = int(sys.argv[2]) if len(sys.argv)>2 else 500
    names  = {k: find_faction(k) for k in ARMIES}
    banners= {k: auto_banner(names[k][1], budget) for k in ARMIES}
    print(f"Budget {budget} pts.  Cell = ROW's win% vs COLUMN.  ~50 = fair.\n")
    print(f"{'':9}" + "".join(f"{LABEL[c][:7]:>8}" for c in ARMIES) + "   avg   army")
    for a in ARMIES:
        cells=[]
        for b in ARMIES:
            if a==b: cells.append(None); continue
            cells.append(round_robin(banners[a],banners[b],games=games,seed0=40000)["rate0"])
        vals=[c for c in cells if c is not None]; avg=sum(vals)/len(vals)
        line="".join((" "*8 if c is None else f"{c*100:>7.0f} ") for c in cells)
        print(f"{LABEL[a]:9}{line}  {avg*100:>4.0f}%  {len(banners[a])}f/{banner_points(banners[a])}p")
    print("\n(Pony plays at +33% pts by design — its equal-points row reads low.)")

if __name__ == "__main__":
    main()
