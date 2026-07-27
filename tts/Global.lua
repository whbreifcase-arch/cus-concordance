--[[
CUS ATTACK CONTROLLER v6.0 — Global.lua

MVP only:
  1. Right-click a CUS miniature and choose "CUS: Attack".
  2. Click another CUS miniature as the target.
  3. Choose a rolling packet, set a manual dice modifier, and roll.
  4. Read the highest Grade reached and apply everything manually.

This controller NEVER spends AP, changes wounds, rolls armour, or applies effects.
It only reads unit definitions and rolls the packet.
--]]

local VERSION = "6.0"
local sessions = {}

local UI_WIDTH = 430
local UI_HEIGHT = 535
local MOD_MIN = -10
local MOD_MAX = 10

local COLORS = {
    panel = "#11161EEB",
    panel2 = "#1B2430F2",
    line = "#516578FF",
    text = "#F1F4F7FF",
    muted = "#9EABB8FF",
    gold = "#E6BE58FF",
    red = "#EF6666FF",
    green = "#67D77BFF",
    blue = "#61A8FFFF",
    purple = "#B78AFFFF",
    button = "#263341FF|#33465AFF|#1C2733FF|#263341FF",
    danger = "#682C34FF|#843945FF|#4E2027FF|#682C34FF",
}

local function clamp(value, minimum, maximum)
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

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

local function playerColorOf(playerOrColor)
    if type(playerOrColor) == "string" then return playerOrColor end
    if playerOrColor ~= nil and playerOrColor.color ~= nil then return playerOrColor.color end
    return nil
end

local function tell(playerOrColor, message, tint)
    local color = playerColorOf(playerOrColor)
    local rgb = tint or {0.80, 0.88, 1.00}
    if color ~= nil and Player[color] ~= nil then
        Player[color].broadcast(message, rgb)
    else
        broadcastToAll(message, rgb)
    end
end

local function safeObjectCall(object, functionName, params)
    if object == nil then return nil end
    local ok, result = pcall(function()
        if params == nil then return object.call(functionName) end
        return object.call(functionName, params)
    end)
    if not ok then return nil end
    return result
end

local function isCUSMiniature(object)
    if object == nil then return false end
    local hasTag = false
    pcall(function() hasTag = object.hasTag("CUS_MINIATURE") end)
    if hasTag then return true end

    -- Compatibility check without importing a foreign Lua table.
    local encoded = safeObjectCall(object, "CUS_GetDefinitionJSON")
    if type(encoded) ~= "string" or encoded == "" then return false end
    local ok, decoded = pcall(JSON.decode, encoded)
    return ok and type(decoded) == "table" and decoded.name ~= nil
end

local function getDefinition(object)
    -- Tables returned directly by object.call remain owned by the object's Lua
    -- sandbox. TTS will throw "resources owned by different scripts" if Global
    -- stores or mutates those foreign tables. Transfer definitions as JSON so
    -- Global receives a fresh local table owned by Global.lua.
    local encoded = safeObjectCall(object, "CUS_GetDefinitionJSON")
    if type(encoded) == "string" and encoded ~= "" then
        local ok, decoded = pcall(JSON.decode, encoded)
        if ok and type(decoded) == "table" then return decoded end
    end

    -- Backward-compatible fallback for older trackers. Re-encode immediately
    -- if TTS permits it; otherwise return nil rather than retaining a foreign
    -- script resource.
    local foreign = safeObjectCall(object, "CUS_GetDefinition")
    if type(foreign) ~= "table" then return nil end
    local okEncode, json = pcall(JSON.encode, foreign)
    if not okEncode or type(json) ~= "string" then return nil end
    local okDecode, decoded = pcall(JSON.decode, json)
    if not okDecode or type(decoded) ~= "table" then return nil end
    return decoded
end

