---
doc_type: llm_session_contract
scope: development_control
applies_to: multi-platform
version: 0.7
status: working
last_updated: 2026-05-23
---

# LLM Session Contract

## 0. Quick Flow

Use this sequence unless a project-specific overlay says otherwise:

1. Read canonical docs and current traceability state.
2. Classify the request:
   - existing-contract fix
   - new feature or product scope change
3. If it is a new feature or product scope change, create or update a
   head `REQUIREMENTS_DIFF_*` and register it in
   `REQUIREMENTS_DIFF_INDEX.md`.
4. Create one atomic executable `IMPL-*` packet, or a root `IMPL-*` family with
   atomic subpackets when the initiative is coherent but too broad for one safe
   execution slice.
5. Execute all work the active LLM can safely implement and self-check
   inside that packet scope.
6. Fill the packet completion criteria ledger. Useful movement, scaffold, or
   75/80% completion must be recorded as such, not as `Implemented`.
7. Run model-side code review.
8. After each implemented, scaffolded, partial, or blocked packet, update the
   packet and `IMPL-INDEX.md` honestly. `Scaffolded` is non-terminal and must
   route to continued work, a follow-up, or an explicit blocker/deferral state.
9. Apply the behavior-definition gate, completion gate, and readiness gate
   before handoff.
10. Route test evidence through the test, handoff, and validation execution
   contracts.
11. After an accepted campaign, do full documentation alignment and update
    `TRACEABILITY_MATRIX.md` from accepted evidence.

## 1. Purpose

This document defines how an LLM-assisted engineering session must be
conducted.

It does not define product behavior. It defines worker behavior.

Primary goals:

- keep LLM usage controlled
- keep product scope auditable
- preserve reproducibility across sessions and models
- prevent undocumented feature drift
- preserve an explicit validation gate before acceptance

## 2. What This Document Is And Is Not

### 2.1 This Document Is

- a development workflow contract
- a control-plane document for LLM-assisted engineering
- a resume and restart aid when model context is lost
- a portable workflow that can be reused across model platforms

### 2.2 This Document Is Not

- a product requirements document
- a runtime behavior specification for the project
- a substitute for `REQUIREMENTS.md`
- a substitute for `TRACEABILITY_MATRIX.md`

## 3. Reading Guide

Read in this order:

1. `00-INDEX.md`
2. `02-DOCSET-GOVERNANCE-CONTRACT.md`
3. `03-BEHAVIORAL-DEFINITION-GATE.md`
4. this document
5. `04-TEST-AND-HANDOFF-CONTRACT.md`
6. `06-VALIDATION-EXECUTION-CONTRACT.md`

## 4. Decision Gate

Before any implementation work starts, the active LLM must classify the
request.

| Request type | Required next step | Notes |
|---|---|---|
| Corrective bug fix inside accepted contract | Go to `IMPL-*` if non-trivial | No `REQUIREMENTS_DIFF_*` needed if product scope does not change |
| Implementation drift fix | Go to `IMPL-*` | Canonical docs remain source of truth |
| Documentation correction only | Apply docs change directly or via small `IMPL-*` | No traceability inflation |
| New feature | Create or update the current head `REQUIREMENTS_DIFF_*` and `REQUIREMENTS_DIFF_INDEX.md` first | Product scope changes before implementation |
| New workflow | Create or update the current head `REQUIREMENTS_DIFF_*` and `REQUIREMENTS_DIFF_INDEX.md` first | Includes approval flow or artifact lifecycle changes |
| Scenario or safety-boundary change | Stop and route through user | Requires explicit approval before execution |

### 4.1 Universal Governing Rules

1. The documentation set is authoritative for the project being worked on.
2. `02-DOCSET-GOVERNANCE-CONTRACT.md` governs authority and synchronization
   between document layers.
3. `03-BEHAVIORAL-DEFINITION-GATE.md` governs blocked states caused by missing
   behavior definitions.
