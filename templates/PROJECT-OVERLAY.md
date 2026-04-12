# Project Overlay

**Version:** 0.1
**Status:** working_draft
**Last updated:** YYYY-MM-DD

---

## 0. Purpose

This document is the project-specific configuration for the flow-of-work
contract system.

It bridges the generic governance contracts with the specific constraints,
language settings, and architectural boundaries of this project.

It is read immediately after `AGENT.md` and before the
flow-of-work contracts. Without it, the active model cannot determine the
project language, protected subsystems, or system perimeter.

**Update rule**: this document is updated through the adoption
procedure at project start, or by explicit user decision during the project
lifecycle. The active model must not update it unilaterally.

This document stores persistent project facts only.
It must not become a dump of setup conversation notes, temporary review text,
or ad hoc planning artifacts.

---

## 1. Project Identity

**Project name:** [Project Name]

The project name replaces all `[Project Name]` placeholders across the
authority docset. If the user has explicitly chosen not to set a name, this
field is set to `no-name` and placeholder replacement is skipped.

---

## 2. Adoption Context

**Adoption mode:** [greenfield / migration / code_first / unknown]

Use:

- `greenfield` when the project is being initialized from a new or effectively
  blank control plane
- `migration` when an existing project is being brought into this structure
- `code_first` when the project begins from existing code and the initial
  document base is being derived from that code
- `unknown` only during incomplete setup

**Adoption procedure:** [starter_guided / starter_manual / unknown]

This field records which adoption procedure created the project control plane.
It is not a second adoption-mode field.

Use:

- `starter_guided` when the project was adopted through `STARTER.md`
- `starter_manual` when the project was adopted through `MANUAL-STARTER.md`
- `unknown` only during incomplete setup

When `adoption mode = code_first`, this field still records how adoption
occurred. The runtime bootstrap state is tracked separately in section 9.

---

## 3. Language Configuration

**Conversation language:** [language]
The language used between the user and the active model during working
sessions. The model responds and reasons in this language.

**Documentation language:** [language]
The language used to produce all documents in this project — contracts,
requirements, IMPL packets, test campaigns, and the traceability matrix.

These two fields are independent. The model must not infer the documentation
language from the conversation language.

The slug of every IMPL packet, REQUIREMENTS_DIFF, and TestCampaign file must
be written in the documentation language, in uppercase, with words separated
by hyphens.

Example: documentation language is English → `IMPL-01-CONTEXT-POLICY.md`.
Example: documentation language is Italian → `IMPL-01-POLICY-CONTESTO.md`.

---

## 4. Protected Subsystems

This table is a routing signal to the active model, not a hard enforcement
mechanism by itself.

The active model must stop and route to the user before touching any of these.
A protected subsystem change is never implicit — it requires a named decision.

Projects that need strong enforcement should also express the same protection
as explicit baseline or accepted-diff requirements, not only here.

| Subsystem | Protection reason | Approval required from |
|---|---|---|
| [subsystem name] | [why it is protected] | User |

If no subsystems are protected at project start, write `none declared` and
revisit as the project grows.

---

## 5. System Perimeter

**What the system modifies:**
[Describe what the system is allowed to change — files, databases, external
services, repositories, etc.]

**What the system must not modify:**
[Describe explicit exclusions — e.g. the control project itself, production
databases, external services without confirmation, etc.]

**Baseline assumption:**
[Single user / multi-user / multi-tenant / offline-first / etc.]

---

## 6. Behavioral Reference

The location of the closest working code that can be used as a behavioral
reference when implementation behavior is under-specified.

**Reference location:** [path or description]

If no behavioral reference exists yet, write `none` and treat missing behavior
as a blocker per `03-BEHAVIORAL-DEFINITION-GATE.md`.

---

## 7. Runtime Context

This section stores future-useful runtime context that should survive
adoption and remain available to later sessions.

It is primarily useful for greenfield projects, but may also be populated in
migration or code-first when the values are already known and stable.

It must not be used as a substitute for formal requirements.

**Primary code roots:** [path list or `none`]
**Primary test command:** [command or `none`]
**Primary run/dev command:** [command or `none`]
**Runtime ecosystem:** [python / node / mixed / etc. or `none`]
**Initial architecture intent:** [short text or `none`]
**Accepted working assumptions:** [short text or `none`]

---

