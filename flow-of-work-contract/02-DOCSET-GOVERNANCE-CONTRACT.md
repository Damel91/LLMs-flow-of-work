---
doc_type: docset_governance_contract
scope: documentation_control
applies_to: multi-platform
version: 0.3
status: working
last_updated: 2026-04-25
---

# Docset Governance Contract

## 0. Quick Rules

1. The documentation system is layered, not flat.
2. Each document type answers a different question and must keep one role.
3. `REQUIREMENTS_DIFF_INDEX.md` declares which diff is active.
4. The active `REQUIREMENTS_DIFF_*` named by the diff index governs the current
   initiative until acceptance and remains as durable historical contract
   record afterward.
5. `IMPL-*` packets execute the active diff or accepted baseline, but do not
   replace either.
6. `TestCampaign-*` records evidence, not plan.
7. `TRACEABILITY_MATRIX.md` records accepted fact only after evidence.
8. When one document layer temporarily supersedes another, that precedence must
   be explicit.
9. Baseline is the stable bone structure; accepted diffs are not merged into
   baseline by default.
10. Only the current head diff of a change line is editable; opening a
   successor freezes all predecessors as history.

## 1. Purpose

This document defines how the documentation set is governed when multiple
layers coexist:

- baseline requirements
- active and accepted requirement diffs
- scenario and use-case definitions
- implementation packets
- test campaigns
- the traceability matrix

It is not a product requirements document and it is not an implementation
packet. It is the authority contract for document synchronization.

The documentation set is intentionally used as a control system for
collaboration with LLMs. Document-role clarity is therefore part of the
engineering method, not just repository hygiene. This makes propagation
discipline a first-class part of the project, not an optional practice.

## 2. Authority Stack

Use the following authority order when working on an active initiative:

1. `01-LLM-SESSION-CONTRACT.md` for LLM session behavior
2. this document for document-layer authority and sync rules
3. `03-BEHAVIORAL-DEFINITION-GATE.md` for blocked states caused by missing
   behavior definitions
4. `REQUIREMENTS_DIFF_INDEX.md` for selecting the active diff
5. active `REQUIREMENTS_DIFF_*` for current product scope change
6. canonical `REQUIREMENTS*` for accepted baseline intent
7. `USE_CASES_AND_SEQUENCES.md` for scenario meaning
8. active `IMPL-*` for bounded execution
9. `TestCampaign-*` for acceptance evidence
10. `TRACEABILITY_MATRIX.md` for accepted factual status

Important distinction:

- active diff governs current change intent
- diff index identifies which diff is active and which diff is the editable
  head of a change line
- only one diff may be the active implementation target at a time; other
  change lines may remain parked in the diff index ledger
- baseline governs accepted stable bone structure
- accepted diffs preserve accepted contract evolution and remain readable history
- active diff may temporarily supersede affected use cases and sequences
- matrix governs accepted factual reality

For any one change line, only one diff is the editable head at a time.
Older diffs are historical records, not mutable working drafts.

## 3. Document Roles

| Document | Role | Must not be used as |
|---|---|---|
| `REQUIREMENTS*` | Stable accepted bone structure | active feature diff or exhaustive history of every accepted change |
| `REQUIREMENTS_DIFF_INDEX.md` | Active diff pointer and diff ledger | product behavior contract or evidence |
| `REQUIREMENTS_DIFF_*` | Current product scope evolution and durable historical change record after acceptance | factual implementation proof |
| `USE_CASES_AND_SEQUENCES.md` | Scenario contract, subject to scoped supersession by the active diff when explicitly declared | packet plan or matrix |
| `IMPL-*` | Bounded execution initiative | final product contract |
| `TestCampaign-*` | Executed validation evidence | implementation plan |
| `TRACEABILITY_MATRIX.md` | Accepted repo reality | future intent |

## 4. Propagation Rules

When a new `REQUIREMENTS_DIFF_*` is opened, it must identify propagation impact
across the rest of the docset.

Before implementation work starts, `REQUIREMENTS_DIFF_INDEX.md` must identify
that diff as the current active head. If the index points elsewhere, the new
diff is draft material only.

Minimum propagation questions:

1. Which baseline requirement statements are now stale or incomplete?
2. Which use cases or sequences are temporarily superseded for this initiative?
3. Which root `IMPL-*` is opened by this diff?
4. Which traceability rows are expected to move only after acceptance?
5. Does `REQUIREMENTS_DIFF_INDEX.md` point to this diff as active head?

The active root `IMPL-*` should carry the initiative ledger for those
propagation targets during execution.

### 4.1 Diff Mutability And Succession

Use the following rules for multiple diffs touching the same requirement area
or change line:

1. The active head diff named by `REQUIREMENTS_DIFF_INDEX.md` is the only
   editable diff for implementation planning.
