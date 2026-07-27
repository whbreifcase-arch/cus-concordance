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
