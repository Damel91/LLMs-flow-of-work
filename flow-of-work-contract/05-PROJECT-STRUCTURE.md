# 05 — Project Structure

**Version:** 0.2
**Status:** working
**Last updated:** 2026-05-09

---

## 0. Purpose

This document defines the canonical directory structure for any project that
adopts the flow-of-work contract.

It answers one question: where do things go.

It is not a process contract. It is a map. A model entering an unfamiliar
repository reads this file first and can orient itself without making
assumptions about layout.

---

## 1. Organizing Principle

This project uses documents as authority and persistent memory.

The directory structure reflects that directly: documents are not scattered
across the repository. They are grouped by the role they play in the authority
stack, inside a single dedicated folder called `authorities/`.

In steady-state operation, four root-level files may be present because models
and users must find them immediately, without navigating: `AGENT.md`,
`README.md`, `CODE-BOOTSTRAP.md`, and `CODE-WORKFLOW-CONTRACT.md`.
Authority documents beyond those root anchors live inside `authorities/`.
Runtime code, tests, release artifacts, and installed governance utilities use
dedicated root folders.

Temporary exception during adoption:

- `STARTER.md` may be used at repository root only while adoption or migration
  is actively in progress
- it is an adoption artifact, not a steady-state control-plane file
- it must be removed or excluded once adoption is complete

**Separation is not cosmetic.** Different folders represent different layers of
authority. Placing a document in the wrong folder breaks the authority
separation that the governance contract depends on.

---

## 2. Canonical Structure

```
/
├── AGENT.md                         # session entrypoint
├── README.md                        # human-facing project introduction
├── CODE-BOOTSTRAP.md                # dormant integration / code-derivation tool
├── CODE-WORKFLOW-CONTRACT.md        # code development workflow contract
├── src/                             # project source code
├── config/                          # configuration files
├── tests/                           # automated test code and harnesses
├── tools/                           # installed governance CLI and project tools
│   └── flowctl.sh                   # workspace control-plane validator
├── release/                         # release-related artifacts (see section 4.7)
└── authorities/                     # all project authority documents
    ├── PROJECT-OVERLAY.md           # project-specific configuration
    ├── TRACEABILITY_MATRIX.md       # cross-cutting factual state register
    ├── manual/                      # user operating manual and onboarding bootstrap
    │   ├── MANUAL-BOOTSTRAP.md
    │   ├── REACHING-THE-LLMS.md
    │   └── *.md                     # supporting notes, if retained
    ├── flow-of-work-contract/       # governance layer
    │   ├── 00-INDEX.md
    │   ├── 01-LLM-SESSION-CONTRACT.md
    │   ├── 02-DOCSET-GOVERNANCE-CONTRACT.md
    │   ├── 03-BEHAVIORAL-DEFINITION-GATE.md
    │   ├── 04-TEST-AND-HANDOFF-CONTRACT.md
    │   └── 05-PROJECT-STRUCTURE.md
    ├── baseline/                    # stable accepted product requirements
    │   ├── REQUIREMENTS.md
    │   ├── REQUIREMENTS_FUNCTIONAL.md
    │   └── REQUIREMENTS_NON_FUNCTIONAL.md
    ├── interactions/                # use cases and interaction sequences
    │   └── USE_CASES_AND_SEQUENCES.md
    ├── diffs/                       # active and historical requirement diffs
    │   ├── REQUIREMENTS_DIFF_INDEX.md
    │   ├── REQUIREMENTS-DIFF-TEMPLATE.md
    │   └── REQUIREMENTS_DIFF_*.md
    ├── impl/                        # implementation packet history
    │   ├── IMPL-INDEX.md
    │   ├── IMPL-TEMPLATE.md
    │   └── IMPL-*.md
    ├── reviews/                     # review holds and clarification records
    │   ├── REVIEW-INDEX.md
    │   ├── REVIEW-TEMPLATE.md
    │   └── REVIEW-*.md
    └── campaigns/                   # test evidence
        ├── TEST-CAMPAIGN-INDEX.md
        ├── TEST-CAMPAIGN-TEMPLATE.md
        ├── TEST-ENVIRONMENT-STARTUP.md
        └── TestCampaign-*.md
```

The diff index, review index, campaign index, environment startup helper, and
category templates shown in `diffs/`, `impl/`, `reviews/`, and `campaigns/`
are standing local references. They are copied by `STARTER.md` into the
destination project so future sessions can select the active diff, track
review holds, navigate campaigns, reuse environment startup procedure, and
create new artifacts without returning to the framework repository.

The diff index, review index, and campaign index are live navigation state.
The templates and startup helper are not active diffs, active packets, review
findings, or campaign evidence. A model must copy the relevant template,
rename the copy according to the category naming rule, replace placeholders,
and leave the installed template unchanged.

Temporary adoption-only root files may exist during active adoption, but
they are not part of the canonical steady-state structure:

