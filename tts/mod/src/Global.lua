-- ==========================================================================
-- Global.lua — CUS Tabletop Simulator playtest controller
-- ==========================================================================
-- Build note: the #include lines below use the official TTS VSCode/Atom Lua
-- extension. If you paste by hand instead, concatenate the files in THIS ORDER
-- (each only touches the shared global `CUS` table, so order = dependency order)
-- and delete the #include lines. See docs/SETUP.md.

#include core/Constants
#include core/Schema
#include core/Logger
#include core/EventBus
#include core/Undo
#include core/Geometry
#include core/UIList
#include core/StateStore
#include modules/PacketRegistry
#include modules/ArmourResolver
#include modules/AttackResolver
#include modules/CounterResolver
#include modules/MovementResolver
#include modules/ChargeAssistant
#include modules/ConditionManager
#include modules/NerveResolver
#include modules/FormationAssistant
#include modules/RoundManager
#include ui/RadialWheel
#include ui/CardViewer
#include ui/StatePanel
#include ui/AttackPanel
#include ui/MovementPanel
#include ui/NervePanel
#include ui/FormationPanel
#include ui/CardFace
#include ui/UnitLibrary

-- Embedded sample data (kept inline so the mod boots with a fixture even before
-- you paste your own). The same JSON also ships in /data for external editing.
#include data/sample_packets
#include data/sample_units
#include data/card_layout
#include data/unit_library
#include objects/Fixture

-- --------------------------------------------------------------------------
-- shared helpers on the CUS table
-- --------------------------------------------------------------------------

-- Write a miniature's working runtime state back to its object (authoritative
-- persistence) and refresh its floating StatePanel.
function CUS.pushRuntimeToMini(guid)
  local mini = getObjectFromGUID(guid)
  if not mini then return end
  local rs = CUS.StateStore.getOrInit(guid)
  pcall(function() mini.call("setRuntimeState", {
    schema_version         = rs.schema_version,
    card_guid              = rs.card_guid,
    expected_definition_id = rs.expected_definition_id,
    state                  = rs.state,
  }) end)
  if CUS.StatePanel then CUS.StatePanel.refresh(mini) end
end

-- transient controller state (file-scope so hotkey closures capture them)
local activeMovers = {}   -- guid -> true while held during a MOVE session
pendingAttack = nil       -- { attacker, packet, mode, player } during targeting

-- ==========================================================================
-- boot
-- ==========================================================================
function onLoad(savedState)
  -- restore or fresh-load registries
  local blob = nil
  if savedState and savedState ~= "" then
    local ok, decoded = pcall(function() return JSON.decode(savedState) end)
    if ok then blob = decoded end
  end

  -- Always build the layout + unit catalog (they are content, not runtime state).
  loadCardLayout()
  buildUnitLibrary()

  if blob then
    CUS.PacketRegistry.restore(blob.packets)
    CUS.StateStore.restore(blob.store)
    CUS.RoundManager.restore(blob.round)
    CUS.Logger.restore(blob.log)
    if blob.layout then CUS.CARD_LAYOUT = blob.layout end   -- keep edited layout
  else
    CUS.PacketRegistry.load(CUS.SAMPLE_PACKETS)              -- baseline sample packets
  end
  -- Merge every faction's packets into the registry (idempotent; library is the
  -- real content, samples are just the boot fixture).
  registerLibraryPackets()

  CUS.Logger.roundProvider = function() return CUS.RoundManager.round end
  registerHotkeys()

  -- discover any miniatures already on the table (they also self-register)
  Wait.frames(function()
    scanMiniatures()
    UI.setAttribute("rm_round", "text", "Round " .. CUS.RoundManager.round)
    UI.show("cus_round")
    CUS.StatePanel.refreshAll()
    CUS.Logger.log("CUS controller ready. Right-click a miniature → CUS Actions.", { broadcast = true })
  end, 5)
end

function onSave()
  return JSON.encode({
    packets = CUS.PacketRegistry.serialize(),
    store   = CUS.StateStore.serialize(),
    round   = CUS.RoundManager.serialize(),
    log     = CUS.Logger.serialize(),
    layout  = CUS.CARD_LAYOUT,
  })
end

-- ==========================================================================
-- content loaders: card layout + unit library (built from embedded JSON)
-- ==========================================================================
function loadCardLayout()
  local ok, decoded = pcall(function() return JSON.decode(CUS.CARD_LAYOUT_JSON) end)
  if ok and type(decoded) == "table" then
    CUS.CARD_LAYOUT = decoded
  else
    CUS.Logger.warn("card_layout.lua JSON failed to parse; using empty layout.", { broadcast = false })
    CUS.CARD_LAYOUT = { card = {}, zones = {} }
  end
end

