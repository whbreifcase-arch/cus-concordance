-- core/StateStore.lua
-- The single owner of miniature RUNTIME state, keyed by miniature GUID.
--
-- Design: TTS object scripts survive save/load via onSave/onLoad, but keeping a
-- mirror in Global makes cross-object logic (resolvers, panels) simple and makes
-- one place responsible for serialization. Each miniature's authoritative copy
-- still lives on the miniature (MiniatureController) and is synced here on load.
--
-- CARD access lives here too: given a miniature, resolve its linked card and
-- pull the DEFINITION by calling the card's own getDefinition(). We never cache
-- a second permanent stat block on the miniature.

CUS = CUS or {}
local Schema = CUS.Schema
local StateStore = { runtime = {} }   -- guid -> runtimeState

-- ---------------------------------------------------------------------------
-- runtime state registry
-- ---------------------------------------------------------------------------
function StateStore.get(guid)
  return StateStore.runtime[guid]
end

function StateStore.getOrInit(guid)
  if not StateStore.runtime[guid] then
    StateStore.runtime[guid] = Schema.defaultRuntimeState()
  end
  return StateStore.runtime[guid]
end

function StateStore.set(guid, rs)
  StateStore.runtime[guid] = rs
end

function StateStore.remove(guid)
  StateStore.runtime[guid] = nil
end

-- ---------------------------------------------------------------------------
-- card / definition resolution  (the definition→instance bridge)
-- ---------------------------------------------------------------------------

-- Resolve the physical card object linked to a miniature. Returns (cardObj|nil, reason).
function StateStore.resolveCard(miniGuid)
  local rs = StateStore.get(miniGuid)
  if not rs or not rs.card_guid then return nil, "no card linked" end
  local card = getObjectFromGUID(rs.card_guid)
  if not card then return nil, "linked card GUID missing (deleted or in a deck)" end
  return card, nil
end

-- Pull the DEFINITION for a miniature. Validates definition_id against the
-- expected id and never substitutes guessed values on failure.
-- Returns (definition|nil, reason).
function StateStore.getDefinition(miniGuid)
  local card, reason = StateStore.resolveCard(miniGuid)
  if not card then return nil, reason end

  -- The card exposes getDefinition() as a callable object method.
  local ok, def = pcall(function() return card.call("getDefinition") end)
  if not ok or type(def) ~= "table" then
    return nil, "linked card returned no valid definition (malformed or stacked in a deck)"
  end

  local valid, errs = Schema.validateDefinition(def)
  if not valid then
    return nil, "card definition invalid: " .. table.concat(errs, "; ")
  end

  local rs = StateStore.get(miniGuid)
  if rs and rs.expected_definition_id and def.definition_id ~= rs.expected_definition_id then
    -- Identity mismatch is a warning, not a silent swap.
    if CUS.Logger then
      CUS.Logger.warn(("Definition id mismatch on %s: expected %s, card is %s"):format(
        miniGuid, tostring(rs.expected_definition_id), tostring(def.definition_id)))
    end
  end
  return def, nil
end

-- ---------------------------------------------------------------------------
-- serialization (Global-side mirror; object scripts also self-persist)
-- ---------------------------------------------------------------------------
function StateStore.serialize()
  return { runtime = StateStore.runtime }
end

function StateStore.restore(blob)
  StateStore.runtime = {}
  if blob and type(blob.runtime) == "table" then
    for guid, rs in pairs(blob.runtime) do
      StateStore.runtime[guid] = Schema.migrateRuntimeState(rs)
    end
  end
end

-- Duplicate-GUID / broken-link audit used by RoundManager & save/load.
function StateStore.audit()
  local problems = {}
  for guid, rs in pairs(StateStore.runtime) do
    local mini = getObjectFromGUID(guid)
    if not mini then
      problems[#problems+1] = "orphan runtime state for missing miniature " .. guid
    elseif rs.card_guid and not getObjectFromGUID(rs.card_guid) then
      problems[#problems+1] = ("miniature %s links missing card %s"):format(guid, rs.card_guid)
    end
  end
  return problems
end

CUS.StateStore = StateStore
