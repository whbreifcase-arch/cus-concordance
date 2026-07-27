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
