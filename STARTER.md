# STARTER

This file is the guided adoption entrypoint for a model reading this
repository for the first time.

This is not a software project. It is a governance system for LLM-assisted
software development. Your role here is to help the user install this system
into a destination project.

---

## 0. What This Repo Is

This repository contains:

- a set of contract documents that define how humans and LLMs collaborate on
  software projects without losing control over time
- one session entrypoint template (`templates/AGENT-TEMPLATE.md`) that destination
  projects install at root
- a project overlay template and supporting templates
- a manual directory containing the front-facing operating manual, its
  onboarding bootstrap, and supporting notes
- two adoption procedures:
  - this guided procedure
  - `MANUAL-STARTER.md`
- one post-adoption code integration tool:
  - `CODE-BOOTSTRAP.md`
- a reader for browsing the contract documents offline

It is not a project. It has no requirements to implement, no traceability
matrix to update, and no IMPL packets to execute.

Do not create an `authorities/` folder here.
Do not execute project-level implementation work in this repository.
Do not expose a derived `AGENT.md` at the same logical level as this starter
inside the framework repository itself.

---

## 1. Establish Your Capability

Before anything else, determine which scenario applies:

**Scenario A — You have filesystem access**
You can create directories and files in the user's environment.
You will produce a real project structure.

**Scenario B — You do not have filesystem access**
You can only produce output for the user to apply manually.
You will generate the exact file contents and directory structure to copy.

Declare your scenario before proceeding.

---

## 2. Read The Adoption Set

Before starting the guided procedure, read in this order:

1. `flow-of-work-contract/00-INDEX.md`
2. `flow-of-work-contract/05-PROJECT-STRUCTURE.md`
3. `templates/PROJECT-OVERLAY.md`
4. `templates/AGENT-TEMPLATE.md`
5. `templates/IMPL-INDEX.md`
6. `templates/TRACEABILITY_MATRIX.md`
7. `CODE-BOOTSTRAP.md`
8. `manual/REACHING-THE-LLMS.md`
9. `manual/MANUAL-BOOTSTRAP.md`

Goal:

- understand the target project structure
- understand what gets copied as template
- understand what stays generic
- understand what must be project-specific
- understand how the code bootstrap is installed and later activated
- understand how the manual is installed and later used for user onboarding

---

## 3. Guided Procedure

Run these steps in sequence.
Ask one question at a time.
Do not skip ahead unless the user explicitly collapses steps.

### Step 1 — Identify the project state

Ask:

"Which of these are we adopting into the flow of work: a new project from
scratch, an existing project with usable documents to migrate, or an existing
codebase without usable documents?"

Record one of:

- `greenfield`
- `migration`
- `code_first`

### Step 2 — Migration shape

If `adoption mode = migration`, ask:

"Do you want a clean reset of the documentation/control plane, or do you want
to migrate and preserve parts of the current documentation structure?"

Record one of:

- `clean_reset`
- `partial_migration`

If `adoption mode` is `greenfield` or `code_first`, skip this step.

### Step 3 — Project name

Ask:

"What is the name of your project? If you prefer not to set a name, I will
mark it as no-name."

Record the answer.

### Step 4 — Language configuration

Ask:

"What language should be used for our conversations? And what language should
all project documents be written in? These can be different."

Record:

- conversation language
- documentation language

### Step 5 — System perimeter

Ask:

"In one or two sentences, what does this system do, and what must it never
touch?"

Record:

- allowed surface
- forbidden surface
- baseline assumption if the user gives one

### Step 6 — Protected subsystems

Ask:

"Are there any protected subsystems or areas that must never be changed
without your explicit approval?"

If yes, record:

- subsystem name
- why it is protected

If no, record `none declared`.

### Step 7 — Working-code behavioral reference

Ask:

"Is there an existing code area or prior implementation that should be treated
as the closest behavioral reference when future behavior is under-specified?"

Record:

- path / description
- or `none`

### Step 8 — Stable runtime context

Ask only for information that will remain useful after adoption. Do not ask for
implementation detail that belongs in requirements.

Ask:

"What runtime context should be predeclared now for future sessions? For
example: main code roots, primary test command, primary run or dev command,
runtime ecosystem, and any initial architecture intent in one or two
sentences."

Record only what the user can already state clearly:

- `primary_code_roots`
- `primary_test_command`
- `primary_run_command`
- `runtime_ecosystem`
- `initial_architecture_intent`
- `accepted_working_assumptions`

If unknown, record `none` or `not yet defined`.