local function rollingPackets(definition)
    local result = {}
    if type(definition) ~= "table" or type(definition.packets) ~= "table" then return result end
    for _, packet in ipairs(definition.packets) do
        local dice = tonumber(packet.dice) or 0
        local success = tonumber(packet.success) or 0
        if dice > 0 and success > 0 then
            table.insert(result, packet)
        end
    end
    return result
end

local function horizontalDistance(a, b)
    if a == nil or b == nil then return 0 end
    local pa = a.getPosition()
    local pb = b.getPosition()
    local dx = pa.x - pb.x
    local dz = pa.z - pb.z
    return math.sqrt(dx * dx + dz * dz)
end

local function formatDistance(value)
    return string.format('%.1f" center distance', tonumber(value) or 0)
end

-- v6 -----------------------------------------------------------------------
-- Base geometry, so the controller can tell BASE CONTACT from "close".
-- Canonical classes are Small · Medium · Large only (B · 1); Monstrous and
-- Cavalry are retired. Legacy words still resolve.
local MM_TO_INCH = 1 / 25.4

local function baseRadiusInches(definition)
    if type(definition) ~= "table" then return 0 end
    local shape = tostring(definition.base_shape or ""):lower()
    local class = tostring(definition.base_class or ""):lower()
    local diameterMm = 25

    if class == "small" then
        diameterMm = shape == "circle" and 25 or 20
    elseif class == "medium" or class == "normal" then
        diameterMm = shape == "circle" and 32 or 25
    elseif class == "large" or class == "monstrous" then
        diameterMm = 40
    elseif class == "cavalry" or class == "mounted" or definition.mounted == true then
        diameterMm = 40
    end
    return (diameterMm * MM_TO_INCH) * 0.5
end

local function inBaseContact(attackerDef, targetDef, centreDistance)
    local gap = centreDistance - baseRadiusInches(attackerDef) - baseRadiusInches(targetDef)
    return gap <= 0.15, gap
end

-- v6: `not_in_contact` (B · 5, B · 8). Reach packets carry it by definition and
-- ranged packets carry it BY DEFAULT — a bow is illegal with a man on your
-- base, and you swing Fists instead. A ranged packet that omits it is claiming
-- a real, priced advantage (wrist crossbow, hand flamer, point-blank spell), so
-- an explicit `not_in_contact = false` is honoured.
local function packetHasNotInContact(packet)
    if type(packet) ~= "table" then return false end
    if packet.not_in_contact == true then return true end
    if packet.not_in_contact == false then return false end

    if type(packet.constraints) == "table" then
        for _, constraint in ipairs(packet.constraints) do
            if tostring(constraint):lower() == "not_in_contact" then return true end
        end
    end

    -- Default: anything that reaches out cannot be used on the base.
    return (tonumber(packet.range) or 0) > 0
end

local function formatRange(packet)
    local range = tonumber(packet and packet.range) or 0
    if range <= 0 then return "Melee" end
    return string.format('Range %g"', range)
end

local function formatArea(packet)
    if packet == nil or packet.area == nil or tostring(packet.area) == "" then return "" end
    return " · " .. tostring(packet.area)
end

local function formatPacketLabel(packet)
    local name = tostring(packet.name or packet.packet_id or "Packet")
    local dice = tonumber(packet.dice) or 0
    local success = tonumber(packet.success) or 0
    return string.format("%s — %dD @ %d+", name, dice, success)
end

local function effectsText(grade)
    if grade == nil then return "No Grade reached." end
    local effects = grade.effects
    if type(effects) ~= "table" then
        if effects == nil or tostring(effects) == "" then return "No listed effects." end
        return tostring(effects)
    end
    if #effects == 0 then return "No listed effects." end
    local lines = {}
    for _, effect in ipairs(effects) do
        table.insert(lines, "• " .. tostring(effect))
    end
    return table.concat(lines, "\n")
end

