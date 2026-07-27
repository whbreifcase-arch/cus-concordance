-- modules/CounterResolver.lua
-- Counter — turn and face (B.9, SIGNED, William 2026-07-24).
--
-- Attack a figure and it Counters: one melee PACKET back, AND it turns to face
-- you — you are now engaged. Structurally a Counter is a PACKET armed against
-- the trigger "struck by an enemy", so it lives in the WAIT family even though
-- it fires automatically.
--
-- v0.6 MIGRATION — three things changed, and they matter:
--
--   1. THERE IS NO CAP. v0.5 gave one Counter per round with a `Counter X`
--      economy for duelists. That is gone. A figure Counters EVERY enemy that
--      attacks it, and Counters EVEN AS IT DIES. Worked example: you attack a
--      figure, engage, it Counters and kills you, your body is shoved off —
--      that same figure is now free and will Counter the next attacker.
--
--   2. A FREE TARGET ALWAYS SWINGS. You cannot walk up and safely stab an
--      unengaged figure. It turns, hits back, and is pulled into engagement.
--      The first attacker on an open figure eats the Counter.
--
--   3. ANGLE ONLY DENIES A BUSY SQUARE. v0.5 denied a Counter on any
--      rear/backstab. v0.6 denies it only when the defender is a SQUARE that is
--      ALREADY ENGAGED WITH ANOTHER ENEMY and is struck in an arc it is not
--      facing. A Circle is FACELESS and therefore always Counters, from any
--      angle — heroes are cracked by numbers, not by angles.
--
-- The only other denial is a Reach strike made WITHOUT base contact: the reach
-- striker is not glued to its target, so it is not engaged and draws nothing.
--
-- A Counter does not itself draw a Counter — it is a response, not an ATTACK —
-- so two figures never loop forever. That is enforced by is_counter = true.

CUS = CUS or {}
local C      = CUS.Constants
local Store  = CUS.StateStore
local Reg    = CUS.PacketRegistry
local Attack = CUS.AttackResolver
local Counter = {}

-- Is a Counter legal for `defenderGuid` against `attackerGuid` right now?
--
-- ctx fields:
--   touching        bases are in contact
--   reach           the attacker struck from a Reach band without contact
--   angle           "front" | "flank" | "rear"   (relative to the defender)
--   engagedElsewhere the defender is already engaged with a DIFFERENT enemy
--   suppressCounter a packet effect explicitly suppresses it
--   isCounter       this strike is itself a Counter
function Counter.isLegal(defenderGuid, attackerGuid, ctx)
  ctx = ctx or {}
  local rt = Store.get(defenderGuid)
  if not rt then return false, "no state" end

  -- A Counter is a response, not an ATTACK: it draws no Counter of its own.
  if ctx.isCounter then return false, "a Counter draws no Counter" end
  if ctx.suppressCounter then return false, "suppressed by a packet effect" end

  -- A dead defender still swings — the dying swing lands. So being at zero
  -- wounds is deliberately NOT checked here.

  -- Reach without contact: the striker is not glued, so no engagement, no Counter.
  if ctx.reach and not ctx.touching then
    return false, "struck from Reach without contact — not engaged"
  end

  if not ctx.touching then return false, "bases not touching" end

  local def = Store.getDefinition(defenderGuid)
  local shape = def and def.base and def.base.shape

  -- Circles are faceless. Angle never matters to or from a Circle.
  if shape == "Circle" then
    return true, "Circle is faceless — it always Counters"
  end

  -- A Square that is NOT already engaged elsewhere is a free target: it turns
  -- to face its attacker and swings. This is the common case.
  if not ctx.engagedElsewhere then
    return true, "free target — it turns to face and Counters"
  end

  -- A Square already facing another foe concedes the arc it cannot see.
  local angle = ctx.angle or "front"
  if angle == "flank" or angle == "rear" then
    return false, ("already engaged elsewhere and struck in its %s — no Counter"):format(angle)
  end

  return true, "engaged and struck in its front — it Counters"
end

-- Resolve a Counter: the defender becomes the attacker for one melee packet.
-- counterPacketId defaults to the defender's first melee attack packet.
function Counter.resolve(defenderGuid, attackerGuid, counterPacketId)
  local defDef = Store.getDefinition(defenderGuid)
  if not defDef then return nil, "defender definition unavailable" end

  if not counterPacketId then
    for _, id in ipairs(defDef.attack_packet_ids or {}) do
      local p = Reg.attack(id)
      if p and (not p.range or p.range == 0) then counterPacketId = id; break end
    end
  end
  if not counterPacketId then return nil, "defender has no melee packet to Counter with" end

  -- No cap to spend (B.9). The old counter_uses_remaining bookkeeping is gone;
  -- the only limit on a figure's Counters is that it eventually dies.

  -- Turn and face: engaging turns Squares to face each other. Circles are
  -- faceless and are left alone.
  local shape = defDef.base and defDef.base.shape
  if shape ~= "Circle" and CUS.Geometry and CUS.Geometry.faceToward then
    CUS.Geometry.faceToward(defenderGuid, attackerGuid)
  end

  -- swap roles, is_counter = true so it never recurses
  local s, reason = Attack.begin({
    attackerGuid = defenderGuid,
    defenderGuid = attackerGuid,
    packetId     = counterPacketId,
    is_counter   = true,
  })
  if not s then return nil, reason end

  if CUS.Logger then
    local st = Store.get(defenderGuid)
    local dying = st and st.state and st.state.wounds_state == "Dead"
    CUS.Logger.log(("Counter! %s turns and swings back%s."):format(
      defDef.name, dying and " — the dying swing lands" or ""))
  end
  return s
end

CUS.CounterResolver = Counter
