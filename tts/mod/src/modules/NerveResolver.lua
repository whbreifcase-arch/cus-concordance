-- modules/NerveResolver.lua
-- Nerve, morale and the Rout, per B.10 (SIGNED, William 2026-07-24).
--
-- v0.6 MIGRATION. Under v0.5 the numeric test was undefined, so this module
-- deliberately refused to invent one and offered only a plugin hook. v0.6
-- SIGNED the test, so it is implemented here now — and the morale track became
-- three states, replacing the old Steady/Routed pair.
--
--   WHO TESTS   Squares only, and only Creature Type Man or Beast.
--               Circles never test and never break (heroes hold).
--               Spirit and Construct never test (fearless).
--
--   THE SHOCK   A Square tests the moment it suffers a shock:
--                 · it is WOUNDED by an ATTACK (took a hit and lived), or
--                 · a friendly figure within 3" is slain or goes Broken.
--               One test per shock. A PACKET Effect may also force one.
--
--   THE ROLL    Roll 3 dice. Each die >= the figure's Nerve is a success.
--                 0 successes  -> step DOWN   (Steady -> Shaken -> Broken)
--                 1-2          -> hold
--                 3            -> step UP     (rally through it)
--
--   BROKEN      The figure Routs by its Temperament. The mod NEVER auto-moves
--               a routed model — it prints the instruction and the player moves.

CUS = CUS or {}
local C     = CUS.Constants
local Store = CUS.StateStore
local Nerve = {}

-- Optional override injected later: fn(def, state) -> successes.
Nerve.plugin = nil

-- ---------------------------------------------------------------- eligibility
function Nerve.eligibility(def)
  local shape = def and def.base and def.base.shape
  local ctype = def and def.creature_type
  if shape == "Circle" then
    return { eligible = false, reason = "Circle hero — never tests Nerve, never breaks." }
  end
  if C.TESTS_NERVE[ctype] == false then
    return { eligible = false, reason = tostring(ctype) .. " — fearless, never tests Nerve." }
  end
  if C.TESTS_NERVE[ctype] then
    return { eligible = true, reason = ("Square %s — tests Nerve on a shock (Nerve %s)."):format(
             ctype, tostring(def.stats and def.stats.nerve)) }
  end
  return { eligible = false, reason = "No Nerve test applies." }
end

-- ---------------------------------------------------------------- the track
local function idx(m) return C.MORALE_ORDER[m or "Steady"] or 1 end
local function name(i)
  if i < 1 then i = 1 end
  if i > #C.MORALE_STATES then i = #C.MORALE_STATES end
  return C.MORALE_STATES[i]
end

function Nerve.currentMorale(guid)
  local rt = Store.get(guid)
  return (rt and rt.state and rt.state.morale) or "Steady"
end

-- Step a figure along the morale track. `delta` is +1 down (worse), -1 up.
function Nerve.step(guid, delta, why)
  local st = Store.getOrInit(guid).state
  local before = st.morale or "Steady"
  local after  = name(idx(before) + delta)
  if after == before then
    if CUS.Logger then CUS.Logger.log(("Morale unchanged (%s) — %s"):format(before, why or "")) end
    return before, before
  end
  if CUS.Undo then CUS.Undo.pushMiniState(getObjectFromGUID(guid), "morale -> " .. after) end
  st.morale = after
  CUS.pushRuntimeToMini(guid)
  if CUS.Logger then
    CUS.Logger.log(("Morale: %s -> %s%s"):format(before, after, why and ("  (" .. why .. ")") or ""))
  end
  return after, before
end

-- Rally steps a figure UP one state (a leader's ACTION, B.10).
function Nerve.rally(guid) return Nerve.step(guid, -1, "Rally") end

-- Manual override, kept for a table that wants to just set the state.
function Nerve.setMorale(guid, morale)
  local st = Store.getOrInit(guid).state
  if CUS.Undo then CUS.Undo.pushMiniState(getObjectFromGUID(guid), "morale -> " .. morale) end
  st.morale = morale
  CUS.pushRuntimeToMini(guid)
  if CUS.Logger then CUS.Logger.log(("Morale of %s set to %s"):format(guid, morale)) end
end

-- ---------------------------------------------------------------- the test
-- Rolls 3 dice against the figure's Nerve and applies the result.
-- Returns a result table, or nil + reason when the figure does not test.
function Nerve.test(guid, why)
  local def = Store.getDefinition(guid)
  if not def then return nil, "definition unavailable" end

  local el = Nerve.eligibility(def)
  if not el.eligible then return nil, el.reason end

  local target = def.stats and def.stats.nerve
  if not target then return nil, "no Nerve value printed on the card" end

  local rolls, successes = {}, 0
  if Nerve.plugin then
    successes = Nerve.plugin(def, Store.getOrInit(guid).state)
  else
    for i = 1, C.NERVE.dice do
      local d = math.random(1, 6)
      rolls[i] = d
      if d >= target then successes = successes + 1 end
    end
  end

  local delta, verdict
  if successes <= C.NERVE.down_at then
    delta, verdict = 1, "steps DOWN"
  elseif successes >= C.NERVE.up_at then
    delta, verdict = -1, "steps UP"
  else
    delta, verdict = 0, "holds"
  end

  local after, before = Nerve.step(guid, delta, why or "Nerve test")

  if CUS.Logger then
    CUS.Logger.log(("Nerve %s: [%s] vs %d+ -> %d success%s, %s (%s -> %s)"):format(
      def.name, table.concat(rolls, " "), target, successes,
      successes == 1 and "" or "es", verdict, before, after))
  end

  local res = {
    rolls = rolls, target = target, successes = successes,
    verdict = verdict, before = before, after = after,
    broken = (after == "Broken"),
  }
  if res.broken then res.rout = Nerve.routInstruction(def) end
  return res
end

-- ---------------------------------------------------------------- the shock
-- Did something just happen that makes this figure test? Callers pass what
-- occurred; this only reports, so the player still confirms.
--   kind = "wounded"        the figure was Wounded by an ATTACK and lived
--   kind = "friend_fell"    a friendly within 3" was slain or went Broken
function Nerve.isShock(guid, kind)
  local def = Store.getDefinition(guid)
  if not def then return false, "definition unavailable" end
  local el = Nerve.eligibility(def)
  if not el.eligible then return false, el.reason end
  if kind == "wounded" then
    return true, "Wounded by an attack — test Nerve."
  elseif kind == "friend_fell" then
    return true, ("A friendly fell within %d\" — test Nerve."):format(C.NERVE.shock_radius_in)
  end
  return false, "not a shock"
end

-- ---------------------------------------------------------------- the rout
-- On Broken, return the exact Temperament instruction. The player moves it.
function Nerve.routInstruction(def)
  local t = def and def.temperament
  local entry = t and C.TEMPERAMENTS[t]
  if not entry then return "No temperament printed — resolve manually." end
  return ("%s (Rout): %s"):format(t, entry.rout)
end

-- Leaderless behaviour, same table, other column (B.10).
function Nerve.leaderlessInstruction(def)
  local t = def and def.temperament
  local entry = t and C.TEMPERAMENTS[t]
  if not entry then return "No temperament printed — resolve manually." end
  return ("%s (leaderless): %s"):format(t, entry.lone)
end

-- Retired v0.5 entry point.
function Nerve.autoTest(guid) return Nerve.test(guid) end

CUS.NerveResolver = Nerve
