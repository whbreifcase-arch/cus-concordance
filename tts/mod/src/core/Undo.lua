-- core/Undo.lua
-- Script-state undo stack. Each entry is a closure that restores prior state,
-- plus a label for the log. Position undo is guaranteed only for explicit
-- movement sessions that recorded an origin/path (see MovementResolver).
--
-- We snapshot the AFFECTED miniature's runtime state (deep copy) rather than
-- the whole world, so undo is cheap and precise.

CUS = CUS or {}
local Undo = { stack = {}, MAX = 60 }

local function deepcopy(v)
  if type(v) ~= "table" then return v end
  local t = {}
  for k, val in pairs(v) do t[k] = deepcopy(val) end
  return t
end
Undo.deepcopy = deepcopy

-- Record a reversible change. `restoreFn` is called on undo.
function Undo.push(label, restoreFn)
  table.insert(Undo.stack, { label = label, restore = restoreFn })
  if #Undo.stack > Undo.MAX then table.remove(Undo.stack, 1) end
end

-- Convenience: snapshot a miniature's runtime state and push a restorer.
function Undo.pushMiniState(mini, label)
  if not mini then return end
  local guid = mini.getGUID()
  local snap = deepcopy(CUS.StateStore and CUS.StateStore.get(guid) or nil)
  Undo.push(label or "state change", function()
    local obj = getObjectFromGUID(guid)
    if obj and CUS.StateStore then
      CUS.StateStore.set(guid, deepcopy(snap))
      if CUS.StatePanel then CUS.StatePanel.refresh(obj) end
    end
  end)
end

function Undo.pop()
  local entry = table.remove(Undo.stack)
  if not entry then
    if CUS.Logger then CUS.Logger.warn("Nothing to undo.") end
    return false
  end
  local ok, err = pcall(entry.restore)
  if not ok then
    if CUS.Logger then CUS.Logger.error("Undo failed: " .. tostring(err)) end
    return false
  end
  if CUS.Logger then CUS.Logger.log("Undid: " .. tostring(entry.label)) end
  return true
end

function Undo.clear() Undo.stack = {} end

CUS.Undo = Undo
