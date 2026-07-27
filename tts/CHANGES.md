# CUS TTS — v6.1

Drop-in replacements. Your originals are untouched.

**Note on lineage:** this is branched from `CUS_Miniature_Tracker(17).lua`. I
grepped both your file and mine — **neither tracker contains library-pull code**,
so that lives in a separate script and nothing here touches it. If your working
copy has tracker-side library code in the part of the paste that got truncated,
tell me and I'll merge it in rather than the other way round.

---

## The HUD, rebuilt to your sketch

```
   [yellow]  [blue]    [heart]   [triangle]
   REACTION    AP       WOUNDS   ACTIVATION
     ●         ●         ♥ 2         △
     ●         ●
     ○         ●
                MOVE  ATK  WAIT  ↻
```

| | |
|---|---|
| **Yellow column** | **Reaction**, full circles, vertical. Filled = still available. |
| **Blue column** | **AP / Agency**, full circles, vertical. |
| **Heart** | **One** heart with the number on it — not a row of hearts. At 1–2 Wounds standard (B·7) a row was noise. At 0 it becomes ☠. |
| **Triangle** | `△` unactivated (green) · `▲` waiting (purple) · `▽` activated (grey). Point up = still has its turn, point down = spent. |

Columns fill from the **bottom up**, so the top circle is the last point you
spend. Height adapts — a 2 AP figure doesn't reserve room for six.

**Why two separate columns and not one row:** Reaction and AP are different
Kernel Resources that **never exchange** (A·IV). AP is what you do on your own
turn; Reaction is what you can still answer with on someone else's. One shared
bar would imply a conversion that doesn't exist.

## Two things I took from your file

Both were better than my versions:

- **`NERVE_MIGRATE = {Routed = "Broken", Breaking = "Broken"}`** — table-driven,
  and it catches `Breaking` which my inline check missed.
- **Mounted stacks on the size class instead of replacing it.** Yours reads
  "elongated geometry on top of whatever class it already is," which is what
  B·1 actually says. Mine had it as a sibling in the `elseif` chain, which was
  wrong for a mounted Small.

## What your file was still missing

- **Reaction pool** — no representation anywhere. In v0.6 this is the cap on
  every response in the game.
- `TURN_STATES` still `Readied` — a retired verb (READY became WAIT, D·1).
  Saved figures migrate.
- `rank` / `tiers` / `counter_uses` — retired names. Legacy JSON still reads.
- **`sub(id, 1, 9) == "cus-heart-"`** — nine characters compared against a
  ten-character string, so **every heart click was silently dropped.** Fixed.
- The Tier-1 action row, and the 3″ charge readout.

## Still in from v6.0

- **WAIT is real** — spends 1 AP, refuses if you have none, and warns if you arm
  it with an empty Reaction pool because *arming is not permission* (A·III).
- **↻ is an activation refresh, not round-wide** — AP + Reaction restored, WAIT
  expired, path cleared (B·12). Which is exactly why a figure that emptied its
  pool late last round starts this one empty.
- **Charge readout** in the ruler: `run-up 2.1"/3"` → `CHARGE 3.6"`. Final leg
  only, since a committed waypoint means you turned.
- **Attack Controller** knows base contact: warns `BASE CONTACT — this packet is
  not_in_contact`, flags out-of-reach, and after a melee-in-contact roll prints
  the Counter rules including *both lethal → BOTH DIE*.

## Two judgement calls to check

1. **The nerve badge survived.** You spec'd four readouts and Nerve wasn't one,
   but Steady/Shaken/Broken drives Routing so I kept it as a small badge at the
   right rather than dropping it silently. Say the word and it goes.
2. **The armour badge survived** too, same position, same reasoning.

## Test order

1. Load an existing mini → Nerve/Turn migrate, nothing resets.
2. Yellow column present; a Circle should show **two** circles, a Square one.
3. Click a heart — it should actually work now.
4. WAIT with 0 AP → refused. WAIT with 0 Reaction → armed, with a warning.
5. Move 4″ straight → `CHARGE`. Drop a waypoint mid-path → run-up resets.
6. Shoot an adjacent figure → `BASE CONTACT` warning.