local function highestGrade(packet, successes)
    if packet == nil or type(packet.grades) ~= "table" then return nil end
    local best = nil
    local bestSuccesses = -math.huge
    local bestGrade = -math.huge
    for _, grade in ipairs(packet.grades) do
        if type(grade) == "table" then
            local needed = tonumber(grade.successes) or tonumber(grade.success) or tonumber(grade.grade) or 0
            local gradeNumber = tonumber(grade.grade) or needed
            if successes >= needed then
                if needed > bestSuccesses or (needed == bestSuccesses and gradeNumber > bestGrade) then
                    best = grade
                    bestSuccesses = needed
                    bestGrade = gradeNumber
                end
            end
        end
    end
    return best
end

local function rollSession(session)
    local packet = session.packets[session.packet_index]
    if packet == nil then return end
    local baseDice = tonumber(packet.dice) or 0
    local threshold = tonumber(packet.success) or 0
    local finalDice = math.max(0, baseDice + (session.modifier or 0))
    local rolls = {}
    local successes = 0
    for _ = 1, finalDice do
        local value = math.random(1, 6)
        table.insert(rolls, value)
        if value >= threshold then successes = successes + 1 end
    end
    table.sort(rolls, function(a, b) return a > b end)
    local reached = highestGrade(packet, successes)

    -- v6: was this a melee ACTION resolved in base contact? Only that draws a
    -- Counter and creates engagement (B · 8). Ranged never does.
    local attacker = getObjectFromGUID(session.attacker_guid)
    local target = getObjectFromGUID(session.target_guid)
    local contact = false
    if attacker ~= nil and target ~= nil then
        local touching = inBaseContact(session.attacker_def, session.target_def, horizontalDistance(attacker, target))
        contact = touching and not packetHasNotInContact(packet)
    end
    session.melee_contact = contact

    session.result = {
        rolls = rolls,
        successes = successes,
        grade = reached,
        final_dice = finalDice,
        threshold = threshold,
    }
end

local function sessionResultText(session)
    if session.result == nil then
        return "Choose a packet and modifier, then roll."
    end
    local result = session.result
    local rollParts = {}
    for _, die in ipairs(result.rolls) do table.insert(rollParts, tostring(die)) end
    local rollLine = #rollParts > 0 and table.concat(rollParts, " · ") or "No dice"
    local grade = result.grade
    local gradeName = "NO GRADE"
    if grade ~= nil then
        gradeName = "GRADE " .. tostring(grade.grade or grade.successes or "?")
    end

    local text = "ROLL: " .. rollLine
        .. "\nSUCCESSES: " .. tostring(result.successes)
        .. "\n\n" .. gradeName
        .. "\n" .. effectsText(grade)

    -- v6: Model 2 — Discrete (A · VI). Resolving Grade N resolves ONLY the
    -- Effects written on that line. A higher Grade does not inherit.
    if grade ~= nil then
        text = text .. "\n\nResolve ONLY this line — Grades do not accumulate."
    end

    -- v6: the Counter reminder. This is the single most-forgotten thing in v0.6
    -- and the controller is the right place to say it, because it knows the
    -- attack was melee-in-contact.
    if session.melee_contact == true then
        text = text .. "\n\n► TARGET COUNTERS — one melee PACKET back, costs it"
            .. "\n  1 REACTION. Deny it only on the unfaced flank/rear of a"
            .. "\n  Square already engaged elsewhere. Circles always Counter."
            .. "\n  Both lethal? BOTH DIE."
    end

    return text
end

local function buildDropdown(session)
    local options = {}
    for index, packet in ipairs(session.packets) do
        local selected = index == session.packet_index and ' selected="true"' or ""
        table.insert(options, '<Option' .. selected .. '>' .. xmlEscape(formatPacketLabel(packet)) .. '</Option>')
    end
    return table.concat(options)
end

