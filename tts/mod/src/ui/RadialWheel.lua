-- ui/RadialWheel.lua
-- Player-local radial wheel. ROOT = exactly MOVE · ACTION · WAIT (A.III, SIGNED).
--
-- v0.6 MIGRATION. The root used to be four buttons — MOVE/ATTACK/USE/READY.
-- ATTACK and USE were never separate verbs; both resolve a PACKET, so both are
-- ACTION. READY is WAIT. The flavour a player actually reads — "Spear Thrust",
-- "Cast", "Brace", "Overwatch" — now lives in the submenu, listed by packet
-- name, exactly as B.15 describes: the player reads the flavour, the system
-- reads MOVE · ACTION · WAIT. Never add a fourth root (Law 11).
--
-- Center closes the wheel / opens the linked card. A small outer utility ring
-- (Activate · State · Command · Undo · Cancel) is NOT presented as new canonical
-- actions.
--
-- The wheel is anchored to screen centre (reliable) rather than chasing the
-- cursor. It lives in Global.xml as panel id="cus_wheel"; this module fills the
-- submenu column (id="cus_wheel_sub") via UI.setXmlTable.

CUS = CUS or {}
local C     = CUS.Constants
local Store = CUS.StateStore
local Reg   = CUS.PacketRegistry
local Wheel = {}

Wheel.ctx = { guid = nil, player = nil, branch = nil }

-- ---------- open / close ----------------------------------------------------
function Wheel.open(guid, playerColor)
  local def, reason = Store.getDefinition(guid)
  if not def then
    if CUS.Logger then CUS.Logger.warn("Cannot open wheel: " .. tostring(reason)) end
    return
  end
  Wheel.ctx = { guid = guid, player = playerColor, branch = nil }
  UI.setAttribute("cus_wheel_title", "text", def.name)
  Wheel.showRoot()
  UI.setAttribute("cus_wheel", "visibility", playerColor)
  UI.show("cus_wheel")
end

function Wheel.close()
  UI.hide("cus_wheel")
  Wheel.ctx.branch = nil
end

function Wheel.center()
  -- center button: if a submenu is open, go back to root; else open card & close
  if Wheel.ctx.branch then
    Wheel.showRoot()
  else
    if CUS.CardViewer and Wheel.ctx.guid then
      CUS.CardViewer.openForMini(Wheel.ctx.guid, Wheel.ctx.player)
    end
    Wheel.close()
  end
end

-- ---------- submenu builder -------------------------------------------------
-- Rows go into the PRE-DECLARED slots whsub1..whsub20 via setAttribute. They
-- are never rebuilt with UI.setXmlTable — that call takes an asset table, not
-- an element id, and would replace the entire UI (see core/UIList.lua).
local SUB_SLOTS = 20

local function subButton(label, fn, tooltip)
  return { text = label, onClick = fn, tooltip = tooltip or "" }
end

local function heading(text)
  return { kind = "header", text = text }
end

local function setSub(rows)
  CUS.UIList.fill("whsub", SUB_SLOTS, rows)
end

function Wheel.showRoot()
  Wheel.ctx.branch = nil
  setSub({
    heading("MOVE — change position now"),
    heading("ACTION — resolve a packet now"),
    heading("WAIT — arm a packet for later"),
  })
  -- root MOVE/ACTION/WAIT are static buttons in Global.xml; nothing to fill
end

-- ---------- MOVE ------------------------------------------------------------
-- "Charge" is retired as a keyword (B.3): a second MOVE is a Sprint, and the
-- contact a Sprint creates is an Impact.
function Wheel.branchMove()
  Wheel.ctx.branch = "MOVE"
  setSub({
    subButton("Begin Move",           "wheelMoveBegin",   "Start a tracked MOVE session"),
    subButton("Sprint / Impact Assist","wheelChargeAssist","Preview the sprint lane, and the Impacts it creates"),
    subButton("Disengage (1 AP)",     "wheelDisengage",   "Leave an engagement — bases are touching"),
    subButton("Advance Formation",    "wheelAdvance",     "Sergeant forms up (1 AP + MOVE)"),
    subButton("Reform (1 AP)",        "wheelReform",      "Rearrange within ~3\""),
    subButton("Add Obstacle / Story", "wheelStory",       "+1 AP per story climbed"),
    subButton("Commit",               "wheelMoveCommit",  "Spend AP, keep position"),
    subButton("Undo",                 "wheelMoveUndo",    "Return to origin"),
    subButton("Cancel",               "wheelShowRoot",    "Back"),
  })
end

local function noDefRows()
  return { { tag = "Text", attributes = { class = "wheelHint", text = "Linked card unavailable." } } }
end

