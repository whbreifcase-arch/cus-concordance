-- ui/AttackPanel.lua
-- Compact player-local attack resolver panel. Renders the AttackResolver
-- session: attacker/defender blocks, a source-labelled modifier ledger,
-- player-confirmable judgment toggles, final Dice/Hit BEFORE rolling, and the
-- roll → preview → Apply flow. Nothing mutates the defender until Apply.

CUS = CUS or {}
local Store  = CUS.StateStore
local Attack = CUS.AttackResolver
local AP = {}

AP.player = nil

local function label(id, text) UI.setAttribute(id, "text", text) end

-- Build the modifier ledger rows (every modifier shows source + consequence).
local function ledgerRows(s)
  local rows = {}
  local function row(src, effect)
    -- Flat rows: the ledger renders into pre-declared slots (ledg_r1..14), so
    -- source and effect share one line rather than nesting a layout.
    rows[#rows+1] = { kind = "header", text = src .. "   ->   " .. effect }
  end
  for _, m in ipairs(s.modifiers) do
    local parts = {}
    if m.dice then parts[#parts+1] = (m.dice >= 0 and "+" or "") .. m.dice .. " dice" end
    if m.hitStep then parts[#parts+1] = "Hit " .. m.hitStep .. " step worse" end
    if m.armourStep then parts[#parts+1] = "Armour " .. m.armourStep .. " step worse" end
    if m.ignoreArmour then parts[#parts+1] = "ignore Armour" end
    if m.suppressCounter then parts[#parts+1] = "no Counter" end
    row(m.source, m.note ~= "" and m.note or table.concat(parts, ", "))
  end
  if s.mob_candidate then
    row("Mob Rule?", s.mob_confirmed and "CONFIRMED: Armour 1 step worse" or "Circle — confirm if engaged by 2+")
  end
  if #rows == 0 then rows[1] = { kind = "header", text = "No modifiers." } end
  return rows
end

function AP.render(playerColor)
  local s = Attack.session
  if not s then return end
  AP.player = playerColor or AP.player
  local comp = Attack.compute(s)

  label("ap_atk_name", s.atkDef.name .. (s.is_counter and "  (COUNTER)" or ""))
  label("ap_def_name", s.defDef.name)
  label("ap_packet", (s.packet.alias or s.packet.id) .. "  ·  " .. (s.mode or "Regular"))
  label("ap_def_armour", "Armour: " .. CUS.Schema.armourClass(s.defDef))
  label("ap_def_wounds", ("Wounds: %d"):format(Store.getOrInit(s.defenderGuid).state.current_wounds))
  -- B.9 (SIGNED): Counters have no cap. There is no allowance to display —
  -- what matters is whether THIS strike draws one.
  label("ap_def_counter", s.is_counter and "Counter: none (a Counter draws no Counter)"
        or (s.suppressCounter and "Counter: suppressed"
        or (s.reach and not s.touching) and "Counter: none (Reach, no contact)"
        or "Counter: yes — it turns and swings back"))
  label("ap_facing", "Facing: " .. tostring(s.facing or "?") ..
        (s.reach and "  · Reach (no Counter)" or "") .. (s.touching and "  · bases touching" or ""))

  CUS.UIList.fill("ledg_r", 14, ledgerRows(s))

  label("ap_final", ("FINAL:  %d dice  ·  Hit %d+%s%s"):format(
    comp.dice, comp.hit,
    comp.ignoreArmour and "  ·  ignore Armour" or "",
    comp.armourStep > 0 and ("  ·  Armour +" .. comp.armourStep .. " worse") or ""))

  -- mob toggle button reflects state
  UI.setAttribute("ap_mob", "text", s.mob_confirmed and "Mob Rule: ON" or "Mob Rule: off")

  UI.setAttribute("cus_attack", "visibility", AP.player)
  UI.show("cus_attack")
  UI.hide("ap_result")   -- hidden until a roll happens
end

-- Render the resolved result (after a roll) — dice, successes, tiers, saves.
function AP.renderResult()
  local s = Attack.session
  if not s or not s.result then return end
  local r = s.result
  local dice = {}
  for _, d in ipairs(r.rolls) do
    dice[#dice+1] = (d.success and ("[" .. d.die .. "]") or tostring(d.die))
  end
  label("ap_dice", "Dice: " .. table.concat(dice, " ") .. ("   → %d success"):format(r.successes))
  local tiers = {}
  for _, t in ipairs(r.reachedTiers) do tiers[#tiers+1] = t.successes .. "→" .. (t.wounds and (t.wounds .. "W") or "") end
  label("ap_tiers", ("Tiers reached: %s   ·   best Wound = %d"):format(table.concat(tiers, ", "), r.wounds))
  label("ap_effects", (#r.effects > 0) and ("Effects: " .. table.concat(r.effects, ", ")) or "Effects: —")
  local saves = {}
  for _, sv in ipairs(r.armour.rolls) do saves[#saves+1] = (sv.saved and (sv.die .. "✓") or (sv.die .. "✗")) end
  label("ap_saves", ("Armour %s: %s   →   %d unsaved"):format(
    r.saveThreshold and (r.saveThreshold .. "+") or "—", table.concat(saves, " "), r.unsaved))
  label("ap_pending", ("Pending: Wounds %d → %d%s"):format(
    r.pending.wounds_before, r.pending.wounds_after,
    r.counter_possible and "   ·   Counter possible" or ""))
  UI.show("ap_result")
end

function AP.close()
  UI.hide("cus_attack")
end

CUS.AttackPanel = AP
