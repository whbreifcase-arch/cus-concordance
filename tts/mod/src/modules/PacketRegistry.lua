-- modules/PacketRegistry.lua
-- The Global packet registry. Cards store packet IDs; they never copy packet
-- bodies. Change a packet here and every card that references it updates.
-- Packets are STATELESS (Law 5): they never hold a figure's wounds/AP.

CUS = CUS or {}
local Schema = CUS.Schema
local Registry = { attacks = {}, abilities = {} }

-- Load from a decoded JSON blob: { attack_packets = {...}, ability_packets = {...} }
function Registry.load(blob)
  Registry.attacks, Registry.abilities = {}, {}
  if type(blob) ~= "table" then return end

  for _, p in ipairs(blob.attack_packets or {}) do
    local ok, errs = Schema.validateAttackPacket(p)
    if ok then
      Registry.attacks[p.id] = p
    elseif CUS.Logger then
      CUS.Logger.warn("skipped attack packet " .. tostring(p and p.id) .. ": " .. table.concat(errs, "; "),
                      { broadcast = false })
    end
  end

  for _, p in ipairs(blob.ability_packets or {}) do
    local ok, errs = Schema.validateAbilityPacket(p)
    if ok then
      Registry.abilities[p.id] = p
    elseif CUS.Logger then
      CUS.Logger.warn("skipped ability packet " .. tostring(p and p.id) .. ": " .. table.concat(errs, "; "),
                      { broadcast = false })
    end
  end

  if CUS.Logger then
    CUS.Logger.log(("Packet registry loaded: %d attacks, %d abilities.")
      :format(Registry.count(Registry.attacks), Registry.count(Registry.abilities)),
      { broadcast = false })
  end
end

function Registry.count(t)
  local n = 0
  for _ in pairs(t) do n = n + 1 end
  return n
end

function Registry.attack(id)  return Registry.attacks[id]  end
function Registry.ability(id) return Registry.abilities[id] end

-- Resolve a definition's attack packets to full bodies (skips unknown IDs, warns).
function Registry.resolveAttacks(def)
  local out = {}
  for _, id in ipairs(def.attack_packet_ids or {}) do
    local p = Registry.attacks[id]
    if p then out[#out+1] = p
    elseif CUS.Logger then CUS.Logger.warn("unknown attack packet id: " .. tostring(id), { broadcast = false }) end
  end
  return out
end

-- Resolve ability packets, optionally filtered by kind and/or parent action.
function Registry.resolveAbilities(def, kind, parentAction)
  local out = {}
  for _, id in ipairs(def.ability_packet_ids or {}) do
    local p = Registry.abilities[id]
    if p then
      local kindOk   = (kind == nil) or (p.type == kind)
      local parentOk = (parentAction == nil) or (p.parent_action == parentAction)
      if kindOk and parentOk then out[#out+1] = p end
    elseif CUS.Logger then
      CUS.Logger.warn("unknown ability packet id: " .. tostring(id), { broadcast = false })
    end
  end
  return out
end

function Registry.serialize()
  return { attacks = Registry.attacks, abilities = Registry.abilities }
end

function Registry.restore(blob)
  if type(blob) ~= "table" then return end
  Registry.attacks   = blob.attacks   or {}
  Registry.abilities = blob.abilities or {}
end

CUS.PacketRegistry = Registry
