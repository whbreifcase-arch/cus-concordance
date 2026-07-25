"""
CUS v0.6 COMBAT ENGINE — built from scratch, native to the Kernel Rebuild (A/B/C).
NOT the retired Module-K. Implements the SIGNED v0.6 combat module:

  * Verbs MOVE / ACTION / WAIT (A.III)
  * PACKET -> count Successes -> Success Grade, Model 2 DISCRETE (A.VI, B.5):
      resolving Grade N resolves ONLY Grade N's effects. No inheritance.
  * Effects: Wound, Push, Pull, Knockdown, Guard, Cleave, Execute, ignore Armour, Terror
  * Armour None/Light/Medium/Heavy = -/6+/5+/4+ , one save die per Wound (B.7)
  * Wounds  Fine -> Hurt -> KO -> Dead (B.7)
  * Counter: turn-and-face, no cap, dying swing lands, Circles faceless,
      flank/rear denial on already-engaged Squares, Reach suffers no Counter,
      a Counter never draws a Counter (B.9, SIGNED)
  * Engagement: bases touching = engaged; Reach threatens 1-2"; Disengage 1 AP (B.8)
  * Nerve: Squares (Man/Beast) test on a shock; roll 3 dice, success = die >= Nerve;
      0 = step down, 1-2 = hold, 3 = step up; Steady->Shaken->Broken (B.10, SIGNED)
  * Sprint -> Impact -> Push / Indent / Crush geometry (B.3, B.4)

SPATIAL: continuous (x,y) inches PLUS a real z elevation axis. Terrain = walls
(block move + LoS), platforms/hills (elevation, climb cost per story, high ground,
LoS block), low cover (ranged penalty). LoS is computed in 3D. High ground grants
+1 attack die; a downhill Impact grants +1. Climbing costs Agency per story (B.2).

Pure stdlib so games pickle cleanly for multiprocessing across all cores.
"""
from __future__ import annotations
import math, random
from dataclasses import dataclass, field
from typing import Optional

# --------------------------------------------------------------------------- #
#  CONSTANTS (Combat Module facts, B — retunable, not Kernel law)
# --------------------------------------------------------------------------- #
STORY_H       = 3.0     # inches per "story" of elevation (B.2 climb unit)
CLIMB_PER_STORY = 3.0   # inches of MOVE budget consumed per story climbed
CONTACT       = 0.30    # base-gap under which two figures count as "touching" (B.8)
REACH_BAND    = (0.30, 2.0)  # a Reach weapon threatens this 1-2" band (B.8)
NERVE_SHOCK_R = 3.0     # a friendly falling within this radius is a shock (B.10)
RALLY_R       = 6.0     # Rally / command aura radius
AURA_R        = 3.0     # generic buff-aura radius
HIGHGROUND_DZ = STORY_H # elevation gap that grants the high-ground die
ARMOUR_SAVE   = {"None": None, "Light": 6, "Medium": 5, "Heavy": 4}
SIZE_RADIUS   = {"Small": 0.40, "Medium": 0.55, "Large": 0.90}   # base radius, inches
SIZE_ORDER    = {"Small": 0, "Medium": 1, "Large": 2}

# --------------------------------------------------------------------------- #
#  GEOMETRY
# --------------------------------------------------------------------------- #
def dist2d(a, b):  return math.hypot(a[0]-b[0], a[1]-b[1])
def dist3d(a, az, b, bz): return math.sqrt((a[0]-b[0])**2 + (a[1]-b[1])**2 + (az-bz)**2)
def norm(dx, dy):
    d = math.hypot(dx, dy)
    return (0.0, 0.0) if d < 1e-9 else (dx/d, dy/d)

def seg_intersect(p1, p2, p3, p4):
    """True if segment p1p2 crosses segment p3p4 (2D)."""
    def ccw(a, b, c): return (c[1]-a[1])*(b[0]-a[0]) - (b[1]-a[1])*(c[0]-a[0])
    d1 = ccw(p3, p4, p1); d2 = ccw(p3, p4, p2)
    d3 = ccw(p1, p2, p3); d4 = ccw(p1, p2, p4)
    if ((d1 > 0) != (d2 > 0)) and ((d3 > 0) != (d4 > 0)):
        return True
    return False

