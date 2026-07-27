-- objects/MiniatureController.lua
-- OBJECT SCRIPT — paste onto each physical MINIATURE.
--
-- The miniature owns RUNTIME STATE only. It stores exactly three things:
--     card_guid              -- link to the current physical card object
--     expected_definition_id -- stable conceptual identity (survives card respawn)
--     runtime_state          -- wounds, AP, activation flags, conditions, etc.
-- It never owns a second permanent stat block; stats come from the linked card.
--
-- Persistence lives here (onSave). Global holds a working mirror for resolvers
-- and panels; when Global mutates state it calls setRuntimeState() back to us so
-- our onSave stays authoritative.

CUS_MINI = true       -- marker global; Global detects CUS miniatures via getVar
local persist = nil   -- { card_guid, expected_definition_id, runtime_state }

local function defaultRuntime()
  return {
    schema_version = 1,
    state = {
      current_wounds = 1, current_ap = 2,
      activated = false, moved_this_activation = false, attacked_this_activation = false,
      ready_packet_id = nil, reaction_spent = false, counter_uses_remaining = 1,
      conditions = {}, morale = "Steady",
      facing_locked = false, forward_axis = "local_z",
      movement_session = nil, formation = nil, temporary_modifiers = {},
    },
  }
end

local function ensure()
  if not persist then
    persist = { card_guid = nil, expected_definition_id = nil, runtime_state = defaultRuntime() }
  end
  if not persist.runtime_state then persist.runtime_state = defaultRuntime() end
end

-- ---------- callable contract (used by Global) -----------------------------
function getLink()
  ensure()
  return {
    card_guid              = persist.card_guid,
    expected_definition_id = persist.expected_definition_id,
    runtime_state          = persist.runtime_state,
  }
end

function setLink(params)
  ensure()
  persist.card_guid = params.card_guid
  persist.expected_definition_id = params.expected_definition_id
end

-- Full runtime blob (the schema-shaped { schema_version, card_guid, expected_definition_id, state }).
function getRuntimeState()
  ensure()
  return {
    schema_version         = persist.runtime_state.schema_version or 1,
    card_guid              = persist.card_guid,
    expected_definition_id = persist.expected_definition_id,
    state                  = persist.runtime_state.state,
  }
end

function setRuntimeState(rs)
  ensure()
  persist.card_guid              = rs.card_guid or persist.card_guid
  persist.expected_definition_id = rs.expected_definition_id or persist.expected_definition_id
  persist.runtime_state = { schema_version = rs.schema_version or 1, state = rs.state }
end

-- ---------- save / load -----------------------------------------------------
function onSave()
  ensure()
  return JSON.encode(persist)
end

function onLoad(saved)
  if saved and saved ~= "" then
    local ok, blob = pcall(function() return JSON.decode(saved) end)
    if ok and type(blob) == "table" then persist = blob end
  end
  ensure()
  -- Register with Global once it has booted (safe if Global isn't ready yet:
  -- Global also re-scans miniatures on its own onLoad).
  Wait.frames(function()
    Global.call("registerMiniature", { guid = self.getGUID() })
  end, 2)
  refreshContextMenu()
end

-- ---------- right-click context menu ---------------------------------------
function refreshContextMenu()
  self.clearContextMenu()
  self.addContextMenuItem("CUS Actions (Wheel)", function(pc)
    Global.call("openRadialFor", { guid = self.getGUID(), player = pc })
  end)
  self.addContextMenuItem("Open Linked Card", function(pc)
    Global.call("openLinkedCard", { guid = self.getGUID(), player = pc })
  end)
  self.addContextMenuItem("Link Selected Card", function(pc)
    Global.call("beginLinkFromMini", { guid = self.getGUID(), player = pc })
  end)
  self.addContextMenuItem("Unlink Card", function(pc)
    Global.call("unlinkCard", { guid = self.getGUID(), player = pc })
  end)
  self.addContextMenuItem("Re-sync From Card", function(pc)
    Global.call("resyncFromCard", { guid = self.getGUID(), player = pc })
  end)
  self.addContextMenuItem("Nerve Test", function(pc)
    Global.call("openNerve", { guid = self.getGUID(), player = pc })
  end)
  self.addContextMenuItem("Calibrate Forward Axis", function(pc)
    Global.call("calibrateFacing", { guid = self.getGUID(), player = pc })
  end)
end

-- ---------- floating StatePanel click forwarders ---------------------------
-- Object-attached UI (StatePanel) calls these; each forwards to Global with the
-- clicking player, so Global owns all mutation & undo. `alt` = right-click.
-- Object UI onClick signature is (player, mouseButton, id); "-2" = right-click.
local function fwd(fn, player, button)
  Global.call(fn, { guid = self.getGUID(), player = player and player.color or nil, alt = (button == "-2") })
end
function stateClickActivation(player, button) fwd("uiToggleActivation", player, button) end
function stateClickAP(player, button)         fwd("uiSpendAP", player, button) end
function stateClickWound(player, button)      fwd("uiApplyWound", player, button) end
function stateClickReady(player, button)      fwd("uiInspectReady", player, button) end
function stateClickConditions(player, button) fwd("uiOpenConditions", player, button) end
function stateClickCard(player, button)       fwd("openLinkedCard", player, button) end
