-- ==========================================================================
-- Global.lua — CUS Tabletop Simulator playtest controller
-- ==========================================================================
-- Build note: the #include lines below use the official TTS VSCode/Atom Lua
-- extension. If you paste by hand instead, concatenate the files in THIS ORDER
-- (each only touches the shared global `CUS` table, so order = dependency order)
-- and delete the #include lines. See docs/SETUP.md.

-- ===== begin core/Constants =====
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

-- ===== end core/Constants =====
-- ===== begin core/Schema =====
-- core/Schema.lua
-- Versioned schemas, validation, and safe defaults.
--   * A Unit DEFINITION lives on the physical card (never holds runtime state).
--   * A miniature RUNTIME STATE lives on the miniature (never holds max stats).
--   * Packets are stateless referenced definitions.
--
-- Validation returns (ok, errorsTable). Safe defaults are provided for UI only;
-- we never guess an unresolved *rule* value.

CUS = CUS or {}
local C = CUS.Constants
local Schema = {}

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------
local function inList(v, list)
  for _, x in ipairs(list) do if x == v then return true end end
  return false
end

local function isNum(v) return type(v) == "number" end
local function isStr(v) return type(v) == "string" and v ~= "" end
local function isBool(v) return type(v) == "boolean" end

-- ---------------------------------------------------------------------------
-- Unit definition (stored on the card)
-- ---------------------------------------------------------------------------
function Schema.defaultDefinition()
  return {
    schema_version = C.UNIT_SCHEMA_VERSION,
    definition_id  = "UNDEFINED",
    name           = "Unnamed Unit",
    role           = "Assault",
    tool           = "Melee",
    creature_type  = "Man",
    archetype      = "",
    signature      = "",
    stats = {
      max_wounds = 1, armour = "None", speed = 6, max_ap = 2, nerve = 0, rank = "I",
    },
    base = {
      shape = "Square", class = "Normal", mounted = false, forward_axis = C.TUNING.facing_axis,
    },
    attack_packet_ids  = {},
    ability_packet_ids = {},
    temperament        = "Resolute",
    display = {
      card_image_url = "", weapon = "", dice = 0, hit = "—",
      tiers = "", armour = "—", base = "", note = "",
    },
  }
end

