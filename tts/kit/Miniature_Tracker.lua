--[[
CUS MINIATURE TRACKER v5.0
Standalone Tabletop Simulator Object script.

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

local VERSION = "5.1"

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
    reactions = 1,
    nerve = "—",
    rank = "—",
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
    hybrid  = "B784FF",   -- v0.6: the Tool set is Melee · Ranged · Hybrid (B·1).
    utility = "B784FF",   -- retired: Utility is a ROLE, not a Tool. Kept so old JSON still colours.
}

-- CUS v0.6 (B.10, SIGNED): the morale track is Steady -> Shaken -> Broken.
-- "Routed" was the v0.5 name for the third state; it is migrated on load.
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
local ICON_BASE = "https://raw.githubusercontent.com/whbreifcase-arch/cus-kernel-rebuild/main/tts/icons/"

local ICON_ASSETS = {
    -- Square badges for the action row.
    action_act   = ICON_BASE .. "act.png",
    action_move  = ICON_BASE .. "move.png",
    action_wait  = ICON_BASE .. "wait2.png",

    -- Triangles for the activation state. Point up = still has its turn.
    activation_unactivated = ICON_BASE .. "unactivated.png",   -- green, up
    activation_waiting     = ICON_BASE .. "wait.png",          -- armed
    activation_activated   = ICON_BASE .. "activated.png",     -- bronze, spent
    activation_ready       = ICON_BASE .. "wait.png",          -- retired v0.5 key

    -- Not drawn yet; leave empty and the glyph fallback is used.
    heart_full = "",
    heart_empty = "",
    armour_light = "",
    armour_medium = "",
    armour_heavy = "",
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

-- NOTE the ordering. `&` is escaped FIRST, so a tooltip written with a literal
-- "&#10;" would come out as "&amp;#10;" and display as visible garbage. Write
-- tooltips with a real newline instead; the newline is converted to the entity
-- LAST, after the & pass. This now matches Global.lua, which already did it
-- correctly — the two files used to disagree.
local function xmlEscape(value)
    local text = tostring(value or "")
    text = text:gsub("&", "&amp;")
    text = text:gsub("<", "&lt;")
    text = text:gsub(">", "&gt;")
    text = text:gsub('"', "&quot;")
    text = text:gsub("'", "&apos;")
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
        -- counter_uses deleted: the counter_x economy is retired (B·9).
        -- Reaction is the only cap now.
        points = first(root.points, DEFAULTS.points),

        wounds = asNumber(first(stats.max_wounds, stats.wounds, root.max_wounds, root.wounds), DEFAULTS.wounds),
        ap = asNumber(first(stats.max_ap, stats.ap, root.max_ap, root.ap), DEFAULTS.ap),
        speed = first(stats.speed, root.speed, DEFAULTS.speed),
        -- `rank` was the v0.5 name for the Nerve stat, so it is read as a
        -- FALLBACK ONLY. This order is load-bearing: library_generic.json
        -- carries BOTH stats.nerve AND a "rank":"I" field, where rank means the
        -- unit's tier, not its Nerve. stats.nerve must win, or every generic
        -- profile is corrupted.
        nerve = first(stats.nerve, root.nerve, root.rank, stats.rank, DEFAULTS.nerve),
        rank = first(root.tier, root.rank, stats.rank, DEFAULTS.rank),

        -- REACTION (A.IV). No library JSON carries this yet, so the shape
        -- default is what will actually fire: a Champion answers twice (B.12).
        reactions = asNumber(first(stats.reactions, root.reactions),
                             (first(baseObject.shape, baseObject.type) == "Circle") and 2 or 1),
        armour = normalizeArmour(first(stats.armour, stats.armor, display.armour, display.armor, DEFAULTS.armour)),

        weapon = first(packetWeapon, display.weapon, root.weapon, DEFAULTS.weapon),
        dice = first(packetDice, display.dice, root.dice, DEFAULTS.dice),
        hit = threshold(first(packetHit, display.hit, root.hit, DEFAULTS.hit)),
        -- Ladder / Tiers / Rungs became Success Grade (A·VI). Old keys are
        -- read as fallbacks so existing unit files still display.
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
    -- Retired v0.5 names are migrated FIRST, before anything validates against
    -- the allowed lists. Otherwise a figure saved as "Readied" or "Routed"
    -- fails validation and silently resets to the default state.
    if runtime.turn_state == "Readied" then runtime.turn_state = "Waiting" end
    if NERVE_MIGRATE[runtime.nerve_state] ~= nil then
        runtime.nerve_state = NERVE_MIGRATE[runtime.nerve_state]
    end

    runtime.current_wounds = asNumber(runtime.current_wounds, definition.wounds)
    runtime.current_ap = asNumber(runtime.current_ap, definition.ap)
    runtime.nerve_state = first(runtime.nerve_state, "Steady")

    -- REACTION is its own Kernel Resource (A.IV): what a figure may spend
    -- during SOMEONE ELSE'S activation. It is never paid out of AP and the two
    -- pools never exchange. Every triggered PACKET — a Counter, a Shield
    -- intercept, a Reach strike, a firing Overwatch — costs 1 Reaction. When
    -- the pool is empty the figure cannot respond at all. That is the only cap.
    runtime.current_reactions = asNumber(runtime.current_reactions, definition.reactions)

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

    runtime.current_reactions = clamp(math.floor(asNumber(runtime.current_reactions, definition.reactions)),
                                      0, definition.reactions)

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
        return {asset = "nerve_breaking", glyph = "◆", fg = HEX.red, tooltip = "Nerve: Breaking / Routed. Left click: worsen. Right click: improve."}
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

local function buildHeartsXml()
    local maximum = math.max(0, tonumber(definition.wounds) or 0)
    local current = math.max(0, tonumber(runtime.current_wounds) or 0)
    if maximum <= 0 then
        return [[<Panel width="28" height="28">
            <Text text="☠" width="28" height="28" fontSize="22" color="#]] .. HEX.red .. [[" alignment="MiddleCenter" />
            ]] .. transparentButton("cus-heart-0", "No wounds remaining. Right click to heal.", 28, 28) .. [[
        </Panel>]], 28
    end

    if maximum > 8 then
        local txt = tostring(current) .. "/" .. tostring(maximum)
        return [[<Panel width="62" height="28">
            <Text text="♥" width="24" height="28" fontSize="22" color="#]] .. woundsColor() .. [[" alignment="MiddleLeft" />
            <Text text="]] .. xmlEscape(txt) .. [[" width="40" height="28" fontSize="13" color="#F2F4F8" alignment="MiddleRight" />
            ]] .. transparentButton("cus-heart-1", "Wounds. Left click: lose 1. Right click: heal 1.", 62, 28) .. [[
        </Panel>]], 62
    end

    local parts = {}
    local totalWidth = 0
    for i = 1, maximum do
        local filled = i <= current
        local asset = filled and "heart_full" or "heart_empty"
        local heartColor = filled and HEX.red or "181A1F"
        if assetEnabled(asset) then
            parts[#parts + 1] = [[<Panel width="28" height="28">
                <Image image="]] .. asset .. [[" width="27" height="27" preserveAspect="true" />
                ]] .. transparentButton("cus-heart-" .. i, "Wounds. Left click: lose 1. Right click: heal 1.", 28, 28) .. [[
            </Panel>]]
        else
            parts[#parts + 1] = [[<Panel width="28" height="28">
                <Text text="♥" width="28" height="28" fontSize="24" color="#]] .. heartColor .. [[" alignment="MiddleCenter" />
                ]] .. transparentButton("cus-heart-" .. i, "Wounds. Left click: lose 1. Right click: heal 1.", 28, 28) .. [[
            </Panel>]]
        end
        totalWidth = totalWidth + 28
        if i < maximum then totalWidth = totalWidth + 1 end
    end
    return table.concat(parts), totalWidth
