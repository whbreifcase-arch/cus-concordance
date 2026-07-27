-- ui/NervePanel.lua
-- Configurable/manual Nerve panel. The Codex defines ELIGIBILITY but not a
-- numeric resolver, so this panel explains eligibility, shows the printed Nerve
-- value & current morale, and offers manual Pass/Fail/Shaken/Rally/Rout plus a
-- plugin hook. On Rout it shows the exact Temperament instruction; it never
-- moves the figure.

CUS = CUS or {}
local Store = CUS.StateStore
local Nerve = CUS.NerveResolver
local NP = {}

NP.guid, NP.player = nil, nil

function NP.open(guid, playerColor)
  local def = Store.getDefinition(guid)
  if not def then if CUS.Logger then CUS.Logger.warn("Nerve: no definition.") end return end
  NP.guid, NP.player = guid, playerColor
  local elig = Nerve.eligibility(def)
  local st = Store.getOrInit(guid).state

  UI.setAttribute("np_name", "text", def.name)
  UI.setAttribute("np_elig", "text", elig.reason)
  UI.setAttribute("np_value", "text", ("Printed Nerve: %s   ·   Morale: %s")
    :format(tostring(def.stats and def.stats.nerve), st.morale or "Steady"))
  UI.setAttribute("np_rout_text", "text", "On Rout -> " .. Nerve.routInstruction(def))

  -- disable action buttons when ineligible (Circle/Spirit/Construct never test)
  local interact = elig.eligible and "True" or "False"
  for _, id in ipairs({ "np_pass", "np_fail", "np_shaken", "np_rout" }) do
    UI.setAttribute(id, "interactable", interact)
  end
  UI.setAttribute("cus_nerve", "visibility", playerColor)
  UI.show("cus_nerve")
end

function NP.close() UI.hide("cus_nerve") end

CUS.NervePanel = NP