4. The user is the routing authority for scenario or structural changes.
5. New feature or product scope changes require a `REQUIREMENTS_DIFF_*` first.
6. Non-trivial execution must be bounded by one atomic executable `IMPL-*`, or
   by a root `IMPL-*` family whose subpackets are atomic executable slices.
7. The active LLM should complete all work inside its reliable execution and
   self-check boundary before handoff.
8. Movement is not completion. A packet cannot be marked `Implemented` unless
   its completion criteria ledger proves that every in-scope objective is
   complete or not applicable.
9. If the active model says the chain is too long, difficult, context-heavy, or
   only partially reliable, it must checkpoint the partial state instead of
   presenting a scaffold as done.
10. `TRACEABILITY_MATRIX.md` is updated only from evidence.
11. The active diff is selected by `REQUIREMENTS_DIFF_INDEX.md`, not by filename
   ordering or by stale status fields inside individual diff files.
12. Diff mutability and succession are governed by
   `02-DOCSET-GOVERNANCE-CONTRACT.md`.

### 4.2 Concept Closure Checklist

When a new concept is introduced in a `REQUIREMENTS_DIFF_*`, it is not
considered closed until the active LLM has identified all of the following:

- producer
- ownership
  - model-owned, runtime-derived, persisted, or rendered-only
- persistence layer
- consumer
- invalidation or lifecycle rule
- test surface

Examples of concepts that require closure:

- prompt-returned fields
- persisted issue payloads
- planning-side refinement objects
- review findings reused by later phases
- history or revision anchors

If one of these dimensions is missing, the concept remains architecturally
open and implementation must either:

- stop and reopen the diff, or
- explicitly document the deferred dimension before coding continues.

### 4.3 Bounded IMPL Initiative Rule

One IMPL packet or root IMPL family must describe one bounded initiative.

Rules:

- `IMPL-N` = one standalone executable initiative, or one root initiative family
- `IMPL-N.0`, `IMPL-N.1`, etc. = dependent packets under `IMPL-N`
- `IMPL-M` = next independent initiative
- when `IMPL-N` is a planned family, decimal packets are the atomic executable
  slices inside that family

An IMPL packet must not bundle unrelated initiatives just to reduce file count.

The boundary is capability-based, not artificially tiny:

- one atomic executable IMPL may contain multiple coordinated code changes
- those changes must still belong to one coherent objective
- the packet ends where human-only validation becomes necessary
- a root family may coordinate multiple executable subpackets, but each
  subpacket must have a clear responsibility boundary

### 4.4 Pre-Execution Chain Review Rule

When an active diff opens a root IMPL family, or when another model generated
the packet chain, execution must not start until the active model has reviewed
the chain against:

- the active `REQUIREMENTS_DIFF_*`
- relevant code surfaces, when the work affects runtime or architecture
- the installed `TRACEABILITY_MATRIX.md`
- overlapping `REVIEW-*` holds
- expected deterministic and live campaign coverage

The review must identify whether the chain actually covers the diff,
whether packet boundaries are coherent, and whether any blocking ambiguity
remains. If the chain is broad enough that a smaller model could lose the
global contract, use a frontier execution model or split the chain further.

This review is not optional ceremony. It is the guard that prevents a long
LLM-generated implementation family from becoming plausible but incomplete.

## 5. Platform Session Setup

Before work starts, the active LLM must be classified and configured by
capability.

### 5.1 Model Profiles

| Profile | Typical examples | Allowed role | Hard limits |
|---|---|---|---|
| `Execution-capable frontier model` | Codex CLI, Claude Code-like tools | Can read repo, draft docs, implement code, run review, prepare traceability updates | Cannot self-authorize scenario changes |
| `Analysis-only frontier model` | Chat-only Claude / ChatGPT sessions without repo tools | Can analyze docs, draft diffs, draft IMPL packets, perform review | Cannot be treated as authoritative on live repo state without evidence |
| `Constrained local model` | small offline coding/chat model | Can support narrow tasks, summarize, classify, draft bounded artifacts | Must not own architecture, governance, traceability, or behavioral decisions |