end


-- ---------------------------------------------------------------------------
-- HUD builders (spec §7)
--
-- §5.3: TTS layout groups FORCE-EXPAND their children by default. A Panel
-- holding Text + Button, nested two layouts deep, collapses to nothing — that
-- is why the pips were invisible and why buttons flew out of the panel. Every
-- layout below therefore sets childForceExpandWidth/Height="false", and every
-- clickable element is a plain <Button>, never a Panel wrapping a Text.
-- ---------------------------------------------------------------------------

-- A vertical column of pips, filled BOTTOM-UP so the top pip is the last one
-- spent. Reaction and AP get separate columns on purpose: the two pools never
-- exchange (A.IV), and one shared bar would imply a conversion that does not exist.
local function buildPipColumn(idPrefix, current, maximum, filledHex, label)
    maximum = math.max(0, math.floor(tonumber(maximum) or 0))
    current = clamp(math.floor(tonumber(current) or 0), 0, maximum)
    if maximum <= 0 then return "", 0 end

    local parts = {}
    if maximum > 6 then
        parts[#parts+1] = '<Button id="' .. idPrefix .. '1" onClick="cusUiClick" text="' ..
            current .. "/" .. maximum ..
            '" width="30" height="16" preferredWidth="30" preferredHeight="16" fontSize="11" colors="#11111100|#FFFFFF14|#FFFFFF0A|#11111100" textColor="#' ..
            filledHex .. '" tooltip="' .. xmlEscape(label .. "\nLeft: spend 1\nRight: restore 1") .. '" />'
    else
        for i = 1, maximum do
            -- i counts from the TOP; a pip is filled once it is below the spent band.
            local filled = i > (maximum - current)
            parts[#parts+1] = '<Button id="' .. idPrefix .. i .. '" onClick="cusUiClick" text="' ..
                (filled and "●" or "○") ..
                '" width="18" height="16" preferredWidth="18" preferredHeight="16" fontSize="15" colors="#11111100|#FFFFFF14|#FFFFFF0A|#11111100" textColor="#' ..
                (filled and filledHex or "55637A") .. '" tooltip="' ..
                xmlEscape(label .. "\nLeft: spend 1\nRight: restore 1") .. '" />'
        end
    end

    -- preferredWidth/Height are REQUIRED, not decoration. A Unity layout group
    -- reads `preferredHeight` from its children and ignores `height` entirely,
    -- so a child carrying only `height` collapses to zero once its parent has
    -- childForceExpandHeight="false". That is what made the wound badge, the
    -- activation triangle and the whole action row invisible.
    local h = tostring(math.max(18, math.min(maximum, 6) * 17 + 2))
    return [[<VerticalLayout spacing="1" childAlignment="LowerCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="26" height="]] ..
        h .. [[" preferredWidth="26" preferredHeight="]] .. h .. [[">]] ..
        table.concat(parts) .. [[</VerticalLayout>]], 26
end

-- ONE heart carrying the number. Wounds are 1-2 as standard (B.7), so a row of
-- hearts is noise. Skull at zero.
local function buildWoundBadge()
    local maximum = math.max(0, tonumber(definition.wounds) or 0)
    local current = clamp(math.floor(tonumber(runtime.current_wounds) or 0), 0, maximum)
    local glyph = (current <= 0) and "☠" or "♥"
    local tint  = (current <= 0) and HEX.red or woundsColor()
    local text  = (current <= 0) and glyph or (glyph .. " " .. tostring(current))
    return '<Button id="cus-heart-1" onClick="cusUiClick" text="' .. text ..
        '" width="46" height="30" preferredWidth="46" preferredHeight="30" fontSize="20" colors="#11111100|#FFFFFF14|#FFFFFF0A|#11111100" textColor="#' ..
        tint .. '" tooltip="' .. xmlEscape("Wounds " .. current .. "/" .. maximum ..
        "\nLeft: lose 1\nRight: heal 1") .. '" />', 46
end

-- One triangle. Point UP = still has its turn, point DOWN = spent.
-- Uses the painted badge when its asset is installed, and falls back to the
-- glyph when it is not, so the HUD still works with no network.
local function buildActivationBadge()
    local glyph, tint, word, asset
    if runtime.turn_state == "Activated" then
        glyph, tint, word, asset = "▽", HEX.grey, "Activated", "activation_activated"
    elseif runtime.turn_state == "Waiting" then
        glyph, tint, word, asset = "▲", HEX.purple, "Waiting (armed)", "activation_waiting"
    else
        glyph, tint, word, asset = "△", HEX.gold, "Unactivated", "activation_unactivated"
    end
    local tip = xmlEscape("Activation: " .. word .. "\nLeft: next state\nRight: previous")

    if assetEnabled(asset) then
        return '<Panel width="34" height="32" preferredWidth="34" preferredHeight="32">' ..
            '<Image image="' .. asset .. '" width="32" height="32" preferredWidth="32" preferredHeight="32" preserveAspect="true" />' ..
            '<Button id="cus-turn-state" onClick="cusUiClick" text="" width="34" height="32" preferredWidth="34" preferredHeight="32"' ..
            ' colors="#00000000|#FFFFFF18|#FFFFFF0C|#00000000" tooltip="' .. tip .. '" />' ..
            '</Panel>', 34
    end

    return '<Button id="cus-turn-state" onClick="cusUiClick" text="' .. glyph ..
        '" width="34" height="30" preferredWidth="34" preferredHeight="30" fontSize="22" colors="#11111100|#FFFFFF14|#FFFFFF0A|#11111100" textColor="#' ..
        tint .. '" tooltip="' .. tip .. '" />', 34
end

local function buildNerveBadge()
    local t = nerveTokenData()
    return '<Button id="cus-nerve" onClick="cusUiClick" text="' .. t.glyph ..
        '" width="28" height="22" preferredWidth="28" preferredHeight="22" fontSize="16" colors="#11111100|#FFFFFF14|#FFFFFF0A|#11111100" textColor="#' ..
        t.fg .. '" tooltip="' .. xmlEscape(t.tooltip) .. '" />', 28
end

-- The whole core loop, permanently on the token instead of behind a right-click.
local function buildActionRow()
    -- preferredWidth/Height are required here too: this row lives inside a
    -- layout group, and a child with only width/height collapses to zero.
    local function b(id, text, tip, w)
        return '<Button id="' .. id .. '" onClick="cusUiClick" text="' .. text ..
            '" width="' .. w .. '" height="18" preferredWidth="' .. w .. '" preferredHeight="18"' ..
            ' fontSize="10" colors="#1C2733CC|#2B3D4FEE|#141C24AA|#1C2733CC" textColor="#C8D4E0" tooltip="' ..
            xmlEscape(tip) .. '" />'
    end

    -- A painted square badge when the asset is installed, text otherwise.
    local function icon(id, asset, label, tip, w)
        if not assetEnabled(asset) then return b(id, label, tip, w) end
        return '<Panel width="' .. w .. '" height="26" preferredWidth="' .. w .. '" preferredHeight="26">' ..
            '<Image image="' .. asset .. '" width="26" height="26" preferredWidth="26" preferredHeight="26" preserveAspect="true" />' ..
            '<Button id="' .. id .. '" onClick="cusUiClick" text="" width="' .. w .. '" height="26" preferredWidth="' .. w .. '" preferredHeight="26"' ..
            ' colors="#00000000|#FFFFFF18|#FFFFFF0C|#00000000" tooltip="' .. xmlEscape(tip) .. '" />' ..
            '</Panel>'
    end

    return [[<HorizontalLayout spacing="2" childAlignment="MiddleCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="146" height="28" preferredWidth="146" preferredHeight="28">]] ..
        icon("cus-move-toggle", "action_move",
             runtime.move_panel_open and "CLOSE" or "MOVE",
             "MOVE - open the movement ruler and start tracking", 30) ..
        -- ACT, not ATK: ATTACK is a retired verb (D.1). Everything a figure
        -- does to someone else resolves a PACKET under ACTION.
        icon("cus-act-attack", "action_act", "ACT",
             "ACT - choose one of your packets, then a target", 30) ..
        icon("cus-act-wait", "action_wait", "WAIT",
             "WAIT - spend 1 AP to arm a packet. It still costs 1 Reaction when it fires.", 30) ..
        b("cus-new-round",   "↻",    "Refresh AP + Reaction, clear the armed WAIT", 26) ..
        [[</HorizontalLayout>]]
end

local function buildAPPipsXml()
    local maximum = math.max(0, tonumber(definition.ap) or 0)
    local current = math.max(0, tonumber(runtime.current_ap) or 0)
    if maximum <= 0 then
        return "", 0
    end

    if maximum > 8 then
        local txt = string.format("%d/%d", current, maximum)
        return [[<Button id="cus-ap-pips" onClick="cusUiClick" text="]] .. xmlEscape(txt) .. [[" width="46" height="16" preferredWidth="46" preferredHeight="16" fontSize="11" colors="#11111100|#11111100|#11111100|#11111100" textColor="#]] .. HEX.blue .. [[" tooltip="AP&#10;Left: spend 1&#10;Right: restore 1" />]], 46
    end

    local parts = {}
    local totalWidth = 0
    for i = 1, maximum do
        local filled = i <= current
        local pipColor = filled and HEX.blue or "273546"
        parts[#parts+1] = [[<Button id="cus-ap-pip-]] .. i .. [[" onClick="cusUiClick" text="●" width="12" height="14" preferredWidth="12" preferredHeight="14" fontSize="14" colors="#11111100|#11111100|#11111100|#11111100" textColor="#]] .. pipColor .. [[" tooltip="AP&#10;Left: spend 1&#10;Right: restore 1" />]]
        totalWidth = totalWidth + 12
        if i < maximum then totalWidth = totalWidth + 2 end
    end
    return table.concat(parts), totalWidth
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

    -- CUS v0.6 (B.1, SIGNED): THREE size classes, read from the footprint.
    --   Square: Small 20mm, Medium 25mm, Large 40mm
    --   Circle: Small 25mm, Medium 32mm, Large 40mm
    -- There is no Monstrous class (a monster is Large + the unstoppable trait)
    -- and no Cavalry class (mounted is elongated GEOMETRY, not a size). The
    -- retired v0.5 names are still accepted so older JSON keeps working.
    if class == "small" then
        diameterMm = shape == "circle" and 25 or 20
    elseif class == "medium" or class == "normal" then
        diameterMm = shape == "circle" and 32 or 25
    elseif class == "large" or class == "monstrous" then
        diameterMm = 40
    elseif class == "cavalry" then
        diameterMm = 40                      -- retired v0.5 class
    end

    -- Mounted is elongated geometry on top of whatever class the figure is.
    -- Use the longer dimension so the ring stays conservative.
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

-- CHARGE THRESHOLD (B.3): a Sprint becomes a charge when it covers 3" of
-- UNINTERRUPTED STRAIGHT run-up into contact.
--
-- Only the FINAL LEG counts — the distance from the last committed waypoint to
-- the current endpoint. A path with a waypoint in it has turned, and a run-up
-- has to be straight, so the earlier legs are irrelevant.
--
-- The ruler reports geometry and nothing else. Whether contact was actually
-- made, and whether the run-up was interrupted, stays with the players (B.3).
local CHARGE_RUNUP_INCHES = 3.0

local function finalLegDistance()
    local points = runtime.move_points or {}
    local last = points[#points]
    local endpoint = runtime.move_endpoint
    if last == nil or endpoint == nil then return 0 end
    return horizontalDistance(last, endpoint)
end

local function chargeLabel()
    local runup = finalLegDistance()
    if runup >= CHARGE_RUNUP_INCHES - 0.001 then
        return string.format('   CHARGE %.1f\"', runup)
    end
    return string.format('   run-up %.1f\"/%d\"', runup, CHARGE_RUNUP_INCHES)
end

local function hasCharge()
    return finalLegDistance() >= CHARGE_RUNUP_INCHES - 0.001
end

local function movementDistanceLabel()
    local total = movementDistance()
    local speed = movementSpeed()
    local prefix = runtime.move_active and "TRACKING  " or "MOVE  "
    local charge = (total > 0.05) and chargeLabel() or ""
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
    -- The old row-of-hearts / token-panel builders are superseded by the §7
    -- column layout below (buildPipColumn, buildWoundBadge, buildActivationBadge).
    -- Armour is no longer a HUD badge; it lives in the description text.
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
<Panel position="]] .. position .. [[" width="300" height="84" rotation="0 0 ]] .. tostring(runtime.ui_rotation) .. [[" scale="]] .. panelScale .. [[" offsetXY="195 36" color="#11151CDD" outline="#]] .. moveOutline .. [[" outlineSize="2 2">
    <VerticalLayout spacing="3" childAlignment="MiddleCenter" width="292" height="76" childForceExpandWidth="false" childForceExpandHeight="false" padding="3 3 3 3">
        <Text id="cus-move-distance" text="]] .. xmlEscape(movementDistanceLabel()) .. [[" width="284" height="36" preferredWidth="284" preferredHeight="36" fontSize="12" color="#]] .. (movementOverLimit() and HEX.red or HEX.white) .. [[" alignment="MiddleCenter" />
        <HorizontalLayout spacing="4" childAlignment="MiddleCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="284" height="26" preferredWidth="284" preferredHeight="26">
            <Button id="cus-move-start" onClick="cusUiClick" text="]] .. moveStartText .. [[" width="58" height="24" preferredWidth="58" preferredHeight="24" fontSize="10" />
            <Button id="cus-move-waypoint" onClick="cusUiClick" text="+ WP" width="52" height="24" preferredWidth="52" preferredHeight="24" fontSize="11" colors="#]] .. accent .. [[AA|#]] .. accent .. [[DD|#]] .. accent .. [[88|#]] .. accent .. [[AA" />
            <Button id="cus-move-undo" onClick="cusUiClick" text="UNDO" width="48" height="24" preferredWidth="48" preferredHeight="24" fontSize="10" />
            <Button id="cus-move-finish" onClick="cusUiClick" text="DONE" width="52" height="24" preferredWidth="52" preferredHeight="24" fontSize="10" />
            <Button id="cus-move-clear" onClick="cusUiClick" text="CLOSE" width="56" height="24" preferredWidth="56" preferredHeight="24" fontSize="10" colors="#]] .. HEX.red .. [[99|#]] .. HEX.red .. [[CC|#]] .. HEX.red .. [[77|#]] .. HEX.red .. [[99" />
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

    -- ---- spec §7 layout -------------------------------------------------
    --    [gold]   [blue]    [heart]   [triangle]
    --   REACTION    AP      WOUNDS    ACTIVATION
    --      ●        ●        ♥ 2          △
    --      ●        ●                     ⏻
    --      ○        ●
    --             MOVE  ATK  WAIT  ↻
    local rxXml   = buildPipColumn("cus-rx-pip-", runtime.current_reactions, definition.reactions, HEX.gold, "Reaction")
    local apCol   = buildPipColumn("cus-ap-pip-", runtime.current_ap, definition.ap, HEX.blue, "AP")
    local woundXml  = buildWoundBadge()
    local activXml  = buildActivationBadge()
    local nerveBadge = buildNerveBadge()
    local actionRow = buildActionRow()

    -- Panel height follows the TALLER column, so a 2 AP figure does not
    -- reserve room for six pips.
    local tallest = math.max(math.min(definition.reactions or 1, 6), math.min(definition.ap or 2, 6), 2)
    local colHeight = math.max(34, tallest * 17 + 2)
    local panelHeight = colHeight + 34   -- + the 28px action row and its spacing

    local xml = [[
<Defaults>
    <Button fontSize="14" textColor="#F2F4F8" colors="#00000000|#FFFFFF12|#FFFFFF08|#00000000" />
    <Text color="#F2F4F8" alignment="MiddleCenter" />
</Defaults>
<Panel position="]] .. position .. [[" width="164" height="]] .. panelHeight .. [[" rotation="0 0 ]] .. tostring(runtime.ui_rotation) .. [[" scale="]] .. panelScale .. [[" color="#00000000">
    <VerticalLayout spacing="2" childAlignment="MiddleCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="164" height="]] .. panelHeight .. [[">
        <HorizontalLayout spacing="6" childAlignment="LowerCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="164" height="]] .. colHeight .. [[" preferredWidth="164" preferredHeight="]] .. colHeight .. [[">
            ]] .. rxXml .. apCol .. woundXml .. [[
            <VerticalLayout spacing="1" childAlignment="MiddleCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="36" height="]] .. colHeight .. [[" preferredWidth="36" preferredHeight="]] .. colHeight .. [[">
                ]] .. activXml .. nerveBadge .. [[
            </VerticalLayout>
        </HorizontalLayout>
        ]] .. actionRow .. [[
    </VerticalLayout>
</Panel>]] .. moveXml .. configXml
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

-- REACTION is spent on SOMEONE ELSE'S turn (A.IV). Hitting zero is the single
-- most-forgotten state in the game, so say it loudly rather than quietly
-- letting a player Counter with a pool they no longer have.
local function changeReactions(amount, player)
    local before = runtime.current_reactions
    runtime.current_reactions = clamp(runtime.current_reactions + amount, 0, definition.reactions)
    refreshAll()

    if runtime.current_reactions <= 0 and before > 0 then
        notify(player, definition.name ..
            " has NO REACTION left — it cannot Counter, intercept, or fire an armed WAIT.",
            {1.00, 0.45, 0.35})
    else
        notify(player, definition.name .. " has " .. runtime.current_reactions ..
            "/" .. definition.reactions .. " Reaction.")
    end
end

local function changeNerve(direction, player)
    runtime.nerve_state = stepState(NERVE_STATES, runtime.nerve_state, direction)
    refreshAll()
    notify(player, definition.name .. " is " .. runtime.nerve_state .. ".")
end

local function changeTurnState(direction, player)
    runtime.turn_state = stepState(TURN_STATES, runtime.turn_state, direction)
    synchronizeTurnFlags()
    refreshAll()
    notify(player, definition.name .. " is " .. runtime.turn_state .. ".")
end

-- Per B.12 a figure refreshes AP + Reaction and expires its armed WAIT at the
-- start of ITS OWN activation, not at the top of the round. So this button is
-- "my activation begins", pressed by the figure's own player — it deliberately
-- does not refill anybody else. A figure that emptied its Reaction pool late
-- last round walks into this one still empty until it activates. That is the
-- point: hit the tired ones.
local function newRound(player)
    clearMovementPath(true)
    runtime.current_ap = definition.ap
    runtime.current_reactions = definition.reactions
    runtime.armed_packet = nil
    runtime.turn_state = "Unactivated"
    synchronizeTurnFlags()
    refreshAll()
    notify(player, definition.name .. " refreshed: " .. definition.ap .. " AP, " ..
        definition.reactions .. " Reaction.", {0.40, 0.80, 1.00})
end

local function resetRuntime(player)
    clearMovementPath(true)
    runtime.current_wounds = definition.wounds
    runtime.current_ap = definition.ap
    runtime.current_reactions = definition.reactions
    runtime.armed_packet = nil
    runtime.nerve_state = "Steady"
    runtime.turn_state = "Unactivated"
    synchronizeTurnFlags()
    refreshAll()
    notify(player, definition.name .. " runtime state fully reset.", {0.40, 0.80, 1.00})
end

local function isRightClick(value)
    return tostring(value) == "-2"
end

local function playerColorOfClick(playerOrColor)
    if type(playerOrColor) == "string" then return playerOrColor end
    if playerOrColor ~= nil and playerOrColor.color ~= nil then return playerOrColor.color end
    return nil
end

-- WAIT (A.III): spend 1 AP NOW to arm a chosen PACKET, and it STILL costs
-- 1 Reaction when it actually fires. Arming is not permission — a figure with
-- an empty Reaction pool may arm a packet that will never resolve, and the
-- tracker says so rather than letting the player discover it mid-fight.
local function toggleWait(player)
    -- Already waiting? Cancel the state. AP is NOT refunded — it was spent.
    if runtime.turn_state == "Waiting" then
        runtime.turn_state = "Unactivated"
        runtime.armed_packet = nil
        synchronizeTurnFlags()
        refreshAll()
        notify(player, definition.name .. " cancels its WAIT. The AP is not refunded.")
        return
    end

    if (runtime.current_ap or 0) < 1 then
        notify(player, definition.name .. " has no AP to spend on WAIT.", {1.00, 0.45, 0.35})
        return
    end

    runtime.current_ap = runtime.current_ap - 1
    runtime.turn_state = "Waiting"
    runtime.armed_packet = true
    synchronizeTurnFlags()
    refreshAll()

    if (runtime.current_reactions or 0) < 1 then
        notify(player, definition.name ..
            " is WAITING, but has NO REACTION — the armed packet will not resolve.",
            {1.00, 0.45, 0.35})
    else
        notify(player, definition.name ..
            " is WAITING. 1 AP spent; firing it will also cost 1 Reaction.",
            {0.72, 0.52, 1.00})
    end
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

    if id ~= nil and string.sub(id, 1, 10) == "cus-heart-" then
        changeWounds(rightClick and 1 or -1, player)
    elseif id == "cus-wounds" then
        changeWounds(rightClick and 1 or -1, player)
    elseif id ~= nil and string.sub(id, 1, 11) == "cus-rx-pip-" then
        changeReactions(rightClick and 1 or -1, player)
    elseif id ~= nil and string.sub(id, 1, 11) == "cus-ap-pip-" then
        changeAP(rightClick and 1 or -1, player)
    elseif id == "cus-act-attack" then
        contextAttack(playerColorOfClick(player))
    elseif id == "cus-act-wait" then
        toggleWait(player)
    elseif id == "cus-ap-pips" or id == "cus-ap" or id == "cus-ap-spend" then
        changeAP(rightClick and 1 or -1, player)
    elseif id == "cus-ap-restore" then
        changeAP(rightClick and -1 or 1, player)
    elseif id == "cus-new-round" then
        newRound(player)
    elseif id == "cus-full-reset" then
        resetRuntime(player)
    elseif id == "cus-nerve" then
        changeNerve(rightClick and -1 or 1, player)
    elseif id == "cus-turn-state" then
        changeTurnState(rightClick and -1 or 1, player)
    elseif id == "cus-move-toggle" then
        -- MOVE opens the ruler AND starts tracking in one press. Opening a
        -- ruler you then have to press START on is two clicks for one intent.
        if runtime.move_panel_open then
            clearMovementPath(false)          -- false = close the panel too
        else
            startMovementPath(player)         -- sets move_panel_open = true
        end
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
    elseif id == "cus-move-clear" then
        -- false = also CLOSE the panel. Passing true wiped the path and left
        -- the panel stuck open with no way out.
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


-- ACT: choose one of this figure's packets, then a target. Global owns the
-- flow because it is the only script that can see both miniatures.
local function contextAttack(playerColor)
    local ok, started = pcall(function()
        return Global.call("CUS_BeginAction", {
            player_color = playerColor,
            attacker_guid = self.getGUID(),
        })
    end)

    -- Fall back to the retired entry point so an older Global still answers.
    if not ok or started ~= true then
        ok, started = pcall(function()
            return Global.call("CUS_BeginAttack", {
                player_color = playerColor,
                attacker_guid = self.getGUID(),
            })
        end)
    end

    if not ok or started ~= true then
        notify(playerColor, "CUS Action Controller is not installed in Global.lua.", {1.00, 0.35, 0.35})
    end
end

-- Open the Unit Library in Global, scoped to THIS miniature. Whatever unit the
-- player picks is stamped straight onto it — no card, no linking step.
local function contextLibrary(playerColor)
    local ok, opened = pcall(function()
        return Global.call("CUS_OpenLibrary", {
            player_color   = playerColor,
            miniature_guid = self.getGUID(),
        })
    end)

    if not ok or opened ~= true then
        notify(playerColor, "CUS Unit Library is not installed in Global.lua.", {1.00, 0.35, 0.35})
    end
end

local function setupContextMenu()
    self.clearContextMenu()

    -- Keep this deliberately short. Everything else lives in the two compact
    -- object-attached panels so TTS's own context menu stays usable.
    self.addContextMenuItem("CUS: Attack", contextAttack)
    self.addContextMenuItem("CUS: Unit Library", contextLibrary)
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

-- Stamp a whole unit definition onto this miniature from outside — the Unit
-- Library in Global calls this. Takes JSON, never a Lua table: a table handed
-- across scripts stays owned by the caller's sandbox and TTS refuses to let
-- this object keep it ("resources owned by different scripts").
--
-- This replaces the card-and-link flow entirely. The miniature IS the unit.
function CUS_SetDefinitionJSON(params)
    local raw = nil
    if type(params) == "table" then
        raw = params.json or params.definition_json or params.definition
    elseif type(params) == "string" then
        raw = params
    end
    if type(raw) ~= "string" or trim(raw) == "" then return false end

    local text = extractJsonObject(raw) or stripCodeFence(raw)
    if text == "" then return false end

    local ok, decoded = pcall(JSON.decode, text)
    if not ok or type(decoded) ~= "table" then return false end

    -- A new unit is a new figure: start it at full wounds and AP, unspent.
    runtime.definition_json = text
    runtime.loaded_definition_id = nil          -- forces a full stat sync
    runtime.schema_adapter_version = nil
    self.memo = text
    if self.setGMNotes then pcall(function() self.setGMNotes("") end) end

    loadDefinition(params and params.player_color or nil, false)

    runtime.current_wounds = definition.wounds
    runtime.current_ap = definition.ap
    runtime.nerve_state = "Steady"
    runtime.turn_state = "Unactivated"
    synchronizeTurnFlags()
    clearMovementPath(false)

    refreshAll()
    notify(params and params.player_color or nil,
        "Stamped " .. tostring(definition.name) .. " onto this miniature.", {0.40, 0.90, 0.55})
    return true
end
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
