-- core/Logger.lua
-- Round/action log with player colour, round, source, target, before/after.
-- Also drives the on-screen broadcast + optional chat echo. Kept compact.

CUS = CUS or {}
local Logger = {}

Logger.entries = {}   -- list of { round, color, msg, source, target, before, after, kind }
Logger.MAX     = 400  -- ring cap so a long game never bloats the save

local function push(entry)
  Logger.entries[#Logger.entries + 1] = entry
  if #Logger.entries > Logger.MAX then
    table.remove(Logger.entries, 1)
  end
end

-- roundProvider is injected by RoundManager so Logger stays dependency-free.
Logger.roundProvider = function() return 0 end

function Logger.log(msg, opts)
  opts = opts or {}
  local entry = {
    round  = Logger.roundProvider(),
    color  = opts.color or "GM",
    msg    = tostring(msg),
    source = opts.source,
    target = opts.target,
    before = opts.before,
    after  = opts.after,
    kind   = opts.kind or "info",
  }
  push(entry)
  if opts.broadcast ~= false then
    local prefix = "[CUS] "
    if opts.color and Color and Color.fromString then
      broadcastToAll(prefix .. entry.msg, opts.rgb or { 0.8, 0.9, 1.0 })
    else
      broadcastToAll(prefix .. entry.msg, opts.rgb or { 0.8, 0.9, 1.0 })
    end
  end
  return entry
end

-- Non-destructive warning surface (broken links, malformed cards, etc.).
function Logger.warn(msg, opts)
  opts = opts or {}
  opts.kind = "warn"
  opts.rgb  = { 1.0, 0.75, 0.2 }
  return Logger.log("⚠ " .. tostring(msg), opts)
end

function Logger.error(msg, opts)
  opts = opts or {}
  opts.kind = "error"
  opts.rgb  = { 1.0, 0.4, 0.4 }
  return Logger.log("✖ " .. tostring(msg), opts)
end

-- Serialize / restore for save-load.
function Logger.serialize() return { entries = Logger.entries } end
function Logger.restore(blob)
  if blob and type(blob.entries) == "table" then Logger.entries = blob.entries end
end

-- Render the last N entries as text (for a debug/log panel).
function Logger.tail(n)
  n = n or 20
  local out, start = {}, math.max(1, #Logger.entries - n + 1)
  for i = start, #Logger.entries do
    local e = Logger.entries[i]
    out[#out+1] = string.format("R%s · %s · %s", tostring(e.round), tostring(e.color), e.msg)
  end
  return table.concat(out, "\n")
end

CUS.Logger = Logger
