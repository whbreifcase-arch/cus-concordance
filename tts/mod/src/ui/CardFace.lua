-- ui/CardFace.lua
-- Renders a card's stats onto the card OBJECT's UI using the shared layout
-- (CUS.CARD_LAYOUT, decoded from data/card_layout.lua — the same JSON the HTML
-- Card Forge edits). Also drives the in-TTS nudge editor that moves/resizes the
-- zones live and can Export/Import the layout JSON so the two editors stay in
-- sync.
--
-- Coordinates in the layout are NORMALIZED (0..1) over a fixed pixel canvas so
-- the same numbers work in HTML and here. Object-UI placement (rotation/scale/
-- offset of the whole face) is tunable via layout.card.ui_* — first load on a
-- given card shape may need a small calibration (see docs/CARDS.md).

CUS = CUS or {}
local Store = CUS.StateStore
local Face = {}

Face.CANVAS_W = 500
Face.CANVAS_H = 700

-- current editor selection
Face.editGuid = nil
Face.editZone = "name"
Face.player   = nil

-- ---- value resolver: binding key -> display string from a definition -------
local function valueFor(key, def)
  local d = def.display or {}
  local s = def.stats or {}
  local b = def.base or {}
  local map = {
    name   = def.name,
    role   = def.role,
    tool   = def.tool,
    temper = def.temperament,
    base   = d.base ~= "" and d.base or ((b.shape or "") .. " / " .. (b.class or "")),
    dice   = d.dice ~= 0 and tostring(d.dice) or "",
    hit    = d.hit,
    wounds = tostring(s.max_wounds),
    armour = d.armour ~= "" and d.armour or (s.armour or ""),
    speed  = tostring(s.speed),
    ap     = tostring(s.max_ap),
    nerve  = (s.nerve and s.nerve > 0) and tostring(s.nerve) or "—",
    rank   = s.rank,
    weapon = d.weapon,
    tiers  = d.tiers,
    note   = d.note,
  }
  local v = map[key]
  if v == nil then v = "" end
  return tostring(v)
end

local ALIGN = { left = "UpperLeft", center = "UpperCenter", right = "UpperRight" }

-- Escape text so it is safe inside a TTS UI XML attribute.
local function xmlEscape(s)
  s = tostring(s or "")
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
       :gsub('"', "&quot;"):gsub("'", "&apos;")
  return s
end

-- Build the object-UI XML for a card face from the layout + definition.
local function buildFaceXml(def, highlightZone)
  local L = CUS.CARD_LAYOUT
  local card = L.card or {}
  local W, H = Face.CANVAS_W, Face.CANVAS_H
  local children = {}

  for key, z in pairs(L.zones or {}) do
    if z.show ~= false then
      local text = (z.label or "") .. valueFor(key, def)
      local px = z.x * W
      local py = z.y * H
      local pw = z.w * W
      local ph = z.h * H
      local fs = math.max(6, math.floor(z.size * H))
      local col = (key == highlightZone) and "#ffcf5a" or (card.fg or "#e8f0ff")
      -- UpperLeft anchor: +x right, +y DOWN needs negative offset y in TTS UI.
      children[#children+1] = string.format(
        '<Text text="%s" rectAlignment="%s" width="%d" height="%d" offsetXY="%d %d" '
        .. 'fontSize="%d" color="%s" alignment="%s" resizeTextForBestFit="false"/>',
        xmlEscape(text), "UpperLeft", math.floor(pw), math.floor(ph),
        math.floor(px), -math.floor(py), fs, col, ALIGN[z.align] or "UpperLeft")
    end
  end

  local rot   = card.ui_rotation or "90 0 0"
  local scale = card.ui_scale or "0.25 0.25 1"
  local pos   = card.ui_position or "0 3 0"
  return string.format(
    '<Panel width="%d" height="%d" position="%s" rotation="%s" scale="%s" color="%s">%s</Panel>',
    W, H, pos, rot, scale, card.bg or "#141821", table.concat(children, ""))
end

-- Render (or clear) a card's face.
function Face.render(cardGuid, highlightZone)
  local card = getObjectFromGUID(cardGuid)
  if not card then return end
  local ok, def = pcall(function() return card.call("getDefinition") end)
  if not ok or type(def) ~= "table" then
    pcall(function() card.UI.setXml("") end)
    return
  end
  pcall(function() card.UI.setXml(buildFaceXml(def, highlightZone)) end)
