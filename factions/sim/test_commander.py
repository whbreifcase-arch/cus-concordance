"""Does the Commander beat the greedy AI? Mirror match (same army both sides),
side 1 = Commander, side 0 = greedy. >50% => smarter. Also reports mean rounds
(decisive/fast, not tedious). Run: python test_commander.py [faction] [games] [budget]"""
import sys, statistics
from multiprocessing import Pool, cpu_count
from engine import Metrics
from game import Game
from balance import find_faction, auto_banner, _deploy, _terrain

def one(args):
    ids, seed = args
    board = _terrain(seed)
    figs = _deploy(board, ids, 0, seed) + _deploy(board, ids, 1, seed)
    m = Metrics()
    res = Game(board, figs, seed=seed, metrics=m, max_rounds=12, commander_sides={1}).run()
    return (res["winner"], res["rounds"], res["reason"])

def main():
    fac    = sys.argv[1] if len(sys.argv) > 1 else "mordor"
    games  = int(sys.argv[2]) if len(sys.argv) > 2 else 800
    budget = int(sys.argv[3]) if len(sys.argv) > 3 else 300
    name, units = find_faction(fac); ids = auto_banner(units, budget)
    tasks = [(ids, 30000+g) for g in range(games)]
    with Pool(max(1, cpu_count()-2)) as p:
        out = p.map(one, tasks, chunksize=8)
    w1 = sum(1 for w,_,_ in out if w == 1)
    w0 = sum(1 for w,_,_ in out if w == 0)
    d  = sum(1 for w,_,_ in out if w is None)
    rounds = statistics.mean(r for _,r,_ in out)
    decisive = sum(1 for _,_,r in out if r == "elimination")
    print(f"{name}  ({len(ids)} figs, {budget} pts, mirror)")
    print(f"  COMMANDER (side1) vs greedy (side0):  commander {(w1+0.5*d)/games*100:.1f}%   "
          f"(W{w1} / L{w0} / D{d})")
    print(f"  mean {rounds:.1f} rounds · {decisive}/{games} ended by elimination (decisive, not stalled)")

if __name__ == "__main__":
    main()