### 5.2 Session Preflight

Every LLM session must be initialized with:

1. Relevant current history:
   - the installed `REQUIREMENTS_DIFF_INDEX.md` at the project's actual
     diff-index location declared by the overlay
   - the active diff named by the index, if the index declares one
   - the installed `REVIEW-INDEX.md` at the project's actual review-index
     location declared by the overlay
   - active `REVIEW-*` records whose scope overlaps the requested work, if any
   - the installed `IMPL-INDEX.md` at the project's actual `impl` location
   - active `IMPL-*`, if present
   - the installed `TEST-CAMPAIGN-INDEX.md` at the project's actual campaign-index
     location declared by the overlay
   - `TestCampaign-*` linked by the active IMPL or active diff, if present
   - `TEST-ENVIRONMENT-STARTUP.md` when a linked campaign references it
2. Repository identity and purpose
3. Canonical docs per `authorities/PROJECT-OVERLAY.md`:
   - the baseline documents at their installed project locations
   - the interaction document at its installed project location
   - `authorities/TRACEABILITY_MATRIX.md`
   - if `REQUIREMENTS_DIFF_INDEX.md` declares an active diff, that diff must be
     read before the canonical docs are treated as the full governing set
4. Governance constraints:
   - docs-first
   - user as master router
   - bounded IMPL initiative rule
   - validation before traceability update
   - project-specific protected subsystem rules from `authorities/PROJECT-OVERLAY.md`

### 5.3 Platform-Specific Setup

#### A. Execution-Capable Model

Required setup:

- repo access enabled
- file edit capability enabled
- shell access enabled if available
- explicit instruction to treat docs as authoritative
- explicit instruction to stop on scenario changes
- explicit instruction to review against docs and IMPL before closure

#### B. Analysis-Only Model

Required setup:

- no assumption of live repo correctness
- use canonical docs or explicit file excerpts as evidence
- produce patch-ready or packet-ready outputs
- mark implementation claims as unverified unless applied by an execution
  model or the user

#### C. Constrained Local Model

Required setup:

- narrow task scope
- reduced context package
- fixed output template
- no ownership of architecture or governance decisions
- no authority to reinterpret requirements
- no direct ownership of raw user intent for code-change execution
- planning-produced input when the runtime uses a planning or refinement stage

## 6. Execution Lifecycle

### 6.1 Lifecycle Table

| Phase | Input | Output | Gate |
|---|---|---|---|
| Docs review | Canonical docs + matrix | classification of request | Must happen first |
| Requirements diff | New feature or product scope change | `REQUIREMENTS_DIFF_*` | Required only when product scope changes |
| IMPL | Accepted requirement scope or fix scope | one atomic `IMPL-*`, or one root family with atomic subpackets | Required for non-trivial execution |
| Execution | active IMPL | code or docs changes | Must stay inside packet scope and inside the LLM capability boundary |
| Model review | changed code + active IMPL + docs | findings / residual risks | Pre-test quality gate |
| Completion gate | changed code + active IMPL + self-check evidence | completion criteria ledger | Required before claiming `Implemented` |
| Packet documentation alignment | packet + completion ledger + self-check evidence | updated packet and `IMPL-INDEX.md` | Required after every implemented, scaffolded, partial, or blocked packet |
| Readiness and behavior gates | packet result + review | handoff decision or blocked state | Blocks premature validation |
| Validation execution | campaign plan + implementation | deterministic/live evidence | Must be adversarial and interpretable |
| Full documentation alignment | accepted campaign evidence | updated campaign index, matrix, review/diff state as needed | Never before campaign acceptance |
| Canonical refresh | accepted contract change | optional curated docs refresh | Only when a restatement improves readability or removes stale supersession |

### 6.2 Phase Details

#### Phase A — Documentation Baseline Check

The model must determine:

