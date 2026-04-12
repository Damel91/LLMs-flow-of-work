# IMPL-INDEX — Implementation Packet Index

**Version:** 0.1
**Status:** Template — replace with project-specific content
**Last updated:** YYYY-MM-DD

> Language configuration for this document and the entire docset is declared
> in `authorities/PROJECT-OVERLAY.md`, section 2. Read that file first.

---

## 1. Purpose

The `IMPL-*.md` files are bounded execution packets.

They capture:

- the rollout plan that originally drove a change,
- the reasoning behind architectural choices,
- file-level implementation notes,
- and checklists used during development.

They are valuable as implementation history, but they are not the canonical
source of truth once their intent has been reflected in the governing
requirement corpus declared in `authorities/PROJECT-OVERLAY.md`, section 10.

Default canonical documents are the installed baseline set, the installed
interaction document, the governing accepted diff history, and the installed
traceability matrix described by
`authorities/flow-of-work-contract/05-PROJECT-STRUCTURE.md`.

If the project has adapted the default structure, the actual locations are
recorded in `authorities/PROJECT-OVERLAY.md`, section 10. Those locations
take precedence over any canonical defaults.

Older checklist items may remain unchecked even when the repo later evolved.
Treat checklist state as archival, not as the current implementation status.

---

## 2. Document Language

Language settings for this document and the entire docset are declared and
maintained in `authorities/PROJECT-OVERLAY.md`, section 2.

Two fields are defined there:

- **Conversation language** — the language used between the user and the
  active model during working sessions.
- **Documentation language** — the language used to produce all documents:
  contracts, requirements, IMPL packets, test campaigns, and the traceability
  matrix.

The active model must read the overlay to determine both values. It must not
infer either from the conversation alone.

**Drift rule**: if any document in the docset is found in a language other
than the declared documentation language, it must be corrected before it is
considered canonical. Mixed-language documents are a documentation failure.

---

## 3. Naming Convention

Packet IDs follow this scheme:

- `IMPL-N` — an independent initiative (integer)
- `IMPL-N.M` — a dependent follow-up on `IMPL-N` (decimal)
- `IMPL-N.M.P` — a further dependent sub-step on `IMPL-N.M`

An integer packet is independent of any other.
A decimal packet depends on its root integer packet.
Bundling unrelated initiatives into one packet is not allowed.

File naming: `IMPL-[ID]-[SLUG].md`

Slug rules:
- Written in the **documentation language** declared in
  `authorities/PROJECT-OVERLAY.md`
- Uppercase words separated by hyphens
- Descriptive of the primary objective, not the mechanism
- No special characters, no spaces

Examples with documentation language English:
`IMPL-03-CONTEXT-POLICY.md`, `IMPL-03.1-TRIMMING-FIX.md`

Examples with documentation language Italian:
`IMPL-03-POLICY-CONTESTO.md`, `IMPL-03.1-CORREZIONE-TRIM.md`

---

## 4. Packet State Vocabulary

| State | Meaning |
|---|---|
| `Open` | Packet exists and is the active implementation record for unresolved work |
| `In progress` | Execution underway inside packet boundary |
| `Planned` | Packet is defined but not yet executed |
| `Planned decomposition` | Root initiative packet that defines a multi-packet execution chain |
| `Implemented` | Packet has been executed and its intended runtime/code changes are live |
| `Merged` | Packet's core intent is reflected in the live code and canonical docs |
| `Merged with open drift` | Packet landed, but a documented behavioral gap remains |
| `Partially merged` | Some parts are live, others remain incomplete |
| `Pending acceptance` | Candidate fixes or status changes not yet accepted as baseline |
| `Closed after empirical validation` | Accepted after live or model-facing validation, not just code completion |
| `Superseded` | Historically important, but no longer the live architectural shape |
| `Deferred` | Design record only — execution intentionally postponed |
| `Cancelled` | Explicitly dropped — no follow-up |

**Drift rule**: if the Notes column contradicts the State column, State must be
updated. A note that says "executed" while State says "Planned" is a
documentation failure, not a valid workaround.

---

## 5. Packet Index

Replace the placeholder row with your project's packets.
Add rows as initiatives are created. Do not delete rows — use `Superseded` or
`Cancelled` instead.

| Packet | Topic | State | Notes |
|---|---|---|---|
| `IMPL-00-[SLUG].md` | [foundational topic] | Open | [notes] |

---

## 6. Quick Operational Summary

> **This section is a non-authoritative working reminder.**
> If it conflicts with `01-LLM-SESSION-CONTRACT.md`, the contract wins.
> Its purpose is to let the active model orient quickly without re-reading
> all four contracts during an ongoing session.

**When opening a new initiative:**

1. Classify the request against the existing contract.
2. If product scope changes: open a `REQUIREMENTS_DIFF_*` first.
3. Open one atomic `IMPL-*` for the bounded execution slice.
4. Execute only what the active model can safely self-validate.
5. Run model code review before handoff.
6. Open a `TestCampaign-*` only after the readiness gate passes.
7. Update the installed `TRACEABILITY_MATRIX.md` only from evidence.

**When resuming a session:**

1. Read this index to locate the active packet.
2. Read the active `IMPL-*` for full packet scope.
3. Read the governing `REQUIREMENTS_DIFF_*` if product scope is still evolving.
4. If the repository layout is unfamiliar, read `05-PROJECT-STRUCTURE.md` first.
5. Do not continue from model memory alone.

**Hard rules (always apply):**

- Missing behavior is a blocker. Do not invent it.
- The user is the routing authority for scenario or structural changes.
- The installed `TRACEABILITY_MATRIX.md` moves only from evidence, never from
  intent.
