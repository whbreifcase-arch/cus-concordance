# 01 — Authority

The authority hierarchy that resolves conflicts between the corpora and their commentary.

## The hierarchy

```text
Second Corpus  governs  present implementation and current system behavior.
Concordance    governs  the explanation of migration — why and how a rule moved.
First Corpus   governs  claims about its own historical text — what was written.
Simulation     governs  empirical claims, only within its tested conditions.
```

And the cross-cutting rule that binds all four:

> **No summary outranks its cited source.**

## How to read the hierarchy

- If you want to know **what the system does now**, the Second Corpus is authoritative. If the
  Second Corpus is silent, the behavior is undefined — not inherited by default from the First.
- If you want to know **why a rule changed**, the Concordance is authoritative. The Second Corpus
  states rules; it does not defend them. The defense lives here.
- If you want to know **what was originally written**, only the First Corpus can settle it — and
  only its literal text, not anyone's paraphrase.
- If you want to make an **empirical claim** ("humans lose disproportionately through Morale"),
  simulation evidence is authoritative *only inside the conditions it actually tested*. It does
  not license a general law.

## Conflict resolution order

1. A claim about present behavior → Second Corpus wins.
2. A claim about *why* → Concordance wins.
3. A claim about the original text → First Corpus literal text wins.
4. A claim of empirical fact → the cited simulation, scoped to its conditions, wins.
5. Any summary vs. its source → the source wins.

Where two documents of equal rank conflict, the conflict is not resolved by prose seniority. It
becomes a `CON-####` case (see [TEMPLATE_concordance_entry.md](TEMPLATE_concordance_entry.md))
and is ruled on explicitly.
