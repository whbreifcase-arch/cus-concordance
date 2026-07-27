-- ui/CardViewer.lua
-- Player-local large card image panel. Toggle with the same action. Pin/Unpin
-- and multiple pinned cards supported. NEVER creates a second authoritative
-- gameplay card — it only shows the presentation PNG/SVG. If no image URL is
-- available, it falls back to highlighting the physical card.

CUS = CUS or {}
local Store = CUS.StateStore
local Viewer = {}

Viewer.open = {}     -- playerColor -> { url, guid, pinned }

function Viewer.openForMini(miniGuid, playerColor)
  local def, reason = Store.getDefinition(miniGuid)
  local card = select(1, Store.resolveCard(miniGuid))
  if not def then
    if CUS.Logger then CUS.Logger.warn("Open Card: " .. tostring(reason)) end
    if card then card.highlightOn({ 0.55, 1, 0.55 }, 4) end
    return
  end
  local url = def.display and def.display.card_image_url or ""
  if url == "" then
    -- fallback: focus/highlight the physical card
    if card then
      card.highlightOn({ 0.55, 1, 0.55 }, 4)
      if CUS.Logger then CUS.Logger.log("No card image URL — highlighted the physical card instead.", { broadcast = false }) end
    end
    return
  end
  -- toggle behaviour
  local cur = Viewer.open[playerColor]
  if cur and cur.guid == miniGuid and not cur.pinned then
    Viewer.close(playerColor)
    return
  end
  Viewer.open[playerColor] = { url = url, guid = miniGuid, pinned = cur and cur.pinned or false }
  -- TTS <Image> references a registered Custom UI Asset by name, not a raw URL.
  -- Register (or update) the card image as an asset, then point the Image at it.
  local assetName = "cuscard_" .. miniGuid
  local assets = UI.getCustomAssets() or {}
  local found = false
  for _, a in ipairs(assets) do if a.name == assetName then a.url = url; found = true end end
  if not found then table.insert(assets, { name = assetName, url = url }) end
  UI.setCustomAssets(assets)
  UI.setAttribute("cus_card_img", "image", assetName)
  UI.setAttribute("cus_card_title", "text", def.name)
  UI.setAttribute("cus_cardviewer", "visibility", playerColor)
  UI.show("cus_cardviewer")
end

function Viewer.togglePin(playerColor)
  local cur = Viewer.open[playerColor]
  if cur then
    cur.pinned = not cur.pinned
    UI.setAttribute("cus_card_pin", "text", cur.pinned and "📌 Pinned" or "Pin")
  end
end

function Viewer.close(playerColor)
  local cur = Viewer.open[playerColor]
  if cur and cur.pinned then return end   -- pinned stays open
  Viewer.open[playerColor] = nil
  UI.hide("cus_cardviewer")
end

CUS.CardViewer = Viewer
