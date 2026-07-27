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
