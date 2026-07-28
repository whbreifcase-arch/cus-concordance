# CUS — THE COMPONENT LAYER
### v0.6 · the analog interface · signed 2026-07-27 (William)

> **What this is.** The physical component system — how CUS state, capability, and
> campaign are carried on a real table of miniatures, cards, dice and pencil. It is
> the concrete discharge of the Constitution's interface commitment: *"Play is
> analog. No screen at the table"* (A·XIX). Everything here lives at the
> **Presentation layer** (A·IX): it **translates** the Kernel onto physical objects
> and **never forks a parallel mechanic**. Where a component seems to imply a rule,
> the rule is owned by A–C or by the Combat Module (B); this document only says
> where it is *read*.
>
> **Authority.** J cites A and does not restate structure. Where J conflicts with
> A–C or B, **they win.** J is not a module — it owns no Procedure. It is the
> physical face of the ones that already exist.
>
> **On "not."** Where the obvious reading of a component choice is wrong, you'll see
> a `→ G·<slug>` token; the argument lives in [Document G · Why Not](G_WHY_NOT.md).

```text
STATE      lives on the MODEL      (an opponent must read it out of turn)
CAPABILITY lives on the CARD       (what this figure can do)
CAMPAIGN   lives in the APP        (what persists between events)
```

That one split is the whole thesis. Everything below is its consequence.

---

# 1 · The Component Law — SIGNED (William, 2026-07-27)

Six principles. They are not mechanics; they are the **generator** that produced
the card model, the on-model state table, and the base. Keep them for the next
decision — when a new sub-system asks for a token, run it through these first.

```text
1  READ TEST.  Does an opponent need to read this when it is NOT my activation?
                 yes → hardware on the model.   no → it lives in your head.
2  THREE HOMES. State lives on the model. Capability lives on the card.
                 Campaign lives in the app.
3  SUBTRACTIVE > ADDITIVE. Components should DECLINE as the game escalates,
                 not pile up.                              → G·subtractive-beats-additive
4  SETUP IS CHEAP, PLAY IS EXPENSIVE. A component that exists is cheap;
                 a component that MOVES during play is expensive. Zombicide failed on
                 bits that move mid-play, not bits that merely exist.
5  ENCODE THE EXCEPTION, NOT THE DEFAULT. Most of the board is Steady most of the
                 time — do not pay a token for the null state.  → G·encode-the-exception
6  THE BASE IS THE MEASURING INSTRUMENT. Nothing may extend the contact perimeter.
                 Engagement, Reach, `not_in_contact` and Form Up all read base
                 geometry (B·1, B·8, B·11) — so the base must stay honest.
```

**The razor, restated for components.** A–C ask whether a *mechanic* reads or
writes Position, Force, State, a Resource, or a relationship. J asks the physical
question underneath it: **who has to read this, and when?** The answer chooses the
material — model, card, or app — every time.

---

# 2 · Cards — one per unit  `[Presentation → Definition]`

**One card per unit, carrying everything that unit is.** A card is the physical
face of a Figure's Definition (A·IX) — its Role, Tempo, Tool, Temperament, and its
PACKET references. It **holds no runtime state** (Law 5): the card is the same at
the end of the battle as at the start. What changed is on the model, not the card.

```text
FRONT   easy-read, player-facing — Role · Tempo · Tool · Temperament · the numbers
        you glance at (Move, Nerve, Armour class, Wounds), the packet NAMES.
BACK    the Kernel grammar — the packets in full: id · dice · success · grades ·
        effects · constraints (`provokes`, `not_in_contact`, reach).
```

- **Cards stay physical and printed.** The whole point is getting screens off the
  table. The companion app is for **downtime and campaign only** (A·XIX) — it never
  sits between two players during a fight.
- **Only what *varies between figures* goes on the card.** Universal constants —
  **AP = 3**, the morale track, the Grade procedure — live on the laminated
  **reference sheet**, printed once, not reprinted on every unit. `→ G·encode-the-exception`
- **Champions get their own cards** — full abilities, their Circle's break-trigger
  (B·10), fancier art. A Champion is exceptional, so its card is allowed to be.