- what canonical docs require now, including the active diff named by
  `REQUIREMENTS_DIFF_INDEX.md`
- what the matrix says is implemented, partial, or gap
- whether the request is within the accepted contract

No code work starts before this step is complete.

#### Phase B — Requirements Diff Gate

Mandatory when the request introduces:

- a new feature
- a new workflow
- a changed use case
- a changed safety boundary
- a changed artifact lifecycle
- or any expanded product scope not already covered by canonical docs

Not mandatory for:

- corrective bug fixes
- implementation drift fixes
- documentation corrections
- narrow fixes inside accepted scope

When product scope changes, the model must decide whether to:

- amend the current head diff in place, or
- open a successor diff

That decision follows the mutability and succession rules from
`02-DOCSET-GOVERNANCE-CONTRACT.md`.

The chosen head or successor must be recorded in `REQUIREMENTS_DIFF_INDEX.md`
before any implementation packet is produced.

#### Phase C — IMPL Packet

All non-trivial execution work must be bound to one atomic executable `IMPL-*`,
or to one root `IMPL-*` family whose currently executed subpacket is atomic.

An IMPL packet or executable subpacket must include at least:

- goal
- packet scope
- packet out of scope
- linked requirement IDs
- expected files to change
- self-check boundary
- required validation handoff
- traceability impact

#### Phase D — Execution

Execution rules:

- implement only the packet scope authorized by the packet
- do not introduce new scenarios implicitly
- do not silently expand architecture
- preserve existing documented constraints
- keep edits minimal and explainable
- complete all work the active LLM can safely self-validate before handoff
- do not optimize for visible movement over completion
- do not treat broad scaffolding, interface creation, or plausible wiring as
  implemented behavior unless the packet objective was explicitly scaffolding

Additional empirical execution rule for constrained execution flows:

- if the system defines a planning or refinement stage before execution,
  do not bypass it by feeding the executor raw user instructions
- execution retries are local recovery only and must not be treated as
  a substitute for planning or context discovery

If the active model reaches a context, capability, or reliability boundary, it
must stop and record the actual state as `Scaffolded`, `Partial`, `Blocked`, or
`In progress`. It must not continue narratively to the end of the chain just to
create the appearance of progress.

`Scaffolded` is an active state, not a closure. It records that useful structure
exists, but behavior is still incomplete. A scaffolded packet must name the
remaining work and its route before handoff.

#### Phase E — Model Code Review

The model reviews:

- canonical docs
- active IMPL
- active review holds that overlap the changed scope
- campaign index and linked campaign evidence when test or acceptance state is
  affected
- environment startup helper when a live campaign path is affected
- changed code

Review output must be:

- findings first
- severity ordered
- tied to files and lines
- explicit about residual risk

This is not final acceptance.

#### Phase E.1 — Completion Gate

Before a packet or subpacket can be marked `Implemented`, the active model must
fill the completion criteria ledger in that packet.

The ledger must compare every in-scope objective or acceptance criterion
against:

- implementation evidence;
- verification performed;
- residual status.

Allowed residual statuses are:

- `complete`;
- `not_applicable`;
- `partial`;
- `blocked`;
- `deferred`.

`Implemented` is allowed only when every in-scope row is `complete` or
`not_applicable`. Any `partial`, `blocked`, or `deferred` row requires the
packet to remain non-implemented and to route the residual work to the same
packet, a follow-up packet, a review hold, a blocker ledger, or a successor
diff.

If the completion claim is `scaffolded`, at least one in-scope criterion must
remain incomplete and the packet must route the remaining behavior. A
scaffolded packet cannot be terminally closed, merged, accepted, or treated as
ready-for-validation as an implemented packet.

This gate exists because LLMs can create convincing bone structures that move a
chain forward while leaving behavior incomplete. The correct response is not to
reward movement; it is to record the actual completion state.

#### Phase F — Packet Documentation Alignment

