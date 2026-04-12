# CODE-BOOTSTRAP

This file is a post-adoption code integration tool.

In the current framework version its automatic runtime use is the derivation
path for projects that started from existing code without usable documents.
It is not an adoption procedure and it is not a parallel entry point to the
framework.

It can also be invoked explicitly later to analyze an external codebase or
repository and convert the relevant parts of that source into the current
contractual structure of an already adopted destination project.

If you are about to initialize a new project, do not read this file. Read
`STARTER.md` instead. `STARTER.md` is the single entry point for adoption.

---

## 0. When This Tool Runs

This tool runs in two legitimate situations:

### A. Automatic code-first derivation

- the destination project has already been adopted via `STARTER.md`
- `STARTER.md` was run in code-first mode because the project started from
  an existing codebase
- `AGENT.md` is installed at the destination project root
- `PROJECT-OVERLAY.md` sec. 2 declares `adoption mode = code_first`
- `PROJECT-OVERLAY.md` sec. 9 declares
  `code bootstrap mode = local_code_first_derivation`
- `PROJECT-OVERLAY.md` sec. 9 declares `code bootstrap status = pending`
  (or `in-progress` if a previous session did not finish)
- the first working session has just started
- the model has read `AGENT.md` and followed it into the overlay
- the overlay state has directed the model to execute this file

### B. Explicit external-source integration

- the destination project has already been adopted
- the user wants to integrate, port, extract, or understand material from an
  external source repository, archive, pasted codebase, or similar source
- the user has explicitly chosen to use this tool for that integration task

If neither situation applies, do not run this tool.

It is also legitimate to invoke this tool in isolation — for example, in a
chat session without filesystem access, on code pasted by the user — as a
pure derivation utility. In that mode, the output is returned as content in
the conversation and the user is responsible for deciding what to do with
it. No assumption is made about writing files, configuring overlays, or
creating project structure. The core derivation and intake procedure below
is the same in both modes; what changes is only where the output goes.

---

## 1. What This Tool Owns

This tool owns the contractual conversion of non-contractual source material
into the current adopted project structure under user validation.

It does:

- guided review of the relevant source code as a system
- reconstruction of interactions from code
- derivation of initial baseline content from code
- seeding of an initial traceability matrix when the destination project
  already has one
- user checkpoints to resolve ambiguity, incoherence, or missing intent
- source intake classification when the source is external or the requested
  integration scope is not obvious
- optional creation of a temporary integration brief for non-trivial external
  intake
- proposal of new `IMPL-*` packets when reverse engineering reveals work that
  should be tracked explicitly

It does not:

- install `AGENT.md`, the overlay, or the `authorities/` structure
- choose a session entrypoint or a control-plane layout
- declare derived content automatically authoritative
- replace explicit user validation
- silently rewrite project intent from code alone
- silently expand external-source analysis beyond what the user asked for

---

## 2. Choose The Operating Mode

Before broad analysis, classify which mode applies.

### A. `local_code_first_derivation`

Use this when the source and destination are the same project and the tool is
running because `code bootstrap mode = local_code_first_derivation` and
`code bootstrap status = pending` or `in-progress`.

Default assumptions:

- integration intent = `bootstrap_docs_only`
- source authority class = `code_only` unless the user says otherwise
- analysis depth = `broad` unless the codebase is very small or very large and
  the user narrows the target
- relevance boundary = the destination project as a whole unless the user
  explicitly narrows the derivation target
- required output = `bootstrap_docs_only`
- stop condition = enough understanding to derive the destination baseline,
  interactions, and initial traceability state for the requested scope

This mode still uses the intake gate below.
What changes is only that most intake variables have a safe default and the
brief is usually not required.

### B. `external_source_integration`

Use this when the source is a different repository, archive, pasted module, or
other non-trivial external material.

In this mode the model must not begin broad analysis until it has fixed:

- integration intent
- source authority class
- analysis depth
- relevance boundary
- required output
- stop condition

If the source is external and the integration target is not trivially small,
create a temporary brief:

- `authorities/CODE-BOOTSTRAP-BRIEF.md`

This brief is not a contract and not a standing control-plane file.
It exists only to keep the session bounded and coherent.

It may be:

- deleted after the bootstrap ends
- or retained at explicit user request as a historical aid

---

## 3. Source Intake Gate

Classify the source before broad analysis.

If mode = `local_code_first_derivation`, use the default values above unless
the user or the repo state gives a reason to override them.

If mode = `external_source_integration`, capture everything explicitly before
broad analysis.

Capture at least:

- source identity
  - local path / git repo / archive / pasted code / URL
- destination identity
  - which adopted project is receiving the integration