Persist these values in `authorities/PROJECT-OVERLAY.md` only.
Do not duplicate them into `AGENT.md`.

### Step 8a — Manual onboarding starting state

Ask:

"What is your current familiarity with the framework manual: not started,
basic, operational, or do you want the installed project to skip guided manual
onboarding?"

Record one of:

- `not_started`
- `basic`
- `operational`
- `skip`

### Step 9 — Structure negotiation

Present the canonical structure from `05-PROJECT-STRUCTURE.md`.

Then ask:

"Do you want to keep the default structure, adapt it while staying compatible
with direct template installation, or adopt a different final structure that
would require the starter to derive final project files before installation?"

Record one of:

- `default`
- `adapted_direct_copy`
- `structure_override`

If the user chooses `adapted_direct_copy`, record the intended final locations.
Use this outcome only when the installed templates can remain semantically
correct without rewriting their structural path assumptions.

If the user chooses `structure_override`, record:

- which operational layer folders are being renamed or relocated:
  - `baseline`
  - `interactions`
  - `diffs`
  - `impl`
  - `campaigns`
- whether the final `05-PROJECT-STRUCTURE.md` must be rewritten from the
  framework canonical version
- whether the starter is transforming the current working repository itself
  into the destination repository

Before proceeding, state explicitly to the user:

"In this phase-1 flow you may adapt the operational layer layout, but the
bootstrap anchors remain fixed: `AGENT.md` stays at root; `authorities/`
remains the authority root; `authorities/manual/`, `PROJECT-OVERLAY.md`, the
contract set, and `TRACEABILITY_MATRIX.md` keep their framework locations.
`IMPL-INDEX.md` follows the final location of the `impl` layer you choose. If
your chosen `impl`, `diffs`, or `campaigns` locations would make direct
template paths false, this is a `structure_override` case."

### Step 10 — Existing documentation mapping

If `adoption mode = migration`, ask:

"What documentation already exists and should be mapped into the new structure?
For example: requirements, use cases, implementation notes, ADRs, test docs,
release docs."

Then classify with the user:

- what becomes `baseline`
- what becomes `interactions`
- what becomes `diffs`
- what becomes `impl`
- what becomes `campaigns`
- what should stay archived and not govern the new system

Do not migrate content yet unless the user asks you to.
This step exists to decide mapping, not to rewrite history automatically.

If `adoption mode` is `greenfield` or `code_first`, skip this step.

### Step 11 — Preview the end state

Before creating anything, summarize:

- project name
- adoption mode
- adoption procedure (`starter_guided`)
- conversation language
- documentation language
- system perimeter
- protected subsystems
- behavioral reference
- runtime context, if declared
- manual onboarding starting state
- chosen structure outcome
- migration shape, if relevant

Ask:

"This is the structure and configuration I am about to create. Do you want to
proceed?"

Do not create files before confirmation.

### Step 12 — Create the structure

**Scenario A — filesystem access**

Create the agreed destination structure.

The starter must first determine whether the chosen structure is:

- `default`
- `adapted_direct_copy`
- `structure_override`

#### 12.1 Always-install control-plane files

Regardless of structure outcome, always ensure the destination project
receives:

- `AGENT.md`
- `authorities/PROJECT-OVERLAY.md`
- `authorities/TRACEABILITY_MATRIX.md`
- `authorities/flow-of-work-contract/*`
- `authorities/manual/*`
- `IMPL-INDEX.md` at the final `impl` location
- `CODE-BOOTSTRAP.md`

`TRACEABILITY_MATRIX.md` is always installed as a template. Its content may be
empty or skeletal, but the file itself is part of the operational control
plane and must exist for later sessions.

Populate `authorities/PROJECT-OVERLAY.md` with:

- project name
- `adoption mode`
- `adoption procedure = starter_guided`
- conversation language
- documentation language
- protected subsystems
- system perimeter
- baseline assumption
- behavioral reference
- runtime context, if declared
- document location map for the final adopted layout

For overlay section 8:

- if manual familiarity = `not_started`:
  - `manual bootstrap status = pending`
  - `manual readiness level = not_started`
  - `last manual checkpoint = none`
  - `manual override acknowledged = no`
- if manual familiarity = `basic`:
  - `manual bootstrap status = completed`
  - `manual readiness level = basic`
  - `last manual checkpoint = The Core Operating Rules`
  - `manual override acknowledged = no`
- if manual familiarity = `operational`:
  - `manual bootstrap status = completed`
  - `manual readiness level = operational`
  - `last manual checkpoint = Final Advice`
  - `manual override acknowledged = no`
