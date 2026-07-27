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
