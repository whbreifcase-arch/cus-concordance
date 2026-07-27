-- objects/CardController.lua
-- OBJECT SCRIPT — paste onto each physical unit CARD.
--
-- The card is the AUTHORITATIVE unit DEFINITION object. It never holds runtime
-- state. It stores its structured definition in the object's own script state
-- (reliable across save/load) and mirrors an editable copy into GM Notes so a
-- designer can hand-tune JSON without opening the Lua editor.
--
-- Stable callable methods (contract required by the spec):
--     getDefinition()      -> table (structured definition)
--     getDefinitionId()    -> string
--     getCardImageUrl()    -> string
--     validateDefinition() -> { ok = bool, errors = {...} }
--
-- This script is intentionally self-contained (object scripts can't share the
-- Global #includes). It calls back into Global only for cross-object actions.

CUS_CARD = true          -- marker global; Global detects CUS cards via getVar
local definition = nil   -- the structured DEFINITION table (schema in Global)

-- ---------- minimal local validation (mirrors core/Schema, kept lean) --------
local ROLES = { Assault=true, Anchor=true, Skirmisher=true, Control=true, Support=true }
local TYPES = { Man=true, Beast=true, Spirit=true, Construct=true }

local function validate(def)
  local errs = {}
  if type(def) ~= "table" then return { ok = false, errors = { "not a table" } } end
  if type(def.definition_id) ~= "string" or def.definition_id == "" then errs[#errs+1] = "missing definition_id" end
  if type(def.name) ~= "string" or def.name == "" then errs[#errs+1] = "missing name" end
  if not ROLES[def.role] then errs[#errs+1] = "invalid role" end
  if not TYPES[def.creature_type] then errs[#errs+1] = "invalid creature_type" end
  if type(def.stats) ~= "table" then errs[#errs+1] = "missing stats" end
  if type(def.base) ~= "table" then errs[#errs+1] = "missing base" end
  return { ok = (#errs == 0), errors = errs }
end

-- ---------- callable contract ----------------------------------------------
function getDefinition()      return definition end
function getDefinitionId()    return definition and definition.definition_id or nil end
function getCardImageUrl()
  return definition and definition.display and definition.display.card_image_url or nil
end
function validateDefinition() return validate(definition) end

-- Global setter so the Global controller (or a loader) can push a definition in.
function setDefinition(newDef)
  definition = newDef
  writeGMNotesFromDefinition()
  refreshContextMenu()
  return validate(definition)
end

-- ---------- GM Notes mirror (editable JSON surface) ------------------------
function writeGMNotesFromDefinition()
  if definition then
    self.setGMNotes(JSON.encode_pretty(definition))
  end
end

-- Re-read the definition from GM Notes (lets a designer edit JSON in-place).
function loadDefinitionFromGMNotes()
  local notes = self.getGMNotes()
  if not notes or notes == "" then
    broadcastToAll("[CUS] Card GM Notes are empty — nothing to load.", { 1, 0.75, 0.2 })
    return
  end
  local ok, decoded = pcall(function() return JSON.decode(notes) end)
  if not ok or type(decoded) ~= "table" then
    broadcastToAll("[CUS] Card GM Notes are not valid JSON — keeping previous definition.", { 1, 0.4, 0.4 })
    return
  end
  local v = validate(decoded)
  if not v.ok then
    broadcastToAll("[CUS] Card definition invalid: " .. table.concat(v.errors, "; "), { 1, 0.4, 0.4 })
    return
  end
  definition = decoded
  broadcastToAll("[CUS] Loaded definition '" .. tostring(definition.name) .. "' from GM Notes.", { 0.6, 1, 0.6 })
  refreshContextMenu()
end

-- ---------- save / load -----------------------------------------------------
function onSave()
  return JSON.encode({ definition = definition })
end

function onLoad(saved)
  if saved and saved ~= "" then
    local ok, blob = pcall(function() return JSON.decode(saved) end)
    if ok and type(blob) == "table" then definition = blob.definition end
  end
  -- If nothing was in script state, try GM Notes (designer-authored path).
  if not definition then
    local notes = self.getGMNotes()
    if notes and notes ~= "" then
      local ok, decoded = pcall(function() return JSON.decode(notes) end)
      if ok and type(decoded) == "table" and validate(decoded).ok then definition = decoded end
    end
  end
  refreshContextMenu()
end

-- ---------- right-click context menu ---------------------------------------
function refreshContextMenu()
  self.clearContextMenu()
  self.addContextMenuItem("Highlight Linked Miniature", function(pc)
    Global.call("cardHighlightLinkedMini", { card = self, player = pc })
  end)
  self.addContextMenuItem("Link Selected Miniature", function(pc)
    Global.call("cardLinkSelectedMini", { card = self, player = pc })
  end)
  self.addContextMenuItem("Open Unit Library (stamp this card)", function(pc)
    Global.call("openUnitLibrary", { player = pc, card = self.getGUID() })
  end)
  self.addContextMenuItem("Render Card Face", function()
    Global.call("renderCardFace", { card = self.getGUID() })
  end)
  self.addContextMenuItem("Edit Card Layout", function(pc)
    Global.call("openLayoutEditor", { player = pc, card = self.getGUID() })
  end)
  self.addContextMenuItem("Load Definition From GM Notes", function() loadDefinitionFromGMNotes() end)
  self.addContextMenuItem("Show Definition Id", function()
    broadcastToAll("[CUS] definition_id = " .. tostring(getDefinitionId()), { 0.8, 0.9, 1 })
  end)
end
