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