-- Decode CUS.UNIT_LIBRARY_JSON (a list of faction objects) into
-- CUS.UNIT_LIBRARY = { factions = {...}, byId = {...} }.
function buildUnitLibrary()
  CUS.UNIT_LIBRARY = { factions = {}, byId = {} }
  local raw = CUS.UNIT_LIBRARY_JSON
  if not raw then return end
  local ok, decoded = pcall(function() return JSON.decode(raw) end)
  if not ok or type(decoded) ~= "table" then
    CUS.Logger.warn("unit_library.lua JSON failed to parse.", { broadcast = false })
    return
  end
  for _, f in ipairs(decoded) do
    CUS.UNIT_LIBRARY.factions[#CUS.UNIT_LIBRARY.factions + 1] = f
    for _, u in ipairs(f.units or {}) do
      CUS.UNIT_LIBRARY.byId[u.definition_id] = u
    end
  end
  local n = 0; for _ in pairs(CUS.UNIT_LIBRARY.byId) do n = n + 1 end
  CUS.Logger.log(("Unit library loaded: %d factions, %d units.")
    :format(#CUS.UNIT_LIBRARY.factions, n), { broadcast = false })
end

-- Merge every faction's attack/ability packets into the live registry.
function registerLibraryPackets()
  for _, f in ipairs((CUS.UNIT_LIBRARY and CUS.UNIT_LIBRARY.factions) or {}) do
    for _, p in ipairs(f.attack_packets or {}) do
      local okp = select(1, CUS.Schema.validateAttackPacket(p))
      if okp then CUS.PacketRegistry.attacks[p.id] = p end
    end
    for _, p in ipairs(f.ability_packets or {}) do
      local okp = select(1, CUS.Schema.validateAbilityPacket(p))
      if okp then CUS.PacketRegistry.abilities[p.id] = p end
    end
  end
end

-- Miniatures announce themselves here (called from the object script onLoad).
function registerMiniature(p)
  local mini = getObjectFromGUID(p.guid)
  if not mini then return end
  local link = mini.call("getRuntimeState")
  if link then CUS.StateStore.set(p.guid, CUS.Schema.migrateRuntimeState(link)) end
  CUS.StatePanel.refresh(mini)
end

-- Fallback discovery: anything tagged as a CUS miniature.
function scanMiniatures()
  for _, obj in ipairs(getAllObjects()) do
    if obj.getVar and obj.getVar("CUS_MINI") ~= nil then
      registerMiniature({ guid = obj.getGUID() })
    end
  end
end

-- ==========================================================================
-- per-frame: sample active MOVE sessions of held miniatures
-- ==========================================================================
function onObjectPickUp(player, obj)
  local guid = obj.getGUID()
  local rs = CUS.StateStore.get(guid)
  if rs and rs.state.movement_session and rs.state.movement_session.active then
    activeMovers[guid] = true
    rs.state.movement_session.holding = true
  end
end

function onObjectDrop(player, obj)
  local guid = obj.getGUID()
  if activeMovers[guid] then
    activeMovers[guid] = nil
    local rs = CUS.StateStore.get(guid)
    if rs and rs.state.movement_session then
      rs.state.movement_session.holding = false
      CUS.MovementResolver.sample(guid)   -- capture final position of this pickup
    end
  end
end

function update()
  for guid in pairs(activeMovers) do
    local rs = CUS.StateStore.get(guid)
    if rs and rs.state.movement_session and rs.state.movement_session.active then
      CUS.MovementResolver.sample(guid)
    else
      activeMovers[guid] = nil   -- prune finished/cancelled sessions
    end
  end
end

-- ==========================================================================
-- named hotkeys
-- ==========================================================================
-- NOTE: the addHotkey callback's first argument is the player COLOR STRING
-- (not a Player object), followed by the hovered object.
function registerHotkeys()
  addHotkey("CUS: Action Wheel", function(pcolor, hovered) withHovered(hovered, function(g) CUS.RadialWheel.open(g, pcolor) end) end)
  addHotkey("CUS: Open Card",    function(pcolor, hovered) withHovered(hovered, function(g) openLinkedCard({ guid = g, player = pcolor }) end) end)
  addHotkey("CUS: Move",         function(pcolor, hovered) withHovered(hovered, function(g) startMove(g, pcolor) end) end)
  -- CUS: Action is context-smart: if an attack is pending its target, the
  -- HOVERED miniature becomes the defender; otherwise it begins the flow on the
  -- hovered attacker. (TTS exposes no global object left-click, so target
  -- selection is hover + this hotkey — see docs/KNOWN_LIMITATIONS.md.)
  addHotkey("CUS: Action", function(pcolor, hovered)
    if pendingAttack and pendingAttack.player == pcolor then
      completeAttackTarget(hovered, pcolor)
    else
      withHovered(hovered, function(g) beginAttackFlow(g, pcolor) end)
    end
  end)
  addHotkey("CUS: Wait",         function(pcolor, hovered) withHovered(hovered, function(g) CUS.RadialWheel.open(g, pcolor); CUS.RadialWheel.branchWait() end) end)
  addHotkey("CUS: Activate / End Activation", function(pcolor, hovered) withHovered(hovered, function(g) uiToggleActivation({ guid = g, player = pcolor }) end) end)
  addHotkey("CUS: Cancel Operation", function(pcolor) cancelEverything(pcolor) end)
  addHotkey("CUS: Undo Last State Change", function() CUS.Undo.pop(); CUS.StatePanel.refreshAll() end)
end

function withHovered(hovered, fn)
  if hovered and hovered.getVar and hovered.getVar("CUS_MINI") ~= nil then
    fn(hovered.getGUID())
  else
    CUS.Logger.warn("Hover a linked miniature first.")
  end
end

function openRadialFor(p) CUS.RadialWheel.open(p.guid, p.player) end

function cancelEverything(color)
  CUS.RadialWheel.close(); CUS.AttackPanel.close(); CUS.MovementPanel.close()
  CUS.NervePanel.close(); CUS.FormationPanel.close()
  UI.hide("cus_manual"); UI.hide("cus_cond")
  CUS.ChargeAssistant.clear()
  if CUS.AttackResolver.session then CUS.AttackResolver.cancel() end
end

-- ==========================================================================
-- linking flow  (SELECTION-based — TTS has no global object left-click event)
-- ==========================================================================
-- Context-menu callbacks pass the clicking player's COLOR STRING; resolve the
-- Player to read their current selection.
local function selectedOf(color, predicateVar)
  local pl = Player[color]
  local sel = pl and pl.getSelectedObjects() or {}
  for _, o in ipairs(sel) do
    if o.getVar and o.getVar(predicateVar) ~= nil then return o end
  end
  return nil
end

-- Mini context menu: "Link Selected Card" — player selects the card, then this.
function beginLinkFromMini(p)
  local card = selectedOf(p.player, "getDefinition")
  if not card then
    CUS.Logger.warn("Select the CARD first, then use 'Link Card…' on the miniature.")
    return
  end
  doLink(p.guid, card.getGUID())
end

-- Card context menu: "Link Selected Miniature" — player selects the mini, then this.
function cardLinkSelectedMini(p)
  local mini = selectedOf(p.player, "getRuntimeState")
  if not mini then
    CUS.Logger.warn("Select a MINIATURE first, then use 'Link Selected Miniature' on the card.")
    return
  end
  doLink(mini.getGUID(), p.card.getGUID())
end

function cardHighlightLinkedMini(p)
  local cardGuid = p.card.getGUID()
  local found = false
  for guid, rs in pairs(CUS.StateStore.runtime) do
    if rs.card_guid == cardGuid then
      local m = getObjectFromGUID(guid)
      if m then m.highlightOn(CUS.Constants.COLOR.linkpair, 4); found = true end
    end
  end
  if not found then CUS.Logger.log("No miniature currently links this card.", { broadcast = false }) end
end

function doLink(miniGuid, cardGuid)
  local card = getObjectFromGUID(cardGuid)
  local defOk = card and card.getVar and card.getVar("CUS_CARD") ~= nil
  if not defOk then CUS.Logger.warn("That object is not a CUS card."); return end
  local def = card.call("getDefinition")
  if type(def) ~= "table" then CUS.Logger.warn("Card has no valid definition."); return end

  local rs = CUS.StateStore.getOrInit(miniGuid)
  rs.card_guid = cardGuid
  rs.expected_definition_id = def.definition_id
  -- initialise runtime maxima from the definition (first link only)
  if rs.state.current_wounds == nil or rs.state._fresh ~= false then
    rs.state.current_wounds = def.stats.max_wounds
    rs.state.current_ap     = def.stats.max_ap
    -- No Counter allowance to seed: B.9 (SIGNED) removed the per-round cap and
    -- the counter_x economy entirely. `def.counter_uses` on an old card is now
    -- inert data, deliberately ignored rather than silently honoured.
    rs.state.forward_axis   = (def.base and def.base.forward_axis) or CUS.Constants.TUNING.facing_axis
    rs.state._fresh = false
  end
  CUS.pushRuntimeToMini(miniGuid)
  local m = getObjectFromGUID(miniGuid)
  if m then m.highlightOn(CUS.Constants.COLOR.linkpair, 3) end
  card.highlightOn(CUS.Constants.COLOR.linkpair, 3)
  CUS.Logger.log(("Linked %s ↔ card '%s' (%s)."):format(miniGuid, def.name, def.definition_id))
end

function unlinkCard(p)
  local rs = CUS.StateStore.get(p.guid)
  if rs then rs.card_guid = nil; CUS.pushRuntimeToMini(p.guid) end
  CUS.Logger.log("Card unlinked (definition identity preserved).", { broadcast = false })
end

-- Re-sync: update maxima & packet refs WITHOUT healing or restoring AP; clamp
-- current values only if they now exceed the new maxima; preserve conditions.
function resyncFromCard(p)
  local def, reason = CUS.StateStore.getDefinition(p.guid)
  if not def then CUS.Logger.warn("Re-sync failed: " .. tostring(reason)); return end
  local rs = CUS.StateStore.getOrInit(p.guid)
  CUS.Undo.pushMiniState(getObjectFromGUID(p.guid), "re-sync from card")
  rs.expected_definition_id = def.definition_id
  -- clamp only (do NOT heal / refill)
  if rs.state.current_wounds > def.stats.max_wounds then rs.state.current_wounds = def.stats.max_wounds end
  if rs.state.current_ap and rs.state.current_ap > def.stats.max_ap then rs.state.current_ap = def.stats.max_ap end
  CUS.pushRuntimeToMini(p.guid)
  CUS.Logger.log(("Re-synced from '%s' — maxima & packets updated; wounds/AP/conditions preserved."):format(def.name))
end

function autoRelinkByDefinitionId(miniGuid)
  local rs = CUS.StateStore.get(miniGuid)
  if not rs or not rs.expected_definition_id then return end
  for _, obj in ipairs(getAllObjects()) do
    if obj.getVar and obj.getVar("CUS_CARD") ~= nil then
      local def = obj.call("getDefinition")
      if type(def) == "table" and def.definition_id == rs.expected_definition_id then
        rs.card_guid = obj.getGUID()
        CUS.pushRuntimeToMini(miniGuid)
        CUS.Logger.log("Auto-relinked by definition_id: " .. rs.expected_definition_id, { broadcast = false })
        return
      end
    end
  end
end

function openLinkedCard(p) CUS.CardViewer.openForMini(p.guid, p.player) end

function calibrateFacing(p)
  -- cycle the forward axis and report; a visible facing arrow could be added.
  local rs = CUS.StateStore.getOrInit(p.guid)
  local order = { local_z = "local_x", local_x = "local_-z", ["local_-z"] = "local_z" }
  rs.state.forward_axis = order[rs.state.forward_axis or "local_z"] or "local_z"
  CUS.pushRuntimeToMini(p.guid)
  CUS.Logger.log("Forward axis set to " .. rs.state.forward_axis .. " for " .. p.guid)
end

-- ==========================================================================
-- floating StatePanel click handlers (forwarded from the mini object script)
-- ==========================================================================
function uiToggleActivation(p)
  local st = CUS.StateStore.getOrInit(p.guid).state
  if st.activated then CUS.RoundManager.endActivation(p.guid)
  else CUS.RoundManager.beginActivation(p.guid) end
  CUS.pushRuntimeToMini(p.guid)
end

function uiSpendAP(p)
  local st = CUS.StateStore.getOrInit(p.guid).state
  CUS.Undo.pushMiniState(getObjectFromGUID(p.guid), "AP change")
  local delta = p.alt and 1 or -1     -- right-click refunds
  local def = CUS.StateStore.getDefinition(p.guid)
  local maxAp = def and def.stats.max_ap or 3
  st.current_ap = math.max(0, math.min(maxAp, (st.current_ap or 0) + delta))
  CUS.pushRuntimeToMini(p.guid)
end

function uiApplyWound(p)
  local st = CUS.StateStore.getOrInit(p.guid).state
  CUS.Undo.pushMiniState(getObjectFromGUID(p.guid), "Wound change")
  local def = CUS.StateStore.getDefinition(p.guid)
  local maxW = def and def.stats.max_wounds or 1
  local delta = p.alt and 1 or -1     -- right-click restores
  st.current_wounds = math.max(0, math.min(maxW, (st.current_wounds or 0) + delta))
  CUS.pushRuntimeToMini(p.guid)
end

function uiInspectReady(p)
  local st = CUS.StateStore.getOrInit(p.guid).state
  if st.ready_packet_id then
    CUS.Logger.log("Ready packet: " .. tostring(st.ready_packet_id) .. " (right-click State icon to cancel).")
    if p.alt then st.ready_packet_id = nil; CUS.pushRuntimeToMini(p.guid); CUS.Logger.log("Ready cancelled.") end
  else
    CUS.Logger.log("No Ready packet armed.")
  end
end

function uiOpenConditions(p) openConditions(p.guid, p.player) end

-- ==========================================================================
-- RADIAL WHEEL onClick shims
-- ==========================================================================
-- The THREE canonical roots (A.III, SIGNED).
function wheelBranchMove()   CUS.RadialWheel.branchMove()   end
function wheelBranchAction() CUS.RadialWheel.branchAction() end
function wheelBranchWait()   CUS.RadialWheel.branchWait()   end
-- Retired v0.5 roots, kept only so a stale binding still lands somewhere.
function wheelBranchAttack() CUS.RadialWheel.branchAction() end
function wheelBranchUse()    CUS.RadialWheel.branchAction() end
function wheelBranchReady()  CUS.RadialWheel.branchWait()   end
function wheelCenter()       CUS.RadialWheel.center()       end
function wheelClose()        CUS.RadialWheel.close()        end
function wheelShowRoot()     CUS.RadialWheel.showRoot()     end

-- MOVE branch
function wheelMoveBegin()  local g = CUS.RadialWheel.ctx.guid; CUS.RadialWheel.close(); startMove(g, CUS.RadialWheel.ctx.player) end
function wheelMoveCommit()  if CUS.MovementPanel.guid then CUS.MovementResolver.commit(CUS.MovementPanel.guid) end end
function wheelMoveUndo()    if CUS.MovementPanel.guid then CUS.MovementResolver.cancel(CUS.MovementPanel.guid) end end
function wheelChargeAssist() chargeAssist(CUS.RadialWheel.ctx.guid, CUS.RadialWheel.ctx.player) end
function wheelDisengage()   disengage(CUS.RadialWheel.ctx.guid) end
function wheelAdvance()     CUS.RadialWheel.close(); CUS.FormationPanel.open(CUS.RadialWheel.ctx.guid, CUS.RadialWheel.ctx.player) end
function wheelReform()      CUS.FormationAssistant.reform(CUS.RadialWheel.ctx.guid); CUS.RadialWheel.close() end
function wheelStory()       if CUS.MovementPanel.guid then CUS.MovementResolver.addStoryCost(CUS.MovementPanel.guid, 1) end end

-- ACTION / WAIT branch buttons pass their argument via onClick="fn(arg)";
-- TTS delivers it as the `value` parameter (id is the element id, unused here).

-- Is this packet one that delivers Force? ACTION covers every packet, so the
-- handler has to look at the packet itself to know whether to open the attack
-- flow or simply announce the effect for the players to resolve.
local function isStrikePacket(guid, packetId)
  local def = CUS.StateStore.getDefinition(guid)
  if not def then return false end
  for _, p in ipairs(CUS.PacketRegistry.resolveAttacks(def) or {}) do
    if p.id == packetId then return true end
  end
  return false
end

function wheelActionPacket(player, value)
  local guid = CUS.RadialWheel.ctx.guid
  CUS.RadialWheel.close()
  if isStrikePacket(guid, value) then
    startAttack(guid, value, "Regular", CUS.RadialWheel.ctx.player)
  else
    CUS.Logger.log("ACTION → " .. tostring(value) .. " (resolve per packet).")
  end
end

function wheelShot(player, value)
  local packetId, mode = value:match("^(.-)|(.+)$")
  CUS.RadialWheel.close()
  startAttack(CUS.RadialWheel.ctx.guid, packetId, mode, CUS.RadialWheel.ctx.player)
end

function wheelWaitPacket(player, value)
  armWait(CUS.RadialWheel.ctx.guid, value); CUS.RadialWheel.close()
end

-- Retired v0.5 entry points, kept as shims.
function wheelAttackPacket(player, value) return wheelActionPacket(player, value) end
function wheelUseAbility(player, value)   return wheelActionPacket(player, value) end
function wheelReadyPacket(player, value)  return wheelWaitPacket(player, value)   end

function wheelInteract()
  CUS.Logger.log("ACTION → Interact: interact with the adjacent object (resolve per object).")
  CUS.RadialWheel.close()
end
function wheelPickUp()
  CUS.Logger.log("ACTION → Pick Up: pick up the target object (resolve per object).")
  CUS.RadialWheel.close()
end

function wheelUtilActivate() uiToggleActivation({ guid = CUS.RadialWheel.ctx.guid }) end
function wheelUtilState()    CUS.StatePanel.refreshGuid(CUS.RadialWheel.ctx.guid) end
function wheelUtilCommand()  CUS.Logger.log("Command (Missions apply to AI banners only).") end
function wheelUtilUndo()     CUS.Undo.pop(); CUS.StatePanel.refreshAll() end

-- ==========================================================================
-- MOVE / CHARGE actions
-- ==========================================================================
function startMove(guid, playerColor)
  local s, reason = CUS.MovementResolver.begin(guid)
  if not s then return end
  activeMovers[guid] = false   -- becomes true on pickup
  CUS.MovementPanel.open(guid, playerColor)
end

function chargeAssist(guid, playerColor)
  local others = enemyList(guid)
  local prev = CUS.ChargeAssistant.preview(guid, others)
  if not prev then return end
  local lines = { ("Charge lane (Speed %d\"). Candidates:"):format(prev.lane.speed) }
  for _, c in ipairs(prev.candidates) do
    lines[#lines+1] = ("• %s @ %.1f\" — %s"):format(c.def.name, c.along, c.plow.note)
  end
  CUS.Logger.log(table.concat(lines, "\n"))
  CUS.Logger.log("Confirm each impact honestly, then open ATTACK for the impact. Wall jam → +2 dice.")
end

function disengage(guid)
  local st = CUS.StateStore.getOrInit(guid).state
  if (st.current_ap or 0) < 1 then CUS.Logger.warn("No AP to Disengage."); return end
  CUS.Undo.pushMiniState(getObjectFromGUID(guid), "Disengage")
  st.current_ap = st.current_ap - 1
  CUS.pushRuntimeToMini(guid)
  CUS.Logger.log("Disengaged (1 AP).")
end

-- Build a rough enemy list for geometry helpers. Sides are inferred from a
-- simple GM tag convention; for the testbed everything not the actor is "enemy".
function enemyList(selfGuid)
  local out = {}
  for guid, rs in pairs(CUS.StateStore.runtime) do
    if guid ~= selfGuid then
      local obj = getObjectFromGUID(guid)
      local def = CUS.StateStore.getDefinition(guid)
      if obj and def then out[#out+1] = { obj = obj, def = def, side = "enemy" } end
    end
  end
  return out
end

-- WAIT arms a PACKET against a trigger. It does not resolve now, and it ENDS
-- the activation even if AP remains (A.III, B.15). Formerly armReady/READY.
function armWait(guid, packetId)
  local st = CUS.StateStore.getOrInit(guid).state
  if (st.current_ap or 0) < 1 then CUS.Logger.warn("No AP to WAIT."); return end
  CUS.Undo.pushMiniState(getObjectFromGUID(guid), "WAIT")
  st.current_ap = st.current_ap - 1
  st.armed_packet_id = packetId
  st.ready_packet_id = packetId       -- legacy key, kept so old saves still read
  st.reaction_spent = true
  st.activated = true                 -- WAIT ends the activation
  CUS.pushRuntimeToMini(guid)
  CUS.Logger.log(("WAIT: %s armed — 1 AP spent, activation ended."):format(packetId))
end

-- Retired v0.5 name.
function armReady(guid, packetId) return armWait(guid, packetId) end

-- ==========================================================================
-- ATTACK flow
-- ==========================================================================
function beginAttackFlow(attackerGuid, playerColor)
  -- open the wheel's ATTACK branch to pick a packet
  CUS.RadialWheel.open(attackerGuid, playerColor)
  CUS.RadialWheel.branchAttack()
end

-- after choosing a packet/mode, the player hovers a defender + presses CUS: Attack.
function startAttack(attackerGuid, packetId, mode, playerColor)
  -- Precision requires not having moved.
  if mode == "Precision" then
    local st = CUS.StateStore.getOrInit(attackerGuid).state
    if st.moved_this_activation then
      CUS.Logger.warn("Precision Shot requires NOT having moved this activation.")
      return
    end
  end
  pendingAttack = { attacker = attackerGuid, packet = packetId, mode = mode, player = playerColor }
  local atk = getObjectFromGUID(attackerGuid)
  if atk then atk.highlightOn(CUS.Constants.COLOR.attacker, 6) end
  -- highlight candidate defenders
  for _, e in ipairs(enemyList(attackerGuid)) do e.obj.highlightOn(CUS.Constants.COLOR.candidate, 6) end
  CUS.Logger.log(("Target %s (%s): HOVER the defender and press 'CUS: Attack' again."):format(packetId, mode))
end

-- Completes the attack once the player hovers a defender and presses CUS: Attack.
function completeAttackTarget(hovered, playerColor)
  if not pendingAttack or playerColor ~= pendingAttack.player then return end
  if not (hovered and hovered.getVar and hovered.getVar("CUS_MINI") ~= nil) then
    CUS.Logger.warn("Hover a linked defender miniature, then press CUS: Attack."); return
  end
  local defenderGuid = hovered.getGUID()
  if defenderGuid == pendingAttack.attacker then
    CUS.Logger.warn("That's the attacker — hover a different figure."); return
  end
  local s, reason = CUS.AttackResolver.begin({
    attackerGuid = pendingAttack.attacker,
    defenderGuid = defenderGuid,
    packetId = pendingAttack.packet,
    mode = pendingAttack.mode,
  })
  clearHighlights()
  local pc = pendingAttack.player
  pendingAttack = nil
  if not s then CUS.Logger.warn("Attack setup failed: " .. tostring(reason)); return end
  CUS.AttackPanel.render(pc)
end

function clearHighlights()
  for guid in pairs(CUS.StateStore.runtime) do
    local o = getObjectFromGUID(guid)
    if o then o.highlightOff() end
  end
end

-- attack panel onClick shims
function apToggleCover() flipJudgment("cover", "Cover", { hitStep = 0, note = "Cover — defender benefits (ignored by Precision)" }) end
function apToggleHigh()  flipJudgment("high",  "High Ground", { dice = 1, note = "High ground — attacker +1 die" }) end
function apToggleLoS()   CUS.Logger.log("LoS confirmed clear by player.") end
function apToggleMob()
  local s = CUS.AttackResolver.session; if not s then return end
  CUS.AttackResolver.confirmMob(not s.mob_confirmed)
  CUS.AttackPanel.render()
end

-- Add/remove a player-confirmed judgment modifier by source label.
function flipJudgment(key, source, mod)
  local s = CUS.AttackResolver.session; if not s then return end
  s.judgments[key] = not s.judgments[key]
  -- remove any existing modifier with this source, then add if toggled on
  for i = #s.modifiers, 1, -1 do if s.modifiers[i].source == source then table.remove(s.modifiers, i) end end
  if s.judgments[key] then
    mod.source = source
    table.insert(s.modifiers, mod)
  end
  CUS.AttackPanel.render()
end

function apRoll()
  local r = CUS.AttackResolver.resolve()
  if r then CUS.AttackPanel.renderResult() end
end

function apEnterDice()
  UI.setAttribute("man_prompt", "text", "Enter dice results (space-separated), e.g. 5 3 6 2")
  manualMode = "dice"; UI.show("cus_manual")
end
function apEnterSuccesses()
  UI.setAttribute("man_prompt", "text", "Enter success COUNT, e.g. 3")
  manualMode = "successes"; UI.show("cus_manual")
end

manualMode = nil
manInputValue = ""
function manInputChanged(player, value) manInputValue = value or "" end
function manOK(player, value, id)
  local txt = manInputValue or ""
  UI.hide("cus_manual")
  if manualMode == "successes" then
    local n = tonumber(txt)
    if n then CUS.AttackResolver.resolve({ successes = n }); CUS.AttackPanel.renderResult() end
  else
    local dice = {}
    for tok in string.gmatch(txt, "%d+") do dice[#dice+1] = tonumber(tok) end
    if #dice > 0 then CUS.AttackResolver.resolve({ dice = dice }); CUS.AttackPanel.renderResult() end
  end
end
function manCancel() UI.hide("cus_manual") end

function apApply()
  local res = CUS.AttackResolver.apply()
  if not res then return end
  CUS.StatePanel.refreshAll()
  if res.counter_possible then
    CUS.Logger.log("Defender may COUNTER (bases touching, not Reach/Backstab). Click 'Resolve Counter' or continue.")
  else
    CUS.AttackPanel.close()
  end
end

function apCounter()
  local s = CUS.AttackResolver.session
  if not s or not s.result then return end
  -- legality via CounterResolver, using facts captured in the session
  local ctx = { touching = s.touching, reach = s.reach,
                suppressCounter = s.result.comp.suppressCounter,
                backstab = (s.facing == "Rear") }
  local legal, why = CUS.CounterResolver.isLegal(s.defenderGuid, s.attackerGuid, ctx)
  if not legal then CUS.Logger.warn("No Counter: " .. why); return end
  local cs, reason = CUS.CounterResolver.resolve(s.defenderGuid, s.attackerGuid)
  if cs then CUS.AttackPanel.render(CUS.AttackPanel.player) else CUS.Logger.warn(tostring(reason)) end
end

function apCancel() CUS.AttackResolver.cancel(); CUS.AttackPanel.close(); clearHighlights() end

-- ==========================================================================
-- MOVEMENT panel shims
-- ==========================================================================
function mpStory()  if CUS.MovementPanel.guid then CUS.MovementResolver.addStoryCost(CUS.MovementPanel.guid, 1) end end
function mpCommit() if CUS.MovementPanel.guid then CUS.MovementResolver.commit(CUS.MovementPanel.guid) end end
function mpUndo()   if CUS.MovementPanel.guid then CUS.MovementResolver.cancel(CUS.MovementPanel.guid) end end
function mpCancel() if CUS.MovementPanel.guid then CUS.MovementResolver.cancel(CUS.MovementPanel.guid) end end

-- ==========================================================================
-- CARD viewer shims
-- ==========================================================================
function cardPin(player)   CUS.CardViewer.togglePin(player.color) end
function cardClose(player) local c = CUS.CardViewer.open[player.color]; if c then c.pinned = false end; CUS.CardViewer.close(player.color) end

-- ==========================================================================
-- NERVE panel shims
-- ==========================================================================
function openNerve(p) CUS.NervePanel.open(p.guid, p.player) end
function npPass()   CUS.Logger.log("Nerve PASS (manual)."); CUS.NervePanel.close() end
function npFail()   local g = CUS.NervePanel.guid; CUS.NerveResolver.setMorale(g, "Shaken"); CUS.Logger.log("Nerve FAIL (manual) → Shaken."); CUS.StatePanel.refreshGuid(g) end
function npShaken() local g = CUS.NervePanel.guid; CUS.NerveResolver.setMorale(g, "Shaken"); CUS.StatePanel.refreshGuid(g) end
function npRally()  local g = CUS.NervePanel.guid; CUS.NerveResolver.setMorale(g, "Steady"); CUS.StatePanel.refreshGuid(g); CUS.NervePanel.close() end
function npRout()
  local g = CUS.NervePanel.guid
  CUS.NerveResolver.setMorale(g, "Broken")
  local def = CUS.StateStore.getDefinition(g)
  CUS.Logger.log("ROUT — " .. CUS.NerveResolver.routInstruction(def) .. "  (move the figure yourself).")
  CUS.StatePanel.refreshGuid(g)
end
function npClose() CUS.NervePanel.close() end

-- ==========================================================================
-- FORMATION panel shims
-- ==========================================================================
function fpFormWedge()  CUS.FormationPanel.setFormation("Wedge") end
function fpFormColumn() CUS.FormationPanel.setFormation("Column") end
function fpFormShield() CUS.FormationPanel.setFormation("Shield Wall") end
function fpFormLine()   CUS.FormationPanel.setFormation("Line") end
function fpAddSel(player)
  local sel = player and player.getSelectedObjects() or {}
  local guids = {}
  for _, o in ipairs(sel) do
    if o.getVar and o.getVar("CUS_MINI") ~= nil then guids[#guids+1] = o.getGUID() end
  end
  CUS.FormationPanel.addSelection(guids)
end
function fpAdvance() CUS.FormationPanel.doAdvance() end
function fpReform()  CUS.FormationPanel.doReform() end
function fpClose()   CUS.FormationPanel.close() end

-- ==========================================================================
-- CONDITIONS panel
-- ==========================================================================
local condTarget = nil
function openConditions(guid, playerColor)
  condTarget = guid
  local def = CUS.StateStore.getDefinition(guid)
  UI.setAttribute("cond_name", "text", "Conditions — " .. (def and def.name or guid))
  refreshConditions()
  UI.setAttribute("cus_cond", "visibility", playerColor)
  UI.show("cus_cond")
end

function refreshConditions()
  if not condTarget then return end
  local rows = {}
  for _, c in ipairs(CUS.ConditionManager.list(condTarget)) do
    -- One flat row per condition; tapping it removes that condition.
    rows[#rows+1] = {
      text = (c.icon or "-") .. " " .. c.id .. "     [tap to remove]",
      onClick = "condRemove(" .. c.id .. ")",
    }
  end
  if #rows == 0 then rows[1] = { kind = "header", text = "none" } end
  CUS.UIList.fill("cond_r", 12, rows)
end

condInputValue = ""
function condInputChanged(player, value) condInputValue = value or "" end
function condAdd()
  local id = condInputValue
  if id and id ~= "" and condTarget then CUS.ConditionManager.add(condTarget, id); refreshConditions(); CUS.StatePanel.refreshGuid(condTarget); condInputValue = "" end
end
function condRemove(player, value)
  if value and condTarget then CUS.ConditionManager.remove(condTarget, value); refreshConditions(); CUS.StatePanel.refreshGuid(condTarget) end
end
function condClose() UI.hide("cus_cond") end

-- ==========================================================================
-- ROUND / LOG shims
-- ==========================================================================
function rmNewRound()
  CUS.RoundManager.newRound()
  UI.setAttribute("rm_round", "text", "Round " .. CUS.RoundManager.round)
  CUS.StatePanel.refreshAll()
  refreshLog()
end
function rmToggleLog()
  logVisible = not logVisible
  if logVisible then refreshLog(); UI.show("cus_logpanel") else UI.hide("cus_logpanel") end
end
function rmUndo() CUS.Undo.pop(); CUS.StatePanel.refreshAll() end
function rmAudit()
  local problems = CUS.StateStore.audit()
  if #problems == 0 then CUS.Logger.log("Link audit: all good.")
  else for _, p in ipairs(problems) do CUS.Logger.warn(p) end end
end
function rmFixture() CUS.Fixture.spawn() end
function rmBlankCard() CUS.Fixture.spawnBlankCard() end
function rmDump()
  print(JSON.encode_pretty({ packets = CUS.PacketRegistry.serialize(), store = CUS.StateStore.serialize() }))
  CUS.Logger.log("Dumped registry + store to the host's -> Console (~).")
end
logVisible = false
function refreshLog() UI.setAttribute("log_text", "text", CUS.Logger.tail(24)) end

-- ==========================================================================
-- UNIT LIBRARY  (browse catalog; stamp a unit's stats onto a card)
-- ==========================================================================
-- Opened from a card's context menu, the Round panel, or a mini's linked card.
function openUnitLibrary(p)             -- p = { player, card? }
  CUS.UnitLibrary.open(p.player, p.card)
end
function rmLibrary(player) CUS.UnitLibrary.open(player.color, nil) end
function libFaction(player, value) CUS.UnitLibrary.setFaction(value) end
function libBack() CUS.UnitLibrary.back() end
function libApply(player, value)  CUS.UnitLibrary.apply(value, player.color) end
function libClose() CUS.UnitLibrary.close() end

-- ==========================================================================
-- CARD LAYOUT EDITOR  (move/resize the stat zones; shared with the HTML forge)
-- ==========================================================================
function openLayoutEditor(p)            -- p = { player, card }
  CUS.CardFace.openEditor(p.card, p.player)
end
function renderCardFace(p) CUS.CardFace.render(p.card) end

local STEP_POS  = 0.01
local STEP_SIZE = 0.005
function clZonePrev() CUS.CardFace.cycleZone(-1) end
function clZoneNext() CUS.CardFace.cycleZone(1) end
function clXminus() CUS.CardFace.adjust("x", -STEP_POS) end
function clXplus()  CUS.CardFace.adjust("x",  STEP_POS) end
function clYminus() CUS.CardFace.adjust("y", -STEP_POS) end
function clYplus()  CUS.CardFace.adjust("y",  STEP_POS) end
function clWminus() CUS.CardFace.adjust("w", -STEP_POS) end
function clWplus()  CUS.CardFace.adjust("w",  STEP_POS) end
function clHminus() CUS.CardFace.adjust("h", -STEP_POS) end
function clHplus()  CUS.CardFace.adjust("h",  STEP_POS) end
function clFminus() CUS.CardFace.adjust("size", -STEP_SIZE) end
function clFplus()  CUS.CardFace.adjust("size",  STEP_SIZE) end
function clAlign()  CUS.CardFace.cycleAlign() end
function clShow()   CUS.CardFace.toggleShow() end
function clApplyAll() CUS.CardFace.renderAll() end
function clExport() CUS.CardFace.exportJSON() end
clImportValue = ""
function clImportChanged(player, value) clImportValue = value or "" end
function clImport() CUS.CardFace.importJSON(clImportValue) end
function clClose()  CUS.CardFace.closeEditor() end
