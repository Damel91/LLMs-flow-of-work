---
doc_type: test_and_handoff_contract
scope: validation_control
applies_to: multi-platform
version: 0.4
status: working_draft
last_updated: 2026-04-12
---

# Test And Handoff Contract

## 0. Quick Rules

1. Validation handoff starts only after known blockers are resolved.
2. A `TestCampaign-*` is an evidence artifact, not an implementation plan.
3. Autonomous same-environment testing is optional and requires explicit user
   delegation.
4. Manual testing is an acceptance activity, not exploratory debugging.
5. Traceability moves only from evidence.
6. Repeated bug-fix loops on the same behavior must add or update targeted
   automated regression tests before the next live campaign.
7. Readiness for handoff and constructibility of a meaningful campaign are
   related but not identical gates.

## 1. Readiness Gate

Before opening a `TestCampaign-*`, the active LLM must declare one of:

- `ready for validation handoff`
- `not ready for validation handoff`
- `blocked`

This decision must be based on whether known blockers still exist against the
targeted use case, sequence, or packet objective.

Manual testing must not be used to discover failures that are already
predictable from the current code and review state.

If predictable blockers remain, the model must continue implementation inside
the current packet boundary or explicitly declare a blocked condition that
requires user routing.

### 1.1 Campaign Constructibility Gate

Separate from handoff readiness, the active LLM and/or user must judge whether
the current state is mature enough that a campaign result would be
interpretable.

A campaign is constructible only when enough behavior has accumulated that:

- the relevant use cases and sequences can be exercised coherently
- a failure would distinguish between incomplete implementation, bug, and scope
  issue with reasonable clarity
- the campaign would validate a meaningful behavior slice rather than merely
  prove that the system is still unfinished

If this condition is not met yet:

- the initiative may remain in an implementatively closed but not yet
  empirically validated state
- `TRACEABILITY_MATRIX.md` may still record the factual conservative state
  allowed by the project
- the project continues through further IMPL work or diff evolution until a
  meaningful campaign becomes possible

Constructibility is therefore not the same as "the current packet has no known
blockers". A packet may be handoff-ready while the broader behavior family is
not yet campaign-constructible.

## 2. Autonomous Same-Environment Test

This phase is optional and project-specific in practice.

It may be used only when all of the following are true:

- the active LLM is execution-capable
- it has access to the same runtime environment as the operator
- the user explicitly delegates execution of the `TestCampaign-*`
- the target surface is deterministic enough to be exercised by the model

Autonomous test rules:

- the campaign must still derive from the relevant use cases, sequences, and
  packet-specific regressions
- if the adopting project defines an environment startup or environment-control
  helper, the executor must use it and the active `TestCampaign-*` must
  reference it explicitly
- if the campaign requires a clean state, the reset or cleanup procedure must
  be executed and recorded before testing starts
- the model must test live system surfaces where possible:
  - local server API
  - live UI
  - real session state
  - real target repo state
- the model must stop at the first acceptance blocker unless the campaign
  explicitly allows continued evidence gathering after failure
- the model must record:
  - environment assumptions
  - executed steps
  - non-executed steps
  - observed outputs
  - blocker classification

Autonomous testing is not permission to infer runtime success from code
inspection alone.

Autonomous testing produces evidence, but it does not automatically authorize
traceability updates unless the user also delegated acceptance authority for
that campaign.

### 2.1 tests/ And campaigns/ Are Not Structurally Coupled

The `tests/` folder and `TestCampaign-*` documents are related by evidence
flow, not by structural coupling.

- `tests/` may contain deterministic harnesses, stubs, probes, and regressions
  that the active model chooses to use during a campaign
- a `TestCampaign-*` may use those artifacts, but this contract does not
  require a one-to-one mapping between a campaign and specific files in `tests/`
- the choice to use a harness from `tests/` is a model strategy decision unless
  the project declares a stricter rule elsewhere
