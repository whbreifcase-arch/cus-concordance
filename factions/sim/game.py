"""
CUS v0.6 — game procedures + AI + runner.  Owns the resolution methods (Law 6):
movement, PACKET resolution, Impact, Counter, Nerve, Rout, and the alternation loop.
The AI is Temperament-driven (B.10 leaderless/rout table); the human grammar is
never applied to figures (there is no human here — both sides run Missions, Law 9).
"""
from __future__ import annotations
import math, random
from engine import (Figure, FigureType, PacketDef, Board, Metrics,
                    dist2d, dist3d, norm, roll_pool, MORALE,
                    CONTACT, REACH_BAND, NERVE_SHOCK_R, RALLY_R, AURA_R,
                    HIGHGROUND_DZ, ARMOUR_SAVE, SIZE_RADIUS, SIZE_ORDER,
                    STORY_H, CLIMB_PER_STORY)

# --------------------------------------------------------------------------- #
#  SPATIAL HELPERS
# --------------------------------------------------------------------------- #
def gap(a: Figure, b: Figure):
    """Edge-to-edge distance between two bases (2D)."""
    return dist2d(a.pos, b.pos) - a.ft.radius - b.ft.radius

def touching(a: Figure, b: Figure):
    return gap(a, b) <= CONTACT

def in_reach_band(a: Figure, b: Figure):
    g = gap(a, b)
    return REACH_BAND[0] <= g <= REACH_BAND[1]

def arc_of(defender: Figure, attacker: Figure):
    """front | flank | rear, from a Square defender's facing. Circles are faceless."""
    if defender.is_circle:
        return "front"                       # faceless -> everything is 'front' (always Counters)
    dx, dy = attacker.x - defender.x, attacker.y - defender.y
    ang = math.atan2(dy, dx)
    rel = abs((ang - defender.facing + math.pi) % (2*math.pi) - math.pi)
    deg = math.degrees(rel)
    if deg <= 60:   return "front"
    if deg <= 120:  return "flank"
    return "rear"

def face_toward(fig: Figure, tx, ty):
    if not fig.is_circle:
        fig.facing = math.atan2(ty - fig.y, tx - fig.x)

def living(figs): return [f for f in figs if not f.out]

def enemies_of(game, fig): return [f for f in game.figs if f.side != fig.side and not f.out]
def allies_of(game, fig):  return [f for f in game.figs if f.side == fig.side and f is not fig and not f.out]

def engaged_enemies(game, fig):
    return [e for e in enemies_of(game, fig) if touching(fig, e)]

def nearest(fig, pool):
    if not pool: return None
    return min(pool, key=lambda o: dist2d(fig.pos, o.pos))