- `STARTER.md`

---

## 3. Layer Authority Table

| Folder | Authority role | Governed by | Must not contain |
|---|---|---|---|
| `/` (root) | Immediate model and user entry points plus installed integration bootstrap and code workflow contract | — | Any authority document other than AGENT.md and README.md, except `CODE-BOOTSTRAP.md`, `CODE-WORKFLOW-CONTRACT.md`, and temporary adoption bootstraps during active adoption |
| `src/` | Project source code | Project-specific | Authority documents, test evidence |
| `config/` | Configuration files | Project-specific | Source code, authority documents |
| `tests/` | Automated test code and harnesses | `04-TEST-AND-HANDOFF-CONTRACT.md` | TestCampaign documents (those belong in campaigns/) |
| `tools/` | Installed governance CLI and project utility scripts | `05-PROJECT-STRUCTURE.md` and project-specific tool policy | Authority documents, product requirements, campaign evidence |
| `release/` | Release artifacts — see section 4.7 | Project-specific | Authority documents, source code |
| `authorities/` | Full project authority docset | `02-DOCSET-GOVERNANCE-CONTRACT.md` | Source code, build artifacts |
| `authorities/PROJECT-OVERLAY.md` | Project-specific configuration and language settings | Updated via guided init or explicit user decision | Generic governance rules (those belong in flow-of-work-contract/) |
| `authorities/manual/` | User operating manual, onboarding bootstrap, and supporting manual notes | Explicit user decision and framework publication | Product requirements, IMPL packets, test evidence |
| `authorities/flow-of-work-contract/` | Workflow governance — how work is conducted | `00-INDEX.md` | Product requirements, IMPL packets |
| `authorities/baseline/` | Stable accepted product intent | `02-DOCSET-GOVERNANCE-CONTRACT.md` | Active diffs, implementation notes |
| `authorities/interactions/` | Scenario and interaction contract | `02-DOCSET-GOVERNANCE-CONTRACT.md` | Requirements baseline, IMPL packets |
| `authorities/diffs/` | Active diff index, current and historical scope evolution, and local diff creation template | `01-LLM-SESSION-CONTRACT.md` | Accepted baseline text, test evidence |
| `authorities/impl/` | Bounded execution history plus its local creation template | `01-LLM-SESSION-CONTRACT.md` | Requirements, test campaigns |
| `authorities/reviews/` | Review holds, clarification records, and local review templates | `02-DOCSET-GOVERNANCE-CONTRACT.md` | Implementation plans, campaign evidence |
| `authorities/campaigns/` | Validation evidence, campaign navigation, environment helper, and local campaign creation template | `04-TEST-AND-HANDOFF-CONTRACT.md` | Implementation plans, requirements |
| `authorities/TRACEABILITY_MATRIX.md` | Accepted factual state across all layers | `02-DOCSET-GOVERNANCE-CONTRACT.md` | Future intent, speculative status |

---

## 4. Root Files and Folders

### 4.1 AGENT.md

`AGENT.md` is the session entrypoint for models working inside an adopted
project.

It must be at the repository root. A model that receives a repository context
looks for this file first. Placing it in a subdirectory breaks that
expectation and forces the model to search, which introduces ambiguity.

The filename does not encode runtime capability. Capability is a property of
the active session, not of the entrypoint file. Projects that need a
tool-specific stub filename may add one locally, but that is outside this
framework's responsibility.

The installed `AGENT.md` should remain small and runtime-focused. It is not
the owner of adoption procedure logic. Starter-time validation and finalization
belong to `STARTER.md`, which may derive the final installed `AGENT.md` before
handoff.

`AGENT.md` must reference `authorities/flow-of-work-contract/00-INDEX.md` as
the first contract document to read after the overlay, and must reference
`CODE-WORKFLOW-CONTRACT.md` before code work begins.

When overlay state declares manual onboarding pending or in progress,
`AGENT.md` may route first into `authorities/manual/MANUAL-BOOTSTRAP.md`
before normal initiative work or code bootstrap begins.

### 4.2 README.md

Human-facing introduction to the project. It is not an authority document.
It should explain what the project does and point to `AGENT.md` for
model-facing context.

### 4.3 CODE-BOOTSTRAP.md

`CODE-BOOTSTRAP.md` is an installed post-adoption integration tool.

In the current framework version its active use is the first working session
of a `code_first` project, where it derives baseline and interactions from
existing code after adoption is already complete.

It is not the session entrypoint. It must not replace `AGENT.md`. In projects
where later operational state never activates it, it remains dormant.

### 4.4 CODE-WORKFLOW-CONTRACT.md

`CODE-WORKFLOW-CONTRACT.md` is the installed code development workflow
contract.

It governs execution discipline for code, prompt, parser, routing, graph,
workspace, apply, regression, and commit work. It exists at root because the
active model must find it before changing runtime behavior.

