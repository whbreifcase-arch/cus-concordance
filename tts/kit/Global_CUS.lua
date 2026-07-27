--[[
CUS ATTACK CONTROLLER v5.1 — Global.lua

MVP only:
  1. Right-click a CUS miniature and choose "CUS: Attack".
  2. Click another CUS miniature as the target.
  3. Choose a rolling packet, set a manual dice modifier, and roll.
  4. Read the highest Grade reached and apply everything manually.

This controller NEVER spends AP, changes wounds, rolls armour, or applies effects.
It only reads unit definitions and rolls the packet.
--]]

local VERSION = "5.2"
local sessions = {}

-- Unit Library state. Declared up here because renderUI() is defined further
-- down but before the library section, and a Lua local is invisible to any
-- function defined above its declaration.
local libraries = {}          -- per-player open state
local library = nil           -- decoded CUS_LIBRARY_JSON, cached
local buildLibraryPanel       -- forward declaration; assigned in the library section

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

-- §6.1 BASE CONTACT — deliberately NOT computed.
--
-- A baseRadiusInches/contactGap pair used to live here and derive contact from
-- centre distance. It is gone. Doing that means trusting TTS world units, the
-- object's scale and a guessed base radius all at once, and being wrong BLOCKS
-- A LEGAL ATTACK. The player declares contact instead (CUS_UI_Contact), the
-- same way the movement ruler reports geometry and refuses to rule on contact.
-- Centre distance is still shown, marked approximate, as a rough guide.

