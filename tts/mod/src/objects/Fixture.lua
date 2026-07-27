-- objects/Fixture.lua
-- Optional playable test fixture. Spawns scripted CARD tiles + MINIATURE blocks
-- and auto-links them, so every acceptance test can be run immediately.
--
-- It works by spawning plain objects and attaching COMPACT stub scripts (below)
-- via setLuaScript()+reload(). The stubs implement the same callable contract as
-- the full CardController / MiniatureController object scripts; all heavy logic
-- still lives in Global. For a production table, paste the full object scripts
-- instead (see docs/SETUP.md).

CUS = CUS or {}
local Fixture = {}

-- Compact CARD stub: definition is injected via GM Notes at spawn time.
local CARD_STUB = [[
CUS_CARD = true
local definition = nil
function getDefinition() return definition end
function getDefinitionId() return definition and definition.definition_id end
function getCardImageUrl() return definition and definition.display and definition.display.card_image_url end
function validateDefinition() return { ok = definition ~= nil, errors = {} } end
function setDefinition(d) definition = d; self.setGMNotes(JSON.encode_pretty(d)) end
function onSave() return JSON.encode({ definition = definition }) end
function onLoad(s)
  if s and s ~= "" then local ok,b = pcall(function() return JSON.decode(s) end); if ok and b then definition = b.definition end end
  if not definition then
    local n = self.getGMNotes()
    if n and n ~= "" then local ok,d = pcall(function() return JSON.decode(n) end); if ok then definition = d end end
  end
  self.addContextMenuItem("Link Selected Miniature", function(pc) Global.call("cardLinkSelectedMini", { card = self, player = pc }) end)
  self.addContextMenuItem("Highlight Linked Miniature", function(pc) Global.call("cardHighlightLinkedMini", { card = self, player = pc }) end)
  self.addContextMenuItem("Open Unit Library (stamp this card)", function(pc) Global.call("openUnitLibrary", { player = pc, card = self.getGUID() }) end)
  self.addContextMenuItem("Render Card Face", function() Global.call("renderCardFace", { card = self.getGUID() }) end)
  self.addContextMenuItem("Edit Card Layout", function(pc) Global.call("openLayoutEditor", { player = pc, card = self.getGUID() }) end)
end
]]

