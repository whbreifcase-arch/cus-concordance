# CUS — Concordance

**Provenance · migration · jurisprudence · interpretation.**

This repository is the mutable record of *why and how* the CUS corpus migrates. It is a fork of
[`cus-kernel-rebuild`](https://github.com/whbreifcase-arch/cus-kernel-rebuild) — the frozen
**First Corpus** — and inherits its full A–N commit history so lineage is provable.

## The three domains

| Repo | Role | Mutable? | Authoritative for |
|---|---|---|---|
| [`cus-kernel-rebuild`](https://github.com/whbreifcase-arch/cus-kernel-rebuild) | **First Corpus** — frozen historical source | **No** (archived) | What was originally written |
| **`cus-concordance`** (this repo) | **Concordance** — provenance & interpretation | Yes | *Why and how* migration occurred |
| [`cus-second-corpus`](https://github.com/whbreifcase-arch/cus-second-corpus) | **Second Corpus** — rebuilt canon | Yes, governed | Current system behavior |

## Authority in one line
> Second Corpus governs present behavior. Concordance governs the explanation of migration.
> First Corpus governs claims about its own historical text. **No summary outranks its cited source.**

## What is authoritative *here*
Only the governance documents this repo authors:

- **[00_CHARTER.md](00_CHARTER.md)** — the archive charter.
- **[01_AUTHORITY.md](01_AUTHORITY.md)** — the authority hierarchy in full.
- **[04_STATUS_CODES.md](04_STATUS_CODES.md)** — the strict status vocabulary.
- **[TEMPLATE_concordance_entry.md](TEMPLATE_concordance_entry.md)** — the `CON-####` decision format.
- **[PROTECTED_MATERIAL.md](PROTECTED_MATERIAL.md)** — the protected-material index.

> **Inherited A–N files.** The `A_*`…`N_*` documents present in this tree are **lineage only**,
> carried over from the fork point. They are **not** authoritative here — the frozen originals
> live in the First Corpus. They may be pruned from this working tree without loss, since the
> history preserves them.

---
*The First Corpus preserves discovery. The Concordance preserves meaning. The Second Corpus preserves use. The redaction preserves the thing that would be destroyed by explanation.*