## 8. Manual Onboarding State

Use this section to track whether the user has completed, paused, or explicitly
skipped the guided manual-onboarding path.

**Manual bootstrap status:** [pending / in-progress / completed / skipped_by_user / unknown]
**Manual readiness level:** [not_started / basic / operational / unknown]
**Last manual checkpoint:** [short section name / `none` / `skipped by user`]
**Manual override acknowledged:** [yes / no / unknown]

Use:

- `pending` when the next working session should route the user into
  `authorities/manual/MANUAL-BOOTSTRAP.md`
- `in-progress` when manual onboarding started but has not been completed
- `completed` when the user has read or discussed enough of the manual to
  operate at the recorded readiness level
- `skipped_by_user` when the user explicitly chose to proceed without guided
  manual onboarding
- `unknown` only during incomplete setup

Readiness:

- `not_started` means no meaningful manual onboarding has happened yet
- `basic` means the user has covered the mental model, operating rules, and
  document roles enough to work conservatively
- `operational` means the user has also covered the working loop, `Partial`,
  campaign constructibility, scope issues, and diff history enough for normal
  framework use
- `unknown` only during incomplete setup

If `manual bootstrap status` is `pending` or `in-progress`, `AGENT.md` should
route the next working session into the installed manual bootstrap before
normal initiative work begins.

If `manual bootstrap status = skipped_by_user`, `manual override acknowledged`
must be `yes`.

---

## 9. Code Bootstrap State

Use this section when a code-bootstrap run is active or prepared for a future
session.

**Code bootstrap mode:** [not_required / local_code_first_derivation / external_source_integration / unknown]
**Code bootstrap status:** [not_required / pending / in-progress / completed / unknown]
**Code bootstrap source type:** [local_project / filesystem_repo / git_repo / url / web_research / archive / pasted_code / none / unknown]
**Code bootstrap source reference:** [path / URL / query / short description / none]
**Code bootstrap requested output:** [not_required / bootstrap_docs_only / understanding_only / integration_recommendation / new_impl_required / implementation_candidate / unknown]

Use:

- `not_required` when no bootstrap run is active
- `local_code_first_derivation` when the project must derive its own initial
  baseline and interactions from existing local code
- `external_source_integration` when the project must analyze or integrate an
  external source through `CODE-BOOTSTRAP.md`
- `unknown` only during incomplete setup

If `code bootstrap status` is `pending` or `in-progress`, the next working
session must run `CODE-BOOTSTRAP.md` before normal initiative work begins.

---

## 10. Document Location Map

If this project has adapted the default structure from
`05-PROJECT-STRUCTURE.md`, record the actual locations here.

| Document type | Default location | Actual location |
|---|---|---|
| Requirements baseline | `authorities/baseline/` | [actual path] |
| Interactions | `authorities/interactions/` | [actual path] |
| Requirement diffs | `authorities/diffs/` | [actual path] |
| Implementation packets | `authorities/impl/` | [actual path] |
| Implementation packet index | `authorities/impl/IMPL-INDEX.md` | [actual path] |
| Test campaigns | `authorities/campaigns/` | [actual path] |
| Traceability matrix | `authorities/TRACEABILITY_MATRIX.md` | [actual path] |

If no adaptations were made, write `default` in the Actual location column.

---

## 11. Adoption Status

Tracks whether the adoption procedure has been completed.

**Procedure completed:** [yes / no / in-progress]
**Completed on:** [YYYY-MM-DD or —]
**Completed by:** [model name or user]

Documents created during adoption:

| Document | Created | Location |
|---|---|---|
| `REQUIREMENTS.md` | [yes / no] | [path] |
| `REQUIREMENTS_FUNCTIONAL.md` | [yes / no] | [path] |
| `REQUIREMENTS_NON_FUNCTIONAL.md` | [yes / no] | [path] |
| `USE_CASES_AND_SEQUENCES.md` | [yes / no] | [path] |
| `TRACEABILITY_MATRIX.md` | [yes / no] | [path] |
| `IMPL-INDEX.md` | [yes / no] | [path] |
| `manual/` | [yes / no] | [path] |

Optional human-support artifacts retained:

| Artifact | Retained | Location |
|---|---|---|
| `reader/` | [yes / no] | [path or —] |
| `beginning/STARTER-DIFF.md` | [yes / no] | [path or —] |