-- §6.2 not_in_contact (B.5, B.8)
-- A packet may declare it cannot be resolved while bases are touching. Reach
-- packets carry it by definition; RANGED packets carry it by default — you do
-- not shoot a bow with a man on your base, you drop it and swing Fists. A
-- packet opts out with "not_in_contact": false, which is a wrist crossbow or
-- a point-blank spell, and that is a priced advantage.
--
-- This is now ADVISORY: it prints the rule and lets the player decide.
local function packetNotInContact(packet)
    if packet == nil then return false end
    if packet.not_in_contact ~= nil then return packet.not_in_contact == true end
    if packet.reach == true then return true end
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

    -- §6.4 Grades are DISCRETE (A.VI, Model 2).
    if grade ~= nil then
        text = text .. "\n\nResolve ONLY the line you reached — Grades do not accumulate."
    end

    -- §6.3 The Counter reminder. Only a MELEE action resolved in base contact
    -- creates engagement and draws a Counter. Ranged never does (B.8).
    if session.melee_in_contact then
        text = text .. "\n\nCOUNTER: the target strikes back — one melee PACKET,"
            .. "\ncosting it 1 Reaction. Denied only on the unfaced flank or"
            .. "\nrear of a Square already engaged elsewhere; a Circle is"
            .. "\nfaceless and ALWAYS Counters."
            .. "\nIf both the attack and the Counter are lethal, BOTH DIE."
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

    -- CONTACT IS DECLARED BY THE PLAYER, NEVER MEASURED.
    --
    -- Deriving it from centre distance means trusting TTS world units, the
    -- object's scale, and a guessed base radius all at once. Those numbers are
    -- not reliable, and a wrong "OUT OF REACH" that blocks a legal attack is
    -- far worse than no check at all. So the tracker asks, and the players
    -- adjudicate — same division of labour as the movement ruler, which reports
    -- geometry and refuses to rule on contact (B.3, §6.5).
    --
    -- The centre distance is still shown, clearly marked as approximate,
    -- because it is genuinely useful for "am I anywhere near?".
    local range = tonumber(packet.range) or 0
    local inContact = session.in_contact == true
    session.melee_in_contact = inContact and range <= 0
    session.blocked = false                     -- nothing is ever blocked now

    -- Advisory only. It states the rule and lets the player decide.
    local warning = ""
    if inContact and packetNotInContact(packet) then
        warning = "not_in_contact — you do not shoot this with a man on your base. Swing Fists."
    end

    local contactLine = string.format('~%.1f" centre to centre  (approximate)', distance)
    local meta = string.format(
        "%dD @ %d+ · %s%s · %d AP",
        tonumber(packet.dice) or 0,
        tonumber(packet.success) or 0,
        formatRange(packet),
        formatArea(packet),
        tonumber(packet.cost_ap) or 0
    )

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

        <Panel width="398" height="]] .. (session.melee_in_contact and 54 or 1) .. [[" color="]] .. (session.melee_in_contact and "#4A2A1EF0" or "#00000000") .. [[" padding="9 9 6 6">
            <Text text="]] .. xmlEscape(session.melee_in_contact and
                ("THIS DRAWS A COUNTER\nMelee in base contact — the target strikes back for 1 Reaction.\nIf both blows are lethal, BOTH DIE.") or "") .. [[" width="380" height="]] .. (session.melee_in_contact and 44 or 1) .. [[" fontSize="12" fontStyle="Bold" color="]] .. COLORS.red .. [[" alignment="UpperLeft" />
        </Panel>

        <Text text="PACKET" width="398" height="18" fontSize="11" fontStyle="Bold" color="]] .. COLORS.muted .. [[" alignment="MiddleLeft" />
        <Dropdown id="cus-attack-packet-]] .. idSuffix .. [[" onValueChanged="CUS_UI_Packet(selectedIndex)" value="]] .. tostring(session.packet_index - 1) .. [[" width="398" height="34" fontSize="14" colors="]] .. COLORS.button .. [[" dropdownBackgroundColor="#1B2430" itemBackgroundColors="#1B2430|#263341" itemTextColor="#F1F4F7" textColor="#F1F4F7" checkColor="#E6BE58" arrowColor="#E6BE58">
            ]] .. buildDropdown(session) .. [[
        </Dropdown>
        <Text text="]] .. xmlEscape(meta) .. [[" width="398" height="20" fontSize="12" color="]] .. COLORS.blue .. [[" alignment="MiddleLeft" />
        <Text text="]] .. xmlEscape(contactLine) .. [[" width="398" height="18" fontSize="11" color="]] .. COLORS.muted .. [[" alignment="MiddleLeft" />

        <HorizontalLayout spacing="6" width="398" height="30" preferredWidth="398" preferredHeight="30" childAlignment="MiddleLeft" childForceExpandWidth="false" childForceExpandHeight="false">
            <Text text="BASES TOUCHING?" width="140" height="28" preferredWidth="140" preferredHeight="28" fontSize="11" fontStyle="Bold" color="]] .. COLORS.muted .. [[" alignment="MiddleLeft" />
            <Button id="cus-contact-yes-]] .. idSuffix .. [[" onClick="CUS_UI_Contact(1)" text="YES" width="90" height="28" preferredWidth="90" preferredHeight="28" fontSize="13" colors="]] .. (inContact and "#285C3AFF|#34784CFF|#1E472DFF|#285C3AFF" or COLORS.button) .. [[" />
            <Button id="cus-contact-no-]] .. idSuffix .. [[" onClick="CUS_UI_Contact(0)" text="NO" width="90" height="28" preferredWidth="90" preferredHeight="28" fontSize="13" colors="]] .. ((not inContact) and "#4A3A20FF|#63512DFF|#382B18FF|#4A3A20FF" or COLORS.button) .. [[" />
        </HorizontalLayout>

        <Text text="]] .. xmlEscape(warning) .. [[" width="398" height="]] .. ((warning ~= "") and 32 or 1) .. [[" fontSize="11" fontStyle="Bold" color="]] .. COLORS.gold .. [[" alignment="UpperLeft" />

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

        <Text text="Manual-only MVP: no AP, Wounds, Armour, or effects are changed." width="398" height="18" fontSize="10" fontStyle="Italic" color="]] .. COLORS.muted .. [[" alignment="MiddleCenter" />
    </VerticalLayout>
</Panel>]]
end