- integration intent
- source authority classification
- analysis depth
- in-scope source areas
- out-of-scope source areas
- contradiction note, if present
- required output
- stop condition

### 3.1 Integration intent

Use one of:

- `reference_only`
- `behavior_extract`
- `module_import`
- `partial_port`
- `full_convergence`

### 3.2 Source authority classification

Use one of:

- `code_only`
- `code_plus_light_docs`
- `code_plus_authoritative_docs`
- `conflicted_or_unknown`

### 3.3 Analysis depth

Use one of:

- `minimal`
- `targeted`
- `broad`
- `deep`

Choose the shallowest depth that can satisfy the intent.
Do not choose `deep` by reflex.

### 3.4 Required output

Use one of:

- `understanding_only`
- `bootstrap_docs_only`
- `integration_recommendation`
- `new_impl_required`
- `implementation_candidate`

### 3.5 Brief rule

If mode = `external_source_integration` and the source is non-trivial, create
`authorities/CODE-BOOTSTRAP-BRIEF.md` before broad analysis and record the
intake classification there.

If mode = `local_code_first_derivation`, the brief is optional. Use it only
when one of these is true:

- the destination repo is large enough that default whole-project analysis
  would be wasteful
- the user wants derivation only for a subsystem or bounded scope
- contradictory pre-existing docs or source surfaces make the default path
  ambiguous
- the model cannot state a reliable stop condition without writing it down

The brief is the commitment point that prevents silent scope expansion.

---

## 4. Read The Required Set

Before starting derivation or targeted integration, read in this order:

