-- core/EventBus.lua
-- Tiny pub/sub so UI panels, resolvers, and object scripts stay decoupled.
-- Handlers are called in registration order; a throwing handler is isolated
-- (logged, never crashes the mod).

CUS = CUS or {}
local Bus = { handlers = {} }

function Bus.on(event, fn)
  Bus.handlers[event] = Bus.handlers[event] or {}
  table.insert(Bus.handlers[event], fn)
  return fn
end

function Bus.off(event, fn)
  local list = Bus.handlers[event]
  if not list then return end
  for i = #list, 1, -1 do
    if list[i] == fn then table.remove(list, i) end
  end
end

function Bus.emit(event, payload)
  local list = Bus.handlers[event]
  if not list then return end
  for _, fn in ipairs(list) do
    local ok, err = pcall(fn, payload)
    if not ok and CUS.Logger then
      CUS.Logger.error("EventBus handler for '" .. tostring(event) .. "' failed: " .. tostring(err),
                       { broadcast = false })
    end
  end
end

CUS.Bus = Bus