After every implemented, scaffolded, partial, or blocked packet or subpacket,
update only the execution-layer documents that describe packet progress:

- the packet status and evidence notes
- `IMPL-INDEX.md`
- active review or hold records, only if the packet resolves them
- deterministic self-check notes or residual risk

Do not use this phase for full documentation alignment. Do not update
`TRACEABILITY_MATRIX.md` as accepted product reality just because the packet was
implemented.

#### Phase G — Validation Execution

Validation evidence flows through `04-TEST-AND-HANDOFF-CONTRACT.md` and
`06-VALIDATION-EXECUTION-CONTRACT.md`.

Campaigns must be designed to expose failures, including worst-case,
regression, negative/error, and isolation paths when relevant. A campaign that
only proves the easy path is weak evidence even if it is green.

If a campaign fails or is partial, preserve the campaign as evidence, route
blockers into fixing `IMPL-*` packets or a successor diff, add targeted
regression coverage where required, and rerun the relevant campaign slice.

#### Phase H — Full Documentation And Traceability Alignment

`TRACEABILITY_MATRIX.md` may be updated only after evidence exists.

Allowed factual outcomes:

- `Implemented`
- `Partial`
- `Gap`

The matrix reflects repo reality, not intended future state.

Implementation-level self-checks may be recorded in the packet and `IMPL-INDEX`,
but they do not move the matrix by themselves. The default rule is no matrix
movement before campaign evidence is accepted.

Full documentation alignment happens after a campaign is green and accepted, or
after the user explicitly accepts a partial/constrained campaign.

It may update:

- `TEST-CAMPAIGN-INDEX.md`
- `TRACEABILITY_MATRIX.md`
- `REQUIREMENTS_DIFF_INDEX.md`
- `REVIEW-INDEX.md`
- blocker ledgers and follow-up routing
- canonical baseline or interactions, only if curated restatement is useful

#### Phase I — Canonical Documentation Refresh

If the accepted work changes the product contract, canonical docs may then be
refreshed only where a curated restatement improves readability or resolves
stale supersession explicitly.

If the accepted work only closes an already documented gap, the traceability
update may be sufficient.

Accepted `REQUIREMENTS_DIFF_*` documents remain durable historical contract
records. Canonical refresh does not require absorbing them into baseline by
default.

## 7. Output Contracts

### 7.1 Requirements Diff Output

Expected output:

- one bounded `REQUIREMENTS_DIFF_*`
- corresponding `REQUIREMENTS_DIFF_INDEX.md` registration or update
- explicit new, modified, or removed requirement IDs
- explicit statement whether the diff is an amended head diff or a successor
- explicit impact on traceability

### 7.2 IMPL Output

Expected output:

- one atomic `IMPL-*`, or one root `IMPL-*` family plus the current executable
  subpacket
- explicit requirement references
- explicit packet scope
- explicit self-check boundary
- explicit required validation handoff

### 7.3 Execution Output

Expected output:

- implemented code or docs changes
- no undocumented scenario expansion
- concise execution summary

### 7.4 Review Output

Expected output:

- findings
- assumptions
- residual risks
- readiness declaration before validation handoff

### 7.5 Traceability Output

Expected output:

- factual status changes only
- notes tied to evidence, packet, or test campaign

## 8. Prohibited Behaviors

The active LLM must not:

- implement a new scenario without user approval
- update traceability before evidence exists
- treat an IMPL packet as the product contract
- treat its own analysis as proof of runtime behavior
- reinterpret project-specific protected subsystem semantics without approval
- mix development workflow rules with runtime product requirements
- claim completion when validation is still pending
- silently rewrite an older diff when a newer successor already exists

## 9. Intended Value

This contract exists to make LLM-assisted engineering:

- auditable for professional environments
- reproducible across model platforms
- robust against context loss
- compatible with offline and constrained deployments
- suitable as a public case study in rigorous LLM usage

It is not a replacement for engineering judgment.

It is the control structure around LLM-assisted work.