- **Modular packets are the most errata-friendly print format there is.** A packet
  is defined once and referenced everywhere (A·V); nerf a spear and you reprint one
  small card, not a book. This is Law 1 (one owner) paying rent at the printer.

---

# 3 · Card handling = hand management  `[Presentation → Agency]`

The cards are not just reference — **holding them is the activation economy made
physical.** This costs no new rule; it is the round (B·12) read off your hand.

```text
HAND THICKNESS   = your remaining activations this round.
PUT A CARD DOWN  = that figure has activated (spent its AP).
PICK IT BACK UP  = next round; eligibility resets (B·12).
```

- A **facedown card placed at a model** is the **WAIT trap** — a Brace or Overwatch
  you have armed, shown to the table as *committed* but not as *what*. It is hidden
  information and bluff, sitting exactly where the Kernel already put WAIT (A·III).
- **No draw variance.** Nothing is ever shuffled, drawn, or discarded — the hand is
  a **status display**, not a deck. CUS is deterministic (A·XVI, *determinism as
  trust*); the cards must not smuggle randomness in through the back door.
  `→ G·the-hand-is-not-a-deck`

> **⚠ PROVISIONAL — the free facedown.** An *untriggered* facedown currently costs
> nothing, so waiting and bluffing are both free. Pinning logic softens it (a locked
> chokepoint just ties up the figures holding it while play resolves elsewhere), but
> it is on the watch-list (E · playtest watch). **If it bites: a facedown stays
> committed until that figure's next activation.** Playing decides.

---

# 4 · On-Model State — the table  `[Presentation → State]`

Everything an opponent must read on *your* turn is hardware on the model
(Principle 1). Everything else is in your head.

| State | Encoding | Reads |
|---|---|---|
| **Activation — one flag, a STOPLIGHT** | Tall flag on bendable wire, magnetic base. **GREEN up = ready · YELLOW up = waiting** (an armed WAIT / Overwatch — or Stunned down to waiting) **· gone = spent.** Lay the card **down** on activation. | B·12 |
| **Nerve** | Small swappable flags, **palette kept OFF green/yellow** (poka-yoke — the two flag families must not misread). **Steady gets NO flag** (Principle 5); a flag appears only for Shaken / Broken. | B·10 |
| **Health** | **Model orientation.** Upright = fine · on its side = **Knocked Out** · removed = **Dead.** | B·7 |
| **Armour** | **WYSIWYG from the sculpt.** Tunic/leather reads light, chain reads medium, plate reads heavy. No token. | B·7 |
| **AP** | **In your head.** Universal 3 (reference sheet), spent in a burst while your hand is on the model. | B·12 |

- **One flag, one owner — SIGNED (William, 2026-07-28).** The activation fact lives in a
  **single stoplight flag**, not a flag *and* a card-position. Earlier drafts encoded it
  twice (flag present + card-down-for-waiting), and a desync (card down, flag standing) was
  the likeliest table error in the system — two owners for one fact, a Law-1 break at the
  physical layer. Collapsed: green/yellow/gone says everything, the card just goes down.
  Bonus — **yellow announces commitment** (the facedown card still hides *what* is armed),
  so bluff survives while ambiguity dies. `→ G·one-flag-one-owner`
- **Activation and Nerve are the only added hardware**, and Nerve only when a figure
  has left Steady. Health and Armour are read off the model itself — orientation and
  sculpt — so they cost **nothing** to display. That is Principle 3 (subtractive)
  and Principle 5 (encode the exception) doing the work.
- **A Knocked Out model lies on its side**, which is also the table's memory that it
  *rolls no Armour if hit again* (B·7, `finish-the-downed`). The physical state and
  the rule are the same fact. `→ G·the-model-is-the-marker`

## Resource costs — colour AND shape (the accepted tracker) — SIGNED (William, 2026-07-28)
The three Resource kinds (A·IV) are the one accepted play-time tracker (small dial/clip,
card-side, William signed off at this fidelity). They read by **colour paired with
shape**, never hue alone — the same poka-yoke that keeps the base wells un-confusable
(§5): a colour-blind player or a badly-lit table must still tell them apart.

