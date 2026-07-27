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