-- ---------- ACTION ----------------------------------------------------------
-- One verb, every packet. Attacks and abilities are no longer separate branches
-- because they were never separate verbs — both resolve a PACKET (A.III, A.V).
-- Packets are listed by their own name so the player still reads the flavour.
function Wheel.branchAction()
  Wheel.ctx.branch = "ACTION"
  local def = Store.getDefinition(Wheel.ctx.guid)
  if not def then setSub(noDefRows()); return end

  local rows = {}
  local st = Store.getState and Store.getState(Wheel.ctx.guid) or nil
  local spent = st and st.attack_used

  -- --- packets that deliver Force (the old ATTACK branch) ---
  local strikes = Reg.resolveAttacks(def) or {}
  if #strikes > 0 then
    rows[#rows+1] = heading(spent and "STRIKE — already attacked this activation"
                                  or  "STRIKE")
    for _, p in ipairs(strikes) do
      rows[#rows+1] = subButton(p.alias or p.id, "wheelActionPacket(" .. p.id .. ")",
        ("Dice %d · Hit %d+%s"):format(p.dice, p.hit,
          (p.range and p.range > 0) and (" · Range " .. p.range .. "\"") or " · Melee"))
      -- ranged modes appear only when legal (a packet may forbid Multi-Shot)
      if p.range and p.range > 0 then
        rows[#rows+1] = subButton("  ↳ Regular Shot",   "wheelShot(" .. p.id .. "|Regular)",   "Move and shoot normally")
        rows[#rows+1] = subButton("  ↳ Precision Shot", "wheelShot(" .. p.id .. "|Precision)", "No MOVE · +1 die · ignores Cover · ends the activation")
        local noMulti = false
        for _, t in ipairs(p.tags or {}) do if t == "no Multi-Shot" then noMulti = true end end
        if not noMulti then
          rows[#rows+1] = subButton("  ↳ Multi-Shot", "wheelShot(" .. p.id .. "|Multi)", "Two shots · Hit one step worse")
        end
      end
    end
  end

  -- --- packets that do anything else (the old USE branch) ---
  -- Accept both the v0.6 parent "ACTION" and the retired v0.5 "USE" so a card
  -- authored before the rebuild still lists its abilities.
  local abilities = Reg.resolveAbilities(def, "Active", "ACTION") or {}
  if #abilities == 0 then abilities = Reg.resolveAbilities(def, "Active", "USE") or {} end
  if #abilities > 0 then
    rows[#rows+1] = heading("CAST / INTERACT")
    for _, p in ipairs(abilities) do
      rows[#rows+1] = subButton(p.alias or p.id, "wheelActionPacket(" .. p.id .. ")", p.note or "")
    end
  end

  rows[#rows+1] = heading("GENERIC")
  rows[#rows+1] = subButton("Interact", "wheelInteract", "Generic object interaction")
  rows[#rows+1] = subButton("Pick Up",  "wheelPickUp",  "Pick up an object")

  if #strikes == 0 and #abilities == 0 then
    table.insert(rows, 1, heading("No packets on this card."))
  end
  if spent then
    rows[#rows+1] = heading("One attack per activation — a strike is spent, but "
      .. "other packets and MOVE remain.")
  end
  rows[#rows+1] = subButton("Cancel", "wheelShowRoot", "Back")
  setSub(rows)
end

-- ---------- WAIT ------------------------------------------------------------
-- WAIT arms a PACKET against a trigger; it does not resolve now, and it ENDS
-- the activation. The Counter also lives in this family structurally, but it
-- fires automatically and is never chosen here (B.9).
function Wheel.branchWait()
  Wheel.ctx.branch = "WAIT"
  local def = Store.getDefinition(Wheel.ctx.guid)
  if not def then setSub(noDefRows()); return end

  local rows = {}
  local armed = Reg.resolveAbilities(def, "Reactive", "WAIT") or {}
  if #armed == 0 then armed = Reg.resolveAbilities(def, "Reactive", "READY") or {} end
  for _, p in ipairs(armed) do
    rows[#rows+1] = subButton(p.alias or p.id, "wheelWaitPacket(" .. p.id .. ")", p.note or "")
  end

  -- Generic reactions. Brace is Square-only (a faceless Circle has no facing to
  -- fix) and is PROVISIONAL until the first game ratifies it (B.9b).
  rows[#rows+1] = heading("GENERIC")
  local shape = (def.base and def.base.shape) or def.shape
  if C.PROVISIONAL.enabled and C.PROVISIONAL.brace and shape ~= "Circle" then
    rows[#rows+1] = subButton("Brace  (provisional)", "wheelWaitPacket(GENERIC_BRACE)",
      "Lock your facing: +1 die into your front, enemies into it roll -1. Flank and rear get in free.")
  end
  rows[#rows+1] = subButton("Overwatch", "wheelWaitPacket(GENERIC_OVERWATCH)", "Arm a ranged packet against movement")
  rows[#rows+1] = subButton("Wait",      "wheelWaitPacket(GENERIC_WAIT)",      "Hold the packet for any trigger you name")

  rows[#rows+1] = heading("WAIT spends 1 AP and ENDS the activation.")
  rows[#rows+1] = subButton("Cancel", "wheelShowRoot", "Back")
  setSub(rows)
end

-- ---------- retired v0.5 entry points --------------------------------------
-- Kept as thin shims so an old hotkey binding or a stale XML reference still
-- lands somewhere sensible instead of erroring. They are NOT new verbs.
function Wheel.branchAttack() return Wheel.branchAction() end
function Wheel.branchUse()    return Wheel.branchAction() end
function Wheel.branchReady()  return Wheel.branchWait()   end

CUS.RadialWheel = Wheel
