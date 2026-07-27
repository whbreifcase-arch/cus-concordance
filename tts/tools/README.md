# luacheck.py

A dependency-free Lua syntax checker. Run it on any build **before** pasting it
into Tabletop Simulator.

```
python tts/tools/luacheck.py tts/kit/Miniature_Tracker.lua tts/kit/Global_CUS_full.lua
```

Reports unclosed blocks with the line each was opened on, unterminated strings,
and unterminated long brackets — the failures that make TTS silently do nothing.

**Why it exists.** There is no Lua runtime on this machine and pip is broken
(`pip._vendor.rich._emoji_codes` is missing on the 3.11 install), so builds were
being handed over unvalidated. Several went in blind.

**It is validated against a known-good file.** If it ever reports an error on a
build that demonstrably runs, the checker is wrong — not the Lua. That happened
once already: the first version double-counted `for ... in ... do`, because the
`do` can sit many tokens after its keyword.

**What it does NOT catch:** runtime errors. A file can pass this and still throw
when a function is called with the wrong shape, or reference a nil upvalue. For
those, read the TTS console (`~`).