def seg_cross_t(a, b, c, d):
    """Parameter t in [0,1] along a->b where it crosses segment c->d, else None."""
    r = (b[0]-a[0], b[1]-a[1]); s = (d[0]-c[0], d[1]-c[1])
    denom = r[0]*s[1] - r[1]*s[0]
    if abs(denom) < 1e-12: return None
    qp = (c[0]-a[0], c[1]-a[1])
    t = (qp[0]*s[1] - qp[1]*s[0]) / denom
    u = (qp[0]*r[1] - qp[1]*r[0]) / denom
    if 0.0 <= t <= 1.0 and 0.0 <= u <= 1.0:
        return t
    return None

# --------------------------------------------------------------------------- #
#  TERRAIN
# --------------------------------------------------------------------------- #
@dataclass
class Wall:
    """A blocking segment of a given height. Blocks MOVE across it and blocks
    line-of-sight for anything trying to see over it from below its height."""
    x1: float; y1: float; x2: float; y2: float
    height: float = 4.0
    def blocks_move(self, a, b):
        return seg_intersect((a[0], a[1]), (b[0], b[1]), (self.x1, self.y1), (self.x2, self.y2))

@dataclass
class Platform:
    """Axis-aligned raised ground (hill / rampart / building top). A figure whose
    (x,y) is inside gains elevation = top. Climbing onto it costs Agency (B.2)."""
    x0: float; y0: float; x1: float; y1: float
    top: float = 3.0
    def contains(self, p): return self.x0 <= p[0] <= self.x1 and self.y0 <= p[1] <= self.y1

@dataclass
class LowCover:
    """Ranged cover: a shot whose line passes through gets +1 to its success number
    (harder). Does not block movement."""
    x0: float; y0: float; x1: float; y1: float
    def seg_crosses(self, a, b):
        edges = [((self.x0,self.y0),(self.x1,self.y0)), ((self.x1,self.y0),(self.x1,self.y1)),
                 ((self.x1,self.y1),(self.x0,self.y1)), ((self.x0,self.y1),(self.x0,self.y0))]
        return any(seg_intersect((a[0],a[1]),(b[0],b[1]),e[0],e[1]) for e in edges)

@dataclass
class Board:
    w: float = 44.0
    d: float = 30.0
    walls: list = field(default_factory=list)
    platforms: list = field(default_factory=list)
    covers: list = field(default_factory=list)

    def ground_z(self, p):
        z = 0.0
        for pf in self.platforms:
            if pf.contains(p): z = max(z, pf.top)
        return z

    def move_blocked(self, a, b):
        return any(wl.blocks_move(a, b) for wl in self.walls)

    def in_bounds(self, p):
        return 0.0 <= p[0] <= self.w and 0.0 <= p[1] <= self.d

    def los_blocked(self, a, az, b, bz):
        """3D LoS: a wall/platform blocks sight only if its top rises ABOVE the
        sight line's interpolated height at the crossing point. A shooter on high
        ground sees over a low wall; a low shooter does not."""
        eye_a, eye_b = az + 1.0, bz + 1.0            # eye height above own footing
        for wl in self.walls:
            t = seg_cross_t((a[0],a[1]),(b[0],b[1]),(wl.x1,wl.y1),(wl.x2,wl.y2))
            if t is not None:
                h_line = eye_a + t*(eye_b - eye_a)
                if wl.height > h_line + 0.01:
                    return True
        for pf in self.platforms:
            if pf.top <= max(az, bz) + 0.1:          # not taller than viewer or target
                continue
            if pf.contains(a) or pf.contains(b):     # standing on/in it -> no self-block
                continue
            edges = [((pf.x0,pf.y0),(pf.x1,pf.y0)), ((pf.x1,pf.y0),(pf.x1,pf.y1)),
                     ((pf.x1,pf.y1),(pf.x0,pf.y1)), ((pf.x0,pf.y1),(pf.x0,pf.y0))]
            for e in edges:
                t = seg_cross_t((a[0],a[1]),(b[0],b[1]),e[0],e[1])
                if t is not None:
                    h_line = eye_a + t*(eye_b - eye_a)
                    if pf.top > h_line + 0.01:
                        return True
        return False

    def cover_between(self, a, b):
        return any(cv.seg_crosses(a, b) for cv in self.covers)

# --------------------------------------------------------------------------- #
#  DEFINITIONS (loaded from the v0.6 JSON — stateless, Law 5)
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class Grade:
    successes: int
    effects: tuple           # tuple[str]