-- Compact MINIATURE stub (mirrors MiniatureController's contract).
local MINI_STUB = [[
CUS_MINI = true
local persist = { card_guid = nil, expected_definition_id = nil, runtime_state = { schema_version = 1, state = {
  current_wounds = 1, current_ap = 2, activated = false, moved_this_activation = false, attacked_this_activation = false,
  ready_packet_id = nil, reaction_spent = false, counter_uses_remaining = 1, conditions = {}, morale = "Steady",
  facing_locked = false, forward_axis = "local_z", movement_session = nil, formation = nil, temporary_modifiers = {} } } }
function getLink() return { card_guid = persist.card_guid, expected_definition_id = persist.expected_definition_id, runtime_state = persist.runtime_state } end
function getRuntimeState() return { schema_version = persist.runtime_state.schema_version, card_guid = persist.card_guid, expected_definition_id = persist.expected_definition_id, state = persist.runtime_state.state } end
function setRuntimeState(rs) persist.card_guid = rs.card_guid or persist.card_guid; persist.expected_definition_id = rs.expected_definition_id or persist.expected_definition_id; persist.runtime_state = { schema_version = rs.schema_version or 1, state = rs.state } end
function onSave() return JSON.encode(persist) end
function onLoad(s)
  if s and s ~= "" then local ok,b = pcall(function() return JSON.decode(s) end); if ok and b then persist = b end end
  Wait.frames(function() Global.call("registerMiniature", { guid = self.getGUID() }) end, 2)
  self.addContextMenuItem("CUS Actions (Wheel)", function(pc) Global.call("openRadialFor", { guid = self.getGUID(), player = pc }) end)
  self.addContextMenuItem("Open Linked Card", function(pc) Global.call("openLinkedCard", { guid = self.getGUID(), player = pc }) end)
  self.addContextMenuItem("Link Selected Card", function(pc) Global.call("beginLinkFromMini", { guid = self.getGUID(), player = pc }) end)
  self.addContextMenuItem("Re-sync From Card", function(pc) Global.call("resyncFromCard", { guid = self.getGUID(), player = pc }) end)
  self.addContextMenuItem("Nerve Test", function(pc) Global.call("openNerve", { guid = self.getGUID(), player = pc }) end)
end
local function fwd(fn, player, button) Global.call(fn, { guid = self.getGUID(), player = player and player.color, alt = (button == "-2") }) end
function stateClickActivation(p,b) fwd("uiToggleActivation",p,b) end
function stateClickAP(p,b) fwd("uiSpendAP",p,b) end
function stateClickWound(p,b) fwd("uiApplyWound",p,b) end
function stateClickReady(p,b) fwd("uiInspectReady",p,b) end
function stateClickConditions(p,b) fwd("uiOpenConditions",p,b) end
function stateClickCard(p,b) fwd("openLinkedCard",p,b) end
]]

-- spawn one scripted card at pos with the given unit definition table.
-- Uses a plain BlockRectangle (no custom-image requirement) as the card body;
-- for a real card face, set the definition's display.card_image_url and paste
-- the full CardController onto a proper card object instead.
-- IMPORTANT: reload() invalidates the pre-reload object reference (and can swap
-- GUIDs), so we do ALL setup (script + GM Notes) BEFORE the single reload, and
-- afterwards only ever touch objects via getObjectFromGUID(guid). We return the
-- GUID and confirm the definition parsed before linking.
local function spawnCard(def, pos)
  local card = spawnObject({ type = "BlockRectangle", position = pos, scale = { 1.4, 0.2, 2.0 } })
  card.setColorTint({ 0.85, 0.82, 0.7 })
  card.setName(def.name)
  card.setGMNotes(JSON.encode(def))   -- set BEFORE reload; CARD_STUB.onLoad reads it
  card.setLuaScript(CARD_STUB)
  card.reload()
  return card.getGUID()
end

local function spawnMini(pos, colorTint)
  local mini = spawnObject({ type = "BlockSquare", position = pos, scale = { 0.6, 0.6, 0.6 } })
  mini.setColorTint(colorTint or { 0.7, 0.7, 0.8 })
  mini.setLuaScript(MINI_STUB)
  mini.reload()
  return mini.getGUID()
end

-- Spawn a 2-card / 2-mini fixture and auto-link once the scripts have compiled.
function Fixture.spawn()
  local units = CUS.SAMPLE_UNITS
  if not units or #units < 2 then CUS.Logger.warn("No sample units to spawn."); return end
  local sword = units[1]   -- Militia Swordsman
  local boss  = units[4]   -- Goblin Warboss (Circle/Large)

  local c1 = spawnCard(sword, { -6, 1.5, 4 })
  local c2 = spawnCard(boss,  {  6, 1.5, 4 })
  local m1 = spawnMini({ -6, 1.5, -2 }, { 0.4, 0.7, 1.0 })
  local m2 = spawnMini({  6, 1.5, -2 }, { 1.0, 0.5, 0.4 })

  -- Poll (up to ~5s) until both cards report a valid definition, THEN link.
  local tries = 0
  local function tryLink()
    tries = tries + 1
    local cardOk = function(g)
      local o = getObjectFromGUID(g)
      if not o or not o.getVar or o.getVar("getDefinition") == nil then return false end
      local ok, def = pcall(function() return o.call("getDefinition") end)
      return ok and type(def) == "table"
    end
    if cardOk(c1) and cardOk(c2) then
      doLink(m1, c1)
      doLink(m2, c2)
      CUS.StatePanel.refreshAll()
      CUS.Logger.log("Test fixture spawned & linked: Militia Swordsman vs Goblin Warboss.")
    elseif tries < 100 then
      Wait.frames(tryLink, 5)
    else
      CUS.Logger.warn("Fixture: cards did not finish loading in time — link them manually.")
    end
  end
  Wait.frames(tryLink, 20)
end

-- Spawn a single BLANK scripted card the player can then stamp from the Unit
-- Library. Returns the spawned card's GUID.
function Fixture.spawnBlankCard(pos)
  pos = pos or { 0, 2, 6 }
  local card = spawnObject({ type = "BlockRectangle", position = pos, scale = { 1.4, 0.2, 2.0 } })
  card.setColorTint({ 0.85, 0.82, 0.7 })
  card.setName("Blank CUS Card")
  card.setLuaScript(CARD_STUB)
  card.reload()
  if CUS.Logger then CUS.Logger.log("Blank card spawned — left-click it, then Unit Library → pick a unit, THEN link a miniature to it.") end
  return card.getGUID()
end

CUS.Fixture = Fixture
