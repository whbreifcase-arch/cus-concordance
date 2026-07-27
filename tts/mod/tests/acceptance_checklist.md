# Acceptance checklist

Run these in TTS after *Spawn Test Fixture* (or your own linked units). Each maps
to the spec's acceptance tests, with the code path that satisfies it.

| # | Test | How to run | Code path |
|---|---|---|---|
| 1 | Link a miniature to a card | Select mini → right-click card → *Link Selected Miniature* (or the reverse) | `doLink` / `cardLinkSelectedMini` / `beginLinkFromMini` |
| 2 | Save & reload preserves link + state | TTS *Save & Load* | `MiniatureController.onSave` + `registerMiniature` + `StateStore.restore` |
| 3 | Re-sync updates maxima without healing | Edit card GM Notes → mini → *Re-sync From Card* | `resyncFromCard` (clamp-only, preserves conditions) |
| 4 | Open a miniature's exact linked card | Hover mini → *CUS: Open Card* (or state-panel 🂠) | `CardViewer.openForMini` |
| 5 | Wheel root = MOVE/ATTACK/USE/READY only | *CUS: Action Wheel* | `Global.xml` `cus_wheel` root buttons |
| 6 | Begin Move, waypoints, distance, Undo, Commit | Wheel → MOVE → Begin Move; drag; *Commit* | `MovementResolver` + `MovementPanel` |
| 7 | Move before ATTACK, attack, then move again | MOVE-commit, ATTACK-apply, MOVE again | `moved_this_activation` never blocks a 2nd MOVE; ATTACK doesn't end turn |
| 8 | Precision Shot only if not moved; ends turn; ignores Cover | Wheel → ATTACK → ranged packet → Precision | `startAttack` guard + `AttackResolver.begin` (precision mod) |
| 9 | Multi-Shot: two targets, Hit one step worse | ATTACK → ranged → Multi-Shot | `AttackResolver` multishot `hitStep`; forbidden if tag `no Multi-Shot` |
| 10 | Tier attack: successes → best Wound, all Effects, Armour, preview, Apply | Melee attack, *Roll Automatically*, *APPLY* | `AttackResolver.resolve` (`readTiers` best-wound + accumulate) → `apply` |
| 11 | Rear attack: +2 dice, suppresses Counter | Position attacker in defender's rear arc | `Geo.facingArc` → Backstab mod (`suppressCounter`) |
| 12 | Flank: +1 die | Attack from the flank arc | `Geo.facingArc` → Flank mod |
| 13 | Reach without contact suppresses Counter & no lock | Spear packet, bases not touching | `AttackResolver.begin` sets `s.reach` |
| 14 | Melee Counter can occur even on a kill, unless suppressed | Attack a touching enemy, *Resolve Counter* | `CounterResolver` (once/round; Counter X) |
| 15 | Circle + 2 engagers → Armour one step worse (confirmed) | Attack a Circle defender, toggle *Mob Rule* | `mob_candidate` + `confirmMob` → armour +1 step |
| 16 | Charge assist: Small slip / mounted class-up / Monstrous body immunity / confirmed wall-jam +2 | Wheel → MOVE → *Sprint / Charge Assist* | `ChargeAssistant.plowVerdict` + `wallJamModifier` |
| 17 | Circle/Spirit/Construct Nerve ineligibility explained | Mini → *Nerve Test* on the Warboss/Construct | `NerveResolver.eligibility` |
| 18 | Rout shows Temperament instruction, no auto-move | Nerve panel → *Rout* | `npRout` + `NerveResolver.routInstruction` |
| 19 | Formation Advance: slowest−1, spends all MOVE, readies, dissolves on contact | Wheel → MOVE → *Advance Formation* | `FormationAssistant.beginAdvance` / `dissolve` |
| 20 | Broken/missing card GUID → readable warning, no crash | Delete a linked card, act on the mini | `StateStore.getDefinition` returns reason; `Logger.warn` |

## Extra manual verifications
- **State UI shows runtime only** — no Role/Tool/Dice/Hit float over the model
  (`StatePanel.buildXml` intentionally omits them).
- **Modifier ledger shows sources** — every row names its source and consequence
  (`AttackPanel.ledgerRows`).
- **Nothing mutates until Apply** — roll, inspect, then *Cancel*: the defender's
  Wounds are unchanged (`AttackResolver.apply` is the only mutation point).
- **Undo** — after any state change, *CUS: Undo Last State Change* restores it.