@dataclass(frozen=True)
class PacketDef:
    packet_id: str
    name: str
    verb: str                # MOVE | ACTION | WAIT
    dice: int
    success: int             # a die >= success is a Success
    rng: float               # 0 = melee
    cost_ap: int
    grades: tuple            # tuple[Grade] ascending by successes
    reach: bool = False      # threatens the reach band, suffers no Counter
    is_ranged: bool = False
    trigger: str = ""

    def grade_for(self, n_success):
        """Highest Grade whose success requirement is met (Model 2 discrete)."""
        chosen = None
        for g in self.grades:
            if n_success >= g.successes:
                chosen = g
        return chosen

@dataclass(frozen=True)
class FigureType:
    definition_id: str
    name: str
    faction: str
    role: str                # Pressure | Anchor | Utility   (v0.6, P/A/U ONLY)
    tempo: str               # > | >> | >>>
    tool: str                # Melee | Ranged | Hybrid
    temperament: str         # Cowardly|Resolute|Aggressive|Protective|Ravenous
    creature_type: str       # Man | Beast | Spirit | Construct
    archetype: str
    rank: str
    shape: str               # Circle | Square
    size: str                # Small | Medium | Large
    mounted: bool
    max_wounds: int
    armour: str              # None|Light|Medium|Heavy
    nerve: int               # success number for the 3-dice test (LOWER = braver)
    speed: float
    max_ap: int
    traits: tuple
    packets: tuple           # tuple[PacketDef]
    points: int = 0

    @property
    def radius(self): return SIZE_RADIUS[self.size]
    def has_trait(self, t): return t in self.traits
    @property
    def melee_packets(self): return tuple(p for p in self.packets if not p.is_ranged and p.verb == "ACTION" and p.dice > 0)
    @property
    def ranged_packets(self): return tuple(p for p in self.packets if p.is_ranged)
    @property
    def util_packets(self): return tuple(p for p in self.packets if p.dice == 0 and p.verb in ("ACTION","WAIT"))

# --------------------------------------------------------------------------- #
#  INSTANCE (the ONLY home of runtime state, Law 5 / A.IX)
# --------------------------------------------------------------------------- #
MORALE = ["Broken", "Shaken", "Steady"]     # index order; step up/down by index

class Figure:
    __slots__ = ("ft","side","uid","x","y","z","facing","cur_wounds","ap","morale",
                 "guard","prone","armed","reaction","alive","ko","activated","dead","braced")
    def __init__(self, ft: FigureType, side: int, uid: str, x, y, facing=0.0):
        self.ft = ft; self.side = side; self.uid = uid
        self.x = x; self.y = y; self.z = 0.0
        self.facing = facing
        self.cur_wounds = ft.max_wounds
        self.ap = ft.max_ap
        self.morale = 2               # Steady
        self.guard = 0
        self.prone = False
        self.armed = None             # (PacketDef, trigger) armed by WAIT
        self.reaction = True
        self.alive = True             # False once removed (Dead)
        self.ko = False               # down but on the board (can be Executed/healed)
        self.dead = False
        self.activated = False
        self.braced = False           # PROVISIONAL: locked facing, front bonus, flank-exposed (B.brace)

    # --- read helpers ---
    @property
    def pos(self): return (self.x, self.y)
    @property
    def name(self): return self.ft.name
    @property
    def hurt(self): return self.cur_wounds < self.ft.max_wounds
    @property
    def is_circle(self): return self.ft.shape == "Circle"
    @property
    def out(self): return self.dead or self.ko or not self.alive
    def tests_nerve(self):
        return (self.ft.shape == "Square"
                and self.ft.creature_type in ("Man", "Beast")
                and not self.ft.has_trait("fearless"))

# --------------------------------------------------------------------------- #
#  DICE
# --------------------------------------------------------------------------- #
def roll_pool(rng: random.Random, n, target):
    """Roll n d6, return number of successes (die >= target)."""
    if n <= 0: return 0
    return sum(1 for _ in range(n) if rng.randint(1, 6) >= target)

# --------------------------------------------------------------------------- #
#  METRICS  (every mechanic gets a fire-counter; a near-zero count = a bug)
# --------------------------------------------------------------------------- #
class Metrics:
    def __init__(self):
        self.c = {}
    def bump(self, k, n=1): self.c[k] = self.c.get(k, 0) + n
    def get(self, k): return self.c.get(k, 0)
