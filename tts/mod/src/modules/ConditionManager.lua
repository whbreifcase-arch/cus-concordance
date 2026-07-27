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
