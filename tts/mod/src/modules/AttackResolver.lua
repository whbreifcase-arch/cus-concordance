-- modules/AttackResolver.lua
-- The SIGNED Combat Module attack procedure (Codex VII.a).
--
--   1. Roll Attack Dice (± Environmental Dice)
--   2. Count SUCCESSES — each die >= Hit
--   3. Read the packet's Tiers to that success count:
--        best WOUND result reached (highest-wins, they do NOT sum)
--        + EVERY Effect passed (accumulate)
--   4. ARMOUR rolls one die PER WOUND
--   5. Apply Wounds -> Counter -> Nerve
--
-- The resolver builds a mutable SESSION. Measurable facts auto-populate the
-- modifier ledger with a labelled source. Judgments (LoS/cover/high ground)
-- are added ONLY when the player confirms them. Nothing mutates the defender
-- until apply() is called.

CUS = CUS or {}
local C       = CUS.Constants
local Store   = CUS.StateStore
local Reg     = CUS.PacketRegistry
local Geo     = CUS.Geo
local Armour  = CUS.ArmourResolver
local Schema  = CUS.Schema
local Bus     = CUS.Bus

local Attack = {}
Attack.session = nil   -- one active resolution at a time (player-local flow)

-- ---------- modifier helpers ------------------------------------------------
local function addMod(s, mod) s.modifiers[#s.modifiers+1] = mod end

local function stepHit(threshold, steps)
  -- worse = higher number, better = lower. Clamp to a rollable 2..6 window
  -- (a "6+ one worse" is handled by making it effectively unreachable at 7).
  local t = threshold + steps
  if t < 2 then t = 2 end
  if t > 7 then t = 7 end
  return t
end

-- ---------- build a session -------------------------------------------------
-- opts = { attackerGuid, defenderGuid, packetId, mode="Regular", is_counter=false }
function Attack.begin(opts)
  local atkDef, aReason = Store.getDefinition(opts.attackerGuid)
  local defDef, dReason = Store.getDefinition(opts.defenderGuid)
  if not atkDef then return nil, "attacker: " .. tostring(aReason) end
  if not defDef then return nil, "defender: " .. tostring(dReason) end

  local packet = Reg.attack(opts.packetId)
  if not packet then return nil, "unknown attack packet: " .. tostring(opts.packetId) end

  local aObj = getObjectFromGUID(opts.attackerGuid)
  local dObj = getObjectFromGUID(opts.defenderGuid)
  local aState = Store.getOrInit(opts.attackerGuid).state
  local dState = Store.getOrInit(opts.defenderGuid).state

  local s = {
    attackerGuid = opts.attackerGuid, defenderGuid = opts.defenderGuid,
    atkDef = atkDef, defDef = defDef,
    packet = packet, mode = opts.mode or "Regular",
    is_counter = opts.is_counter or false,
    base_dice = packet.dice, base_hit = packet.hit,
    env_dice = 0,
    modifiers = {},              -- ledger, each { source, dice?, hitStep?, armourStep?, ignoreArmour?, suppressCounter?, effects?, note }
    judgments = {},              -- player-confirmed toggles, e.g. { cover = true }
    reach = false,               -- Reach tag & not touching (suppresses Counter, no lock)
    touching = false,
    result = nil,
  }

  -- ---- measurable auto-detection -----------------------------------------
  if aObj and dObj then
    local touching = Geo.basesTouching(aObj, atkDef, dObj, defDef)
    s.touching = touching
    local hasReach = false
    for _, t in ipairs(packet.tags or {}) do if t == "Reach" then hasReach = true end end
    s.reach = hasReach and not touching

    -- Facing (frozen on enemy turn is enforced by round logic; arc is a fact).
    local axis = dState.forward_axis or C.TUNING.facing_axis
    local arc = Geo.facingArc(aObj, dObj, axis)
    s.facing = arc
    if arc == "Flank" then
      addMod(s, { source = "Flank", dice = C.TUNING.flank_die, note = "+1 die" })
    elseif arc == "Rear" and not s.is_counter then
      addMod(s, { source = "Rear / Backstab", dice = C.TUNING.backstab_die, suppressCounter = true,
                  note = "+2 dice, no Counter" })
    end

    -- Distance (informational; range legality flagged for ranged packets).
    s.distance_in = Geo.toInches(Geo.planarDist(aObj, dObj))
  end

  -- attacker moved this activation (a fact; some packets/modes care).
  s.attacker_moved = aState.moved_this_activation == true

  -- ---- ranged mode modifiers ---------------------------------------------
  local isRanged = (packet.range and packet.range > 0)
  if isRanged then
    if s.mode == "Precision" then
      addMod(s, { source = "Precision Shot", dice = C.TUNING.precision_die, ignoreCover = true,
                  note = "+1 die, ignores Cover, ends turn (requires not moved)" })
    elseif s.mode == "Multi" then
      addMod(s, { source = "Multi-Shot", hitStep = C.TUNING.multishot_hit_step,
                  note = "Hit one step worse (per shot)" })
    end
  end

  -- ---- Mob Rule (Circle defender engaged by 2+): armour one step worse ----
  -- Engagement is descriptive; we only PROPOSE it and let the player confirm.
  if defDef.base and defDef.base.shape == "Circle" then
    s.mob_candidate = true
  end

  -- ---- conditions represented as structured modifiers --------------------
  for _, cond in ipairs(dState.conditions or {}) do
    if type(cond) == "table" and cond.modifiers then
      addMod(s, { source = "Condition: " .. tostring(cond.id), armourStep = cond.modifiers.armourStep,
                  dice = cond.modifiers.defenderDice, note = cond.note or "" })
    end
  end

  Attack.session = s
  Bus.emit("attack:begin", s)
  return s
end

-- Player toggles a judgment (cover, high ground, LoS-clear, etc.).
function Attack.setJudgment(key, value) if Attack.session then Attack.session.judgments[key] = value end end
function Attack.confirmMob(on)
  local s = Attack.session; if not s then return end
  s.mob_confirmed = on and true or false
end

-- ---------- compute final numbers (pure) ------------------------------------
function Attack.compute(s)
  s = s or Attack.session
  local dice = s.base_dice + (s.env_dice or 0)
  local hitStep, armourStep = 0, 0
  local ignoreArmour, suppressCounter = false, false
  local effectsForced = {}

  for _, m in ipairs(s.modifiers) do
    dice       = dice + (m.dice or 0)
    hitStep    = hitStep + (m.hitStep or 0)
    armourStep = armourStep + (m.armourStep or 0)
    if m.ignoreArmour then ignoreArmour = true end
    if m.suppressCounter then suppressCounter = true end
    for _, e in ipairs(m.effects or {}) do effectsForced[#effectsForced+1] = e end
  end

  if s.mob_confirmed then armourStep = armourStep + 1 end
  if dice < 0 then dice = 0 end

  return {
    dice = dice,
    hit = stepHit(s.base_hit, hitStep),
    armourStep = armourStep,
    ignoreArmour = ignoreArmour,
    suppressCounter = suppressCounter,
    effectsForced = effectsForced,
  }
end

-- ---------- read the Tiers --------------------------------------------------
-- best wound (highest-wins, no sum) + every effect passed.
local function readTiers(packet, successes)
  local bestWound, effects = 0, {}
  local reached = {}
  for _, t in ipairs(packet.tiers) do
    if successes >= t.successes then
      reached[#reached+1] = t
      if (t.wounds or 0) > bestWound then bestWound = t.wounds or 0 end
      for _, e in ipairs(t.effects or {}) do effects[#effects+1] = e end
    end
  end
  return bestWound, effects, reached
end

-- ---------- resolve (roll, or accept manual inputs) -------------------------
-- manual = { dice = {...} } OR { successes = N }.  Returns the result table.
function Attack.resolve(manual)
  local s = Attack.session
  if not s then return nil, "no active attack" end
  local comp = Attack.compute(s)

  -- 1–2: roll & count successes (or accept manual entry)
  local rolls, successes = {}, 0
  if manual and manual.successes ~= nil then
    successes = manual.successes
  elseif manual and manual.dice then
    for i, d in ipairs(manual.dice) do
      rolls[i] = { die = d, success = d >= comp.hit }
      if d >= comp.hit then successes = successes + 1 end
    end
  else
    for i = 1, comp.dice do
      local d = math.random(1, 6)
      rolls[i] = { die = d, success = d >= comp.hit }
      if d >= comp.hit then successes = successes + 1 end
    end
  end

  -- 3: Tiers
  local wounds, effects, reached = readTiers(s.packet, successes)
  for _, e in ipairs(comp.effectsForced) do effects[#effects+1] = e end

  -- 4: Armour, one die per wound
  local saveThr, saveWhy = Armour.effectiveSave(s.defDef, { steps = comp.armourStep, ignore = comp.ignoreArmour })
  local armour = Armour.rollSaves(wounds, saveThr)

  -- 5: pending state (NOT applied yet)
  local defState = Store.getOrInit(s.defenderGuid).state
  local result = {
    comp = comp,
    rolls = rolls, successes = successes,
    reachedTiers = reached, wounds = wounds, effects = effects,
    armour = armour, saveThreshold = saveThr, saveWhy = saveWhy,
    unsaved = armour.unsaved,
    pending = {
      wounds_before = defState.current_wounds,
      wounds_after  = math.max(0, defState.current_wounds - armour.unsaved),
    },
    -- Counter legality (evaluated at apply time too, but previewed here):
    counter_possible = s.touching and (not comp.suppressCounter) and (not s.reach) and (not s.is_counter),
  }
  s.result = result
  Bus.emit("attack:resolved", s)
  return result
end

-- ---------- apply (the only place the defender mutates) ---------------------
function Attack.apply()
  local s = Attack.session
  if not s or not s.result then return nil, "nothing to apply" end
  local mini = getObjectFromGUID(s.defenderGuid)
  if CUS.Undo then CUS.Undo.pushMiniState(mini, "attack on " .. tostring(s.defDef.name)) end

  local defRt = Store.getOrInit(s.defenderGuid)
  local before = defRt.state.current_wounds
  defRt.state.current_wounds = s.result.pending.wounds_after

  -- forced/accumulated effects become conditions where structured (Guard/Push/
  -- Knockdown/etc. are surfaced; the player applies displacement honestly).
  if CUS.ConditionManager then
    for _, e in ipairs(s.result.effects) do
      CUS.ConditionManager.noteEffect(s.defenderGuid, e)
    end
  end

  -- attacker spends the ATTACK (one per activation) unless this is a Counter.
  if not s.is_counter then
    local atkRt = Store.getOrInit(s.attackerGuid)
    atkRt.state.attacked_this_activation = true
  end

  CUS.pushRuntimeToMini(s.defenderGuid)
  CUS.pushRuntimeToMini(s.attackerGuid)

  if CUS.Logger then
    CUS.Logger.log(("%s → %s: %d success, %dW, %d unsaved (%d→%d)%s"):format(
      s.atkDef.name, s.defDef.name, s.result.successes, s.result.wounds,
      s.result.unsaved, before, defRt.state.current_wounds,
      (#s.result.effects > 0 and (" · " .. table.concat(s.result.effects, ", ")) or "")),
      { source = s.attackerGuid, target = s.defenderGuid, before = before, after = defRt.state.current_wounds })
  end

  Bus.emit("attack:applied", s)
  local counterPossible = s.result.counter_possible
  return { applied = true, counter_possible = counterPossible }
end

function Attack.cancel()
  Attack.session = nil
  Bus.emit("attack:cancel", nil)
end

CUS.AttackResolver = Attack
