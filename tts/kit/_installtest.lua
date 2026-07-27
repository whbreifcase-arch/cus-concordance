--[[
CUS INSTALL TEST
================

Paste THIS ONLY onto one miniature's Object script, then Save & Play.
It is deliberately tiny so that if it fails, the fault cannot be the code.

WHAT IT ANSWERS

  1. Is the script reaching the object at all?
     -> a "CUS INSTALL TEST" entry appears when you right-click the mini.
        setupContextMenu-style calls run at the very top of onLoad, so if this
        entry is missing, no Lua landed on that object. That is an install
        problem, not a code problem.

  2. Do the icons load?
     -> a small green orb should appear floating above the base.
        If you get a white/blank square instead, the image URL 404'd. TTS
        reports a missing URL as "unsupported format: UNKNOWN", which reads
        like a corrupt file and is not.

  3. Does self.UI.setAttribute accept position / rotation / scale?
     -> the orb slides right, tilts, and grows about a second after load, and
        the console reports OK for each. This decides whether the rebuilt HUD
        can move pieces cheaply or has to re-emit XML to do it.

READ THE CONSOLE (~ key). Every line below is prefixed "CUS TEST:".
--]]

local ICON_BASE = "https://raw.githubusercontent.com/whbreifcase-arch/cus-kernel-rebuild/main/tts/icons/"

local function say(msg)
    print("CUS TEST: " .. tostring(msg))
end

function onLoad()
    -- 1 ---------------------------------------------------------------- menu
    self.addContextMenuItem("CUS INSTALL TEST", function(playerColor)
        broadcastToAll("CUS TEST: the context menu works. Script IS on this object.", {0.4, 0.9, 0.5})
    end)
    say("script is running on GUID " .. tostring(self.getGUID()) ..
        " (" .. tostring(self.getName()) .. ")")

    -- 2 -------------------------------------------------------------- assets
    local ok = pcall(function()
        self.UI.setCustomAssets({
            {name = "test_orb", url = ICON_BASE .. "ap_full.png"},
        })
    end)
    say("setCustomAssets " .. (ok and "OK" or "FAILED"))

    local scale = self.getScale()
    local sx = 1 / math.max(scale.x, 0.001)
    local sy = 1 / math.max(scale.y, 0.001)
    local sz = 1 / math.max(scale.z, 0.001)

    self.UI.setXml([[
<Panel id="t_panel" position="]] .. string.format("%.1f %.1f %.1f", 0, 60 * sy, -105 * sz) .. [["
       rotation="0 0 0"
       scale="]] .. string.format("%.4f %.4f %.4f", sx * 0.6, sy * 0.6, sz * 0.6) .. [["
       width="60" height="60" color="#00000000">
  <Image id="t_orb" image="test_orb" width="56" height="56" preserveAspect="true" />
</Panel>]])
    say("setXml pushed - you should see a green orb above the base")

    -- 3 ------------------------------------------------- setAttribute probe
    -- Wait a beat so TTS has actually instantiated the XML; calling
    -- setAttribute on an element that does not exist yet throws.
    Wait.time(function()
        if self == nil or self.isDestroyed() then return end

        local okPos = pcall(function()
            self.UI.setAttribute("t_panel", "position",
                string.format("%.1f %.1f %.1f", 40 * sx, 60 * sy, -105 * sz))
        end)
        local okRot = pcall(function()
            self.UI.setAttribute("t_panel", "rotation", "0 0 25")
        end)
        local okScl = pcall(function()
            self.UI.setAttribute("t_panel", "scale",
                string.format("%.4f %.4f %.4f", sx * 0.9, sy * 0.9, sz * 0.9))
        end)
        local okImg = pcall(function()
            self.UI.setAttribute("t_orb", "color", "#FFFFFFFF")
        end)

        say("setAttribute position " .. (okPos and "OK" or "FAILED"))
        say("setAttribute rotation " .. (okRot and "OK" or "FAILED"))
        say("setAttribute scale    " .. (okScl and "OK" or "FAILED"))
        say("setAttribute on child " .. (okImg and "OK" or "FAILED"))
        say("--- if the orb MOVED, TILTED and GREW, the rebuild can use setAttribute for layout ---")
        broadcastToAll("CUS TEST complete - check the console (~).", {0.4, 0.8, 1.0})
    end, 1.5)
end
