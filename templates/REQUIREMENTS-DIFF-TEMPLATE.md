# REQUIREMENTS_DIFF_[ID]-[SLUG]

**Version:** 0.1
**Status:** Template reference
**Created:** YYYY-MM-DD
**Activated:** [YYYY-MM-DD / not active]
**Governing baseline:** [baseline document references]
**Change line:** [short change-family name]
**Head status:** [head / superseded by REQUIREMENTS_DIFF_* / historical]

> This is a product-contract change document.
> It is not implementation evidence and not an IMPL packet.
> When installed in a destination project, this file is a category reference
> for creating new `REQUIREMENTS_DIFF_*` documents. Copy it, rename the copy,
> replace all placeholders, and leave this template unchanged.

---

## 1. Purpose

Describe the product-scope change in one or two paragraphs.

State whether this diff:

- introduces new product behavior
- changes existing behavior
- removes behavior
- corrects or supersedes a previous diff
- clarifies behavior that was previously under-specified

---

## 2. Authority And Succession

**Current authority:** [head diff / successor diff / historical only]

**Supersedes:** [none / REQUIREMENTS_DIFF_*]

**Superseded by:** [none / REQUIREMENTS_DIFF_*]

**Absorbed design inputs:** [none / IMPL-* / spec path / review path]

**Editable:** [yes / no]

**Diff index registration:** [active head / parked draft / superseded history / accepted history / rejected history]

Rules:

- only the current head diff in a change line is editable
- the current head is the one named by `REQUIREMENTS_DIFF_INDEX.md`
- opening a successor freezes predecessors as history
- returning to older behavior requires a new successor diff, not rewriting history
- if an earlier IMPL or spec is absorbed, preserve valid decisions here and
  make clear that the old document is no longer the active execution source

---

## 3. Scope

### In Scope

- [behavior, scenario, or requirement family changed by this diff]

### Out Of Scope

- [nearby behavior intentionally not changed]

### Non-Goals

- [what this diff explicitly does not attempt to solve]

---

## 4. Requirement Changes

### Added Requirements

| ID | Requirement |
|---|---|
| `FR-[AREA]-NN` | [new functional requirement] |
| `NFR-[AREA]-NN` | [new non-functional requirement] |

### Modified Requirements

| ID | Previous reading | New reading |
|---|---|---|
| `FR-[AREA]-NN` | [old accepted meaning] | [new governing meaning] |

### Removed Requirements

| ID | Removal reason | Replacement, if any |
|---|---|---|
| `FR-[AREA]-NN` | [why removed] | [new ID or none] |

---

## 5. Interaction And Sequence Impact

List every affected use case or sequence.

| Use case / sequence | Impact | Governing note |
|---|---|---|
| [name] | [added / modified / temporarily superseded / unchanged] | [short explanation] |

If this diff temporarily supersedes text in `USE_CASES_AND_SEQUENCES.md`,
state that explicitly.

---

## 6. Concept Closure

For every new concept introduced by this diff, close the required dimensions.

| Concept | Producer | Ownership | Persistence | Consumer | Invalidation / lifecycle | Test surface |
|---|---|---|---|---|---|---|
| [concept name] | [who creates it] | [model-owned / runtime-derived / persisted / rendered-only] | [where stored or none] | [who reads it] | [when it changes or expires] | [how it is validated] |

If any dimension is unknown, this diff is not ready for implementation.

---

## 7. Behavioral Definition

Define all behavior needed for safe implementation.

Include, when relevant:

- user-visible flow
- routing or clarification behavior
- prompt output schema
- graph or state-machine transition
- fallback behavior
- error behavior
- strictness of validation

If behavior depends on existing working code, name the reference explicitly.

---

## 8. Propagation Impact

| Layer | Impact |
|---|---|
| Baseline requirements | [none / stale / optional canonical refresh target] |
| Functional requirements | [none / affected IDs] |
| Non-functional requirements | [none / affected IDs] |
| Use cases and sequences | [none / affected flows] |
| Root IMPL | [expected root IMPL ID or TBD] |
| Test campaign | [expected campaign scope or TBD] |
| Traceability matrix | [expected Gap / Partial / Implemented movement after evidence] |

If the diff opens a root implementation family, name the root family and first
packet explicitly. If later packets remain intentionally late, state that so
the IMPL index and campaign index do not imply full execution readiness.

---

## 8.1 Implementation Packet Split

Use this section when the diff is broad enough to require multiple packets.

| Packet | Purpose | Prerequisite | Execution status |
|---|---|---|---|
| [R.0 / IMPL-N] | [root boundary or first slice] | [none] | [not generated / planned / implemented] |
| [R.1 / IMPL-N.1] | [slice] | [packet] | [not generated / planned / implemented] |

The packet split is planning authority only. It becomes executable when the
corresponding `IMPL-*` packet exists and is registered in the IMPL index.

---

## 9. Acceptance Criteria

This diff can be considered accepted only when:

- [criterion tied to behavior or requirement]
- [criterion tied to evidence]
- [criterion tied to user acceptance, if needed]

---

## 10. Open Questions

| Question | Owner | Blocking? |
|---|---|---|
| [question] | [user / model / future IMPL] | [yes / no] |

If any blocking question remains, do not proceed to implementation.