- if manual familiarity = `skip`:
  - `manual bootstrap status = skipped_by_user`
  - `manual readiness level = not_started`
  - `last manual checkpoint = skipped by user`
  - `manual override acknowledged = yes`

For overlay section 9:

- if `adoption mode = greenfield`:
  - `code bootstrap mode = not_required`
  - `code bootstrap status = not_required`
  - `code bootstrap source type = none`
  - `code bootstrap source reference = none`
  - `code bootstrap requested output = not_required`
- if `adoption mode = migration`:
  - `code bootstrap mode = not_required`
  - `code bootstrap status = not_required`
  - `code bootstrap source type = none`
  - `code bootstrap source reference = none`
  - `code bootstrap requested output = not_required`
- if `adoption mode = code_first`:
  - `code bootstrap mode = local_code_first_derivation`
  - `code bootstrap status = pending`
  - `code bootstrap source type = local_project`
  - `code bootstrap source reference = repository root`
  - `code bootstrap requested output = bootstrap_docs_only`

The optional minimum operational docset remains optional only for:

- `REQUIREMENTS.md`
- `REQUIREMENTS_FUNCTIONAL.md`
- `REQUIREMENTS_NON_FUNCTIONAL.md`
- `USE_CASES_AND_SEQUENCES.md`

#### 12.2 Default or direct-copy case

If the structure result is `default` or `adapted_direct_copy`:

- copy `templates/AGENT-TEMPLATE.md` into the destination or private workspace as the
  working source for the final installed `AGENT.md`
- copy `templates/PROJECT-OVERLAY.md` directly into the destination as
  `authorities/PROJECT-OVERLAY.md`
- copy `templates/TRACEABILITY_MATRIX.md` directly into the destination as
  `authorities/TRACEABILITY_MATRIX.md`
- copy `manual/*` directly into the destination as `authorities/manual/`
- copy `templates/IMPL-INDEX.md` directly into the final `impl` location
- copy `flow-of-work-contract/*` directly into the destination contract set
- copy `CODE-BOOTSTRAP.md` directly into the destination as
  `CODE-BOOTSTRAP.md`

No structure-override workspace is required in this branch.
The starter may still use a private working copy of `templates/AGENT-TEMPLATE.md`
before final promotion. Do not hand off the raw template unchanged.

#### 12.3 Structure-override case

If the structure result is `structure_override`:

1. create `.starter-work/`
2. copy into it the working sources needed for derivation:
   - `templates/AGENT-TEMPLATE.md`
   - `flow-of-work-contract/00-INDEX.md`
   - `flow-of-work-contract/05-PROJECT-STRUCTURE.md`
   - `CODE-BOOTSTRAP.md`
   - any other starter-needed source files
3. derive inside `.starter-work/`:
   - the final project-specific `AGENT.md`
   - the final project-specific `00-INDEX.md`
   - the final project-specific `05-PROJECT-STRUCTURE.md`
   - if needed, a final project-specific `CODE-BOOTSTRAP.md`
4. copy directly into the destination:
   - `templates/PROJECT-OVERLAY.md` -> `authorities/PROJECT-OVERLAY.md`
   - `templates/TRACEABILITY_MATRIX.md` -> `authorities/TRACEABILITY_MATRIX.md`
   - `manual/*` -> `authorities/manual/`
   - `templates/IMPL-INDEX.md` -> the final `impl` location chosen by the user
   - the contract set
5. replace only the file(s) that must become project-specific:
   - `AGENT.md`
   - `authorities/flow-of-work-contract/00-INDEX.md`
   - `authorities/flow-of-work-contract/05-PROJECT-STRUCTURE.md`
   - `CODE-BOOTSTRAP.md` if a derived copy was needed
6. promote only the final derived results into the destination project
7. remove `.starter-work/` when promotion is complete

The final promoted `AGENT.md` remains the single structural anchor used by the
next session.

The final promoted `05-PROJECT-STRUCTURE.md` becomes the structural contract of
the adopted project, even if it no longer matches the framework repository's
canonical default.

When the starter derives `AGENT.md` in the private workspace, it may rewrite:

- first-read paths
- traceability and IMPL index paths
- diffs and campaigns paths
- any other structural references needed so that the next session can start
  from `AGENT.md` alone and still find the control plane

The working `AGENT.md` source may temporarily still contain template-only
bootstrap text such as `Initialization Check` and adoption fallback routing.
Those parts belong to the template stage, not to the final adopted project.

When the starter derives `00-INDEX.md` in the private workspace, it may
rewrite:

- the authority-note references to operational layer locations
- any reading guidance that would otherwise name canonical layer paths that are
  false in the adopted project
- any cross-reference that must align with the final project-specific
  `05-PROJECT-STRUCTURE.md`

When the starter derives `05-PROJECT-STRUCTURE.md` in the private workspace, it
may rewrite:

- the canonical tree shown to the next session
- the authority table entries
- the location statements for baseline, interactions, diffs, impl, campaigns,
  and traceability

If `CODE-BOOTSTRAP.md` needs project-specific structural references in order to
operate coherently later, the starter may derive a final copy in
`.starter-work/` and promote that copy into the destination project.

If no such changes are required, copy the framework file directly.

If the user wants the minimum operational docset immediately:

- for `greenfield` or `migration`, create the baseline and interaction files at
  their final adopted locations chosen during structure negotiation:
  - `REQUIREMENTS.md`
  - `REQUIREMENTS_FUNCTIONAL.md`
  - `REQUIREMENTS_NON_FUNCTIONAL.md`
  - `USE_CASES_AND_SEQUENCES.md`
- for `code_first`, create only the final adopted baseline and interaction
  folders, without deriving their content yet

Populate created files only with:

- collected answers
- minimal placeholder structure

Do not invent project requirements.
Do not derive code-first baseline or interaction content here.

When writing files:

- write project-specific persistent configuration into
  `authorities/PROJECT-OVERLAY.md`
- keep `AGENT.md` focused on runtime behavior, read order, and rules
- let the starter, not the installed `AGENT.md`, own adoption-time validation
- do not turn `AGENT.md` into a second overlay
- do not duplicate runtime context across multiple files unless `AGENT.md`
  needs a minimal reference to read it from the overlay
- do not let `.starter-work/` or transient adaptation notes survive into the
  final destination project

### Step 12.4 — Finalization checks and final AGENT promotion

Before handoff, validate the installed control plane.

Check at least:

- `authorities/PROJECT-OVERLAY.md` exists and its project identity is no longer
  `[Project Name]`
- `authorities/flow-of-work-contract/00-INDEX.md` exists
- `authorities/TRACEABILITY_MATRIX.md` exists
- `authorities/manual/MANUAL-BOOTSTRAP.md` exists
- `authorities/manual/REACHING-THE-LLMS.md` exists
- the installed `IMPL-INDEX.md` exists at the final location declared by the
  overlay
- if the structure was adapted, the overlay document map matches the files
  actually installed
- overlay sec. 8 declares a non-placeholder manual onboarding state
- if `manual bootstrap status = skipped_by_user`, overlay sec. 8 also declares:
  - `manual override acknowledged = yes`
- if `adoption mode = code_first`, overlay sec. 9 declares:
  - `code bootstrap mode = local_code_first_derivation`
  - `code bootstrap status = pending`
- otherwise overlay sec. 9 declares:
  - `code bootstrap mode = not_required`
  - `code bootstrap status = not_required`

If these checks do not pass, do not hand off the project as ready.
Fix the destination control plane first.

After these checks pass, promote the final installed `AGENT.md`.

The starter may derive this final `AGENT.md` from the template even when the
structure is not overridden. The goal is to leave a runtime-ready entrypoint,
not a bootstrap-checking one.

This finalization is mandatory for every successful adoption path.
The installed project must never keep the raw template's bootstrap-checking
form as its final `AGENT.md`.

The final installed `AGENT.md` should:

- keep the manual-bootstrap handoff
- keep the code-bootstrap handoff
- keep the normal read order
- keep only essential runtime hard stops
- resolve installed paths coherently when structure was adapted
- remove the template-only `Initialization Check` section
- remove the template-only adoption fallback routing to `STARTER.md` and
  `MANUAL-STARTER.md`
- keep no adoption-procedure logic once the starter has validated the
  destination control plane successfully

In no-filesystem mode, simulate the same finalization privately and output only
the final promoted `AGENT.md`, not the raw working source.

Optional human-support artifacts may also be installed if the user wants them:

- `reader/`
- `beginning/STARTER-DIFF.md`

Do not install framework-repository residue into the destination project.

**Scenario B — no filesystem access**

Produce:

- the directory tree
- the list of files to create
- the contents of each file ready to copy

If the structure outcome is `structure_override`, simulate `.starter-work/`
privately in your own reasoning and output only the final derived files.

### Step 13 — Install set check

Before handoff, state explicitly which files belong in the destination project.

The required install set is:

