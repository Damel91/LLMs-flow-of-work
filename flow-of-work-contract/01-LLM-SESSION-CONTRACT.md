---
doc_type: llm_session_contract
scope: development_control
applies_to: multi-platform
version: 0.3
status: working_draft
last_updated: 2026-04-12
---

# LLM Session Contract

## 0. Quick Flow

Use this sequence unless a project-specific overlay says otherwise:

1. Read canonical docs and current traceability state.
2. Classify the request:
   - existing-contract fix
   - new feature or product scope change
3. If it is a new feature or product scope change, create or update a
   head `REQUIREMENTS_DIFF_*`.
4. Create one atomic `IMPL-*` packet for the bounded execution slice.
5. Execute all work the active LLM can safely implement and self-check
   inside that packet scope.
6. Run model-side code review.
7. Apply the behavior-definition gate and the readiness gate before handoff.
8. Route test evidence through the test and handoff contract.
9. Update `TRACEABILITY_MATRIX.md` only from evidence.

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

## 4. Decision Gate

Before any implementation work starts, the active LLM must classify the
request.

| Request type | Required next step | Notes |
|---|---|---|
| Corrective bug fix inside accepted contract | Go to `IMPL-*` if non-trivial | No `REQUIREMENTS_DIFF_*` needed if product scope does not change |
| Implementation drift fix | Go to `IMPL-*` | Canonical docs remain source of truth |
| Documentation correction only | Apply docs change directly or via small `IMPL-*` | No traceability inflation |
| New feature | Create or update the current head `REQUIREMENTS_DIFF_*` first | Product scope changes before implementation |
| New workflow | Create or update the current head `REQUIREMENTS_DIFF_*` first | Includes approval flow or artifact lifecycle changes |
| Scenario or safety-boundary change | Stop and route through user | Requires explicit approval before execution |

### 4.1 Universal Governing Rules

1. The documentation set is authoritative for the project being worked on.
2. `02-DOCSET-GOVERNANCE-CONTRACT.md` governs authority and synchronization
   between document layers.
3. `03-BEHAVIORAL-DEFINITION-GATE.md` governs blocked states caused by missing
   behavior definitions.
4. The user is the routing authority for scenario or structural changes.
5. New feature or product scope changes require a `REQUIREMENTS_DIFF_*` first.
6. Non-trivial execution must be bounded by one atomic `IMPL-*`.
7. The active LLM should complete all work inside its reliable execution and
   self-check boundary before handoff.
8. `TRACEABILITY_MATRIX.md` is updated only from evidence.
9. Diff mutability and succession are governed by
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

### 4.3 Atomic IMPL Rule

One IMPL packet must describe one bounded initiative.

Rules:

- `IMPL-N` = one standalone initiative
- `IMPL-N.1` = dependent follow-up on `IMPL-N`
- `IMPL-N.2` = further dependent follow-up on `IMPL-N`
- `IMPL-M` = next independent initiative

An IMPL packet must not bundle unrelated initiatives just to reduce file count.

The boundary is capability-based, not artificially tiny:

- one IMPL may contain multiple coordinated code changes
- those changes must still belong to one coherent objective
- the packet ends where human-only validation becomes necessary

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

1. Repository identity and purpose
2. Canonical docs per `authorities/PROJECT-OVERLAY.md`:
   - the baseline documents at their installed project locations
   - the interaction document at its installed project location
   - `authorities/TRACEABILITY_MATRIX.md`
3. Relevant current history:
   - the installed `IMPL-INDEX.md` at the project's actual `impl` location
   - active `IMPL-*`, if present
   - latest relevant `TestCampaign-*`
   - latest governing `REQUIREMENTS_DIFF_*`
4. Governance constraints:
   - docs-first
   - user as master router
   - atomic IMPL rule
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
| IMPL | Accepted requirement scope or fix scope | one atomic `IMPL-*` | Required for non-trivial execution |
| Execution | active IMPL | code or docs changes | Must stay inside packet scope and inside the LLM capability boundary |
| Model review | changed code + active IMPL + docs | findings / residual risks | Pre-test quality gate |
| Readiness and behavior gates | implemented result + review | handoff decision or blocked state | Blocks premature validation |
| Traceability update | test evidence | factual matrix refresh | Never before evidence |
| Canonical refresh | accepted contract change | optional curated docs refresh | Only when a restatement improves readability or removes stale supersession |

### 6.2 Phase Details

#### Phase A — Documentation Baseline Check

The model must determine:

- what canonical docs require now, including any governing active diff layer
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

#### Phase C — IMPL Packet

All non-trivial execution work must be bound to one atomic `IMPL-*`.

An IMPL packet must include at least:

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

Additional empirical execution rule for constrained execution flows:

- if the system defines a planning or refinement stage before execution,
  do not bypass it by feeding the executor raw user instructions
- execution retries are local recovery only and must not be treated as
  a substitute for planning or context discovery

#### Phase E — Model Code Review

The model reviews:

- canonical docs
- active IMPL
- changed code

Review output must be:

- findings first
- severity ordered
- tied to files and lines
- explicit about residual risk

This is not final acceptance.

#### Phase F — Traceability Matrix Update

`TRACEABILITY_MATRIX.md` may be updated only after evidence exists.

Allowed factual outcomes:

- `Implemented`
- `Partial`
- `Gap`

The matrix reflects repo reality, not intended future state.

For worker behavior, one accepted operational reading matters here:

- `Partial` may record that a requirement is implemented at code level and
  self-checked, but still awaiting its first authoritative campaign

This is a factual conservative state, not final acceptance.

#### Phase G — Canonical Documentation Refresh

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
- explicit new, modified, or removed requirement IDs
- explicit statement whether the diff is an amended head diff or a successor
- explicit impact on traceability

### 7.2 IMPL Output

Expected output:

- one atomic `IMPL-*`
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