- the repeated bug-fix loop rule in section 3.1 is the explicit exception:
  there, a targeted automated regression becomes required as a content rule,
  not as a general structural coupling rule

## 3. User Acceptance Test

The user is the default acceptance authority.

User acceptance should be recorded in a `TestCampaign-*` document once the
implementation reaches the boundary where human confirmation is still required.

`TestCampaign-*` is the evidence artifact.

`IMPL-*` is not the evidence artifact.

The test campaign must be derived from:

- the relevant use case(s)
- the relevant sequence(s)
- the scenario preconditions, key transitions, and postconditions
- packet-specific regression checks for the changed code paths

The test campaign must not be derived only from changed files or only from bug
symptoms.

The test result is the basis for:

- accept packet
- reject packet
- create decimal follow-up
- create next independent IMPL
- open a superseding `REQUIREMENTS_DIFF_*` when the failure is a scope issue

Manual testing is an acceptance activity, not an exploratory debugging phase.

## 3.1 Repeated Bug-Fix Loop Rule

When the same behavioral area has already gone through multiple corrective
rounds, the active LLM must stop relying on live campaigns alone.

At that point, the fix loop must include:

- a targeted automated regression test for the reproduced defect
- execution of that regression locally before the next live campaign
- explicit recording of which bug the regression protects

Expected trigger:

- approximately the third corrective round onward for the same behavioral seam
- or earlier if the same failure reappears after a previous live fix

Accepted forms:

- `unittest`
- `pytest`
- other deterministic local test harnesses already accepted by the project

The exact framework is not authoritative.
The regression coverage is authoritative.

If the environment lacks a preferred test tool, the executor must use the
best available deterministic local harness instead of skipping the regression.

## 4. Failure Triage

When validation fails, classify the outcome as one of:

- incomplete implementation still inside current packet scope
- dependent follow-up requiring `IMPL-X.1`
- independent issue requiring the next integer IMPL
- scope issue requiring a superseding `REQUIREMENTS_DIFF_*`
- documentation or traceability drift only

The classification determines whether work stays in the same initiative or
opens a new one.

This same classification logic also applies when an autonomous same-environment
campaign fails.

### 4.1 Scope-Issue Handling

When a campaign shows that the implementation matches the governing diff but
the governing diff itself was incomplete or wrong, treat the result as a scope
issue, not as a pure implementation bug.

Required consequences:

- keep the campaign as evidence of what was actually exercised
- open a superseding `REQUIREMENTS_DIFF_*` for the corrected intent
- keep `TRACEABILITY_MATRIX.md` factual:
  - existing rows remain factual if they still describe what the repo does
  - new or corrected requirement IDs enter the matrix as `Gap` by default, or
    `Partial` only if corrected behavior is already partly present
- do not introduce ad hoc matrix states such as `pending` or `deferred` for
  this purpose

Lifecycle nuance belongs in the diff and IMPL layers, not in the matrix status
legend.

## 5. Test Output Contract

Expected output:

- test executor identified:
  - autonomous same-environment LLM
  - manual user
- explicit use cases covered
- explicit sequences covered
- recorded execution results
- environment or runtime surface used
- executed vs non-executed tests clearly separated
- relevant logs or observations captured
- packet-specific regression checks clearly identified
- constructibility judgment made explicit when relevant
- failure classification when the campaign does not pass

## 6. Project-Specific Extension Point

An adopting project may define stricter autonomous-testing rules for its own
runtime and environment.

Typical project-specific additions include:

1. requiring use of a real runtime instead of inferred behavior
2. naming an environment startup helper or reset helper
3. defining clean-state prerequisites
4. constraining which repositories or mutable targets may be touched
5. limiting when autonomous execution may propose traceability refreshes
6. requiring targeted automated regressions after repeated corrective loops

Those rules belong in the adopting project's overlay or adjacent helper docs.
They must not be hardcoded into this generic contract with project-local paths.