- `AGENT.md`
- `authorities/PROJECT-OVERLAY.md`
- `authorities/TRACEABILITY_MATRIX.md`
- `authorities/flow-of-work-contract/*`
- `authorities/manual/*`
- `IMPL-INDEX.md` at the final `impl` location
- `CODE-BOOTSTRAP.md`
- any minimum operational docs explicitly created during adoption

The optional human-support set is:

- `reader/`
- `beginning/STARTER-DIFF.md`

The non-install set is:

- `STARTER.md`
- `MANUAL-STARTER.md`
- `README.md`
- `WHY.md`
- `LLM-CONTRIBUTORS.md`
- `.starter-work/`
- any temporary review, preparation, probe, or transient adaptation note that
  belongs only to this framework repository

If the user wants to keep an additional framework file, require an explicit
decision and state that it is being kept as a human-support artifact, not as
part of the operational control plane.

### Step 14 — Beginning record

If filesystem access is available, offer:

"Would you like me to save a record of this adoption in a `beginning/`
folder? It is optional and not part of the operational structure."

If accepted, create:

- `beginning/STARTER-DIFF.md`

Include:

- all answers collected
- structure decisions
- adoption mode
- migration shape if relevant
- files created
- files intentionally deferred

### Step 15 — End-state summary

At the end, produce an explicit summary containing:

- project identity
- adoption mode
- adoption procedure
- selected languages
- perimeter
- protected subsystems
- behavioral reference
- persisted runtime context, if any
- structure adopted
- whether direct template copy or `structure_override` was used
- whether `.starter-work/` was created
- whether `.starter-work/` was removed
- whether `AGENT.md` was copied directly or derived privately
- whether `00-INDEX.md` was copied directly or derived privately
- whether `05-PROJECT-STRUCTURE.md` was copied directly or derived privately
- whether `CODE-BOOTSTRAP.md` was copied directly or derived privately
- files created
- files deferred
- optional human-support artifacts retained
- framework files intentionally excluded
- exact location of the destination repository
- first document to use in the next working session

### Step 16 — Handoff

If `adoption mode = code_first`, conclude with:

"Your project is adopted for this flow of work. Start the first working session
from `AGENT.md` at the project root. If overlay sec. 8 still declares manual
onboarding pending or in progress, `AGENT.md` will first route that session
into `authorities/manual/MANUAL-BOOTSTRAP.md`. After manual onboarding is
completed or explicitly skipped, overlay sec. 9 still declares
`code bootstrap mode = local_code_first_derivation` and
`code bootstrap status = pending`, so the next first operational task is to
run `CODE-BOOTSTRAP.md` before normal initiative work begins."

Otherwise conclude with:

"Your project is adopted for this flow of work. From now on, start new
sessions from `AGENT.md` at the project root. If overlay sec. 8 still declares
manual onboarding pending or in progress, `AGENT.md` will first route the
session into `authorities/manual/MANUAL-BOOTSTRAP.md`; if manual onboarding is
completed or explicitly skipped, normal work begins from the control plane in
`authorities/`. `CODE-BOOTSTRAP.md` remains installed as a dormant integration
artifact unless later operational state activates it."

---

## 4. What Not To Do

- Do not invent product requirements during adoption.
- Do not open `IMPL-*` packets during adoption unless the user explicitly
  asks to migrate an active initiative immediately.
- Do not update a traceability matrix with implementation claims during
  adoption.
- Do not silently migrate historical documents into authoritative folders.
- Do not treat old project notes as canonical without explicit user mapping.
- Do not confuse this repository with the destination project.
- Do not persist adoption-only conversational notes into the overlay.
- Do not store runtime context in both overlay and entrypoint files.
- Do not copy the entire framework repository into the destination project by
  default.
- Do not leave `STARTER.md` in the destination project as an operational file.
- Do not leave `.starter-work/` or transient adaptation notes in the
  destination project.
- Do not run `CODE-BOOTSTRAP.md` during the adoption session itself.

---

## 5. Adoption Note

This starter intentionally separates:

- adoption procedure ownership
- persistent project configuration
- runtime entrypoint behavior
- structural contract finalization
- post-adoption code integration work

The adoption procedure belongs here.
Persistent project facts belong in `PROJECT-OVERLAY.md`.
Runtime operating rules belong in `AGENT.md`.
The final structural contract of the adopted project belongs in the installed
`05-PROJECT-STRUCTURE.md`.
Code integration and code-first derivation belong in `CODE-BOOTSTRAP.md` and
begin only after adoption has completed or when later operational state
explicitly activates that tool.
