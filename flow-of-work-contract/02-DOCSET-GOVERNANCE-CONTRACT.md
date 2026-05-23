---
doc_type: docset_governance_contract
scope: documentation_control
applies_to: multi-platform
version: 0.6
status: working
last_updated: 2026-05-23
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
11. A root `IMPL-*` may define an implementation family; dependent packets
    execute slices inside that family.
12. If an `IMPL-*` packet has the wrong boundary but contains valid decisions,
    preserve those decisions in the active diff or replacement family instead
    of executing the packet as written.
13. After each implemented packet, update the packet itself and `IMPL-INDEX.md`
    before moving to validation.
14. Full documentation alignment happens only after a green campaign or after
    explicit user acceptance of a partial/constrained campaign.
15. If a campaign exposes blockers, keep the evidence, route fixing packets,
    rerun regression/live validation, and delay full documentation alignment
    until acceptance.

## 1. Purpose

This document defines how the documentation set is governed when multiple
layers coexist:

- baseline requirements
- active and accepted requirement diffs
- scenario and use-case definitions
- implementation packets
- review and clarification holds
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
9. `REVIEW-INDEX.md` for active review hold discovery
10. active `Review-*` / `REVIEW-*` records for holds that constrain execution
   or acceptance
11. `TEST-CAMPAIGN-INDEX.md` for campaign navigation and acceptance-state lookup
12. `TEST-ENVIRONMENT-STARTUP.md` for reusable validation startup procedure,
    when a campaign references it
13. `06-VALIDATION-EXECUTION-CONTRACT.md` for validation design and execution
    quality
14. `TestCampaign-*` for acceptance evidence
15. `TRACEABILITY_MATRIX.md` for accepted factual status

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
| `REVIEW-INDEX.md` | Active review hold and clarification navigation | evidence or implementation packet |
| `Review-*` / `REVIEW-*` | Clarification, risk, or acceptance hold record | implementation packet or evidence |
| `TEST-CAMPAIGN-INDEX.md` | Campaign navigation, campaign acceptance state, and active review links | validation evidence |
| `TEST-ENVIRONMENT-STARTUP.md` | Reusable environment startup and preflight procedure for campaigns | campaign result or acceptance evidence |
| `06-VALIDATION-EXECUTION-CONTRACT.md` | Validation design and execution quality contract | campaign evidence or implementation plan |
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
3. Which root `IMPL-*` or root implementation family is opened by this diff?
4. Which traceability rows are expected to move only after acceptance?
5. Does `REQUIREMENTS_DIFF_INDEX.md` point to this diff as active head?
6. Are any earlier IMPL packets absorbed, replaced, or preserved as design
   input rather than executed directly?

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
9. active review holds for affected scope
10. validation execution rules from `06-VALIDATION-EXECUTION-CONTRACT.md`
11. factual evidence from `TestCampaign-*`
12. accepted status from `TRACEABILITY_MATRIX.md`

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

### 7.1 Packet Completion Versus Campaign Acceptance

Packet completion and campaign acceptance are different document events.

After each implemented packet or subpacket, update only packet-execution state:

- the packet status, evidence notes, and residual risks;
- `IMPL-INDEX.md`;
- review holds or review index rows that the packet actually resolves;
- deterministic self-check notes.

Do not perform full documentation alignment at this point. Do not update
`TRACEABILITY_MATRIX.md` as accepted reality from implementation completion
alone.

After a campaign is green, or after the user explicitly accepts a partial or
constrained campaign, perform full documentation alignment:

- update the campaign record and `TEST-CAMPAIGN-INDEX.md`;
- update `TRACEABILITY_MATRIX.md` from accepted evidence;
- update `REQUIREMENTS_DIFF_INDEX.md`, `REVIEW-INDEX.md`, blocker ledgers, and
  follow-up routing when their factual state changed;
- refresh canonical baseline or interaction documents only when curated
  restatement improves readability or removes stale supersession.

If a campaign fails or records blockers, keep the campaign as evidence and route
the blockers into fixing `IMPL-*` packets or a successor diff. Full
documentation alignment waits until the relevant validation is green or
explicitly accepted.

## 8. Initiative Ledger Rule

Each root `IMPL-*` should act as the live initiative ledger for its change
family.

The root packet should identify:

- active governing diff
- affected scenario layer
- baseline areas known to be stale during execution
- requirement-to-packet coverage when the active diff is broad
- expected test campaign
- expected post-acceptance canonical refresh targets, if any

This keeps initiative-specific synchronization out of the global contracts.

### 8.1 IMPL Families And Subpackets

A root `IMPL-*` may be an executable packet or a planned decomposition.

Use a planned decomposition when the initiative is architecturally coherent but
too broad for one safe execution slice. In that case:

- the root packet defines the boundary, governing diff, sequencing, and
  acceptance gate for the whole family
- decimal subpackets define executable slices
- each subpacket must have a clear write or responsibility scope
- the IMPL index must list the root and every generated subpacket
- the root remains the family ledger until the family is accepted, superseded,
  or cancelled

Subpacket execution must not change the product contract by itself. If a
subpacket reveals that the governing diff is wrong or incomplete, route through
the active diff or a successor diff.

### 8.2 Packet Boundary Correction And Absorption

Sometimes a packet is not wrong in substance but wrong in boundary.

Examples:

- it solves only half of an architectural problem
- it mixes an implementation patch with a broader product or architecture
  contract
- it carries useful backend, data, or configuration decisions but cannot be
  executed safely as an isolated change

When this happens:

1. Do not execute the packet merely because it exists.
2. Identify which decisions remain valid.
3. Move those decisions into the active diff, a replacement root IMPL family,
   or a dedicated spec document if the project uses one.
4. Mark the old packet as absorbed, superseded, or cancelled in the IMPL index.
5. Remove or freeze the old packet as an active execution source so there is
   one current authority for the work.

The replacement document must state what it preserves and what boundary it
changes. This keeps history auditable without leaving two competing plans.

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
- execute an IMPL packet after its boundary has been declared wrong
- keep both an absorbed packet and its replacement as active execution sources

## 10. Project Overlay

Replace this section with project-specific document governance constraints.

The overlay must identify, at minimum:

- any document locations that differ from the defaults in
  `authorities/flow-of-work-contract/05-PROJECT-STRUCTURE.md`
- any additional document types introduced by the project and their role in
  the authority stack
- any project-specific propagation rules that extend section 4