2. Parked draft lines are non-governing until the index promotes one of them
   to active head.
3. A head diff should normally be amended in place while it is still the
   current working statement of intent.
4. Opening a successor diff immediately freezes the predecessor as historical
   record, even if the predecessor has not yet been covered by an authoritative
   campaign.
5. After a successor exists, the predecessor must not be rewritten. Any
   correction, rollback, or refinement must be expressed in the active head
   diff or in a newer successor.
6. A previously superseded diff never becomes governing again directly. If the
   user wants to return to an older behavior, a new successor diff must say so
   and be registered as the active head in `REQUIREMENTS_DIFF_INDEX.md`.

Practical consequence:

- campaign closure is one way a diff becomes historically stable
- successor creation is another
- retroactive editing of non-head diffs is prohibited because it changes
  project history

## 5. Temporary Supersession And Staleness

Baseline requirements and scenario documents may temporarily lag behind an
active diff.

That is allowed only if all of the following are true:

- the active diff clearly states the changed product scope
- the active diff explicitly declares any affected scenario meaning that is
  temporarily superseded
- the root `IMPL-*` clearly references the active diff
- conflicting baseline or interaction text is treated as historical for the
  moment, not as the governing rule for the initiative
- the contradiction is not hidden

Recommended markers:

- `deprecated as public contract`
- `superseded by active diff`
- `historical baseline text preserved`
- `historical interaction text preserved`
- `stale until canonical refresh`

Silence is not acceptable when two layers disagree.

## 6. Conflict Resolution

When documents disagree, resolve them in this order:

1. process rules from `01-LLM-SESSION-CONTRACT.md`
2. doc-layer authority from this contract
3. behavior blocking rules from `03-BEHAVIORAL-DEFINITION-GATE.md`
4. `REQUIREMENTS_DIFF_INDEX.md` when deciding which diff is active
5. active `REQUIREMENTS_DIFF_*`
6. accepted baseline `REQUIREMENTS*`
7. scenario meaning from `USE_CASES_AND_SEQUENCES.md`
8. bounded execution details from active `IMPL-*`
9. factual evidence from `TestCampaign-*`
10. accepted status from `TRACEABILITY_MATRIX.md`

If an active diff explicitly changes scenario meaning for a bounded scope, that
scoped reading prevails over conflicting passages in
`USE_CASES_AND_SEQUENCES.md` until an explicit canonical refresh or a later
superseding diff changes it again.

If multiple accepted diffs touch the same requirement area, the most recent
accepted diff is the governing historical interpretation. Older accepted diffs
remain auditable history only.

If the conflict cannot be resolved without changing scenario meaning or product
scope, stop and route through the user.

## 7. Post-Acceptance Canonical State

After an initiative is accepted through evidence:

1. keep the accepted `REQUIREMENTS_DIFF_*` as a durable historical contract
   record
2. update `TRACEABILITY_MATRIX.md` from evidence
3. keep historical `IMPL-*` packets as execution history
4. optionally refresh canonical baseline and/or
   `USE_CASES_AND_SEQUENCES.md` if a curated restatement improves readability
5. retire or mark stale temporary contradictions only when a canonical refresh
   or explicit supersession makes them obsolete

Canonical refresh is a curation activity, not an automatic acceptance step.
Baseline is not required to absorb every accepted diff.

## 8. Initiative Ledger Rule

Each root `IMPL-*` should act as the live initiative ledger for its change
family.

The root packet should identify:

- active governing diff
- affected scenario layer
- baseline areas known to be stale during execution
- expected test campaign
- expected post-acceptance canonical refresh targets, if any

This keeps initiative-specific synchronization out of the global contracts.

## 9. Prohibited Behaviors

Do not:

- treat the matrix as product scope authority
- infer the active diff from the highest version number, latest modified file,
  or stale status fields inside individual diff files
- treat an active diff as accepted baseline after implementation but before
  evidence
- update canonical baseline during an initiative without making supersession
  explicit
- assume acceptance requires baseline merge
- erase accepted diff history by silently absorbing it into baseline
- edit a non-head diff after a successor exists
- edit a diff that is not the active head named by `REQUIREMENTS_DIFF_INDEX.md`
- reactivate an older diff directly instead of opening a new successor diff
- use `IMPL-*` as product-law replacement for requirements
- use a `TestCampaign-*` as if it were an implementation plan
- leave conflicting document layers ambiguous

## 10. Project Overlay

Replace this section with project-specific document governance constraints.

The overlay must identify, at minimum:

- any document locations that differ from the defaults in
  `authorities/flow-of-work-contract/05-PROJECT-STRUCTURE.md`
- any additional document types introduced by the project and their role in
  the authority stack
- any project-specific propagation rules that extend section 4