local function buildSessionPanel(playerColor, session)
    local packet = session.packets[session.packet_index]
    local attacker = getObjectFromGUID(session.attacker_guid)
    local target = getObjectFromGUID(session.target_guid)
    if attacker == nil or target == nil or packet == nil then return "" end

    local distance = horizontalDistance(attacker, target)
    local finalDice = math.max(0, (tonumber(packet.dice) or 0) + (session.modifier or 0))
    local meta = string.format(
        "%dD @ %d+ · %s%s · %d AP",
        tonumber(packet.dice) or 0,
        tonumber(packet.success) or 0,
        formatRange(packet),
        formatArea(packet),
        tonumber(packet.cost_ap) or 0
    )

    -- v6: legality line. Base contact is the thing that decides whether a Reach
    -- or Ranged packet is even usable (`not_in_contact`, B · 5 / B · 8) and
    -- whether a Counter is coming back (B · 9). The controller knows the
    -- geometry, so it should say so instead of leaving it to memory.
    local touching, gap = inBaseContact(session.attacker_def, session.target_def, distance)
    local blocked = touching and packetHasNotInContact(packet)
    local range = tonumber(packet.range) or 0
    local outOfRange = (not touching) and range > 0 and gap > range + 0.001

    local legalityText = formatDistance(distance)
    local legalityColor = COLORS.muted
    if blocked then
        legalityText = "BASE CONTACT — this packet is not_in_contact. Swing Fists instead."
        legalityColor = COLORS.red
    elseif outOfRange then
        legalityText = string.format('OUT OF REACH — %.1f" gap vs %g" reach.', gap, range)
        legalityColor = COLORS.red
    elseif touching then
        legalityText = "In base contact — melee. Expect a Counter (1 Reaction)."
        legalityColor = COLORS.gold
    else
        legalityText = string.format('%.1f" gap between bases · no engagement, no Counter.', gap)
    end

    local idSuffix = playerColor:gsub("[^%w]", "")
    return [[
<Panel id="cus-attack-panel-]] .. idSuffix .. [[" visibility="]] .. xmlEscape(playerColor) .. [[" rectAlignment="MiddleRight" offsetXY="-28 0" width="]] .. UI_WIDTH .. [[" height="]] .. UI_HEIGHT .. [[" color="]] .. COLORS.panel .. [[" outline="]] .. COLORS.line .. [[" outlineSize="2 2" padding="16 16 16 16">
    <VerticalLayout spacing="9" childAlignment="UpperCenter" width="398" height="503">
        <HorizontalLayout spacing="8" width="398" height="28" childAlignment="MiddleCenter">
            <Text text="ATTACK CONTROLLER" width="335" height="28" fontSize="20" fontStyle="Bold" color="]] .. COLORS.gold .. [[" alignment="MiddleLeft" />
            <Button id="cus-attack-close-]] .. idSuffix .. [[" onClick="CUS_UI_Close" text="×" width="36" height="28" fontSize="20" colors="]] .. COLORS.danger .. [[" />
        </HorizontalLayout>

        <Panel width="398" height="78" color="]] .. COLORS.panel2 .. [[" padding="10 10 8 8">
            <VerticalLayout spacing="3" width="378" height="62">
                <Text text="ATTACKER" width="378" height="16" fontSize="11" fontStyle="Bold" color="]] .. COLORS.muted .. [[" alignment="MiddleLeft" />
                <Text text="]] .. xmlEscape(session.attacker_name) .. [[" width="378" height="22" fontSize="18" fontStyle="Bold" color="]] .. COLORS.text .. [[" alignment="MiddleLeft" />
                <Text text="TARGET: ]] .. xmlEscape(session.target_name) .. [[" width="378" height="18" fontSize="13" color="]] .. COLORS.red .. [[" alignment="MiddleLeft" />
            </VerticalLayout>
        </Panel>

        <Text text="PACKET" width="398" height="18" fontSize="11" fontStyle="Bold" color="]] .. COLORS.muted .. [[" alignment="MiddleLeft" />
        <Dropdown id="cus-attack-packet-]] .. idSuffix .. [[" onValueChanged="CUS_UI_Packet(selectedIndex)" value="]] .. tostring(session.packet_index - 1) .. [[" width="398" height="34" fontSize="14" colors="]] .. COLORS.button .. [[" dropdownBackgroundColor="#1B2430" itemBackgroundColors="#1B2430|#263341" itemTextColor="#F1F4F7" textColor="#F1F4F7" checkColor="#E6BE58" arrowColor="#E6BE58">
            ]] .. buildDropdown(session) .. [[
        </Dropdown>
        <Text text="]] .. xmlEscape(meta) .. [[" width="398" height="20" fontSize="12" color="]] .. COLORS.blue .. [[" alignment="MiddleLeft" />
        <Text text="]] .. xmlEscape(legalityText) .. [[" width="398" height="20" fontSize="12" color="]] .. legalityColor .. [[" alignment="MiddleLeft" />

        <Panel width="398" height="64" color="#151D27E8" padding="8 8 8 8">
            <HorizontalLayout spacing="8" childAlignment="MiddleCenter" width="382" height="48">
                <Text text="DICE MODIFIER" width="160" height="34" fontSize="14" fontStyle="Bold" color="]] .. COLORS.text .. [[" alignment="MiddleLeft" />
                <Button id="cus-attack-mod-minus-]] .. idSuffix .. [[" onClick="CUS_UI_ModMinus" text="−" width="42" height="34" fontSize="20" colors="]] .. COLORS.button .. [[" />
                <Text text="]] .. tostring(session.modifier or 0) .. [[" width="50" height="34" fontSize="18" fontStyle="Bold" color="]] .. COLORS.gold .. [[" alignment="MiddleCenter" />
                <Button id="cus-attack-mod-plus-]] .. idSuffix .. [[" onClick="CUS_UI_ModPlus" text="+" width="42" height="34" fontSize="20" colors="]] .. COLORS.button .. [[" />
            </HorizontalLayout>
        </Panel>

        <Text text="FINAL ROLL: ]] .. tostring(finalDice) .. [[D @ ]] .. tostring(tonumber(packet.success) or 0) .. [[+" width="398" height="27" fontSize="18" fontStyle="Bold" color="]] .. COLORS.green .. [[" alignment="MiddleCenter" />
        <Button id="cus-attack-roll-]] .. idSuffix .. [[" onClick="CUS_UI_Roll" text="ROLL" width="398" height="42" fontSize="20" fontStyle="Bold" colors="#285C3AFF|#34784CFF|#1E472DFF|#285C3AFF" />

        <Panel width="398" height="160" color="#0C1118E8" outline="#33465A" outlineSize="1 1" padding="10 10 10 10">
            <Text text="]] .. xmlEscape(sessionResultText(session)) .. [[" width="378" height="140" fontSize="14" color="]] .. COLORS.text .. [[" alignment="UpperLeft" />
        </Panel>

        <Text text="Manual-only: nothing is spent or applied. AP, Reaction, Wounds and Armour stay yours." width="398" height="18" fontSize="10" fontStyle="Italic" color="]] .. COLORS.muted .. [[" alignment="MiddleCenter" />
    </VerticalLayout>
</Panel>]]
end

