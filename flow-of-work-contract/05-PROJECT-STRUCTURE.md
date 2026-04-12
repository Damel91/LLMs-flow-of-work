# 05 — Project Structure

**Version:** 0.1
**Status:** working_draft
**Last updated:** YYYY-MM-DD

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

In steady-state operation, three root-level files may be present because
models and users must find them immediately, without navigating:
`AGENT.md`, `README.md`, and `CODE-BOOTSTRAP.md`. Everything else lives inside
`authorities/`.

Temporary exception during adoption:

- `STARTER.md` and `MANUAL-STARTER.md` may be used at repository root only
  while adoption or migration is actively in progress
- they are adoption artifacts, not steady-state control-plane files
- they must be removed or excluded once adoption is complete

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
├── src/                             # project source code
├── config/                          # configuration files
├── tests/                           # automated test code and harnesses
├── release/                         # release-related artifacts (see section 4)
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
    │   └── REQUIREMENTS_DIFF_*.md
    ├── impl/                        # implementation packet history
    │   ├── IMPL-INDEX.md
    │   └── IMPL-*.md
    └── campaigns/                   # test evidence
        └── TestCampaign-*.md
```

Temporary adoption-only root files may exist during active adoption, but
they are not part of the canonical steady-state structure:

- `STARTER.md`
- `MANUAL-STARTER.md`

---

## 3. Layer Authority Table

| Folder | Authority role | Governed by | Must not contain |
|---|---|---|---|
| `/` (root) | Immediate model and user entry points plus installed integration bootstrap | — | Any authority document other than AGENT.md and README.md, except `CODE-BOOTSTRAP.md` and temporary adoption bootstraps during active adoption |
| `src/` | Project source code | Project-specific | Authority documents, test evidence |
| `config/` | Configuration files | Project-specific | Source code, authority documents |
| `tests/` | Automated test code and harnesses | `04-TEST-AND-HANDOFF-CONTRACT.md` | TestCampaign documents (those belong in campaigns/) |
| `release/` | Release artifacts — see section 4.5 | Project-specific | Authority documents, source code |
| `authorities/` | Full project authority docset | `02-DOCSET-GOVERNANCE-CONTRACT.md` | Source code, build artifacts |
| `authorities/PROJECT-OVERLAY.md` | Project-specific configuration and language settings | Updated via guided init or explicit user decision | Generic governance rules (those belong in flow-of-work-contract/) |
| `authorities/manual/` | User operating manual, onboarding bootstrap, and supporting manual notes | Explicit user decision and framework publication | Product requirements, IMPL packets, test evidence |
| `authorities/flow-of-work-contract/` | Workflow governance — how work is conducted | `00-INDEX.md` | Product requirements, IMPL packets |
| `authorities/baseline/` | Stable accepted product intent | `02-DOCSET-GOVERNANCE-CONTRACT.md` | Active diffs, implementation notes |
| `authorities/interactions/` | Scenario and interaction contract | `02-DOCSET-GOVERNANCE-CONTRACT.md` | Requirements baseline, IMPL packets |
| `authorities/diffs/` | Current and historical scope evolution | `01-LLM-SESSION-CONTRACT.md` | Accepted baseline text, test evidence |
| `authorities/impl/` | Bounded execution history | `01-LLM-SESSION-CONTRACT.md` | Requirements, test campaigns |
| `authorities/campaigns/` | Validation evidence | `04-TEST-AND-HANDOFF-CONTRACT.md` | Implementation plans, requirements |
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
the first document to read after the entrypoint itself.

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

### 4.4 tests/

Contains automated test code and harnesses — unit tests, integration tests,
regression tests, and any deterministic local test runners the project uses.

This folder is distinct from `authorities/campaigns/`. The difference is:

- `tests/` contains **executable code** that verifies behavior automatically.
- `authorities/campaigns/` contains **evidence documents** that record the
  outcome of a validation campaign, whether automated or manual.

A regression test lives in `tests/`. The record of running it lives in
`authorities/campaigns/`. Do not conflate the two.

### 4.5 release/

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

---

## 6. Adaptation Rules

The structure above is the canonical starting point. Projects may adapt it
within these constraints:

**Allowed:**
- Renaming `baseline/`, `interactions/`, `impl/`, `diffs/`, or `campaigns/`
  to names that better fit the project domain.
- Adding subfolders inside any layer folder to organize growing document sets.
- Adding project-specific document types inside the appropriate layer folder.

**Not allowed:**
- Merging two layer folders into one. The separation of baseline, diffs, impl,
  and campaigns is structural, not cosmetic. Merging them recreates the
  management problem this structure is designed to solve.
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