-- Validate a definition. Coerces obvious legacy shapes; reports hard errors.
function Schema.validateDefinition(def)
  local errs = {}
  if type(def) ~= "table" then return false, { "definition is not a table" } end

  if not isNum(def.schema_version) then errs[#errs+1] = "missing schema_version" end
  if not isStr(def.definition_id)  then errs[#errs+1] = "missing definition_id"  end
  if not isStr(def.name)           then errs[#errs+1] = "missing name"           end
  if not inList(def.role, C.ROLES)                   then errs[#errs+1] = "invalid role: "..tostring(def.role) end
  if not inList(def.creature_type, C.CREATURE_TYPES) then errs[#errs+1] = "invalid creature_type: "..tostring(def.creature_type) end

  local s = def.stats
  if type(s) ~= "table" then
    errs[#errs+1] = "missing stats block"
  else
    if not isNum(s.max_wounds) then errs[#errs+1] = "stats.max_wounds not a number" end
    if not isNum(s.max_ap)     then errs[#errs+1] = "stats.max_ap not a number"     end
    -- armour may be a class name, a numeric save, or nil/— (None)
    if s.armour ~= nil and not isStr(s.armour) and not isNum(s.armour) then
      errs[#errs+1] = "stats.armour must be a class name, number, or nil"
    end
  end

  local b = def.base
  if type(b) ~= "table" then
    errs[#errs+1] = "missing base block"
  else
    if not inList(b.shape, C.SHAPES) then errs[#errs+1] = "invalid base.shape: "..tostring(b.shape) end
    if not inList(b.class, C.CLASSES) then errs[#errs+1] = "invalid base.class: "..tostring(b.class) end
  end

  if def.temperament ~= nil and not C.TEMPERAMENTS[def.temperament] then
    errs[#errs+1] = "invalid temperament: "..tostring(def.temperament)
  end
  if type(def.attack_packet_ids)  ~= "table" then errs[#errs+1] = "attack_packet_ids not a list"  end
  if type(def.ability_packet_ids) ~= "table" then errs[#errs+1] = "ability_packet_ids not a list" end

  return #errs == 0, errs
end

-- Resolve a definition's armour class name from its stored value (class | save# | nil).
function Schema.armourClass(def)
  local a = def and def.stats and def.stats.armour
  if a == nil or a == "" or a == "—" then return "None" end
  if type(a) == "number" then return C.ARMOUR_BY_SAVE[a] or "None" end
  if C.ARMOUR[a] then return a end
  return "None"
end

-- ---------------------------------------------------------------------------
-- Attack packet
-- ---------------------------------------------------------------------------
function Schema.validateAttackPacket(p)
  local errs = {}
  if type(p) ~= "table" then return false, { "packet not a table" } end
  if not isStr(p.id)   then errs[#errs+1] = "packet missing id" end
  if p.parent_action ~= "ATTACK" then errs[#errs+1] = "attack packet parent_action must be ATTACK" end
  if not isNum(p.dice) then errs[#errs+1] = "packet.dice not a number" end
  if not isNum(p.hit)  then errs[#errs+1] = "packet.hit not a number" end
  if type(p.tiers) ~= "table" or #p.tiers == 0 then
    errs[#errs+1] = "packet.tiers must be a non-empty list"
  else
    for i, t in ipairs(p.tiers) do
      if not isNum(t.successes) then errs[#errs+1] = "tier "..i.." missing successes" end
      if t.wounds ~= nil and not isNum(t.wounds) then errs[#errs+1] = "tier "..i.." wounds not a number" end
    end
  end
  return #errs == 0, errs
end

-- ---------------------------------------------------------------------------
-- Ability packet
-- ---------------------------------------------------------------------------
function Schema.validateAbilityPacket(p)
  local errs = {}
  if type(p) ~= "table" then return false, { "packet not a table" } end
  if not isStr(p.id) then errs[#errs+1] = "ability packet missing id" end
  if not inList(p.type, C.ABILITY_TYPES) then errs[#errs+1] = "ability packet invalid type: "..tostring(p.type) end
  -- Active abilities MUST hyperlink to exactly one canonical action.
  if p.type == "Active" and not C.ACTION_SET[p.parent_action] then
    errs[#errs+1] = "Active ability must have a canonical parent_action"
  end
  return #errs == 0, errs
end

-- ---------------------------------------------------------------------------
-- Miniature runtime state (lives on the miniature)
-- ---------------------------------------------------------------------------
function Schema.defaultRuntimeState()
  return {
    schema_version         = C.STATE_SCHEMA_VERSION,
    card_guid              = nil,
    expected_definition_id = nil,
    state = {
      current_wounds          = 1,
      current_ap              = 2,
      activated               = false,
      moved_this_activation   = false,
      attacked_this_activation= false,
      armed_packet_id         = nil,  -- the packet a WAIT has armed
      ready_packet_id         = nil,  -- retired v0.5 key, kept so old saves load
      reaction_spent          = false,
      -- No counter_uses_remaining. B.9 (SIGNED): Counters have NO per-round cap
      -- and no counter_x economy — a figure Counters every enemy that attacks
      -- it, and Counters even as it dies. The only cap is that it eventually dies.
      conditions              = {},   -- list of { id, icon?, duration?, source?, modifiers? }
      morale                  = "Steady", -- Steady | Shaken | Broken (never auto-moves)
      facing_locked           = false,
      forward_axis            = C.TUNING.facing_axis,
      movement_session        = nil,  -- { origin, rot, path = {...}, used, active }
      formation               = nil,  -- { name, family, leader_guid }
      temporary_modifiers     = {},
    },
  }
end

function Schema.validateRuntimeState(rs)
  local errs = {}
  if type(rs) ~= "table" then return false, { "runtime state not a table" } end
  if type(rs.state) ~= "table" then errs[#errs+1] = "missing state block" end
  return #errs == 0, errs
end

-- Migration hook: nil-safe upgrade of an older stored blob to current version.
-- Extend the branches as versions grow; unknown extension fields are preserved.
function Schema.migrateDefinition(def)
  if type(def) ~= "table" then return Schema.defaultDefinition() end
  local d = Schema.defaultDefinition()
  -- shallow-merge known keys, keep unknown namespaced extensions
  for k, v in pairs(def) do d[k] = v end
  if type(d.stats) ~= "table" then d.stats = Schema.defaultDefinition().stats end
  if type(d.base)  ~= "table" then d.base  = Schema.defaultDefinition().base  end
  d.schema_version = C.UNIT_SCHEMA_VERSION
  return d
end

function Schema.migrateRuntimeState(rs)
  if type(rs) ~= "table" then return Schema.defaultRuntimeState() end
  local base = Schema.defaultRuntimeState()
  base.card_guid              = rs.card_guid
  base.expected_definition_id = rs.expected_definition_id
  if type(rs.state) == "table" then
    for k, v in pairs(rs.state) do base.state[k] = v end
  end
  base.schema_version = C.STATE_SCHEMA_VERSION
  return base
end

CUS.Schema = Schema

-- ===== end core/Schema =====
-- ===== begin core/Logger =====
-- core/Logger.lua
-- Round/action log with player colour, round, source, target, before/after.
-- Also drives the on-screen broadcast + optional chat echo. Kept compact.

CUS = CUS or {}
local Logger = {}

Logger.entries = {}   -- list of { round, color, msg, source, target, before, after, kind }
Logger.MAX     = 400  -- ring cap so a long game never bloats the save

local function push(entry)
  Logger.entries[#Logger.entries + 1] = entry
  if #Logger.entries > Logger.MAX then
    table.remove(Logger.entries, 1)
  end
end

-- roundProvider is injected by RoundManager so Logger stays dependency-free.
Logger.roundProvider = function() return 0 end

function Logger.log(msg, opts)
  opts = opts or {}
  local entry = {
    round  = Logger.roundProvider(),
    color  = opts.color or "GM",
    msg    = tostring(msg),
    source = opts.source,
    target = opts.target,
    before = opts.before,
    after  = opts.after,
    kind   = opts.kind or "info",
  }
  push(entry)
  if opts.broadcast ~= false then
    local prefix = "[CUS] "
    if opts.color and Color and Color.fromString then
      broadcastToAll(prefix .. entry.msg, opts.rgb or { 0.8, 0.9, 1.0 })
    else
      broadcastToAll(prefix .. entry.msg, opts.rgb or { 0.8, 0.9, 1.0 })
    end
  end
  return entry
end

-- Non-destructive warning surface (broken links, malformed cards, etc.).
function Logger.warn(msg, opts)
  opts = opts or {}
  opts.kind = "warn"
  opts.rgb  = { 1.0, 0.75, 0.2 }
  return Logger.log("⚠ " .. tostring(msg), opts)
end

function Logger.error(msg, opts)
  opts = opts or {}
  opts.kind = "error"
  opts.rgb  = { 1.0, 0.4, 0.4 }
  return Logger.log("✖ " .. tostring(msg), opts)
end

-- Serialize / restore for save-load.
function Logger.serialize() return { entries = Logger.entries } end
function Logger.restore(blob)
  if blob and type(blob.entries) == "table" then Logger.entries = blob.entries end
end

-- Render the last N entries as text (for a debug/log panel).
function Logger.tail(n)
  n = n or 20
  local out, start = {}, math.max(1, #Logger.entries - n + 1)
  for i = start, #Logger.entries do
    local e = Logger.entries[i]
    out[#out+1] = string.format("R%s · %s · %s", tostring(e.round), tostring(e.color), e.msg)
  end
  return table.concat(out, "\n")
end

CUS.Logger = Logger

-- ===== end core/Logger =====
-- ===== begin core/EventBus =====
-- core/EventBus.lua
-- Tiny pub/sub so UI panels, resolvers, and object scripts stay decoupled.
-- Handlers are called in registration order; a throwing handler is isolated
-- (logged, never crashes the mod).

CUS = CUS or {}
local Bus = { handlers = {} }

function Bus.on(event, fn)
  Bus.handlers[event] = Bus.handlers[event] or {}
  table.insert(Bus.handlers[event], fn)
  return fn
end

function Bus.off(event, fn)
  local list = Bus.handlers[event]
  if not list then return end
  for i = #list, 1, -1 do
    if list[i] == fn then table.remove(list, i) end
  end
end

function Bus.emit(event, payload)
  local list = Bus.handlers[event]
  if not list then return end
  for _, fn in ipairs(list) do
    local ok, err = pcall(fn, payload)
    if not ok and CUS.Logger then
      CUS.Logger.error("EventBus handler for '" .. tostring(event) .. "' failed: " .. tostring(err),
                       { broadcast = false })
    end
  end
end

CUS.Bus = Bus

-- ===== end core/EventBus =====
-- ===== begin core/Undo =====
-- core/Undo.lua
-- Script-state undo stack. Each entry is a closure that restores prior state,
-- plus a label for the log. Position undo is guaranteed only for explicit
-- movement sessions that recorded an origin/path (see MovementResolver).
--
-- We snapshot the AFFECTED miniature's runtime state (deep copy) rather than
-- the whole world, so undo is cheap and precise.

CUS = CUS or {}
local Undo = { stack = {}, MAX = 60 }

local function deepcopy(v)
  if type(v) ~= "table" then return v end
  local t = {}
  for k, val in pairs(v) do t[k] = deepcopy(val) end
  return t
end
Undo.deepcopy = deepcopy

-- Record a reversible change. `restoreFn` is called on undo.
function Undo.push(label, restoreFn)
  table.insert(Undo.stack, { label = label, restore = restoreFn })
  if #Undo.stack > Undo.MAX then table.remove(Undo.stack, 1) end
end

-- Convenience: snapshot a miniature's runtime state and push a restorer.
function Undo.pushMiniState(mini, label)
  if not mini then return end
  local guid = mini.getGUID()
  local snap = deepcopy(CUS.StateStore and CUS.StateStore.get(guid) or nil)
  Undo.push(label or "state change", function()
    local obj = getObjectFromGUID(guid)
    if obj and CUS.StateStore then
      CUS.StateStore.set(guid, deepcopy(snap))
      if CUS.StatePanel then CUS.StatePanel.refresh(obj) end
    end
  end)
end

function Undo.pop()
  local entry = table.remove(Undo.stack)
  if not entry then
    if CUS.Logger then CUS.Logger.warn("Nothing to undo.") end
    return false
  end
  local ok, err = pcall(entry.restore)
  if not ok then
    if CUS.Logger then CUS.Logger.error("Undo failed: " .. tostring(err)) end
    return false
  end
  if CUS.Logger then CUS.Logger.log("Undid: " .. tostring(entry.label)) end
  return true
end

function Undo.clear() Undo.stack = {} end

CUS.Undo = Undo

-- ===== end core/Undo =====
-- ===== begin core/Geometry =====
-- core/Geometry.lua
-- Measurable spatial facts only. Anything requiring judgment (LoS, cover, high
-- ground, "does this terrain block") is NEVER decided here — the resolvers ask
-- the player to confirm those. This file computes distances, facing arcs, and
-- engagement candidates from positions the engine actually knows.
--
-- TTS world units: 1 unit ≈ 1 inch on the default table. cm helpers convert.

CUS = CUS or {}
local Geo = {}

Geo.IN_PER_UNIT = 1.0
Geo.CM_PER_UNIT = 2.54

local function v(o) return o.getPosition() end

-- Planar (X/Z) distance in world units between two objects, ignoring height.
function Geo.planarDist(a, b)
  local pa, pb = v(a), v(b)
  local dx, dz = pa.x - pb.x, pa.z - pb.z
  return math.sqrt(dx*dx + dz*dz)
end

function Geo.toInches(units) return units * Geo.IN_PER_UNIT end
function Geo.toCm(units)     return units * Geo.CM_PER_UNIT end

-- Approximate base radius in world units from a class label (for edge-to-edge).
-- These mirror the Codex base sizes; used only to estimate "bases touching".
local CLASS_RADIUS_MM = { Small = 12.5, Normal = 16, Cavalry = 20, Large = 20, Monstrous = 25 }
function Geo.baseRadiusUnits(def)
  local class = def and def.base and def.base.class or "Normal"
  local mm = CLASS_RADIUS_MM[class] or 16
  return (mm / 10) / Geo.CM_PER_UNIT   -- mm -> cm -> units
end

-- Edge-to-edge distance in cm between two miniatures (their approx base radii).
function Geo.edgeToEdgeCm(a, defA, b, defB)
  local centerUnits = Geo.planarDist(a, b)
  local edgeUnits = centerUnits - Geo.baseRadiusUnits(defA) - Geo.baseRadiusUnits(defB)
  if edgeUnits < 0 then edgeUnits = 0 end
  return Geo.toCm(edgeUnits)
end

-- Are two bases effectively touching? (edge gap ≤ ~0.5 cm tolerance)
function Geo.basesTouching(a, defA, b, defB)
  return Geo.edgeToEdgeCm(a, defA, b, defB) <= 0.6
end

-- Facing arc of `target` relative to `attacker`, using target's forward axis.
-- Returns "Front" | "Flank" | "Rear". Facing is a measurable fact; whether it is
-- "frozen this turn" is enforced by the round/turn logic, not here.
function Geo.facingArc(attacker, target, forwardAxisName)
  local fwd
  if forwardAxisName == "local_x" then
    fwd = target.getTransformRight()
  elseif forwardAxisName == "local_-z" then
    local f = target.getTransformForward(); fwd = { x = -f.x, y = -f.y, z = -f.z }
  else -- default local_z
    fwd = target.getTransformForward()
  end
  local tp, ap = target.getPosition(), attacker.getPosition()
  local dir = { x = ap.x - tp.x, z = ap.z - tp.z }
  local len = math.sqrt(dir.x*dir.x + dir.z*dir.z)
  if len < 1e-4 then return "Front" end
  dir.x, dir.z = dir.x/len, dir.z/len
  -- normalize forward to planar
  local flen = math.sqrt(fwd.x*fwd.x + fwd.z*fwd.z)
  local fx, fz = fwd.x/flen, fwd.z/flen
  local dot = fx*dir.x + fz*dir.z            -- 1 = directly in front
  if dot >= 0.5 then return "Front"          -- within ~60° front arc
  elseif dot <= -0.5 then return "Rear"      -- within ~60° rear arc
  else return "Flank" end
end

-- Candidate engagers: enemy miniatures in CONTACT with `mini`.
--
-- v0.6 (B.8, SIGNED): engagement is bases TOUCHING. There is no measured band —
-- if the bases touch, the figures are engaged, full stop. The tolerance below
-- exists only to absorb physics jitter in TTS; it is not a rules band, and it
-- replaces the old v0.5 `engagement_cm` stickiness band.
--
-- `others` is a list of { obj, def, side }; caller supplies sides & defs.
function Geo.engagersWithin(mini, def, others, cm)
  cm = cm or CUS.Constants.TUNING.contact_tolerance_cm
  local hits = {}
  for _, o in ipairs(others) do
    if o.obj ~= mini then
      local d = Geo.edgeToEdgeCm(mini, def, o.obj, o.def)
      if d <= cm then hits[#hits+1] = { obj = o.obj, def = o.def, side = o.side, cm = d } end
    end
  end
  return hits
end

-- Turn and face. Engaging or Countering turns a SQUARE to face its foe (B.8).
-- A Circle is faceless and is never rotated by this. Returns true if it turned.
function Geo.faceToward(guid, targetGuid)
  local me  = getObjectFromGUID(guid)
  local you = getObjectFromGUID(targetGuid)
  if not me or not you then return false end

  local def = CUS.StateStore and CUS.StateStore.getDefinition(guid)
  local shape = def and def.base and def.base.shape
  if shape == "Circle" then return false end          -- faceless: nothing to turn

  local st = CUS.StateStore and CUS.StateStore.get(guid)
  if st and st.state and st.state.facing_locked then
    -- a Braced figure cannot turn; that is the price of the stance (B.9b)
    if CUS.Logger then CUS.Logger.log("Facing is locked (Braced) — it does not turn.") end
    return false
  end

  local mp, yp = me.getPosition(), you.getPosition()
  local dx, dz = yp.x - mp.x, yp.z - mp.z
  if (dx * dx + dz * dz) < 1e-6 then return false end

  local yaw = math.deg(math.atan2(dx, dz))            -- TTS: +z is forward
  local rot = me.getRotation()
  me.setRotationSmooth({ rot.x, yaw, rot.z }, false, false)
  return true
end

CUS.Geo = Geo
-- Some modules reach for the longer name; keep one table, two handles.
CUS.Geometry = Geo

-- ===== end core/Geometry =====
-- ===== begin core/UIList =====
-- core/UIList.lua
-- Dynamic list rendering for TTS panels, done the way TTS actually supports.
--
-- WHY THIS EXISTS. The mod used to build lists with:
--     UI.setXmlTable(rows, "some_element_id")
-- That call does NOT scope the rows to an element. TTS's signature is
--     UI.setXmlTable(xmlTable, assetTable)
-- so the second argument was being taken as the custom ASSET TABLE, and the
-- rows replaced the ENTIRE global UI. Symptom: opening the Unit Library (or the
-- radial wheel) blanked every panel and left one button stretched across the
-- whole screen. It was doing exactly what it was told.
--
-- TTS has no supported "replace the children of element X" call. The standard
-- pattern is to PRE-DECLARE a fixed number of slots in the XML, inactive by
-- default, and then drive them with UI.setAttribute — which touches only the
-- element named and never disturbs the rest of the UI.
--
-- Usage:
--   CUS.UIList.fill("lib_r", 20, {
--     { text = "Militia", onClick = "libFaction(Militia)" },
--     { text = "Goblins", onClick = "libFaction(Goblins)", color = "#3a4a72" },
--   })
--
-- Any slot beyond the supplied rows is hidden. If there are more rows than
-- slots, the overflow is reported rather than silently dropped.

CUS = CUS or {}
local L = {}

L.DEFAULT_COLOR      = "#2a3550"
L.DEFAULT_TEXT_COLOR = "#dce6ff"

-- Fill `count` slots named prefix1..prefixN from `rows`.
-- A row is { text, onClick?, tooltip?, color?, textColor?, fontSize?, kind? }
-- kind = "header" renders as a dimmed, non-clickable label.
function L.fill(prefix, count, rows)
  rows = rows or {}
  for i = 1, count do
    local id  = prefix .. i
    local row = rows[i]
    if row then
      local header = (row.kind == "header")
      UI.setAttribute(id, "active",    "true")
      UI.setAttribute(id, "text",      tostring(row.text or ""))
      UI.setAttribute(id, "onClick",   header and "" or tostring(row.onClick or ""))
      UI.setAttribute(id, "tooltip",   tostring(row.tooltip or ""))
      UI.setAttribute(id, "color",     header and "#00000000" or (row.color or L.DEFAULT_COLOR))
      UI.setAttribute(id, "textColor", row.textColor or (header and "#8899bb" or L.DEFAULT_TEXT_COLOR))
      UI.setAttribute(id, "fontSize",  tostring(row.fontSize or (header and 12 or 14)))
      UI.setAttribute(id, "interactable", header and "false" or "true")
    else
      UI.setAttribute(id, "active", "false")
    end
  end

  if #rows > count and CUS.Logger then
    CUS.Logger.warn(("%s: %d rows but only %d slots — %d not shown."):format(
      prefix, #rows, count, #rows - count), { broadcast = false })
  end
end

-- Convenience: hide every slot in a list.
function L.clear(prefix, count)
  for i = 1, count do UI.setAttribute(prefix .. i, "active", "false") end
end

-- Slot counts, declared once here so the Lua and the XML cannot drift.
L.SLOTS = {
  lib      = 20,   -- lib_r1..20     Unit Library rows (factions, then units)
  wheelsub = 20,   -- whsub1..20     radial wheel submenu
  cond     = 12,   -- cond_r1..12    conditions list
  ledger   = 14,   -- ledg_r1..14    attack modifier ledger
}

CUS.UIList = L

-- ===== end core/UIList =====
-- ===== begin core/StateStore =====
-- core/StateStore.lua
-- The single owner of miniature RUNTIME state, keyed by miniature GUID.
--
-- Design: TTS object scripts survive save/load via onSave/onLoad, but keeping a
-- mirror in Global makes cross-object logic (resolvers, panels) simple and makes
-- one place responsible for serialization. Each miniature's authoritative copy
-- still lives on the miniature (MiniatureController) and is synced here on load.
--
-- CARD access lives here too: given a miniature, resolve its linked card and
-- pull the DEFINITION by calling the card's own getDefinition(). We never cache
-- a second permanent stat block on the miniature.

CUS = CUS or {}
local Schema = CUS.Schema
local StateStore = { runtime = {} }   -- guid -> runtimeState

-- ---------------------------------------------------------------------------
-- runtime state registry
-- ---------------------------------------------------------------------------
function StateStore.get(guid)
  return StateStore.runtime[guid]
end

function StateStore.getOrInit(guid)
  if not StateStore.runtime[guid] then
    StateStore.runtime[guid] = Schema.defaultRuntimeState()
  end
  return StateStore.runtime[guid]
end

function StateStore.set(guid, rs)
  StateStore.runtime[guid] = rs
end

function StateStore.remove(guid)
  StateStore.runtime[guid] = nil
end

-- ---------------------------------------------------------------------------
-- card / definition resolution  (the definition→instance bridge)
-- ---------------------------------------------------------------------------

-- Resolve the physical card object linked to a miniature. Returns (cardObj|nil, reason).
function StateStore.resolveCard(miniGuid)
  local rs = StateStore.get(miniGuid)
  if not rs or not rs.card_guid then return nil, "no card linked" end
  local card = getObjectFromGUID(rs.card_guid)
  if not card then return nil, "linked card GUID missing (deleted or in a deck)" end
  return card, nil
end

-- Pull the DEFINITION for a miniature. Validates definition_id against the
-- expected id and never substitutes guessed values on failure.
-- Returns (definition|nil, reason).
function StateStore.getDefinition(miniGuid)
  local card, reason = StateStore.resolveCard(miniGuid)
  if not card then return nil, reason end

  -- The card exposes getDefinition() as a callable object method.
  local ok, def = pcall(function() return card.call("getDefinition") end)
  if not ok or type(def) ~= "table" then
    return nil, "linked card returned no valid definition (malformed or stacked in a deck)"
  end

  local valid, errs = Schema.validateDefinition(def)
  if not valid then
    return nil, "card definition invalid: " .. table.concat(errs, "; ")
  end

  local rs = StateStore.get(miniGuid)
  if rs and rs.expected_definition_id and def.definition_id ~= rs.expected_definition_id then
    -- Identity mismatch is a warning, not a silent swap.
    if CUS.Logger then
      CUS.Logger.warn(("Definition id mismatch on %s: expected %s, card is %s"):format(
        miniGuid, tostring(rs.expected_definition_id), tostring(def.definition_id)))
    end
  end
  return def, nil
end

-- ---------------------------------------------------------------------------
-- serialization (Global-side mirror; object scripts also self-persist)
-- ---------------------------------------------------------------------------
function StateStore.serialize()
  return { runtime = StateStore.runtime }
end

function StateStore.restore(blob)
  StateStore.runtime = {}
  if blob and type(blob.runtime) == "table" then
    for guid, rs in pairs(blob.runtime) do
      StateStore.runtime[guid] = Schema.migrateRuntimeState(rs)
    end
  end
end

-- Duplicate-GUID / broken-link audit used by RoundManager & save/load.
function StateStore.audit()
  local problems = {}
  for guid, rs in pairs(StateStore.runtime) do
    local mini = getObjectFromGUID(guid)
    if not mini then
      problems[#problems+1] = "orphan runtime state for missing miniature " .. guid
    elseif rs.card_guid and not getObjectFromGUID(rs.card_guid) then
      problems[#problems+1] = ("miniature %s links missing card %s"):format(guid, rs.card_guid)
    end
  end
  return problems
end

CUS.StateStore = StateStore

-- ===== end core/StateStore =====
-- ===== begin modules/PacketRegistry =====
-- modules/PacketRegistry.lua
-- The Global packet registry. Cards store packet IDs; they never copy packet
-- bodies. Change a packet here and every card that references it updates.
-- Packets are STATELESS (Law 5): they never hold a figure's wounds/AP.

CUS = CUS or {}
local Schema = CUS.Schema
local Registry = { attacks = {}, abilities = {} }

-- Load from a decoded JSON blob: { attack_packets = {...}, ability_packets = {...} }
function Registry.load(blob)
  Registry.attacks, Registry.abilities = {}, {}
  if type(blob) ~= "table" then return end

  for _, p in ipairs(blob.attack_packets or {}) do
    local ok, errs = Schema.validateAttackPacket(p)
    if ok then
      Registry.attacks[p.id] = p
    elseif CUS.Logger then
      CUS.Logger.warn("skipped attack packet " .. tostring(p and p.id) .. ": " .. table.concat(errs, "; "),
                      { broadcast = false })
    end
  end

  for _, p in ipairs(blob.ability_packets or {}) do
    local ok, errs = Schema.validateAbilityPacket(p)
    if ok then
      Registry.abilities[p.id] = p
    elseif CUS.Logger then
      CUS.Logger.warn("skipped ability packet " .. tostring(p and p.id) .. ": " .. table.concat(errs, "; "),
                      { broadcast = false })
    end
  end

  if CUS.Logger then
    CUS.Logger.log(("Packet registry loaded: %d attacks, %d abilities.")
      :format(Registry.count(Registry.attacks), Registry.count(Registry.abilities)),
      { broadcast = false })
  end
end

function Registry.count(t)
  local n = 0
  for _ in pairs(t) do n = n + 1 end
  return n
end

function Registry.attack(id)  return Registry.attacks[id]  end
function Registry.ability(id) return Registry.abilities[id] end

-- Resolve a definition's attack packets to full bodies (skips unknown IDs, warns).
function Registry.resolveAttacks(def)
  local out = {}
  for _, id in ipairs(def.attack_packet_ids or {}) do
    local p = Registry.attacks[id]
    if p then out[#out+1] = p
    elseif CUS.Logger then CUS.Logger.warn("unknown attack packet id: " .. tostring(id), { broadcast = false }) end
  end
  return out
end

-- Resolve ability packets, optionally filtered by kind and/or parent action.
function Registry.resolveAbilities(def, kind, parentAction)
  local out = {}
  for _, id in ipairs(def.ability_packet_ids or {}) do
    local p = Registry.abilities[id]
    if p then
      local kindOk   = (kind == nil) or (p.type == kind)
      local parentOk = (parentAction == nil) or (p.parent_action == parentAction)
      if kindOk and parentOk then out[#out+1] = p end
    elseif CUS.Logger then
      CUS.Logger.warn("unknown ability packet id: " .. tostring(id), { broadcast = false })
    end
  end
  return out
end

function Registry.serialize()
  return { attacks = Registry.attacks, abilities = Registry.abilities }
end

function Registry.restore(blob)
  if type(blob) ~= "table" then return end
  Registry.attacks   = blob.attacks   or {}
  Registry.abilities = blob.abilities or {}
end

CUS.PacketRegistry = Registry

-- ===== end modules/PacketRegistry =====
-- ===== begin modules/ArmourResolver =====
-- modules/ArmourResolver.lua
-- The armour sheet: one save die per Wound.
--   None = —   Light = 6+   Medium = 5+   Heavy = 4+
-- "Step worse" raises the threshold by 1 (Mob Rule, some effects). A step worse
-- than 6+ becomes unsaveable. ignore_armour zeroes the save entirely.

CUS = CUS or {}
local C = CUS.Constants
local Schema = CUS.Schema
local Armour = {}

-- Return the effective save threshold (number) or nil (no possible save),
-- given a definition and a list of step deltas / flags.
--   opts = { steps = 0, ignore = false }
function Armour.effectiveSave(def, opts)
  opts = opts or {}
  if opts.ignore then return nil, "ignored" end
  local class = Schema.armourClass(def)
  local base  = C.ARMOUR[class].save          -- nil for None
  if base == nil then return nil, "None" end
  local thr = base + (opts.steps or 0)
  if thr > 6 then return nil, "worsened past 6+" end  -- can no longer save
  return thr, class
end

-- Roll `wounds` save dice against threshold. Returns a table describing each
-- die and the number of UNSAVED wounds. Uses TTS math.random (seeded by engine).
function Armour.rollSaves(wounds, threshold, roller)
  roller = roller or function() return math.random(1, 6) end
  local rolls, saved = {}, 0
  for i = 1, wounds do
    local d = roller()
    local ok = (threshold ~= nil) and (d >= threshold)
    rolls[i] = { die = d, saved = ok }
    if ok then saved = saved + 1 end
  end
  return { rolls = rolls, saved = saved, unsaved = wounds - saved, threshold = threshold }
end

CUS.ArmourResolver = Armour

-- ===== end modules/ArmourResolver =====
-- ===== begin modules/AttackResolver =====
-- modules/AttackResolver.lua
-- The SIGNED Combat Module attack procedure (Codex VII.a).
--
--   1. Roll Attack Dice (± Environmental Dice)
--   2. Count SUCCESSES — each die >= Hit
--   3. Read the packet's Tiers to that success count:
--        best WOUND result reached (highest-wins, they do NOT sum)
--        + EVERY Effect passed (accumulate)
--   4. ARMOUR rolls one die PER WOUND
--   5. Apply Wounds -> Counter -> Nerve
--
-- The resolver builds a mutable SESSION. Measurable facts auto-populate the
-- modifier ledger with a labelled source. Judgments (LoS/cover/high ground)
-- are added ONLY when the player confirms them. Nothing mutates the defender
-- until apply() is called.

CUS = CUS or {}
local C       = CUS.Constants
local Store   = CUS.StateStore
local Reg     = CUS.PacketRegistry
local Geo     = CUS.Geo
local Armour  = CUS.ArmourResolver
local Schema  = CUS.Schema
local Bus     = CUS.Bus

local Attack = {}
Attack.session = nil   -- one active resolution at a time (player-local flow)

-- ---------- modifier helpers ------------------------------------------------
local function addMod(s, mod) s.modifiers[#s.modifiers+1] = mod end

local function stepHit(threshold, steps)
  -- worse = higher number, better = lower. Clamp to a rollable 2..6 window
  -- (a "6+ one worse" is handled by making it effectively unreachable at 7).
  local t = threshold + steps
  if t < 2 then t = 2 end
  if t > 7 then t = 7 end
  return t
end

-- ---------- build a session -------------------------------------------------
-- opts = { attackerGuid, defenderGuid, packetId, mode="Regular", is_counter=false }
function Attack.begin(opts)
  local atkDef, aReason = Store.getDefinition(opts.attackerGuid)
  local defDef, dReason = Store.getDefinition(opts.defenderGuid)
  if not atkDef then return nil, "attacker: " .. tostring(aReason) end
  if not defDef then return nil, "defender: " .. tostring(dReason) end

  local packet = Reg.attack(opts.packetId)
  if not packet then return nil, "unknown attack packet: " .. tostring(opts.packetId) end

  local aObj = getObjectFromGUID(opts.attackerGuid)
  local dObj = getObjectFromGUID(opts.defenderGuid)
  local aState = Store.getOrInit(opts.attackerGuid).state
  local dState = Store.getOrInit(opts.defenderGuid).state

  local s = {
    attackerGuid = opts.attackerGuid, defenderGuid = opts.defenderGuid,
    atkDef = atkDef, defDef = defDef,
    packet = packet, mode = opts.mode or "Regular",
    is_counter = opts.is_counter or false,
    base_dice = packet.dice, base_hit = packet.hit,
    env_dice = 0,
    modifiers = {},              -- ledger, each { source, dice?, hitStep?, armourStep?, ignoreArmour?, suppressCounter?, effects?, note }
    judgments = {},              -- player-confirmed toggles, e.g. { cover = true }
    reach = false,               -- Reach tag & not touching (suppresses Counter, no lock)
    touching = false,
    result = nil,
  }

  -- ---- measurable auto-detection -----------------------------------------
  if aObj and dObj then
    local touching = Geo.basesTouching(aObj, atkDef, dObj, defDef)
    s.touching = touching
    local hasReach = false
    for _, t in ipairs(packet.tags or {}) do if t == "Reach" then hasReach = true end end
    s.reach = hasReach and not touching

    -- Facing (frozen on enemy turn is enforced by round logic; arc is a fact).
    local axis = dState.forward_axis or C.TUNING.facing_axis
    local arc = Geo.facingArc(aObj, dObj, axis)
    s.facing = arc
    if arc == "Flank" then
      addMod(s, { source = "Flank", dice = C.TUNING.flank_die, note = "+1 die" })
    elseif arc == "Rear" and not s.is_counter then
      addMod(s, { source = "Rear / Backstab", dice = C.TUNING.backstab_die, suppressCounter = true,
                  note = "+2 dice, no Counter" })
    end

    -- Distance (informational; range legality flagged for ranged packets).
    s.distance_in = Geo.toInches(Geo.planarDist(aObj, dObj))
  end

  -- attacker moved this activation (a fact; some packets/modes care).
  s.attacker_moved = aState.moved_this_activation == true

  -- ---- ranged mode modifiers ---------------------------------------------
  local isRanged = (packet.range and packet.range > 0)
  if isRanged then
    if s.mode == "Precision" then
      addMod(s, { source = "Precision Shot", dice = C.TUNING.precision_die, ignoreCover = true,
                  note = "+1 die, ignores Cover, ends turn (requires not moved)" })
    elseif s.mode == "Multi" then
      addMod(s, { source = "Multi-Shot", hitStep = C.TUNING.multishot_hit_step,
                  note = "Hit one step worse (per shot)" })
    end
  end

  -- ---- Mob Rule (Circle defender engaged by 2+): armour one step worse ----
  -- Engagement is descriptive; we only PROPOSE it and let the player confirm.
  if defDef.base and defDef.base.shape == "Circle" then
    s.mob_candidate = true
  end

  -- ---- conditions represented as structured modifiers --------------------
  for _, cond in ipairs(dState.conditions or {}) do
    if type(cond) == "table" and cond.modifiers then
      addMod(s, { source = "Condition: " .. tostring(cond.id), armourStep = cond.modifiers.armourStep,
                  dice = cond.modifiers.defenderDice, note = cond.note or "" })
    end
  end

  Attack.session = s
  Bus.emit("attack:begin", s)
  return s
end

-- Player toggles a judgment (cover, high ground, LoS-clear, etc.).
function Attack.setJudgment(key, value) if Attack.session then Attack.session.judgments[key] = value end end
function Attack.confirmMob(on)
  local s = Attack.session; if not s then return end
  s.mob_confirmed = on and true or false
end

-- ---------- compute final numbers (pure) ------------------------------------
function Attack.compute(s)
  s = s or Attack.session
  local dice = s.base_dice + (s.env_dice or 0)
  local hitStep, armourStep = 0, 0
  local ignoreArmour, suppressCounter = false, false
  local effectsForced = {}

  for _, m in ipairs(s.modifiers) do
    dice       = dice + (m.dice or 0)
    hitStep    = hitStep + (m.hitStep or 0)
    armourStep = armourStep + (m.armourStep or 0)
    if m.ignoreArmour then ignoreArmour = true end
    if m.suppressCounter then suppressCounter = true end
    for _, e in ipairs(m.effects or {}) do effectsForced[#effectsForced+1] = e end
  end

  if s.mob_confirmed then armourStep = armourStep + 1 end
  if dice < 0 then dice = 0 end

  return {
    dice = dice,
    hit = stepHit(s.base_hit, hitStep),
    armourStep = armourStep,
    ignoreArmour = ignoreArmour,
    suppressCounter = suppressCounter,
    effectsForced = effectsForced,
  }
end

-- ---------- read the Tiers --------------------------------------------------
-- best wound (highest-wins, no sum) + every effect passed.
local function readTiers(packet, successes)
  local bestWound, effects = 0, {}
  local reached = {}
  for _, t in ipairs(packet.tiers) do
    if successes >= t.successes then
      reached[#reached+1] = t
      if (t.wounds or 0) > bestWound then bestWound = t.wounds or 0 end
      for _, e in ipairs(t.effects or {}) do effects[#effects+1] = e end
    end
  end
  return bestWound, effects, reached
end

-- ---------- resolve (roll, or accept manual inputs) -------------------------
-- manual = { dice = {...} } OR { successes = N }.  Returns the result table.
function Attack.resolve(manual)
  local s = Attack.session
  if not s then return nil, "no active attack" end
  local comp = Attack.compute(s)

  -- 1–2: roll & count successes (or accept manual entry)
  local rolls, successes = {}, 0
  if manual and manual.successes ~= nil then
    successes = manual.successes
  elseif manual and manual.dice then
    for i, d in ipairs(manual.dice) do
      rolls[i] = { die = d, success = d >= comp.hit }
      if d >= comp.hit then successes = successes + 1 end
    end
  else
    for i = 1, comp.dice do
      local d = math.random(1, 6)
      rolls[i] = { die = d, success = d >= comp.hit }
      if d >= comp.hit then successes = successes + 1 end
    end
  end

  -- 3: Tiers
  local wounds, effects, reached = readTiers(s.packet, successes)
  for _, e in ipairs(comp.effectsForced) do effects[#effects+1] = e end

  -- 4: Armour, one die per wound
  local saveThr, saveWhy = Armour.effectiveSave(s.defDef, { steps = comp.armourStep, ignore = comp.ignoreArmour })
  local armour = Armour.rollSaves(wounds, saveThr)

  -- 5: pending state (NOT applied yet)
  local defState = Store.getOrInit(s.defenderGuid).state
  local result = {
    comp = comp,
    rolls = rolls, successes = successes,
    reachedTiers = reached, wounds = wounds, effects = effects,
    armour = armour, saveThreshold = saveThr, saveWhy = saveWhy,
    unsaved = armour.unsaved,
    pending = {
      wounds_before = defState.current_wounds,
      wounds_after  = math.max(0, defState.current_wounds - armour.unsaved),
    },
    -- Counter legality (evaluated at apply time too, but previewed here):
    counter_possible = s.touching and (not comp.suppressCounter) and (not s.reach) and (not s.is_counter),
  }
  s.result = result
  Bus.emit("attack:resolved", s)
  return result
end

-- ---------- apply (the only place the defender mutates) ---------------------
function Attack.apply()
  local s = Attack.session
  if not s or not s.result then return nil, "nothing to apply" end
  local mini = getObjectFromGUID(s.defenderGuid)
  if CUS.Undo then CUS.Undo.pushMiniState(mini, "attack on " .. tostring(s.defDef.name)) end

  local defRt = Store.getOrInit(s.defenderGuid)
  local before = defRt.state.current_wounds
  defRt.state.current_wounds = s.result.pending.wounds_after

  -- forced/accumulated effects become conditions where structured (Guard/Push/
  -- Knockdown/etc. are surfaced; the player applies displacement honestly).
  if CUS.ConditionManager then
    for _, e in ipairs(s.result.effects) do
      CUS.ConditionManager.noteEffect(s.defenderGuid, e)
    end
  end

  -- attacker spends the ATTACK (one per activation) unless this is a Counter.
  if not s.is_counter then
    local atkRt = Store.getOrInit(s.attackerGuid)
    atkRt.state.attacked_this_activation = true
  end

  CUS.pushRuntimeToMini(s.defenderGuid)
  CUS.pushRuntimeToMini(s.attackerGuid)

  if CUS.Logger then
    CUS.Logger.log(("%s → %s: %d success, %dW, %d unsaved (%d→%d)%s"):format(
      s.atkDef.name, s.defDef.name, s.result.successes, s.result.wounds,
      s.result.unsaved, before, defRt.state.current_wounds,
      (#s.result.effects > 0 and (" · " .. table.concat(s.result.effects, ", ")) or "")),
      { source = s.attackerGuid, target = s.defenderGuid, before = before, after = defRt.state.current_wounds })
  end

  Bus.emit("attack:applied", s)
  local counterPossible = s.result.counter_possible
  return { applied = true, counter_possible = counterPossible }
end

function Attack.cancel()
  Attack.session = nil
  Bus.emit("attack:cancel", nil)
end

CUS.AttackResolver = Attack

-- ===== end modules/AttackResolver =====
-- ===== begin modules/CounterResolver =====
-- modules/CounterResolver.lua
-- Counter — turn and face (B.9, SIGNED, William 2026-07-24).
--
-- Attack a figure and it Counters: one melee PACKET back, AND it turns to face
-- you — you are now engaged. Structurally a Counter is a PACKET armed against
-- the trigger "struck by an enemy", so it lives in the WAIT family even though
-- it fires automatically.
--
-- v0.6 MIGRATION — three things changed, and they matter:
--
--   1. THERE IS NO CAP. v0.5 gave one Counter per round with a `Counter X`
--      economy for duelists. That is gone. A figure Counters EVERY enemy that
--      attacks it, and Counters EVEN AS IT DIES. Worked example: you attack a
--      figure, engage, it Counters and kills you, your body is shoved off —
--      that same figure is now free and will Counter the next attacker.
--
--   2. A FREE TARGET ALWAYS SWINGS. You cannot walk up and safely stab an
--      unengaged figure. It turns, hits back, and is pulled into engagement.
--      The first attacker on an open figure eats the Counter.
--
--   3. ANGLE ONLY DENIES A BUSY SQUARE. v0.5 denied a Counter on any
--      rear/backstab. v0.6 denies it only when the defender is a SQUARE that is
--      ALREADY ENGAGED WITH ANOTHER ENEMY and is struck in an arc it is not
--      facing. A Circle is FACELESS and therefore always Counters, from any
--      angle — heroes are cracked by numbers, not by angles.
--
-- The only other denial is a Reach strike made WITHOUT base contact: the reach
-- striker is not glued to its target, so it is not engaged and draws nothing.
--
-- A Counter does not itself draw a Counter — it is a response, not an ATTACK —
-- so two figures never loop forever. That is enforced by is_counter = true.

CUS = CUS or {}
local C      = CUS.Constants
local Store  = CUS.StateStore
local Reg    = CUS.PacketRegistry
local Attack = CUS.AttackResolver
local Counter = {}

-- Is a Counter legal for `defenderGuid` against `attackerGuid` right now?
--
-- ctx fields:
--   touching        bases are in contact
--   reach           the attacker struck from a Reach band without contact
--   angle           "front" | "flank" | "rear"   (relative to the defender)
--   engagedElsewhere the defender is already engaged with a DIFFERENT enemy
--   suppressCounter a packet effect explicitly suppresses it
--   isCounter       this strike is itself a Counter
function Counter.isLegal(defenderGuid, attackerGuid, ctx)
  ctx = ctx or {}
  local rt = Store.get(defenderGuid)
  if not rt then return false, "no state" end

  -- A Counter is a response, not an ATTACK: it draws no Counter of its own.
  if ctx.isCounter then return false, "a Counter draws no Counter" end
  if ctx.suppressCounter then return false, "suppressed by a packet effect" end

  -- A dead defender still swings — the dying swing lands. So being at zero
  -- wounds is deliberately NOT checked here.

  -- Reach without contact: the striker is not glued, so no engagement, no Counter.
  if ctx.reach and not ctx.touching then
    return false, "struck from Reach without contact — not engaged"
  end

  if not ctx.touching then return false, "bases not touching" end

  local def = Store.getDefinition(defenderGuid)
  local shape = def and def.base and def.base.shape

  -- Circles are faceless. Angle never matters to or from a Circle.
  if shape == "Circle" then
    return true, "Circle is faceless — it always Counters"
  end

  -- A Square that is NOT already engaged elsewhere is a free target: it turns
  -- to face its attacker and swings. This is the common case.
  if not ctx.engagedElsewhere then
    return true, "free target — it turns to face and Counters"
  end

  -- A Square already facing another foe concedes the arc it cannot see.
  local angle = ctx.angle or "front"
  if angle == "flank" or angle == "rear" then
    return false, ("already engaged elsewhere and struck in its %s — no Counter"):format(angle)
  end

  return true, "engaged and struck in its front — it Counters"
end

-- Resolve a Counter: the defender becomes the attacker for one melee packet.
-- counterPacketId defaults to the defender's first melee attack packet.
function Counter.resolve(defenderGuid, attackerGuid, counterPacketId)
  local defDef = Store.getDefinition(defenderGuid)
  if not defDef then return nil, "defender definition unavailable" end

  if not counterPacketId then
    for _, id in ipairs(defDef.attack_packet_ids or {}) do
      local p = Reg.attack(id)
      if p and (not p.range or p.range == 0) then counterPacketId = id; break end
    end
  end
  if not counterPacketId then return nil, "defender has no melee packet to Counter with" end

  -- No cap to spend (B.9). The old counter_uses_remaining bookkeeping is gone;
  -- the only limit on a figure's Counters is that it eventually dies.

  -- Turn and face: engaging turns Squares to face each other. Circles are
  -- faceless and are left alone.
  local shape = defDef.base and defDef.base.shape
  if shape ~= "Circle" and CUS.Geometry and CUS.Geometry.faceToward then
    CUS.Geometry.faceToward(defenderGuid, attackerGuid)
  end

  -- swap roles, is_counter = true so it never recurses
  local s, reason = Attack.begin({
    attackerGuid = defenderGuid,
    defenderGuid = attackerGuid,
    packetId     = counterPacketId,
    is_counter   = true,
  })
  if not s then return nil, reason end

  if CUS.Logger then
    local st = Store.get(defenderGuid)
    local dying = st and st.state and st.state.wounds_state == "Dead"
    CUS.Logger.log(("Counter! %s turns and swings back%s."):format(
      defDef.name, dying and " — the dying swing lands" or ""))
  end
  return s
end

CUS.CounterResolver = Counter

-- ===== end modules/CounterResolver =====
-- ===== begin modules/MovementResolver =====
-- modules/MovementResolver.lua
-- Continuous MOVE with a recorded session. We track the horizontal X/Z path
-- while the model is picked up and moved, ignore hand jitter, support multiple
-- pickups in one session, draw the travelled path, and show distance used /
-- remaining. State only mutates on Commit; Undo restores the recorded origin.
--
-- ATTACK does not end the activation — a figure may MOVE before and after it.
-- READY ends the turn (enforced in the round/wheel logic, not here).

CUS = CUS or {}
local C     = CUS.Constants
local Store = CUS.StateStore
local Geo   = CUS.Geo
local Bus   = CUS.Bus
local Move  = {}

local function session(guid) return Store.getOrInit(guid).state.movement_session end

-- Begin a movement session. Reads Speed & AP from the linked card.
function Move.begin(guid)
  local def, reason = Store.getDefinition(guid)
  if not def then return nil, reason end
  local mini = getObjectFromGUID(guid)
  if not mini then return nil, "miniature object missing" end

  local st = Store.getOrInit(guid).state
  if (st.current_ap or 0) < 1 then
    if CUS.Logger then CUS.Logger.warn(def.name .. " has no AP to MOVE.") end
    return nil, "no AP"
  end

  local pos = mini.getPosition()
  st.movement_session = {
    origin  = { x = pos.x, y = pos.y, z = pos.z },
    rot     = mini.getRotation(),
    path    = { { x = pos.x, z = pos.z } },
    used    = 0,
    active  = true,
    holding = false,
    speed   = def.stats.speed or 6,
  }
  CUS.pushRuntimeToMini(guid)
  if CUS.Logger then CUS.Logger.log(("MOVE begun: %s (Speed %d\")"):format(def.name, st.movement_session.speed), { broadcast = false }) end
  Bus.emit("move:begin", { guid = guid })
  return st.movement_session
end

-- Sample the model's current position (called each frame while a session is
-- active). Adds a waypoint only after meaningful movement (jitter filtered).
function Move.sample(guid)
  local s = session(guid)
  if not s or not s.active then return end
  local mini = getObjectFromGUID(guid)
  if not mini then return end
  local pos = mini.getPosition()
  local last = s.path[#s.path]
  local dx, dz = pos.x - last.x, pos.z - last.z
  local step = math.sqrt(dx*dx + dz*dz)
  if step >= C.TUNING.jitter_threshold then
    s.path[#s.path+1] = { x = pos.x, z = pos.z }
    s.used = s.used + step
    Move.draw(guid)
    Bus.emit("move:update", { guid = guid, used = s.used, remaining = Move.remaining(guid) })
  end
end

function Move.remaining(guid)
  local s = session(guid); if not s then return 0 end
  return math.max(0, s.speed - Geo.toInches(s.used))
end

function Move.usedInches(guid)
  local s = session(guid); if not s then return 0 end
  return Geo.toInches(s.used)
end

-- Draw the travelled path as a vector line on the miniature.
function Move.draw(guid)
  local s = session(guid); if not s then return end
  local mini = getObjectFromGUID(guid); if not mini then return end
  local y = mini.getPosition().y + 0.2
  local pts = {}
  for _, p in ipairs(s.path) do pts[#pts+1] = { p.x, y, p.z } end
  Global.setVectorLines((function()
    -- preserve other lines? For the testbed we own the layer; keep it simple.
    return { { points = pts, color = { 0.3, 0.8, 1.0 }, thickness = 0.08 } }
  end)())
end

-- Add an explicit obstacle / story cost inline (paid as part of the MOVE).
-- stories>0 climbs (+1 AP each); the caller confirms drops/damage separately.
function Move.addStoryCost(guid, stories)
  local s = session(guid); if not s then return end
  s.story_ap = (s.story_ap or 0) + math.max(0, stories or 0)
  if CUS.Logger then CUS.Logger.log(("+%d AP story/obstacle cost queued."):format(stories), { broadcast = false }) end
end

-- Commit: spend AP (1 for the MOVE + any story climbs), set moved flag,
-- keep the model where it is, and clear the session.
function Move.commit(guid)
  local s = session(guid)
  if not s then return nil, "no movement session" end
  local st = Store.getOrInit(guid).state
  local cost = 1 + (s.story_ap or 0)
  if (st.current_ap or 0) < cost then
    if CUS.Logger then CUS.Logger.warn(("Not enough AP to commit MOVE (need %d)."):format(cost)) end
    return nil, "insufficient AP"
  end

  local mini = getObjectFromGUID(guid)
  if CUS.Undo and mini then
    local origin = { x = s.origin.x, y = s.origin.y, z = s.origin.z }
    local rot    = s.rot
    local snapAp = st.current_ap
    CUS.Undo.push("MOVE commit", function()
      local o = getObjectFromGUID(guid)
      if o then o.setPositionSmooth(origin, false, false); o.setRotationSmooth(rot, false, false) end
      local rr = Store.getOrInit(guid).state
      rr.current_ap = snapAp
      rr.moved_this_activation = false
      CUS.pushRuntimeToMini(guid)
    end)
  end

  st.current_ap = st.current_ap - cost
  st.moved_this_activation = true
  local usedIn = Move.usedInches(guid)
  st.movement_session = nil
  CUS.pushRuntimeToMini(guid)
  Global.setVectorLines({})
  if CUS.Logger then CUS.Logger.log(("MOVE committed: %.1f\" used, %d AP spent."):format(usedIn, cost),
    { target = guid }) end
  Bus.emit("move:commit", { guid = guid })
  if CUS.StatePanel then CUS.StatePanel.refresh(mini) end
  return true
end

-- Undo/Cancel: snap back to the recorded origin, clear session, spend nothing.
function Move.cancel(guid)
  local s = session(guid)
  if not s then return end
  local mini = getObjectFromGUID(guid)
  if mini then
    mini.setPositionSmooth({ s.origin.x, s.origin.y, s.origin.z }, false, false)
    mini.setRotationSmooth(s.rot, false, false)
  end
  Store.getOrInit(guid).state.movement_session = nil
  CUS.pushRuntimeToMini(guid)
  Global.setVectorLines({})
  if CUS.Logger then CUS.Logger.log("MOVE cancelled — returned to origin.", { broadcast = false }) end
  Bus.emit("move:cancel", { guid = guid })
end

CUS.MovementResolver = Move

-- ===== end modules/MovementResolver =====
-- ===== begin modules/ChargeAssistant =====
-- modules/ChargeAssistant.lua
-- Charge is a MOVE mode, NOT a canonical action (sprinting into an enemy IS a
-- Charge; each impact is an ATTACK rolling the weapon's Tiers). This assistant
-- VISUALIZES and VALIDATES measurable facts, then requires the player to
-- confirm each descriptive outcome. It never physics-flings models.
--
-- The cascade:  1 Shove Aside → 2 Indent → 3 Crush (wall/obstacle → jam, +2 dice)
-- Size gates the plow · Mounted = a class up · Monstrous = unstoppable by bodies
-- · Small can't plow (slips through, no Disengage). Head-on tie = charger's choice.

CUS = CUS or {}
local C     = CUS.Constants
local Store = CUS.StateStore
local Geo   = CUS.Geo
local Charge = {}

local function classIdx(def)
  local cls = def and def.base and def.base.class or "Normal"
  local idx = C.CLASS_ORDER[cls] or 2
  if def and def.base and def.base.mounted then idx = idx + 1 end   -- mounted charges a class up
  return idx, cls, (def and def.base and def.base.mounted)
end

-- Compare the charger's effective class to a target's; returns a plow verdict.
function Charge.plowVerdict(chargerDef, targetDef)
  local ci, ccls, mounted = classIdx(chargerDef)
  local ti = C.CLASS_ORDER[targetDef and targetDef.base and targetDef.base.class or "Normal"] or 2
  local chargerSmall = (ccls == "Small") and not mounted
  local chargerMonstrous = (chargerDef and chargerDef.base and chargerDef.base.class == "Monstrous")

  if chargerSmall then
    return { verdict = "slip", note = "Small can't plow — slips through without a Disengage." }
  elseif chargerMonstrous then
    return { verdict = "plow_bodies", note = "Monstrous — unstoppable by bodies; only a wall jams it." }
  elseif ci > ti then
    return { verdict = "plow", note = (mounted and "Mounted (+class) plows freely." or "Bigger — plows freely.") }
  elseif ci == ti then
    return { verdict = "grudging", note = "Same size — plows grudgingly (short lane / jams easily)." }
  else
    return { verdict = "blocked", note = "Smaller than the target — cannot plow through it." }
  end
end

-- Build a charge preview: the straight travel lane + likely impact candidates.
-- others = list of { obj, def, side } (caller supplies enemy set & defs).
function Charge.preview(chargerGuid, others)
  local def = Store.getDefinition(chargerGuid)
  if not def then return nil, "charger definition unavailable" end
  local mini = getObjectFromGUID(chargerGuid)
  if not mini then return nil, "charger object missing" end

  local st = Store.getOrInit(chargerGuid).state
  local speed = def.stats.speed or 6
  local origin = mini.getPosition()
  local fwd = mini.getTransformForward()   -- straight-line lane

  -- lane endpoint at Speed inches ahead
  local endp = { x = origin.x + fwd.x * speed, y = origin.y + 0.2, z = origin.z + fwd.z * speed }

  -- candidate impacts: enemies whose base centre is near the lane segment
  local candidates = {}
  for _, o in ipairs(others or {}) do
    local p = o.obj.getPosition()
    -- distance from point to the lane segment (planar)
    local ax, az = origin.x, origin.z
    local bx, bz = endp.x, endp.z
    local dx, dz = bx-ax, bz-az
    local len2 = dx*dx + dz*dz
    local t = len2 > 0 and (((p.x-ax)*dx + (p.z-az)*dz) / len2) or 0
    t = math.max(0, math.min(1, t))
    local cx, cz = ax + t*dx, az + t*dz
    local off = math.sqrt((p.x-cx)^2 + (p.z-cz)^2)
    local corridor = Geo.baseRadiusUnits(def) + Geo.baseRadiusUnits(o.def)
    if off <= corridor * 1.2 then
      candidates[#candidates+1] = {
        obj = o.obj, def = o.def, side = o.side,
        along = t * speed,               -- how far along the lane the impact is
        plow = Charge.plowVerdict(def, o.def),
      }
    end
  end
  table.sort(candidates, function(a, b) return a.along < b.along end)

  Global.setVectorLines({
    { points = { { origin.x, origin.y+0.2, origin.z }, endp }, color = { 1, 0.55, 0.1 }, thickness = 0.1 },
  })

  return { charger = def, lane = { origin = origin, endp = endp, speed = speed }, candidates = candidates }
end

-- Wall-jam confirmation → the crush impact hits at +2 dice. Returns the modifier
-- the AttackResolver should receive for that impact.
function Charge.wallJamModifier()
  return { source = "Wall/Obstacle Crush (jam)", dice = C.TUNING.wall_crush_die, note = "+2 dice (confirmed jam)" }
end

function Charge.clear() Global.setVectorLines({}) end

CUS.ChargeAssistant = Charge

-- ===== end modules/ChargeAssistant =====
-- ===== begin modules/ConditionManager =====
-- modules/ConditionManager.lua
-- Generic condition manager driven by string IDs + optional icons. We do NOT
-- hard-code an exhaustive canonical list the Codex doesn't define. Unknown
-- conditions still display and persist safely. A condition may optionally carry
-- structured modifiers, duration, source, and removal timing.

CUS = CUS or {}
local Store = CUS.StateStore
local Cond = {}

-- Sample condition library (presentation + optional structured modifiers).
-- Extend freely; anything not listed here is still accepted as a bare id.
Cond.LIBRARY = {
  Burning      = { icon = "🔥", note = "Takes damage / spreads (resolve per source)." },
  Poisoned     = { icon = "☠", note = "Lingering harm (resolve per source)." },
  Marked       = { icon = "🎯", modifiers = { defenderDice = 1 }, note = "Attackers get +1 die." },
  Frozen       = { icon = "❄", note = "Movement impaired (resolve per source)." },
  Blinded      = { icon = "🌫", note = "Attacks Hit one step worse." },
  Rooted       = { icon = "🪵", note = "Cannot MOVE." },
  ["Knocked Down"] = { icon = "⬇", modifiers = { armourStep = 1 }, note = "Prone — save one step worse until it stands." },
  Guard        = { icon = "🛡", note = "Guard stance granted by a Tier effect." },
  Push         = { icon = "➡", note = "Shoved — apply displacement honestly." },
}

local function state(guid) return Store.getOrInit(guid).state end

function Cond.list(guid) return state(guid).conditions or {} end

function Cond.add(guid, id, opts)
  opts = opts or {}
  local lib = Cond.LIBRARY[id] or {}
  local conds = state(guid).conditions
  local entry = {
    id = id,
    icon = opts.icon or lib.icon,
    duration = opts.duration or lib.duration,
    source = opts.source,
    modifiers = opts.modifiers or lib.modifiers,
    note = opts.note or lib.note,
  }
  if CUS.Undo then CUS.Undo.pushMiniState(getObjectFromGUID(guid), "add condition " .. id) end
  conds[#conds+1] = entry
  CUS.pushRuntimeToMini(guid)
  if CUS.Logger then CUS.Logger.log(("Condition +%s on %s"):format(id, guid), { broadcast = false }) end
  return entry
end

function Cond.remove(guid, id)
  local conds = state(guid).conditions
  for i = #conds, 1, -1 do
    if conds[i].id == id then
      if CUS.Undo then CUS.Undo.pushMiniState(getObjectFromGUID(guid), "remove condition " .. id) end
      table.remove(conds, i)
      CUS.pushRuntimeToMini(guid)
      return true
    end
  end
  return false
end

-- Called by AttackResolver when a Tier Effect lands — surfaces it as a condition
-- where it maps to one; otherwise just logs the effect for the player to apply.
function Cond.noteEffect(guid, effect)
  if Cond.LIBRARY[effect] then
    Cond.add(guid, effect, { source = "attack effect" })
  elseif CUS.Logger then
    CUS.Logger.log(("Effect '%s' landed — apply per weapon text."):format(effect), { broadcast = false })
  end
end

-- Icons string for the state UI (cap + overflow "+N").
function Cond.iconStrip(guid, cap)
  cap = cap or 4
  local conds = state(guid).conditions or {}
  local out = {}
  for i = 1, math.min(cap, #conds) do
    out[#out+1] = conds[i].icon or "•"
  end
  local extra = #conds - cap
  if extra > 0 then out[#out+1] = "+" .. extra end
  return table.concat(out, " ")
end

CUS.ConditionManager = Cond

-- ===== end modules/ConditionManager =====
-- ===== begin modules/NerveResolver =====
-- modules/NerveResolver.lua
-- Nerve, morale and the Rout, per B.10 (SIGNED, William 2026-07-24).
--
-- v0.6 MIGRATION. Under v0.5 the numeric test was undefined, so this module
-- deliberately refused to invent one and offered only a plugin hook. v0.6
-- SIGNED the test, so it is implemented here now — and the morale track became
-- three states, replacing the old Steady/Routed pair.
--
--   WHO TESTS   Squares only, and only Creature Type Man or Beast.
--               Circles never test and never break (heroes hold).
--               Spirit and Construct never test (fearless).
--
--   THE SHOCK   A Square tests the moment it suffers a shock:
--                 · it is WOUNDED by an ATTACK (took a hit and lived), or
--                 · a friendly figure within 3" is slain or goes Broken.
--               One test per shock. A PACKET Effect may also force one.
--
--   THE ROLL    Roll 3 dice. Each die >= the figure's Nerve is a success.
--                 0 successes  -> step DOWN   (Steady -> Shaken -> Broken)
--                 1-2          -> hold
--                 3            -> step UP     (rally through it)
--
--   BROKEN      The figure Routs by its Temperament. The mod NEVER auto-moves
--               a routed model — it prints the instruction and the player moves.

CUS = CUS or {}
local C     = CUS.Constants
local Store = CUS.StateStore
local Nerve = {}

-- Optional override injected later: fn(def, state) -> successes.
Nerve.plugin = nil

-- ---------------------------------------------------------------- eligibility
function Nerve.eligibility(def)
  local shape = def and def.base and def.base.shape
  local ctype = def and def.creature_type
  if shape == "Circle" then
    return { eligible = false, reason = "Circle hero — never tests Nerve, never breaks." }
  end
  if C.TESTS_NERVE[ctype] == false then
    return { eligible = false, reason = tostring(ctype) .. " — fearless, never tests Nerve." }
  end
  if C.TESTS_NERVE[ctype] then
    return { eligible = true, reason = ("Square %s — tests Nerve on a shock (Nerve %s)."):format(
             ctype, tostring(def.stats and def.stats.nerve)) }
  end
  return { eligible = false, reason = "No Nerve test applies." }
end

-- ---------------------------------------------------------------- the track
local function idx(m) return C.MORALE_ORDER[m or "Steady"] or 1 end
local function name(i)
  if i < 1 then i = 1 end
  if i > #C.MORALE_STATES then i = #C.MORALE_STATES end
  return C.MORALE_STATES[i]
end

function Nerve.currentMorale(guid)
  local rt = Store.get(guid)
  return (rt and rt.state and rt.state.morale) or "Steady"
end

-- Step a figure along the morale track. `delta` is +1 down (worse), -1 up.
function Nerve.step(guid, delta, why)
  local st = Store.getOrInit(guid).state
  local before = st.morale or "Steady"
  local after  = name(idx(before) + delta)
  if after == before then
    if CUS.Logger then CUS.Logger.log(("Morale unchanged (%s) — %s"):format(before, why or "")) end
    return before, before
  end
  if CUS.Undo then CUS.Undo.pushMiniState(getObjectFromGUID(guid), "morale -> " .. after) end
  st.morale = after
  CUS.pushRuntimeToMini(guid)
  if CUS.Logger then
    CUS.Logger.log(("Morale: %s -> %s%s"):format(before, after, why and ("  (" .. why .. ")") or ""))
  end
  return after, before
end

-- Rally steps a figure UP one state (a leader's ACTION, B.10).
function Nerve.rally(guid) return Nerve.step(guid, -1, "Rally") end

-- Manual override, kept for a table that wants to just set the state.
function Nerve.setMorale(guid, morale)
  local st = Store.getOrInit(guid).state
  if CUS.Undo then CUS.Undo.pushMiniState(getObjectFromGUID(guid), "morale -> " .. morale) end
  st.morale = morale
  CUS.pushRuntimeToMini(guid)
  if CUS.Logger then CUS.Logger.log(("Morale of %s set to %s"):format(guid, morale)) end
end

-- ---------------------------------------------------------------- the test
-- Rolls 3 dice against the figure's Nerve and applies the result.
-- Returns a result table, or nil + reason when the figure does not test.
function Nerve.test(guid, why)
  local def = Store.getDefinition(guid)
  if not def then return nil, "definition unavailable" end

  local el = Nerve.eligibility(def)
  if not el.eligible then return nil, el.reason end

  local target = def.stats and def.stats.nerve
  if not target then return nil, "no Nerve value printed on the card" end

  local rolls, successes = {}, 0
  if Nerve.plugin then
    successes = Nerve.plugin(def, Store.getOrInit(guid).state)
  else
    for i = 1, C.NERVE.dice do
      local d = math.random(1, 6)
      rolls[i] = d
      if d >= target then successes = successes + 1 end
    end
  end

  local delta, verdict
  if successes <= C.NERVE.down_at then
    delta, verdict = 1, "steps DOWN"
  elseif successes >= C.NERVE.up_at then
    delta, verdict = -1, "steps UP"
  else
    delta, verdict = 0, "holds"
  end

  local after, before = Nerve.step(guid, delta, why or "Nerve test")

  if CUS.Logger then
    CUS.Logger.log(("Nerve %s: [%s] vs %d+ -> %d success%s, %s (%s -> %s)"):format(
      def.name, table.concat(rolls, " "), target, successes,
      successes == 1 and "" or "es", verdict, before, after))
  end

  local res = {
    rolls = rolls, target = target, successes = successes,
    verdict = verdict, before = before, after = after,
    broken = (after == "Broken"),
  }
  if res.broken then res.rout = Nerve.routInstruction(def) end
  return res
end

-- ---------------------------------------------------------------- the shock
-- Did something just happen that makes this figure test? Callers pass what
-- occurred; this only reports, so the player still confirms.
--   kind = "wounded"        the figure was Wounded by an ATTACK and lived
--   kind = "friend_fell"    a friendly within 3" was slain or went Broken
function Nerve.isShock(guid, kind)
  local def = Store.getDefinition(guid)
  if not def then return false, "definition unavailable" end
  local el = Nerve.eligibility(def)
  if not el.eligible then return false, el.reason end
  if kind == "wounded" then
    return true, "Wounded by an attack — test Nerve."
  elseif kind == "friend_fell" then
    return true, ("A friendly fell within %d\" — test Nerve."):format(C.NERVE.shock_radius_in)
  end
  return false, "not a shock"
end

-- ---------------------------------------------------------------- the rout
-- On Broken, return the exact Temperament instruction. The player moves it.
function Nerve.routInstruction(def)
  local t = def and def.temperament
  local entry = t and C.TEMPERAMENTS[t]
  if not entry then return "No temperament printed — resolve manually." end
  return ("%s (Rout): %s"):format(t, entry.rout)
end

-- Leaderless behaviour, same table, other column (B.10).
function Nerve.leaderlessInstruction(def)
  local t = def and def.temperament
  local entry = t and C.TEMPERAMENTS[t]
  if not entry then return "No temperament printed — resolve manually." end
  return ("%s (leaderless): %s"):format(t, entry.lone)
end

-- Retired v0.5 entry point.
function Nerve.autoTest(guid) return Nerve.test(guid) end

CUS.NerveResolver = Nerve

-- ===== end modules/NerveResolver =====
-- ===== begin modules/FormationAssistant =====
-- modules/FormationAssistant.lua
-- Formations are DESCRIPTIVE, not prescriptive. We never enforce spacing
-- matrices. A Formation card carries only Name · Picture · one sentence · family.
--
-- Advance:  a Sergeant/leader spends 1 AP + its MOVE to form up with Square
--           companions; group Speed = slowest Speed − 1; Advance spends EVERY
--           participant's MOVE; move only the Sergeant; participants become
--           READY; no combat bonus; dissolves on contact/attack/manual break.
-- Reform:   1 AP, rearrange within a ~3" circle of the leader.

CUS = CUS or {}
local C     = CUS.Constants
local Store = CUS.StateStore
local Geo   = CUS.Geo
local Form  = {}

-- Sample formation cards (name · one sentence · family). Extend via data.
Form.LIBRARY = {
  Wedge            = { family = "Closed", line = "Keep the spearhead." },
  Stagger          = { family = "Open",   line = "Keep a loose stagger." },
  Column           = { family = "Open",   line = "Follow in file." },
  Line             = { family = "Closed", line = "Hold the line." },
  ["Shield Wall"]  = { family = "Closed", line = "Shields locked, hold." },
  Box              = { family = "Closed", line = "Face out on every side." },
  Ring             = { family = "Closed", line = "Guard the ring." },
  ["Protected Center"] = { family = "Closed", line = "Keep the centre protected." },
}

-- Begin an Advance. leaderGuid + list of participant miniature GUIDs.
-- Validates: participants are Square companions; computes group Speed.
function Form.beginAdvance(leaderGuid, participantGuids, formationName)
  local ldef = Store.getDefinition(leaderGuid)
  if not ldef then return nil, "leader definition unavailable" end
  local lstate = Store.getOrInit(leaderGuid).state
  if (lstate.current_ap or 0) < 1 then return nil, "leader has no AP for Advance" end

  local slowest = ldef.stats.speed or 6
  local members = {}
  for _, g in ipairs(participantGuids) do
    local def = Store.getDefinition(g)
    if not def then return nil, "participant " .. g .. " has no definition" end
    if def.base and def.base.shape ~= "Square" then
      return nil, "participant " .. (def.name or g) .. " is not a Square companion"
    end
    slowest = math.min(slowest, def.stats.speed or 6)
    members[#members+1] = g
  end

  local groupSpeed = math.max(1, slowest - 1)
  local fdata = Form.LIBRARY[formationName] or { family = "Open", line = "" }

  -- Advance spends the MOVE of EVERY participant (closes daisy-chaining) and
  -- readies them; the leader spends 1 AP + its MOVE.
  for _, g in ipairs(members) do
    local st = Store.getOrInit(g).state
    st.moved_this_activation = true
    st.formation = { name = formationName, family = fdata.family, leader_guid = leaderGuid }
    -- participants become READY (can still react) until their own activation
    st.ready_packet_id = st.ready_packet_id or "FORMATION_READY"
    CUS.pushRuntimeToMini(g)
  end
  lstate.current_ap = lstate.current_ap - 1
  lstate.moved_this_activation = true
  lstate.formation = { name = formationName, family = fdata.family, leader_guid = leaderGuid, is_leader = true }
  CUS.pushRuntimeToMini(leaderGuid)

  if CUS.Logger then
    CUS.Logger.log(("Advance in %s: group Speed %d\" (slowest−1), %d participants readied.")
      :format(tostring(formationName), groupSpeed, #members))
  end
  return { leader = leaderGuid, members = members, groupSpeed = groupSpeed, family = fdata.family, line = fdata.line }
end

-- Dissolve a formation (member contacted, attacked, or manual break).
function Form.dissolve(leaderGuid)
  local grp = { leaderGuid }
  -- clear any miniature that references this leader
  for guid, rt in pairs(Store.runtime) do
    if rt.state.formation and rt.state.formation.leader_guid == leaderGuid then
      rt.state.formation = nil
      if rt.state.ready_packet_id == "FORMATION_READY" then rt.state.ready_packet_id = nil end
      CUS.pushRuntimeToMini(guid)
    end
  end
  local lst = Store.getOrInit(leaderGuid).state
  lst.formation = nil
  CUS.pushRuntimeToMini(leaderGuid)
  if CUS.Logger then CUS.Logger.log("Formation dissolved.", { broadcast = false }) end
end

-- Reform: draw the ~3" circle around the leader; player places models honestly.
function Form.reform(leaderGuid)
  local lstate = Store.getOrInit(leaderGuid).state
  if (lstate.current_ap or 0) < 1 then return nil, "no AP to Reform" end
  local mini = getObjectFromGUID(leaderGuid)
  if not mini then return nil, "leader object missing" end
  lstate.current_ap = lstate.current_ap - 1
  CUS.pushRuntimeToMini(leaderGuid)

  -- draw the reform circle
  local p = mini.getPosition()
  local pts, r, seg = {}, C.TUNING.reform_radius_in, 32
  for i = 0, seg do
    local a = (i / seg) * math.pi * 2
    pts[#pts+1] = { p.x + math.cos(a) * r, p.y + 0.2, p.z + math.sin(a) * r }
  end
  Global.setVectorLines({ { points = pts, color = { 0.6, 0.9, 0.6 }, thickness = 0.06 } })
  if CUS.Logger then CUS.Logger.log("Reform: place models honestly within the ~3\" circle (1 AP).") end
  return true
end

CUS.FormationAssistant = Form

-- ===== end modules/FormationAssistant =====
-- ===== begin modules/RoundManager =====
-- modules/RoundManager.lua
-- Compact round/activation assistance — NOT an initiative director. It marks
-- activation, restores AP, resets flags, and manages round-limited Counter
-- state. It never imposes an activation order the Codex doesn't define.
--
-- New Round: restore AP · clear activations · reset Counter uses · clear
-- moved/attacked flags · PRESERVE wounds/conditions/links · configurable Ready
-- cleanup by packet duration.

CUS = CUS or {}
local C     = CUS.Constants
local Store = CUS.StateStore
local Nerve = CUS.NerveResolver
local Round = { round = 1 }

-- expose the current round to the Logger
if CUS.Logger then CUS.Logger.roundProvider = function() return Round.round end end

-- Start a figure's own activation: facing may update, activation-local flags reset.
function Round.beginActivation(guid)
  local st = Store.getOrInit(guid).state
  st.activated = true
  st.facing_locked = false                  -- facing updates on your OWN turn
  st.moved_this_activation = false
  st.attacked_this_activation = false
  CUS.pushRuntimeToMini(guid)
  if CUS.Logger then CUS.Logger.log(("Activation started (%s)."):format(guid), { broadcast = false }) end
end

function Round.endActivation(guid)
  local st = Store.getOrInit(guid).state
  st.activated = true                       -- stays marked activated for the round
  st.facing_locked = true                   -- facing frozen during others' turns
  CUS.pushRuntimeToMini(guid)
end

-- Advance to a new round across ALL known miniatures.
function Round.newRound(opts)
  opts = opts or {}
  Round.round = Round.round + 1
  local touched = 0
  for guid, rt in pairs(Store.runtime) do
    local def = Store.getDefinition(guid)     -- may be nil if link broken; that's fine
    local st = rt.state
    -- restore AP to the card maximum (facts stored; max comes from the definition)
    if def and def.stats and def.stats.max_ap then st.current_ap = def.stats.max_ap end
    st.activated = false
    st.moved_this_activation = false
    st.attacked_this_activation = false
    st.reaction_spent = false
    -- Nothing to reset for Counters. B.9 (SIGNED): no per-round cap, no
    -- counter_x economy — a figure Counters every enemy that attacks it, every
    -- round, and even as it dies. Only death stops it.
    -- configurable Ready cleanup: drop reactions that expire at round end
    if opts.clear_ready ~= false then
      if st.ready_packet_id == "FORMATION_READY" then
        -- formation READY persists until the member's own activation; leave it
      else
        st.ready_packet_id = nil
      end
    end
    -- PRESERVE wounds, conditions, morale, card links (do nothing to them)
    CUS.pushRuntimeToMini(guid)
    touched = touched + 1
  end
  if CUS.Logger then CUS.Logger.log(("── New Round %d ── (%d figures refreshed; wounds & links preserved)")
    :format(Round.round, touched)) end
  if CUS.Bus then CUS.Bus.emit("round:new", { round = Round.round }) end
end

function Round.serialize() return { round = Round.round } end
function Round.restore(blob) if blob and blob.round then Round.round = blob.round end end

CUS.RoundManager = Round

-- ===== end modules/RoundManager =====
-- ===== begin ui/RadialWheel =====
-- ui/RadialWheel.lua
-- Player-local radial wheel. ROOT = exactly MOVE · ACTION · WAIT (A.III, SIGNED).
--
-- v0.6 MIGRATION. The root used to be four buttons — MOVE/ATTACK/USE/READY.
-- ATTACK and USE were never separate verbs; both resolve a PACKET, so both are
-- ACTION. READY is WAIT. The flavour a player actually reads — "Spear Thrust",
-- "Cast", "Brace", "Overwatch" — now lives in the submenu, listed by packet
-- name, exactly as B.15 describes: the player reads the flavour, the system
-- reads MOVE · ACTION · WAIT. Never add a fourth root (Law 11).
--
-- Center closes the wheel / opens the linked card. A small outer utility ring
-- (Activate · State · Command · Undo · Cancel) is NOT presented as new canonical
-- actions.
--
-- The wheel is anchored to screen centre (reliable) rather than chasing the
-- cursor. It lives in Global.xml as panel id="cus_wheel"; this module fills the
-- submenu column (id="cus_wheel_sub") via UI.setXmlTable.

CUS = CUS or {}
local C     = CUS.Constants
local Store = CUS.StateStore
local Reg   = CUS.PacketRegistry
local Wheel = {}

Wheel.ctx = { guid = nil, player = nil, branch = nil }

-- ---------- open / close ----------------------------------------------------
function Wheel.open(guid, playerColor)
  local def, reason = Store.getDefinition(guid)
  if not def then
    if CUS.Logger then CUS.Logger.warn("Cannot open wheel: " .. tostring(reason)) end
    return
  end
  Wheel.ctx = { guid = guid, player = playerColor, branch = nil }
  UI.setAttribute("cus_wheel_title", "text", def.name)
  Wheel.showRoot()
  UI.setAttribute("cus_wheel", "visibility", playerColor)
  UI.show("cus_wheel")
end

function Wheel.close()
  UI.hide("cus_wheel")
  Wheel.ctx.branch = nil
end

function Wheel.center()
  -- center button: if a submenu is open, go back to root; else open card & close
  if Wheel.ctx.branch then
    Wheel.showRoot()
  else
    if CUS.CardViewer and Wheel.ctx.guid then
      CUS.CardViewer.openForMini(Wheel.ctx.guid, Wheel.ctx.player)
    end
    Wheel.close()
  end
end

-- ---------- submenu builder -------------------------------------------------
-- Rows go into the PRE-DECLARED slots whsub1..whsub20 via setAttribute. They
-- are never rebuilt with UI.setXmlTable — that call takes an asset table, not
-- an element id, and would replace the entire UI (see core/UIList.lua).
local SUB_SLOTS = 20

local function subButton(label, fn, tooltip)
  return { text = label, onClick = fn, tooltip = tooltip or "" }
end

local function heading(text)
  return { kind = "header", text = text }
end

local function setSub(rows)
  CUS.UIList.fill("whsub", SUB_SLOTS, rows)
end

function Wheel.showRoot()
  Wheel.ctx.branch = nil
  setSub({
    heading("MOVE — change position now"),
    heading("ACTION — resolve a packet now"),
    heading("WAIT — arm a packet for later"),
  })
  -- root MOVE/ACTION/WAIT are static buttons in Global.xml; nothing to fill
end

-- ---------- MOVE ------------------------------------------------------------
-- "Charge" is retired as a keyword (B.3): a second MOVE is a Sprint, and the
-- contact a Sprint creates is an Impact.
function Wheel.branchMove()
  Wheel.ctx.branch = "MOVE"
  setSub({
    subButton("Begin Move",           "wheelMoveBegin",   "Start a tracked MOVE session"),
    subButton("Sprint / Impact Assist","wheelChargeAssist","Preview the sprint lane, and the Impacts it creates"),
    subButton("Disengage (1 AP)",     "wheelDisengage",   "Leave an engagement — bases are touching"),
    subButton("Advance Formation",    "wheelAdvance",     "Sergeant forms up (1 AP + MOVE)"),
    subButton("Reform (1 AP)",        "wheelReform",      "Rearrange within ~3\""),
    subButton("Add Obstacle / Story", "wheelStory",       "+1 AP per story climbed"),
    subButton("Commit",               "wheelMoveCommit",  "Spend AP, keep position"),
    subButton("Undo",                 "wheelMoveUndo",    "Return to origin"),
    subButton("Cancel",               "wheelShowRoot",    "Back"),
  })
end

local function noDefRows()
  return { { tag = "Text", attributes = { class = "wheelHint", text = "Linked card unavailable." } } }
end

-- ---------- ACTION ----------------------------------------------------------
-- One verb, every packet. Attacks and abilities are no longer separate branches
-- because they were never separate verbs — both resolve a PACKET (A.III, A.V).
-- Packets are listed by their own name so the player still reads the flavour.
function Wheel.branchAction()
  Wheel.ctx.branch = "ACTION"
  local def = Store.getDefinition(Wheel.ctx.guid)
  if not def then setSub(noDefRows()); return end

  local rows = {}
  local st = Store.getState and Store.getState(Wheel.ctx.guid) or nil
  local spent = st and st.attack_used

  -- --- packets that deliver Force (the old ATTACK branch) ---
  local strikes = Reg.resolveAttacks(def) or {}
  if #strikes > 0 then
    rows[#rows+1] = heading(spent and "STRIKE — already attacked this activation"
                                  or  "STRIKE")
    for _, p in ipairs(strikes) do
      rows[#rows+1] = subButton(p.alias or p.id, "wheelActionPacket(" .. p.id .. ")",
        ("Dice %d · Hit %d+%s"):format(p.dice, p.hit,
          (p.range and p.range > 0) and (" · Range " .. p.range .. "\"") or " · Melee"))
      -- ranged modes appear only when legal (a packet may forbid Multi-Shot)
      if p.range and p.range > 0 then
        rows[#rows+1] = subButton("  ↳ Regular Shot",   "wheelShot(" .. p.id .. "|Regular)",   "Move and shoot normally")
        rows[#rows+1] = subButton("  ↳ Precision Shot", "wheelShot(" .. p.id .. "|Precision)", "No MOVE · +1 die · ignores Cover · ends the activation")
        local noMulti = false
        for _, t in ipairs(p.tags or {}) do if t == "no Multi-Shot" then noMulti = true end end
        if not noMulti then
          rows[#rows+1] = subButton("  ↳ Multi-Shot", "wheelShot(" .. p.id .. "|Multi)", "Two shots · Hit one step worse")
        end
      end
    end
  end

  -- --- packets that do anything else (the old USE branch) ---
  -- Accept both the v0.6 parent "ACTION" and the retired v0.5 "USE" so a card
  -- authored before the rebuild still lists its abilities.
  local abilities = Reg.resolveAbilities(def, "Active", "ACTION") or {}
  if #abilities == 0 then abilities = Reg.resolveAbilities(def, "Active", "USE") or {} end
  if #abilities > 0 then
    rows[#rows+1] = heading("CAST / INTERACT")
    for _, p in ipairs(abilities) do
      rows[#rows+1] = subButton(p.alias or p.id, "wheelActionPacket(" .. p.id .. ")", p.note or "")
    end
  end

  rows[#rows+1] = heading("GENERIC")
  rows[#rows+1] = subButton("Interact", "wheelInteract", "Generic object interaction")
  rows[#rows+1] = subButton("Pick Up",  "wheelPickUp",  "Pick up an object")

  if #strikes == 0 and #abilities == 0 then
    table.insert(rows, 1, heading("No packets on this card."))
  end
  if spent then
    rows[#rows+1] = heading("One attack per activation — a strike is spent, but "
      .. "other packets and MOVE remain.")
  end
  rows[#rows+1] = subButton("Cancel", "wheelShowRoot", "Back")
  setSub(rows)
end

-- ---------- WAIT ------------------------------------------------------------
-- WAIT arms a PACKET against a trigger; it does not resolve now, and it ENDS
-- the activation. The Counter also lives in this family structurally, but it
-- fires automatically and is never chosen here (B.9).
function Wheel.branchWait()
  Wheel.ctx.branch = "WAIT"
  local def = Store.getDefinition(Wheel.ctx.guid)
  if not def then setSub(noDefRows()); return end

  local rows = {}
  local armed = Reg.resolveAbilities(def, "Reactive", "WAIT") or {}
  if #armed == 0 then armed = Reg.resolveAbilities(def, "Reactive", "READY") or {} end
  for _, p in ipairs(armed) do
    rows[#rows+1] = subButton(p.alias or p.id, "wheelWaitPacket(" .. p.id .. ")", p.note or "")
  end

  -- Generic reactions. Brace is Square-only (a faceless Circle has no facing to
  -- fix) and is PROVISIONAL until the first game ratifies it (B.9b).
  rows[#rows+1] = heading("GENERIC")
  local shape = (def.base and def.base.shape) or def.shape
  if C.PROVISIONAL.enabled and C.PROVISIONAL.brace and shape ~= "Circle" then
    rows[#rows+1] = subButton("Brace  (provisional)", "wheelWaitPacket(GENERIC_BRACE)",
      "Lock your facing: +1 die into your front, enemies into it roll -1. Flank and rear get in free.")
  end
  rows[#rows+1] = subButton("Overwatch", "wheelWaitPacket(GENERIC_OVERWATCH)", "Arm a ranged packet against movement")
  rows[#rows+1] = subButton("Wait",      "wheelWaitPacket(GENERIC_WAIT)",      "Hold the packet for any trigger you name")

  rows[#rows+1] = heading("WAIT spends 1 AP and ENDS the activation.")
  rows[#rows+1] = subButton("Cancel", "wheelShowRoot", "Back")
  setSub(rows)
end

-- ---------- retired v0.5 entry points --------------------------------------
-- Kept as thin shims so an old hotkey binding or a stale XML reference still
-- lands somewhere sensible instead of erroring. They are NOT new verbs.
function Wheel.branchAttack() return Wheel.branchAction() end
function Wheel.branchUse()    return Wheel.branchAction() end
function Wheel.branchReady()  return Wheel.branchWait()   end

CUS.RadialWheel = Wheel

-- ===== end ui/RadialWheel =====
-- ===== begin ui/CardViewer =====
-- ui/CardViewer.lua
-- Player-local large card image panel. Toggle with the same action. Pin/Unpin
-- and multiple pinned cards supported. NEVER creates a second authoritative
-- gameplay card — it only shows the presentation PNG/SVG. If no image URL is
-- available, it falls back to highlighting the physical card.

CUS = CUS or {}
local Store = CUS.StateStore
local Viewer = {}

Viewer.open = {}     -- playerColor -> { url, guid, pinned }

function Viewer.openForMini(miniGuid, playerColor)
  local def, reason = Store.getDefinition(miniGuid)
  local card = select(1, Store.resolveCard(miniGuid))
  if not def then
    if CUS.Logger then CUS.Logger.warn("Open Card: " .. tostring(reason)) end
    if card then card.highlightOn({ 0.55, 1, 0.55 }, 4) end
    return
  end
  local url = def.display and def.display.card_image_url or ""
  if url == "" then
    -- fallback: focus/highlight the physical card
    if card then
      card.highlightOn({ 0.55, 1, 0.55 }, 4)
      if CUS.Logger then CUS.Logger.log("No card image URL — highlighted the physical card instead.", { broadcast = false }) end
    end
    return
  end
  -- toggle behaviour
  local cur = Viewer.open[playerColor]
  if cur and cur.guid == miniGuid and not cur.pinned then
    Viewer.close(playerColor)
    return
  end
  Viewer.open[playerColor] = { url = url, guid = miniGuid, pinned = cur and cur.pinned or false }
  -- TTS <Image> references a registered Custom UI Asset by name, not a raw URL.
  -- Register (or update) the card image as an asset, then point the Image at it.
  local assetName = "cuscard_" .. miniGuid
  local assets = UI.getCustomAssets() or {}
  local found = false
  for _, a in ipairs(assets) do if a.name == assetName then a.url = url; found = true end end
  if not found then table.insert(assets, { name = assetName, url = url }) end
  UI.setCustomAssets(assets)
  UI.setAttribute("cus_card_img", "image", assetName)
  UI.setAttribute("cus_card_title", "text", def.name)
  UI.setAttribute("cus_cardviewer", "visibility", playerColor)
  UI.show("cus_cardviewer")
end

function Viewer.togglePin(playerColor)
  local cur = Viewer.open[playerColor]
  if cur then
    cur.pinned = not cur.pinned
    UI.setAttribute("cus_card_pin", "text", cur.pinned and "📌 Pinned" or "Pin")
  end
end

function Viewer.close(playerColor)
  local cur = Viewer.open[playerColor]
  if cur and cur.pinned then return end   -- pinned stays open
  Viewer.open[playerColor] = nil
  UI.hide("cus_cardviewer")
end

CUS.CardViewer = Viewer

-- ===== end ui/CardViewer =====
-- ===== begin ui/StatePanel =====
-- ui/StatePanel.lua
-- Floating RUNTIME state above each miniature — and ONLY runtime state:
-- activation · remaining AP · current Wounds · Ready/reaction · conditions.
-- It never floats Role/Tool/Dice/Hit/Armour/Speed/Rank/weapon/Tiers (those are
-- the card's job). Compact icons sit inside large touch-friendly hitboxes.
--
-- Implemented as OBJECT-attached UI (mini.UI). The miniature's object script
-- exposes thin click forwarders (stateClick*) that call back into Global.

CUS = CUS or {}
local Store = CUS.StateStore
local Cond  = CUS.ConditionManager
local Panel = {}

-- Build the object UI XML for one miniature from its runtime state + definition.
local function buildXml(guid)
  local rt  = Store.getOrInit(guid)
  local st  = rt.state
  local def = Store.getDefinition(guid)      -- may be nil (broken link)
  local maxAp = def and def.stats and def.stats.max_ap or (st.current_ap or 0)
  local maxW  = def and def.stats and def.stats.max_wounds or (st.current_wounds or 0)

  local activationColor = st.activated and "#666666" or "#33d9ff"
  local activationText  = st.activated and "◐" or "○"

  -- AP pips as compact text
  local ap = ("AP %d/%d"):format(st.current_ap or 0, maxAp)
  local wounds = ("♥ %d/%d"):format(st.current_wounds or 0, maxW)
  local ready = (st.ready_packet_id and ("⚑ " .. tostring(st.ready_packet_id)) or "")
  local morale = (st.morale and st.morale ~= "Steady") and (" " .. st.morale) or ""
  local conds = Cond and Cond.iconStrip(guid, 4) or ""

  -- world-space panel above the model (offset up in Y via object UI position)
  return string.format([[
<Panel width="360" height="150" position="0 90 0" rotation="0 0 0" scale="0.28 0.28 1"
       color="rgba(0,0,0,0.55)" outlineSize="1 1" outline="rgba(0,0,0,0.8)">
  <VerticalLayout padding="6 6 4 4" spacing="2">
    <HorizontalLayout preferredHeight="52" spacing="6">
      <Button fontSize="34" color="%s" textColor="white" onClick="stateClickActivation"
              tooltip="Begin / End activation">%s</Button>
      <Button fontSize="26" color="rgba(0,0,0,0)" textColor="#ffe08a" onClick="stateClickAP"
              tooltip="Left area = spend AP / right-click refund">%s</Button>
      <Button fontSize="26" color="rgba(0,0,0,0)" textColor="#ff8a8a" onClick="stateClickWound"
              tooltip="Apply / restore a Wound">%s</Button>
    </HorizontalLayout>
    <HorizontalLayout preferredHeight="40" spacing="6">
      <Button fontSize="20" color="rgba(0,0,0,0)" textColor="#9ad0ff" onClick="stateClickReady"
              tooltip="Inspect / cancel Ready">%s</Button>
      <Button fontSize="20" color="rgba(0,0,0,0)" textColor="#ffd27a" onClick="stateClickConditions"
              tooltip="Open condition manager">%s%s</Button>
      <Button fontSize="20" color="rgba(0,0,0,0)" textColor="#cfe8ff" onClick="stateClickCard"
              tooltip="Open linked card">🂠</Button>
    </HorizontalLayout>
  </VerticalLayout>
</Panel>]], activationColor, activationText, ap, wounds, ready, conds, morale)
end

function Panel.refresh(miniObj)
  if not miniObj then return end
  local guid = miniObj.getGUID()
  local ok = pcall(function() miniObj.UI.setXml(buildXml(guid)) end)
  if not ok and CUS.Logger then
    CUS.Logger.warn("StatePanel refresh failed for " .. guid, { broadcast = false })
  end
end

function Panel.refreshGuid(guid)
  local o = getObjectFromGUID(guid)
  if o then Panel.refresh(o) end
end

function Panel.refreshAll()
  for guid in pairs(Store.runtime) do Panel.refreshGuid(guid) end
end

CUS.StatePanel = Panel

-- ===== end ui/StatePanel =====
-- ===== begin ui/AttackPanel =====
-- ui/AttackPanel.lua
-- Compact player-local attack resolver panel. Renders the AttackResolver
-- session: attacker/defender blocks, a source-labelled modifier ledger,
-- player-confirmable judgment toggles, final Dice/Hit BEFORE rolling, and the
-- roll → preview → Apply flow. Nothing mutates the defender until Apply.

CUS = CUS or {}
local Store  = CUS.StateStore
local Attack = CUS.AttackResolver
local AP = {}

AP.player = nil

local function label(id, text) UI.setAttribute(id, "text", text) end

-- Build the modifier ledger rows (every modifier shows source + consequence).
local function ledgerRows(s)
  local rows = {}
  local function row(src, effect)
    -- Flat rows: the ledger renders into pre-declared slots (ledg_r1..14), so
    -- source and effect share one line rather than nesting a layout.
    rows[#rows+1] = { kind = "header", text = src .. "   ->   " .. effect }
  end
  for _, m in ipairs(s.modifiers) do
    local parts = {}
    if m.dice then parts[#parts+1] = (m.dice >= 0 and "+" or "") .. m.dice .. " dice" end
    if m.hitStep then parts[#parts+1] = "Hit " .. m.hitStep .. " step worse" end
    if m.armourStep then parts[#parts+1] = "Armour " .. m.armourStep .. " step worse" end
    if m.ignoreArmour then parts[#parts+1] = "ignore Armour" end
    if m.suppressCounter then parts[#parts+1] = "no Counter" end
    row(m.source, m.note ~= "" and m.note or table.concat(parts, ", "))
  end
  if s.mob_candidate then
    row("Mob Rule?", s.mob_confirmed and "CONFIRMED: Armour 1 step worse" or "Circle — confirm if engaged by 2+")
  end
  if #rows == 0 then rows[1] = { kind = "header", text = "No modifiers." } end
  return rows
end

function AP.render(playerColor)
  local s = Attack.session
  if not s then return end
  AP.player = playerColor or AP.player
  local comp = Attack.compute(s)

  label("ap_atk_name", s.atkDef.name .. (s.is_counter and "  (COUNTER)" or ""))
  label("ap_def_name", s.defDef.name)
  label("ap_packet", (s.packet.alias or s.packet.id) .. "  ·  " .. (s.mode or "Regular"))
  label("ap_def_armour", "Armour: " .. CUS.Schema.armourClass(s.defDef))
  label("ap_def_wounds", ("Wounds: %d"):format(Store.getOrInit(s.defenderGuid).state.current_wounds))
  -- B.9 (SIGNED): Counters have no cap. There is no allowance to display —
  -- what matters is whether THIS strike draws one.
  label("ap_def_counter", s.is_counter and "Counter: none (a Counter draws no Counter)"
        or (s.suppressCounter and "Counter: suppressed"
        or (s.reach and not s.touching) and "Counter: none (Reach, no contact)"
        or "Counter: yes — it turns and swings back"))
  label("ap_facing", "Facing: " .. tostring(s.facing or "?") ..
        (s.reach and "  · Reach (no Counter)" or "") .. (s.touching and "  · bases touching" or ""))

  CUS.UIList.fill("ledg_r", 14, ledgerRows(s))

  label("ap_final", ("FINAL:  %d dice  ·  Hit %d+%s%s"):format(
    comp.dice, comp.hit,
    comp.ignoreArmour and "  ·  ignore Armour" or "",
    comp.armourStep > 0 and ("  ·  Armour +" .. comp.armourStep .. " worse") or ""))

  -- mob toggle button reflects state
  UI.setAttribute("ap_mob", "text", s.mob_confirmed and "Mob Rule: ON" or "Mob Rule: off")

  UI.setAttribute("cus_attack", "visibility", AP.player)
  UI.show("cus_attack")
  UI.hide("ap_result")   -- hidden until a roll happens
end

-- Render the resolved result (after a roll) — dice, successes, tiers, saves.
function AP.renderResult()
  local s = Attack.session
  if not s or not s.result then return end
  local r = s.result
  local dice = {}
  for _, d in ipairs(r.rolls) do
    dice[#dice+1] = (d.success and ("[" .. d.die .. "]") or tostring(d.die))
  end
  label("ap_dice", "Dice: " .. table.concat(dice, " ") .. ("   → %d success"):format(r.successes))
  local tiers = {}
  for _, t in ipairs(r.reachedTiers) do tiers[#tiers+1] = t.successes .. "→" .. (t.wounds and (t.wounds .. "W") or "") end
  label("ap_tiers", ("Tiers reached: %s   ·   best Wound = %d"):format(table.concat(tiers, ", "), r.wounds))
  label("ap_effects", (#r.effects > 0) and ("Effects: " .. table.concat(r.effects, ", ")) or "Effects: —")
  local saves = {}
  for _, sv in ipairs(r.armour.rolls) do saves[#saves+1] = (sv.saved and (sv.die .. "✓") or (sv.die .. "✗")) end
  label("ap_saves", ("Armour %s: %s   →   %d unsaved"):format(
    r.saveThreshold and (r.saveThreshold .. "+") or "—", table.concat(saves, " "), r.unsaved))
  label("ap_pending", ("Pending: Wounds %d → %d%s"):format(
    r.pending.wounds_before, r.pending.wounds_after,
    r.counter_possible and "   ·   Counter possible" or ""))
  UI.show("ap_result")
end

function AP.close()
  UI.hide("cus_attack")
end

CUS.AttackPanel = AP

-- ===== end ui/AttackPanel =====
-- ===== begin ui/MovementPanel =====
-- ui/MovementPanel.lua
-- Compact player-local MOVE HUD: distance used / remaining + Commit/Undo/Cancel
-- and the inline story/obstacle cost hook. Live-updates from move:update events.

CUS = CUS or {}
local Move = CUS.MovementResolver
local MP = {}

MP.guid, MP.player = nil, nil

function MP.open(guid, playerColor)
  MP.guid, MP.player = guid, playerColor
  MP.refresh()
  UI.setAttribute("cus_move", "visibility", playerColor)
  UI.show("cus_move")
end

function MP.refresh()
  if not MP.guid then return end
  local used = Move.usedInches(MP.guid)
  local rem  = Move.remaining(MP.guid)
  UI.setAttribute("mp_dist", "text", ("Used %.1f\"   ·   Remaining %.1f\""):format(used, rem))
end

function MP.close()
  UI.hide("cus_move")
  MP.guid = nil
end

-- wire live updates
if CUS.Bus then
  CUS.Bus.on("move:update", function(p) if p.guid == MP.guid then MP.refresh() end end)
  CUS.Bus.on("move:commit", function(p) if p.guid == MP.guid then MP.close() end end)
  CUS.Bus.on("move:cancel", function(p) if p.guid == MP.guid then MP.close() end end)
end

CUS.MovementPanel = MP

-- ===== end ui/MovementPanel =====
-- ===== begin ui/NervePanel =====
-- ui/NervePanel.lua
-- Configurable/manual Nerve panel. The Codex defines ELIGIBILITY but not a
-- numeric resolver, so this panel explains eligibility, shows the printed Nerve
-- value & current morale, and offers manual Pass/Fail/Shaken/Rally/Rout plus a
-- plugin hook. On Rout it shows the exact Temperament instruction; it never
-- moves the figure.

CUS = CUS or {}
local Store = CUS.StateStore
local Nerve = CUS.NerveResolver
local NP = {}

NP.guid, NP.player = nil, nil

function NP.open(guid, playerColor)
  local def = Store.getDefinition(guid)
  if not def then if CUS.Logger then CUS.Logger.warn("Nerve: no definition.") end return end
  NP.guid, NP.player = guid, playerColor
  local elig = Nerve.eligibility(def)
  local st = Store.getOrInit(guid).state

  UI.setAttribute("np_name", "text", def.name)
  UI.setAttribute("np_elig", "text", elig.reason)
  UI.setAttribute("np_value", "text", ("Printed Nerve: %s   ·   Morale: %s")
    :format(tostring(def.stats and def.stats.nerve), st.morale or "Steady"))
  UI.setAttribute("np_rout_text", "text", "On Rout -> " .. Nerve.routInstruction(def))

  -- disable action buttons when ineligible (Circle/Spirit/Construct never test)
  local interact = elig.eligible and "True" or "False"
  for _, id in ipairs({ "np_pass", "np_fail", "np_shaken", "np_rout" }) do
    UI.setAttribute(id, "interactable", interact)
  end
  UI.setAttribute("cus_nerve", "visibility", playerColor)
  UI.show("cus_nerve")
end

function NP.close() UI.hide("cus_nerve") end

CUS.NervePanel = NP

-- ===== end ui/NervePanel =====
-- ===== begin ui/FormationPanel =====
-- ui/FormationPanel.lua
-- Player-local formation helper. Lets a leader pick a formation, list selected
-- Square companions, Advance (draws the imagined footprint) or Reform. It only
-- assists & visualises; the player places models honestly.

CUS = CUS or {}
local Form  = CUS.FormationAssistant
local Store = CUS.StateStore
local FP = {}

FP.leader, FP.player, FP.selection, FP.formation = nil, nil, {}, "Wedge"

function FP.open(leaderGuid, playerColor)
  FP.leader, FP.player = leaderGuid, playerColor
  FP.selection = {}
  local def = Store.getDefinition(leaderGuid)
  UI.setAttribute("fp_leader", "text", "Leader: " .. (def and def.name or leaderGuid))
  FP.refresh()
  UI.setAttribute("cus_form", "visibility", playerColor)
  UI.show("cus_form")
end

function FP.setFormation(name)
  FP.formation = name
  FP.refresh()
end

-- Add currently-selected miniatures (by the player) as participants.
function FP.addSelection(guids)
  for _, g in ipairs(guids) do
    if not FP.selection[g] then FP.selection[g] = true end
  end
  FP.refresh()
end

function FP.refresh()
  local lib = Form.LIBRARY[FP.formation] or {}
  UI.setAttribute("fp_formation", "text", ("Formation: %s (%s) — %s")
    :format(FP.formation, lib.family or "?", lib.line or ""))
  local n = 0
  for _ in pairs(FP.selection) do n = n + 1 end
  UI.setAttribute("fp_count", "text", ("Participants: %d Square companions"):format(n))
end

function FP.doAdvance()
  local list = {}
  for g in pairs(FP.selection) do list[#list+1] = g end
  local res, reason = Form.beginAdvance(FP.leader, list, FP.formation)
  if not res then
    if CUS.Logger then CUS.Logger.warn("Advance failed: " .. tostring(reason)) end
    return
  end
  if CUS.StatePanel then CUS.StatePanel.refreshAll() end
  FP.close()
end

function FP.doReform()
  Form.reform(FP.leader)
  FP.close()
end

function FP.close() UI.hide("cus_form") end

CUS.FormationPanel = FP

-- ===== end ui/FormationPanel =====
-- ===== begin ui/CardFace =====
-- ui/CardFace.lua
-- Renders a card's stats onto the card OBJECT's UI using the shared layout
-- (CUS.CARD_LAYOUT, decoded from data/card_layout.lua — the same JSON the HTML
-- Card Forge edits). Also drives the in-TTS nudge editor that moves/resizes the
-- zones live and can Export/Import the layout JSON so the two editors stay in
-- sync.
--
-- Coordinates in the layout are NORMALIZED (0..1) over a fixed pixel canvas so
-- the same numbers work in HTML and here. Object-UI placement (rotation/scale/
-- offset of the whole face) is tunable via layout.card.ui_* — first load on a
-- given card shape may need a small calibration (see docs/CARDS.md).

CUS = CUS or {}
local Store = CUS.StateStore
local Face = {}

Face.CANVAS_W = 500
Face.CANVAS_H = 700

-- current editor selection
Face.editGuid = nil
Face.editZone = "name"
Face.player   = nil

-- ---- value resolver: binding key -> display string from a definition -------
local function valueFor(key, def)
  local d = def.display or {}
  local s = def.stats or {}
  local b = def.base or {}
  local map = {
    name   = def.name,
    role   = def.role,
    tool   = def.tool,
    temper = def.temperament,
    base   = d.base ~= "" and d.base or ((b.shape or "") .. " / " .. (b.class or "")),
    dice   = d.dice ~= 0 and tostring(d.dice) or "",
    hit    = d.hit,
    wounds = tostring(s.max_wounds),
    armour = d.armour ~= "" and d.armour or (s.armour or ""),
    speed  = tostring(s.speed),
    ap     = tostring(s.max_ap),
    nerve  = (s.nerve and s.nerve > 0) and tostring(s.nerve) or "—",
    rank   = s.rank,
    weapon = d.weapon,
    tiers  = d.tiers,
    note   = d.note,
  }
  local v = map[key]
  if v == nil then v = "" end
  return tostring(v)
end

local ALIGN = { left = "UpperLeft", center = "UpperCenter", right = "UpperRight" }

-- Escape text so it is safe inside a TTS UI XML attribute.
local function xmlEscape(s)
  s = tostring(s or "")
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
       :gsub('"', "&quot;"):gsub("'", "&apos;")
  return s
end

-- Build the object-UI XML for a card face from the layout + definition.
local function buildFaceXml(def, highlightZone)
  local L = CUS.CARD_LAYOUT
  local card = L.card or {}
  local W, H = Face.CANVAS_W, Face.CANVAS_H
  local children = {}

  for key, z in pairs(L.zones or {}) do
    if z.show ~= false then
      local text = (z.label or "") .. valueFor(key, def)
      local px = z.x * W
      local py = z.y * H
      local pw = z.w * W
      local ph = z.h * H
      local fs = math.max(6, math.floor(z.size * H))
      local col = (key == highlightZone) and "#ffcf5a" or (card.fg or "#e8f0ff")
      -- UpperLeft anchor: +x right, +y DOWN needs negative offset y in TTS UI.
      children[#children+1] = string.format(
        '<Text text="%s" rectAlignment="%s" width="%d" height="%d" offsetXY="%d %d" '
        .. 'fontSize="%d" color="%s" alignment="%s" resizeTextForBestFit="false"/>',
        xmlEscape(text), "UpperLeft", math.floor(pw), math.floor(ph),
        math.floor(px), -math.floor(py), fs, col, ALIGN[z.align] or "UpperLeft")
    end
  end

  local rot   = card.ui_rotation or "90 0 0"
  local scale = card.ui_scale or "0.25 0.25 1"
  local pos   = card.ui_position or "0 3 0"
  return string.format(
    '<Panel width="%d" height="%d" position="%s" rotation="%s" scale="%s" color="%s">%s</Panel>',
    W, H, pos, rot, scale, card.bg or "#141821", table.concat(children, ""))
end

-- Render (or clear) a card's face.
function Face.render(cardGuid, highlightZone)
  local card = getObjectFromGUID(cardGuid)
  if not card then return end
  local ok, def = pcall(function() return card.call("getDefinition") end)
  if not ok or type(def) ~= "table" then
    pcall(function() card.UI.setXml("") end)
    return
  end
  pcall(function() card.UI.setXml(buildFaceXml(def, highlightZone)) end)
end

-- Render a card face for the card linked to a miniature (convenience).
function Face.renderForMini(miniGuid)
  local rs = Store.get(miniGuid)
  if rs and rs.card_guid then Face.render(rs.card_guid) end
end

-- Re-render every known CUS card (after a layout change).
function Face.renderAll()
  for _, obj in ipairs(getAllObjects()) do
    if obj.getVar and obj.getVar("CUS_CARD") ~= nil then Face.render(obj.getGUID()) end
  end
end

-- ---- nudge editor ----------------------------------------------------------
Face.ZONE_ORDER = { "name","role","tool","base","temper","dice","hit","wounds",
                    "armour","speed","ap","nerve","rank","weapon","tiers","note" }

function Face.openEditor(cardGuid, playerColor)
  Face.editGuid = cardGuid
  Face.player = playerColor
  Face.editZone = Face.editZone or "name"
  Face.refreshEditor()
  UI.setAttribute("cus_layout", "visibility", playerColor)
  UI.show("cus_layout")
  Face.render(cardGuid, Face.editZone)
end

function Face.refreshEditor()
  local z = CUS.CARD_LAYOUT.zones[Face.editZone] or {}
  UI.setAttribute("cl_zone", "text", "Zone: " .. Face.editZone)
  UI.setAttribute("cl_info", "text", string.format(
    "x %.3f  y %.3f   w %.3f  h %.3f   size %.3f   %s   %s",
    z.x or 0, z.y or 0, z.w or 0, z.h or 0, z.size or 0, z.align or "left",
    (z.show == false) and "HIDDEN" or "shown"))
end

function Face.cycleZone(dir)
  local idx = 1
  for i, k in ipairs(Face.ZONE_ORDER) do if k == Face.editZone then idx = i end end
  idx = ((idx - 1 + dir) % #Face.ZONE_ORDER) + 1
  Face.editZone = Face.ZONE_ORDER[idx]
  Face.refreshEditor()
  if Face.editGuid then Face.render(Face.editGuid, Face.editZone) end
end

-- adjust a property of the selected zone (dx/dy/dw/dh/dsize) and re-render
function Face.adjust(prop, delta)
  local z = CUS.CARD_LAYOUT.zones[Face.editZone]
  if not z then return end
  z[prop] = math.max(0, (z[prop] or 0) + delta)
  Face.refreshEditor()
  if Face.editGuid then Face.render(Face.editGuid, Face.editZone) end
end

function Face.cycleAlign()
  local z = CUS.CARD_LAYOUT.zones[Face.editZone]; if not z then return end
  local order = { left = "center", center = "right", right = "left" }
  z.align = order[z.align or "left"] or "left"
  Face.refreshEditor()
  if Face.editGuid then Face.render(Face.editGuid, Face.editZone) end
end

function Face.toggleShow()
  local z = CUS.CARD_LAYOUT.zones[Face.editZone]; if not z then return end
  z.show = not (z.show ~= false)
  Face.refreshEditor()
  if Face.editGuid then Face.render(Face.editGuid, Face.editZone) end
end

-- Export the current layout as JSON (printed to host console for paste-back).
function Face.exportJSON()
  local json = JSON.encode_pretty({ card = CUS.CARD_LAYOUT.card, zones = CUS.CARD_LAYOUT.zones })
  print("[CUS card_layout.json]\n" .. json)
  if CUS.Logger then CUS.Logger.log("Layout JSON printed to host console (~). Paste it into card_layout.json / the HTML forge.") end
  return json
end

-- Import a pasted layout JSON string.
function Face.importJSON(str)
  local ok, decoded = pcall(function() return JSON.decode(str) end)
  if not ok or type(decoded) ~= "table" or type(decoded.zones) ~= "table" then
    if CUS.Logger then CUS.Logger.warn("Import failed: not valid layout JSON.") end
    return
  end
  CUS.CARD_LAYOUT = decoded
  Face.refreshEditor()
  Face.renderAll()
  if CUS.Logger then CUS.Logger.log("Layout imported and applied to all cards.") end
end

function Face.closeEditor()
  UI.hide("cus_layout")
  if Face.editGuid then Face.render(Face.editGuid) end   -- drop highlight
end

CUS.CardFace = Face

-- ===== end ui/CardFace =====
-- ===== begin ui/UnitLibrary =====
-- ui/UnitLibrary.lua
-- Browse the whole unit catalog (all factions) and stamp a chosen unit onto a
-- card with one click — "click the card and it takes all its stats." The card
-- becomes the authoritative definition object for that unit; the miniature
-- linked to it then reads those stats normally.
--
-- Catalog shape (built in Global from data/unit_library.lua):
--   CUS.UNIT_LIBRARY = {
--     factions = { { faction="Sauron", prefix="SAU", units={ {def}, ... } }, ... },
--     byId     = { SAU_TROLL = {def}, ... }
--   }

CUS = CUS or {}
local Lib = {}
Lib.player, Lib.faction, Lib.targetCard = nil, nil, nil

local function factions() return (CUS.UNIT_LIBRARY and CUS.UNIT_LIBRARY.factions) or {} end

local SLOTS = 20                                  -- must match lib_r1..lib_r20 in Global.xml
local function fill(rows) CUS.UIList.fill("lib_r", SLOTS, rows) end

-- A small popup with two steps: pick a faction, then tap a unit. One list is
-- reused for both, so the panel stays the same size either way.
Lib.mode = "factions"

function Lib.open(playerColor, targetCardGuid)
  Lib.player = playerColor
  Lib.targetCard = targetCardGuid            -- may be nil; resolved at apply time
  Lib.showFactions()
  UI.setAttribute("cus_lib", "visibility", playerColor)
  UI.show("cus_lib")
end

function Lib.showFactions()
  Lib.mode = "factions"
  local rows = {}
  for _, f in ipairs(factions()) do
    local n = #(f.units or {})
    rows[#rows+1] = {
      text = ("%s   (%d)"):format(f.faction, n),
      onClick = "libFaction(" .. f.faction .. ")",
    }
  end
  if #rows == 0 then
    rows[1] = { kind = "header", text = "No factions loaded. Check the console for a unit-library parse warning." }
  end
  fill(rows)
  UI.setAttribute("lib_title", "text", "Unit Library")
  UI.setAttribute("lib_hint",  "text", "Pick a faction.")
  UI.setAttribute("lib_back",  "active", "false")
end

function Lib.currentFaction()
  for _, f in ipairs(factions()) do if f.faction == Lib.faction then return f end end
  return nil
end

-- Retired: the old two-column layout had a separate faction tab strip.
function Lib.buildFactionTabs() Lib.showFactions() end

function Lib.buildUnitList()
  Lib.mode = "units"
  local f = Lib.currentFaction()
  local rows = {}
  if f then
    for _, u in ipairs(f.units or {}) do
      local b = u.base or {}
      -- v0.6: mounted is GEOMETRY (an elongated base), not a class; Monstrous
      -- is gone — a monster is a Large figure carrying the unstoppable trait.
      -- Old cards still say Cavalry/Monstrous, so both spellings are read.
      local tag = ""
      if b.mounted or b.class == "Cavalry" then tag = "  [mtd]"
      elseif b.class == "Large" or b.class == "Monstrous" then tag = "  [Lg]" end

      -- ASCII only. TTS's UI font has no emoji glyphs, and non-ASCII here is
      -- what the build-script encoding bug used to mangle.
      local cls = CUS.Constants.migrateClass(b.class or "")
      rows[#rows+1] = {
        text = string.format("%s  -  %s %s%s",
          tostring(u.name), tostring(u.role or "?"), cls, tag),
        onClick = "libApply(" .. u.definition_id .. ")",
        tooltip = (u.display and u.display.weapon or "") .. "  " ..
                  (u.display and (u.display.grades or u.display.tiers) or ""),
      }
    end
  end
  if #rows == 0 then rows[1] = { kind = "header", text = "No units in this faction." } end
  fill(rows)
  UI.setAttribute("lib_title", "text", tostring(Lib.faction or "?"))
  UI.setAttribute("lib_hint",  "text", "Select a card, then tap a unit to stamp it.")
  UI.setAttribute("lib_back",  "active", "true")
end

function Lib.setFaction(name)
  Lib.faction = name
  Lib.buildUnitList()
end

-- Back to the faction list.
function Lib.back() Lib.showFactions() end

-- Resolve which card to stamp: explicit target, else the player's selected card,
-- else the card currently open in the layout editor.
local function resolveTargetCard(playerColor)
  if Lib.targetCard and getObjectFromGUID(Lib.targetCard) then return Lib.targetCard end
  local pl = Player[playerColor]
  for _, o in ipairs(pl and pl.getSelectedObjects() or {}) do
    if o.getVar and o.getVar("CUS_CARD") ~= nil then return o.getGUID() end
  end
  if CUS.CardFace and CUS.CardFace.editGuid then return CUS.CardFace.editGuid end
  return nil
end

function Lib.apply(defId, playerColor)
  local def = CUS.UNIT_LIBRARY and CUS.UNIT_LIBRARY.byId and CUS.UNIT_LIBRARY.byId[defId]
  if not def then if CUS.Logger then CUS.Logger.warn("Unknown unit: " .. tostring(defId)) end return end
  local cardGuid = resolveTargetCard(playerColor)
  if not cardGuid then
    if CUS.Logger then CUS.Logger.warn("Select a CUS card first (left-click it), then pick a unit.") end
    return
  end
  local card = getObjectFromGUID(cardGuid)
  -- deep copy so each card owns its own definition instance
  local copy = CUS.Undo and CUS.Undo.deepcopy(def) or def
  local res = card.call("setDefinition", copy)
  card.setName(def.name)
  if CUS.CardFace then CUS.CardFace.render(cardGuid) end
  card.highlightOn({ 0.6, 1, 0.6 }, 3)
  if CUS.Logger then CUS.Logger.log(("Stamped '%s' (%s) onto card %s."):format(def.name, def.definition_id, cardGuid)) end
  -- if a miniature is already linked to this card, refresh its panels
  for guid, rs in pairs(CUS.StateStore.runtime) do
    if rs.card_guid == cardGuid then
      rs.expected_definition_id = def.definition_id
      CUS.pushRuntimeToMini(guid)
    end
  end
end

function Lib.close() UI.hide("cus_lib") end

CUS.UnitLibrary = Lib

-- ===== end ui/UnitLibrary =====

-- Embedded sample data (kept inline so the mod boots with a fixture even before
-- you paste your own). The same JSON also ships in /data for external editing.
-- ===== begin data/sample_packets =====
-- data/sample_packets.lua
-- Embedded packet fixture (mirrors data/sample_packets.json). Loaded at boot so
-- the mod runs without external files. Weapons follow the Codex reference Tiers.
CUS = CUS or {}
CUS.SAMPLE_PACKETS = {
  attack_packets = {
    { id = "ATK_SWORD_01", alias = "Sword", parent_action = "ATTACK", dice = 3, hit = 3, range = 0, cost_ap = 1,
      tags = { "Melee" }, tiers = { { successes = 1, wounds = 1, effects = {} }, { successes = 3, wounds = 1, effects = { "Guard" } } } },
    { id = "ATK_DAGGER_01", alias = "Dagger", parent_action = "ATTACK", dice = 2, hit = 2, range = 0, cost_ap = 1,
      tags = { "Melee" }, tiers = { { successes = 1, wounds = 1, effects = {} }, { successes = 2, wounds = 1, effects = { "ignore Armour" } } } },
    { id = "ATK_SPEAR_01", alias = "Spear", parent_action = "ATTACK", dice = 2, hit = 4, range = 0, cost_ap = 1,
      tags = { "Melee", "Reach" }, tiers = { { successes = 1, wounds = 1, effects = {} }, { successes = 2, wounds = 1, effects = { "Push" } } } },
    { id = "ATK_GREATAXE_01", alias = "Greataxe", parent_action = "ATTACK", dice = 3, hit = 5, range = 0, cost_ap = 1,
      tags = { "Melee" }, tiers = { { successes = 1, wounds = 1, effects = {} }, { successes = 2, wounds = 2, effects = {} }, { successes = 3, wounds = 2, effects = { "Cleave" } } } },
    { id = "ATK_ASSASSIN_01", alias = "Assassin Blade", parent_action = "ATTACK", dice = 3, hit = 3, range = 0, cost_ap = 1,
      tags = { "Melee" }, tiers = { { successes = 1, wounds = 1, effects = {} }, { successes = 3, wounds = 2, effects = {} }, { successes = 5, wounds = 2, effects = { "Execute" } } } },
    { id = "ATK_BOW_01", alias = "Bow", parent_action = "ATTACK", dice = 2, hit = 4, range = 18, cost_ap = 1,
      tags = { "Ranged", "never countered" }, tiers = { { successes = 1, wounds = 1, effects = {} }, { successes = 3, wounds = 2, effects = {} } } },
    { id = "ATK_CROSSBOW_01", alias = "Crossbow", parent_action = "ATTACK", dice = 2, hit = 3, range = 24, cost_ap = 1,
      tags = { "Ranged", "no Multi-Shot", "never countered" }, tiers = { { successes = 1, wounds = 1, effects = {} }, { successes = 2, wounds = 2, effects = {} } } },
  },
  ability_packets = {
    { id = "ABIL_GUARD_01", alias = "Guard", type = "Reactive", parent_action = "READY",
      trigger = "Defined by packet", condition = "Defined by packet", resolution = "Defined by packet", tags = {} },
    { id = "ABIL_OVERWATCH_01", alias = "Overwatch", type = "Reactive", parent_action = "READY",
      trigger = "Enemy enters LoS in range", condition = "Player confirms", resolution = "Resolve a Regular Shot", tags = { "Ranged" } },
    { id = "ABIL_BRACE_01", alias = "Brace", type = "Reactive", parent_action = "READY",
      trigger = "Charged / struck", condition = "Player confirms", resolution = "Defined by packet", tags = {} },
    { id = "ABIL_HEAL_01", alias = "Field Dressing", type = "Active", parent_action = "USE",
      note = "Restore 1 Wound to an adjacent ally (per packet).", tags = {} },
    { id = "ABIL_REACH_PASSIVE", alias = "Reach", type = "Passive", parent_action = nil,
      note = "Threatens its band; no lock, no Counter suffered.", tags = {} },
  },
}

-- ===== end data/sample_packets =====
-- ===== begin data/sample_units =====
-- data/sample_units.lua
-- Embedded unit-definition fixture (mirrors data/sample_units.json). These are
-- what you paste into a card's GM Notes (or spawn via the test fixture). Cards
-- own the DEFINITION; miniatures own runtime state.
CUS = CUS or {}
CUS.SAMPLE_UNITS = {
  {
    schema_version = 1, definition_id = "MIL_SWORD_01", name = "Militia Swordsman",
    role = "Assault", tool = "Melee", creature_type = "Man", archetype = "Swordsman", signature = "Shield Drill",
    stats = { max_wounds = 2, armour = "Medium", speed = 6, max_ap = 2, nerve = 3, rank = "I" },
    base = { shape = "Square", class = "Normal", mounted = false, forward_axis = "local_z" },
    attack_packet_ids = { "ATK_SWORD_01" }, ability_packet_ids = { "ABIL_GUARD_01" },
    temperament = "Resolute",
    display = { card_image_url = "", weapon = "Sword", dice = 3, hit = "3+", tiers = "1→1W · 3→Guard",
                armour = "5+", base = "Square / Normal", note = "" },
  },
  {
    schema_version = 1, definition_id = "MIL_SPEAR_01", name = "Militia Spearman",
    role = "Anchor", tool = "Melee", creature_type = "Man", archetype = "Spearman", signature = "Brace",
    stats = { max_wounds = 2, armour = "Light", speed = 6, max_ap = 2, nerve = 3, rank = "I" },
    base = { shape = "Square", class = "Normal", mounted = false, forward_axis = "local_z" },
    attack_packet_ids = { "ATK_SPEAR_01" }, ability_packet_ids = { "ABIL_BRACE_01", "ABIL_REACH_PASSIVE" },
    temperament = "Resolute",
    display = { card_image_url = "", weapon = "Spear (Reach)", dice = 2, hit = "4+", tiers = "1→1W · 2→Push",
                armour = "6+", base = "Square / Normal", note = "Reach: no lock, no Counter suffered." },
  },
  {
    schema_version = 1, definition_id = "GOB_ARCHER_01", name = "Goblin Archer",
    role = "Skirmisher", tool = "Ranged", creature_type = "Man", archetype = "Archer", signature = "Skulk",
    stats = { max_wounds = 1, armour = "None", speed = 7, max_ap = 2, nerve = 2, rank = "I" },
    base = { shape = "Square", class = "Small", mounted = false, forward_axis = "local_z" },
    attack_packet_ids = { "ATK_BOW_01" }, ability_packet_ids = { "ABIL_OVERWATCH_01" },
    temperament = "Cowardly",
    display = { card_image_url = "", weapon = "Bow", dice = 2, hit = "4+", tiers = "1→1W · 3→2W",
                armour = "—", base = "Square / Small", note = "Never countered." },
  },
  {
    schema_version = 1, definition_id = "GOB_BOSS_01", name = "Goblin Warboss",
    role = "Assault", tool = "Melee", creature_type = "Man", archetype = "Berserker", signature = "Reckless",
    counter_uses = 2,
    stats = { max_wounds = 3, armour = "Light", speed = 6, max_ap = 3, nerve = 4, rank = "III" },
    base = { shape = "Circle", class = "Large", mounted = false, forward_axis = "local_z" },
    attack_packet_ids = { "ATK_GREATAXE_01" }, ability_packet_ids = {},
    temperament = "Aggressive",
    display = { card_image_url = "", weapon = "Greataxe", dice = 3, hit = "5+", tiers = "1→1W · 2→2W · 3→Cleave",
                armour = "6+", base = "Circle / Large", note = "Circle hero — never tests Nerve. Counter 2." },
  },
  {
    schema_version = 1, definition_id = "CHAMP_ASSN_01", name = "Shadowblade Champion",
    role = "Skirmisher", tool = "Melee", creature_type = "Man", archetype = "Assassin", signature = "Backstab",
    stats = { max_wounds = 2, armour = "None", speed = 8, max_ap = 3, nerve = 5, rank = "III" },
    base = { shape = "Circle", class = "Normal", mounted = false, forward_axis = "local_z" },
    attack_packet_ids = { "ATK_ASSASSIN_01", "ATK_DAGGER_01" }, ability_packet_ids = { "ABIL_HEAL_01" },
    temperament = "Aggressive",
    display = { card_image_url = "", weapon = "Assassin Blade", dice = 3, hit = "3+", tiers = "1→1W · 3→2W · 5→Execute",
                armour = "—", base = "Circle / Normal", note = "Champion (3 AP). Circle hero." },
  },
  {
    schema_version = 1, definition_id = "SKEL_CON_01", name = "Bone Construct",
    role = "Anchor", tool = "Melee", creature_type = "Construct", archetype = "Sentinel", signature = "Tireless",
    stats = { max_wounds = 2, armour = "Heavy", speed = 5, max_ap = 2, nerve = 0, rank = "I" },
    base = { shape = "Square", class = "Normal", mounted = false, forward_axis = "local_z" },
    attack_packet_ids = { "ATK_SWORD_01" }, ability_packet_ids = {},
    temperament = "Resolute",
    display = { card_image_url = "", weapon = "Sword", dice = 3, hit = "3+", tiers = "1→1W · 3→Guard",
                armour = "4+", base = "Square / Normal", note = "Construct — never tests Nerve." },
  },
}

-- ===== end data/sample_units =====
-- ===== begin data/card_layout =====
-- data/card_layout.lua
-- The DEFAULT card layout for the mod, stored as the SAME JSON text the HTML
-- Card Forge uses (single source of truth). Global decodes it into
-- CUS.CARD_LAYOUT at load. Editing zones in-game (nudge editor) mutates the
-- decoded table; Export prints JSON you can paste back into card_layout.json /
-- the HTML forge, and Import accepts pasted JSON. Keep this in sync with
-- data/card_layout.json (build/bundle.ps1 does not auto-sync these two).
CUS = CUS or {}
CUS.CARD_LAYOUT_JSON = [==[
{
  "card": { "aspect_w": 5, "aspect_h": 7, "bg": "#141821", "fg": "#e8f0ff", "accent": "#8fd0ff" },
  "zones": {
    "name":   { "x": 0.06, "y": 0.035, "w": 0.88, "h": 0.10, "size": 0.070, "align": "left",   "label": "",      "show": true },
    "role":   { "x": 0.06, "y": 0.140, "w": 0.44, "h": 0.045, "size": 0.034, "align": "left",   "label": "",      "show": true },
    "tool":   { "x": 0.06, "y": 0.185, "w": 0.44, "h": 0.040, "size": 0.030, "align": "left",   "label": "",      "show": true },
    "base":   { "x": 0.50, "y": 0.140, "w": 0.44, "h": 0.045, "size": 0.032, "align": "right",  "label": "",      "show": true },
    "temper": { "x": 0.50, "y": 0.185, "w": 0.44, "h": 0.040, "size": 0.030, "align": "right",  "label": "",      "show": true },
    "dice":   { "x": 0.06, "y": 0.600, "w": 0.21, "h": 0.070, "size": 0.045, "align": "center", "label": "DICE ", "show": true },
    "hit":    { "x": 0.29, "y": 0.600, "w": 0.19, "h": 0.070, "size": 0.045, "align": "center", "label": "HIT ",  "show": true },
    "wounds": { "x": 0.50, "y": 0.600, "w": 0.19, "h": 0.070, "size": 0.045, "align": "center", "label": "W ",    "show": true },
    "armour": { "x": 0.71, "y": 0.600, "w": 0.23, "h": 0.070, "size": 0.045, "align": "center", "label": "ARM ",  "show": true },
    "speed":  { "x": 0.06, "y": 0.680, "w": 0.21, "h": 0.060, "size": 0.038, "align": "center", "label": "SPD ",  "show": true },
    "ap":     { "x": 0.29, "y": 0.680, "w": 0.19, "h": 0.060, "size": 0.038, "align": "center", "label": "AP ",   "show": true },
    "nerve":  { "x": 0.50, "y": 0.680, "w": 0.19, "h": 0.060, "size": 0.038, "align": "center", "label": "NRV ",  "show": true },
    "rank":   { "x": 0.71, "y": 0.680, "w": 0.23, "h": 0.060, "size": 0.038, "align": "center", "label": "RANK ", "show": true },
    "weapon": { "x": 0.06, "y": 0.770, "w": 0.88, "h": 0.050, "size": 0.040, "align": "left",   "label": "",      "show": true },
    "tiers":  { "x": 0.06, "y": 0.825, "w": 0.88, "h": 0.060, "size": 0.032, "align": "left",   "label": "",      "show": true },
    "note":   { "x": 0.06, "y": 0.895, "w": 0.88, "h": 0.085, "size": 0.028, "align": "left",   "label": "",      "show": true }
  }
}
]==]

-- ===== end data/card_layout =====
-- ===== begin data/unit_library =====
-- data/unit_library.lua  (GENERATED by build/assemble_library.ps1 - do not hand-edit)
-- Full 5-faction unit catalog as a JSON string the mod decodes into CUS.UNIT_LIBRARY.
CUS = CUS or {}
CUS.UNIT_LIBRARY_JSON = [==[
[{"faction":"Militia","prefix":"MIL","attack_packets":[{"id":"ATK_MIL_CAPTAIN","alias":"Arming Sword","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":1,"effects":["Guard"]}]},{"id":"ATK_MIL_MILITIAMAN","alias":"Spear or Blade","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Guard"]}]},{"id":"ATK_MIL_LEVY","alias":"Pitchfork","parent_action":"ATTACK","dice":2,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee","Reach","never countered"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Push"]}]},{"id":"ATK_MIL_GUARD","alias":"Short Sword","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":1,"effects":["Guard"]}]},{"id":"ATK_MIL_EXECUTIONER","alias":"Headsman\u0027s Axe","parent_action":"ATTACK","dice":3,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":2,"effects":["Execute"]}]},{"id":"ATK_MIL_HUNTER","alias":"Hunting Bow","parent_action":"ATTACK","dice":2,"hit":4,"range":18,"area":null,"cost_ap":1,"tags":["Ranged","never countered"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":2,"effects":[]}]},{"id":"ATK_MIL_SCOUT_BOW","alias":"Shortbow","parent_action":"ATTACK","dice":2,"hit":4,"range":15,"area":null,"cost_ap":1,"tags":["Ranged","never countered"],"tiers":[{"successes":1,"wounds":1,"effects":[]}]},{"id":"ATK_MIL_SCOUT_KNIFE","alias":"Knife","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]}]},{"id":"ATK_MIL_POACHER","alias":"Snare \u0026 Knife","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":2,"effects":[]},{"successes":5,"wounds":2,"effects":["Execute"]}]},{"id":"ATK_MIL_PRIEST","alias":"Cudgel","parent_action":"ATTACK","dice":2,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]}]},{"id":"ATK_MIL_WIZARD","alias":"Hex Bolt","parent_action":"ATTACK","dice":2,"hit":4,"range":12,"area":null,"cost_ap":1,"tags":["Ranged"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]}]},{"id":"ATK_MIL_WARDOG","alias":"Bite","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Knockdown"]}]},{"id":"ATK_MIL_GOLEM","alias":"Timber \u0026 Iron","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":2,"effects":["Knockdown","Push"]}]},{"id":"ATK_MIL_SERGEANT","alias":"Cavalry Lance","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Push"]},{"successes":3,"wounds":2,"effects":["Knockdown"]}]},{"id":"ATK_MIL_OUTRIDER","alias":"Mounted Bow","parent_action":"ATTACK","dice":2,"hit":4,"range":15,"area":null,"cost_ap":1,"tags":["Ranged","never countered"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":2,"effects":[]}]},{"id":"ATK_MIL_SENTINEL","alias":"Stone Fists","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":3,"effects":["Knockdown"]}]}],"ability_packets":[{"id":"ABIL_MIL_CAPTAIN_1","alias":"Rally Aura","type":"Passive","parent_action":null,"note":"Militia within 6\" stop routing and may re-roll one failed Nerve test per round.","tags":[]},{"id":"ABIL_MIL_MILITIAMAN_1","alias":"Shoulder to Shoulder","type":"Passive","parent_action":null,"note":"+1 Nerve per adjacent Militiaman (cap +2); +1 die while at least two Militia are within 3\".","tags":[]},{"id":"ABIL_MIL_LEVY_1","alias":"Levy","type":"Passive","parent_action":null,"note":"Stabs safely from the second rank via Reach and suffers no Counter.","tags":[]},{"id":"ABIL_MIL_GUARD_1","alias":"Bulwark","type":"Passive","parent_action":null,"note":"Attackers roll one fewer die against this figure.","tags":[]},{"id":"ABIL_MIL_GUARD_2","alias":"Interpose","type":"Reactive","parent_action":"READY","note":"READY to interpose and take a wound aimed at an adjacent Militia.","tags":[]},{"id":"ABIL_MIL_HUNTER_1","alias":"Poacher\u0027s Eye","type":"Active","parent_action":"ATTACK","note":"Precision Shot gains +1 die and ignores Cover.","tags":[]},{"id":"ABIL_MIL_SCOUT_1","alias":"Fast \u0026 Free","type":"Passive","parent_action":null,"note":"Sprint 16\" and Disengage for free.","tags":[]},{"id":"ABIL_MIL_SCOUT_2","alias":"Carry the Word","type":"Active","parent_action":"USE","note":"Once per game, re-activate one friendly Order.","tags":[]},{"id":"ABIL_MIL_POACHER_1","alias":"From the Hedgerow","type":"Passive","parent_action":null,"note":"+2 dice from cover or the rear; Snare stops the target Disengaging next turn.","tags":[]},{"id":"ABIL_MIL_PRIEST_1","alias":"Heal","type":"Active","parent_action":"USE","note":"Twice per game, remove 1W or stand a Knockdown within 6\".","tags":[]},{"id":"ABIL_MIL_PRIEST_2","alias":"Bless","type":"Active","parent_action":"USE","note":"A chosen Militia auto-passes its next Nerve test.","tags":[]},{"id":"ABIL_MIL_PRIEST_3","alias":"Sermon Aura","type":"Passive","parent_action":null,"note":"Militia within 6\" gain +1 Nerve while the Priest lives.","tags":[]},{"id":"ABIL_MIL_WIZARD_1","alias":"Mud \u0026 Mist","type":"Active","parent_action":"USE","note":"Conjure a patch of difficult terrain or cover.","tags":[]},{"id":"ABIL_MIL_WARDOG_1","alias":"Loyal","type":"Passive","parent_action":null,"note":"Sprint 12\"; will not rout while the Captain is within 6\".","tags":[]},{"id":"ABIL_MIL_GOLEM_1","alias":"Immovable","type":"Passive","parent_action":null,"note":"Blocks line of sight; unbreakable and cannot be pushed or moved.","tags":[]},{"id":"ABIL_MIL_SERGEANT_1","alias":"Lance Charge","type":"Active","parent_action":"MOVE","note":"Plows a class up and gains +1 die on the turn it Charges.","tags":[]},{"id":"ABIL_MIL_OUTRIDER_1","alias":"Hit \u0026 Run","type":"Passive","parent_action":null,"note":"Sprint 18\"; free Disengage; +1 die when it Charges.","tags":[]},{"id":"ABIL_MIL_SENTINEL_1","alias":"Bulwark","type":"Passive","parent_action":null,"note":"Blocks line of sight; unbreakable and cannot be pushed or moved.","tags":[]}],"units":[{"schema_version":1,"definition_id":"MIL_CAPTAIN","name":"Village Captain","role":"Support","tool":"Melee","creature_type":"Man","archetype":"Captain","signature":"Rally","counter_uses":1,"stats":{"max_wounds":3,"armour":"Medium","speed":6,"max_ap":3,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_CAPTAIN"],"ability_packet_ids":["ABIL_MIL_CAPTAIN_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Arming Sword","dice":3,"hit":"4+","tiers":"1-\u003e1W · 3-\u003eGuard","armour":"5+","base":"Circle / Normal","note":"Morale keystone; rally aura."}},{"schema_version":1,"definition_id":"MIL_MILITIAMAN","name":"Militiaman","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Spearman","signature":"Cohesion","stats":{"max_wounds":2,"armour":"Light","speed":6,"max_ap":2,"nerve":2,"rank":"I"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_MILITIAMAN"],"ability_packet_ids":["ABIL_MIL_MILITIAMAN_1"],"temperament":"Cowardly","display":{"card_image_url":"","weapon":"Spear or Blade","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003eGuard","armour":"6+","base":"Square / Normal","note":"Weak alone, stubborn in a block."}},{"schema_version":1,"definition_id":"MIL_LEVY","name":"Pitchfork Levy","role":"Anchor","tool":"Melee","creature_type":"Man","archetype":"Levy","signature":"Green","stats":{"max_wounds":2,"armour":"None","speed":6,"max_ap":2,"nerve":1,"rank":"I"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_LEVY"],"ability_packet_ids":["ABIL_MIL_LEVY_1"],"temperament":"Cowardly","display":{"card_image_url":"","weapon":"Pitchfork","dice":2,"hit":"5+","tiers":"1-\u003e1W · 2-\u003ePush","armour":"—","base":"Square / Normal","note":"Reach 2\"; first to break."}},{"schema_version":1,"definition_id":"MIL_GUARD","name":"Tower Shield Guard","role":"Anchor","tool":"Melee","creature_type":"Man","archetype":"Shieldbearer","signature":"Bulwark","stats":{"max_wounds":2,"armour":"Heavy","speed":5,"max_ap":2,"nerve":3,"rank":"II"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_GUARD"],"ability_packet_ids":["ABIL_MIL_GUARD_1","ABIL_MIL_GUARD_2"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Short Sword","dice":2,"hit":"4+","tiers":"1-\u003e1W · 3-\u003eGuard","armour":"4+","base":"Square / Normal","note":"Bulwark; the line\u0027s backbone."}},{"schema_version":1,"definition_id":"MIL_EXECUTIONER","name":"Executioner","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Headsman","signature":"Execute","stats":{"max_wounds":2,"armour":"Light","speed":5,"max_ap":2,"nerve":2,"rank":"II"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_EXECUTIONER"],"ability_packet_ids":[],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Headsman\u0027s Axe","dice":3,"hit":"5+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003eExecute","armour":"6+","base":"Square / Normal","note":"Terrifying top rung, but Hit 5+."}},{"schema_version":1,"definition_id":"MIL_HUNTER","name":"Hunter","role":"Skirmisher","tool":"Ranged","creature_type":"Man","archetype":"Bowman","signature":"Precision","stats":{"max_wounds":2,"armour":"Light","speed":6,"max_ap":2,"nerve":2,"rank":"II"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_HUNTER"],"ability_packet_ids":["ABIL_MIL_HUNTER_1"],"temperament":"Cowardly","display":{"card_image_url":"","weapon":"Hunting Bow","dice":2,"hit":"4+","tiers":"1-\u003e1W · 3-\u003e2W","armour":"6+","base":"Square / Normal","note":"Range 18\"; Precision kiting brake."}},{"schema_version":1,"definition_id":"MIL_SCOUT","name":"Scout","role":"Skirmisher","tool":"Ranged","creature_type":"Man","archetype":"Scout","signature":"Swift","stats":{"max_wounds":2,"armour":"Light","speed":8,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_SCOUT_BOW","ATK_MIL_SCOUT_KNIFE"],"ability_packet_ids":["ABIL_MIL_SCOUT_1","ABIL_MIL_SCOUT_2"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Shortbow / Knife","dice":2,"hit":"4+","tiers":"1-\u003e1W","armour":"6+","base":"Circle / Normal","note":"Sprint 16\"; free Disengage."}},{"schema_version":1,"definition_id":"MIL_POACHER","name":"Poacher","role":"Skirmisher","tool":"Melee","creature_type":"Man","archetype":"Poacher","signature":"Ambush","stats":{"max_wounds":2,"armour":"Light","speed":7,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_POACHER"],"ability_packet_ids":["ABIL_MIL_POACHER_1"],"temperament":"Cowardly","display":{"card_image_url":"","weapon":"Snare \u0026 Knife","dice":3,"hit":"4+","tiers":"1-\u003e1W · 3-\u003e2W · 5-\u003eExecute","armour":"6+","base":"Circle / Normal","note":"An ordinary man who hunts men."}},{"schema_version":1,"definition_id":"MIL_PRIEST","name":"Priest","role":"Support","tool":"Utility","creature_type":"Man","archetype":"Priest","signature":"Faith","stats":{"max_wounds":2,"armour":"Light","speed":6,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_PRIEST"],"ability_packet_ids":["ABIL_MIL_PRIEST_1","ABIL_MIL_PRIEST_2","ABIL_MIL_PRIEST_3"],"temperament":"Protective","display":{"card_image_url":"","weapon":"Cudgel","dice":2,"hit":"5+","tiers":"1-\u003e1W","armour":"6+","base":"Circle / Normal","note":"Heal, Bless, faith aura; key target."}},{"schema_version":1,"definition_id":"MIL_WIZARD","name":"Hedge Wizard","role":"Control","tool":"Utility","creature_type":"Man","archetype":"Hedge Wizard","signature":"Terrain","stats":{"max_wounds":2,"armour":"None","speed":6,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_WIZARD"],"ability_packet_ids":["ABIL_MIL_WIZARD_1"],"temperament":"Cowardly","display":{"card_image_url":"","weapon":"Hex Bolt","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003e2W","armour":"—","base":"Circle / Normal","note":"Range 12\"; terrain-shaping support."}},{"schema_version":1,"definition_id":"MIL_WARDOG","name":"War Dog","role":"Skirmisher","tool":"Melee","creature_type":"Beast","archetype":"War Hound","signature":"Loyal","stats":{"max_wounds":2,"armour":"None","speed":10,"max_ap":2,"nerve":0,"rank":"I"},"base":{"shape":"Circle","class":"Small","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_WARDOG"],"ability_packet_ids":["ABIL_MIL_WARDOG_1"],"temperament":"Protective","display":{"card_image_url":"","weapon":"Bite","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003eKnockdown","armour":"—","base":"Circle / Small","note":"Sprint 12\"; loyal to the Captain."}},{"schema_version":1,"definition_id":"MIL_GOLEM","name":"Village Golem","role":"Anchor","tool":"Melee","creature_type":"Construct","archetype":"Ox-Cart Golem","signature":"Immovable","stats":{"max_wounds":6,"armour":"Medium","speed":4,"max_ap":2,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Large","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_GOLEM"],"ability_packet_ids":["ABIL_MIL_GOLEM_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Timber \u0026 Iron","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003eKnockdown","armour":"5+","base":"Circle / Large","note":"Rolling anchor; blocks LoS; never panics."}},{"schema_version":1,"definition_id":"MIL_SERGEANT","name":"Mounted Sergeant","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Man-at-Arms","signature":"Lance","stats":{"max_wounds":3,"armour":"Medium","speed":11,"max_ap":2,"nerve":3,"rank":"III"},"base":{"shape":"Square","class":"Cavalry","mounted":true,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_SERGEANT"],"ability_packet_ids":["ABIL_MIL_SERGEANT_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Cavalry Lance","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003ePush · 3-\u003eKnockdown","armour":"5+","base":"Square / Cavalry","note":"Mounted shock; plows a class up."}},{"schema_version":1,"definition_id":"MIL_OUTRIDER","name":"Yeoman Outrider","role":"Skirmisher","tool":"Ranged","creature_type":"Man","archetype":"Outrider","signature":"Hit \u0026 Run","stats":{"max_wounds":2,"armour":"Light","speed":12,"max_ap":2,"nerve":2,"rank":"II"},"base":{"shape":"Square","class":"Cavalry","mounted":true,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_OUTRIDER"],"ability_packet_ids":["ABIL_MIL_OUTRIDER_1"],"temperament":"Cowardly","display":{"card_image_url":"","weapon":"Mounted Bow","dice":2,"hit":"4+","tiers":"1-\u003e1W · 3-\u003e2W","armour":"6+","base":"Square / Cavalry","note":"Range 15\"; kites and picks off stragglers."}},{"schema_version":1,"definition_id":"MIL_SENTINEL","name":"Stone Sentinel","role":"Anchor","tool":"Melee","creature_type":"Construct","archetype":"Stone Golem","signature":"Colossus","stats":{"max_wounds":8,"armour":"Heavy","speed":3,"max_ap":2,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Monstrous","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_MIL_SENTINEL"],"ability_packet_ids":["ABIL_MIL_SENTINEL_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Stone Fists","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003e3W","armour":"4+","base":"Circle / Monstrous","note":"Unbreakable colossus; blocks LoS."}}]},{"faction":"Goblins","prefix":"GOB","attack_packets":[{"id":"ATK_GOB_BOSS","alias":"Cruel Blade","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Push"]},{"successes":4,"wounds":2,"effects":[]}]},{"id":"ATK_GOB_RABBLE","alias":"Rusty Blade","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Push"]}]},{"id":"ATK_GOB_SPEARGIT","alias":"Pokey Spear","parent_action":"ATTACK","dice":2,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Reach","never countered"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Push"]}]},{"id":"ATK_GOB_BIGSHIELD","alias":"Jagged Shiv","parent_action":"ATTACK","dice":2,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Guard"]}]},{"id":"ATK_GOB_CHAINBALL","alias":"Whirling Chain","parent_action":"ATTACK","dice":4,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":2,"effects":["Knockdown"]}]},{"id":"ATK_GOB_ARCHER","alias":"Short Bow","parent_action":"ATTACK","dice":2,"hit":5,"range":15,"area":null,"cost_ap":1,"tags":["Ranged"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]}]},{"id":"ATK_GOB_WOLFRIDER_SPEAR","alias":"Rider Spear","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Push"]}]},{"id":"ATK_GOB_WOLFRIDER_BITE","alias":"Wolf Bite","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Knockdown"]}]},{"id":"ATK_GOB_SNEAKY","alias":"Back-Stabba","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":2,"effects":[]},{"successes":5,"wounds":2,"effects":["Execute"]}]},{"id":"ATK_GOB_FUNGUSDOC","alias":"Bone Saw","parent_action":"ATTACK","dice":2,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]}]},{"id":"ATK_GOB_SHAMAN","alias":"Green Bolt","parent_action":"ATTACK","dice":3,"hit":4,"range":12,"area":null,"cost_ap":1,"tags":["Ranged"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":2,"effects":["Cleave"]}]},{"id":"ATK_GOB_SQUIG","alias":"Chompa","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":2,"effects":[]}]},{"id":"ATK_GOB_TROLL","alias":"Big Club","parent_action":"ATTACK","dice":3,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":3,"effects":["Knockdown"]}]},{"id":"ATK_GOB_CAVETROLL","alias":"Boulder Fists","parent_action":"ATTACK","dice":4,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":3,"effects":[]},{"successes":4,"wounds":3,"effects":["Knockdown","Push"]}]},{"id":"ATK_GOB_SPIDERRIDER_FANGS","alias":"Spider Fangs","parent_action":"ATTACK","dice":2,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["ignore Armour"]}]},{"id":"ATK_GOB_SPIDERRIDER_JAB","alias":"Rider Jab","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Push"]}]}],"ability_packets":[{"id":"ABIL_GOB_BOSS_1","alias":"Rally Aura","type":"Passive","parent_action":null,"note":"6\": Goblins stop routing and ignore the Mob -1 while the Boss lives.","tags":["Aura","Morale"]},{"id":"ABIL_GOB_BOSS_2","alias":"Decapitation","type":"Passive","parent_action":null,"note":"If the Boss dies, all Goblins within 6\" test Nerve at -1.","tags":["Morale"]},{"id":"ABIL_GOB_RABBLE_1","alias":"Mob Courage","type":"Passive","parent_action":null,"note":"+1 Nerve while Goblins outnumber enemies within 6\"; -1 while outnumbered.","tags":["Morale"]},{"id":"ABIL_GOB_RABBLE_2","alias":"Gang","type":"Passive","parent_action":null,"note":"+1 die while 2+ Rabble on one target.","tags":[]},{"id":"ABIL_GOB_SPEARGIT_1","alias":"Set \u0027Em Up","type":"Passive","parent_action":null,"note":"On a Push, an adjacent Goblin gets +1 die vs the shoved model.","tags":[]},{"id":"ABIL_GOB_BIGSHIELD_1","alias":"Big Shield","type":"Passive","parent_action":null,"note":"Attackers roll -1 die.","tags":[]},{"id":"ABIL_GOB_BIGSHIELD_2","alias":"Cover for the Boys","type":"Passive","parent_action":null,"note":"Goblins directly behind it get Cover (-1 die when shot).","tags":[]},{"id":"ABIL_GOB_CHAINBALL_1","alias":"Uncontrolled","type":"Passive","parent_action":null,"note":"Must attack the nearest model, friend or foe, if any is adjacent; fearless.","tags":[]},{"id":"ABIL_GOB_ARCHER_1","alias":"Brave From Afar","type":"Passive","parent_action":null,"note":"+1 Nerve while 12\"+ from any enemy.","tags":["Morale"]},{"id":"ABIL_GOB_ARCHER_2","alias":"Multi-Shot","type":"Passive","parent_action":null,"note":"Fires two shots, each at Hit one step worse (standard).","tags":[]},{"id":"ABIL_GOB_WOLFRIDER_1","alias":"Hit \u0026 Run","type":"Active","parent_action":"MOVE","note":"Sprint 18\"; free Disengage.","tags":[]},{"id":"ABIL_GOB_WOLFRIDER_2","alias":"Charging Lance","type":"Passive","parent_action":null,"note":"+1 die on the turn it Charges; plows a class up (mounted).","tags":[]},{"id":"ABIL_GOB_SNEAKY_1","alias":"Sneaky Stabbin\u0027","type":"Passive","parent_action":null,"note":"+2 dice from the rear or while another Goblin engages the target.","tags":[]},{"id":"ABIL_GOB_SNEAKY_2","alias":"Now Ya See Me","type":"Passive","parent_action":null,"note":"Hides if it ends its turn out of LoS.","tags":[]},{"id":"ABIL_GOB_FUNGUSDOC_1","alias":"Patch","type":"Active","parent_action":"USE","note":"x2: remove 1W, base contact.","tags":["Heal"]},{"id":"ABIL_GOB_FUNGUSDOC_2","alias":"Mad Cap Mushroom","type":"Active","parent_action":"USE","note":"Target Goblin ignores the Mob -1 and +1 die this turn, then takes 1W after.","tags":["Buff"]},{"id":"ABIL_GOB_FUNGUSDOC_3","alias":"Spore Cloud","type":"Active","parent_action":"USE","note":"Goblins within 4cm +1 Nerve for one round.","tags":["Aura","Morale"]},{"id":"ABIL_GOB_SHAMAN_1","alias":"Warp Risk","type":"Passive","parent_action":null,"note":"If the roll shows 2+ misses, the Shaman takes 1W (Heat).","tags":[]},{"id":"ABIL_GOB_SHAMAN_2","alias":"Fungus Hex","type":"Active","parent_action":"ATTACK","note":"A target enemy square tests Nerve at -1 on its next trigger.","tags":["Morale"]},{"id":"ABIL_GOB_SQUIG_1","alias":"Boing","type":"Active","parent_action":"MOVE","note":"Must Sprint (14\") toward the nearest enemy each activation.","tags":["Forced"]},{"id":"ABIL_GOB_TROLL_1","alias":"Regeneration","type":"Passive","parent_action":null,"note":"Recover 1W at activation start.","tags":[]},{"id":"ABIL_GOB_TROLL_2","alias":"Too Stupid to Flee","type":"Passive","parent_action":null,"note":"Ignores Mob-Courage swings; on a Rout it rampages at the nearest model.","tags":[]},{"id":"ABIL_GOB_CAVETROLL_1","alias":"Regeneration","type":"Passive","parent_action":null,"note":"Recover 1W at activation start.","tags":[]},{"id":"ABIL_GOB_CAVETROLL_2","alias":"Stone Hide","type":"Passive","parent_action":null,"note":"Monstrous: unstoppable by bodies; only a wall jams it.","tags":[]},{"id":"ABIL_GOB_SPIDERRIDER_1","alias":"Wall Crawler","type":"Active","parent_action":"MOVE","note":"Climbs and crosses vertical terrain freely (no per-story AP).","tags":[]},{"id":"ABIL_GOB_SPIDERRIDER_2","alias":"Venom","type":"Passive","parent_action":null,"note":"Spider Fangs ignore Armour on the second success tier.","tags":[]}],"units":[{"schema_version":1,"definition_id":"GOB_BOSS","name":"Goblin Boss","role":"Support","tool":"Melee","creature_type":"Man","archetype":"Commander","signature":"Bully of the mob; his death collapses the line","counter_uses":1,"stats":{"max_wounds":3,"armour":"Light","speed":7,"max_ap":3,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_GOB_BOSS"],"ability_packet_ids":["ABIL_GOB_BOSS_1","ABIL_GOB_BOSS_2"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Cruel Blade","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003ePush · 4-\u003e2W","armour":"6+","base":"Circle / Normal","note":"Rally aura; decapitation collapse"}},{"schema_version":1,"definition_id":"GOB_RABBLE","name":"Goblin Rabble","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Line Fighter","signature":"Brave in numbers, gone when thinned","stats":{"max_wounds":1,"armour":"None","speed":7,"max_ap":2,"nerve":1,"rank":"I"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_GOB_RABBLE"],"ability_packet_ids":["ABIL_GOB_RABBLE_1","ABIL_GOB_RABBLE_2"],"temperament":"Cowardly","display":{"card_image_url":"","weapon":"Rusty Blade","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003ePush","armour":"—","base":"Square / Normal","note":"Mob Courage + Gang"}},{"schema_version":1,"definition_id":"GOB_SPEARGIT","name":"Spear Git","role":"Anchor","tool":"Melee","creature_type":"Man","archetype":"Reach Spearman","signature":"Stabs from the second rank to make openings","stats":{"max_wounds":1,"armour":"None","speed":7,"max_ap":2,"nerve":1,"rank":"I"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_GOB_SPEARGIT"],"ability_packet_ids":["ABIL_GOB_SPEARGIT_1"],"temperament":"Cowardly","display":{"card_image_url":"","weapon":"Pokey Spear","dice":2,"hit":"5+","tiers":"1-\u003e1W · 2-\u003ePush","armour":"—","base":"Square / Normal","note":"Reach 2\"; no Counter; Set \u0027Em Up"}},{"schema_version":1,"definition_id":"GOB_BIGSHIELD","name":"Big Shield Goblin","role":"Anchor","tool":"Melee","creature_type":"Man","archetype":"Shield Tank","signature":"Shields the mob\u0027s nerve, not a lane","stats":{"max_wounds":2,"armour":"Medium","speed":6,"max_ap":2,"nerve":2,"rank":"I"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_GOB_BIGSHIELD"],"ability_packet_ids":["ABIL_GOB_BIGSHIELD_1","ABIL_GOB_BIGSHIELD_2"],"temperament":"Protective","display":{"card_image_url":"","weapon":"Jagged Shiv","dice":2,"hit":"5+","tiers":"1-\u003e1W · 2-\u003eGuard","armour":"5+","base":"Square / Normal","note":"Big Shield; Cover for the Boys"}},{"schema_version":1,"definition_id":"GOB_CHAINBALL","name":"Chain Ball Lunatic","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Fungus-Mad Flail","signature":"Fearless AoE melee that endangers its own side","stats":{"max_wounds":2,"armour":"None","speed":6,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_GOB_CHAINBALL"],"ability_packet_ids":["ABIL_GOB_CHAINBALL_1"],"temperament":"Ravenous","display":{"card_image_url":"","weapon":"Whirling Chain","dice":4,"hit":"5+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003eKnockdown","armour":"—","base":"Circle / Normal","note":"Uncontrolled; hits nearest model any side"}},{"schema_version":1,"definition_id":"GOB_ARCHER","name":"Gobbo Archer","role":"Skirmisher","tool":"Ranged","creature_type":"Man","archetype":"Volume Archer","signature":"Sprays volume; breaks the instant anything reaches it","stats":{"max_wounds":1,"armour":"None","speed":7,"max_ap":2,"nerve":1,"rank":"I"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_GOB_ARCHER"],"ability_packet_ids":["ABIL_GOB_ARCHER_1","ABIL_GOB_ARCHER_2"],"temperament":"Cowardly","display":{"card_image_url":"","weapon":"Short Bow","dice":2,"hit":"5+","tiers":"1-\u003e1W · 2-\u003e2W","armour":"—","base":"Square / Normal","note":"Multi-Shot; Brave From Afar"}},{"schema_version":1,"definition_id":"GOB_WOLFRIDER","name":"Wolf Rider","role":"Skirmisher","tool":"Melee","creature_type":"Man","archetype":"Light Cavalry","signature":"Fast flanker that picks off stragglers","stats":{"max_wounds":2,"armour":"Light","speed":12,"max_ap":2,"nerve":2,"rank":"II"},"base":{"shape":"Square","class":"Cavalry","mounted":true,"forward_axis":"local_z"},"attack_packet_ids":["ATK_GOB_WOLFRIDER_SPEAR","ATK_GOB_WOLFRIDER_BITE"],"ability_packet_ids":["ABIL_GOB_WOLFRIDER_1","ABIL_GOB_WOLFRIDER_2"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Rider Spear / Wolf Bite","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003ePush / Knockdown","armour":"6+","base":"Cavalry / Mounted","note":"Hit \u0026 Run; two attacks; charges a class up"}},{"schema_version":1,"definition_id":"GOB_SNEAKY","name":"Purple Sneaky Git","role":"Skirmisher","tool":"Melee","creature_type":"Man","archetype":"Assassin","signature":"Hunts the enemy support hero to collapse their morale","stats":{"max_wounds":2,"armour":"Light","speed":8,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_GOB_SNEAKY"],"ability_packet_ids":["ABIL_GOB_SNEAKY_1","ABIL_GOB_SNEAKY_2"],"temperament":"Cowardly","display":{"card_image_url":"","weapon":"Back-Stabba","dice":3,"hit":"4+","tiers":"1-\u003e1W · 3-\u003e2W · 5-\u003eExecute","armour":"6+","base":"Circle / Normal","note":"Sneaky Stabbin\u0027; Now Ya See Me"}},{"schema_version":1,"definition_id":"GOB_FUNGUSDOC","name":"Fungus Doctor","role":"Support","tool":"Utility","creature_type":"Man","archetype":"Chem-Medic","signature":"Momentum in a syringe; chemical morale","stats":{"max_wounds":2,"armour":"Light","speed":6,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_GOB_FUNGUSDOC"],"ability_packet_ids":["ABIL_GOB_FUNGUSDOC_1","ABIL_GOB_FUNGUSDOC_2","ABIL_GOB_FUNGUSDOC_3"],"temperament":"Protective","display":{"card_image_url":"","weapon":"Bone Saw","dice":2,"hit":"5+","tiers":"1-\u003e1W","armour":"6+","base":"Circle / Normal","note":"Patch x2; Mad Cap Mushroom; Spore Cloud"}},{"schema_version":1,"definition_id":"GOB_SHAMAN","name":"Cave Shaman","role":"Control","tool":"Ranged","creature_type":"Man","archetype":"Warp Mage","signature":"AoE bolt with a push-your-luck backlash","stats":{"max_wounds":2,"armour":"None","speed":6,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_GOB_SHAMAN"],"ability_packet_ids":["ABIL_GOB_SHAMAN_1","ABIL_GOB_SHAMAN_2"],"temperament":"Cowardly","display":{"card_image_url":"","weapon":"Green Bolt","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003eblast","armour":"—","base":"Circle / Normal","note":"Warp Heat risk; Fungus Hex on enemy morale"}},{"schema_version":1,"definition_id":"GOB_SQUIG","name":"Squig","role":"Skirmisher","tool":"Melee","creature_type":"Beast","archetype":"Chaotic Biter","signature":"Semi-uncontrolled; must charge the nearest enemy","stats":{"max_wounds":2,"armour":"Light","speed":10,"max_ap":2,"nerve":0,"rank":"I"},"base":{"shape":"Circle","class":"Small","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_GOB_SQUIG"],"ability_packet_ids":["ABIL_GOB_SQUIG_1"],"temperament":"Ravenous","display":{"card_image_url":"","weapon":"Chompa","dice":2,"hit":"4+","tiers":"1-\u003e1W · 3-\u003e2W","armour":"6+","base":"Circle / Small","note":"Boing: forced Sprint at nearest enemy"}},{"schema_version":1,"definition_id":"GOB_TROLL","name":"Troll","role":"Assault","tool":"Melee","creature_type":"Beast","archetype":"Regenerating Monster","signature":"Too dumb to scare; regenerates; rampages on a rout","stats":{"max_wounds":8,"armour":"Light","speed":6,"max_ap":3,"nerve":3,"rank":"III"},"base":{"shape":"Square","class":"Large","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_GOB_TROLL"],"ability_packet_ids":["ABIL_GOB_TROLL_1","ABIL_GOB_TROLL_2"],"temperament":"Ravenous","display":{"card_image_url":"","weapon":"Big Club","dice":3,"hit":"5+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003e3W+Knockdown","armour":"6+","base":"Square / Large","note":"Regeneration; Too Stupid to Flee"}},{"schema_version":1,"definition_id":"GOB_CAVETROLL","name":"Cave Troll","role":"Assault","tool":"Melee","creature_type":"Beast","archetype":"Monstrous Bruiser","signature":"A stone-hided horror bodies cannot stop","stats":{"max_wounds":10,"armour":"Medium","speed":5,"max_ap":3,"nerve":3,"rank":"III"},"base":{"shape":"Square","class":"Monstrous","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_GOB_CAVETROLL"],"ability_packet_ids":["ABIL_GOB_CAVETROLL_1","ABIL_GOB_CAVETROLL_2"],"temperament":"Ravenous","display":{"card_image_url":"","weapon":"Boulder Fists","dice":4,"hit":"5+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003e3W · 4-\u003eKnockdown+Push","armour":"5+","base":"Square / Monstrous","note":"Regeneration; Stone Hide (unstoppable by bodies)"}},{"schema_version":1,"definition_id":"GOB_SPIDERRIDER","name":"Spider Rider","role":"Skirmisher","tool":"Melee","creature_type":"Man","archetype":"Wall-Crawling Cavalry","signature":"Venomous flanker that scales any terrain","stats":{"max_wounds":2,"armour":"Light","speed":12,"max_ap":2,"nerve":2,"rank":"II"},"base":{"shape":"Square","class":"Cavalry","mounted":true,"forward_axis":"local_z"},"attack_packet_ids":["ATK_GOB_SPIDERRIDER_FANGS","ATK_GOB_SPIDERRIDER_JAB"],"ability_packet_ids":["ABIL_GOB_SPIDERRIDER_1","ABIL_GOB_SPIDERRIDER_2"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Spider Fangs / Rider Jab","dice":2,"hit":"5+","tiers":"1-\u003e1W · 2-\u003eignore Armour / Push","armour":"6+","base":"Cavalry / Mounted","note":"Wall Crawler; Venom; two attacks"}}]},{"faction":"Stormwarden","prefix":"STW","attack_packets":[{"id":"ATK_STW_CAPTAIN","alias":"Arming Sword","parent_action":"ATTACK","dice":3,"hit":3,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":0,"effects":["Guard"]}]},{"id":"ATK_STW_SHIELDKNIGHT","alias":"Sword \u0026 Shield","parent_action":"ATTACK","dice":3,"hit":3,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":0,"effects":["Guard"]}]},{"id":"ATK_STW_IRONWARDEN","alias":"Warhammer","parent_action":"ATTACK","dice":2,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":0,"effects":["Knockdown"]}]},{"id":"ATK_STW_HALBERDIER","alias":"Halberd","parent_action":"ATTACK","dice":2,"hit":4,"range":2,"area":null,"cost_ap":1,"tags":["Reach","never countered"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":0,"effects":["Knockdown"]},{"successes":3,"wounds":0,"effects":["Guard"]}]},{"id":"ATK_STW_GREATSWORD","alias":"Greatsword","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":0,"effects":["Cleave"]}]},{"id":"ATK_STW_RANGER_BOW","alias":"Shortbow","parent_action":"ATTACK","dice":2,"hit":4,"range":15,"area":null,"cost_ap":1,"tags":["Ranged"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":2,"effects":[]}]},{"id":"ATK_STW_RANGER_SWORD","alias":"Shortsword","parent_action":"ATTACK","dice":2,"hit":3,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]}]},{"id":"ATK_STW_SHADOWBLADE","alias":"Stiletto","parent_action":"ATTACK","dice":3,"hit":3,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":2,"effects":[]},{"successes":5,"wounds":0,"effects":["Execute"]}]},{"id":"ATK_STW_LONGBOWMAN","alias":"Longbow","parent_action":"ATTACK","dice":2,"hit":4,"range":24,"area":null,"cost_ap":1,"tags":["Ranged","never countered"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":2,"effects":[]}]},{"id":"ATK_STW_CLERIC","alias":"Mace","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":0,"effects":["Knockdown"]}]},{"id":"ATK_STW_STORMMAGE","alias":"Chain Lightning","parent_action":"ATTACK","dice":3,"hit":4,"range":12,"area":null,"cost_ap":1,"tags":["Ranged"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":2,"effects":[]}]},{"id":"ATK_STW_WARHOUND","alias":"Bite","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":0,"effects":["Knockdown"]}]},{"id":"ATK_STW_WARGOLEM","alias":"Great Fists","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":0,"effects":["Knockdown","Push"]}]},{"id":"ATK_STW_LANCER","alias":"Warlance","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":0,"effects":["Push"]},{"successes":3,"wounds":0,"effects":["Knockdown"]}]},{"id":"ATK_STW_OUTRIDER","alias":"Horseman\u0027s Lance","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":0,"effects":["Push"]},{"successes":3,"wounds":0,"effects":["Knockdown"]}]},{"id":"ATK_STW_DRAKE_CLAWS","alias":"Claws \u0026 Fangs","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":3,"effects":["Cleave"]}]},{"id":"ATK_STW_DRAKE_BREATH","alias":"Storm Breath","parent_action":"ATTACK","dice":3,"hit":4,"range":10,"area":4,"cost_ap":1,"tags":["Ranged","no Multi-Shot"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":["Push"]}]}],"ability_packets":[{"id":"ABIL_STW_CAPTAIN_1","alias":"Aura - Steady","type":"Passive","parent_action":null,"note":"Friendly Squares within 6\" re-roll failed Nerve.","tags":[]},{"id":"ABIL_STW_SHIELDKNIGHT_1","alias":"Shield Wall","type":"Passive","parent_action":null,"note":"Base-to-base with another Shield Knight: +1 die defending a Counter.","tags":[]},{"id":"ABIL_STW_IRONWARDEN_1","alias":"Bulwark","type":"Passive","parent_action":null,"note":"Attackers targeting it roll -1 die; cannot be Pushed.","tags":[]},{"id":"ABIL_STW_HALBERDIER_1","alias":"Brace","type":"Reactive","parent_action":"READY","note":"+1 die striking an enemy that Charged this turn.","tags":[]},{"id":"ABIL_STW_RANGER_1","alias":"Skirmish","type":"Active","parent_action":"MOVE","note":"Free Disengage; may MOVE after a Regular Shot (kite).","tags":[]},{"id":"ABIL_STW_SHADOWBLADE_1","alias":"From the Shadows","type":"Passive","parent_action":null,"note":"+2 dice attacking from the rear; ignores Counter. Glass cannon.","tags":[]},{"id":"ABIL_STW_CLERIC_1","alias":"Heal","type":"Active","parent_action":"USE","note":"x2: remove 1 Wound or stand a Knockdown, range 6\".","tags":[]},{"id":"ABIL_STW_CLERIC_2","alias":"Bless","type":"Active","parent_action":"USE","note":"1/turn: a friendly gains Guard +1 or re-rolls a Nerve.","tags":[]},{"id":"ABIL_STW_CLERIC_3","alias":"Purify","type":"Active","parent_action":"USE","note":"Clear a Stun/condition.","tags":[]},{"id":"ABIL_STW_STORMMAGE_1","alias":"Ward","type":"Active","parent_action":"READY","note":"Friendly Squares within 4cm roll Armour +1.","tags":[]},{"id":"ABIL_STW_STORMMAGE_2","alias":"Arc","type":"Passive","parent_action":null,"note":"On 3 successes the bolt arcs to the nearest enemy within 4cm and repeats the roll.","tags":[]},{"id":"ABIL_STW_WARHOUND_1","alias":"Pack","type":"Passive","parent_action":null,"note":"Sprint 12\"; +1 die if another Hound is engaged with the same target.","tags":[]},{"id":"ABIL_STW_WARGOLEM_1","alias":"Immovable","type":"Passive","parent_action":null,"note":"Cannot be Pushed/Knocked; blocks LoS.","tags":[]},{"id":"ABIL_STW_LANCER_1","alias":"Couched Lance","type":"Active","parent_action":"MOVE","note":"On a Charge: +1 die and plows a class up (the lance).","tags":[]},{"id":"ABIL_STW_OUTRIDER_1","alias":"Outflank","type":"Active","parent_action":"MOVE","note":"Free Disengage; +1 die on a Flank charge.","tags":[]},{"id":"ABIL_STW_DRAKE_1","alias":"Flight","type":"Passive","parent_action":null,"note":"Flies; ignores ground obstacles and engagement when moving over.","tags":[]}],"units":[{"schema_version":1,"definition_id":"STW_CAPTAIN","name":"Warden Captain","role":"Support","tool":"Melee","creature_type":"Man","archetype":"Commander","signature":"Defensive shaping - makes the line un-break-able.","counter_uses":2,"stats":{"max_wounds":4,"armour":"Heavy","speed":6,"max_ap":3,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_CAPTAIN"],"ability_packet_ids":["ABIL_STW_CAPTAIN_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Arming Sword","dice":3,"hit":"3+","tiers":"1-\u003e1W · 3-\u003eGuard +2","armour":"4+","base":"Circle / Normal","note":"Counter (2). Aura - Steady: friendly squares re-roll Nerve."}},{"schema_version":1,"definition_id":"STW_SHIELDKNIGHT","name":"Shield Knight","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Line Infantry","signature":"The shield wall - wins the exchange by surviving it.","stats":{"max_wounds":2,"armour":"Medium","speed":6,"max_ap":2,"nerve":3,"rank":"II"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_SHIELDKNIGHT"],"ability_packet_ids":["ABIL_STW_SHIELDKNIGHT_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Sword \u0026 Shield","dice":3,"hit":"3+","tiers":"1-\u003e1W · 3-\u003eGuard +1","armour":"5+","base":"Square / Normal","note":"Shield Wall: +1 die defending a Counter beside another Shield Knight."}},{"schema_version":1,"definition_id":"STW_IRONWARDEN","name":"Iron Warden","role":"Anchor","tool":"Melee","creature_type":"Man","archetype":"Tank","signature":"The anvil - reliable, immovable, low damage.","stats":{"max_wounds":3,"armour":"Heavy","speed":4,"max_ap":2,"nerve":3,"rank":"II"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_IRONWARDEN"],"ability_packet_ids":["ABIL_STW_IRONWARDEN_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Warhammer","dice":2,"hit":"5+","tiers":"1-\u003e1W · 2-\u003eKnockdown","armour":"4+","base":"Square / Normal","note":"Bulwark: attackers roll -1 die; cannot be Pushed. Exceptional armour."}},{"schema_version":1,"definition_id":"STW_HALBERDIER","name":"Halberdier","role":"Anchor","tool":"Melee","creature_type":"Man","archetype":"Reach Infantry","signature":"Punishes the charge before it lands.","stats":{"max_wounds":2,"armour":"Medium","speed":6,"max_ap":2,"nerve":3,"rank":"II"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_HALBERDIER"],"ability_packet_ids":["ABIL_STW_HALBERDIER_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Halberd","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003eKnockdown · 3-\u003eGuard +1","armour":"5+","base":"Square / Normal","note":"Reach 2\" / Fend, no Counter. Brace: +1 die vs a charger."}},{"schema_version":1,"definition_id":"STW_GREATSWORD","name":"Greatsword","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Heavy Weapon","signature":"A clean, readable 3-rung ladder - the control sample.","stats":{"max_wounds":2,"armour":"Light","speed":5,"max_ap":2,"nerve":2,"rank":"II"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_GREATSWORD"],"ability_packet_ids":[],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Greatsword","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003eCleave","armour":"6+","base":"Square / Normal","note":"Two-handed, no shield (thin armour)."}},{"schema_version":1,"definition_id":"STW_RANGER","name":"Ranger","role":"Skirmisher","tool":"Ranged","creature_type":"Man","archetype":"Skirmisher","signature":"Move-shoot-move - reach the objective, stay untouchable.","stats":{"max_wounds":2,"armour":"Light","speed":7,"max_ap":2,"nerve":0,"rank":"I"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_RANGER_BOW","ATK_STW_RANGER_SWORD"],"ability_packet_ids":["ABIL_STW_RANGER_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Shortbow / Shortsword","dice":2,"hit":"4+","tiers":"Bow 1-\u003e1W · 3-\u003e2W","armour":"6+","base":"Circle / Normal","note":"Skirmish: free Disengage; MOVE after a Regular Shot (obeys 3-shot rule)."}},{"schema_version":1,"definition_id":"STW_SHADOWBLADE","name":"Shadowblade","role":"Skirmisher","tool":"Melee","creature_type":"Man","archetype":"Assassin","signature":"Reaches Execute only by stacking positional dice.","stats":{"max_wounds":1,"armour":"None","speed":8,"max_ap":2,"nerve":0,"rank":"I"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_SHADOWBLADE"],"ability_packet_ids":["ABIL_STW_SHADOWBLADE_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Stiletto","dice":3,"hit":"3+","tiers":"1-\u003e1W · 3-\u003e2W · 5-\u003eExecute","armour":"—","base":"Circle / Normal","note":"From the Shadows: +2 dice from rear, ignores Counter. Dies if caught."}},{"schema_version":1,"definition_id":"STW_LONGBOWMAN","name":"Longbowman","role":"Skirmisher","tool":"Ranged","creature_type":"Man","archetype":"Archer","signature":"The disciplined kiting-brake - the Precision sniper.","stats":{"max_wounds":2,"armour":"Light","speed":6,"max_ap":2,"nerve":2,"rank":"I"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_LONGBOWMAN"],"ability_packet_ids":[],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Longbow","dice":2,"hit":"4+","tiers":"1-\u003e1W · 3-\u003e2W","armour":"6+","base":"Square / Normal","note":"Range 24\", never countered. Best with Precision Shot (+1 die, ignore Cover)."}},{"schema_version":1,"definition_id":"STW_CLERIC","name":"Cleric","role":"Support","tool":"Utility","creature_type":"Man","archetype":"Support","signature":"Heal-from-safety-and-bless - keeps the wall standing.","stats":{"max_wounds":2,"armour":"Medium","speed":6,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_CLERIC"],"ability_packet_ids":["ABIL_STW_CLERIC_1","ABIL_STW_CLERIC_2","ABIL_STW_CLERIC_3"],"temperament":"Protective","display":{"card_image_url":"","weapon":"Mace","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003eKnockdown","armour":"5+","base":"Circle / Normal","note":"Heal x2, Bless (1/turn), Purify. Safe, ranged, reliable."}},{"schema_version":1,"definition_id":"STW_STORMMAGE","name":"Storm Mage","role":"Control","tool":"Ranged","creature_type":"Man","archetype":"Mage","signature":"Precise AoE + control - threads through a formation.","stats":{"max_wounds":2,"armour":"Light","speed":6,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_STORMMAGE"],"ability_packet_ids":["ABIL_STW_STORMMAGE_1","ABIL_STW_STORMMAGE_2"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Chain Lightning","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003earc \u0026 repeat","armour":"6+","base":"Circle / Normal","note":"Range 12\". Ward: friendly squares within 4cm roll Armour +1."}},{"schema_version":1,"definition_id":"STW_WARHOUND","name":"War Hound","role":"Skirmisher","tool":"Melee","creature_type":"Beast","archetype":"Beast","signature":"The disciplined runner - grabs the far objective on command.","stats":{"max_wounds":2,"armour":"None","speed":10,"max_ap":2,"nerve":0,"rank":"I"},"base":{"shape":"Circle","class":"Small","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_WARHOUND"],"ability_packet_ids":["ABIL_STW_WARHOUND_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Bite","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003eKnockdown","armour":"—","base":"Circle / Small","note":"Pack: Sprint 12\"; +1 die if another Hound shares the target."}},{"schema_version":1,"definition_id":"STW_WARGOLEM","name":"War Golem","role":"Anchor","tool":"Melee","creature_type":"Construct","archetype":"Monster","signature":"High-armour large base - the immovable construct.","stats":{"max_wounds":6,"armour":"Heavy","speed":5,"max_ap":3,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Large","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_WARGOLEM"],"ability_packet_ids":["ABIL_STW_WARGOLEM_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Great Fists","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003eKnockdown + Push 4cm","armour":"4+","base":"Circle / Large","note":"Immovable: cannot be Pushed/Knocked; blocks LoS. Construct never tests Nerve."}},{"schema_version":1,"definition_id":"STW_LANCER","name":"Warden Lancer","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Heavy Cavalry","signature":"The disciplined charge - couched lance plows the line.","stats":{"max_wounds":3,"armour":"Medium","speed":11,"max_ap":2,"nerve":3,"rank":"II"},"base":{"shape":"Square","class":"Cavalry","mounted":true,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_LANCER"],"ability_packet_ids":["ABIL_STW_LANCER_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Warlance","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003ePush · 3-\u003eKnockdown","armour":"5+","base":"Square / Cavalry","note":"Mounted, plows a class up. Couched Lance: +1 die on the Charge."}},{"schema_version":1,"definition_id":"STW_OUTRIDER","name":"Knight Outrider","role":"Skirmisher","tool":"Melee","creature_type":"Man","archetype":"Light Cavalry","signature":"The fast flank - harasses and wheels away.","stats":{"max_wounds":2,"armour":"Light","speed":12,"max_ap":2,"nerve":2,"rank":"I"},"base":{"shape":"Square","class":"Cavalry","mounted":true,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_OUTRIDER"],"ability_packet_ids":["ABIL_STW_OUTRIDER_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Horseman\u0027s Lance","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003ePush · 3-\u003eKnockdown","armour":"6+","base":"Square / Cavalry","note":"Mounted, plows a class up. Outflank: free Disengage; +1 die on a Flank charge."}},{"schema_version":1,"definition_id":"STW_DRAKE","name":"Storm Drake","role":"Assault","tool":"Melee","creature_type":"Beast","archetype":"Monster","signature":"The winged storm - a flying monstrous breath-attacker.","stats":{"max_wounds":7,"armour":"Medium","speed":10,"max_ap":3,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Monstrous","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_STW_DRAKE_CLAWS","ATK_STW_DRAKE_BREATH"],"ability_packet_ids":["ABIL_STW_DRAKE_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Claws \u0026 Fangs / Storm Breath","dice":3,"hit":"4+","tiers":"Claws 1-\u003e1W · 2-\u003e2W · 3-\u003e3W + Cleave","armour":"5+","base":"Circle / Monstrous","note":"Flight. Storm Breath: Range 10\" blast (4cm), no Multi-Shot. Monstrous - unstoppable by bodies."}}]},{"faction":"Orks","prefix":"ORK","attack_packets":[{"id":"ATK_ORK_WARBOSS","alias":"Boss Choppa","parent_action":"ATTACK","dice":4,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":0,"effects":["Push"]},{"successes":4,"wounds":2,"effects":["Knockdown"]}]},{"id":"ATK_ORK_BOY","alias":"Choppa","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":0,"effects":["Push"]}]},{"id":"ATK_ORK_MEGABRUTE","alias":"Krusha","parent_action":"ATTACK","dice":3,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":0,"effects":["Knockdown","Push"]}]},{"id":"ATK_ORK_SPEARBOY","alias":"Stabba","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee","Reach","never countered"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":0,"effects":["Push"]},{"successes":3,"wounds":0,"effects":["Push"]}]},{"id":"ATK_ORK_CHOPPABRUTE","alias":"Twin Choppas","parent_action":"ATTACK","dice":4,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":4,"wounds":3,"effects":["Cleave"]}]},{"id":"ATK_ORK_KOMMANDO","alias":"Sneaky Choppa","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]}]},{"id":"ATK_ORK_KOMMANDO_BOMB","alias":"Stikkbomb","parent_action":"ATTACK","dice":2,"hit":4,"range":8,"area":2,"cost_ap":1,"tags":["Ranged","no Multi-Shot"],"tiers":[{"successes":1,"wounds":0,"effects":["Knockdown"]}]},{"id":"ATK_ORK_SNEAKYGIT","alias":"Shiv","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":2,"effects":[]},{"successes":5,"wounds":0,"effects":["Execute"]}]},{"id":"ATK_ORK_GOBLINARCHER","alias":"Short Bow","parent_action":"ATTACK","dice":2,"hit":5,"range":15,"area":null,"cost_ap":1,"tags":["Ranged","never countered"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]}]},{"id":"ATK_ORK_PAINBOY","alias":"Saw","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]}]},{"id":"ATK_ORK_WEIRDBOY","alias":"Da Krunch","parent_action":"ATTACK","dice":4,"hit":4,"range":12,"area":4,"cost_ap":1,"tags":["Ranged","no Multi-Shot"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":2,"effects":["Knockdown"]}]},{"id":"ATK_ORK_SQUIG","alias":"Chompa","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":2,"effects":[]}]},{"id":"ATK_ORK_TROLL","alias":"Big Club","parent_action":"ATTACK","dice":3,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":3,"effects":["Knockdown"]}]},{"id":"ATK_ORK_SQUIGGOTH","alias":"Goring Charge","parent_action":"ATTACK","dice":4,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":["Push"]},{"successes":4,"wounds":3,"effects":["Knockdown","Cleave"]}]},{"id":"ATK_ORK_BOARBOY","alias":"Choppa \u0026 Tusks","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":0,"effects":["Push"]},{"successes":3,"wounds":2,"effects":["Knockdown"]}]},{"id":"ATK_ORK_WARBOAR","alias":"Tusker Lance","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":["Push"]},{"successes":3,"wounds":3,"effects":["Knockdown"]}]}],"ability_packets":[{"id":"ABIL_ORK_WARBOSS_1","alias":"\u0027Ere We Go (Aura)","type":"Passive","parent_action":null,"note":"Friendly Orks within 6\" ignore their first Knockdown each round.","tags":["Aura"]},{"id":"ABIL_ORK_WARBOSS_2","alias":"Brutal","type":"Passive","parent_action":null,"note":"Counter rolls +1 die.","tags":["Counter"]},{"id":"ABIL_ORK_BOY_1","alias":"Mob (\u0027Ere We Go)","type":"Passive","parent_action":null,"note":"+1 Attack die while \u003e=2 friendly Boyz are within 3\".","tags":[]},{"id":"ABIL_ORK_MEGABRUTE_1","alias":"Brutal Retaliation","type":"Passive","parent_action":null,"note":"Counter rolls +1 die and ignores Guard.","tags":["Counter"]},{"id":"ABIL_ORK_SPEARBOY_1","alias":"Open the Line","type":"Passive","parent_action":null,"note":"On a Pull, an adjacent friendly Ork gets +1 die vs the dragged target.","tags":[]},{"id":"ABIL_ORK_CHOPPABRUTE_1","alias":"Reckless Swing","type":"Passive","parent_action":null,"note":"Swingy monster ladder; the top rung needs Charge or Flank dice to reach.","tags":[]},{"id":"ABIL_ORK_KOMMANDO_1","alias":"Infiltrate","type":"Passive","parent_action":null,"note":"Deploys forward + hidden; its first attack from stealth counts as Backstab.","tags":[]},{"id":"ABIL_ORK_SNEAKYGIT_1","alias":"Gang Up","type":"Passive","parent_action":null,"note":"+2 dice while another friendly Ork is engaged with the same target.","tags":[]},{"id":"ABIL_ORK_GOBLINARCHER_1","alias":"Multi-Shot","type":"Active","parent_action":"ATTACK","note":"Fires two shots (any targets in range), each at Hit one step worse.","tags":["Ranged"]},{"id":"ABIL_ORK_PAINBOY_1","alias":"Patch","type":"Active","parent_action":"USE","note":"Remove 1 Wound - base contact only (2 uses).","tags":["Heal"]},{"id":"ABIL_ORK_PAINBOY_2","alias":"Stimm","type":"Active","parent_action":"USE","note":"Target Ork gets +1 die \u0026 ignores Knockdown this turn, then takes 1 Wound after.","tags":["Buff"]},{"id":"ABIL_ORK_WEIRDBOY_1","alias":"Warp Risk (Heat)","type":"Passive","parent_action":null,"note":"If Da Krunch shows \u003e=2 misses, the Weirdboy takes 1 Wound and the blast scatters.","tags":["Warp"]},{"id":"ABIL_ORK_SQUIG_1","alias":"Boing","type":"Active","parent_action":"MOVE","note":"Must Sprint (14\") toward the nearest enemy each activation - semi-uncontrolled.","tags":["Forced Movement"]},{"id":"ABIL_ORK_TROLL_1","alias":"Regeneration","type":"Passive","parent_action":null,"note":"Recover 1 Wound at the start of each activation.","tags":[]},{"id":"ABIL_ORK_TROLL_2","alias":"Brutal","type":"Passive","parent_action":null,"note":"Counter rolls +1 die.","tags":["Counter"]},{"id":"ABIL_ORK_SQUIGGOTH_1","alias":"Unstoppable","type":"Passive","parent_action":null,"note":"Monstrous - unstoppable by bodies; only a wall jams the charge (crush at +2 dice).","tags":["Monstrous"]},{"id":"ABIL_ORK_SQUIGGOTH_2","alias":"Stampede","type":"Active","parent_action":"MOVE","note":"Sprint-into-charge tramples a straight lane, plowing bodies aside.","tags":["Charge"]},{"id":"ABIL_ORK_BOARBOY_1","alias":"Boar Charge","type":"Active","parent_action":"MOVE","note":"Mounted - charges a class up (the tusk plow).","tags":["Charge"]},{"id":"ABIL_ORK_WARBOAR_1","alias":"Gore Charge","type":"Active","parent_action":"MOVE","note":"Mounted lance charge - plows a class up and hits hardest on the impact.","tags":["Charge"]}],"units":[{"schema_version":1,"definition_id":"ORK_WARBOSS","name":"Warboss","role":"Support","tool":"Melee","creature_type":"Man","archetype":"Warlord","signature":"\u0027Ere We Go","counter_uses":2,"stats":{"max_wounds":6,"armour":"Light","speed":7,"max_ap":3,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_WARBOSS"],"ability_packet_ids":["ABIL_ORK_WARBOSS_1","ABIL_ORK_WARBOSS_2"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Boss Choppa","dice":4,"hit":"4+","tiers":"1-\u003e1W · 2-\u003ePush · 4-\u003e2W + Knockdown","armour":"6+","base":"Circle / Normal","note":"Aura: friendly Orks ignore first Knockdown. Counter (2), Brutal."}},{"schema_version":1,"definition_id":"ORK_BOY","name":"Boy","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Ork Boy","signature":"Mob","stats":{"max_wounds":3,"armour":"Light","speed":6,"max_ap":2,"nerve":2,"rank":"II"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_BOY"],"ability_packet_ids":["ABIL_ORK_BOY_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Choppa","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003ePush","armour":"6+","base":"Square / Normal","note":"Mob: +1 die while \u003e=2 Boyz within 3\"."}},{"schema_version":1,"definition_id":"ORK_MEGABRUTE","name":"Mega Brute","role":"Anchor","tool":"Melee","creature_type":"Man","archetype":"Ork Tank","signature":"Brutal Retaliation","counter_uses":1,"stats":{"max_wounds":7,"armour":"Light","speed":5,"max_ap":2,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_MEGABRUTE"],"ability_packet_ids":["ABIL_ORK_MEGABRUTE_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Krusha","dice":3,"hit":"5+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003eKnockdown + Push","armour":"6+","base":"Circle / Normal","note":"Brutal Retaliation: Counter +1 die, ignores Guard. Survives on wounds."}},{"schema_version":1,"definition_id":"ORK_SPEARBOY","name":"Spear Boy","role":"Anchor","tool":"Melee","creature_type":"Man","archetype":"Reach Boy","signature":"Open the Line","stats":{"max_wounds":3,"armour":"Light","speed":6,"max_ap":2,"nerve":2,"rank":"II"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_SPEARBOY"],"ability_packet_ids":["ABIL_ORK_SPEARBOY_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Stabba","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003ePush · 3-\u003ePull","armour":"6+","base":"Square / Normal","note":"Reach 2\", no Counter. Open the Line: pulled target ganged +1 die."}},{"schema_version":1,"definition_id":"ORK_CHOPPABRUTE","name":"Choppa Brute","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Berserker","signature":"Twin Choppas","stats":{"max_wounds":4,"armour":"Light","speed":6,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_CHOPPABRUTE"],"ability_packet_ids":["ABIL_ORK_CHOPPABRUTE_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Twin Choppas","dice":4,"hit":"5+","tiers":"1-\u003e1W · 2-\u003e2W · 4-\u003e3W + Cleave","armour":"6+","base":"Circle / Normal","note":"Swingy ladder; top rung needs Charge or Flank dice."}},{"schema_version":1,"definition_id":"ORK_KOMMANDO","name":"Kommando","role":"Skirmisher","tool":"Melee","creature_type":"Man","archetype":"Infiltrator","signature":"Infiltrate","stats":{"max_wounds":3,"armour":"Light","speed":7,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_KOMMANDO","ATK_ORK_KOMMANDO_BOMB"],"ability_packet_ids":["ABIL_ORK_KOMMANDO_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Sneaky Choppa","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003e2W","armour":"6+","base":"Circle / Normal","note":"Infiltrate: deploys forward + hidden; first attack is Backstab. Stikkbomb (1 use)."}},{"schema_version":1,"definition_id":"ORK_SNEAKYGIT","name":"Sneaky Git","role":"Skirmisher","tool":"Melee","creature_type":"Man","archetype":"Assassin","signature":"Gang Up","stats":{"max_wounds":2,"armour":"Light","speed":7,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_SNEAKYGIT"],"ability_packet_ids":["ABIL_ORK_SNEAKYGIT_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Shiv","dice":3,"hit":"4+","tiers":"1-\u003e1W · 3-\u003e2W · 5-\u003eExecute","armour":"6+","base":"Circle / Normal","note":"Gang Up: +2 dice while another Ork is engaged with the same target."}},{"schema_version":1,"definition_id":"ORK_GOBLINARCHER","name":"Goblin Archer","role":"Skirmisher","tool":"Ranged","creature_type":"Man","archetype":"Grot Archer","signature":"Multi-Shot Spray","stats":{"max_wounds":1,"armour":"None","speed":7,"max_ap":2,"nerve":1,"rank":"I"},"base":{"shape":"Square","class":"Small","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_GOBLINARCHER"],"ability_packet_ids":["ABIL_ORK_GOBLINARCHER_1"],"temperament":"Cowardly","display":{"card_image_url":"","weapon":"Short Bow","dice":2,"hit":"5+","tiers":"1-\u003e1W · 2-\u003e2W","armour":"—","base":"Square / Small","note":"Multi-Shot standard - sprays two weak shots. Fragile chaff-clearer."}},{"schema_version":1,"definition_id":"ORK_PAINBOY","name":"Painboy","role":"Support","tool":"Utility","creature_type":"Man","archetype":"Field Medic","signature":"Stimm","stats":{"max_wounds":3,"armour":"Light","speed":6,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_PAINBOY"],"ability_packet_ids":["ABIL_ORK_PAINBOY_1","ABIL_ORK_PAINBOY_2"],"temperament":"Protective","display":{"card_image_url":"","weapon":"Saw","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003e2W","armour":"6+","base":"Circle / Normal","note":"Patch x2 (base contact). Stimm: +1 die \u0026 ignore Knockdown, then 1 Wound."}},{"schema_version":1,"definition_id":"ORK_WEIRDBOY","name":"Weirdboy","role":"Control","tool":"Ranged","creature_type":"Man","archetype":"Warp Mage","signature":"Warp Risk","stats":{"max_wounds":2,"armour":"None","speed":6,"max_ap":2,"nerve":0,"rank":"I"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_WEIRDBOY"],"ability_packet_ids":["ABIL_ORK_WEIRDBOY_1"],"temperament":"Ravenous","display":{"card_image_url":"","weapon":"Da Krunch","dice":4,"hit":"4+","tiers":"1-\u003e1W · 3-\u003e2W + Knockdown","armour":"—","base":"Circle / Normal","note":"Warp blast: hits all within 4cm. \u003e=2 misses -\u003e Weirdboy takes 1 Wound + scatter."}},{"schema_version":1,"definition_id":"ORK_SQUIG","name":"Squig","role":"Skirmisher","tool":"Melee","creature_type":"Beast","archetype":"Runner Beast","signature":"Boing","stats":{"max_wounds":2,"armour":"Light","speed":10,"max_ap":2,"nerve":0,"rank":"I"},"base":{"shape":"Circle","class":"Small","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_SQUIG"],"ability_packet_ids":["ABIL_ORK_SQUIG_1"],"temperament":"Ravenous","display":{"card_image_url":"","weapon":"Chompa","dice":2,"hit":"4+","tiers":"1-\u003e1W · 3-\u003e2W","armour":"6+","base":"Circle / Small","note":"Boing: must Sprint 14\" toward nearest enemy each activation."}},{"schema_version":1,"definition_id":"ORK_TROLL","name":"Troll","role":"Anchor","tool":"Melee","creature_type":"Beast","archetype":"Regenerating Brute","signature":"Regeneration","counter_uses":1,"stats":{"max_wounds":8,"armour":"Light","speed":6,"max_ap":3,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Large","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_TROLL"],"ability_packet_ids":["ABIL_ORK_TROLL_1","ABIL_ORK_TROLL_2"],"temperament":"Ravenous","display":{"card_image_url":"","weapon":"Big Club","dice":3,"hit":"5+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003e3W + Knockdown","armour":"6+","base":"Circle / Large","note":"Regeneration: recover 1 Wound each activation. Brutal: Counter +1 die."}},{"schema_version":1,"definition_id":"ORK_SQUIGGOTH","name":"Great Squiggoth","role":"Assault","tool":"Melee","creature_type":"Beast","archetype":"Monstrous Beast","signature":"Unstoppable","stats":{"max_wounds":12,"armour":"Medium","speed":7,"max_ap":3,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Monstrous","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_SQUIGGOTH"],"ability_packet_ids":["ABIL_ORK_SQUIGGOTH_1","ABIL_ORK_SQUIGGOTH_2"],"temperament":"Ravenous","display":{"card_image_url":"","weapon":"Goring Charge","dice":4,"hit":"5+","tiers":"1-\u003e1W · 2-\u003e2W + Push · 4-\u003e3W + Knockdown + Cleave","armour":"5+","base":"Circle / Monstrous","note":"Unstoppable by bodies - only a wall jams it (crush +2 dice). Tramples on the charge."}},{"schema_version":1,"definition_id":"ORK_BOARBOY","name":"Boar Boy","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Boar Cavalry","signature":"Boar Charge","stats":{"max_wounds":3,"armour":"Light","speed":12,"max_ap":2,"nerve":2,"rank":"II"},"base":{"shape":"Square","class":"Cavalry","mounted":true,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_BOARBOY"],"ability_packet_ids":["ABIL_ORK_BOARBOY_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Choppa \u0026 Tusks","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003ePush · 3-\u003e2W + Knockdown","armour":"6+","base":"Square / Cavalry","note":"Mounted - charges a class up (tusk plow). Fast green shock cavalry."}},{"schema_version":1,"definition_id":"ORK_WARBOAR","name":"Warboar Rider","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Heavy Cavalry","signature":"Gore Charge","stats":{"max_wounds":4,"armour":"Medium","speed":12,"max_ap":2,"nerve":2,"rank":"II"},"base":{"shape":"Square","class":"Cavalry","mounted":true,"forward_axis":"local_z"},"attack_packet_ids":["ATK_ORK_WARBOAR"],"ability_packet_ids":["ABIL_ORK_WARBOAR_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Tusker Lance","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003e2W + Push · 3-\u003e3W + Knockdown","armour":"5+","base":"Square / Cavalry","note":"Mounted lance - plows a class up, hits hardest on impact. Armoured warboar."}}]},{"faction":"Sauron","prefix":"SAU","attack_packets":[{"id":"ATK_SAU_CAPTAIN","alias":"Morgul Blade","parent_action":"ATTACK","dice":3,"hit":3,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":2,"effects":["ignore Armour"]}]},{"id":"ATK_SAU_WARRIOR","alias":"Orc Scimitar","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Push"]}]},{"id":"ATK_SAU_SHIELD","alias":"Uruk Blade \u0026 Shield","parent_action":"ATTACK","dice":3,"hit":3,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":1,"effects":["Guard"]}]},{"id":"ATK_SAU_PIKE","alias":"Long Pike","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee","Reach","never countered"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Push"]}]},{"id":"ATK_SAU_BERSERKER","alias":"Two-Handed Cleaver","parent_action":"ATTACK","dice":3,"hit":5,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":2,"effects":["Cleave"]}]},{"id":"ATK_SAU_STALKER","alias":"Twin Knives","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]}]},{"id":"ATK_SAU_ASSASSIN","alias":"Poisoned Blade","parent_action":"ATTACK","dice":3,"hit":3,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":2,"effects":[]},{"successes":5,"wounds":2,"effects":["Execute"]}]},{"id":"ATK_SAU_CROSSBOW","alias":"Heavy Crossbow","parent_action":"ATTACK","dice":2,"hit":3,"range":24,"area":null,"cost_ap":1,"tags":["Ranged","no Multi-Shot","never countered"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]}]},{"id":"ATK_SAU_SORCERER","alias":"Black Breath","parent_action":"ATTACK","dice":3,"hit":4,"range":12,"area":4,"cost_ap":1,"tags":["Ranged"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":3,"wounds":2,"effects":["Knockdown"]}]},{"id":"ATK_SAU_TASKMASTER","alias":"Barbed Whip","parent_action":"ATTACK","dice":2,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee","Reach"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Push"]}]},{"id":"ATK_SAU_WARG","alias":"Warg Fangs \u0026 Lance","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Push"]},{"successes":3,"wounds":2,"effects":["Knockdown"]}]},{"id":"ATK_SAU_KNIGHT","alias":"Morgul Lance","parent_action":"ATTACK","dice":3,"hit":3,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":1,"effects":["Push"]},{"successes":3,"wounds":2,"effects":[]}]},{"id":"ATK_SAU_TROLL","alias":"Troll Fists","parent_action":"ATTACK","dice":3,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":2,"effects":["Knockdown","Push"]}]},{"id":"ATK_SAU_OLOG","alias":"Great Maul","parent_action":"ATTACK","dice":4,"hit":4,"range":0,"area":null,"cost_ap":1,"tags":["Melee"],"tiers":[{"successes":1,"wounds":1,"effects":[]},{"successes":2,"wounds":2,"effects":[]},{"successes":3,"wounds":3,"effects":["Knockdown"]}]}],"ability_packets":[{"id":"ABIL_SAU_DREAD_1","alias":"Dread Aura","type":"Passive","parent_action":null,"note":"Enemy Squares within 6\" test Nerve one step worse.","tags":[]},{"id":"ABIL_SAU_SPIRIT_1","alias":"Wraith","type":"Passive","parent_action":null,"note":"Spirit: never tests Nerve; radiates Dread.","tags":[]},{"id":"ABIL_SAU_SHIELDWALL_1","alias":"Shield Wall","type":"Reactive","parent_action":"READY","note":"Base-to-base with another Uruk: +1 die defending a Counter.","tags":[]},{"id":"ABIL_SAU_REACH_1","alias":"Reach","type":"Passive","parent_action":null,"note":"Threatens its band; no lock, no Counter suffered.","tags":[]},{"id":"ABIL_SAU_BRACE_1","alias":"Brace","type":"Reactive","parent_action":"READY","note":"+1 die striking an enemy that Charged this turn.","tags":[]},{"id":"ABIL_SAU_FRENZY_1","alias":"Blood Frenzy","type":"Passive","parent_action":null,"note":"+1 die on a Charge; cannot Guard.","tags":[]},{"id":"ABIL_SAU_INFILTRATE_1","alias":"Stalk","type":"Passive","parent_action":null,"note":"Deploys forward and hidden; first strike from stealth counts as Backstab.","tags":[]},{"id":"ABIL_SAU_BACKSTAB_1","alias":"Backstab","type":"Passive","parent_action":null,"note":"+2 dice from the rear; ignores Counter.","tags":[]},{"id":"ABIL_SAU_OVERWATCH_1","alias":"Overwatch","type":"Reactive","parent_action":"READY","note":"Enemy enters LoS in range: resolve a Regular Shot.","tags":["Ranged"]},{"id":"ABIL_SAU_CURSE_1","alias":"Curse of Morgul","type":"Active","parent_action":"USE","note":"Enemies within 4\" of a point roll Armour one step worse until your next turn.","tags":[]},{"id":"ABIL_SAU_WHIP_1","alias":"Drive Them On","type":"Active","parent_action":"USE","note":"A friendly Orc within 3\" makes an immediate free MOVE, then takes 1 Wound.","tags":[]},{"id":"ABIL_SAU_PACK_1","alias":"Pack Hunter","type":"Passive","parent_action":null,"note":"+1 die if another Warg Rider is engaged with the same target.","tags":[]},{"id":"ABIL_SAU_LARGE_1","alias":"Large","type":"Passive","parent_action":null,"note":"Large base: plows same-size bodies; blocks LoS.","tags":[]},{"id":"ABIL_SAU_MONSTROUS_1","alias":"Monstrous","type":"Passive","parent_action":null,"note":"Monstrous: unstoppable by bodies; only a wall jams it.","tags":[]},{"id":"ABIL_SAU_REGEN_1","alias":"Troll Hide","type":"Passive","parent_action":null,"note":"Recover 1 Wound at the start of each activation.","tags":[]}],"units":[{"schema_version":1,"definition_id":"SAU_CAPTAIN","name":"Morgul Captain","role":"Support","tool":"Melee","creature_type":"Spirit","archetype":"Dread Commander","signature":"Dread Aura","counter_uses":2,"stats":{"max_wounds":4,"armour":"Medium","speed":7,"max_ap":3,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_SAU_CAPTAIN"],"ability_packet_ids":["ABIL_SAU_DREAD_1","ABIL_SAU_SPIRIT_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Morgul Blade","dice":3,"hit":"3+","tiers":"1-\u003e1W · 3-\u003e2W + ignore Armour","armour":"5+","base":"Circle / Normal","note":"Nazgul — never tests Nerve. Dread aura. Counter 2."}},{"schema_version":1,"definition_id":"SAU_WARRIOR","name":"Mordor Orc Warrior","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Horde Warrior","signature":"Mob","stats":{"max_wounds":2,"armour":"Light","speed":6,"max_ap":2,"nerve":2,"rank":"I"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_SAU_WARRIOR"],"ability_packet_ids":[],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Orc Scimitar","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003ePush","armour":"6+","base":"Square / Normal","note":"The cruel horde — numerous, expendable."}},{"schema_version":1,"definition_id":"SAU_SHIELD","name":"Uruk-hai Shieldbearer","role":"Anchor","tool":"Melee","creature_type":"Man","archetype":"Sentinel","signature":"Shield Wall","stats":{"max_wounds":3,"armour":"Heavy","speed":5,"max_ap":2,"nerve":3,"rank":"II"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_SAU_SHIELD"],"ability_packet_ids":["ABIL_SAU_SHIELDWALL_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Uruk Blade \u0026 Shield","dice":3,"hit":"3+","tiers":"1-\u003e1W · 3-\u003eGuard","armour":"4+","base":"Square / Normal","note":"Elite, disciplined. Holds the line."}},{"schema_version":1,"definition_id":"SAU_PIKE","name":"Orc Pikeman","role":"Anchor","tool":"Melee","creature_type":"Man","archetype":"Pikeman","signature":"Brace","stats":{"max_wounds":2,"armour":"Light","speed":6,"max_ap":2,"nerve":2,"rank":"I"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_SAU_PIKE"],"ability_packet_ids":["ABIL_SAU_REACH_1","ABIL_SAU_BRACE_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Long Pike (Reach)","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003ePush","armour":"6+","base":"Square / Normal","note":"Reach: no lock, no Counter suffered. Punishes charges."}},{"schema_version":1,"definition_id":"SAU_BERSERKER","name":"Uruk Berserker","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Berserker","signature":"Blood Frenzy","stats":{"max_wounds":3,"armour":"Medium","speed":6,"max_ap":2,"nerve":3,"rank":"II"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_SAU_BERSERKER"],"ability_packet_ids":["ABIL_SAU_FRENZY_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Two-Handed Cleaver","dice":3,"hit":"5+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003eCleave","armour":"5+","base":"Square / Normal","note":"Swingy top-rung ladder; +1 die on Charge, cannot Guard."}},{"schema_version":1,"definition_id":"SAU_STALKER","name":"Morgul Stalker","role":"Skirmisher","tool":"Melee","creature_type":"Man","archetype":"Scout","signature":"Stalk","stats":{"max_wounds":2,"armour":"None","speed":8,"max_ap":2,"nerve":0,"rank":"II"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_SAU_STALKER"],"ability_packet_ids":["ABIL_SAU_INFILTRATE_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Twin Knives","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003e2W","armour":"—","base":"Circle / Normal","note":"Infiltrates; first strike from stealth is Backstab."}},{"schema_version":1,"definition_id":"SAU_ASSASSIN","name":"Black Numenorean Assassin","role":"Skirmisher","tool":"Melee","creature_type":"Man","archetype":"Assassin","signature":"Backstab","stats":{"max_wounds":2,"armour":"Light","speed":8,"max_ap":3,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_SAU_ASSASSIN"],"ability_packet_ids":["ABIL_SAU_BACKSTAB_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Poisoned Blade","dice":3,"hit":"3+","tiers":"1-\u003e1W · 3-\u003e2W · 5-\u003eExecute","armour":"6+","base":"Circle / Normal","note":"Circle hero (3 AP). Reaches Execute via positional dice."}},{"schema_version":1,"definition_id":"SAU_CROSSBOW","name":"Orc Crossbow","role":"Skirmisher","tool":"Ranged","creature_type":"Man","archetype":"Marksman","signature":"Heavy Bolt","stats":{"max_wounds":1,"armour":"None","speed":6,"max_ap":2,"nerve":2,"rank":"I"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_SAU_CROSSBOW"],"ability_packet_ids":["ABIL_SAU_OVERWATCH_1"],"temperament":"Cowardly","display":{"card_image_url":"","weapon":"Heavy Crossbow","dice":2,"hit":"3+","tiers":"1-\u003e1W · 2-\u003e2W","armour":"—","base":"Square / Normal","note":"No Multi-Shot, never countered. Reliable long-range punch."}},{"schema_version":1,"definition_id":"SAU_SORCERER","name":"Mouth of Sauron","role":"Control","tool":"Utility","creature_type":"Man","archetype":"Dark Sorcerer","signature":"Curse of Morgul","stats":{"max_wounds":3,"armour":"Medium","speed":6,"max_ap":3,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_SAU_SORCERER"],"ability_packet_ids":["ABIL_SAU_CURSE_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Black Breath (area)","dice":3,"hit":"4+","tiers":"1-\u003e1W · 3-\u003e2W + Knockdown","armour":"5+","base":"Circle / Normal","note":"Area curse: enemies save one step worse. Circle hero."}},{"schema_version":1,"definition_id":"SAU_TASKMASTER","name":"Orc Taskmaster","role":"Support","tool":"Utility","creature_type":"Man","archetype":"Overseer","signature":"Drive Them On","stats":{"max_wounds":2,"armour":"Light","speed":6,"max_ap":2,"nerve":3,"rank":"II"},"base":{"shape":"Square","class":"Normal","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_SAU_TASKMASTER"],"ability_packet_ids":["ABIL_SAU_WHIP_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Barbed Whip (Reach)","dice":2,"hit":"4+","tiers":"1-\u003e1W · 2-\u003ePush","armour":"6+","base":"Square / Normal","note":"Whips orcs into a free Move at the cost of a Wound."}},{"schema_version":1,"definition_id":"SAU_WARG","name":"Warg Rider","role":"Assault","tool":"Melee","creature_type":"Man","archetype":"Lancer","signature":"Pack Hunter","stats":{"max_wounds":2,"armour":"Light","speed":12,"max_ap":2,"nerve":2,"rank":"I"},"base":{"shape":"Square","class":"Cavalry","mounted":true,"forward_axis":"local_z"},"attack_packet_ids":["ATK_SAU_WARG"],"ability_packet_ids":["ABIL_SAU_PACK_1"],"temperament":"Aggressive","display":{"card_image_url":"","weapon":"Warg Fangs \u0026 Lance","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003ePush · 3-\u003eKnockdown","armour":"6+","base":"Cavalry / mounted","note":"Mounted: charges a class up. Fast flanking pack."}},{"schema_version":1,"definition_id":"SAU_KNIGHT","name":"Morgul Knight","role":"Assault","tool":"Melee","creature_type":"Spirit","archetype":"Black Rider","signature":"Wraith","counter_uses":2,"stats":{"max_wounds":3,"armour":"Heavy","speed":13,"max_ap":3,"nerve":0,"rank":"III"},"base":{"shape":"Circle","class":"Cavalry","mounted":true,"forward_axis":"local_z"},"attack_packet_ids":["ATK_SAU_KNIGHT"],"ability_packet_ids":["ABIL_SAU_SPIRIT_1","ABIL_SAU_DREAD_1"],"temperament":"Resolute","display":{"card_image_url":"","weapon":"Morgul Lance","dice":3,"hit":"3+","tiers":"1-\u003e1W · 2-\u003ePush · 3-\u003e2W","armour":"4+","base":"Cavalry / mounted","note":"Wraith rider — never tests Nerve. Dread aura. Counter 2."}},{"schema_version":1,"definition_id":"SAU_TROLL","name":"Cave Troll","role":"Assault","tool":"Melee","creature_type":"Beast","archetype":"Brute","signature":"Large","stats":{"max_wounds":6,"armour":"Medium","speed":6,"max_ap":3,"nerve":4,"rank":"II"},"base":{"shape":"Square","class":"Large","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_SAU_TROLL"],"ability_packet_ids":["ABIL_SAU_LARGE_1"],"temperament":"Ravenous","display":{"card_image_url":"","weapon":"Troll Fists","dice":3,"hit":"4+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003eKnockdown + Push","armour":"5+","base":"Square / Large","note":"Large-base monster. Beast — tests Nerve; Ravenous."}},{"schema_version":1,"definition_id":"SAU_OLOG","name":"Olog-hai","role":"Assault","tool":"Melee","creature_type":"Beast","archetype":"War Troll","signature":"Monstrous","stats":{"max_wounds":8,"armour":"Heavy","speed":6,"max_ap":3,"nerve":5,"rank":"III"},"base":{"shape":"Square","class":"Monstrous","mounted":false,"forward_axis":"local_z"},"attack_packet_ids":["ATK_SAU_OLOG"],"ability_packet_ids":["ABIL_SAU_MONSTROUS_1","ABIL_SAU_REGEN_1"],"temperament":"Ravenous","display":{"card_image_url":"","weapon":"Great Maul","dice":4,"hit":"4+","tiers":"1-\u003e1W · 2-\u003e2W · 3-\u003e3W + Knockdown","armour":"4+","base":"Square / Monstrous","note":"Monstrous — unstoppable by bodies; regenerates 1W/activation."}}]}]
]==]


-- ===== end data/unit_library =====
-- ===== begin objects/Fixture =====
-- objects/Fixture.lua
-- Optional playable test fixture. Spawns scripted CARD tiles + MINIATURE blocks
-- and auto-links them, so every acceptance test can be run immediately.
--
-- It works by spawning plain objects and attaching COMPACT stub scripts (below)
-- via setLuaScript()+reload(). The stubs implement the same callable contract as
-- the full CardController / MiniatureController object scripts; all heavy logic
-- still lives in Global. For a production table, paste the full object scripts
-- instead (see docs/SETUP.md).

CUS = CUS or {}
local Fixture = {}

-- Compact CARD stub: definition is injected via GM Notes at spawn time.
local CARD_STUB = [[
CUS_CARD = true
local definition = nil
function getDefinition() return definition end
function getDefinitionId() return definition and definition.definition_id end
function getCardImageUrl() return definition and definition.display and definition.display.card_image_url end
function validateDefinition() return { ok = definition ~= nil, errors = {} } end
function setDefinition(d) definition = d; self.setGMNotes(JSON.encode_pretty(d)) end
function onSave() return JSON.encode({ definition = definition }) end
function onLoad(s)
  if s and s ~= "" then local ok,b = pcall(function() return JSON.decode(s) end); if ok and b then definition = b.definition end end
  if not definition then
    local n = self.getGMNotes()
    if n and n ~= "" then local ok,d = pcall(function() return JSON.decode(n) end); if ok then definition = d end end
  end
  self.addContextMenuItem("Link Selected Miniature", function(pc) Global.call("cardLinkSelectedMini", { card = self, player = pc }) end)
  self.addContextMenuItem("Highlight Linked Miniature", function(pc) Global.call("cardHighlightLinkedMini", { card = self, player = pc }) end)
  self.addContextMenuItem("Open Unit Library (stamp this card)", function(pc) Global.call("openUnitLibrary", { player = pc, card = self.getGUID() }) end)
  self.addContextMenuItem("Render Card Face", function() Global.call("renderCardFace", { card = self.getGUID() }) end)
  self.addContextMenuItem("Edit Card Layout", function(pc) Global.call("openLayoutEditor", { player = pc, card = self.getGUID() }) end)
end
]]

-- Compact MINIATURE stub (mirrors MiniatureController's contract).
local MINI_STUB = [[
CUS_MINI = true
local persist = { card_guid = nil, expected_definition_id = nil, runtime_state = { schema_version = 1, state = {
  current_wounds = 1, current_ap = 2, activated = false, moved_this_activation = false, attacked_this_activation = false,
  ready_packet_id = nil, reaction_spent = false, counter_uses_remaining = 1, conditions = {}, morale = "Steady",
  facing_locked = false, forward_axis = "local_z", movement_session = nil, formation = nil, temporary_modifiers = {} } } }
function getLink() return { card_guid = persist.card_guid, expected_definition_id = persist.expected_definition_id, runtime_state = persist.runtime_state } end
function getRuntimeState() return { schema_version = persist.runtime_state.schema_version, card_guid = persist.card_guid, expected_definition_id = persist.expected_definition_id, state = persist.runtime_state.state } end
function setRuntimeState(rs) persist.card_guid = rs.card_guid or persist.card_guid; persist.expected_definition_id = rs.expected_definition_id or persist.expected_definition_id; persist.runtime_state = { schema_version = rs.schema_version or 1, state = rs.state } end
function onSave() return JSON.encode(persist) end
function onLoad(s)
  if s and s ~= "" then local ok,b = pcall(function() return JSON.decode(s) end); if ok and b then persist = b end end
  Wait.frames(function() Global.call("registerMiniature", { guid = self.getGUID() }) end, 2)
  self.addContextMenuItem("CUS Actions (Wheel)", function(pc) Global.call("openRadialFor", { guid = self.getGUID(), player = pc }) end)
  self.addContextMenuItem("Open Linked Card", function(pc) Global.call("openLinkedCard", { guid = self.getGUID(), player = pc }) end)
  self.addContextMenuItem("Link Selected Card", function(pc) Global.call("beginLinkFromMini", { guid = self.getGUID(), player = pc }) end)
  self.addContextMenuItem("Re-sync From Card", function(pc) Global.call("resyncFromCard", { guid = self.getGUID(), player = pc }) end)
  self.addContextMenuItem("Nerve Test", function(pc) Global.call("openNerve", { guid = self.getGUID(), player = pc }) end)
end
local function fwd(fn, player, button) Global.call(fn, { guid = self.getGUID(), player = player and player.color, alt = (button == "-2") }) end
function stateClickActivation(p,b) fwd("uiToggleActivation",p,b) end
function stateClickAP(p,b) fwd("uiSpendAP",p,b) end
function stateClickWound(p,b) fwd("uiApplyWound",p,b) end
function stateClickReady(p,b) fwd("uiInspectReady",p,b) end
function stateClickConditions(p,b) fwd("uiOpenConditions",p,b) end
function stateClickCard(p,b) fwd("openLinkedCard",p,b) end
]]

-- spawn one scripted card at pos with the given unit definition table.
-- Uses a plain BlockRectangle (no custom-image requirement) as the card body;
-- for a real card face, set the definition's display.card_image_url and paste
-- the full CardController onto a proper card object instead.
-- IMPORTANT: reload() invalidates the pre-reload object reference (and can swap
-- GUIDs), so we do ALL setup (script + GM Notes) BEFORE the single reload, and
-- afterwards only ever touch objects via getObjectFromGUID(guid). We return the
-- GUID and confirm the definition parsed before linking.
local function spawnCard(def, pos)
  local card = spawnObject({ type = "BlockRectangle", position = pos, scale = { 1.4, 0.2, 2.0 } })
  card.setColorTint({ 0.85, 0.82, 0.7 })
  card.setName(def.name)
  card.setGMNotes(JSON.encode(def))   -- set BEFORE reload; CARD_STUB.onLoad reads it
  card.setLuaScript(CARD_STUB)
  card.reload()
  return card.getGUID()
end

local function spawnMini(pos, colorTint)
  local mini = spawnObject({ type = "BlockSquare", position = pos, scale = { 0.6, 0.6, 0.6 } })
  mini.setColorTint(colorTint or { 0.7, 0.7, 0.8 })
  mini.setLuaScript(MINI_STUB)
  mini.reload()
  return mini.getGUID()
end

-- Spawn a 2-card / 2-mini fixture and auto-link once the scripts have compiled.
function Fixture.spawn()
  local units = CUS.SAMPLE_UNITS
  if not units or #units < 2 then CUS.Logger.warn("No sample units to spawn."); return end
  local sword = units[1]   -- Militia Swordsman
  local boss  = units[4]   -- Goblin Warboss (Circle/Large)

  local c1 = spawnCard(sword, { -6, 1.5, 4 })
  local c2 = spawnCard(boss,  {  6, 1.5, 4 })
  local m1 = spawnMini({ -6, 1.5, -2 }, { 0.4, 0.7, 1.0 })
  local m2 = spawnMini({  6, 1.5, -2 }, { 1.0, 0.5, 0.4 })

  -- Poll (up to ~5s) until both cards report a valid definition, THEN link.
  local tries = 0
  local function tryLink()
    tries = tries + 1
    local cardOk = function(g)
      local o = getObjectFromGUID(g)
      if not o or not o.getVar or o.getVar("getDefinition") == nil then return false end
      local ok, def = pcall(function() return o.call("getDefinition") end)
      return ok and type(def) == "table"
    end
    if cardOk(c1) and cardOk(c2) then
      doLink(m1, c1)
      doLink(m2, c2)
      CUS.StatePanel.refreshAll()
      CUS.Logger.log("Test fixture spawned & linked: Militia Swordsman vs Goblin Warboss.")
    elseif tries < 100 then
      Wait.frames(tryLink, 5)
    else
      CUS.Logger.warn("Fixture: cards did not finish loading in time — link them manually.")
    end
  end
  Wait.frames(tryLink, 20)
end

-- Spawn a single BLANK scripted card the player can then stamp from the Unit
-- Library. Returns the spawned card's GUID.
function Fixture.spawnBlankCard(pos)
  pos = pos or { 0, 2, 6 }
  local card = spawnObject({ type = "BlockRectangle", position = pos, scale = { 1.4, 0.2, 2.0 } })
  card.setColorTint({ 0.85, 0.82, 0.7 })
  card.setName("Blank CUS Card")
  card.setLuaScript(CARD_STUB)
  card.reload()
  if CUS.Logger then CUS.Logger.log("Blank card spawned — left-click it, then Unit Library → pick a unit, THEN link a miniature to it.") end
  return card.getGUID()
end

CUS.Fixture = Fixture

-- ===== end objects/Fixture =====

-- --------------------------------------------------------------------------
-- shared helpers on the CUS table
-- --------------------------------------------------------------------------

-- Write a miniature's working runtime state back to its object (authoritative
-- persistence) and refresh its floating StatePanel.
function CUS.pushRuntimeToMini(guid)
  local mini = getObjectFromGUID(guid)
  if not mini then return end
  local rs = CUS.StateStore.getOrInit(guid)
  pcall(function() mini.call("setRuntimeState", {
    schema_version         = rs.schema_version,
    card_guid              = rs.card_guid,
    expected_definition_id = rs.expected_definition_id,
    state                  = rs.state,
  }) end)
  if CUS.StatePanel then CUS.StatePanel.refresh(mini) end
end

-- transient controller state (file-scope so hotkey closures capture them)
local activeMovers = {}   -- guid -> true while held during a MOVE session
pendingAttack = nil       -- { attacker, packet, mode, player } during targeting

-- ==========================================================================
-- boot
-- ==========================================================================
function onLoad(savedState)
  -- restore or fresh-load registries
  local blob = nil
  if savedState and savedState ~= "" then
    local ok, decoded = pcall(function() return JSON.decode(savedState) end)
    if ok then blob = decoded end
  end

  -- Always build the layout + unit catalog (they are content, not runtime state).
  loadCardLayout()
  buildUnitLibrary()

  if blob then
    CUS.PacketRegistry.restore(blob.packets)
    CUS.StateStore.restore(blob.store)
    CUS.RoundManager.restore(blob.round)
    CUS.Logger.restore(blob.log)
    if blob.layout then CUS.CARD_LAYOUT = blob.layout end   -- keep edited layout
  else
    CUS.PacketRegistry.load(CUS.SAMPLE_PACKETS)              -- baseline sample packets
  end
  -- Merge every faction's packets into the registry (idempotent; library is the
  -- real content, samples are just the boot fixture).
  registerLibraryPackets()

  CUS.Logger.roundProvider = function() return CUS.RoundManager.round end
  registerHotkeys()

  -- discover any miniatures already on the table (they also self-register)
  Wait.frames(function()
    scanMiniatures()
    UI.setAttribute("rm_round", "text", "Round " .. CUS.RoundManager.round)
    UI.show("cus_round")
    CUS.StatePanel.refreshAll()
    CUS.Logger.log("CUS controller ready. Right-click a miniature → CUS Actions.", { broadcast = true })
  end, 5)
end

function onSave()
  return JSON.encode({
    packets = CUS.PacketRegistry.serialize(),
    store   = CUS.StateStore.serialize(),
    round   = CUS.RoundManager.serialize(),
    log     = CUS.Logger.serialize(),
    layout  = CUS.CARD_LAYOUT,
  })
end

-- ==========================================================================
-- content loaders: card layout + unit library (built from embedded JSON)
-- ==========================================================================
function loadCardLayout()
  local ok, decoded = pcall(function() return JSON.decode(CUS.CARD_LAYOUT_JSON) end)
  if ok and type(decoded) == "table" then
    CUS.CARD_LAYOUT = decoded
  else
    CUS.Logger.warn("card_layout.lua JSON failed to parse; using empty layout.", { broadcast = false })
    CUS.CARD_LAYOUT = { card = {}, zones = {} }
  end
end

-- Decode CUS.UNIT_LIBRARY_JSON (a list of faction objects) into
-- CUS.UNIT_LIBRARY = { factions = {...}, byId = {...} }.
function buildUnitLibrary()
  CUS.UNIT_LIBRARY = { factions = {}, byId = {} }
  local raw = CUS.UNIT_LIBRARY_JSON
  if not raw then return end
  local ok, decoded = pcall(function() return JSON.decode(raw) end)
  if not ok or type(decoded) ~= "table" then
    CUS.Logger.warn("unit_library.lua JSON failed to parse.", { broadcast = false })
    return
  end
  for _, f in ipairs(decoded) do
    CUS.UNIT_LIBRARY.factions[#CUS.UNIT_LIBRARY.factions + 1] = f
    for _, u in ipairs(f.units or {}) do
      CUS.UNIT_LIBRARY.byId[u.definition_id] = u
    end
  end
  local n = 0; for _ in pairs(CUS.UNIT_LIBRARY.byId) do n = n + 1 end
  CUS.Logger.log(("Unit library loaded: %d factions, %d units.")
    :format(#CUS.UNIT_LIBRARY.factions, n), { broadcast = false })
end

-- Merge every faction's attack/ability packets into the live registry.
function registerLibraryPackets()
  for _, f in ipairs((CUS.UNIT_LIBRARY and CUS.UNIT_LIBRARY.factions) or {}) do
    for _, p in ipairs(f.attack_packets or {}) do
      local okp = select(1, CUS.Schema.validateAttackPacket(p))
      if okp then CUS.PacketRegistry.attacks[p.id] = p end
    end
    for _, p in ipairs(f.ability_packets or {}) do
      local okp = select(1, CUS.Schema.validateAbilityPacket(p))
      if okp then CUS.PacketRegistry.abilities[p.id] = p end
    end
  end
end

-- Miniatures announce themselves here (called from the object script onLoad).
function registerMiniature(p)
  local mini = getObjectFromGUID(p.guid)
  if not mini then return end
  local link = mini.call("getRuntimeState")
  if link then CUS.StateStore.set(p.guid, CUS.Schema.migrateRuntimeState(link)) end
  CUS.StatePanel.refresh(mini)
end

-- Fallback discovery: anything tagged as a CUS miniature.
function scanMiniatures()
  for _, obj in ipairs(getAllObjects()) do
    if obj.getVar and obj.getVar("CUS_MINI") ~= nil then
      registerMiniature({ guid = obj.getGUID() })
    end
  end
end

-- ==========================================================================
-- per-frame: sample active MOVE sessions of held miniatures
-- ==========================================================================
function onObjectPickUp(player, obj)
  local guid = obj.getGUID()
  local rs = CUS.StateStore.get(guid)
  if rs and rs.state.movement_session and rs.state.movement_session.active then
    activeMovers[guid] = true
    rs.state.movement_session.holding = true
  end
end

function onObjectDrop(player, obj)
  local guid = obj.getGUID()
  if activeMovers[guid] then
    activeMovers[guid] = nil
    local rs = CUS.StateStore.get(guid)
    if rs and rs.state.movement_session then
      rs.state.movement_session.holding = false
      CUS.MovementResolver.sample(guid)   -- capture final position of this pickup
    end
  end
end

function update()
  for guid in pairs(activeMovers) do
    local rs = CUS.StateStore.get(guid)
    if rs and rs.state.movement_session and rs.state.movement_session.active then
      CUS.MovementResolver.sample(guid)
    else
      activeMovers[guid] = nil   -- prune finished/cancelled sessions
    end
  end
end

-- ==========================================================================
-- named hotkeys
-- ==========================================================================
-- NOTE: the addHotkey callback's first argument is the player COLOR STRING
-- (not a Player object), followed by the hovered object.
function registerHotkeys()
  addHotkey("CUS: Action Wheel", function(pcolor, hovered) withHovered(hovered, function(g) CUS.RadialWheel.open(g, pcolor) end) end)
  addHotkey("CUS: Open Card",    function(pcolor, hovered) withHovered(hovered, function(g) openLinkedCard({ guid = g, player = pcolor }) end) end)
  addHotkey("CUS: Move",         function(pcolor, hovered) withHovered(hovered, function(g) startMove(g, pcolor) end) end)
  -- CUS: Action is context-smart: if an attack is pending its target, the
  -- HOVERED miniature becomes the defender; otherwise it begins the flow on the
  -- hovered attacker. (TTS exposes no global object left-click, so target
  -- selection is hover + this hotkey — see docs/KNOWN_LIMITATIONS.md.)
  addHotkey("CUS: Action", function(pcolor, hovered)
    if pendingAttack and pendingAttack.player == pcolor then
      completeAttackTarget(hovered, pcolor)
    else
      withHovered(hovered, function(g) beginAttackFlow(g, pcolor) end)
    end
  end)
  addHotkey("CUS: Wait",         function(pcolor, hovered) withHovered(hovered, function(g) CUS.RadialWheel.open(g, pcolor); CUS.RadialWheel.branchWait() end) end)
  addHotkey("CUS: Activate / End Activation", function(pcolor, hovered) withHovered(hovered, function(g) uiToggleActivation({ guid = g, player = pcolor }) end) end)
  addHotkey("CUS: Cancel Operation", function(pcolor) cancelEverything(pcolor) end)
  addHotkey("CUS: Undo Last State Change", function() CUS.Undo.pop(); CUS.StatePanel.refreshAll() end)
end

function withHovered(hovered, fn)
  if hovered and hovered.getVar and hovered.getVar("CUS_MINI") ~= nil then
    fn(hovered.getGUID())
  else
    CUS.Logger.warn("Hover a linked miniature first.")
  end
end

function openRadialFor(p) CUS.RadialWheel.open(p.guid, p.player) end

function cancelEverything(color)
  CUS.RadialWheel.close(); CUS.AttackPanel.close(); CUS.MovementPanel.close()
  CUS.NervePanel.close(); CUS.FormationPanel.close()
  UI.hide("cus_manual"); UI.hide("cus_cond")
  CUS.ChargeAssistant.clear()
  if CUS.AttackResolver.session then CUS.AttackResolver.cancel() end
end

-- ==========================================================================
-- linking flow  (SELECTION-based — TTS has no global object left-click event)
-- ==========================================================================
-- Context-menu callbacks pass the clicking player's COLOR STRING; resolve the
-- Player to read their current selection.
local function selectedOf(color, predicateVar)
  local pl = Player[color]
  local sel = pl and pl.getSelectedObjects() or {}
  for _, o in ipairs(sel) do
    if o.getVar and o.getVar(predicateVar) ~= nil then return o end
  end
  return nil
end

-- Mini context menu: "Link Selected Card" — player selects the card, then this.
function beginLinkFromMini(p)
  local card = selectedOf(p.player, "getDefinition")
  if not card then
    CUS.Logger.warn("Select the CARD first, then use 'Link Card…' on the miniature.")
    return
  end
  doLink(p.guid, card.getGUID())
end

-- Card context menu: "Link Selected Miniature" — player selects the mini, then this.
function cardLinkSelectedMini(p)
  local mini = selectedOf(p.player, "getRuntimeState")
  if not mini then
    CUS.Logger.warn("Select a MINIATURE first, then use 'Link Selected Miniature' on the card.")
    return
  end
  doLink(mini.getGUID(), p.card.getGUID())
end

function cardHighlightLinkedMini(p)
  local cardGuid = p.card.getGUID()
  local found = false
  for guid, rs in pairs(CUS.StateStore.runtime) do
    if rs.card_guid == cardGuid then
      local m = getObjectFromGUID(guid)
      if m then m.highlightOn(CUS.Constants.COLOR.linkpair, 4); found = true end
    end
  end
  if not found then CUS.Logger.log("No miniature currently links this card.", { broadcast = false }) end
end

function doLink(miniGuid, cardGuid)
  local card = getObjectFromGUID(cardGuid)
  local defOk = card and card.getVar and card.getVar("CUS_CARD") ~= nil
  if not defOk then CUS.Logger.warn("That object is not a CUS card."); return end
  local def = card.call("getDefinition")
  if type(def) ~= "table" then CUS.Logger.warn("Card has no valid definition."); return end

  local rs = CUS.StateStore.getOrInit(miniGuid)
  rs.card_guid = cardGuid
  rs.expected_definition_id = def.definition_id
  -- initialise runtime maxima from the definition (first link only)
  if rs.state.current_wounds == nil or rs.state._fresh ~= false then
    rs.state.current_wounds = def.stats.max_wounds
    rs.state.current_ap     = def.stats.max_ap
    -- No Counter allowance to seed: B.9 (SIGNED) removed the per-round cap and
    -- the counter_x economy entirely. `def.counter_uses` on an old card is now
    -- inert data, deliberately ignored rather than silently honoured.
    rs.state.forward_axis   = (def.base and def.base.forward_axis) or CUS.Constants.TUNING.facing_axis
    rs.state._fresh = false
  end
  CUS.pushRuntimeToMini(miniGuid)
  local m = getObjectFromGUID(miniGuid)
  if m then m.highlightOn(CUS.Constants.COLOR.linkpair, 3) end
  card.highlightOn(CUS.Constants.COLOR.linkpair, 3)
  CUS.Logger.log(("Linked %s ↔ card '%s' (%s)."):format(miniGuid, def.name, def.definition_id))
end

function unlinkCard(p)
  local rs = CUS.StateStore.get(p.guid)
  if rs then rs.card_guid = nil; CUS.pushRuntimeToMini(p.guid) end
  CUS.Logger.log("Card unlinked (definition identity preserved).", { broadcast = false })
end

-- Re-sync: update maxima & packet refs WITHOUT healing or restoring AP; clamp
-- current values only if they now exceed the new maxima; preserve conditions.
function resyncFromCard(p)
  local def, reason = CUS.StateStore.getDefinition(p.guid)
  if not def then CUS.Logger.warn("Re-sync failed: " .. tostring(reason)); return end
  local rs = CUS.StateStore.getOrInit(p.guid)
  CUS.Undo.pushMiniState(getObjectFromGUID(p.guid), "re-sync from card")
  rs.expected_definition_id = def.definition_id
  -- clamp only (do NOT heal / refill)
  if rs.state.current_wounds > def.stats.max_wounds then rs.state.current_wounds = def.stats.max_wounds end
  if rs.state.current_ap and rs.state.current_ap > def.stats.max_ap then rs.state.current_ap = def.stats.max_ap end
  CUS.pushRuntimeToMini(p.guid)
  CUS.Logger.log(("Re-synced from '%s' — maxima & packets updated; wounds/AP/conditions preserved."):format(def.name))
end

function autoRelinkByDefinitionId(miniGuid)
  local rs = CUS.StateStore.get(miniGuid)
  if not rs or not rs.expected_definition_id then return end
  for _, obj in ipairs(getAllObjects()) do
    if obj.getVar and obj.getVar("CUS_CARD") ~= nil then
      local def = obj.call("getDefinition")
      if type(def) == "table" and def.definition_id == rs.expected_definition_id then
        rs.card_guid = obj.getGUID()
        CUS.pushRuntimeToMini(miniGuid)
        CUS.Logger.log("Auto-relinked by definition_id: " .. rs.expected_definition_id, { broadcast = false })
        return
      end
    end
  end
end

function openLinkedCard(p) CUS.CardViewer.openForMini(p.guid, p.player) end

function calibrateFacing(p)
  -- cycle the forward axis and report; a visible facing arrow could be added.
  local rs = CUS.StateStore.getOrInit(p.guid)
  local order = { local_z = "local_x", local_x = "local_-z", ["local_-z"] = "local_z" }
  rs.state.forward_axis = order[rs.state.forward_axis or "local_z"] or "local_z"
  CUS.pushRuntimeToMini(p.guid)
  CUS.Logger.log("Forward axis set to " .. rs.state.forward_axis .. " for " .. p.guid)
end

-- ==========================================================================
-- floating StatePanel click handlers (forwarded from the mini object script)
-- ==========================================================================
function uiToggleActivation(p)
  local st = CUS.StateStore.getOrInit(p.guid).state
  if st.activated then CUS.RoundManager.endActivation(p.guid)
  else CUS.RoundManager.beginActivation(p.guid) end
  CUS.pushRuntimeToMini(p.guid)
end

function uiSpendAP(p)
  local st = CUS.StateStore.getOrInit(p.guid).state
  CUS.Undo.pushMiniState(getObjectFromGUID(p.guid), "AP change")
  local delta = p.alt and 1 or -1     -- right-click refunds
  local def = CUS.StateStore.getDefinition(p.guid)
  local maxAp = def and def.stats.max_ap or 3
  st.current_ap = math.max(0, math.min(maxAp, (st.current_ap or 0) + delta))
  CUS.pushRuntimeToMini(p.guid)
end

function uiApplyWound(p)
  local st = CUS.StateStore.getOrInit(p.guid).state
  CUS.Undo.pushMiniState(getObjectFromGUID(p.guid), "Wound change")
  local def = CUS.StateStore.getDefinition(p.guid)
  local maxW = def and def.stats.max_wounds or 1
  local delta = p.alt and 1 or -1     -- right-click restores
  st.current_wounds = math.max(0, math.min(maxW, (st.current_wounds or 0) + delta))
  CUS.pushRuntimeToMini(p.guid)
end

function uiInspectReady(p)
  local st = CUS.StateStore.getOrInit(p.guid).state
  if st.ready_packet_id then
    CUS.Logger.log("Ready packet: " .. tostring(st.ready_packet_id) .. " (right-click State icon to cancel).")
    if p.alt then st.ready_packet_id = nil; CUS.pushRuntimeToMini(p.guid); CUS.Logger.log("Ready cancelled.") end
  else
    CUS.Logger.log("No Ready packet armed.")
  end
end

function uiOpenConditions(p) openConditions(p.guid, p.player) end

-- ==========================================================================
-- RADIAL WHEEL onClick shims
-- ==========================================================================
-- The THREE canonical roots (A.III, SIGNED).
function wheelBranchMove()   CUS.RadialWheel.branchMove()   end
function wheelBranchAction() CUS.RadialWheel.branchAction() end
function wheelBranchWait()   CUS.RadialWheel.branchWait()   end
-- Retired v0.5 roots, kept only so a stale binding still lands somewhere.
function wheelBranchAttack() CUS.RadialWheel.branchAction() end
function wheelBranchUse()    CUS.RadialWheel.branchAction() end
function wheelBranchReady()  CUS.RadialWheel.branchWait()   end
function wheelCenter()       CUS.RadialWheel.center()       end
function wheelClose()        CUS.RadialWheel.close()        end
function wheelShowRoot()     CUS.RadialWheel.showRoot()     end

-- MOVE branch
function wheelMoveBegin()  local g = CUS.RadialWheel.ctx.guid; CUS.RadialWheel.close(); startMove(g, CUS.RadialWheel.ctx.player) end
function wheelMoveCommit()  if CUS.MovementPanel.guid then CUS.MovementResolver.commit(CUS.MovementPanel.guid) end end
function wheelMoveUndo()    if CUS.MovementPanel.guid then CUS.MovementResolver.cancel(CUS.MovementPanel.guid) end end
function wheelChargeAssist() chargeAssist(CUS.RadialWheel.ctx.guid, CUS.RadialWheel.ctx.player) end
function wheelDisengage()   disengage(CUS.RadialWheel.ctx.guid) end
function wheelAdvance()     CUS.RadialWheel.close(); CUS.FormationPanel.open(CUS.RadialWheel.ctx.guid, CUS.RadialWheel.ctx.player) end
function wheelReform()      CUS.FormationAssistant.reform(CUS.RadialWheel.ctx.guid); CUS.RadialWheel.close() end
function wheelStory()       if CUS.MovementPanel.guid then CUS.MovementResolver.addStoryCost(CUS.MovementPanel.guid, 1) end end

-- ACTION / WAIT branch buttons pass their argument via onClick="fn(arg)";
-- TTS delivers it as the `value` parameter (id is the element id, unused here).

-- Is this packet one that delivers Force? ACTION covers every packet, so the
-- handler has to look at the packet itself to know whether to open the attack
-- flow or simply announce the effect for the players to resolve.
local function isStrikePacket(guid, packetId)
  local def = CUS.StateStore.getDefinition(guid)
  if not def then return false end
  for _, p in ipairs(CUS.PacketRegistry.resolveAttacks(def) or {}) do
    if p.id == packetId then return true end
  end
  return false
end

function wheelActionPacket(player, value)
  local guid = CUS.RadialWheel.ctx.guid
  CUS.RadialWheel.close()
  if isStrikePacket(guid, value) then
    startAttack(guid, value, "Regular", CUS.RadialWheel.ctx.player)
  else
    CUS.Logger.log("ACTION → " .. tostring(value) .. " (resolve per packet).")
  end
end

function wheelShot(player, value)
  local packetId, mode = value:match("^(.-)|(.+)$")
  CUS.RadialWheel.close()
  startAttack(CUS.RadialWheel.ctx.guid, packetId, mode, CUS.RadialWheel.ctx.player)
end

function wheelWaitPacket(player, value)
  armWait(CUS.RadialWheel.ctx.guid, value); CUS.RadialWheel.close()
end

-- Retired v0.5 entry points, kept as shims.
function wheelAttackPacket(player, value) return wheelActionPacket(player, value) end
function wheelUseAbility(player, value)   return wheelActionPacket(player, value) end
function wheelReadyPacket(player, value)  return wheelWaitPacket(player, value)   end

function wheelInteract()
  CUS.Logger.log("ACTION → Interact: interact with the adjacent object (resolve per object).")
  CUS.RadialWheel.close()
end
function wheelPickUp()
  CUS.Logger.log("ACTION → Pick Up: pick up the target object (resolve per object).")
  CUS.RadialWheel.close()
end

function wheelUtilActivate() uiToggleActivation({ guid = CUS.RadialWheel.ctx.guid }) end
function wheelUtilState()    CUS.StatePanel.refreshGuid(CUS.RadialWheel.ctx.guid) end
function wheelUtilCommand()  CUS.Logger.log("Command (Missions apply to AI banners only).") end
function wheelUtilUndo()     CUS.Undo.pop(); CUS.StatePanel.refreshAll() end

-- ==========================================================================
-- MOVE / CHARGE actions
-- ==========================================================================
function startMove(guid, playerColor)
  local s, reason = CUS.MovementResolver.begin(guid)
  if not s then return end
  activeMovers[guid] = false   -- becomes true on pickup
  CUS.MovementPanel.open(guid, playerColor)
end

function chargeAssist(guid, playerColor)
  local others = enemyList(guid)
  local prev = CUS.ChargeAssistant.preview(guid, others)
  if not prev then return end
  local lines = { ("Charge lane (Speed %d\"). Candidates:"):format(prev.lane.speed) }
  for _, c in ipairs(prev.candidates) do
    lines[#lines+1] = ("• %s @ %.1f\" — %s"):format(c.def.name, c.along, c.plow.note)
  end
  CUS.Logger.log(table.concat(lines, "\n"))
  CUS.Logger.log("Confirm each impact honestly, then open ATTACK for the impact. Wall jam → +2 dice.")
end

function disengage(guid)
  local st = CUS.StateStore.getOrInit(guid).state
  if (st.current_ap or 0) < 1 then CUS.Logger.warn("No AP to Disengage."); return end
  CUS.Undo.pushMiniState(getObjectFromGUID(guid), "Disengage")
  st.current_ap = st.current_ap - 1
  CUS.pushRuntimeToMini(guid)
  CUS.Logger.log("Disengaged (1 AP).")
end

-- Build a rough enemy list for geometry helpers. Sides are inferred from a
-- simple GM tag convention; for the testbed everything not the actor is "enemy".
function enemyList(selfGuid)
  local out = {}
  for guid, rs in pairs(CUS.StateStore.runtime) do
    if guid ~= selfGuid then
      local obj = getObjectFromGUID(guid)
      local def = CUS.StateStore.getDefinition(guid)
      if obj and def then out[#out+1] = { obj = obj, def = def, side = "enemy" } end
    end
  end
  return out
end

-- WAIT arms a PACKET against a trigger. It does not resolve now, and it ENDS
-- the activation even if AP remains (A.III, B.15). Formerly armReady/READY.
function armWait(guid, packetId)
  local st = CUS.StateStore.getOrInit(guid).state
  if (st.current_ap or 0) < 1 then CUS.Logger.warn("No AP to WAIT."); return end
  CUS.Undo.pushMiniState(getObjectFromGUID(guid), "WAIT")
  st.current_ap = st.current_ap - 1
  st.armed_packet_id = packetId
  st.ready_packet_id = packetId       -- legacy key, kept so old saves still read
  st.reaction_spent = true
  st.activated = true                 -- WAIT ends the activation
  CUS.pushRuntimeToMini(guid)
  CUS.Logger.log(("WAIT: %s armed — 1 AP spent, activation ended."):format(packetId))
end

-- Retired v0.5 name.
function armReady(guid, packetId) return armWait(guid, packetId) end

-- ==========================================================================
-- ATTACK flow
-- ==========================================================================
function beginAttackFlow(attackerGuid, playerColor)
  -- open the wheel's ATTACK branch to pick a packet
  CUS.RadialWheel.open(attackerGuid, playerColor)
  CUS.RadialWheel.branchAttack()
end

-- after choosing a packet/mode, the player hovers a defender + presses CUS: Attack.
function startAttack(attackerGuid, packetId, mode, playerColor)
  -- Precision requires not having moved.
  if mode == "Precision" then
    local st = CUS.StateStore.getOrInit(attackerGuid).state
    if st.moved_this_activation then
      CUS.Logger.warn("Precision Shot requires NOT having moved this activation.")
      return
    end
  end
  pendingAttack = { attacker = attackerGuid, packet = packetId, mode = mode, player = playerColor }
  local atk = getObjectFromGUID(attackerGuid)
  if atk then atk.highlightOn(CUS.Constants.COLOR.attacker, 6) end
  -- highlight candidate defenders
  for _, e in ipairs(enemyList(attackerGuid)) do e.obj.highlightOn(CUS.Constants.COLOR.candidate, 6) end
  CUS.Logger.log(("Target %s (%s): HOVER the defender and press 'CUS: Attack' again."):format(packetId, mode))
end

-- Completes the attack once the player hovers a defender and presses CUS: Attack.
function completeAttackTarget(hovered, playerColor)
  if not pendingAttack or playerColor ~= pendingAttack.player then return end
  if not (hovered and hovered.getVar and hovered.getVar("CUS_MINI") ~= nil) then
    CUS.Logger.warn("Hover a linked defender miniature, then press CUS: Attack."); return
  end
  local defenderGuid = hovered.getGUID()
  if defenderGuid == pendingAttack.attacker then
    CUS.Logger.warn("That's the attacker — hover a different figure."); return
  end
  local s, reason = CUS.AttackResolver.begin({
    attackerGuid = pendingAttack.attacker,
    defenderGuid = defenderGuid,
    packetId = pendingAttack.packet,
    mode = pendingAttack.mode,
  })
  clearHighlights()
  local pc = pendingAttack.player
  pendingAttack = nil
  if not s then CUS.Logger.warn("Attack setup failed: " .. tostring(reason)); return end
  CUS.AttackPanel.render(pc)
end

function clearHighlights()
  for guid in pairs(CUS.StateStore.runtime) do
    local o = getObjectFromGUID(guid)
    if o then o.highlightOff() end
  end
end

-- attack panel onClick shims
function apToggleCover() flipJudgment("cover", "Cover", { hitStep = 0, note = "Cover — defender benefits (ignored by Precision)" }) end
function apToggleHigh()  flipJudgment("high",  "High Ground", { dice = 1, note = "High ground — attacker +1 die" }) end
function apToggleLoS()   CUS.Logger.log("LoS confirmed clear by player.") end
function apToggleMob()
  local s = CUS.AttackResolver.session; if not s then return end
  CUS.AttackResolver.confirmMob(not s.mob_confirmed)
  CUS.AttackPanel.render()
end

-- Add/remove a player-confirmed judgment modifier by source label.
function flipJudgment(key, source, mod)
  local s = CUS.AttackResolver.session; if not s then return end
  s.judgments[key] = not s.judgments[key]
  -- remove any existing modifier with this source, then add if toggled on
  for i = #s.modifiers, 1, -1 do if s.modifiers[i].source == source then table.remove(s.modifiers, i) end end
  if s.judgments[key] then
    mod.source = source
    table.insert(s.modifiers, mod)
  end
  CUS.AttackPanel.render()
end

function apRoll()
  local r = CUS.AttackResolver.resolve()
  if r then CUS.AttackPanel.renderResult() end
end

function apEnterDice()
  UI.setAttribute("man_prompt", "text", "Enter dice results (space-separated), e.g. 5 3 6 2")
  manualMode = "dice"; UI.show("cus_manual")
end
function apEnterSuccesses()
  UI.setAttribute("man_prompt", "text", "Enter success COUNT, e.g. 3")
  manualMode = "successes"; UI.show("cus_manual")
end

manualMode = nil
manInputValue = ""
function manInputChanged(player, value) manInputValue = value or "" end
function manOK(player, value, id)
  local txt = manInputValue or ""
  UI.hide("cus_manual")
  if manualMode == "successes" then
    local n = tonumber(txt)
    if n then CUS.AttackResolver.resolve({ successes = n }); CUS.AttackPanel.renderResult() end
  else
    local dice = {}
    for tok in string.gmatch(txt, "%d+") do dice[#dice+1] = tonumber(tok) end
    if #dice > 0 then CUS.AttackResolver.resolve({ dice = dice }); CUS.AttackPanel.renderResult() end
  end
end
function manCancel() UI.hide("cus_manual") end

function apApply()
  local res = CUS.AttackResolver.apply()
  if not res then return end
  CUS.StatePanel.refreshAll()
  if res.counter_possible then
    CUS.Logger.log("Defender may COUNTER (bases touching, not Reach/Backstab). Click 'Resolve Counter' or continue.")
  else
    CUS.AttackPanel.close()
  end
end

function apCounter()
  local s = CUS.AttackResolver.session
  if not s or not s.result then return end
  -- legality via CounterResolver, using facts captured in the session
  local ctx = { touching = s.touching, reach = s.reach,
                suppressCounter = s.result.comp.suppressCounter,
                backstab = (s.facing == "Rear") }
  local legal, why = CUS.CounterResolver.isLegal(s.defenderGuid, s.attackerGuid, ctx)
  if not legal then CUS.Logger.warn("No Counter: " .. why); return end
  local cs, reason = CUS.CounterResolver.resolve(s.defenderGuid, s.attackerGuid)
  if cs then CUS.AttackPanel.render(CUS.AttackPanel.player) else CUS.Logger.warn(tostring(reason)) end
end

function apCancel() CUS.AttackResolver.cancel(); CUS.AttackPanel.close(); clearHighlights() end

-- ==========================================================================
-- MOVEMENT panel shims
-- ==========================================================================
function mpStory()  if CUS.MovementPanel.guid then CUS.MovementResolver.addStoryCost(CUS.MovementPanel.guid, 1) end end
function mpCommit() if CUS.MovementPanel.guid then CUS.MovementResolver.commit(CUS.MovementPanel.guid) end end
function mpUndo()   if CUS.MovementPanel.guid then CUS.MovementResolver.cancel(CUS.MovementPanel.guid) end end
function mpCancel() if CUS.MovementPanel.guid then CUS.MovementResolver.cancel(CUS.MovementPanel.guid) end end

-- ==========================================================================
-- CARD viewer shims
-- ==========================================================================
function cardPin(player)   CUS.CardViewer.togglePin(player.color) end
function cardClose(player) local c = CUS.CardViewer.open[player.color]; if c then c.pinned = false end; CUS.CardViewer.close(player.color) end

-- ==========================================================================
-- NERVE panel shims
-- ==========================================================================
function openNerve(p) CUS.NervePanel.open(p.guid, p.player) end
function npPass()   CUS.Logger.log("Nerve PASS (manual)."); CUS.NervePanel.close() end
function npFail()   local g = CUS.NervePanel.guid; CUS.NerveResolver.setMorale(g, "Shaken"); CUS.Logger.log("Nerve FAIL (manual) → Shaken."); CUS.StatePanel.refreshGuid(g) end
function npShaken() local g = CUS.NervePanel.guid; CUS.NerveResolver.setMorale(g, "Shaken"); CUS.StatePanel.refreshGuid(g) end
function npRally()  local g = CUS.NervePanel.guid; CUS.NerveResolver.setMorale(g, "Steady"); CUS.StatePanel.refreshGuid(g); CUS.NervePanel.close() end
function npRout()
  local g = CUS.NervePanel.guid
  CUS.NerveResolver.setMorale(g, "Broken")
  local def = CUS.StateStore.getDefinition(g)
  CUS.Logger.log("ROUT — " .. CUS.NerveResolver.routInstruction(def) .. "  (move the figure yourself).")
  CUS.StatePanel.refreshGuid(g)
end
function npClose() CUS.NervePanel.close() end

-- ==========================================================================
-- FORMATION panel shims
-- ==========================================================================
function fpFormWedge()  CUS.FormationPanel.setFormation("Wedge") end
function fpFormColumn() CUS.FormationPanel.setFormation("Column") end
function fpFormShield() CUS.FormationPanel.setFormation("Shield Wall") end
function fpFormLine()   CUS.FormationPanel.setFormation("Line") end
function fpAddSel(player)
  local sel = player and player.getSelectedObjects() or {}
  local guids = {}
  for _, o in ipairs(sel) do
    if o.getVar and o.getVar("CUS_MINI") ~= nil then guids[#guids+1] = o.getGUID() end
  end
  CUS.FormationPanel.addSelection(guids)
end
function fpAdvance() CUS.FormationPanel.doAdvance() end
function fpReform()  CUS.FormationPanel.doReform() end
function fpClose()   CUS.FormationPanel.close() end

-- ==========================================================================
-- CONDITIONS panel
-- ==========================================================================
local condTarget = nil
function openConditions(guid, playerColor)
  condTarget = guid
  local def = CUS.StateStore.getDefinition(guid)
  UI.setAttribute("cond_name", "text", "Conditions — " .. (def and def.name or guid))
  refreshConditions()
  UI.setAttribute("cus_cond", "visibility", playerColor)
  UI.show("cus_cond")
end

function refreshConditions()
  if not condTarget then return end
  local rows = {}
  for _, c in ipairs(CUS.ConditionManager.list(condTarget)) do
    -- One flat row per condition; tapping it removes that condition.
    rows[#rows+1] = {
      text = (c.icon or "-") .. " " .. c.id .. "     [tap to remove]",
      onClick = "condRemove(" .. c.id .. ")",
    }
  end
  if #rows == 0 then rows[1] = { kind = "header", text = "none" } end
  CUS.UIList.fill("cond_r", 12, rows)
end

condInputValue = ""
function condInputChanged(player, value) condInputValue = value or "" end
function condAdd()
  local id = condInputValue
  if id and id ~= "" and condTarget then CUS.ConditionManager.add(condTarget, id); refreshConditions(); CUS.StatePanel.refreshGuid(condTarget); condInputValue = "" end
end
function condRemove(player, value)
  if value and condTarget then CUS.ConditionManager.remove(condTarget, value); refreshConditions(); CUS.StatePanel.refreshGuid(condTarget) end
end
function condClose() UI.hide("cus_cond") end

-- ==========================================================================
-- ROUND / LOG shims
-- ==========================================================================
function rmNewRound()
  CUS.RoundManager.newRound()
  UI.setAttribute("rm_round", "text", "Round " .. CUS.RoundManager.round)
  CUS.StatePanel.refreshAll()
  refreshLog()
end
function rmToggleLog()
  logVisible = not logVisible
  if logVisible then refreshLog(); UI.show("cus_logpanel") else UI.hide("cus_logpanel") end
end
function rmUndo() CUS.Undo.pop(); CUS.StatePanel.refreshAll() end
function rmAudit()
  local problems = CUS.StateStore.audit()
  if #problems == 0 then CUS.Logger.log("Link audit: all good.")
  else for _, p in ipairs(problems) do CUS.Logger.warn(p) end end
end
function rmFixture() CUS.Fixture.spawn() end
function rmBlankCard() CUS.Fixture.spawnBlankCard() end
function rmDump()
  print(JSON.encode_pretty({ packets = CUS.PacketRegistry.serialize(), store = CUS.StateStore.serialize() }))
  CUS.Logger.log("Dumped registry + store to the host's -> Console (~).")
end
logVisible = false
function refreshLog() UI.setAttribute("log_text", "text", CUS.Logger.tail(24)) end

-- ==========================================================================
-- UNIT LIBRARY  (browse catalog; stamp a unit's stats onto a card)
-- ==========================================================================
-- Opened from a card's context menu, the Round panel, or a mini's linked card.
function openUnitLibrary(p)             -- p = { player, card? }
  CUS.UnitLibrary.open(p.player, p.card)
end
function rmLibrary(player) CUS.UnitLibrary.open(player.color, nil) end
function libFaction(player, value) CUS.UnitLibrary.setFaction(value) end
function libBack() CUS.UnitLibrary.back() end
function libApply(player, value)  CUS.UnitLibrary.apply(value, player.color) end
function libClose() CUS.UnitLibrary.close() end

-- ==========================================================================
-- CARD LAYOUT EDITOR  (move/resize the stat zones; shared with the HTML forge)
-- ==========================================================================
function openLayoutEditor(p)            -- p = { player, card }
  CUS.CardFace.openEditor(p.card, p.player)
end
function renderCardFace(p) CUS.CardFace.render(p.card) end

local STEP_POS  = 0.01
local STEP_SIZE = 0.005
function clZonePrev() CUS.CardFace.cycleZone(-1) end
function clZoneNext() CUS.CardFace.cycleZone(1) end
function clXminus() CUS.CardFace.adjust("x", -STEP_POS) end
function clXplus()  CUS.CardFace.adjust("x",  STEP_POS) end
function clYminus() CUS.CardFace.adjust("y", -STEP_POS) end
function clYplus()  CUS.CardFace.adjust("y",  STEP_POS) end
function clWminus() CUS.CardFace.adjust("w", -STEP_POS) end
function clWplus()  CUS.CardFace.adjust("w",  STEP_POS) end
function clHminus() CUS.CardFace.adjust("h", -STEP_POS) end
function clHplus()  CUS.CardFace.adjust("h",  STEP_POS) end
function clFminus() CUS.CardFace.adjust("size", -STEP_SIZE) end
function clFplus()  CUS.CardFace.adjust("size",  STEP_SIZE) end
function clAlign()  CUS.CardFace.cycleAlign() end
function clShow()   CUS.CardFace.toggleShow() end
function clApplyAll() CUS.CardFace.renderAll() end
function clExport() CUS.CardFace.exportJSON() end
clImportValue = ""
function clImportChanged(player, value) clImportValue = value or "" end
function clImport() CUS.CardFace.importJSON(clImportValue) end
function clClose()  CUS.CardFace.closeEditor() end