local function renderUI()
    local panels = {}
    for playerColor, session in pairs(sessions) do
        if session.phase == "controller" then
            table.insert(panels, buildSessionPanel(playerColor, session))
        end
    end
    UI.setXml(table.concat(panels, "\n"))
end

local function clearSession(playerColor)
    -- Targeting highlights use short durations. Do not call highlightOff here,
    -- because the miniature tracker may be using a persistent team glow.
    sessions[playerColor] = nil
    renderUI()
end

local function beginTargeting(playerColor, attacker)
    local definition = getDefinition(attacker)
    if definition == nil then
        tell(playerColor, "That miniature has no readable CUS definition.", {1.00, 0.35, 0.35})
        return false
    end
    local packets = rollingPackets(definition)
    if #packets == 0 then
        tell(playerColor, tostring(definition.name or "This unit") .. " has no packets with dice to roll.", {1.00, 0.55, 0.30})
        return false
    end

    clearSession(playerColor)
    sessions[playerColor] = {
        phase = "targeting",
        attacker_guid = attacker.getGUID(),
        attacker_name = tostring(definition.name or attacker.getName()),
        attacker_def = definition,
        packets = packets,
        packet_index = 1,
        modifier = 0,
        result = nil,
    }
    pcall(function() attacker.highlightOn({0.35, 0.85, 1.00}, 8) end)
    tell(playerColor, "Click the target miniature for " .. tostring(definition.name or "the attacker") .. ". Select the attacker again to cancel.", {0.35, 0.85, 1.00})
    return true
