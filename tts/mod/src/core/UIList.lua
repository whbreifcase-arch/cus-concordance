-- core/UIList.lua
-- Dynamic list rendering for TTS panels, done the way TTS actually supports.
--
-- WHY THIS EXISTS. The mod used to build lists with:
--     UI.setXmlTable(rows, "some_element_id")
-- That call does NOT scope the rows to an element. TTS's signature is
--     UI.setXmlTable(xmlTable, assetTable)
-- so the second argument was being taken as the custom ASSET TABLE, and the
-- rows replaced the ENTIRE global UI. Symptom: opening the Unit Library (or the
-- radial wheel) blanked every panel and left one button stretched across the
-- whole screen. It was doing exactly what it was told.
--
-- TTS has no supported "replace the children of element X" call. The standard
-- pattern is to PRE-DECLARE a fixed number of slots in the XML, inactive by
-- default, and then drive them with UI.setAttribute — which touches only the
-- element named and never disturbs the rest of the UI.
--
-- Usage:
--   CUS.UIList.fill("lib_r", 20, {
--     { text = "Militia", onClick = "libFaction(Militia)" },
--     { text = "Goblins", onClick = "libFaction(Goblins)", color = "#3a4a72" },
--   })
--
-- Any slot beyond the supplied rows is hidden. If there are more rows than
-- slots, the overflow is reported rather than silently dropped.

CUS = CUS or {}
local L = {}

L.DEFAULT_COLOR      = "#2a3550"
L.DEFAULT_TEXT_COLOR = "#dce6ff"

-- Fill `count` slots named prefix1..prefixN from `rows`.
-- A row is { text, onClick?, tooltip?, color?, textColor?, fontSize?, kind? }
-- kind = "header" renders as a dimmed, non-clickable label.
function L.fill(prefix, count, rows)
  rows = rows or {}
  for i = 1, count do
    local id  = prefix .. i
    local row = rows[i]
    if row then
      local header = (row.kind == "header")
      UI.setAttribute(id, "active",    "true")
      UI.setAttribute(id, "text",      tostring(row.text or ""))
      UI.setAttribute(id, "onClick",   header and "" or tostring(row.onClick or ""))
      UI.setAttribute(id, "tooltip",   tostring(row.tooltip or ""))
      UI.setAttribute(id, "color",     header and "#00000000" or (row.color or L.DEFAULT_COLOR))
      UI.setAttribute(id, "textColor", row.textColor or (header and "#8899bb" or L.DEFAULT_TEXT_COLOR))
      UI.setAttribute(id, "fontSize",  tostring(row.fontSize or (header and 12 or 14)))
      UI.setAttribute(id, "interactable", header and "false" or "true")
    else
      UI.setAttribute(id, "active", "false")
    end
  end

  if #rows > count and CUS.Logger then
    CUS.Logger.warn(("%s: %d rows but only %d slots — %d not shown."):format(
      prefix, #rows, count, #rows - count), { broadcast = false })
  end
end

-- Convenience: hide every slot in a list.
function L.clear(prefix, count)
  for i = 1, count do UI.setAttribute(prefix .. i, "active", "false") end
end

-- Slot counts, declared once here so the Lua and the XML cannot drift.
L.SLOTS = {
  lib      = 20,   -- lib_r1..20     Unit Library rows (factions, then units)
  wheelsub = 20,   -- whsub1..20     radial wheel submenu
  cond     = 12,   -- cond_r1..12    conditions list
  ledger   = 14,   -- ledg_r1..14    attack modifier ledger
}

CUS.UIList = L
