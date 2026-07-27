--[[
CUS MINIATURE TRACKER v6.1  —  aligned to CUS v0.6 canon
Standalone Tabletop Simulator Object script.

HUD layout (William's spec):

    [yellow]  [blue]   [heart]   [triangle]
    REACTION    AP      WOUNDS   ACTIVATION
      ●         ●        ♥ 2        △
      ●         ●
      ○         ●
                                  MOVE ATK WAIT ↻

  * Yellow column — REACTION, full circles. Spent on someone else's turn.
  * Blue column   — AP / Agency, full circles. Spent on your own turn.
  * Heart         — one heart, with the remaining Wounds written on it.
  * Triangle      — △ unactivated · ▲ waiting · ▽ activated.

Paste a unit definition as JSON into this miniature's GM Notes, then paste this
script into the miniature's Object Lua script and press Save & Play.

This version uses a more visual tracker:
  * Wounds shown as floating hearts above the miniature
  * Armour shown as a small shield badge if present
  * AP shown as pips instead of the text label "AP"
  * Nerve shown as a small state badge/icon
  * Activation shown as a small state badge/icon
  * Optional live movement ruler with committed zig-zag waypoints
  * Optional base-edge AURA circle in any decimal inch radius

Controls:
  * Hearts badge: left-click lose 1 wound, right-click heal 1
  * AP badge: left-click spend 1 AP, right-click restore 1 AP
  * Nerve badge: left-click worsen, right-click improve
  * Turn badge: left-click Unactivated -> Waiting -> Activated, right-click reverse
  * Movement badge: open ruler; START, move, + WP, continue, then DONE
  * Aura control: type a radius such as 1, 2, 3 or 1.4 inches
--]]

local VERSION = "6.1"

local definition = {}
local runtime = {}
local definitionValid = false
local definitionError = nil

local DEFAULTS = {
    schema = "—",
    name = "CUS Figure",
    faction = "—",
    role = "—",
    tempo = "—",
    tool = "—",
    creature = "—",
    archetype = "—",
    dice = "—",
    hit = "—",
    wounds = 1,
    armour = "—",
    speed = "—",
    ap = 2,
    -- v6: Reaction is a Kernel Resource in its own right (A·IV). It is spent on
    -- SOMEONE ELSE'S activation and is never paid out of AP. Combat budget is
    -- 1 per figure, 2 for a Circle (B·12), refreshed on the figure's own
    -- activation. Every triggered PACKET costs 1 — Counter, Shield Intercept,
    -- Reach strike, a firing Overwatch.
    reactions = 1,
    nerve = "—",
    weapon = "—",
    grades = "—",
    note = "",
    base = "—",
    temper = "—",
    points = "—",
    traits = {},
    packets = {},
    abilities = {},
    tags = {},
}

local HEX = {
    white = "F2F4F8",
    muted = "9AA6B2",
    dark = "171A20",
    green = "65D46E",
    amber = "F4B942",
    red = "EF5B5B",
    blue = "55A7FF",
    cyan = "58D6D6",
    purple = "B784FF",
    orange = "F28C45",
    grey = "747D89",
    gold = "E8C35A",
    pink = "FF6B81",
}

local ROLE_COLORS = {
    pressure = "F28C45",
    anchor = "55A7FF",
    utility = "B784FF",
    assault = "F28C45",
    skirmisher = "E8C35A",
    control = "B784FF",
    support = "65D46E",
}

local TOOL_COLORS = {
    melee = "F28C45",
    ranged = "55A7FF",
    utility = "B784FF",
}

-- CUS v0.6 (B · 10, SIGNED): the morale track is Steady → Shaken → Broken.
-- "Routed" was the v0.5 name for the third state and is what a Broken figure
-- DOES, not a state it is in. Migrated on load. (Table-driven per William's
-- version — it also catches "Breaking".)
local NERVE_STATES = {"Steady", "Shaken", "Broken"}
local NERVE_MIGRATE = {Routed = "Broken", Breaking = "Broken"}
local TURN_STATES = {"Unactivated", "Waiting", "Activated"}
local UI_SCALES = {0.45, 0.58, 0.72, 0.88}
local OVERLAY_STEP = 10
local COLOR_PRESETS = {
    red = "EF5B5B",
    orange = "F28C45",
    gold = "E8C35A",
    green = "65D46E",
    cyan = "58D6D6",
    blue = "55A7FF",
    purple = "B784FF",
    white = "F2F4F8",
}

-- Optional custom token art. Leave a URL empty to use the built-in placeholder.
-- Once your PNGs are uploaded to Steam Cloud or another direct HTTPS host,
-- paste their URLs here. SVG source art should be exported to transparent PNGs.
local ICON_ASSETS = {
    heart_full = "",
    heart_empty = "",
    armour_light = "",
    armour_medium = "",
    armour_heavy = "",
    activation_unactivated = "",
    activation_activated = "",
    activation_ready = "",
    nerve_fine = "",
    nerve_shaken = "",
    nerve_breaking = "",
}

local function assetEnabled(name)
    return type(ICON_ASSETS[name]) == "string" and ICON_ASSETS[name] ~= ""
end

local function installCustomAssets()
    local bundle = {}
    for name, url in pairs(ICON_ASSETS) do
        if type(url) == "string" and url ~= "" then
            table.insert(bundle, {name = name, url = url})
        end
    end
    if #bundle > 0 then
        pcall(function() self.UI.setCustomAssets(bundle) end)
    end
end

local MOVE_SAMPLE_FRAMES = 3
local MOVE_LINE_THICKNESS = 0.085
local MOVE_WAYPOINT_SIZE = 0.13
local MOVE_MIN_SEGMENT = 0.03
local movementFrameCounter = 0

local AURA_LINE_THICKNESS = 0.065
local AURA_SEGMENTS = 96
local AURA_MAX_RADIUS = 99
local MM_TO_INCH = 1 / 25.4

local function isWhitespaceByte(byte)
    return byte == 9 or byte == 10 or byte == 11 or byte == 12 or byte == 13 or byte == 32
end

-- Avoid Lua pattern matching here. TTS can throw "pattern too complex" when a
-- long JSON/description string is passed through the usual ^%s*(.-)%s*$ trim.
local function trim(value)
    if value == nil then return "" end
    local text = tostring(value)
    local firstIndex = 1
    local lastIndex = #text

    while firstIndex <= lastIndex and isWhitespaceByte(string.byte(text, firstIndex)) do
        firstIndex = firstIndex + 1
    end
    while lastIndex >= firstIndex and isWhitespaceByte(string.byte(text, lastIndex)) do
        lastIndex = lastIndex - 1
    end

    if firstIndex > lastIndex then return "" end
    if firstIndex == 1 and lastIndex == #text then return text end
    return text:sub(firstIndex, lastIndex)
end

local function lower(value)
    return string.lower(trim(value))
end

local function first(...)
    local values = {...}
    for _, value in ipairs(values) do
        if value ~= nil and value ~= "" then
            return value
        end
    end
    return nil
end

local function asNumber(value, fallback)
    if type(value) == "number" then return value end
    if type(value) == "string" then
        local parsed = tonumber(value:match("%-?%d+%.?%d*"))
        if parsed ~= nil then return parsed end
    end
    return fallback
end

local function clamp(value, minimum, maximum)
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function copyTable(source)
    local result = {}
    if type(source) ~= "table" then return result end
    for key, value in pairs(source) do
        if type(value) == "table" then
            result[key] = copyTable(value)
        else
            result[key] = value
        end
    end
    return result
end

local function mergeDefaults(source)
    local result = copyTable(DEFAULTS)
    if type(source) == "table" then
        for key, value in pairs(source) do
            result[key] = value
        end
    end
    return result
end

local function xmlEscape(value)
    local text = tostring(value or "")
    text = text:gsub("&", "&amp;")
    text = text:gsub("<", "&lt;")
    text = text:gsub(">", "&gt;")
    text = text:gsub('"', "&quot;")
    text = text:gsub("'", "&apos;")
    -- v6.1 BUGFIX: escaping runs "&" -> "&amp;" FIRST, so a tooltip written
    -- with a literal "&#10;" came out as "&amp;#10;" and rendered as visible
    -- garbage. Write tooltips with real "\n" and convert here, after escaping.
    text = text:gsub("\r\n", "\n")
    text = text:gsub("\r", "\n")
    text = text:gsub("\n", "&#10;")
    return text
end

local function bbEscape(value)
    local text = tostring(value or "")
    text = text:gsub("%[", "(")
    text = text:gsub("%]", ")")
    return text
end

local function bb(color, text, bold)
    local open = "[" .. color .. "]"
    if bold then open = open .. "[b]" end
    local close = bold and "[/b][-]" or "[-]"
    return open .. bbEscape(text) .. close
end

local function bbSmallItalic(color, text)
    return "[" .. color .. "][i]" .. bbEscape(text) .. "[/i][-]"
end

local function notify(playerOrColor, message, color)
    local playerColor = nil
    if type(playerOrColor) == "string" then
        playerColor = playerOrColor
    elseif playerOrColor ~= nil and playerOrColor.color ~= nil then
        playerColor = playerOrColor.color
    end

    local tint = color or {0.85, 0.90, 1.00}
    if playerColor ~= nil and Player[playerColor] ~= nil then
        Player[playerColor].broadcast(message, tint)
    else
        broadcastToAll(message, tint)
    end
end

local function roman(number)
    local n = tonumber(number)
    if n == nil then return tostring(number or "—") end
    local numerals = {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"}
    return numerals[n] or tostring(n)
end

local function threshold(value)
    if value == nil or value == "" then return "—" end
    if type(value) == "number" then return tostring(value) .. "+" end
    local text = trim(value)
    if text == "-" or text == "—" or text == "none" or text == "None" then
        return "—"
    end
    if text:find("+", 1, true) then return text end
    if tonumber(text) ~= nil then return text .. "+" end
    return text
end

local function joinSimple(value, separator)
    separator = separator or " · "
    if value == nil then return "" end
    if type(value) ~= "table" then return tostring(value) end

    local items = {}
    for _, item in ipairs(value) do
        if type(item) == "table" then
            local label = first(item.name, item.alias, item.id, item.label)
            if label ~= nil then table.insert(items, tostring(label)) end
        else
            table.insert(items, tostring(item))
        end
    end
    return table.concat(items, separator)
end

local function formatTiers(value)
    if value == nil then return "—" end
    if type(value) ~= "table" then return tostring(value) end

    local parts = {}
    for _, tier in ipairs(value) do
        if type(tier) == "table" then
            local successes = first(tier.successes, tier.success, tier.at, tier.threshold, "?")
            local resultParts = {}
            local wounds = first(tier.wounds, tier.wound, tier.damage)
            if wounds ~= nil then table.insert(resultParts, tostring(wounds) .. "W") end
            local effects = first(tier.effects, tier.effect, tier.riders)
            if type(effects) == "table" then
                for _, effect in ipairs(effects) do
                    if type(effect) == "table" then
                        table.insert(resultParts, tostring(first(effect.name, effect.id, effect.label, "Effect")))
                    else
                        table.insert(resultParts, tostring(effect))
                    end
                end
            elseif effects ~= nil and effects ~= "" then
                table.insert(resultParts, tostring(effects))
            end
            if #resultParts == 0 then
                local result = first(tier.result, tier.outcome, tier.text)
                if result ~= nil then table.insert(resultParts, tostring(result)) end
            end
            table.insert(parts, tostring(successes) .. "→" .. table.concat(resultParts, "+"))
        else
            table.insert(parts, tostring(tier))
        end
    end

    if #parts == 0 then return "—" end
    return table.concat(parts, " · ")
end

local function formatBase(value)
    if value == nil then return "—" end
    if type(value) ~= "table" then return tostring(value) end

    local shape = first(value.shape, value.type)
    local class = first(value.class, value.size)
    local mounted = value.mounted == true and "Mounted" or nil
    local parts = {}
    if shape ~= nil then table.insert(parts, tostring(shape)) end
    if class ~= nil then table.insert(parts, tostring(class)) end
    if mounted ~= nil then table.insert(parts, mounted) end
    if #parts == 0 then return "—" end
    return table.concat(parts, " / ")
end

local function stripCodeFence(raw)
    local text = trim(raw)
    if text:sub(1, 3) ~= "```" then return text end

    -- Drop the opening fence/language line without regex backtracking.
    local newline = text:find("\n", 1, true)
    if newline ~= nil then
        text = text:sub(newline + 1)
    else
        text = text:sub(4)
    end

    text = trim(text)
    if text:sub(-3) == "```" then
        text = text:sub(1, #text - 3)
    end
    return trim(text)
end

-- Extract the first complete JSON object from a field. This lets the tracker
-- recover definitions even when TTS or another mod has surrounded the JSON
-- with tooltip text. It respects braces inside quoted JSON strings.
local function extractJsonObject(raw)
    local text = stripCodeFence(raw)
    if text == "" then return nil end

    local startIndex = text:find("{", 1, true)
    if startIndex == nil then return nil end

    local depth = 0
    local inString = false
    local escaped = false

    for index = startIndex, #text do
        local char = text:sub(index, index)
        if inString then
            if escaped then
                escaped = false
            elseif char == "\\" then
                escaped = true
            elseif char == '"' then
                inString = false
            end
        else
            if char == '"' then
                inString = true
            elseif char == "{" then
                depth = depth + 1
            elseif char == "}" then
                depth = depth - 1
                if depth == 0 then
                    return text:sub(startIndex, index)
                end
            end
        end
    end

    return nil
end

local function safeDecode(raw)
    local text = extractJsonObject(raw) or stripCodeFence(raw)
    if text == "" then return nil, "No JSON text was provided." end
    local ok, decoded = pcall(JSON.decode, text)
    if not ok or type(decoded) ~= "table" then
        return nil, "The unit definition is not valid JSON."
    end
    return decoded, nil
end

local function readDefinitionSource()
    local candidates = {
        {label = "GM Notes", value = self.getGMNotes and self.getGMNotes() or ""},
        {label = "Object memo", value = type(self.memo) == "string" and self.memo or ""},
        {label = "saved definition", value = type(runtime.definition_json) == "string" and runtime.definition_json or ""},
        {label = "Description", value = self.getDescription and self.getDescription() or ""},
    }

    for _, candidate in ipairs(candidates) do
        local jsonText = extractJsonObject(candidate.value)
        if jsonText ~= nil then
            local ok, decoded = pcall(JSON.decode, jsonText)
            if ok and type(decoded) == "table" then
                return jsonText, candidate.label
            end
        end
    end

    return nil, nil
end

local function normalizeArmour(value)
    if value == nil then return "—" end
    local text = trim(value)
    local key = lower(text)
    local classes = {
        none = "—",
        light = "6+",
        medium = "5+",
        heavy = "4+",
    }
    if classes[key] ~= nil then return classes[key] end
    return threshold(value)
end

local function replacePlain(text, search, replacement)
    if text == nil then return nil end
    local value = tostring(text)
    local output = {}
    local cursor = 1
    while true do
        local found = value:find(search, cursor, true)
        if found == nil then
            table.insert(output, value:sub(cursor))
            break
        end
        table.insert(output, value:sub(cursor, found - 1))
        table.insert(output, replacement)
        cursor = found + #search
    end
    return table.concat(output)
end

local function cleanDisplayText(value)
    if value == nil then return nil end
    local text = tostring(value)
    text = replacePlain(text, "Â·", "·")
    text = replacePlain(text, "->", "→")
    return text
end

local function normalizeTraits(value)
    local result = {}
    if type(value) ~= "table" then return result end
    for _, trait in ipairs(value) do
        if type(trait) == "table" then
            table.insert(result, {
                trait_id = first(trait.trait_id, trait.id, trait.name),
                name = first(trait.name, trait.trait_id, trait.id, "Trait"),
                note = cleanDisplayText(first(trait.note, trait.description, trait.text, "")),
            })
        elseif trait ~= nil then
            table.insert(result, {trait_id = tostring(trait), name = tostring(trait), note = ""})
        end
    end
    return result
end

local function formatPacketGrades(grades)
    if type(grades) ~= "table" or #grades == 0 then return "—" end
    local parts = {}
    for _, grade in ipairs(grades) do
        if type(grade) == "table" then
            local successes = first(grade.successes, grade.success, grade.grade, "?")
            local effects = grade.effects
            local effectText = "—"
            if type(effects) == "table" then
                local cleaned = {}
                for _, effect in ipairs(effects) do
                    table.insert(cleaned, cleanDisplayText(effect))
                end
                effectText = table.concat(cleaned, " + ")
            elseif effects ~= nil then
                effectText = cleanDisplayText(effects)
            end
            table.insert(parts, tostring(successes) .. "S→" .. tostring(effectText))
        end
    end
    if #parts == 0 then return "—" end
    return table.concat(parts, " · ")
end

local function normalizePackets(value)
    local result = {}
    if type(value) ~= "table" then return result end
    for _, packet in ipairs(value) do
        if type(packet) == "table" then
            table.insert(result, {
                packet_id = first(packet.packet_id, packet.id, packet.name),
                name = first(packet.name, packet.packet_id, packet.id, "Packet"),
                verb = first(packet.verb, "ACTION"),
                dice = asNumber(packet.dice, 0),
                success = asNumber(first(packet.success, packet.hit), 0),
                range = asNumber(packet.range, 0),
                area = cleanDisplayText(first(packet.area, "")),
                cost_ap = asNumber(first(packet.cost_ap, packet.ap_cost, packet.cost), 0),
                grades = type(packet.grades) == "table" and copyTable(packet.grades) or {},
                grades_text = formatPacketGrades(packet.grades),
            })
        end
    end
    return result
end

local function primaryPacketFrom(packets)
    if type(packets) ~= "table" then return nil end
    for _, packet in ipairs(packets) do
        if asNumber(packet.dice, 0) > 0 then return packet end
    end
    return packets[1]
end

local function packetRangeText(packet)
    if packet == nil then return "—" end
    local range = asNumber(packet.range, 0)
    if range <= 0 then return "Melee" end
    return tostring(range) .. '"'
end

local function packetRollText(packet)
    if packet == nil then return "—" end
    local dice = asNumber(packet.dice, 0)
    local success = asNumber(packet.success, 0)
    if dice <= 0 or success <= 0 then return "No roll" end
    return tostring(dice) .. "D @ " .. tostring(success) .. "+"
end

-- Supports the current cus-0.6-unit schema and keeps legacy Card Forge JSON
-- readable so existing miniatures do not have to be rebuilt at once.
local function normalizeDefinition(decoded)
    local root = decoded.definition or decoded.unit or decoded
    local stats = type(root.stats) == "table" and root.stats or {}
    local display = type(root.display) == "table" and root.display or {}
    local baseObject = type(root.base) == "table" and root.base or {}

    local traits = normalizeTraits(root.traits)
    local packets = normalizePackets(root.packets)
    local primaryPacket = primaryPacketFrom(packets)

    local abilities = {}
    for _, trait in ipairs(traits) do
        table.insert(abilities, tostring(trait.name))
    end
    if root.signature ~= nil and root.signature ~= "" then
        table.insert(abilities, tostring(root.signature))
    end
    if type(root.ability_packet_ids) == "table" then
        for _, packetId in ipairs(root.ability_packet_ids) do
            table.insert(abilities, tostring(packetId))
        end
    end

    local packetWeapon = primaryPacket and primaryPacket.name or nil
    local packetDice = primaryPacket and primaryPacket.dice or nil
    local packetHit = primaryPacket and primaryPacket.success or nil
    local packetGrades = primaryPacket and primaryPacket.grades_text or nil

    local normalized = {
        schema = first(root.schema, root.schema_version, "legacy"),
        schema_version = first(root.schema_version, root.schema, 1),
        id = first(root.definition_id, root.id, root.unit_id),
        name = first(root.name, root.title, self.getName(), DEFAULTS.name),
        faction = first(root.faction, DEFAULTS.faction),
        role = first(root.role, DEFAULTS.role),
        tempo = first(root.tempo, DEFAULTS.tempo),
        tool = first(root.tool, DEFAULTS.tool),
        creature = first(root.creature_type, root.creature, root.type, DEFAULTS.creature),
        archetype = first(root.archetype, root.class, DEFAULTS.archetype),
        signature = first(root.signature, ""),
        points = first(root.points, DEFAULTS.points),

        wounds = asNumber(first(stats.max_wounds, stats.wounds, root.max_wounds, root.wounds), DEFAULTS.wounds),
        ap = asNumber(first(stats.max_ap, stats.ap, root.max_ap, root.ap), DEFAULTS.ap),
        speed = first(stats.speed, root.speed, DEFAULTS.speed),
        -- v6: `rank` was the old name for this stat and is retired — the Nerve
        -- test rolls 3 dice against it (B · 10). Legacy JSON still reads.
        nerve = first(stats.nerve, root.nerve, root.rank, stats.rank, DEFAULTS.nerve),
        armour = normalizeArmour(first(stats.armour, stats.armor, display.armour, display.armor, DEFAULTS.armour)),

        weapon = first(packetWeapon, display.weapon, root.weapon, DEFAULTS.weapon),
        dice = first(packetDice, display.dice, root.dice, DEFAULTS.dice),
        hit = threshold(first(packetHit, display.hit, root.hit, DEFAULTS.hit)),
        grades = cleanDisplayText(first(packetGrades, display.grades, root.grades, display.tiers, root.tiers, DEFAULTS.grades)),
        note = first(display.note, root.note, root.notes, DEFAULTS.note),

        base = formatBase(next(baseObject) ~= nil and baseObject or first(display.base, DEFAULTS.base)),
        base_shape = first(baseObject.shape, baseObject.type),
        base_class = first(baseObject.size, baseObject.class),
        mounted = baseObject.mounted == true,
        forward_axis = first(baseObject.forward_axis, "local_z"),

        temper = first(root.temperament, root.temper, DEFAULTS.temper),
        traits = traits,
        packets = packets,
        abilities = abilities,
        tags = first(root.tags, {}),
        attack_packet_ids = first(root.attack_packet_ids, {}),
        ability_packet_ids = first(root.ability_packet_ids, {}),
        card_image_url = first(display.card_image_url, ""),
    }

    normalized.wounds = math.max(0, math.floor(normalized.wounds or DEFAULTS.wounds))
    normalized.ap = math.max(0, math.floor(normalized.ap or DEFAULTS.ap))

    -- v6: Reaction budget. Explicit value wins; otherwise B · 12 default —
    -- 1 per figure, 2 for a Circle (the Champion answers twice).
    local declaredReactions = asNumber(first(stats.reactions, stats.reaction, root.reactions, root.reaction), nil)
    if declaredReactions == nil then
        local shape = lower(normalized.base_shape or "")
        declaredReactions = (shape == "circle") and 2 or 1
    end
    normalized.reactions = math.max(0, math.floor(declaredReactions))

    return mergeDefaults(normalized)
end

local function stateIndex(states, current)
    for index, value in ipairs(states) do
        if value == current then return index end
    end
    return 1
end

local function stepState(states, current, direction)
    local index = stateIndex(states, current)
    local count = #states
    local nextIndex = ((index - 1 + direction) % count) + 1
    return states[nextIndex]
end

local function synchronizeTurnFlags()
    runtime.activated = runtime.turn_state == "Activated"
    runtime.readied = runtime.turn_state == "Waiting"
end


-- Keep runtime counters synchronized with definition maxima without healing a
-- genuinely damaged/spent figure on every reload. If the figure was full at
-- the old maximum (or this is the first successful sync), it becomes full at
-- the new maximum. Otherwise its current value is preserved and only clamped.
local function synchronizeDefinitionLimits(previousMaxWounds, previousMaxAP, forceFull)
    local newMaxWounds = math.max(0, math.floor(asNumber(definition.wounds, DEFAULTS.wounds)))
    local newMaxAP = math.max(0, math.floor(asNumber(definition.ap, DEFAULTS.ap)))

    local currentWounds = asNumber(runtime.current_wounds, nil)
    if forceFull or currentWounds == nil or previousMaxWounds == nil or currentWounds == previousMaxWounds then
        runtime.current_wounds = newMaxWounds
    else
        runtime.current_wounds = clamp(math.floor(currentWounds), 0, newMaxWounds)
    end

    local currentAP = asNumber(runtime.current_ap, nil)
    if forceFull or currentAP == nil or previousMaxAP == nil or currentAP == previousMaxAP then
        runtime.current_ap = newMaxAP
    else
        runtime.current_ap = clamp(math.floor(currentAP), 0, newMaxAP)
    end

    runtime.synced_max_wounds = newMaxWounds
    runtime.synced_max_ap = newMaxAP
end

local function initializeRuntime()
    runtime.current_wounds = asNumber(runtime.current_wounds, definition.wounds)
    runtime.current_ap = asNumber(runtime.current_ap, definition.ap)
    runtime.nerve_state = first(runtime.nerve_state, "Steady")

    -- v6 migration: the old "Readied" state was the retired READY verb
    -- (Document D · 1 — READY became WAIT). Saved figures carry over.
    if runtime.turn_state == "Readied" then runtime.turn_state = "Waiting" end
    if NERVE_MIGRATE[runtime.nerve_state] ~= nil then
        runtime.nerve_state = NERVE_MIGRATE[runtime.nerve_state]
    end

    if runtime.turn_state ~= "Unactivated" and runtime.turn_state ~= "Waiting" and runtime.turn_state ~= "Activated" then
        if runtime.activated == true then
            runtime.turn_state = "Activated"
        elseif runtime.readied == true then
            runtime.turn_state = "Waiting"
        else
            runtime.turn_state = "Unactivated"
        end
    end
    synchronizeTurnFlags()

    -- v6: Reaction pool. Refreshed on the figure's own activation (B · 12).
    runtime.current_reactions = asNumber(runtime.current_reactions, definition.reactions)
    runtime.current_reactions = clamp(math.floor(runtime.current_reactions), 0, math.max(0, asNumber(definition.reactions, 1)))

    runtime.ui_hidden = runtime.ui_hidden == true
    runtime.ui_rotation = asNumber(runtime.ui_rotation, 0)
    runtime.ui_scale = asNumber(runtime.ui_scale, 0.58)
    runtime.ui_scale = clamp(runtime.ui_scale, 0.35, 1.20)

    -- v1.5: direct XYZ placement replaces the old one-dimensional distance.
    runtime.ui_x = asNumber(runtime.ui_x, 0)
    runtime.ui_y = asNumber(runtime.ui_y, 0)
    if runtime.ui_z == nil then
        runtime.ui_z = -asNumber(runtime.ui_distance, 105)
    else
        runtime.ui_z = asNumber(runtime.ui_z, -105)
    end
    runtime.ui_config_open = runtime.ui_config_open == true
    runtime.library_open = runtime.library_open == true

    -- v3.1 layout migration: keep the permanent display clean and above the
    -- base. Expanded tools remain available through the right-click menu.
    if runtime.overlay_layout_version ~= 31 then
        runtime.ui_config_open = false
        runtime.move_panel_open = false
        if math.abs(asNumber(runtime.ui_y, 0)) < 0.001 then runtime.ui_y = 55 end
        runtime.overlay_layout_version = 31
    end

    runtime.ui_accent = tostring(runtime.ui_accent or HEX.cyan):gsub("#", ""):upper()
    if not runtime.ui_accent:match("^[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]$") then
        runtime.ui_accent = HEX.cyan
    end
    runtime.model_highlight = runtime.model_highlight == true

    -- v2.1 aura ring. The entered value is measured in inches from the
    -- miniature's base edge. The ring uses the same selected accent/glow color.
    runtime.aura_radius = clamp(asNumber(runtime.aura_radius, 0), 0, AURA_MAX_RADIUS)
    if runtime.aura_visible == nil then
        runtime.aura_visible = runtime.aura_radius > 0
    else
        runtime.aura_visible = runtime.aura_visible == true
    end

    -- v1.6 movement ruler state. Points are stored in world coordinates so the
    -- path survives repeated pickups and can form a zig-zag through waypoints.
    runtime.move_panel_open = runtime.move_panel_open == true
    runtime.move_active = runtime.move_active == true
    if type(runtime.move_points) ~= "table" then runtime.move_points = {} end
    if type(runtime.move_endpoint) ~= "table" then runtime.move_endpoint = nil end
    runtime.move_line_y = asNumber(runtime.move_line_y, nil)

    runtime.current_wounds = clamp(math.floor(runtime.current_wounds), 0, definition.wounds)
    runtime.current_ap = clamp(math.floor(runtime.current_ap), 0, definition.ap)

    local validNerve = false
    for _, value in ipairs(NERVE_STATES) do
        if runtime.nerve_state == value then validNerve = true end
    end
    if not validNerve then runtime.nerve_state = "Steady" end
end

local function applyTags()
    self.addTag("CUS")
    self.addTag("CUS_MINIATURE")

    local tagValues = {definition.faction, definition.role, definition.tempo, definition.tool, definition.creature, definition.temper}
    for _, value in ipairs(tagValues) do
        if value ~= nil and value ~= "" and value ~= "—" then
            self.addTag("CUS:" .. tostring(value))
        end
    end

    if type(definition.tags) == "table" then
        for _, value in ipairs(definition.tags) do
            if type(value) == "string" and value ~= "" then
                self.addTag(value)
            end
        end
    end
end

local function loadDefinition(playerOrColor, announce)
    local previousMaxWounds = asNumber(runtime.synced_max_wounds, nil)
    local previousMaxAP = asNumber(runtime.synced_max_ap, nil)

    -- Older saves did not record the synchronized maxima. Only use the live
    -- definition as a fallback when it was previously valid.
    if previousMaxWounds == nil and definitionValid then
        previousMaxWounds = asNumber(definition.wounds, nil)
    end
    if previousMaxAP == nil and definitionValid then
        previousMaxAP = asNumber(definition.ap, nil)
    end

    local raw, source = readDefinitionSource()
    local decoded, err = safeDecode(raw or "")

    if decoded == nil then
        definition = mergeDefaults({name = first(self.getName(), DEFAULTS.name)})
        definitionValid = false
        definitionError = raw == nil
            and "No unit JSON found. Use CUS: Paste / Edit Unit JSON."
            or err
    else
        definition = normalizeDefinition(decoded)
        definitionValid = true
        definitionError = nil

        -- The v2 schema adapter deliberately performs one full synchronization
        -- when first installed or when a different definition_id is loaded. Later
        -- reloads preserve real damage/spent AP unless the maxima themselves clamp it.
        local forceFullSync = runtime.schema_adapter_version ~= 4
            or runtime.loaded_definition_id == nil
            or runtime.loaded_definition_id ~= definition.id
        synchronizeDefinitionLimits(previousMaxWounds, previousMaxAP, forceFullSync)
        runtime.schema_adapter_version = 4
        runtime.loaded_definition_id = definition.id

        -- Keep one hidden, persistent copy so the tracker does not depend on
        -- which TTS text field the user originally pasted into.
        runtime.definition_json = stripCodeFence(raw)
        self.memo = runtime.definition_json

        -- Keep the full JSON out of TTS's visible right-click tooltip. The
        -- authoritative copy remains in script state + object memo and is still
        -- editable through CUS: Unit JSON. A newly pasted GM Notes definition is
        -- imported first, then cleared from the visible field.
        if self.setGMNotes then
            pcall(function() self.setGMNotes("") end)
        end
    end

    initializeRuntime()
    applyTags()

    if announce then
        if definitionValid then
            notify(playerOrColor, "CUS loaded from " .. tostring(source or "saved data") .. ": " .. tostring(definition.name), {0.40, 0.90, 0.55})
        else
            notify(playerOrColor, "CUS JSON warning: " .. tostring(definitionError), {1.00, 0.35, 0.35})
        end
    end
end

local function woundsColor()
    if runtime.current_wounds <= 0 then return HEX.red end
    if definition.wounds > 0 and runtime.current_wounds <= definition.wounds / 2 then return HEX.amber end
    return HEX.red
end

local function nerveColor()
    if runtime.nerve_state == "Broken" then return HEX.red end
    if runtime.nerve_state == "Shaken" then return HEX.amber end
    return HEX.green end

local function turnStateColor()
    if runtime.turn_state == "Activated" then return HEX.grey end
    if runtime.turn_state == "Waiting" then return HEX.purple end
    return HEX.gold
end

local function roleColor() return ROLE_COLORS[lower(definition.role)] or HEX.orange end
local function toolColor() return TOOL_COLORS[lower(definition.tool)] or HEX.blue end

local function renderHearts(current, maximum)
    if maximum <= 0 then return "☠" end
    if maximum <= 6 then
        local out = {}
        for i = 1, maximum do
            if i <= current then table.insert(out, "♥") else table.insert(out, "♡") end
        end
        return table.concat(out, "")
    end
    if current <= 0 then return "☠" end
    return "♥ " .. tostring(current) .. "/" .. tostring(maximum)
end

local function renderAPPips(current, maximum)
    if maximum <= 0 then return "—" end
    local out = {}
    if maximum <= 5 then
        for i = 1, maximum do
            if i <= current then table.insert(out, "●") else table.insert(out, "○") end
        end
        return table.concat(out, "")
    end
    return string.format("%d/%d", current, maximum)
end

local function renderNerveBadge()
    if runtime.nerve_state == "Broken" then return "↯" end
    if runtime.nerve_state == "Shaken" then return "!" end
    return "◉"
end

local function renderTurnBadge()
    if runtime.turn_state == "Activated" then return "✓" end
    if runtime.turn_state == "Waiting" then return "✦" end
    return "◌"
end

local function armorDisplay()
    local a = tostring(definition.armour or "—")
    if trim(a) == "" or a == "—" or a == "-" then return nil end
    return a
end

local function armorStateData()
    local raw = lower(definition.armour or "—")
    if raw == "4+" or raw == "heavy" then
        return {state = "heavy", label = "4+", tooltip = "Heavy Armour (4+)", asset = "armour_heavy", fg = "AFC8E6", glyph = "⬢"}
    elseif raw == "5+" or raw == "medium" then
        return {state = "medium", label = "5+", tooltip = "Medium Armour (5+)", asset = "armour_medium", fg = "7FB6E8", glyph = "⬟"}
    elseif raw == "6+" or raw == "light" then
        return {state = "light", label = "6+", tooltip = "Light Armour (6+)", asset = "armour_light", fg = "A97A4A", glyph = "⬟"}
    end
    return nil
end

local function activationTokenData()
    if runtime.turn_state == "Waiting" then
        return {asset = "activation_ready", glyph = "▲", fg = HEX.purple, tooltip = "Activation: Ready. Left click: next state. Right click: previous state."}
    elseif runtime.turn_state == "Activated" then
        return {asset = "activation_activated", glyph = "▲", fg = "2D7B42", tooltip = "Activation: Activated. Left click: next state. Right click: previous state."}
    end
    return {asset = "activation_unactivated", glyph = "△", fg = HEX.green, tooltip = "Activation: Unactivated. Left click: next state. Right click: previous state."}
end

local function nerveTokenData()
    if runtime.nerve_state == "Broken" then
        return {asset = "nerve_breaking", glyph = "◆", fg = HEX.red, tooltip = "Nerve: Broken. Left click: worsen. Right click: improve."}
    elseif runtime.nerve_state == "Shaken" then
        return {asset = "nerve_shaken", glyph = "◆", fg = HEX.amber, tooltip = "Nerve: Shaken. Left click: worsen. Right click: improve."}
    end
    return {asset = "nerve_fine", glyph = "◇", fg = HEX.gold, tooltip = "Nerve: Fine / Steady. Left click: worsen. Right click: improve."}
end

local function transparentButton(id, tooltip, width, height)
    return [[<Button id="]] .. id .. [[" onClick="cusUiClick" text="" width="]] .. width .. [[" height="]] .. height .. [[" colors="#00000000|#FFFFFF12|#FFFFFF08|#00000000" tooltip="]] .. xmlEscape(tooltip) .. [[" />]]
end

local function buildTokenXml(id, token, width, height)
    if assetEnabled(token.asset) then
        return [[<Panel width="]] .. width .. [[" height="]] .. height .. [[">
            <Image image="]] .. token.asset .. [[" width="]] .. width .. [[" height="]] .. height .. [[" preserveAspect="true" />
            ]] .. transparentButton(id, token.tooltip, width, height) .. [[
        </Panel>]]
    end

    return [[<Panel width="]] .. width .. [[" height="]] .. height .. [[">
        <Text text="]] .. xmlEscape(token.glyph) .. [[" width="]] .. width .. [[" height="]] .. height .. [[" fontSize="28" color="#]] .. token.fg .. [[" alignment="MiddleCenter" />
        ]] .. transparentButton(id, token.tooltip, width, height) .. [[
    </Panel>]]
end

local function buildArmourXml(armor)
    if armor == nil then return "", 0 end
    local width, height = 38, 30
    if assetEnabled(armor.asset) then
        return [[<Panel width="38" height="30">
            <Image image="]] .. armor.asset .. [[" width="34" height="30" preserveAspect="true" />
            <Text text="]] .. xmlEscape(armor.label) .. [[" width="22" height="14" fontSize="10" color="#F2F4F8" alignment="MiddleCenter" offsetXY="0 -1" />
        </Panel>]], width
    end

    return [[<Panel width="38" height="30" tooltip="]] .. xmlEscape(armor.tooltip) .. [[">
        <Text text="]] .. xmlEscape(armor.glyph) .. [[" width="38" height="30" fontSize="27" color="#]] .. armor.fg .. [[" alignment="MiddleCenter" />
        <Text text="]] .. xmlEscape(armor.label) .. [[" width="24" height="13" fontSize="9" color="#F2F4F8" alignment="MiddleCenter" offsetXY="0 -1" />
    </Panel>]], width
end

-- ---------------------------------------------------------------------------
-- v6.1 HUD — four readouts in a row, per William's layout sketch:
--
--     [ yellow ]  [ blue ]   [ heart ]   [ triangle ]
--     REACTION      AP        WOUNDS      ACTIVATION
--     ●            ●         ♥ 2         △
--     ●            ●
--     ○            ●
--
-- Reaction and AP are VERTICAL COLUMNS of full circles because they are
-- pools you burn down. Wounds is ONE heart with a number, because at 1-2
-- Wounds standard (B · 7) a row of hearts is noise. Activation is one
-- triangle with three states.
-- ---------------------------------------------------------------------------

local COLUMN_SLOT = 20      -- height of one circle row
local COLUMN_WIDTH = 22

-- Forward declaration: the Unit Library panel is defined much further down
-- (it needs loadDefinition), but buildUIXml has to be able to append it.
local buildLibraryPanelXml = function() return "" end

-- One vertical stack of full circles. Filled = still available.
--
-- v6.1 BUGFIX: this used to emit <Panel><Text/><Button/></Panel> nested inside
-- a VerticalLayout inside a HorizontalLayout. TTS layout groups force-expand
-- their children by default, so the whole stack collapsed and the circles were
-- invisible. Plain <Button> elements with a text glyph render reliably — that
-- is what the original AP pip row used — and every layout group now explicitly
-- turns force-expand OFF.
local function buildPoolColumnXml(idPrefix, current, maximum, filledHex, emptyHex, tooltip)
    if maximum <= 0 then return "", 0, 0 end

    local tip = xmlEscape(tooltip)

    -- Absurd budgets fall back to a number so the HUD never grows off-screen.
    if maximum > 8 then
        local txt = string.format("%d/%d", current, maximum)
        local xml = [[<Button id="]] .. idPrefix .. [[1" onClick="cusUiClick" text="]] .. xmlEscape(txt)
            .. [[" width="]] .. COLUMN_WIDTH .. [[" height="]] .. COLUMN_SLOT
            .. [[" fontSize="11" colors="#00000000|#FFFFFF14|#FFFFFF08|#00000000" textColor="#]] .. filledHex
            .. [[" tooltip="]] .. tip .. [[" />]]
        return xml, COLUMN_WIDTH, COLUMN_SLOT
    end

    local parts = {}
    for i = maximum, 1, -1 do          -- top of the column is the last point spent
        local filled = i <= current
        local glyph = filled and "●" or "○"
        local colour = filled and filledHex or emptyHex
        parts[#parts + 1] = [[<Button id="]] .. idPrefix .. i .. [[" onClick="cusUiClick" text="]] .. glyph
            .. [[" width="]] .. COLUMN_WIDTH .. [[" height="]] .. COLUMN_SLOT
            .. [[" fontSize="18" colors="#00000000|#FFFFFF14|#FFFFFF08|#00000000" textColor="#]] .. colour
            .. [[" tooltip="]] .. tip .. [[" />]]
    end

    local height = maximum * COLUMN_SLOT
    local xml = [[<VerticalLayout spacing="0" padding="0 0 0 0" childAlignment="MiddleCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="]]
        .. COLUMN_WIDTH .. [[" height="]] .. height .. [[">]] .. table.concat(parts) .. [[</VerticalLayout>]]
    return xml, COLUMN_WIDTH, height
end

-- ONE heart, with the remaining Wounds written on it.
local function buildWoundHeartXml()
    local maximum = math.max(0, tonumber(definition.wounds) or 0)
    local current = math.max(0, tonumber(runtime.current_wounds) or 0)
    local size = 46
    local tooltip = "WOUNDS " .. current .. "/" .. maximum
        .. "\nLeft: lose 1\nRight: heal 1\nAt 0 the figure is KNOCKED OUT."

    if current <= 0 then
        -- Down. Armour protects the standing and nothing else (H · 7).
        return [[<Panel width="]] .. size .. [[" height="]] .. size .. [[" tooltip="KNOCKED OUT&#10;A downed figure that is hit is KILLED, and rolls no Armour.">
            <Text text="☠" width="]] .. size .. [[" height="]] .. size .. [[" fontSize="34" color="#]] .. HEX.red .. [[" alignment="MiddleCenter" />
            ]] .. transparentButton("cus-heart-1", tooltip, size, size) .. [[
        </Panel>]], size
    end

    if assetEnabled("heart_full") then
        return [[<Panel width="]] .. size .. [[" height="]] .. size .. [[">
            <Image image="heart_full" width="]] .. size .. [[" height="]] .. size .. [[" preserveAspect="true" />
            <Text text="]] .. tostring(current) .. [[" width="]] .. size .. [[" height="]] .. size .. [[" fontSize="20" color="#FFFFFF" alignment="MiddleCenter" offsetXY="0 -2" />
            ]] .. transparentButton("cus-heart-1", tooltip, size, size) .. [[
        </Panel>]], size
    end

    return [[<Panel width="]] .. size .. [[" height="]] .. size .. [[">
        <Text text="♥" width="]] .. size .. [[" height="]] .. size .. [[" fontSize="42" color="#]] .. HEX.red .. [[" alignment="MiddleCenter" />
        <Text text="]] .. tostring(current) .. [[" width="]] .. size .. [[" height="]] .. size .. [[" fontSize="19" color="#FFFFFF" alignment="MiddleCenter" offsetXY="0 -3" />
        ]] .. transparentButton("cus-heart-1", tooltip, size, size) .. [[
    </Panel>]], size
end

-- ONE triangle, three states. Point up = it still has its turn. Filled purple
-- = an armed WAIT. Point down = spent.
local function buildActivationTriangleXml()
    local size = 40
    local glyph, colour, label

    if runtime.turn_state == "Activated" then
        glyph, colour, label = "▽", HEX.grey, "ACTIVATED — spent for this round."
    elseif runtime.turn_state == "Waiting" then
        glyph, colour, label = "▲", HEX.purple, "WAITING — a PACKET is armed. It still costs a Reaction to fire."
    else
        glyph, colour, label = "△", HEX.green, "UNACTIVATED — this figure has not gone yet."
    end

    local tooltip = label .. "\nLeft: next state\nRight: previous state"
    return [[<Panel width="]] .. size .. [[" height="]] .. size .. [[">
        <Text text="]] .. glyph .. [[" width="]] .. size .. [[" height="]] .. size .. [[" fontSize="34" color="#]] .. colour .. [[" alignment="MiddleCenter" />
        ]] .. transparentButton("cus-turn-state", tooltip, size, size) .. [[
    </Panel>]], size
end


local function buildAPPipsXml()
    -- BLUE column — Agency (AP). What you spend on YOUR OWN activation.
    return buildPoolColumnXml(
        "cus-ap-pip-",
        math.max(0, tonumber(runtime.current_ap) or 0),
        math.max(0, tonumber(definition.ap) or 0),
        HEX.blue, "1E2A3A",
        "AP — AGENCY\nSpent on your OWN activation.\n1 AP = one MOVE, one ACTION, or one WAIT.\nLeft: spend 1\nRight: restore 1"
    )
end

-- YELLOW column — Reaction. A separate Kernel Resource (A · IV): what you can
-- spend on SOMEONE ELSE'S activation. It is never paid out of AP and the two
-- pools never exchange, which is why they are two columns and not one. Every
-- triggered PACKET costs one — Counter, Shield Intercept, Reach strike, a
-- firing Overwatch. Empty column, and the figure cannot respond at all.
local function buildReactionPipsXml()
    return buildPoolColumnXml(
        "cus-react-pip-",
        math.max(0, tonumber(runtime.current_reactions) or 0),
        math.max(0, tonumber(definition.reactions) or 0),
        HEX.gold, "3A3018",
        "REACTION\nSpent on SOMEONE ELSE'S activation.\nCounter · Shield Intercept · Reach · Overwatch.\nRefreshes at the start of your own activation.\nLeft: spend 1\nRight: restore 1"
    )
end

-- v6: the Tier-1 action row. These four are the whole core loop, so they live
-- permanently on the token instead of behind a right-click menu.
local function buildActionRowXml()
    local accent = runtime.ui_accent or HEX.cyan
    local waitOn = runtime.turn_state == "Waiting"
    local waitColor = waitOn and HEX.purple or "2A3442"
    -- v6.1: MOVE is a TOGGLE. It was opening the ruler with no way back.
    local moveLabel = runtime.move_panel_open and "CLOSE" or "MOVE"
    local moveHex = runtime.move_panel_open and HEX.red or accent
    return [[
<Button id="cus-act-move" onClick="cusUiClick" text="]] .. moveLabel .. [[" width="42" height="17" fontSize="9" colors="#]] .. moveHex .. [[55|#]] .. moveHex .. [[99|#]] .. moveHex .. [[33|#]] .. moveHex .. [[55" tooltip="Movement ruler — click again to close.&#10;START, move, + WP, DONE." />
<Button id="cus-act-attack" onClick="cusUiClick" text="ATK" width="34" height="17" fontSize="9" colors="#F28C4555|#F28C4599|#F28C4533|#F28C4555" tooltip="Attack Controller.&#10;Then click the target." />
<Button id="cus-act-wait" onClick="cusUiClick" text="WAIT" width="38" height="17" fontSize="9" colors="#]] .. waitColor .. [[AA|#]] .. waitColor .. [[EE|#]] .. waitColor .. [[77|#]] .. waitColor .. [[AA" tooltip="WAIT — 1 AP to arm a PACKET.&#10;Still spends a Reaction when it fires.&#10;Right click: cancel." />
<Button id="cus-act-round" onClick="cusUiClick" text="↻" width="24" height="17" fontSize="12" colors="#65D46E55|#65D46E99|#65D46E33|#65D46E55" tooltip="Activation refresh — restore AP and Reaction,&#10;set Unactivated, clear the movement path (B · 12)." />]], 42 + 34 + 38 + 24 + 9
end

local function colorFromHex(hex)
    local clean = tostring(hex or HEX.cyan):gsub("#", "")
    if not clean:match("^[0-9A-Fa-f]+$") or #clean < 6 then clean = HEX.cyan end
    local r = tonumber(clean:sub(1, 2), 16) / 255
    local g = tonumber(clean:sub(3, 4), 16) / 255
    local b = tonumber(clean:sub(5, 6), 16) / 255
    return Color(r, g, b, 1)
end

local function applyModelHighlight()
    if runtime.model_highlight then
        pcall(function() self.highlightOn(colorFromHex(runtime.ui_accent)) end)
    else
        pcall(function() self.highlightOff() end)
    end
end


-- ---------------------------------------------------------------------------
-- Aura ring
-- ---------------------------------------------------------------------------

local function formatInches(value)
    local number = asNumber(value, 0)
    if math.abs(number - math.floor(number + 0.5)) < 0.001 then
        return string.format('%d"', math.floor(number + 0.5))
    end
    local text = string.format('%.2f', number)
    while text:sub(-1) == '0' do text = text:sub(1, -2) end
    if text:sub(-1) == '.' then text = text:sub(1, -2) end
    return text .. '"'
end

-- Approximate the canonical base radius so an entered 3" aura means 3" from
-- the base edge, not 3" from the model's centre. Elongated/mounted bases use
-- half of their longest standard dimension so the circular guide is conservative.
local function canonicalBaseRadiusInches()
    local shape = lower(definition.base_shape)
    local class = lower(definition.base_class)
    local diameterMm = 0

    -- v6: canonical base classes are Small · Medium · Large ONLY (B · 1).
    -- Monstrous and Cavalry are retired as classes — a "monstrous" figure is a
    -- Large base carrying the `unstoppable` trait, and mounted is elongated
    -- geometry, not a size. Legacy JSON saying "normal"/"monstrous"/"cavalry"
    -- still resolves so old miniatures do not have to be rebuilt.
    if class == "small" then
        diameterMm = shape == "circle" and 25 or 20
    elseif class == "medium" or class == "normal" then
        diameterMm = shape == "circle" and 32 or 25
    elseif class == "large" or class == "monstrous" then
        diameterMm = 40
    elseif class == "cavalry" then
        diameterMm = 40                      -- retired v0.5 class
    end

    -- Mounted is elongated geometry laid ON TOP of whatever class the figure
    -- already is — not a replacement for it. Use the longer dimension so the
    -- ring stays conservative. (William's handling; better than replacing.)
    if definition.mounted == true and diameterMm < 40 then
        diameterMm = 40
    end

    return (diameterMm * MM_TO_INCH) * 0.5
end

local function auraWorldRadius()
    local entered = clamp(asNumber(runtime.aura_radius, 0), 0, AURA_MAX_RADIUS)
    if entered <= 0 then return 0 end
    return entered + canonicalBaseRadiusInches()
end

-- ---------------------------------------------------------------------------
-- Movement ruler / waypoint path
-- ---------------------------------------------------------------------------

local function worldPoint(position, yOverride)
    local p = position or self.getPosition()
    return {
        x = asNumber(p.x or p[1], 0),
        y = asNumber(yOverride, asNumber(p.y or p[2], 0)),
        z = asNumber(p.z or p[3], 0),
    }
end

local function copyPoint(point)
    if type(point) ~= "table" then return nil end
    return worldPoint(point)
end

local function horizontalDistance(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return 0 end
    local dx = asNumber(b.x or b[1], 0) - asNumber(a.x or a[1], 0)
    local dz = asNumber(b.z or b[3], 0) - asNumber(a.z or a[3], 0)
    return math.sqrt(dx * dx + dz * dz)
end

local function currentLineY()
    if runtime.move_line_y ~= nil then return runtime.move_line_y end
    local ok, bounds = pcall(function() return self.getBounds() end)
    if ok and type(bounds) == "table" and type(bounds.center) == "table" and type(bounds.size) == "table" then
        local centerY = asNumber(bounds.center.y or bounds.center[2], self.getPosition().y)
        local sizeY = asNumber(bounds.size.y or bounds.size[2], 0)
        return centerY - (sizeY * 0.5) + 0.12
    end
    return self.getPosition().y
end

local function auraVectorLines()
    local lines = {}
    if runtime.aura_visible ~= true or asNumber(runtime.aura_radius, 0) <= 0 then
        return lines
    end

    local radius = auraWorldRadius()
    if radius <= 0 then return lines end

    local center = self.getPosition()
    local y = currentLineY()
    local points = {}
    for index = 0, AURA_SEGMENTS do
        local angle = (math.pi * 2 * index) / AURA_SEGMENTS
        local world = {
            x = center.x + math.cos(angle) * radius,
            y = y + 0.02,
            z = center.z + math.sin(angle) * radius,
        }
        local ok, localPoint = pcall(function() return self.positionToLocal(world) end)
        if ok and localPoint ~= nil then table.insert(points, localPoint) end
    end

    if #points >= 3 then
        table.insert(lines, {
            points = points,
            color = colorFromHex(runtime.ui_accent),
            thickness = AURA_LINE_THICKNESS,
        })
    end
    return lines
end

local function currentMovePoint()
    return worldPoint(self.getPosition(), currentLineY())
end

local function routeWorldPoints()
    local points = {}
    for _, point in ipairs(runtime.move_points or {}) do
        local p = copyPoint(point)
        if p ~= nil then table.insert(points, p) end
    end

    if runtime.move_endpoint ~= nil then
        local endpoint = copyPoint(runtime.move_endpoint)
        local last = points[#points]
        if endpoint ~= nil and (last == nil or horizontalDistance(last, endpoint) > MOVE_MIN_SEGMENT) then
            table.insert(points, endpoint)
        end
    end
    return points
end

local function movementDistance()
    local points = routeWorldPoints()
    local total = 0
    for index = 2, #points do
        total = total + horizontalDistance(points[index - 1], points[index])
    end
    return total
end

local function movementSpeed()
    return asNumber(definition.speed, nil)
end

local function movementOverLimit()
    local speed = movementSpeed()
    return speed ~= nil and movementDistance() > speed + 0.001
end

-- v6: the 3" sprint→charge threshold (B · 3). A Sprint becomes a CHARGE when it
-- covers 3" of uninterrupted straight run-up into contact. "Straight" is the
-- part the ruler can actually check: a path with committed waypoints has turned,
-- so only the FINAL leg counts toward the run-up.
local CHARGE_THRESHOLD = 3.0

local function finalLegDistance()
    local points = routeWorldPoints()
    if #points < 2 then return 0 end
    return horizontalDistance(points[#points - 1], points[#points])
end

local function chargeEarned()
    return finalLegDistance() >= CHARGE_THRESHOLD - 0.001
end

local function movementDistanceLabel()
    local total = movementDistance()
    local speed = movementSpeed()
    local prefix = runtime.move_active and "TRACKING  " or "MOVE  "

    -- The charge tag reports the final straight leg, because that is what earns
    -- it. Contact and interruption are still the players' call (B · 3, F).
    local charge = ""
    if finalLegDistance() > 0.05 then
        if chargeEarned() then
            charge = string.format('   CHARGE %.1f\"', finalLegDistance())
        else
            charge = string.format('   run-up %.1f\"/3\"', finalLegDistance())
        end
    end

    if speed ~= nil then
        local suffix = total > speed + 0.001 and "  OVER" or ""
        return string.format('%s%.1f\" / %.1f\"%s%s', prefix, total, speed, suffix, charge)
    end
    return string.format('%s%.1f\"%s', prefix, total, charge)
end

local function movementColor()
    if movementOverLimit() then return colorFromHex(HEX.red) end
    return colorFromHex(runtime.ui_accent)
end

local function refreshMovementDistanceText()
    -- The distance label only exists while the movement panel is open.
    -- Calling UI.setValue on a missing element causes a noisy TTS stack trace.
    if not runtime.move_panel_open or runtime.ui_hidden then return end
    self.UI.setValue("cus-move-distance", movementDistanceLabel())
    self.UI.setAttribute("cus-move-distance", "color", movementOverLimit() and ("#" .. HEX.red) or ("#" .. HEX.white))
end

local function refreshMovementLines()
    -- Aura and movement share the object's VectorLines collection, so they must
    -- be rebuilt together instead of either feature clearing the other.
    local lines = auraVectorLines()
    local worldPoints = routeWorldPoints()

    if #worldPoints >= 2 then
        local localPoints = {}
        for _, point in ipairs(worldPoints) do
            local ok, localPoint = pcall(function() return self.positionToLocal(point) end)
            if ok and localPoint ~= nil then table.insert(localPoints, localPoint) end
        end

        if #localPoints >= 2 then
            local lineColor = movementColor()
            table.insert(lines, {
                points = localPoints,
                color = lineColor,
                thickness = MOVE_LINE_THICKNESS,
            })

            -- Small crosses make committed waypoints obvious without spawning tokens.
            for index = 2, math.max(1, #runtime.move_points) do
                local point = runtime.move_points[index]
                if point ~= nil then
                    local leftWorld = {x = point.x - MOVE_WAYPOINT_SIZE, y = point.y, z = point.z}
                    local rightWorld = {x = point.x + MOVE_WAYPOINT_SIZE, y = point.y, z = point.z}
                    local backWorld = {x = point.x, y = point.y, z = point.z - MOVE_WAYPOINT_SIZE}
                    local frontWorld = {x = point.x, y = point.y, z = point.z + MOVE_WAYPOINT_SIZE}
                    local ok1, left = pcall(function() return self.positionToLocal(leftWorld) end)
                    local ok2, right = pcall(function() return self.positionToLocal(rightWorld) end)
                    local ok3, back = pcall(function() return self.positionToLocal(backWorld) end)
                    local ok4, front = pcall(function() return self.positionToLocal(frontWorld) end)
                    if ok1 and ok2 then
                        table.insert(lines, {points = {left, right}, color = lineColor, thickness = MOVE_LINE_THICKNESS})
                    end
                    if ok3 and ok4 then
                        table.insert(lines, {points = {back, front}, color = lineColor, thickness = MOVE_LINE_THICKNESS})
                    end
                end
            end
        end
    end

    self.setVectorLines(lines)
    refreshMovementDistanceText()
end

local function clearMovementPath(keepPanel)
    runtime.move_active = false
    runtime.move_points = {}
    runtime.move_endpoint = nil
    runtime.move_line_y = nil
    if not keepPanel then runtime.move_panel_open = false end
    refreshMovementLines()
end

local function startMovementPath(player)
    runtime.move_line_y = currentLineY()
    local start = currentMovePoint()
    runtime.move_points = {start}
    runtime.move_endpoint = copyPoint(start)
    runtime.move_active = true
    runtime.move_panel_open = true
    refreshMovementLines()
    notify(player, definition.name .. " movement tracking started.", {0.40, 0.80, 1.00})
end

local function addMovementWaypoint(player)
    if not runtime.move_active or #runtime.move_points == 0 then
        startMovementPath(player)
        return
    end

    runtime.move_endpoint = currentMovePoint()
    local last = runtime.move_points[#runtime.move_points]
    if horizontalDistance(last, runtime.move_endpoint) > MOVE_MIN_SEGMENT then
        table.insert(runtime.move_points, copyPoint(runtime.move_endpoint))
        notify(player, string.format('%s waypoint set at %.1f\".', definition.name, movementDistance()))
    end
    refreshMovementLines()
end

local function undoMovementWaypoint(player)
    if #runtime.move_points > 1 then
        table.remove(runtime.move_points)
        runtime.move_endpoint = currentMovePoint()
        notify(player, definition.name .. " removed the last waypoint.")
    elseif #runtime.move_points == 1 then
        runtime.move_endpoint = copyPoint(runtime.move_points[1])
    end
    refreshMovementLines()
end

local function finishMovementPath(player)
    if #runtime.move_points == 0 then return end
    runtime.move_endpoint = currentMovePoint()
    local last = runtime.move_points[#runtime.move_points]
    if horizontalDistance(last, runtime.move_endpoint) > MOVE_MIN_SEGMENT then
        table.insert(runtime.move_points, copyPoint(runtime.move_endpoint))
    end
    runtime.move_endpoint = copyPoint(runtime.move_points[#runtime.move_points])
    runtime.move_active = false
    refreshMovementLines()
    notify(player, string.format('%s movement frozen at %.1f\".', definition.name, movementDistance()))
end

local function runtimeNamePrefix()
    local stateText = renderTurnBadge()
    local woundText = renderHearts(runtime.current_wounds, definition.wounds)
    return "{" .. bb(turnStateColor(), stateText, true) .. " " .. bb(woundsColor(), woundText, true) .. "}"
end

local function buildDescription()
    local lines = {}
    if not definitionValid then
        table.insert(lines, bb(HEX.red, "CUS JSON ERROR", true))
        table.insert(lines, bb(HEX.red, definitionError or "Unknown error", false))
        table.insert(lines, "")
    end

    if definition.faction ~= nil and definition.faction ~= "—" then
        table.insert(lines, bb(HEX.gold, tostring(definition.faction), true))
    end

    -- Tempo is presented first as a bracketed visual tag, then Role / Tool / Archetype.
    local identity = ""
    if definition.tempo ~= nil and definition.tempo ~= "—" and trim(definition.tempo) ~= "" then
        identity = bb(HEX.gold, "[" .. tostring(definition.tempo) .. "]", true) .. "  "
    end
    identity = identity
        .. bb(roleColor(), tostring(definition.role), true)
        .. "  ·  " .. bb(toolColor(), tostring(definition.tool), true)
        .. "  ·  " .. bb(HEX.muted, tostring(definition.archetype), false)
    table.insert(lines, identity)

    -- Runtime values keep their semantic colors without repeating W / AP / N labels.
    table.insert(lines,
        bb(woundsColor(), runtime.current_wounds .. "/" .. definition.wounds, true)
        .. "   " .. bb(HEX.blue, runtime.current_ap .. "/" .. definition.ap, true)
        .. "   " .. bb(nerveColor(), runtime.nerve_state, true)
    )
    table.insert(lines, bb(turnStateColor(), string.upper(runtime.turn_state), true))
    if runtime.aura_visible and runtime.aura_radius > 0 then
        table.insert(lines, bb(runtime.ui_accent, "AURA " .. formatInches(runtime.aura_radius) .. " FROM BASE", true))
    end

    local statParts = {}
    local armourText = trim(definition.armour)
    if armourText ~= "" and armourText ~= "—" and armourText ~= "-" then
        table.insert(statParts, bb(HEX.cyan, "ARM", true) .. " " .. tostring(definition.armour))
    end
    table.insert(statParts, bb(HEX.blue, "SPD", true) .. " " .. tostring(definition.speed))
    table.insert(statParts, bb(HEX.purple, "NERVE", true) .. " " .. tostring(definition.nerve))
    table.insert(statParts, bb(HEX.pink, "REACT", true) .. " " .. runtime.current_reactions .. "/" .. definition.reactions)
    if definition.points ~= nil and definition.points ~= "—" then
        table.insert(statParts, bb(HEX.gold, "PTS", true) .. " " .. tostring(definition.points))
    end
    table.insert(lines, table.concat(statParts, "   "))

    local identityParts = {}
    if definition.creature ~= "—" then table.insert(identityParts, tostring(definition.creature)) end
    if definition.base ~= "—" then table.insert(identityParts, tostring(definition.base)) end
    if definition.temper ~= "—" then table.insert(identityParts, tostring(definition.temper)) end
    if #identityParts > 0 then
        table.insert(lines, bb(HEX.muted, table.concat(identityParts, " · "), false))
    end

    if type(definition.traits) == "table" and #definition.traits > 0 then
        table.insert(lines, "")
        table.insert(lines, bb(HEX.purple, "TRAITS", true))
        for _, trait in ipairs(definition.traits) do
            table.insert(lines, bb(HEX.purple, tostring(trait.name), true))
            if trait.note ~= nil and trim(trait.note) ~= "" then
                table.insert(lines, "  " .. bbSmallItalic(HEX.muted, tostring(trait.note)))
            end
        end
    end

    if type(definition.packets) == "table" and #definition.packets > 0 then
        table.insert(lines, "")
        for packetIndex, packet in ipairs(definition.packets) do
            if packetIndex > 1 then table.insert(lines, "") end
            table.insert(lines, bb(HEX.orange, tostring(packet.name), true))

            local packetMeta = bb(HEX.muted, tostring(packet.verb), false)
                .. "  ·  " .. packetRollText(packet)
                .. "  ·  " .. packetRangeText(packet)
                .. "  ·  " .. tostring(packet.cost_ap or 0) .. " AP"
            if packet.area ~= nil and trim(packet.area) ~= "" then
                packetMeta = packetMeta .. "  ·  " .. tostring(packet.area)
            end
            table.insert(lines, "  " .. packetMeta)

            if type(packet.grades) == "table" and #packet.grades > 0 then
                for _, grade in ipairs(packet.grades) do
                    if type(grade) == "table" then
                        local successes = first(grade.successes, grade.success, grade.grade, "?")
                        local effects = grade.effects
                        local effectText = "—"
                        if type(effects) == "table" then
                            local cleaned = {}
                            for _, effect in ipairs(effects) do
                                table.insert(cleaned, cleanDisplayText(effect))
                            end
                            effectText = table.concat(cleaned, " + ")
                        elseif effects ~= nil then
                            effectText = cleanDisplayText(effects)
                        end
                        table.insert(lines, "  " .. bb(HEX.muted, tostring(successes) .. "S → " .. tostring(effectText), false))
                    end
                end
            else
                table.insert(lines, bb(HEX.muted, "—", false))
            end
        end
    else
        table.insert(lines, "")
        table.insert(lines,
            bb(HEX.orange, "ATK", true) .. " " .. tostring(definition.dice)
            .. "   " .. bb(HEX.orange, "HIT", true) .. " " .. tostring(definition.hit)
            .. "   " .. bb(HEX.purple, "WEAPON", true) .. " " .. tostring(definition.weapon)
        )
        table.insert(lines, bb(HEX.muted, "GRADES", true) .. " " .. tostring(definition.grades))
    end

    if definition.note ~= nil and trim(definition.note) ~= "" then
        table.insert(lines, bb(HEX.muted, "NOTE", true) .. " " .. tostring(definition.note))
    end
    return table.concat(lines, "\n")
end

local function buildUIXml()
    if runtime.ui_hidden then return "" end

    local scale = self.getScale()
    local sx = 1 / math.max(scale.x, 0.001)
    local sy = 1 / math.max(scale.y, 0.001)
    local sz = 1 / math.max(scale.z, 0.001)
    local position = string.format("%.1f %.1f %.1f", runtime.ui_x * sx, runtime.ui_y * sy, runtime.ui_z * sz)
    local uiScale = runtime.ui_scale or 0.58
    local panelScale = string.format("%.4f %.4f %.4f", sx * uiScale, sy * uiScale, sz * uiScale)

    local accent = runtime.ui_accent or HEX.cyan
    local apXml, apWidth, apHeight = buildAPPipsXml()
    local reactXml, reactWidth, reactHeight = buildReactionPipsXml()
    local actionXml, actionWidth = buildActionRowXml()
    local heartXml, heartWidth = buildWoundHeartXml()
    local armorXml, armorWidth = buildArmourXml(armorStateData())
    local actXml, actWidth = buildActivationTriangleXml()
    local nerveXml = buildTokenXml("cus-nerve", nerveTokenData(), 34, 30)
    local auraRadius = asNumber(runtime.aura_radius, 0)
    local auraLabel = auraRadius > 0 and ("AURA " .. formatInches(auraRadius)) or "SET AURA"
    local auraToggleLabel = runtime.aura_visible and "ON" or "OFF"

    -- Expanded controls are deliberately not part of the permanent token strip.
    -- Open them from the miniature's CUS right-click menu.
    local moveXml = ""
    if runtime.move_panel_open then
        local moveStartText = runtime.move_active and "RESET" or "START"
        local moveOutline = movementOverLimit() and HEX.red or accent
        moveXml = [[
<Panel position="]] .. position .. [[" width="220" height="64" rotation="0 0 ]] .. tostring(runtime.ui_rotation) .. [[" scale="]] .. panelScale .. [[" offsetXY="150 28" color="#11151CDD" outline="#]] .. moveOutline .. [[" outlineSize="2 2">
    <VerticalLayout spacing="3" childAlignment="MiddleCenter" width="216" height="60" padding="3 3 3 3">
        <Text id="cus-move-distance" text="]] .. xmlEscape(movementDistanceLabel()) .. [[" width="210" height="22" fontSize="13" color="#]] .. (movementOverLimit() and HEX.red or HEX.white) .. [[" alignment="MiddleCenter" />
        <HorizontalLayout spacing="3" childAlignment="MiddleCenter" width="210" height="28">
            <Button id="cus-move-start" onClick="cusUiClick" text="]] .. moveStartText .. [[" width="48" height="24" fontSize="10" />
            <Button id="cus-move-waypoint" onClick="cusUiClick" text="+ WP" width="42" height="24" fontSize="11" colors="#]] .. accent .. [[AA|#]] .. accent .. [[DD|#]] .. accent .. [[88|#]] .. accent .. [[AA" />
            <Button id="cus-move-undo" onClick="cusUiClick" text="↶" width="30" height="24" fontSize="15" />
            <Button id="cus-move-finish" onClick="cusUiClick" text="DONE" width="42" height="24" fontSize="10" />
            <Button id="cus-move-clear" onClick="cusUiClick" text="×" width="30" height="24" fontSize="15" colors="#]] .. HEX.red .. [[99|#]] .. HEX.red .. [[CC|#]] .. HEX.red .. [[77|#]] .. HEX.red .. [[99" />
        </HorizontalLayout>
    </VerticalLayout>
</Panel>]]
    end

    local configXml = ""
    if runtime.ui_config_open then
        local glowText = runtime.model_highlight and "GLOW ON" or "GLOW OFF"
        local glowColor = runtime.model_highlight and accent or HEX.grey
        configXml = [[
<Panel position="]] .. position .. [[" width="184" height="228" rotation="0 0 ]] .. tostring(runtime.ui_rotation) .. [[" scale="]] .. panelScale .. [[" offsetXY="-150 -58" color="#11151CDD" outline="#]] .. accent .. [[" outlineSize="2 2">
    <VerticalLayout spacing="3" childAlignment="MiddleCenter" width="180" height="224" padding="4 4 4 4">
        <Text text="OVERLAY" width="172" height="18" fontSize="12" color="#F2F4F8" />
        <HorizontalLayout spacing="3" childAlignment="MiddleCenter" width="172" height="24"><Text text="X" width="18" height="22" /><Button id="cus-x-minus" onClick="cusUiClick" text="−" width="28" height="22" /><Text text="]] .. string.format("%.0f", runtime.ui_x) .. [[" width="54" height="22" /><Button id="cus-x-plus" onClick="cusUiClick" text="+" width="28" height="22" /></HorizontalLayout>
        <HorizontalLayout spacing="3" childAlignment="MiddleCenter" width="172" height="24"><Text text="Y" width="18" height="22" /><Button id="cus-y-minus" onClick="cusUiClick" text="−" width="28" height="22" /><Text text="]] .. string.format("%.0f", runtime.ui_y) .. [[" width="54" height="22" /><Button id="cus-y-plus" onClick="cusUiClick" text="+" width="28" height="22" /></HorizontalLayout>
        <HorizontalLayout spacing="3" childAlignment="MiddleCenter" width="172" height="24"><Text text="Z" width="18" height="22" /><Button id="cus-z-minus" onClick="cusUiClick" text="−" width="28" height="22" /><Text text="]] .. string.format("%.0f", runtime.ui_z) .. [[" width="54" height="22" /><Button id="cus-z-plus" onClick="cusUiClick" text="+" width="28" height="22" /></HorizontalLayout>
        <HorizontalLayout spacing="3" childAlignment="MiddleCenter" width="172" height="24"><Text text="S" width="18" height="22" /><Button id="cus-scale-minus" onClick="cusUiClick" text="−" width="28" height="22" /><Text text="]] .. string.format("%d%%", math.floor(runtime.ui_scale * 100 + 0.5)) .. [[" width="54" height="22" /><Button id="cus-scale-plus" onClick="cusUiClick" text="+" width="28" height="22" /></HorizontalLayout>
        <HorizontalLayout spacing="3" childAlignment="MiddleCenter" width="172" height="22">
            <Button id="cus-color-red" onClick="cusUiClick" text="" width="18" height="18" colors="#EF5B5BFF|#EF5B5BFF|#EF5B5BFF|#EF5B5BFF" />
            <Button id="cus-color-gold" onClick="cusUiClick" text="" width="18" height="18" colors="#E8C35AFF|#E8C35AFF|#E8C35AFF|#E8C35AFF" />
            <Button id="cus-color-green" onClick="cusUiClick" text="" width="18" height="18" colors="#65D46EFF|#65D46EFF|#65D46EFF|#65D46EFF" />
            <Button id="cus-color-cyan" onClick="cusUiClick" text="" width="18" height="18" colors="#58D6D6FF|#58D6D6FF|#58D6D6FF|#58D6D6FF" />
            <Button id="cus-color-blue" onClick="cusUiClick" text="" width="18" height="18" colors="#55A7FFFF|#55A7FFFF|#55A7FFFF|#55A7FFFF" />
            <Button id="cus-color-purple" onClick="cusUiClick" text="" width="18" height="18" colors="#B784FFFF|#B784FFFF|#B784FFFF|#B784FFFF" />
            <Button id="cus-color-white" onClick="cusUiClick" text="" width="18" height="18" colors="#F2F4F8FF|#F2F4F8FF|#F2F4F8FF|#F2F4F8FF" />
        </HorizontalLayout>
        <HorizontalLayout spacing="3" childAlignment="MiddleCenter" width="172" height="24"><Button id="cus-aura-set" onClick="cusUiClick" text="]] .. xmlEscape(auraLabel) .. [[" width="92" height="22" fontSize="11" /><Button id="cus-aura-toggle" onClick="cusUiClick" text="]] .. auraToggleLabel .. [[" width="42" height="22" fontSize="10" /><Button id="cus-aura-clear" onClick="cusUiClick" text="×" width="28" height="22" /></HorizontalLayout>
        <HorizontalLayout spacing="3" childAlignment="MiddleCenter" width="172" height="24"><Button id="cus-ap-spend" onClick="cusUiClick" text="SPEND AP" width="82" height="22" fontSize="10" /><Button id="cus-ap-restore" onClick="cusUiClick" text="RESTORE AP" width="82" height="22" fontSize="10" /></HorizontalLayout>
        <HorizontalLayout spacing="3" childAlignment="MiddleCenter" width="172" height="24"><Button id="cus-new-round" onClick="cusUiClick" text="NEW ROUND" width="82" height="22" fontSize="10" /><Button id="cus-full-reset" onClick="cusUiClick" text="FULL RESET" width="82" height="22" fontSize="10" colors="#EF5B5B77|#EF5B5BAA|#EF5B5B55|#EF5B5B77" /></HorizontalLayout>
        <Button id="cus-highlight-toggle" onClick="cusUiClick" text="]] .. glowText .. [[" width="108" height="21" fontSize="11" colors="#]] .. glowColor .. [[CC|#]] .. glowColor .. [[FF|#]] .. glowColor .. [[AA|#]] .. glowColor .. [[CC" />
    </VerticalLayout>
</Panel>]]
    end

    -- v6.1 layout: one horizontal row — reaction column, AP column, heart,
    -- triangle, then armour and nerve badges. Height is driven by whichever
    -- pool column is tallest, so a 2 AP figure does not reserve room for 6.
    local rowHeight = math.max(48, asNumber(apHeight, 0), asNumber(reactHeight, 0))
    local rowWidth = asNumber(reactWidth, 0) + asNumber(apWidth, 0) + heartWidth
        + asNumber(actWidth, 0) + armorWidth + 34 + (6 * 5)
    local baseWidth = math.max(120, rowWidth + 8, actionWidth + 6)
    local totalHeight = rowHeight + 23
    local xml = [[
<Defaults>
    <Button fontSize="14" textColor="#F2F4F8" colors="#00000000|#FFFFFF12|#FFFFFF08|#00000000" />
    <Text color="#F2F4F8" alignment="MiddleCenter" />
</Defaults>
<Panel position="]] .. position .. [[" width="]] .. baseWidth .. [[" height="]] .. totalHeight .. [[" rotation="0 0 ]] .. tostring(runtime.ui_rotation) .. [[" scale="]] .. panelScale .. [[" color="#00000000">
    <VerticalLayout spacing="3" padding="0 0 0 0" childAlignment="MiddleCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="]] .. baseWidth .. [[" height="]] .. totalHeight .. [[">
        <HorizontalLayout spacing="6" padding="0 0 0 0" childAlignment="MiddleCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="]] .. baseWidth .. [[" height="]] .. rowHeight .. [[">]]
            .. reactXml .. apXml .. heartXml .. actXml .. armorXml .. nerveXml .. [[</HorizontalLayout>
        <HorizontalLayout spacing="3" padding="0 0 0 0" childAlignment="MiddleCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="]] .. baseWidth .. [[" height="19">]] .. actionXml .. [[</HorizontalLayout>
    </VerticalLayout>
</Panel>]] .. moveXml .. configXml .. buildLibraryPanelXml(position, panelScale, accent)
    return xml
end

local function refreshAll()
    initializeRuntime()
    self.setName(runtimeNamePrefix() .. " " .. tostring(definition.name))
    self.setDescription(buildDescription())
    self.UI.setXml(buildUIXml())
    applyModelHighlight()

    -- Let TTS instantiate the new XML before updating any element by ID.
    Wait.frames(function()
        if self ~= nil and not self.isDestroyed() then
            refreshMovementLines()
        end
    end, 1)
end

local function changeWounds(amount, player)
    runtime.current_wounds = clamp(runtime.current_wounds + amount, 0, definition.wounds)
    refreshAll()
    local status = runtime.current_wounds <= 0 and " is KO." or (" is at " .. runtime.current_wounds .. "/" .. definition.wounds .. " Wounds.")
    notify(player, definition.name .. status)
end

local function changeAP(amount, player)
    runtime.current_ap = clamp(runtime.current_ap + amount, 0, definition.ap)
    refreshAll()
    notify(player, definition.name .. " has " .. runtime.current_ap .. "/" .. definition.ap .. " AP.")
end

-- v6: Reaction never comes out of AP (A · IV). Separate pool, separate control.
local function changeReactions(amount, player)
    local maximum = math.max(0, asNumber(definition.reactions, 1))
    local before = runtime.current_reactions
    runtime.current_reactions = clamp(runtime.current_reactions + amount, 0, maximum)
    refreshAll()

    if runtime.current_reactions == 0 and before > 0 then
        notify(player, definition.name .. " has NO REACTION left — it cannot Counter, intercept, or fire an armed WAIT.", {1.00, 0.45, 0.55})
    else
        notify(player, definition.name .. " has " .. runtime.current_reactions .. "/" .. maximum .. " Reaction.")
    end
end

local function changeNerve(direction, player)
    runtime.nerve_state = stepState(NERVE_STATES, runtime.nerve_state, direction)
    refreshAll()
    if runtime.nerve_state == "Broken" then
        notify(player, definition.name .. " is BROKEN — it Routs by its Temperament (" .. tostring(definition.temper) .. ").", {1.00, 0.40, 0.40})
    else
        notify(player, definition.name .. " is " .. runtime.nerve_state .. ".")
    end
end

-- v6: WAIT is 1 AP to arm a PACKET, and it STILL spends a Reaction when it
-- fires (A · III). Arming is not permission — with an empty pool it does not
-- resolve, so the button refuses when there is nothing to fire with.
local function armWait(player)
    if runtime.turn_state == "Waiting" then
        runtime.turn_state = "Unactivated"
        synchronizeTurnFlags()
        refreshAll()
        notify(player, definition.name .. " cancelled its WAIT. (AP is not refunded.)")
        return
    end

    if runtime.current_ap <= 0 then
        notify(player, definition.name .. " has no AP to arm a WAIT.", {1.00, 0.45, 0.45})
        return
    end

    runtime.current_ap = clamp(runtime.current_ap - 1, 0, definition.ap)
    runtime.turn_state = "Waiting"
    synchronizeTurnFlags()
    refreshAll()

    if runtime.current_reactions <= 0 then
        notify(player, definition.name .. " armed a WAIT — but has NO REACTION, so it will not resolve. Arming is not permission.", {1.00, 0.55, 0.35})
    else
        notify(player, definition.name .. " armed a WAIT. It still spends a Reaction when it fires.", {0.72, 0.52, 1.00})
    end
end

local function changeTurnState(direction, player)
    runtime.turn_state = stepState(TURN_STATES, runtime.turn_state, direction)
    synchronizeTurnFlags()
    refreshAll()
    notify(player, definition.name .. " is " .. runtime.turn_state .. ".")
end

-- v6: this is the ACTIVATION refresh, not a round-wide one. Per B · 12 a figure
-- refreshes its AP and Reaction and expires its armed WAIT at the start of its
-- OWN activation — which is why a figure that emptied its pool late last round
-- walks into this one still empty. Hit the tired ones.
local function newRound(player)
    clearMovementPath(true)
    runtime.current_ap = definition.ap
    runtime.current_reactions = math.max(0, asNumber(definition.reactions, 1))
    runtime.turn_state = "Unactivated"
    synchronizeTurnFlags()
    refreshAll()
    notify(player, definition.name .. " refreshed: " .. runtime.current_ap .. " AP, " .. runtime.current_reactions .. " Reaction. Armed WAIT expired.", {0.40, 0.80, 1.00})
end

local function resetRuntime(player)
    clearMovementPath(true)
    runtime.current_wounds = definition.wounds
    runtime.current_ap = definition.ap
    runtime.current_reactions = math.max(0, asNumber(definition.reactions, 1))
    runtime.nerve_state = "Steady"
    runtime.turn_state = "Unactivated"
    synchronizeTurnFlags()
    refreshAll()
    notify(player, definition.name .. " runtime state fully reset.", {0.40, 0.80, 1.00})
end

local function isRightClick(value)
    return tostring(value) == "-2"
end

local function setAuraRadiusFromText(text, playerColor)
    local radius = asNumber(text, nil)
    if radius == nil then
        notify(playerColor, "Enter an aura radius such as 1, 2, 3 or 1.4.", {1.00, 0.35, 0.35})
        return
    end

    radius = clamp(radius, 0, AURA_MAX_RADIUS)
    runtime.aura_radius = radius
    runtime.aura_visible = radius > 0
    refreshAll()

    if radius > 0 then
        notify(playerColor, definition.name .. " aura set to " .. formatInches(radius) .. " from the base edge.")
    else
        notify(playerColor, definition.name .. " aura cleared.")
    end
end

local function openAuraDialog(playerOrColor)
    local playerColor = type(playerOrColor) == "string" and playerOrColor or (playerOrColor and playerOrColor.color)
    local player = playerColor and Player[playerColor] or nil
    if player == nil then return end

    local defaultValue = runtime.aura_radius > 0 and tostring(runtime.aura_radius) or ""
    local callback = function(text, callbackColor)
        setAuraRadiusFromText(text, callbackColor)
    end

    if player.showInputDialog ~= nil then
        player.showInputDialog("Aura radius in inches (0 clears it).", defaultValue, callback)
    else
        player.showMemoDialog("Aura radius in inches (0 clears it).", defaultValue, callback)
    end
end

function cusUiClick(player, value, id)
    local rightClick = isRightClick(value)

    -- v6 BUGFIX: "cus-heart-" is ten characters, so the old sub(id, 1, 9)
    -- compared "cus-heart" against "cus-heart-" and never matched. Every heart
    -- click was silently dropped.
    if id ~= nil and string.sub(id, 1, 10) == "cus-heart-" then
        changeWounds(rightClick and 1 or -1, player)
    elseif id == "cus-wounds" then
        changeWounds(rightClick and 1 or -1, player)
    elseif id ~= nil and string.sub(id, 1, 11) == "cus-ap-pip-" then
        changeAP(rightClick and 1 or -1, player)
    elseif id == "cus-ap-pips" or id == "cus-ap" or id == "cus-ap-spend" then
        changeAP(rightClick and 1 or -1, player)
    elseif id == "cus-ap-restore" then
        changeAP(rightClick and -1 or 1, player)
    -- v6: Reaction pool
    elseif id ~= nil and string.sub(id, 1, 14) == "cus-react-pip-" then
        changeReactions(rightClick and 1 or -1, player)
    elseif id == "cus-react-pips" then
        changeReactions(rightClick and 1 or -1, player)
    -- v6: Tier-1 action row
    -- v6.1: toggle. Opening starts tracking; closing clears the path so you are
    -- not left with an orphaned ruler drawn on the table.
    elseif id == "cus-act-move" then
        if runtime.move_panel_open then
            clearMovementPath(false)
        else
            runtime.move_panel_open = true
            if not runtime.move_active then startMovementPath(player) end
        end
        refreshAll()
    elseif id == "cus-act-attack" then
        -- Inlined rather than calling contextAttack(), which is declared later
        -- in the file and would still be nil at this point.
        local attackColor = type(player) == "string" and player or (player and player.color)
        local ok, started = pcall(function()
            return Global.call("CUS_BeginAttack", {
                player_color = attackColor,
                attacker_guid = self.getGUID(),
            })
        end)
        if not ok or started ~= true then
            notify(player, "CUS Attack Controller is not installed in Global.lua.", {1.00, 0.35, 0.35})
        end
    elseif id == "cus-act-wait" then
        armWait(player)
    elseif id == "cus-act-round" then
        newRound(player)
    elseif id == "cus-new-round" then
        newRound(player)
    elseif id == "cus-full-reset" then
        resetRuntime(player)
    elseif id == "cus-nerve" then
        changeNerve(rightClick and -1 or 1, player)
    elseif id == "cus-turn-state" then
        changeTurnState(rightClick and -1 or 1, player)
    elseif id == "cus-move-toggle" then
        runtime.move_panel_open = not runtime.move_panel_open
        refreshAll()
    elseif id == "cus-move-start" then
        startMovementPath(player)
        refreshAll()
    elseif id == "cus-move-waypoint" then
        addMovementWaypoint(player)
        refreshAll()
    elseif id == "cus-move-undo" then
        undoMovementWaypoint(player)
        refreshAll()
    elseif id == "cus-move-finish" then
        finishMovementPath(player)
        refreshAll()
    -- v6.1: the × in the ruler panel now actually CLOSES it. It used to pass
    -- keepPanel = true, which wiped the path and left the panel stuck open.
    elseif id == "cus-move-clear" then
        clearMovementPath(false)
        refreshAll()
    elseif id == "cus-armour" then
        -- Placeholder armour token. Derived from JSON, not manually cycled.
    elseif id == "cus-aura-set" then
        openAuraDialog(player)
    elseif id == "cus-aura-toggle" then
        if runtime.aura_radius <= 0 then
            openAuraDialog(player)
        else
            runtime.aura_visible = not runtime.aura_visible
            refreshAll()
        end
    elseif id == "cus-aura-clear" then
        runtime.aura_radius = 0
        runtime.aura_visible = false
        refreshAll()
    elseif id == "cus-config-toggle" then
        runtime.ui_config_open = not runtime.ui_config_open
        refreshAll()
    elseif id == "cus-x-minus" then
        runtime.ui_x = runtime.ui_x - OVERLAY_STEP
        refreshAll()
    elseif id == "cus-x-plus" then
        runtime.ui_x = runtime.ui_x + OVERLAY_STEP
        refreshAll()
    elseif id == "cus-y-minus" then
        runtime.ui_y = runtime.ui_y - OVERLAY_STEP
        refreshAll()
    elseif id == "cus-y-plus" then
        runtime.ui_y = runtime.ui_y + OVERLAY_STEP
        refreshAll()
    elseif id == "cus-z-minus" then
        runtime.ui_z = runtime.ui_z - OVERLAY_STEP
        refreshAll()
    elseif id == "cus-z-plus" then
        runtime.ui_z = runtime.ui_z + OVERLAY_STEP
        refreshAll()
    elseif id == "cus-scale-minus" then
        runtime.ui_scale = clamp(runtime.ui_scale - 0.05, 0.35, 1.20)
        refreshAll()
    elseif id == "cus-scale-plus" then
        runtime.ui_scale = clamp(runtime.ui_scale + 0.05, 0.35, 1.20)
        refreshAll()
    elseif id == "cus-highlight-toggle" then
        runtime.model_highlight = not runtime.model_highlight
        refreshAll()
    -- v6.1 Unit Library
    elseif id == "cus-lib-close" then
        runtime.library_open = false
        refreshAll()
    elseif id == "cus-lib-reload" then
        CUS_LibraryReload(player)
    elseif id ~= nil and string.sub(id, 1, 13) == "cus-lib-unit-" then
        CUS_LibraryPick(tonumber(string.sub(id, 14)), player)
    elseif id ~= nil and string.sub(id, 1, 12) == "cus-lib-fac-" then
        CUS_LibraryFaction(tonumber(string.sub(id, 13)), player)
    else
        local preset = id:match("^cus%-color%-(.+)$")
        if preset ~= nil and COLOR_PRESETS[preset] ~= nil then
            runtime.ui_accent = COLOR_PRESETS[preset]
            refreshAll()
        end
    end
end

local function contextEditJson(playerColor)
    local player = Player[playerColor]
    if player == nil then return end

    local existing = first(
        type(runtime.definition_json) == "string" and runtime.definition_json or nil,
        type(self.memo) == "string" and self.memo or nil,
        self.getGMNotes and self.getGMNotes() or nil,
        ""
    )
    player.showMemoDialog(
        "Paste the complete CUS unit JSON, then press OK.",
        existing,
        function(text, callbackColor)
            local raw = extractJsonObject(text or "") or stripCodeFence(text or "")
            if raw == "" then
                notify(callbackColor, "CUS JSON was left empty.", {1.00, 0.35, 0.35})
                return
            end

            runtime.definition_json = raw
            self.memo = raw
            if self.setGMNotes then pcall(function() self.setGMNotes("") end) end
            loadDefinition(callbackColor, true)
            refreshAll()
        end
    )
end

local function contextReload(playerColor)
    loadDefinition(playerColor, true)
    refreshAll()
end
local function contextSpendAP(playerColor) changeAP(-1, playerColor) end
local function contextRestoreAP(playerColor) changeAP(1, playerColor) end
local function contextNewRound(playerColor) newRound(playerColor) end
local function contextReset(playerColor) resetRuntime(playerColor) end
local function contextToggleUI(playerColor)
    runtime.ui_hidden = not runtime.ui_hidden
    refreshAll()
    notify(playerColor, runtime.ui_hidden and "CUS tracker hidden." or "CUS tracker shown.")
end
local function contextRotateUI(playerColor)
    runtime.ui_rotation = (runtime.ui_rotation + 90) % 360
    refreshAll()
    notify(playerColor, "CUS tracker rotated to " .. runtime.ui_rotation .. "°.")
end
local function contextMoveOut(playerColor)
    runtime.ui_z = runtime.ui_z - OVERLAY_STEP
    refreshAll()
end
local function contextMoveIn(playerColor)
    runtime.ui_z = runtime.ui_z + OVERLAY_STEP
    refreshAll()
end
local function contextOverlayControls(playerColor)
    runtime.ui_config_open = not runtime.ui_config_open
    refreshAll()
end
local function contextMovementControls(playerColor)
    runtime.move_panel_open = not runtime.move_panel_open
    refreshAll()
end
local function contextSetAura(playerColor)
    openAuraDialog(playerColor)
end
local function contextToggleAura(playerColor)
    if runtime.aura_radius <= 0 then
        openAuraDialog(playerColor)
    else
        runtime.aura_visible = not runtime.aura_visible
        refreshAll()
    end
end
local function contextClearAura(playerColor)
    runtime.aura_radius = 0
    runtime.aura_visible = false
    refreshAll()
end
local function contextClearMovement(playerColor)
    clearMovementPath(true)
    refreshAll()
end
local function contextCycleUISize(playerColor)
    local current = runtime.ui_scale or 0.58
    local nearestIndex = 1
    local nearestDistance = math.huge
    for index, value in ipairs(UI_SCALES) do
        local distance = math.abs(current - value)
        if distance < nearestDistance then
            nearestDistance = distance
            nearestIndex = index
        end
    end
    local nextIndex = (nearestIndex % #UI_SCALES) + 1
    runtime.ui_scale = UI_SCALES[nextIndex]
    refreshAll()
    notify(playerColor, string.format("CUS tracker size: %d%%.", math.floor(runtime.ui_scale * 100 + 0.5)))
end


-- ---------------------------------------------------------------------------
-- v6.1 UNIT LIBRARY  —  pulls straight from the repo over HTTPS
--
-- Source of truth is github.com/whbreifcase-arch/cus-kernel-rebuild, so a
-- balance change to a JSON file is live on the next pick with nothing to
-- re-import. Units reference packets and traits BY ID (Law 1 — defined once,
-- referenced everywhere), so this resolves those IDs against the packet and
-- trait files before handing a complete definition to the tracker.
-- ---------------------------------------------------------------------------

local LIBRARY_BASE = "https://raw.githubusercontent.com/whbreifcase-arch/cus-kernel-rebuild/main/factions/data/"

local LIBRARY_FILES = {
    {label = "Generic",     file = "library_generic.json"},
    {label = "Templars",    file = "faction_templar.json"},
    {label = "Mordor",      file = "faction_mordor.json"},
    {label = "Militia",     file = "faction_militia.json"},
    {label = "Goblins",     file = "faction_goblin.json"},
    {label = "Lizardfolk",  file = "faction_lizardfolk.json"},
    {label = "Ponies",      file = "faction_pony.json"},
    {label = "Dragon",      file = "faction_dragon.json"},
    {label = "Bestiary",    file = "faction_bestiary.json"},
}

-- Packets live in several files; they are merged into one id -> packet map.
local PACKET_FILES = {
    "packets_generic.json",
    "packets.json",
    "packets_family.json",
    "packets_bestiary.json",
}

local library = {
    packets = nil,      -- id -> packet object
    traits = nil,       -- id -> trait object
    units = {},         -- the currently listed faction's units
    factionLabel = "",
    factionIndex = 1,
    status = "",
    busy = false,
}

-- refreshAll is already in scope here, so the panel just rebuilds with the HUD.

local function librarySetStatus(text, player)
    library.status = tostring(text or "")
    refreshAll()
    if player ~= nil and text ~= nil and text ~= "" then notify(player, "CUS Library: " .. text) end
end

local function libraryGet(file, onDecoded, onFailed)
    local url = LIBRARY_BASE .. file
    WebRequest.get(url, function(request)
        if request.is_error or request.response_code ~= 200 then
            if onFailed ~= nil then
                onFailed(tostring(request.error or ("HTTP " .. tostring(request.response_code))))
            end
            return
        end
        local ok, decoded = pcall(JSON.decode, request.text)
        if not ok or type(decoded) ~= "table" then
            if onFailed ~= nil then onFailed(file .. " is not valid JSON.") end
            return
        end
        onDecoded(decoded)
    end)
end

-- Merge every packets array we can find in a decoded file into the id map.
local function libraryAbsorbPackets(decoded)
    if type(decoded) ~= "table" then return end
    if type(decoded.packets) == "table" then
        for _, packet in ipairs(decoded.packets) do
            if type(packet) == "table" and packet.packet_id ~= nil then
                library.packets[tostring(packet.packet_id)] = packet
            end
        end
    end
    -- Faction files may carry their own packets inline on the unit list's file.
    if type(decoded.units) == "table" then
        for _, unit in ipairs(decoded.units) do
            if type(unit) == "table" and type(unit.packets) == "table" then
                for _, packet in ipairs(unit.packets) do
                    if type(packet) == "table" and packet.packet_id ~= nil then
                        library.packets[tostring(packet.packet_id)] = packet
                    end
                end
            end
        end
    end
end

local function libraryEnsureDefinitions(done, player)
    if library.packets ~= nil and library.traits ~= nil then
        done()
        return
    end

    library.packets = library.packets or {}
    library.traits = library.traits or {}

    local remaining = #PACKET_FILES + 1
    local failed = false

    local function step()
        remaining = remaining - 1
        if remaining <= 0 and not failed then done() end
    end

    libraryGet("traits.json", function(decoded)
        if type(decoded.traits) == "table" then
            for _, trait in ipairs(decoded.traits) do
                if type(trait) == "table" and trait.trait_id ~= nil then
                    library.traits[tostring(trait.trait_id)] = trait
                end
            end
        end
        step()
    end, function(err)
        failed = true
        library.busy = false
        librarySetStatus("traits.json failed — " .. err, player)
    end)

    for _, file in ipairs(PACKET_FILES) do
        libraryGet(file, function(decoded)
            libraryAbsorbPackets(decoded)
            step()
        end, function(err)
            -- A missing packet file is survivable; the units that need it will
            -- simply come through with fewer packets.
            step()
        end)
    end
end

local function libraryLoadFaction(index, player)
    local entry = LIBRARY_FILES[index]
    if entry == nil then return end

    library.factionIndex = index
    library.busy = true
    librarySetStatus("loading " .. entry.label .. "…")

    libraryEnsureDefinitions(function()
        libraryGet(entry.file, function(decoded)
            local units = {}
            if type(decoded.units) == "table" then
                for _, unit in ipairs(decoded.units) do
                    if type(unit) == "table" and unit.name ~= nil then
                        table.insert(units, unit)
                    end
                end
            end
            libraryAbsorbPackets(decoded)
            library.units = units
            library.factionLabel = tostring(decoded.faction or entry.label)
            library.busy = false
            librarySetStatus(#units .. " profiles — pick one")
        end, function(err)
            library.busy = false
            librarySetStatus(entry.file .. " failed — " .. err, player)
        end)
    end, player)
end

-- Turn a library unit (which references packets/traits by ID) into a complete
-- definition the tracker can normalize.
local function libraryBuildDefinition(unit)
    local built = copyTable(unit)

    local resolvedPackets = {}
    if type(unit.packets) == "table" then
        for _, reference in ipairs(unit.packets) do
            if type(reference) == "table" then
                table.insert(resolvedPackets, copyTable(reference))
            else
                local found = library.packets[tostring(reference)]
                if found ~= nil then
                    table.insert(resolvedPackets, copyTable(found))
                else
                    table.insert(resolvedPackets, {packet_id = tostring(reference), name = tostring(reference)})
                end
            end
        end
    end
    built.packets = resolvedPackets

    local resolvedTraits = {}
    if type(unit.traits) == "table" then
        for _, reference in ipairs(unit.traits) do
            if type(reference) == "table" then
                table.insert(resolvedTraits, copyTable(reference))
            else
                local found = library.traits[tostring(reference)]
                if found ~= nil then
                    table.insert(resolvedTraits, copyTable(found))
                else
                    table.insert(resolvedTraits, {trait_id = tostring(reference), name = tostring(reference)})
                end
            end
        end
    end
    built.traits = resolvedTraits

    return built
end

local function libraryPick(index, player)
    local unit = library.units[index]
    if unit == nil then return end

    local built = libraryBuildDefinition(unit)
    local ok, encoded = pcall(JSON.encode, built)
    if not ok or type(encoded) ~= "string" then
        notify(player, "CUS Library: could not encode " .. tostring(unit.name), {1.00, 0.35, 0.35})
        return
    end

    runtime.definition_json = encoded
    self.memo = encoded
    if self.setGMNotes then pcall(function() self.setGMNotes("") end) end

    -- A different figure entirely, so its pools start full.
    runtime.loaded_definition_id = nil
    runtime.current_wounds = nil
    runtime.current_ap = nil
    runtime.current_reactions = nil

    loadDefinition(player, false)
    runtime.library_open = false
    refreshAll()
    notify(player, "Stamped: " .. tostring(unit.name) .. " (" .. library.factionLabel .. ")", {0.40, 0.90, 0.55})
end

buildLibraryPanelXml = function(position, panelScale, accent)
    if runtime.library_open ~= true then return "" end

    local tabs = {}
    for index, entry in ipairs(LIBRARY_FILES) do
        local on = index == library.factionIndex
        local hex = on and accent or "2A3442"
        tabs[#tabs + 1] = [[<Button id="cus-lib-fac-]] .. index .. [[" onClick="cusUiClick" text="]] .. xmlEscape(entry.label)
            .. [[" width="74" height="20" fontSize="9" colors="#]] .. hex .. [[AA|#]] .. hex .. [[EE|#]] .. hex .. [[77|#]] .. hex .. [[AA" />]]
    end

    local rows = {}
    for index, unit in ipairs(library.units) do
        local stats = type(unit.stats) == "table" and unit.stats or {}
        local meta = table.concat({
            tostring(unit.role or "—"),
            tostring(unit.tool or "—"),
            "W" .. tostring(stats.max_wounds or "?"),
            tostring(stats.armour or "—"),
        }, " · ")
        rows[#rows + 1] = [[<Button id="cus-lib-unit-]] .. index .. [[" onClick="cusUiClick" text="]]
            .. xmlEscape(tostring(unit.name) .. "   —   " .. meta)
            .. [[" width="330" height="22" fontSize="11" alignment="MiddleLeft" colors="#1B2430FF|#2C3B4EFF|#141C26FF|#1B2430FF" />]]
    end
    if #rows == 0 then
        rows[1] = [[<Text text="]] .. xmlEscape(library.busy and "Loading…" or "No profiles loaded.") .. [[" width="330" height="22" fontSize="11" color="#9AA6B2" />]]
    end

    local listHeight = math.max(66, math.min(#rows * 24, 260))
    return [[
<Panel position="]] .. position .. [[" width="360" height="]] .. (listHeight + 92) .. [[" rotation="0 0 ]] .. tostring(runtime.ui_rotation) .. [[" scale="]] .. panelScale .. [[" offsetXY="0 -200" color="#11151CF2" outline="#]] .. accent .. [[" outlineSize="2 2">
    <VerticalLayout spacing="4" padding="6 6 6 6" childAlignment="UpperCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="348" height="]] .. (listHeight + 80) .. [[">
        <HorizontalLayout spacing="3" padding="0 0 0 0" childAlignment="MiddleCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="344" height="22">
            <Text text="UNIT LIBRARY" width="180" height="20" fontSize="12" color="#F2F4F8" alignment="MiddleLeft" />
            <Button id="cus-lib-reload" onClick="cusUiClick" text="RELOAD" width="60" height="20" fontSize="9" />
            <Button id="cus-lib-close" onClick="cusUiClick" text="✕" width="26" height="20" fontSize="12" colors="#EF5B5B99|#EF5B5BCC|#EF5B5B77|#EF5B5B99" />
        </HorizontalLayout>
        <HorizontalLayout spacing="2" padding="0 0 0 0" childAlignment="MiddleCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="344" height="22">]]
            .. table.concat(tabs, "") .. [[</HorizontalLayout>
        <Text text="]] .. xmlEscape(library.status) .. [[" width="344" height="16" fontSize="10" color="#9AA6B2" alignment="MiddleLeft" />
        <VerticalScrollView width="344" height="]] .. listHeight .. [[" color="#0C1118C0">
            <VerticalLayout spacing="2" padding="2 2 2 2" childAlignment="UpperCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="336" height="]] .. (#rows * 24 + 6) .. [[">]]
                .. table.concat(rows, "") .. [[</VerticalLayout>
        </VerticalScrollView>
    </VerticalLayout>
</Panel>]]
end

local function contextLibrary(playerColor)
    runtime.library_open = not runtime.library_open
    if runtime.library_open and #library.units == 0 then
        libraryLoadFaction(library.factionIndex, playerColor)
    else
        refreshAll()
    end
end

-- cusUiClick is defined earlier in the file than this block, so the library
-- entry points are exposed as globals for it to reach.
function CUS_LibraryPick(index, player)
    if index ~= nil then libraryPick(index, player) end
end

function CUS_LibraryFaction(index, player)
    if index ~= nil then libraryLoadFaction(index, player) end
end

function CUS_LibraryReload(player)
    library.packets = nil
    library.traits = nil
    library.units = {}
    libraryLoadFaction(library.factionIndex, player)
end

function CUS_LibraryOpen(params)
    runtime.library_open = true
    if #library.units == 0 then
        libraryLoadFaction(library.factionIndex, params and params.player_color or nil)
    else
        refreshAll()
    end
end


local function contextAttack(playerColor)
    local ok, started = pcall(function()
        return Global.call("CUS_BeginAttack", {
            player_color = playerColor,
            attacker_guid = self.getGUID(),
        })
    end)

    if not ok or started ~= true then
        notify(playerColor, "CUS Attack Controller is not installed in Global.lua.", {1.00, 0.35, 0.35})
    end
end

local function setupContextMenu()
    self.clearContextMenu()

    -- Keep this deliberately short. Everything else lives in the two compact
    -- object-attached panels so TTS's own context menu stays usable.
    self.addContextMenuItem("CUS: Unit Library", contextLibrary)
    self.addContextMenuItem("CUS: Attack", contextAttack)
    self.addContextMenuItem("CUS: Controls", contextOverlayControls)
    self.addContextMenuItem("CUS: Movement", contextMovementControls)
    self.addContextMenuItem("CUS: New Round", contextNewRound)
    self.addContextMenuItem("CUS: Unit JSON", contextEditJson)
    self.addContextMenuItem("CUS: Hide / Show HUD", contextToggleUI)
end

function CUS_GetDefinition() return copyTable(definition) end
function CUS_GetDefinitionJSON()
    -- Cross-script calls should use this JSON bridge. Returning a Lua table
    -- directly leaves it owned by this object's script sandbox.
    return JSON.encode(definition)
end
function CUS_GetRuntime() return copyTable(runtime) end
function CUS_NewRound(params)
    local player = params and params.player_color or nil
    newRound(player)
end
function CUS_SetRuntime(params)
    if type(params) ~= "table" then return false end
    for key, value in pairs(params) do runtime[key] = value end
    initializeRuntime()
    refreshAll()
    return true
end
function CUS_SetTurnState(params)
    local requested = type(params) == "table" and params.state or params
    if requested ~= "Unactivated" and requested ~= "Waiting" and requested ~= "Activated" then return false end
    runtime.turn_state = requested
    synchronizeTurnFlags()
    refreshAll()
    return true
end

function CUS_StartMovement(params)
    startMovementPath(params and params.player_color or nil)
    refreshAll()
end

function CUS_AddWaypoint(params)
    addMovementWaypoint(params and params.player_color or nil)
    refreshAll()
end

function CUS_FinishMovement(params)
    finishMovementPath(params and params.player_color or nil)
    refreshAll()
end

function CUS_ClearMovement()
    clearMovementPath(true)
    refreshAll()
end

function CUS_SetAura(params)
    if type(params) ~= "table" then return false end
    local radius = asNumber(params.radius, nil)
    if radius == nil then return false end
    runtime.aura_radius = clamp(radius, 0, AURA_MAX_RADIUS)
    runtime.aura_visible = params.visible ~= false and runtime.aura_radius > 0
    refreshAll()
    return true
end

function CUS_ClearAura()
    runtime.aura_radius = 0
    runtime.aura_visible = false
    refreshAll()
end

function onPickUp(playerColor)
    if runtime.move_active then
        runtime.move_endpoint = currentMovePoint()
        refreshMovementLines()
    end
end

function onDrop(playerColor)
    if runtime.move_active then
        runtime.move_endpoint = currentMovePoint()
    end
    refreshMovementLines()
    refreshMovementDistanceText()
end

function onUpdate()
    local hasRoute = type(runtime.move_points) == "table" and #runtime.move_points > 0
    if not hasRoute then return end

    movementFrameCounter = movementFrameCounter + 1
    if movementFrameCounter < MOVE_SAMPLE_FRAMES then return end
    movementFrameCounter = 0

    if runtime.move_active and self.held_by_color ~= nil then
        runtime.move_endpoint = currentMovePoint()
    end

    -- Recalculate local coordinates as the miniature moves/rotates so the path
    -- remains fixed on the battlefield instead of travelling with the model.
    refreshMovementLines()
end

function onLoad(savedData)
    runtime = {}
    if savedData ~= nil and savedData ~= "" then
        local ok, saved = pcall(JSON.decode, savedData)
        if ok and type(saved) == "table" then runtime = saved.runtime or saved end
    end
    loadDefinition(nil, false)
    installCustomAssets()
    setupContextMenu()
    refreshAll()
end

function onSave()
    return JSON.encode({version = VERSION, runtime = runtime})
end