end

-- Render a card face for the card linked to a miniature (convenience).
function Face.renderForMini(miniGuid)
  local rs = Store.get(miniGuid)
  if rs and rs.card_guid then Face.render(rs.card_guid) end
end

-- Re-render every known CUS card (after a layout change).
function Face.renderAll()
  for _, obj in ipairs(getAllObjects()) do
    if obj.getVar and obj.getVar("CUS_CARD") ~= nil then Face.render(obj.getGUID()) end
  end
end

-- ---- nudge editor ----------------------------------------------------------
Face.ZONE_ORDER = { "name","role","tool","base","temper","dice","hit","wounds",
                    "armour","speed","ap","nerve","rank","weapon","tiers","note" }

function Face.openEditor(cardGuid, playerColor)
  Face.editGuid = cardGuid
  Face.player = playerColor
  Face.editZone = Face.editZone or "name"
  Face.refreshEditor()
  UI.setAttribute("cus_layout", "visibility", playerColor)
  UI.show("cus_layout")
  Face.render(cardGuid, Face.editZone)
end

function Face.refreshEditor()
  local z = CUS.CARD_LAYOUT.zones[Face.editZone] or {}
  UI.setAttribute("cl_zone", "text", "Zone: " .. Face.editZone)
  UI.setAttribute("cl_info", "text", string.format(
    "x %.3f  y %.3f   w %.3f  h %.3f   size %.3f   %s   %s",
    z.x or 0, z.y or 0, z.w or 0, z.h or 0, z.size or 0, z.align or "left",
    (z.show == false) and "HIDDEN" or "shown"))
end

function Face.cycleZone(dir)
  local idx = 1
  for i, k in ipairs(Face.ZONE_ORDER) do if k == Face.editZone then idx = i end end
  idx = ((idx - 1 + dir) % #Face.ZONE_ORDER) + 1
  Face.editZone = Face.ZONE_ORDER[idx]
  Face.refreshEditor()
  if Face.editGuid then Face.render(Face.editGuid, Face.editZone) end
end

-- adjust a property of the selected zone (dx/dy/dw/dh/dsize) and re-render
function Face.adjust(prop, delta)
  local z = CUS.CARD_LAYOUT.zones[Face.editZone]
  if not z then return end
  z[prop] = math.max(0, (z[prop] or 0) + delta)
  Face.refreshEditor()
  if Face.editGuid then Face.render(Face.editGuid, Face.editZone) end
end

function Face.cycleAlign()
  local z = CUS.CARD_LAYOUT.zones[Face.editZone]; if not z then return end
  local order = { left = "center", center = "right", right = "left" }
  z.align = order[z.align or "left"] or "left"
  Face.refreshEditor()
  if Face.editGuid then Face.render(Face.editGuid, Face.editZone) end
end

function Face.toggleShow()
  local z = CUS.CARD_LAYOUT.zones[Face.editZone]; if not z then return end
  z.show = not (z.show ~= false)
  Face.refreshEditor()
  if Face.editGuid then Face.render(Face.editGuid, Face.editZone) end
end

-- Export the current layout as JSON (printed to host console for paste-back).
function Face.exportJSON()
  local json = JSON.encode_pretty({ card = CUS.CARD_LAYOUT.card, zones = CUS.CARD_LAYOUT.zones })
  print("[CUS card_layout.json]\n" .. json)
  if CUS.Logger then CUS.Logger.log("Layout JSON printed to host console (~). Paste it into card_layout.json / the HTML forge.") end
  return json
end

-- Import a pasted layout JSON string.
function Face.importJSON(str)
  local ok, decoded = pcall(function() return JSON.decode(str) end)
  if not ok or type(decoded) ~= "table" or type(decoded.zones) ~= "table" then
    if CUS.Logger then CUS.Logger.warn("Import failed: not valid layout JSON.") end
    return
  end
  CUS.CARD_LAYOUT = decoded
  Face.refreshEditor()
  Face.renderAll()
  if CUS.Logger then CUS.Logger.log("Layout imported and applied to all cards.") end
end

function Face.closeEditor()
  UI.hide("cus_layout")
  if Face.editGuid then Face.render(Face.editGuid) end   -- drop highlight
end

CUS.CardFace = Face
