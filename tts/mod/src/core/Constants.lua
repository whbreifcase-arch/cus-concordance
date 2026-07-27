-- core/Constants.lua
-- Canonical CUS vocabulary. Nothing here is runtime state; these are the fixed
-- strings the kernel defines. Do not invent parallel values.
--
-- AUTHORITY: CUS_KERNEL_REBUILD v0.6 (SIGNED, closed 2026-07-24) —
--   A_KERNEL_CONSTITUTION.md · B_COMBAT_MODULE.md · C_KERNEL_DICTIONARY.md
-- This file was migrated off Codex v0.5. Where v0.5 and v0.6 disagree, v0.6
-- wins; the v0.5 term is recorded in C.RETIRED so old saves still load.
--
-- Include order note: this file only reads/writes the global `CUS` table, so it
-- may be #include'd first. Every module follows the same pattern:
--     CUS = CUS or {}
--     CUS.Thing = { ... }

CUS = CUS or {}

local C = {}

C.CODEX_VERSION = "0.6"

-- Schema versions (bump + add a migration hook when a stored shape changes).
-- v2 = the v0.6 kernel rebuild: three verbs, three roles, three classes.
C.UNIT_SCHEMA_VERSION  = 2
C.STATE_SCHEMA_VERSION = 2

-- ---------------------------------------------------------------- THE VERBS
-- THREE canonical verbs (A.III, SIGNED). The radial wheel root is EXACTLY
-- these. Combat renames them for flavour only — the player reads "Strike", the
-- system reads ACTION. Never add a fourth (Law 11: translate, don't fork).
--   MOVE   changes Position now
--   ACTION resolves a PACKET now
--   WAIT   arms a PACKET for later
C.ACTIONS = { "MOVE", "ACTION", "WAIT" }
C.ACTION_SET = { MOVE = true, ACTION = true, WAIT = true }

-- Player-facing flavour per verb. Presentation only (B.15).
C.ACTION_FLAVOUR = {
  MOVE   = { "Advance", "Sprint", "Leap", "Withdraw" },
  ACTION = { "Strike", "Interact", "Cast" },
  WAIT   = { "Brace", "Overwatch", "Ready" },
}

-- v0.5 -> v0.6 mapping, used when loading an old save or an old card.
C.RETIRED = {
  ACTIONS = { ATTACK = "ACTION", USE = "ACTION", READY = "WAIT" },
  ROLES   = { Assault = "Pressure", Skirmisher = "Pressure",
              Control = "Utility",  Support    = "Utility",
              Anchor  = "Anchor" },
  CLASSES = { Normal = "Medium", Cavalry = "Medium", Monstrous = "Large" },
  -- Cavalry becomes Medium + mounted geometry; Monstrous becomes Large + the
  -- `unstoppable` trait. Neither is a size class any more (B.1, B.4).
  CLASS_SIDECAR = { Cavalry = { mounted = true }, Monstrous = { trait = "unstoppable" } },
  TERMS = { Charge = "Sprint + Impact", Tier = "Grade", Rung = "Grade", Push = "Shove" },
}

-- ---------------------------------------------------------------- THE AXES
-- ROLE — relationship with Force (A.VII, SIGNED: exactly three).
C.ROLES = { "Pressure", "Anchor", "Utility" }
C.ROLE_NOTE = {
  Pressure = "Applies Force. Breaks, defeats or forces back.",
  Anchor   = "Absorbs or denies Force. Holds a place, a line or a figure.",
  Utility  = "Redirects Force. Enables, restores, controls, interacts.",
}

-- TEMPO — relative timing of Force (ordinal classification, Law 10).
C.TEMPO = { ">", ">>", ">>>" }

-- TOOL — how Force is delivered (vibe-check, SIGNED).
C.TOOLS = { "Melee", "Ranged", "Hybrid" }

-- TEMPERAMENT — preferred application of Force. Governs leaderless behaviour
-- and Rout behaviour (B.10). Text shown to the player verbatim; the mod never
-- auto-moves a routed model.
C.TEMPERAMENTS = {
  Cowardly   = { rout = "Flees to its own table edge.",                            lone = "Keeps distance, strikes only with the odds." },
  Resolute   = { rout = "Falls back toward its leader / the objective.",           lone = "Holds or pursues the objective." },
  Aggressive = { rout = "Makes one last reckless advance at the nearest enemy.",   lone = "Advances on the nearest enemy." },
  Protective = { rout = "Retreats to the nearest ally.",                           lone = "Guards / stays close to the nearest ally." },
  Ravenous   = { rout = "Turns WILD — attacks the nearest figure, friend or foe.", lone = "Attacks the nearest figure, any side." },
}

-- Creature types (govern Nerve eligibility & mending, B.13).
C.CREATURE_TYPES = { "Man", "Beast", "Spirit", "Construct" }
-- Only Man and Beast test Nerve. Spirit and Construct are fearless (B.10).
C.TESTS_NERVE = { Man = true, Beast = true, Spirit = false, Construct = false }

-- ---------------------------------------------------------------- THE BASE
-- Shape = TYPE.  Circle = hero/avatar. FACELESS — no facing, cannot be flanked,
--                never tests Nerve, never breaks, cannot Brace.
--                Square = crew. Has a facing. May test Nerve, may break.
-- SIGNED: a Banner fields EXACTLY ONE Circle — its Champion.
C.SHAPES = { "Circle", "Square" }
C.ONE_CIRCLE_PER_BANNER = true

-- Size = CLASS. THREE classes, read from the footprint (B.1, SIGNED).
-- There is no Monstrous class and no Cavalry class.
C.CLASSES = { "Small", "Medium", "Large" }
C.CLASS_ORDER = { Small = 1, Medium = 2, Large = 3 }

-- Footprints in millimetres, by shape and class.
C.FOOTPRINT = {
  Square = { Small = 20, Medium = 25, Large = 40 },
  Circle = { Small = 25, Medium = 32, Large = 40 },
}

-- Mounted is GEOMETRY, not a size class: an elongated base. A mounted figure
-- keeps its class and PLOWS AS ONE CLASS LARGER (the lance, B.4).
C.MOUNTED_PLOWS_UP = 1

-- Default Agency by shape (a DEFAULT, not a law — always read the card;
-- the Watch Sergeant is a Square with 3 AP).
C.DEFAULT_AP = { Circle = 3, Square = 2 }

-- ---------------------------------------------------------------- RESULTS
-- Success Grade (A.VI, SIGNED — Model 2, DISCRETE). Resolving Grade N resolves
-- ONLY the effects printed on Grade N. A higher Grade does NOT carry up the
-- lower Grades' effects. Never call this a Tier, a Ladder or a Rung.
C.GRADE_MODEL = "discrete"
C.GRADES = { 1, 2, 3 }

-- Armour save sheet (a die per Wound). Numeric threshold or nil (= None).
-- "step worse" adds 1 to the threshold; worse than 6+ can no longer save.
C.ARMOUR = {
  None   = { save = nil, label = "None"   },
  Light  = { save = 6,   label = "Light"  },
  Medium = { save = 5,   label = "Medium" },
  Heavy  = { save = 4,   label = "Heavy"  },
}
C.ARMOUR_BY_SAVE = { [6] = "Light", [5] = "Medium", [4] = "Heavy" }

-- Health track (B.7, a Combat fact — retunable, do not promote upward).
C.WOUND_STATES = { "Fine", "Hurt", "KO", "Dead" }

-- Morale track (B.10, SIGNED — three states, like everything else).
C.MORALE_STATES = { "Steady", "Shaken", "Broken" }
C.MORALE_ORDER  = { Steady = 1, Shaken = 2, Broken = 3 }

-- The Nerve test (B.10, SIGNED): roll 3 dice, each >= the figure's Nerve is a
-- success. 0 -> step DOWN the morale track; 1-2 -> hold; 3 -> step UP.
C.NERVE = {
  dice            = 3,
  down_at         = 0,   -- successes
  hold_lo         = 1,
  hold_hi         = 2,
  up_at           = 3,
  shock_radius_in = 3,   -- a friendly slain or Broken within 3" is a shock
}

-- Ranged modes (poster / B.15).
C.SHOT_MODES = { "Regular", "Precision", "Multi" }

-- Packet kinds. Under v0.6 these are no longer three species of "ability" —
-- Active and Reactive are simply which VERB resolves the PACKET (ACTION or
-- WAIT), and Passive is not a packet at all: an always-true property is a
-- TRAIT, a referenced passive Definition that resolves nothing (B.14).
-- The vocabulary is kept because card data and Schema still validate against it.
C.ABILITY_TYPES = { "Active", "Reactive", "Passive" }
C.ABILITY_PARENT_VERB = { Active = "ACTION", Reactive = "WAIT", Passive = nil }

-- Formation families. Formations are DESCRIPTIVE, not prescriptive (B.11):
-- a Definition holds only Name, Picture and one sentence of intent.
C.FORMATION_FAMILIES = { "Open", "Closed" }

-- ---------------------------------------------------------------- TUNING
-- All descriptive-geometry helpers; the player always confirms.
C.TUNING = {
  -- Engagement is BASE CONTACT (B.8, SIGNED). There is no measured band — if
  -- the bases touch, the figures are engaged, full stop. The tolerance below
  -- exists only to absorb physics jitter in TTS, never as a rules band.
  contact_tolerance_cm = 0.35,
  reach_band_in_min    = 1.0,  -- a Reach figure threatens 1-2" without contact
  reach_band_in_max    = 2.0,
  disengage_ap         = 1,    -- leaving an engagement costs 1 AP
  jitter_threshold     = 0.3,  -- min world units before a MOVE waypoint is added
  reform_radius_in     = 3.0,
  flank_die            = 1,    -- Flank = +1 die
  backstab_die         = 2,    -- Rear/Backstab = +2 dice AND no Counter
  wall_crush_die       = 2,    -- confirmed wall/obstacle jam = +2 dice
  multishot_hit_step   = 1,
  precision_die        = 1,
  brace_die            = 1,    -- PROVISIONAL (B.9b): +1 attacking into your front,
  brace_penalty_die    = 1,    -- and enemies into your front roll -1
  shove_default_in     = 1.0,  -- PROVISIONAL: Shove X = Y = 1" by default
  one_attack_per_activation = true,
  facing_axis          = "local_z",
}

-- Counter (B.9, SIGNED). There is NO per-round cap and no counter_x economy.
C.COUNTER = {
  capped               = false, -- a figure Counters EVERY enemy that attacks it
  dying_swing          = true,  -- and Counters even as it dies
  draws_no_counter     = true,  -- a Counter is a response, not an ATTACK
  free_target_always   = true,  -- a free target always swings, and becomes engaged
  denied_by_flank_rear = true,  -- only on a Square ALREADY engaged elsewhere
  circles_always       = true,  -- a Circle is faceless: it always Counters
  reach_no_contact     = false, -- a Reach strike from outside contact draws none
}

-- PROVISIONAL (B.9b) — shields, Brace and Shove fell out of one conversation
-- and are NOT ratified. Gate anything that reads these behind this flag.
C.PROVISIONAL = {
  enabled       = true,
  shield_intercept = true,  -- consume an ACTION aimed at a friend within 1"
  brace         = true,     -- Square-only WAIT, locks facing
  shove         = true,     -- weapon displacement, renamed from "Push"
}

-- ---------------------------------------------------------------- HOTKEYS
-- Named hotkeys registered with TTS (mapped by the user in Options -> Controls).
C.HOTKEYS = {
  "CUS: Action Wheel",
  "CUS: Open Card",
  "CUS: Move",
  "CUS: Action",
  "CUS: Wait",
  "CUS: Activate / End Activation",
  "CUS: Cancel Operation",
  "CUS: Undo Last State Change",
}

-- UI colour language (kept small so the table stays clean).
C.COLOR = {
  selected  = { 0.25, 0.85, 1.00 },  -- current figure
  attacker  = { 1.00, 0.55, 0.10 },  -- current attacker
  defender  = { 0.95, 0.20, 0.20 },  -- current defender
  candidate = { 1.00, 0.90, 0.30 },  -- target candidate
  linkpair  = { 0.55, 1.00, 0.55 },  -- hovered link pair
}

-- ---------------------------------------------------------------- HELPERS
-- Normalise a term loaded from a v0.5 save or an old card.
function C.migrateAction(a) return C.RETIRED.ACTIONS[a] or a end
function C.migrateRole(r)   return C.RETIRED.ROLES[r]   or r end
function C.migrateClass(c)  return C.RETIRED.CLASSES[c] or c end

-- Returns the v0.6 class, plus any sidecar facts the old class implied
-- (Cavalry -> mounted, Monstrous -> the unstoppable trait).
function C.migrateClassFull(c)
  local side = C.RETIRED.CLASS_SIDECAR[c]
  return (C.RETIRED.CLASSES[c] or c), side
end

CUS.Constants = C
