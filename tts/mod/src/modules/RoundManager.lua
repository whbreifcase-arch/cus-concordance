-- modules/RoundManager.lua
-- Compact round/activation assistance — NOT an initiative director. It marks
-- activation, restores AP, resets flags, and manages round-limited Counter
-- state. It never imposes an activation order the Codex doesn't define.
--
-- New Round: restore AP · clear activations · reset Counter uses · clear
-- moved/attacked flags · PRESERVE wounds/conditions/links · configurable Ready
-- cleanup by packet duration.

CUS = CUS or {}
local C     = CUS.Constants
local Store = CUS.StateStore
local Nerve = CUS.NerveResolver
local Round = { round = 1 }

-- expose the current round to the Logger
if CUS.Logger then CUS.Logger.roundProvider = function() return Round.round end end

-- Start a figure's own activation: facing may update, activation-local flags reset.
function Round.beginActivation(guid)
  local st = Store.getOrInit(guid).state
  st.activated = true
  st.facing_locked = false                  -- facing updates on your OWN turn
  st.moved_this_activation = false
  st.attacked_this_activation = false
  CUS.pushRuntimeToMini(guid)
  if CUS.Logger then CUS.Logger.log(("Activation started (%s)."):format(guid), { broadcast = false }) end
end

function Round.endActivation(guid)
  local st = Store.getOrInit(guid).state
  st.activated = true                       -- stays marked activated for the round
  st.facing_locked = true                   -- facing frozen during others' turns
  CUS.pushRuntimeToMini(guid)
end

-- Advance to a new round across ALL known miniatures.
function Round.newRound(opts)
  opts = opts or {}
  Round.round = Round.round + 1
  local touched = 0
  for guid, rt in pairs(Store.runtime) do
    local def = Store.getDefinition(guid)     -- may be nil if link broken; that's fine
    local st = rt.state
    -- restore AP to the card maximum (facts stored; max comes from the definition)
    if def and def.stats and def.stats.max_ap then st.current_ap = def.stats.max_ap end
    st.activated = false
    st.moved_this_activation = false
    st.attacked_this_activation = false
    st.reaction_spent = false
    -- Nothing to reset for Counters. B.9 (SIGNED): no per-round cap, no
    -- counter_x economy — a figure Counters every enemy that attacks it, every
    -- round, and even as it dies. Only death stops it.
    -- configurable Ready cleanup: drop reactions that expire at round end
    if opts.clear_ready ~= false then
      if st.ready_packet_id == "FORMATION_READY" then
        -- formation READY persists until the member's own activation; leave it
      else
        st.ready_packet_id = nil
      end
    end
    -- PRESERVE wounds, conditions, morale, card links (do nothing to them)
    CUS.pushRuntimeToMini(guid)
    touched = touched + 1
  end
  if CUS.Logger then CUS.Logger.log(("── New Round %d ── (%d figures refreshed; wounds & links preserved)")
    :format(Round.round, touched)) end
  if CUS.Bus then CUS.Bus.emit("round:new", { round = Round.round }) end
end

function Round.serialize() return { round = Round.round } end
function Round.restore(blob) if blob and blob.round then Round.round = blob.round end end

CUS.RoundManager = Round