end

function CUS_BeginAttack(params)
    if type(params) ~= "table" then return false end
    local playerColor = params.player_color
    local attacker = getObjectFromGUID(params.attacker_guid or "")
    if playerColor == nil or attacker == nil then return false end
    return beginTargeting(playerColor, attacker)
end

function onPlayerAction(player, action, targets)
    local playerColor = player and player.color or nil
    local session = playerColor and sessions[playerColor] or nil
    if session == nil or session.phase ~= "targeting" then return true end
    if action ~= Player.Action.Select then return true end

    local target = targets and targets[1] or nil
    if target == nil then return false end

    if target.getGUID() == session.attacker_guid then
        tell(playerColor, "Attack targeting cancelled.", {0.90, 0.75, 0.35})
        clearSession(playerColor)
        return false
    end

    if not isCUSMiniature(target) then
        tell(playerColor, "Choose another scripted CUS miniature as the target.", {1.00, 0.50, 0.35})
        return false
    end

    local targetDefinition = getDefinition(target)
    if targetDefinition == nil then
        tell(playerColor, "The selected target has no readable CUS definition.", {1.00, 0.35, 0.35})
        return false
    end

    session.target_guid = target.getGUID()
    session.target_name = tostring(targetDefinition.name or target.getName())
    session.target_def = targetDefinition
    session.phase = "controller"
    session.result = nil
    pcall(function() target.highlightOn({1.00, 0.35, 0.35}, 3) end)
    renderUI()
    return false
end

function CUS_UI_Packet(player, selectedIndex, id)
    local color = playerColorOf(player)
    local session = color and sessions[color] or nil
    if session == nil then return end
    local index = (tonumber(selectedIndex) or 0) + 1
    session.packet_index = clamp(index, 1, #session.packets)
    session.result = nil
    renderUI()
end

function CUS_UI_ModMinus(player, value, id)
    local color = playerColorOf(player)
    local session = color and sessions[color] or nil
    if session == nil then return end
    session.modifier = clamp((session.modifier or 0) - 1, MOD_MIN, MOD_MAX)
    session.result = nil
    renderUI()
end

function CUS_UI_ModPlus(player, value, id)
    local color = playerColorOf(player)
    local session = color and sessions[color] or nil
    if session == nil then return end
    session.modifier = clamp((session.modifier or 0) + 1, MOD_MIN, MOD_MAX)
    session.result = nil
    renderUI()
end

function CUS_UI_Roll(player, value, id)
    local color = playerColorOf(player)
    local session = color and sessions[color] or nil
    if session == nil then return end
    rollSession(session)
    renderUI()
end

function CUS_UI_Close(player, value, id)
    local color = playerColorOf(player)
    if color ~= nil then clearSession(color) end
end

function onPlayerDisconnect(player)
    if player ~= nil and player.color ~= nil then clearSession(player.color) end
end

function onLoad(savedData)
    sessions = {}
    renderUI()
end