# --------------------------------------------------------------------------- #
#  GAME
# --------------------------------------------------------------------------- #
class Game:
    def __init__(self, board: Board, figs, seed=0, metrics=None, max_rounds=12, log=None, record=False):
        self.board = board
        self.figs = figs
        self.rng = random.Random(seed)
        self.m = metrics or Metrics()
        self.max_rounds = max_rounds
        self.round = 0
        self.log = log            # optional list to append (event) tuples for replay
        self.record = record      # if True, capture per-round snapshots into self.frames
        self.frames = []
        for f in self.figs:
            f.z = board.ground_z(f.pos)

    def _snapshot(self, label):
        self.frames.append({
            "label": label,
            "figs": [{"uid":f.uid,"side":f.side,"name":f.name,"x":round(f.x,2),"y":round(f.y,2),
                      "z":round(f.z,2),"r":round(f.ft.radius,2),"shape":f.ft.shape,
                      "hp":max(0,f.cur_wounds),"maxhp":f.ft.max_wounds,
                      "status":("dead" if f.dead else "ko" if f.ko else "broken" if f.morale==0 else "ok"),
                      "role":f.ft.role} for f in self.figs]})

    def _ev(self, *a):
        if self.log is not None: self.log.append((self.round,) + a)

    # ---------------- MOVEMENT (writes Position; elevation-aware) ---------- #
    def move_toward(self, fig: Figure, tx, ty, budget=None, stop_gap=0.0, avoid=True):
        """Advance in a straight line toward (tx,ty). Respects walls (stop short),
        bounds, base overlap, and pays climb cost per story (B.2). Returns dist moved."""
        budget = fig.ft.speed if budget is None else budget
        moved = 0.0
        step = 0.35
        while budget > 0.05:
            d = dist2d(fig.pos, (tx, ty))
            if d <= stop_gap + 1e-3: break
            ux, uy = norm(tx - fig.x, ty - fig.y)
            hop = min(step, budget, d - stop_gap if d > stop_gap else step)
            nx, ny = fig.x + ux*hop, fig.y + uy*hop
            if not self.board.in_bounds((nx, ny)): break
            if self.board.move_blocked(fig.pos, (nx, ny)) and not fig.ft.has_trait("flying"):
                break                                                # wall (fliers pass over)
            if avoid and self._overlaps(fig, nx, ny): break          # body block
            # climb cost: entering higher ground costs extra budget per story
            nz = self.board.ground_z((nx, ny))
            climb = 0.0
            if nz > fig.z + 1e-6:
                climb = (nz - fig.z) / STORY_H * CLIMB_PER_STORY
            if hop + climb > budget + 1e-6:
                break
            fig.x, fig.y = nx, ny
            fig.z = nz
            budget -= (hop + climb)
            moved += hop
        return moved

    def _overlaps(self, fig, nx, ny):
        for o in self.figs:
            if o is fig or o.out: continue
            if dist2d((nx, ny), o.pos) < (fig.ft.radius + o.ft.radius - 0.05):
                return True
        return False

    # ---------------- SPRINT -> IMPACT -> PUSH (B.3, B.4) ------------------ #
    def sprint_impact(self, fig: Figure, target: Figure):
        """MOVE into contact with target, resolve the Push geometry, then resolve
        the mover's Impact packet with the charge (+1 die) and downhill bonus."""
        stop = fig.ft.radius + target.ft.radius + CONTACT*0.5
        pre = fig.pos
        self.move_toward(fig, target.x, target.y, stop_gap=stop, avoid=True)
        if gap(fig, target) > REACH_BAND[1]:
            return False                       # never reached contact
        face_toward(fig, target.x, target.y)
        self.m.bump("sprints")
        # PUSH geometry: shove target along the mover's heading (B.4)
        self._push(fig, target, along=norm(target.x - pre[0], target.y - pre[1]),
                   dist=self._plow_distance(fig, target), impact=True)
        # Impact packet = mounted lance / beast bite / troll smash, else best melee
        pk = self._impact_packet(fig)
        if pk:
            self.resolve_attack(fig, target, pk, charge=True)
        return True

    def _plow_distance(self, mover, target):
        mo = SIZE_ORDER[mover.ft.size] + (1 if mover.ft.mounted else 0)  # mounted plows a class up
        to = SIZE_ORDER[target.ft.size]
        if mover.ft.size == "Small" and not mover.ft.mounted:
            return 0.0                          # Small does not plow (B.4)
        if mo > to:  return 1.6
        if mo == to: return 0.8                 # same size plows grudgingly
        return 0.0

    def _push(self, pusher, target, along, dist, impact=False, depth=0):
        """Push -> Indent -> Crush (B.4). Displacement is Position, not damage;
        only a wall-crush feeds the hit. Depth-bounded: a jammed cascade Crushes."""
        if dist <= 0.05: return
        nx, ny = target.x + along[0]*dist, target.y + along[1]*dist
        # CRUSH: blocked by a wall/edge, or the indent chain jammed -> nowhere to go
        if (depth >= 4 or self.board.move_blocked(target.pos, (nx, ny))
                or not self.board.in_bounds((nx, ny))):
            self.m.bump("crush"); self._crush_bonus = True
            return
        # INDENT: bodies behind -> carry the nearest one forward too (single, bounded)
        blockers = [o for o in self.figs if o is not target and o is not pusher and not o.out
                    and dist2d((nx, ny), o.pos) < (target.ft.radius + o.ft.radius - 0.05)]
        if blockers:
            o = min(blockers, key=lambda o: dist2d((nx,ny), o.pos))
            self._push(target, o, along, dist*0.7, depth=depth+1)
            # if the blocker didn't clear (still overlapping), the mover jams (Crush)
            if dist2d((nx, ny), o.pos) < (target.ft.radius + o.ft.radius - 0.05):
                self.m.bump("crush"); self._crush_bonus = True
                return
        target.x, target.y = nx, ny
        target.z = self.board.ground_z((nx, ny))
        self.m.bump("pushes")

    def _impact_packet(self, fig):
        for p in fig.ft.packets:
            if p.packet_id in ("templar_lance", "warg_bite", "troll_smash"):
                return p
        mp = fig.ft.melee_packets
        return mp[0] if mp else None

    # ---------------- SHOVE (weapon effect, NOT the charge plow) ----------- #
    def _shove(self, pivot, target, up_to=1.0, max_gap=1.0, toward=False):
        """SHOVE (renamed weapon 'Push', SIGNED William 2026-07-24, PROVISIONAL):
        move the target directly away from the pivot, **up to** `up_to`", ending
        **no more than** `max_gap`" from the pivot. If already >= max_gap out, it
        barely moves — a reach weapon holds a foe at bay, it does not launch him.
        `toward=True` = a Pull (drag inward, not past contact). Jams (no move) on a
        wall/edge/body; the wall-crush bonus belongs to the Impact plow, not here."""
        g = gap(pivot, target)
        if toward:
            dist = min(up_to, max(0.0, g))                 # pull inward, stop at contact
            ux, uy = norm(pivot.x - target.x, pivot.y - target.y)
        else:
            dist = min(up_to, max(0.0, max_gap - g))       # shove out to (at most) max_gap
            ux, uy = norm(target.x - pivot.x, target.y - pivot.y)
        if dist <= 0.05:
            return
        nx, ny = target.x + ux*dist, target.y + uy*dist
        if not self.board.in_bounds((nx, ny)) or self.board.move_blocked(target.pos, (nx, ny)):
            return
        for o in self.figs:
            if o is target or o is pivot or o.out: continue
            if dist2d((nx, ny), o.pos) < (target.ft.radius + o.ft.radius - 0.05):
                return
        target.x, target.y = nx, ny
        target.z = self.board.ground_z((nx, ny))
        self.m.bump("shoves")

    # ---------------- PACKET RESOLUTION -> GRADE -> EFFECTS ---------------- #
    def resolve_attack(self, attacker: Figure, target: Figure, pk: PacketDef,
                       charge=False, is_counter=False, reach_strike=False):
        if attacker.out or target.out: return None
        # SHIELD INTERCEPT (reaction, PROVISIONAL) — an adjacent shield-bearer may
        # take this hit for a friend within 1". Redirect the target before rolling.
        if not is_counter and not reach_strike:
            target = self._maybe_intercept(attacker, target, pk)
            if target.out: return None
        self._crush_bonus = getattr(self, "_crush_bonus", False)
        dice = pk.dice
        # --- die-count modifiers (prefer Position over numbers, but these are signed) ---
        if charge:                          dice += 1; self.m.bump("charge_bonus")
        if attacker.z - target.z >= HIGHGROUND_DZ:   dice += 1; self.m.bump("highground")
        arc = arc_of(target, attacker)
        if arc == "flank":                  dice += 1; self.m.bump("flank")
        if arc == "rear":                   dice += 2; self.m.bump("backstab")
        if target.prone:                    dice += 1
        if target.guard > 0:                dice -= 1               # defender Guard blunts it
        # BRACE (PROVISIONAL) — a braced attacker dominates its front; a braced
        # defender is harder to hit from its front (but wide open to flank/rear).
        if attacker.braced and arc_of(attacker, target) == "front":  dice += 1; self.m.bump("brace_atk")
        if target.braced and arc == "front":                          dice -= 1; self.m.bump("brace_def")
        if not pk.is_ranged and not is_counter:                    # MOB: many bodies on one foe
            mob = sum(1 for a in self.figs if a.side == attacker.side and not a.out and touching(a, target))
            if mob >= 2:                    dice += 1; self.m.bump("mob")
        succ_target = pk.success
        if pk.is_ranged and self.board.cover_between(attacker.pos, target.pos):
            succ_target = min(6, succ_target + 1); self.m.bump("cover")
        if self._crush_bonus:               dice += 1; self._crush_bonus = False
        dice = max(1, dice)

        n = roll_pool(self.rng, dice, succ_target)
        self.m.bump("attacks")
        grade = pk.grade_for(n)
        self._ev("attack", attacker.uid, target.uid, pk.packet_id, n, grade.successes if grade else -1)
        if grade is None:
            # miss -> still may eat a Counter if this was an attack into contact
            self._maybe_counter(attacker, target, pk, is_counter, reach_strike)
            return None
        self._apply_grade(attacker, target, pk, grade, is_counter)
        # Counter happens AFTER effects, and the dying swing still lands (B.9)
        self._maybe_counter(attacker, target, pk, is_counter, reach_strike)
        return grade

    def _apply_grade(self, attacker, target, pk, grade, is_counter):
        ignore_armour = "ignore Armour" in grade.effects
        wounds = 0
        for e in grade.effects:
            if e.endswith("Wound") or e.endswith("Wounds"):
                wounds = int(e.split()[0])
        # WOUND (+ Armour save per Wound, B.7)
        if wounds:
            self._wound(target, wounds, ignore_armour, source=attacker)
        # CLEAVE — apply the same wounds to a second engaged enemy (B.6 Cleave)
        if "Cleave" in grade.effects and wounds:
            others = [e for e in engaged_enemies(self, attacker) if e is not target]
            if others:
                self._wound(others[0], wounds, ignore_armour, source=attacker)
                self.m.bump("cleave")
        # EXECUTE — a Hurt/KO target is slain outright (B.6)
        if "Execute" in grade.effects and (target.hurt or target.ko) and not target.dead:
            self._slay(target, source=attacker); self.m.bump("execute")
        # DISPLACEMENT — SHOVE (weapon effect, renamed from Push; the charge
        # Push->Indent->Crush plow is separate, see _push). PROVISIONAL 1"/1".
        if "Shove" in grade.effects:
            self._shove(attacker, target, up_to=1.0, max_gap=1.0)
        if "Pull" in grade.effects:
            self._shove(attacker, target, up_to=1.0, max_gap=1.0, toward=True)
            self.m.bump("pull")
        if "Knockdown" in grade.effects and not target.out:
            target.prone = True; self.m.bump("knockdown")
        # GUARD — the acting figure takes a defensive stance
        if "Guard" in grade.effects:
            attacker.guard = 1; self.m.bump("guard")
        # TERROR — force a Nerve test on the target
        if "Terror" in grade.effects and target.tests_nerve():
            self.nerve_test(target, "terror")

    def _wound(self, target, n, ignore_armour, source=None):
        save = ARMOUR_SAVE[target.ft.armour]
        applied = 0
        for _ in range(n):
            if target.out: break
            if (not ignore_armour) and save is not None and self.rng.randint(1,6) >= save:
                self.m.bump("saves"); continue
            target.cur_wounds -= 1; applied += 1
            self.m.bump("wounds")
            if target.cur_wounds <= 0:
                self._down(target); break
        if applied and not target.out and target.tests_nerve():
            self.nerve_test(target, "wounded")     # shock: wounded and survived (B.10)

    def _down(self, target):
        """Wounds exhausted -> KO (on the board, can be Executed or healed)."""
        if target.ko or target.dead: return
        target.ko = True; target.prone = True
        self.m.bump("ko")
        self._shock_allies(target)

    def _slay(self, target, source=None):
        target.dead = True; target.alive = False; target.ko = False
        self.m.bump("slain")
        self._shock_allies(target)

    def _shock_allies(self, fallen):
        """A friendly falling within 3" is a shock -> nearby allies test Nerve (B.10)."""
        for a in allies_of(self, fallen):
            if a.tests_nerve() and dist2d(a.pos, fallen.pos) <= NERVE_SHOCK_R:
                self.nerve_test(a, "ally_fell")

    # ---------------- COUNTER (turn-and-face, no cap, dying swing) --------- #
    def _maybe_counter(self, attacker, target, pk, is_counter, reach_strike):
        if is_counter:            return          # a Counter never draws a Counter (B.9)
        if reach_strike:          return          # struck from reach without contact -> no Counter
        if pk.is_ranged:          return          # ranged draws no Counter
        # target may be KO/Dead from the strike, but the DYING SWING still lands (B.9)
        if target.dead:           return          # truly removed (Executed) -> nothing swings
        arc = arc_of(target, attacker)
        # BRACED (PROVISIONAL): locked facing -> flank/rear hits draw no Counter, ever
        if target.braced and (not target.is_circle) and arc in ("flank", "rear"):
            self.m.bump("counter_denied"); return
        if (not target.is_circle) and arc in ("flank", "rear"):
            # denial only if the Square is already engaged with ANOTHER enemy it faces
            others = [e for e in engaged_enemies(self, target) if e is not attacker]
            if others:
                self.m.bump("counter_denied"); return
        cp = self._counter_packet(target)
        if not cp: return
        face_toward(target, attacker.x, attacker.y)
        self.m.bump("counters")
        self.resolve_attack(target, attacker, cp, is_counter=True)

    # ---------------- SHIELD INTERCEPT (reaction, PROVISIONAL) ------------- #
    def _maybe_intercept(self, attacker, target, pk):
        """A shield-bearer within 1" of the intended target may take the hit for it
        (SIGNED William 2026-07-24, PROVISIONAL). Uncapped — dying is the cap.
        Ignores facing. AI intercepts to protect a more-wounded or valuable friend."""
        guards = [a for a in allies_of(self, target)
                  if a.ft.has_trait("shield") and not a.out and gap(a, target) <= 1.0]
        if not guards:
            return target
        guard = max(guards, key=lambda g: g.cur_wounds)
        if guard.cur_wounds <= 0 or guard is target:
            return target
        valuable = (target.ft.has_trait("leader") or target.ft.has_trait("champion")
                    or target.ft.role == "Utility")
        # take the hit if the friend is at least as hurt as the shield, or is valuable,
        # or is one hit from going down — and the shield can still stand
        if target.cur_wounds <= guard.cur_wounds or valuable or target.cur_wounds <= 1:
            self.m.bump("intercepts")
            return guard
        return target

    def _counter_packet(self, fig):
        mp = fig.ft.melee_packets
        return mp[0] if mp else None

    # ---------------- NERVE / MORALE / ROUT (B.10) ------------------------- #
    def nerve_test(self, fig, reason):
        if not fig.tests_nerve() or fig.out: return
        # zeal/banner: some traits let a figure ignore the first step down (handled as re-read)
        n = roll_pool(self.rng, 3, fig.ft.nerve)
        self.m.bump("nerve_tests")
        old = fig.morale
        if n == 0:
            fig.morale = max(0, fig.morale - 1)
            if fig.ft.has_trait("zealous") and old == 2:
                fig.morale = old                  # zeal ignores the first Shaken step
        elif n == 3:
            fig.morale = min(2, fig.morale + 1)
        if fig.morale == 0 and old != 0:
            self.m.bump("routs")
            self._shock_allies(fig)               # a friendly going Broken is itself a shock

    def rally(self, leader):
        for a in allies_of(self, leader):
            if dist2d(a.pos, leader.pos) <= RALLY_R and a.morale < 2:
                a.morale = min(2, a.morale + 1); self.m.bump("rallies")

    # ---------------- ACTIVATION (Temperament-driven AI) ------------------ #
    def activate(self, fig: Figure):
        if fig.out: return
        fig.ap = fig.ft.max_ap
        fig.guard = max(0, fig.guard)             # guard persists until used up
        fig.braced = False                        # brace lasted until now; it expires as you act
        # stand up from Knockdown (costs 1 AP) if it wants to act
        if fig.prone and not fig.ko:
            fig.prone = False; fig.ap -= 1
        if fig.morale == 0:                       # BROKEN -> Rout by Temperament
            self._rout(fig); return
        # REGENERATION — a monster knits its wounds at the start of its activation
        if fig.ft.has_trait("regenerating") and fig.cur_wounds < fig.ft.max_wounds and not fig.ko:
            fig.cur_wounds += 1; self.m.bump("regen")
        # TERROR aura — the sight of the beast tests the nerve of everything near it
        if fig.ft.has_trait("terror"):
            for e in enemies_of(self, fig):
                if e.tests_nerve() and dist2d(fig.pos, e.pos) <= 4.0:
                    self.nerve_test(e, "terror_aura")
        # leaders rally first
        if fig.ft.has_trait("leader") or fig.ft.has_trait("champion"):
            self.rally(fig)
        temper = fig.ft.temperament
        guard_break = 0
        while fig.ap > 0 and guard_break < 8:
            guard_break += 1
            acted = self._ai_one_action(fig, temper)
            if not acted: break

    def _ai_one_action(self, fig, temper):
        foes = enemies_of(self, fig)
        if not foes: return False
        # --- Utility figures: heal/buff/debuff ---
        if fig.ft.role == "Utility":
            if self._try_utility(fig): return True
        # --- ranged / hybrid: shoot if a target is in range+LoS ---
        if fig.ft.ranged_packets:
            if self._try_shoot(fig): return True
        # --- REACH: strike an approaching foe in the 1-2" band BEFORE it makes
        #     contact — no Counter suffered (B.8). This is how a spear holds a lane.
        if any(p.reach for p in fig.ft.melee_packets) and fig.ap > 0:
            band = [e for e in foes if in_reach_band(fig, e)]
            if band:
                rp = next(p for p in fig.ft.melee_packets if p.reach)
                self.resolve_attack(fig, nearest(fig, band), rp, reach_strike=True)
                self.m.bump("reach_strikes")
                fig.ap -= 1; return True
        # engaged? strike the foe in contact.
        eng = engaged_enemies(self, fig)
        # BRACE (PROVISIONAL): a shield-bearer not yet engaged, with a foe closing
        # inside charge range, sets to receive it instead of walking onto their spears.
        if fig.ft.has_trait("shield") and not eng and not fig.braced and fig.ap > 0:
            n = nearest(fig, foes)
            if n and dist2d(fig.pos, n.pos) <= 7.0:
                face_toward(fig, n.x, n.y)
                fig.braced = True; fig.ap = 0; self.m.bump("braces")
                return True
        if eng:
            tgt = self._pick_melee_target(fig, eng)
            mp = fig.ft.melee_packets
            if mp and fig.ap > 0:
                self.resolve_attack(fig, tgt, self._best_melee(fig))
                fig.ap -= 1
                return True
        # movement intent by Temperament
        target = self._movement_target(fig, temper, foes)
        if target is None: return False
        tx, ty = target
        # if the intent is an enemy and Aggressive/Ravenous -> Sprint to Impact (charge)
        if isinstance(target, Figure):
            pass
        # decide charge
        tfig = self._charge_target(fig, temper, foes)
        if tfig is not None and fig.ap > 0:
            if self.sprint_impact(fig, tfig):
                fig.ap -= 1; return True
        # plain advance / reposition
        if fig.ap > 0:
            moved = self.move_toward(fig, tx, ty, budget=fig.ft.speed)
            fig.ap -= 1
            return moved > 0.05
        return False

    def _charge_target(self, fig, temper, foes):
        if temper not in ("Aggressive", "Ravenous") and not fig.ft.mounted:
            return None
        # a foe we can reach this activation
        reachable = [e for e in foes if dist2d(fig.pos, e.pos) - fig.ft.radius - e.ft.radius <= fig.ft.speed]
        if not reachable: return None
        if temper == "Ravenous":
            everyone = living([f for f in self.figs if f is not fig])
            everyone = [e for e in everyone if dist2d(fig.pos, e.pos)-fig.ft.radius-e.ft.radius <= fig.ft.speed]
            return nearest(fig, everyone) if everyone else None
        # GANG UP: prefer a foe an ally is already engaging (mob bonus + flank/rear arc)
        ganged = [e for e in reachable if any(touching(a, e) for a in allies_of(self, fig))]
        if ganged:
            return nearest(fig, ganged)
        return nearest(fig, reachable)

    def _movement_target(self, fig, temper, foes):
        n = nearest(fig, foes)
        if n is None: return None
        if temper == "Cowardly":
            # keep distance: if a foe is close, step away; else hold
            if dist2d(fig.pos, n.pos) < 8.0:
                ux, uy = norm(fig.x - n.x, fig.y - n.y)
                return (fig.x + ux*fig.ft.speed, fig.y + uy*fig.ft.speed)
            return (fig.x, fig.y)
        if temper == "Protective":
            ally = nearest(fig, allies_of(self, fig))
            if ally and dist2d(fig.pos, ally.pos) > 3.0:
                return (ally.x, ally.y)
            return (n.x, n.y)
        if temper == "Resolute":
            return (n.x, n.y)                     # advance to the objective/nearest steadily
        return (n.x, n.y)                         # Aggressive/Ravenous close in

    def _rout(self, fig):
        """Broken figure Routs by Temperament (B.10 table)."""
        t = fig.ft.temperament
        self.m.bump("rout_moves")
        if t == "Cowardly":
            edge_y = 0.0 if fig.side == 0 else self.board.d
            self.move_toward(fig, fig.x, edge_y, budget=fig.ft.speed)
        elif t == "Resolute":
            ally = nearest(fig, allies_of(self, fig))
            if ally: self.move_toward(fig, ally.x, ally.y, budget=fig.ft.speed*0.5)
        elif t == "Aggressive":
            foe = nearest(fig, enemies_of(self, fig))
            if foe and self.sprint_impact(fig, foe): pass
        elif t == "Protective":
            ally = nearest(fig, allies_of(self, fig))
            if ally: self.move_toward(fig, ally.x, ally.y, budget=fig.ft.speed)
        elif t == "Ravenous":                     # Wild: attack nearest figure, any side
            everyone = living([f for f in self.figs if f is not fig])
            v = nearest(fig, everyone)
            if v: self.sprint_impact(fig, v)

    # ---- action sub-helpers ----
    def _best_melee(self, fig):
        mp = fig.ft.melee_packets
        return max(mp, key=lambda p: p.dice) if mp else None
    def _pick_melee_target(self, fig, eng):
        # prefer a target we can finish (already Hurt) or a flank/rear shot
        hurt = [e for e in eng if e.hurt or e.ko]
        if hurt: return nearest(fig, hurt)
        flankable = [e for e in eng if arc_of(e, fig) in ("flank","rear")]
        if flankable: return nearest(fig, flankable)
        return nearest(fig, eng)

    def _try_shoot(self, fig):
        best = None
        for p in fig.ft.ranged_packets:
            cands = [e for e in enemies_of(self, fig)
                     if dist3d(fig.pos, fig.z, e.pos, e.z) <= p.rng
                     and not self.board.los_blocked(fig.pos, fig.z, e.pos, e.z)
                     and not touching(fig, e)]
            if cands:
                tgt = nearest(fig, cands)
                best = (p, tgt); break
        if not best: return False
        p, tgt = best
        self.resolve_attack(fig, tgt, p); fig.ap -= 1; return True

    def _try_utility(self, fig):
        # heal a hurt/KO ally; else buff; else debuff enemy cluster; else fall through
        for p in fig.ft.util_packets:
            pid = p.packet_id
            if pid in ("lay_on_hands",):
                hurt = [a for a in allies_of(self, fig) if (a.hurt or a.ko) and dist2d(fig.pos,a.pos)<=AURA_R+a.ft.radius]
                if hurt:
                    t = nearest(fig, hurt)
                    if t.ko: t.ko=False; t.prone=False; t.cur_wounds=1
                    else: t.cur_wounds=min(t.ft.max_wounds, t.cur_wounds+1)
                    t.morale=min(2,t.morale+1); fig.ap-=1; self.m.bump("heals"); return True
            if pid in ("rally_command","holy_banner"):
                low = [a for a in allies_of(self, fig) if a.morale<2 and dist2d(fig.pos,a.pos)<=RALLY_R]
                if low:
                    self.rally(fig); fig.ap-=1; self.m.bump("commands"); return True
            if pid in ("curse_of_morgul",):
                foes = [e for e in enemies_of(self, fig) if dist2d(fig.pos,e.pos)<=RALLY_R]
                if len(foes)>=2:
                    for e in foes:
                        if e.tests_nerve(): self.nerve_test(e,"curse")
                    fig.ap-=1; self.m.bump("curses"); return True
            if pid in ("drive_them_on","savage_command"):
                mate = nearest(fig, [a for a in allies_of(self, fig) if a.ft.creature_type=="Man"])
                if mate:
                    foe=nearest(mate, enemies_of(self,mate))
                    if foe: self.move_toward(mate, foe.x, foe.y, budget=mate.ft.speed*0.6)
                    if p.packet_id=="drive_them_on" and mate.tests_nerve(): self._wound(mate,1,False)
                    fig.ap-=1; self.m.bump("drives"); return True
            if pid in ("smite","black_breath"):     # utility hybrids can also blast
                cands=[e for e in enemies_of(self,fig) if dist2d(fig.pos,e.pos)<=p.rng
                       and not self.board.los_blocked(fig.pos,fig.z,e.pos,e.z)]
                if cands:
                    self.resolve_attack(fig,nearest(fig,cands),p); fig.ap-=1; return True
        return False

    # ---------------- RUN LOOP (alternation, B.12) ------------------------- #
    def run(self):
        if self.record: self._snapshot("Deploy")
        for self.round in range(1, self.max_rounds+1):
            for f in self.figs: f.activated = False
            order = self._activation_order()
            for fig in order:
                if fig.out or fig.activated: continue
                fig.activated = True
                self.activate(fig)
            if self.record: self._snapshot(f"Round {self.round}")
            w = self._winner()
            if w is not None:
                return {"winner": w, "reason": "elimination", "rounds": self.round,
                        "survivors": self._counts()}
        return {"winner": self._winner(force=True), "reason": "rounds",
                "rounds": self.max_rounds, "survivors": self._counts()}

    def _activation_order(self):
        # alternation: A, B, A, B ... using Tempo as a soft tie-break (Fast acts earlier)
        tv = {">":0, ">>":1, ">>>":2}
        a = sorted([f for f in self.figs if f.side==0 and not f.out], key=lambda f:-tv.get(f.ft.tempo,1))
        b = sorted([f for f in self.figs if f.side==1 and not f.out], key=lambda f:-tv.get(f.ft.tempo,1))
        order=[]
        for i in range(max(len(a),len(b))):
            if i<len(a): order.append(a[i])
            if i<len(b): order.append(b[i])
        return order

    def _counts(self):
        return (len([f for f in self.figs if f.side==0 and not f.out]),
                len([f for f in self.figs if f.side==1 and not f.out]))

    def _effective(self, side):
        # a side is combat-effective if it has non-Broken, non-out figures
        return [f for f in self.figs if f.side==side and not f.out and f.morale>0]

    def _winner(self, force=False):
        e0, e1 = self._effective(0), self._effective(1)
        if not e0 and not e1: return None if not force else self._by_points()
        if not e0: return 1
        if not e1: return 0
        if force:  return self._by_points()
        return None

    def _by_points(self):
        c0,c1=self._counts()
        if c0==c1: return None
        return 0 if c0>c1 else 1
