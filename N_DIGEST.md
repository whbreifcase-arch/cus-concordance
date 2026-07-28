# CUS — THE DIGEST
### v0.6 · the jurisprudence register · compiled case-law from adversarial play · signed 2026-07-28 (William)

> **What this is.** The **fourth pillar.** The legislation is A–M; the signed **rulings**
> are [E](E_OPEN_DECISIONS.md); the **rationale** is [G](G_WHY_NOT.md); and this is
> **jurisprudence** — what adversarial contact *discovers* about how the law actually
> plays. Every game's FAQ/errata pile is this, kept informally as sludge. The Digest is it
> **typed, judged, and consumed by the tools.**
>
> **Why the name.** Justinian's *Digest* — compiled case-law — is Rome's most durable
> infrastructure: the aqueducts fell, the *Corpus Juris Civilis* is load-bearing under
> half the world's law fifteen centuries later. The thing that lasts a thousand years is
> **law with an amendment process.** The constitution is not decoration on the game; the
> constitution **is** the game's Roman spine, and the Digest is how it survives contact.
>
> **Authority.** The Digest **records and judges**; it changes nothing by itself. A remedy
> is applied through the existing layers (A–M, E), and the Digest only says *which rung*
> was used and *why*. Where an entry seems to contradict A–M, A–M win until an amendment
> is signed.

---

# 1 · What a Digest entry is

Discovered play is an exception to the designer's expectation — so by Law 15 it lives as a
**named, owned, typed field**, never as FAQ prose. Steal the container doctrine: one entry
per discovery, and the load-bearing field is **the verdict.**

```text
DIGEST ENTRY = {
  id          neutral slug                         e.g. morale-bomb-the-flank
  discovered  the play itself, concretely — the "cheese," reproducible at the table
  reading     from what angle it looks like a break (the accusation)
  verdict     DEGENERATE | TECH        ← SIGNED. the one field a tool cannot set (§2)
  remedy      the rung applied (§3) + what changed  — or "promote" (TECH) / "watch"
  policy      the sim-policy that reproduces it — a permanent regression test (§4)
  signature   who judged it, and when   (a verdict can be re-judged; it carries history)
}
```

An entry is **additive** and **stateless** (Law 5): it records a discovery and a ruling,
it holds no live game-state. The tools read it; the table never has to.

---

# 2 · The verdict — DEGENERATE vs TECH

**Not everything strangers discover is degeneracy. Some of it is depth.** From the wrong
angle, **squelch** looks like an exploit ("morale-bombing the flank"); a fighting game's
**wavedash** was an *engine glitch* that became the skill ceiling. **If the register
auto-prevents everything strangers find, it sterilises the exact emergence the system
exists to produce.** So every entry is judged:

```text
DEGENERATE  collapses decision-space · violates a G-slug's intent · boring to play against
            →  remedy it (§3). Kill it at the cheapest rung that holds.
TECH        expands decision-space · rewards mastery · reads as a discovered skill
            →  PROMOTE it. Name it, teach it, and it becomes canon — a new G-slug, a named
               mechanic, or scenario-designer guidance. Discovered play → law.
```

**The verdict is a judgment, not a fact (Law 10).** Detection, remedy, and regression can
all be tooled — the DEGENERATE/TECH call cannot. It requires taste, and so it is **signed**,
exactly like a ruling in E. `→ G·the-verdict-is-a-judgment`

**A verdict can be re-judged.** A TECH that later collapses the meta is re-tried and can
fall to DEGENERATE; a play first ruled DEGENERATE may, under a later standard, be re-read as
TECH. The Digest is **living** case-law — the signature carries the date, and the history
stays in the entry. This is the whole difference between a Digest and a dead FAQ.

---

# 3 · The remedy ladder — cheapest first

A DEGENERATE entry is repaired at the **lowest rung that holds.** The ladder is not
arbitrary: **each rung is a different layer's tool.** Most exploits die at rungs 1–2
without the law ever feeling it — *local repairs, rare rewrites of the standard,* which is
the actual Roman maintenance doctrine.

```text
RUNG                        LAYER / TOOL                         cost
1  authoring constraint     the scenario generator stops         cheapest — the law
   — deny the geometry      building the geometry that enables   never feels it
     that enables it        it  (SCENARIO_PROMPT, Document L)
2  price adjustment         the pricer re-values the piece       cheap
                            (factions/sim · balance.py)
3  packet field change      a data edit — a named field flips    moderate — content only
                            (K · factions/data)
4  constitutional amendment the standard itself changes          expensive — SIGNATURE
                            (A / E, a new signed batch)           required, rare
```

Reach for rung 4 only when the discovery proves the *standard* is wrong, not merely a map
or a price. `→ G·remedy-at-the-cheapest-rung`

---

# 4 · CI for legislation — every entry becomes a sim policy

The move that turns the register from paperwork into infrastructure:

> **Every registered exploit is written as a scripted sim policy that reproduces the
> cheese** — and every future signing **re-runs all policies against the new law
> automatically.**

Discovered breaks become **permanent regression tests.** If a later amendment silently
re-opens a closed exploit, its policy **fails the run**, and the register catches it
*before it ships*. This is not a wargame practice — it is **continuous integration for
legislation**, and it is the honest mechanism by which a system maintained by **one
person** survives adversarial contact for decades.

- The sim already ships **mechanic-assertion scenarios** (`factions/sim/scenarios.py`).
  Digest policies are the *same object*, pointed at **discovered** play instead of intended
  play. The Digest extends that harness; it does not invent one.
- A **TECH** entry gets a policy too — an *assertion that the depth still works.* Promote a
  tech, and you must not let a future edit quietly delete it.

```text
SIGN A NEW BATCH  →  re-run every Digest policy against the amended law
   DEGENERATE policy now PASSES (exploit still dead)   → good, ship
   DEGENERATE policy now FAILS  (exploit re-opened)    → block: the amendment regressed
   TECH policy now FAILS        (depth deleted)        → block: the amendment sterilised it
```

---

# 5 · The loop — how discovered play becomes canon

The Kernel's own decision loop (A·XII), run at the **design** level:

```text
LEGISLATION (A–M)  →  PLAY  →  a stranger discovers something
        ↓
THE DIGEST: record it → JUDGE it (DEGENERATE | TECH), signed
        ↓                                   ↓
   DEGENERATE                             TECH
   remedy at the cheapest rung (§3)       PROMOTE — name it, teach it → it becomes
        ↓                                 a G-slug / a named mechanic / designer guidance
   write the sim POLICY (§4) ← ─────────────┘
        ↓
   every future signing re-runs it — discovered play is now permanent law
```

Four pillars, and now the loop is closed: **legislation** proposes, **rulings** decide,
**rationale** defends, and **jurisprudence** learns from contact and feeds the other three.

---

# 6 · What the Digest owes the Kernel

```text
It OWNS       the record and the verdict of discovered play. It changes no rule by itself.
It USES       Law 15 (every entry is a named field, not FAQ prose) · Law 10 (the verdict is
              a judgment, signed) · Law 5 (entries are stateless) · A·XII (the loop).
It FEEDS      G (a promoted TECH becomes a slug) · E (a rung-4 remedy is a signed amendment)
              · the scenario generator (rung-1 constraints) · the pricer (rung-2) · the sim
              (every entry is a regression policy).
It MUST NOT   auto-prevent what strangers find — that sterilises emergence. It JUDGES first.
```

The register is not just an immune system. It is how the game **keeps learning** — the part
of the constitution that turns a thousand strangers into co-authors, one signed verdict at
a time.
