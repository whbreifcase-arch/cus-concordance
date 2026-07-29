# 04 — Status Codes

The strict status vocabulary. Every migrated rule, concept, and case carries exactly one status.
Vague labels like "done" are banned — they hide whether a thing was verified, contested, or merely
transcribed.

| Status | Meaning |
|---|---|
| `UNREVIEWED` | Present in the First Corpus; not yet examined. |
| `EXTRACTED` | Pulled into an inventory verbatim; not yet analyzed. |
| `CONTESTED` | Two sources or two readings disagree; a case is open. |
| `PROVISIONAL` | A temporary ruling is in force pending evidence. |
| `MIGRATED` | Carried into the Second Corpus with a destination recorded. |
| `SPLIT` | One First-Corpus concept became several. |
| `MERGED` | Several First-Corpus concepts became one. |
| `RENAMED` | Same concept, new canonical name (alias recorded). |
| `SUPERSEDED` | Replaced by a different mechanism; old form retired. |
| `REJECTED` | Deliberately not carried forward; loss report required. |
| `RESERVED` | A slot held open for a concept not yet built. |
| `PROTECTED` | Non-reducible; see [PROTECTED_MATERIAL.md](PROTECTED_MATERIAL.md). |
| `REDACTED` | Concealed in public canon; preserved in full in custody. |
| `UNRESOLVED` | An open question with no ruling yet; must not hide in prose. |
| `VALIDATED` | Tested (mechanically, in play, or in simulation) and confirmed. |

## Rules of use

- Every deletion (`REJECTED`) requires a **loss report**: what becomes impossible to express, what
  historical evidence resists it, what emergent behavior may disappear.
- Every merge (`MERGED`) requires a **distinction report**: proof the merged concepts were not in
  fact meaningfully different.
- Every new primitive requires a **necessity proof**.
- `VALIDATED` may only be claimed with a citation to the test that validated it.
