# IMPL-INDEX — Implementation Packet Index

**Version:** 0.2
**Status:** Template — replace with project-specific content
**Last updated:** YYYY-MM-DD

> Language configuration for this document and the entire docset is declared
> in `authorities/PROJECT-OVERLAY.md`, section 3. Read that file first.

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
maintained in `authorities/PROJECT-OVERLAY.md`, section 3.

Two fields are defined there:

- **Conversation language** — the language used between the user and the
  active model during working sessions.
- **Documentation language** — the language used to produce all documents:
  contracts, requirements, requirement diffs and indexes, IMPL packets and
  indexes, review records and indexes, test campaigns and indexes,
  environment startup helpers, and the traceability matrix.

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

An integer packet may also be a root implementation family. Use this when the
initiative is one coherent architectural or product boundary but must execute
through multiple safe subpackets. In that case:

- `IMPL-N` carries the family ledger, governing diff, packet ordering, and
  acceptance gate
- `IMPL-N.0`, `IMPL-N.1`, etc. carry concrete executable slices
- the index must list both the root and each generated subpacket
- subpackets do not replace the root packet's boundary; they execute inside it

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
| `Scaffolded` | Non-terminal active state: bone structure, interfaces, or partial wiring exist, but owned behavior is not complete |
| `Implemented` | Packet has been executed and its intended runtime/code changes are live |
| `Merged` | Packet's core intent is reflected in the live code and canonical docs |
| `Merged with open drift` | Packet landed, but a documented behavioral gap remains |
| `Partially merged` | Some parts are live, others remain incomplete |
| `Pending acceptance` | Candidate fixes or status changes not yet accepted as baseline |
| `Closed after empirical validation` | Accepted after live or model-facing validation, not just code completion |
| `Superseded` | Historically important, but no longer the live architectural shape |
| `Absorbed` | Packet boundary was replaced, but valid decisions were preserved in another diff, spec, or IMPL family |
| `Deferred` | Design record only — execution intentionally postponed |
| `Cancelled` | Explicitly dropped — no follow-up |

**Drift rule**: if the Notes column contradicts the State column, State must be
updated. A note that says "executed" while State says "Planned" is a
documentation failure, not a valid workaround.

**Completion rule**: `Implemented` is allowed only when the packet's completion
criteria ledger shows every in-scope criterion as complete or not applicable.
`Scaffolded`, `Partially merged`, and `Pending acceptance` are not shame states;
they are the required states when the model produced useful movement but did
not finish the behavior. Do not record progress as completion to make the
chain look healthier than it is.

`Scaffolded` is not a closure state. A scaffolded packet remains active and
must route to one of:

- continued execution in the same packet;
- a follow-up packet that owns the remaining behavior;
- `Partial` / `Partially merged` with explicit accepted subset and residual
  blockers;
- `Blocked`, `Deferred`, `Superseded`, or `Cancelled` with explicit reason.

If no follow-up or blocker route exists, keep the packet `In progress` instead
of using `Scaffolded` as a final resting state.

---

## 5. Packet Index

Replace the placeholder row with your project's packets.
Add rows as initiatives are created. Do not delete rows — use `Superseded` or
`Cancelled` instead.

| Packet | Topic | State | Notes |
|---|---|---|---|
| `IMPL-00-[SLUG].md` | [foundational topic] | Open | [notes] |

---

## 6. Active Diff Planning

Use this section when an active requirements diff has generated or is about to
generate an implementation family.

Current active diff: `[REQUIREMENTS_DIFF_* / none]`

Current active implementation family: `[IMPL-N / none]`

Planning note:

- [which blockers, requirement families, or scope items drive the first
  implementation wave]
- [which later packets remain in the active diff but are intentionally not
  first]
- [which old packet, if any, was absorbed or replaced]

Concrete packets:

| Packet | Executes diff packet / requirement | State | Notes |
|---|---|---|---|
| `IMPL-N-[SLUG].md` | [root / diff packet ID] | Planned decomposition | [family boundary] |
| `IMPL-N.0-[SLUG].md` | [slice] | Planned | [dependency or prerequisite] |

---

## 7. Quick Operational Summary

> **This section is a non-authoritative working reminder.**
> If it conflicts with `01-LLM-SESSION-CONTRACT.md`, the contract wins.
> Its purpose is to let the active model orient quickly without re-reading
> the full contract set during an ongoing session.

**When opening a new initiative:**

1. Classify the request against the existing contract.
2. If product scope changes: open a `REQUIREMENTS_DIFF_*` first.
3. Open one atomic `IMPL-*`, or a root family plus subpackets when the boundary
   is coherent but too broad for one slice.
4. Execute only what the active model can safely self-validate.
5. Fill the packet completion criteria ledger before claiming implementation.
6. After each implemented, scaffolded, partial, or blocked packet, update the
   packet status and this index honestly.
7. Run model code review before handoff.
8. Check `REVIEW-INDEX.md` before handoff if any review hold overlaps the
   packet.
9. Open a `TestCampaign-*` only after the readiness gate passes, and update
   `TEST-CAMPAIGN-INDEX.md` when the campaign state changes.
10. Update the installed `TRACEABILITY_MATRIX.md` only after accepted campaign
   evidence.

**When resuming a session:**

1. Read this index to locate the active packet.
2. Read the active `IMPL-*` for full packet scope.
3. Read the governing `REQUIREMENTS_DIFF_*` if product scope is still evolving.
4. Read `REVIEW-INDEX.md` and `TEST-CAMPAIGN-INDEX.md` when they reference the
   active packet or diff.
5. If the repository layout is unfamiliar, read `05-PROJECT-STRUCTURE.md` first.
6. Do not continue from model memory alone.

**Hard rules (always apply):**

- Missing behavior is a blocker. Do not invent it.
- The user is the routing authority for scenario or structural changes.
- The installed `TRACEABILITY_MATRIX.md` moves only from evidence, never from
  intent.