It is not a product requirements document, not an IMPL packet, and not test
evidence. It must be referenced by the installed `AGENT.md` read order and hard
stops.

### 4.5 tools/

Contains installed workflow utilities and project-local helper scripts.

The default installed framework utility is:

- `tools/flowctl.sh`

The starter must install it as an operational shell tool. On macOS, Linux, and
Windows through Git Bash, the starter runs `chmod +x tools/flowctl.sh` from the
destination project root after copying it. The portable invocation remains
`bash tools/flowctl.sh ...`; `./tools/flowctl.sh ...` is available when the
executable bit is active.

This folder is not an authority-document layer. It may contain executable or
portable tooling used to inspect the project, but product requirements,
implementation packets, reviews, and campaign evidence still belong under
`authorities/`.

If a project later adds its own tools, keep them operational and avoid turning
this folder into a documentation archive.

### 4.6 tests/

Contains automated test code and harnesses — unit tests, integration tests,
regression tests, and any deterministic local test runners the project uses.

This folder is distinct from `authorities/campaigns/`. The difference is:

- `tests/` contains **executable code** that verifies behavior automatically.
- `authorities/campaigns/` contains **evidence documents** that record the
  outcome of a validation campaign, whether automated or manual.

A regression test lives in `tests/`. The record of running it lives in
`authorities/campaigns/`. Do not conflate the two.

### 4.7 release/

Contains release-related artifacts. The exact content depends on the nature
of the project and may include any combination of:

- changelog and release notes
- versioned build artifacts or distribution packages
- deployment descriptors or packaging configuration
- migration guides between versions

This folder has no fixed internal structure — adapt it to the project's
release process. The only constraint is that authority documents must not be
placed here, and source code must not be placed here.

If the project has no release process, this folder may be omitted entirely.

---

## 5. TRACEABILITY_MATRIX.md Position

The traceability matrix lives at the root of `authorities/` rather than inside
any subfolder because it references all layers simultaneously — baseline,
interactions, diffs, impl packets, and campaigns.

Placing it inside any single subfolder would imply a layer membership it does
not have. It is the cross-cutting factual state register for the entire
authority stack.

## 5.1 REQUIREMENTS_DIFF_INDEX.md Position

The diff index lives inside `authorities/diffs/` because it governs only the
requirements-diff layer. It identifies the active head diff and records diff
succession state.

It is not a requirements diff itself, not an IMPL packet, and not evidence.
It must be installed in every adopted project even when no active diff exists.
In that case its active diff field is `none`.

## 5.2 REVIEW-INDEX.md Position

The review index lives inside `authorities/reviews/` because it governs only
review holds and clarification records. It identifies active reviews that may
block or qualify execution in another layer.

It is not a review finding itself, not an implementation packet, and not test
evidence. It must be installed in every adopted project even when no active
review exists. In that case its active review list is empty.

## 5.3 TEST-CAMPAIGN-INDEX.md Position

The campaign index lives inside `authorities/campaigns/` because it governs
campaign navigation and validation evidence lookup. It records active,
accepted, partial, deferred, and historical campaign references.

It is not campaign evidence by itself. It must be installed in every adopted
project even when no campaign has been run yet.

## 5.4 TEST-ENVIRONMENT-STARTUP.md Position

The environment startup helper lives inside `authorities/campaigns/` because
it supports repeatable validation. It records stable runtime startup,
preflight, reset, shutdown, and known-environment constraints that test
campaigns can reference instead of duplicating setup prose.

It is not a campaign result and must not be treated as acceptance evidence.

---

## 6. Adaptation Rules

The structure above is the canonical starting point. Projects may adapt it
within these constraints:

**Allowed:**
- Renaming `baseline/`, `interactions/`, `impl/`, `diffs/`, `reviews/`, or
  `campaigns/` to names that better fit the project domain.
- Adding subfolders inside any layer folder to organize growing document sets.
- Adding project-specific document types inside the appropriate layer folder.

**Not allowed:**
- Merging two layer folders into one. The separation of baseline, diffs, impl,
  reviews, and campaigns is structural, not cosmetic. Merging them recreates
  the management problem this structure is designed to solve.
- Moving `AGENT.md` or `README.md` out of the root.
- Placing authority documents outside `authorities/`.
- Moving `authorities/manual/` out of `authorities/` or turning it into a
  project-specific product-doc layer.
- Placing `TRACEABILITY_MATRIX.md` inside a layer subfolder.

If an adaptation requires breaking one of these rules, stop and discuss with
the user before proceeding. The structure is a governance decision, not a
style preference.

If a destination project needs a stronger structure override while keeping
`AGENT.md` at root and `authorities/` as the authority root, use
`STARTER.md`. In that case the starter may derive a project-specific
`AGENT.md` and `05-PROJECT-STRUCTURE.md` before installation, and
`IMPL-INDEX.md` follows the final location of the adopted `impl` layer.