1. `authorities/PROJECT-OVERLAY.md` (the destination project's overlay)
2. `authorities/flow-of-work-contract/03-BEHAVIORAL-DEFINITION-GATE.md`
3. `authorities/flow-of-work-contract/05-PROJECT-STRUCTURE.md`
4. any existing destination content in the installed baseline and interaction
   locations declared by the overlay
5. the relevant source code itself — entry points, major modules, test surfaces

If mode = `external_source_integration` and source documentation exists inside
the declared scope:

- read the in-scope source docs before broad code analysis
- use those docs as guidance only to the degree justified by the source
  authority classification
- verify them against code when the integration decision depends on them

If mode = `local_code_first_derivation` and partial pre-existing destination
docs exist, read them only as weak guidance unless the user explicitly says
they are still reliable. They do not override code-derived analysis by default
in this mode.

Goal:

- understand the destination project's declared structure
- understand which destination locations would receive derived or integrated
  material
- understand what the relevant source actually does
- do only as much reading as the chosen depth and intent justify

If running in isolation without a destination project, skip destination-specific
steps and treat the output as content to return to the user.

---

## 5. Review The Source As A System

Inspect the relevant source to identify:

- main entry points
- major subsystems
- user-visible surfaces
- data or state boundaries
- external integrations
- obvious operational constraints

If a relevance boundary was declared, stay inside it unless a contradiction or
hard dependency forces expansion. If that happens, state it explicitly and
update the brief before continuing when a brief exists.

This is not a bug review. This is a system-level reverse engineering pass
aimed at understanding what the relevant source does today, in enough detail
to reconstruct interaction and baseline meaning under user validation.

---

## 6. Reconstruct Interactions First

Produce the first interaction artifact justified by the active mode and the
required output.

If mode = `local_code_first_derivation`:

- produce a first draft of interaction content for the destination project's
  installed `USE_CASES_AND_SEQUENCES.md` location

If mode = `external_source_integration`:

- produce only the interaction material required by the brief
- if the required output is `bootstrap_docs_only`, `new_impl_required`, or
  `implementation_candidate`, draft destination interaction content at the
  installed destination interaction location
- if the required output is `understanding_only` or
  `integration_recommendation`, return the interaction reconstruction in the
  conversation or in the brief without writing destination docs yet

The draft should reconstruct:

- main actors
- main use cases
- key sequences or flows
- important state transitions
- boundaries that are evident from source code

Mark derived interaction material clearly as derived from code and pending user
validation.

---

## 7. User Checkpoint On Interactions

Present to the user:

- what was reconstructed confidently
- what remains ambiguous
- what appears inconsistent
- what appears missing
- what was intentionally left out because it was outside the chosen scope

Ask the user to confirm, correct, narrow, or override.
Do not proceed to baseline derivation until this checkpoint is handled.

---

## 8. Derive The Baseline

After the interaction checkpoint, produce the baseline material justified by
the active mode and required output.

If mode = `local_code_first_derivation`:

- produce a first draft of baseline content for the destination project's
  installed `REQUIREMENTS.md`,
  `REQUIREMENTS_FUNCTIONAL.md`, and
  `REQUIREMENTS_NON_FUNCTIONAL.md` locations

If mode = `external_source_integration`:

- derive only the baseline material required by the brief
- if the required output is `bootstrap_docs_only`, `new_impl_required`, or
  `implementation_candidate`, write draft destination baseline content into the
  installed destination baseline locations
- if the required output is `understanding_only` or
  `integration_recommendation`, return the derived baseline understanding
  without forcing destination writes

These drafts must express:

- what the relevant source appears to do today
- what constraints are evident from source code
- what behavior has been confirmed by the user during the interaction
  checkpoint
- what remains derived and not yet validated

Mark each derived document or derived baseline block as code-derived and
partially validated.

Non-functional derivation from code is limited by construction: performance
budgets, security constraints, and operational boundaries rarely leave
legible traces in source. Be explicit about what you cannot derive and ask
the user to declare those constraints directly.

---

## 9. Seed The Traceability Matrix

Only update or seed the destination traceability matrix when the required
output justifies conversion into the adopted project's contractual structure.

If the result is only understanding or recommendation, do not touch the
matrix.

When the matrix is in scope, create or populate the installed
`TRACEABILITY_MATRIX.md` reflecting the state of the destination project
relative to the derived or imported document base.

Distinguish at least:

- derived from code
- user-validated
- not yet validated

The matrix at this stage is a seeded state description, not a claim of final
requirements acceptance.

---

## 10. Resolve Incoherences Explicitly

If analysis reveals incoherences between current code behavior, reconstructed
interactions, derived baseline, source documentation, or user-declared
intended behavior, do not force silent convergence.

Name each incoherence explicitly, ask the user to decide which source should
govern for this integration task, and update the derived materials only after
that decision.

If mode = `external_source_integration`, record the contradiction in
`CODE-BOOTSTRAP-BRIEF.md` if the brief exists.

---

## 11. Propose IMPL Packets When Needed

If the derivation or integration reveals work that should be tracked as an
explicit bounded initiative — behavior clarified but code and docs diverge,
architecture that needs controlled cleanup, documented flow that must be
repaired, traceability that requires a known implementation follow-up, or an
external integration that cannot be completed safely in one pass — propose
new `IMPL-*` packets.

Do not open the packets automatically without user agreement.

---

## 12. Close The Run

If mode = `local_code_first_derivation`:

- when derivation is complete and the user has validated enough content to
  proceed with normal work, update `PROJECT-OVERLAY.md` sec. 9 to set:
  - `code bootstrap mode = not_required`
  - `code bootstrap status = not_required`
  - `code bootstrap source type = none`
  - `code bootstrap source reference = none`
  - `code bootstrap requested output = not_required`
- summarize:
  - what was derived from code
  - what was validated by the user
  - what remains open
  - whether new `IMPL-*` packets are recommended
  - that the destination project is now in normal operational mode

If mode = `external_source_integration`:

- if this run was activated through overlay state, reset `PROJECT-OVERLAY.md`
  sec. 9 to:
  - `code bootstrap mode = not_required`
  - `code bootstrap status = not_required`
  - `code bootstrap source type = none`
  - `code bootstrap source reference = none`
  - `code bootstrap requested output = not_required`
  unless the user explicitly wants the completion state retained
- summarize:
  - what source was analyzed
  - what was intentionally not analyzed
  - what is now understood sufficiently
  - what remains unknown
  - whether the integration can proceed
  - whether new `IMPL-*` packets are recommended
  - whether `CODE-BOOTSTRAP-BRIEF.md` should be deleted or retained

From this point forward, the destination project continues normal work from
`AGENT.md`. This tool is invoked again only when explicit operational state or
an explicit user decision calls for it.

---

## 13. What Not To Do

- Do not treat code-derived documents as automatically authoritative.
- Do not skip the user checkpoint between interaction reconstruction and
  baseline derivation.
- Do not write final traceability claims as if requirements were already
  fully validated.
- Do not open `IMPL-*` packets automatically without user confirmation.
- Do not confuse bug review with system-level reverse engineering.
- Do not begin broad external-source analysis before classifying intent,
  authority, depth, and scope.
- Do not assume source documentation is authoritative just because it exists.
- Do not confuse understanding a source with integrating that source.
- Do not leave `CODE-BOOTSTRAP-BRIEF.md` standing by default after it has
  served its purpose.
- Do not install, modify, or overwrite `AGENT.md`, the overlay structure, or
  any control-plane file that the adoption procedure already placed.
- Do not assume filesystem access. If you do not have it, return the output as
  content in the conversation and let the user place it.
