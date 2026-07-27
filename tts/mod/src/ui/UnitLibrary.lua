-- ui/UnitLibrary.lua
-- Browse the whole unit catalog (all factions) and stamp a chosen unit onto a
-- card with one click — "click the card and it takes all its stats." The card
-- becomes the authoritative definition object for that unit; the miniature
-- linked to it then reads those stats normally.
--
-- Catalog shape (built in Global from data/unit_library.lua):
--   CUS.UNIT_LIBRARY = {
--     factions = { { faction="Sauron", prefix="SAU", units={ {def}, ... } }, ... },
--     byId     = { SAU_TROLL = {def}, ... }
--   }

CUS = CUS or {}
local Lib = {}
Lib.player, Lib.faction, Lib.targetCard = nil, nil, nil

local function factions() return (CUS.UNIT_LIBRARY and CUS.UNIT_LIBRARY.factions) or {} end

local SLOTS = 20                                  -- must match lib_r1..lib_r20 in Global.xml
local function fill(rows) CUS.UIList.fill("lib_r", SLOTS, rows) end

-- A small popup with two steps: pick a faction, then tap a unit. One list is
-- reused for both, so the panel stays the same size either way.
Lib.mode = "factions"

function Lib.open(playerColor, targetCardGuid)
  Lib.player = playerColor
  Lib.targetCard = targetCardGuid            -- may be nil; resolved at apply time
  Lib.showFactions()
  UI.setAttribute("cus_lib", "visibility", playerColor)
  UI.show("cus_lib")
end

function Lib.showFactions()
  Lib.mode = "factions"
  local rows = {}
  for _, f in ipairs(factions()) do
    local n = #(f.units or {})
    rows[#rows+1] = {
      text = ("%s   (%d)"):format(f.faction, n),
      onClick = "libFaction(" .. f.faction .. ")",
    }
  end
  if #rows == 0 then
    rows[1] = { kind = "header", text = "No factions loaded. Check the console for a unit-library parse warning." }
  end
  fill(rows)
  UI.setAttribute("lib_title", "text", "Unit Library")
  UI.setAttribute("lib_hint",  "text", "Pick a faction.")
  UI.setAttribute("lib_back",  "active", "false")
end

function Lib.currentFaction()
  for _, f in ipairs(factions()) do if f.faction == Lib.faction then return f end end
  return nil
end

-- Retired: the old two-column layout had a separate faction tab strip.
function Lib.buildFactionTabs() Lib.showFactions() end

function Lib.buildUnitList()
  Lib.mode = "units"
  local f = Lib.currentFaction()
  local rows = {}
  if f then
    for _, u in ipairs(f.units or {}) do
      local b = u.base or {}
      -- v0.6: mounted is GEOMETRY (an elongated base), not a class; Monstrous
      -- is gone — a monster is a Large figure carrying the unstoppable trait.
      -- Old cards still say Cavalry/Monstrous, so both spellings are read.
      local tag = ""
      if b.mounted or b.class == "Cavalry" then tag = "  [mtd]"
      elseif b.class == "Large" or b.class == "Monstrous" then tag = "  [Lg]" end

      -- ASCII only. TTS's UI font has no emoji glyphs, and non-ASCII here is
      -- what the build-script encoding bug used to mangle.
      local cls = CUS.Constants.migrateClass(b.class or "")
      rows[#rows+1] = {
        text = string.format("%s  -  %s %s%s",
          tostring(u.name), tostring(u.role or "?"), cls, tag),
        onClick = "libApply(" .. u.definition_id .. ")",
        tooltip = (u.display and u.display.weapon or "") .. "  " ..
                  (u.display and (u.display.grades or u.display.tiers) or ""),
      }
    end
  end
  if #rows == 0 then rows[1] = { kind = "header", text = "No units in this faction." } end
  fill(rows)
  UI.setAttribute("lib_title", "text", tostring(Lib.faction or "?"))
  UI.setAttribute("lib_hint",  "text", "Select a card, then tap a unit to stamp it.")
  UI.setAttribute("lib_back",  "active", "true")
end

function Lib.setFaction(name)
  Lib.faction = name
  Lib.buildUnitList()
end

-- Back to the faction list.
function Lib.back() Lib.showFactions() end

-- Resolve which card to stamp: explicit target, else the player's selected card,
-- else the card currently open in the layout editor.
local function resolveTargetCard(playerColor)
  if Lib.targetCard and getObjectFromGUID(Lib.targetCard) then return Lib.targetCard end
  local pl = Player[playerColor]
  for _, o in ipairs(pl and pl.getSelectedObjects() or {}) do
    if o.getVar and o.getVar("CUS_CARD") ~= nil then return o.getGUID() end
  end
  if CUS.CardFace and CUS.CardFace.editGuid then return CUS.CardFace.editGuid end
  return nil
end

function Lib.apply(defId, playerColor)
  local def = CUS.UNIT_LIBRARY and CUS.UNIT_LIBRARY.byId and CUS.UNIT_LIBRARY.byId[defId]
  if not def then if CUS.Logger then CUS.Logger.warn("Unknown unit: " .. tostring(defId)) end return end
  local cardGuid = resolveTargetCard(playerColor)
  if not cardGuid then
    if CUS.Logger then CUS.Logger.warn("Select a CUS card first (left-click it), then pick a unit.") end
    return
  end
  local card = getObjectFromGUID(cardGuid)
  -- deep copy so each card owns its own definition instance
  local copy = CUS.Undo and CUS.Undo.deepcopy(def) or def
  local res = card.call("setDefinition", copy)
  card.setName(def.name)
  if CUS.CardFace then CUS.CardFace.render(cardGuid) end
  card.highlightOn({ 0.6, 1, 0.6 }, 3)
  if CUS.Logger then CUS.Logger.log(("Stamped '%s' (%s) onto card %s."):format(def.name, def.definition_id, cardGuid)) end
  -- if a miniature is already linked to this card, refresh its panels
  for guid, rs in pairs(CUS.StateStore.runtime) do
    if rs.card_guid == cardGuid then
      rs.expected_definition_id = def.definition_id
      CUS.pushRuntimeToMini(guid)
    end
  end
end

function Lib.close() UI.hide("cus_lib") end

CUS.UnitLibrary = Lib