-- ACT flow, in the order the rules actually care about:
--   picking  -> choose one of YOUR packets
--   targeting-> click the figure you are resolving it against
--   controller-> the roll panel, with contact + Counter already worked out
--
-- Packet first is deliberate. Whether base contact helps you or forbids you
-- depends entirely on which packet you picked (§6.2), so asking for the target
-- first means answering "can I do this?" before you have said what "this" is.
local function buildPickerPanel(playerColor, session)
    local idSuffix = playerColor:gsub("[^%w]", "")
    local rows = {}
    for index, packet in ipairs(session.packets) do
        local range = tonumber(packet.range) or 0
        local meta = string.format("%dD @ %d+   %s%s",
            tonumber(packet.dice) or 0, tonumber(packet.success) or 0,
            (range > 0) and (range .. '"') or "Melee",
            packetNotInContact(packet) and "   not-in-contact" or "")
        rows[#rows+1] = '<Button id="cus-pick-' .. index .. '-' .. idSuffix ..
            '" onClick="CUS_UI_Pick(' .. index .. ')" text="' ..
            xmlEscape(tostring(packet.name or packet.packet_id) .. "\n" .. meta) ..
            '" width="330" height="44" preferredWidth="330" preferredHeight="44" fontSize="13" colors="' ..
            COLORS.button .. '" textColor="#F1F4F7" />'
    end
    if #rows == 0 then
        rows[1] = '<Text text="This figure has no packets with dice." width="330" height="40" preferredWidth="330" preferredHeight="40" fontSize="12" color="' .. COLORS.red .. '" />'
    end

    local listHeight = math.min(300, math.max(60, #rows * 48 + 8))
    return [[
<Panel id="cus-pick-panel-]] .. idSuffix .. [[" visibility="]] .. xmlEscape(playerColor) .. [[" rectAlignment="MiddleRight" offsetXY="-28 0" width="370" height="]] .. tostring(listHeight + 110) .. [[" color="]] .. COLORS.panel .. [[" outline="]] .. COLORS.line .. [[" outlineSize="2 2" padding="16 16 16 16">
    <VerticalLayout spacing="8" childAlignment="UpperCenter" childForceExpandWidth="false" childForceExpandHeight="false" width="338" height="]] .. tostring(listHeight + 78) .. [[">
        <Text text="ACT" width="338" height="26" preferredWidth="338" preferredHeight="26" fontSize="19" fontStyle="Bold" color="]] .. COLORS.gold .. [[" alignment="MiddleLeft" />
        <Text text="]] .. xmlEscape(session.attacker_name .. "  -  choose a packet") .. [[" width="338" height="20" preferredWidth="338" preferredHeight="20" fontSize="12" color="]] .. COLORS.muted .. [[" alignment="MiddleLeft" />
        <VerticalScrollView width="338" height="]] .. listHeight .. [[" preferredWidth="338" preferredHeight="]] .. listHeight .. [[" color="#0C1118E8">
            <VerticalLayout spacing="4" padding="4 4 4 4" childAlignment="UpperCenter" childForceExpandWidth="false" childForceExpandHeight="false">
                ]] .. table.concat(rows, "\n") .. [[
            </VerticalLayout>
        </VerticalScrollView>
        <Button id="cus-pick-cancel-]] .. idSuffix .. [[" onClick="CUS_UI_Close" text="Cancel" width="338" height="30" preferredWidth="338" preferredHeight="30" fontSize="13" colors="]] .. COLORS.danger .. [[" />
    </VerticalLayout>
</Panel>]]
end

local function renderUI()
    local panels = {}
    for playerColor, session in pairs(sessions) do
        if session.phase == "controller" then
            table.insert(panels, buildSessionPanel(playerColor, session))
        elseif session.phase == "picking" then
            table.insert(panels, buildPickerPanel(playerColor, session))
        end
    end
    -- The library sits on the left, the attack controller on the right, so
    -- both can be open at once without overlapping.
    for playerColor, state in pairs(libraries) do
        table.insert(panels, buildLibraryPanel(playerColor, state))
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
        -- Start at the PACKET picker, not at targeting.
        phase = "picking",
        attacker_guid = attacker.getGUID(),
        attacker_name = tostring(definition.name or attacker.getName()),
        attacker_def = definition,          -- kept for the base-radius lookup (§6.1)
        packets = packets,
        packet_index = 1,
        modifier = 0,
        result = nil,
    }
    pcall(function() attacker.highlightOn({0.35, 0.85, 1.00}, 8) end)
    renderUI()
    return true
end

-- The player chose a packet. NOW go looking for a target.
function CUS_UI_Pick(player, value, id)
    local color = playerColorOf(player)
    local session = color and sessions[color] or nil
    if session == nil or session.phase ~= "picking" then return end

    session.packet_index = clamp(tonumber(value) or 1, 1, #session.packets)
    session.phase = "targeting"
    session.result = nil
    renderUI()

    local packet = session.packets[session.packet_index]
    tell(color, "Packet: " .. tostring(packet.name or packet.packet_id) ..
        ". Now click the target miniature. Select the attacker again to cancel.",
        {0.35, 0.85, 1.00})
end

function CUS_BeginAttack(params)
    if type(params) ~= "table" then return false end
    local playerColor = params.player_color
    local attacker = getObjectFromGUID(params.attacker_guid or "")
    if playerColor == nil or attacker == nil then return false end
    return beginTargeting(playerColor, attacker)
end

-- The tracker's ACT button. Same entry point; the name matches the verb (A.III)
-- now that ATTACK is retired and everything resolves a PACKET under ACTION.
function CUS_BeginAction(params) return CUS_BeginAttack(params) end

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
    session.target_def = targetDefinition   -- kept for the base-radius lookup (§6.1)
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

-- The player declares base contact. Nothing is measured (see buildSessionPanel).
function CUS_UI_Contact(player, value, id)
    local color = playerColorOf(player)
    local session = color and sessions[color] or nil
    if session == nil then return end
    session.in_contact = (tostring(value) == "1")
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

-- ===========================================================================
-- UNIT LIBRARY
-- ---------------------------------------------------------------------------
-- Pick a unit and stamp it straight onto a miniature. There is no card and no
-- linking step: the miniature carries its own definition, so a unit is just a
-- blob of JSON handed to it.
--
-- Flow: right-click a miniature -> CUS: Unit Library -> pick a faction ->
--       tap a unit. Done.
--
-- Data comes from CUS_LIBRARY_JSON at the bottom of this file, generated by
-- CUS_MINI_KIT/build_library.ps1 out of the v0.6 faction files with every
-- packet and trait already resolved inline.
-- ===========================================================================

-- `library` and `libraries` are declared at the top of the file (see note there).

local LIB_WIDTH  = 400
local LIB_HEIGHT = 560

-- The tracker writes a BBCode status prefix into the object's name, e.g.
--   {[E8C35A][b]o[/b][-] [EF5B5B][b]****[/b][-]} Grand Master
-- Raw markup is meaningless in a panel, so strip the tags and the braces.
local function stripMarkup(value)
    local text = tostring(value or "")
    text = text:gsub("%b{}", "")        -- the whole {...} status block
    text = text:gsub("%[[^%]]-%]", "")  -- any leftover [tag]
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")
    if text == "" then return "miniature" end
    return text
end

local function getLibrary()
    if library ~= nil then return library end
    if type(CUS_LIBRARY_JSON) ~= "string" or CUS_LIBRARY_JSON == "" then
        library = {factions = {}}
        return library
    end
    local ok, decoded = pcall(JSON.decode, CUS_LIBRARY_JSON)
    if not ok or type(decoded) ~= "table" then
        library = {factions = {}}
        return library
    end
    library = decoded
    return library
end

local function libFactionAt(index)
    local lib = getLibrary()
    return lib.factions and lib.factions[index] or nil
end

-- Two dropdowns and an Apply button.
--
-- This deliberately does NOT hand-build a list of buttons inside a layout
-- group. TTS/Unity layout groups ignore `height` on their children (they read
-- `preferredHeight`), so a hand-built list either stretches into a few giant
-- rows or collapses to nothing depending on childForceExpandHeight. A
-- Dropdown brings its own scrolling and its own sizing, and the attack panel
-- in this same file already proves it renders correctly here.
buildLibraryPanel = function(playerColor, state)
    local lib = getLibrary()
    local idSuffix = playerColor:gsub("[^%w]", "")
    local factions = lib.factions or {}
    if #factions == 0 then return "" end

    local fIndex = math.max(1, math.min(state.faction_index or 1, #factions))
    local faction = factions[fIndex]
    local units = (faction and faction.units) or {}
    local uIndex = math.max(1, math.min(state.unit_index or 1, math.max(1, #units)))
    local unit = units[uIndex]

    -- faction options
    local fOpts = {}
    for index, f in ipairs(factions) do
        local sel = (index == fIndex) and ' selected="true"' or ""
        fOpts[#fOpts + 1] = "<Option" .. sel .. ">" ..
            xmlEscape(string.format("%s  (%d)", tostring(f.faction), #(f.units or {}))) .. "</Option>"
    end

    -- unit options
    local uOpts = {}
    for index, u in ipairs(units) do
        local sel = (index == uIndex) and ' selected="true"' or ""
        local base = u.base or {}
        local tag = ""
        if base.mounted == true then tag = " [mtd]"
        elseif tostring(base.size) == "Large" then tag = " [Lg]" end
        local lead = u.tier and (tostring(u.tier):sub(1, 3):upper() .. " ") or ""
        uOpts[#uOpts + 1] = "<Option" .. sel .. ">" ..
            xmlEscape(string.format("%s%s - %s %s%s", lead, tostring(u.name),
                tostring(u.role or "?"), tostring(base.size or ""), tag)) .. "</Option>"
    end
    if #uOpts == 0 then uOpts[1] = "<Option>(no units)</Option>" end

    -- stat preview for the highlighted unit
    local preview = "Select a unit."
    if unit ~= nil then
        local s = unit.stats or {}
        local packetBits = {}
        for _, p in ipairs(unit.packets or {}) do
            packetBits[#packetBits + 1] = string.format("%s %sD@%s+",
                tostring(p.name), tostring(p.dice), tostring(p.success))
        end
        preview = string.format("W %s   AP %s   Armour %s   Nerve %s   Speed %s\n%s\n%s",
            tostring(s.max_wounds), tostring(s.max_ap), tostring(s.armour),
            tostring(s.nerve), tostring(s.speed),
            table.concat({tostring(unit.role), tostring(unit.tool),
                          tostring(unit.temperament), tostring(unit.creature_type)}, "  /  "),
            #packetBits > 0 and table.concat(packetBits, "   ") or "no packets")
    end

    local ddStyle = 'colors="' .. COLORS.button ..
        '" dropdownBackgroundColor="#1B2430" itemBackgroundColors="#1B2430|#263341"' ..
        ' itemTextColor="#F1F4F7" textColor="#F1F4F7" checkColor="#E6BE58" arrowColor="#E6BE58"'

    return [[
<Panel id="cus-lib-panel-]] .. idSuffix .. [[" visibility="]] .. xmlEscape(playerColor) .. [[" rectAlignment="MiddleLeft" offsetXY="28 0" width="430" height="400" color="]] .. COLORS.panel .. [[" outline="]] .. COLORS.line .. [[" outlineSize="2 2" padding="16 16 16 16">
    <VerticalLayout spacing="8" childAlignment="UpperCenter" width="398" height="368">
        <Text text="UNIT LIBRARY" width="398" height="26" fontSize="19" fontStyle="Bold" color="]] .. COLORS.gold .. [[" alignment="MiddleLeft" />
        <Text text="]] .. xmlEscape("onto:  " .. stripMarkup(state.miniature_name)) .. [[" width="398" height="20" fontSize="13" color="]] .. COLORS.blue .. [[" alignment="MiddleLeft" />

        <Text text="FACTION" width="398" height="16" fontSize="11" fontStyle="Bold" color="]] .. COLORS.muted .. [[" alignment="MiddleLeft" />
        <Dropdown id="cus-lib-faction-]] .. idSuffix .. [[" onValueChanged="CUS_Lib_Faction(selectedIndex)" value="]] .. tostring(fIndex - 1) .. [[" width="398" height="34" fontSize="14" ]] .. ddStyle .. [[>
            ]] .. table.concat(fOpts) .. [[
        </Dropdown>

        <Text text="UNIT" width="398" height="16" fontSize="11" fontStyle="Bold" color="]] .. COLORS.muted .. [[" alignment="MiddleLeft" />
        <Dropdown id="cus-lib-unit-]] .. idSuffix .. [[" onValueChanged="CUS_Lib_Unit(selectedIndex)" value="]] .. tostring(uIndex - 1) .. [[" width="398" height="34" fontSize="14" ]] .. ddStyle .. [[>
            ]] .. table.concat(uOpts) .. [[
        </Dropdown>

        <Panel width="398" height="76" color="#0C1118E8" outline="#33465A" outlineSize="1 1" padding="10 10 8 8">
            <Text text="]] .. xmlEscape(preview) .. [[" width="378" height="60" fontSize="12" color="]] .. COLORS.text .. [[" alignment="UpperLeft" />
        </Panel>

        <Button id="cus-lib-apply-]] .. idSuffix .. [[" onClick="CUS_Lib_Apply" text="STAMP ONTO MINIATURE" width="398" height="38" fontSize="16" fontStyle="Bold" colors="#285C3AFF|#34784CFF|#1E472DFF|#285C3AFF" />
        <Button id="cus-lib-close-]] .. idSuffix .. [[" onClick="CUS_Lib_Close" text="Close" width="398" height="28" fontSize="13" colors="]] .. COLORS.danger .. [[" />
    </VerticalLayout>
</Panel>]]
end


function CUS_OpenLibrary(params)
    if type(params) ~= "table" then return false end
    local playerColor = params.player_color
    if playerColor == nil then return false end

    local mini = getObjectFromGUID(params.miniature_guid or "")
    if mini == nil then
        tell(playerColor, "That miniature could not be found.", {1.00, 0.35, 0.35})
        return false
    end

    local lib = getLibrary()
    if lib.factions == nil or #lib.factions == 0 then
        tell(playerColor, "The unit library is empty. Re-run build_library.ps1 and re-paste Global.", {1.00, 0.35, 0.35})
        return false
    end

    libraries[playerColor] = {
        miniature_guid = mini.getGUID(),
        miniature_name = mini.getName(),
        faction_index = 1,
        unit_index = 1,
    }
    renderUI()
    return true
end

-- Dropdowns report a ZERO-based selectedIndex.
function CUS_Lib_Faction(player, value, id)
    local color = playerColorOf(player)
    local state = color and libraries[color] or nil
    if state == nil then return end
    state.faction_index = (tonumber(value) or 0) + 1
    state.unit_index = 1                       -- new faction, start at its first unit
    renderUI()
end

function CUS_Lib_Unit(player, value, id)
    local color = playerColorOf(player)
    local state = color and libraries[color] or nil
    if state == nil then return end
    state.unit_index = (tonumber(value) or 0) + 1
    renderUI()                                  -- refresh the stat preview
end

function CUS_Lib_Close(player, value, id)
    local color = playerColorOf(player)
    if color ~= nil then libraries[color] = nil end
    renderUI()
end

-- Retired: the old two-step button list had a Back button.
function CUS_Lib_Back(player, value, id) end

function CUS_Lib_Apply(player, value, id)
    local color = playerColorOf(player)
    local state = color and libraries[color] or nil
    if state == nil then return end

    local faction = libFactionAt(state.faction_index)
    local unit = faction and faction.units and faction.units[state.unit_index] or nil
    if unit == nil then
        tell(color, "Pick a unit first.", {1.00, 0.55, 0.30})
        return
    end

    local mini = getObjectFromGUID(state.miniature_guid or "")
    if mini == nil then
        tell(color, "That miniature is gone.", {1.00, 0.35, 0.35})
        libraries[color] = nil
        renderUI()
        return
    end

    -- Hand the definition over as JSON. A Lua table passed between scripts
    -- stays owned by this sandbox and TTS refuses to let the object keep it.
    local okEncode, unitJson = pcall(JSON.encode, unit)
    if not okEncode then
        tell(color, "Could not encode that unit.", {1.00, 0.35, 0.35})
        return
    end

    local applied = safeObjectCall(mini, "CUS_SetDefinitionJSON", {
        json = unitJson,
        player_color = color,
    })

    if applied == true then
        pcall(function() mini.highlightOn({0.40, 1.00, 0.55}, 3) end)
        libraries[color] = nil
        renderUI()
    else
        tell(color, "That miniature is not running the CUS tracker script.", {1.00, 0.35, 0.35})
    end
end

function onPlayerDisconnect(player)
    if player ~= nil and player.color ~= nil then
        clearSession(player.color)
        libraries[player.color] = nil
    end
end

function onLoad(savedData)
    sessions = {}
    libraries = {}
    local lib = getLibrary()
    print(("CUS: unit library loaded - %d factions."):format(#(lib.factions or {})))
    renderUI()
end
