# Save / load & reliability

## What persists, and where
Persistence is layered so nothing is lost and there is a single owner per fact:

| Data | Authoritative store | Serialized by |
|---|---|---|
| Unit **definition** | the physical **card** object | `CardController.onSave` (script state + GM Notes mirror) |
| Miniature **runtime state** | the **miniature** object | `MiniatureController.onSave` |
| Packet **registry** | Global | `Global.onSave → PacketRegistry.serialize` |
| Runtime **mirror**, round #, log | Global | `Global.onSave` |

On load, each miniature re-registers with Global (`registerMiniature`) and hands
back its runtime blob, so the Global working mirror is rebuilt from the
authoritative object copies. Links, Wounds, AP, conditions, morale, and the
round counter all survive a TTS Save & Load.

## Versioning & migration
* `schema_version` is stamped on definitions and runtime state
  (`core/Constants.lua`).
* `Schema.migrateDefinition` / `Schema.migrateRuntimeState` do nil-safe upgrades
  and **preserve unknown namespaced extension fields** — older code ignores
  fields it doesn't recognise instead of crashing.

## Identity vs. link
A miniature stores **both**:
* `card_guid` — the current physical card object (can change if a card is
  deleted/respawned),
* `expected_definition_id` — the stable conceptual identity.

`autoRelinkByDefinitionId` can rebind a miniature to a replacement card that
carries the same `definition_id`. `Re-sync From Card` updates maxima and packet
references **without healing or refilling AP** — it only clamps current values
that now exceed new maxima, and preserves conditions.

## Undo
`core/Undo.lua` keeps a script-state undo stack. Most mutations snapshot the
affected miniature's runtime state and push a restorer. **Position** undo is
guaranteed only for explicit **movement sessions** (which record an origin and
path) and for committed MOVEs; casual pick-ups outside a session never mutate
state.

## Audits & safe failure
* **Audit Links** (Round panel) reports orphan runtime state and miniatures
  pointing at a missing card.
* A missing / malformed / deck-stacked card produces a readable non-destructive
  warning — the resolver never substitutes guessed values and the mod never
  crashes.
* The **Debug: Dump JSON** button prints the raw registry + store to the host's
  console (`~`) for inspection without exposing that complexity during play.