```text
🟢 Agency   green · a PIP     renews each activation (mostly in-head; AP = 3)
🟡 Charge   yellow · a BAR    finite; a small track that empties (skin: ammo / arrows)
🔴 Strain   red · a WEDGE     accumulates toward a cap (skin: heat / corruption)
```
The public read stays the **card-down** (this gun is offline — reloading or locked); the
exact count is the owner's, glanced off the card. `→ G·the-model-is-the-marker`

---

# 5 · Base construction  `[Presentation → the measuring instrument]`

The base is Principle 6 made of resin: it is what Engagement, Reach,
`not_in_contact` and Form Up actually measure (B·1, B·8, B·11), and it carries the
activation and Nerve flags. It must fit the flags forever and never lie about the
contact perimeter.

```text
TWO recessed magnet wells per base, sculpted INTO the basing scenery — rock, dirt,
tiny wells, fallen bodies — so they read as terrain, not hardware.
```

- **Model the well once as a standalone part and boolean it into every base.**
  Sculpt scenery *around* it, never *into* it — this guarantees every flag fits
  every base, forever, across every future sculpt.
- **Different diameters for the two wells — 2 mm and 1.5 mm** — so a Nerve post
  *physically cannot* enter the Activation hole. **Poka-yoke beats a convention you
  would have to teach.** The parts refuse to be confused.
- **The wall takes the torque; the magnet only takes the lift.** Make it a real
  socket, not a shallow magnet well, or a knocked flag levers the magnet out.
  **Chamfer the mouth** so the post self-centres on the way in.
- **Mark polarity on every base and post as you print** — so a flag never repels
  instead of seating.
- **Build three or four base variants, not sixteen.** Variety is set dressing
  (Principle 4: setup-time is cheap); more than a handful is inventory nobody needs.

> **The base may never extend the contact perimeter.** No banner pole, no cloak, no
> scenic overhang counts as the figure for measurement — the Kernel reads the base
> footprint and only the base footprint (B·1). Scenery on the base is decoration up
> to the rim and irrelevant past it. `→ G·the-base-does-not-lie`

---

# 6 · What varies vs. what is constant

The card/model/reference-sheet split is one question asked three ways:

```text
VARIES BETWEEN FIGURES   → the CARD          (packets, the four axes, the numbers)
TRUE RIGHT NOW           → the MODEL          (activation, nerve, health, position)
TRUE FOR EVERY FIGURE    → the REFERENCE SHEET (AP = 3, the Grade ladder, the tracks)
PERSISTS BETWEEN EVENTS  → the APP            (scars, injuries, gear entropy, upkeep)
```

Put a fact in the wrong place and you pay for it every game: a constant on the card
gets reprinted needlessly, a variable on the reference sheet gets looked up
mid-fight, a runtime state on the card breaks Law 5, and a campaign fact on the
table brings the screen back. **The split is the design.**

---

# 7 · Open component questions — pointer

These are on the register's **playtest watch-list** (E), not settled here. They are
the component decisions most likely to move under real play:

```text
free-facedown        an untriggered WAIT costs nothing — watch bluff/stall (§3)
champion-wounds      a Champion with >1 Wound needs somewhere to COUNT it — the
                     one place a model may need an added counter. They are the ones
                     getting bespoke cards; the count may live there.
form-up-stress       eight figures moving as one body (B·11) is where loose dice,
                     flags and footprints get tested at once. The formation is the
                     stress case for every choice above.
```

Full text and status: **[Document E · Decision Register](E_OPEN_DECISIONS.md)**.

---

# 8 · What this layer owes the Kernel

```text
It OWNS       no Procedure and no primitive. It is Presentation (A·IX).
It TRANSLATES State onto models, Definition onto cards, Persistence onto the app.
It MUST NOT   fork a mechanic, add a rule, or let a component contradict A–C.
It CITES      A·IX (layers) · A·XVI (design principles) · A·XIX (analog interface)
              · B·1 (bases) · B·7 (wounds/armour) · B·10 (nerve) · B·11 (Form Up)
              · B·12 (the round).
```

If a component ever seems to *decide* something, it is reading a rule that lives
elsewhere. Find that rule. If there isn't one, the component is inventing a
mechanic — and that is the one thing this layer may not do.
