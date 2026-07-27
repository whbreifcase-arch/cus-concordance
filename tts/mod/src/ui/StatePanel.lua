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
