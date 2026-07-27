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
