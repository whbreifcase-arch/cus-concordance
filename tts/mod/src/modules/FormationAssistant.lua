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
