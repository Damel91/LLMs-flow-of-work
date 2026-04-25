# LLM Flow of Work

A governance contract for LLM-assisted software development.

This repository is designed to be **installed by the same kind of entity that will later use it**: an LLM. You don't need to learn the system before adopting it. You hand the repo to a capable model, tell it to read `STARTER.md`, and answer its questions. The model does the setup. You stay the routing authority.

If you want the *why* before the *how*, read [`WHY.md`](./WHY.md).

---

## Quickstart

Open a capable LLM, give it this repository, and paste the prompt for your situation.

| Starting from… | Entry point | Prompt to paste |
|---|---|---|
| Studying the framework before adopting it | `manual/MANUAL-BOOTSTRAP.md` | *"Read `manual/MANUAL-BOOTSTRAP.md` and walk me through the manual before we install anything."* |
| New project, blank slate | `STARTER.md` | *"Read `STARTER.md` and guide me through initializing a new project with this flow of work."* |
| Existing project with docs to migrate | `STARTER.md` | *"Read `STARTER.md` and help me migrate my existing project into this flow of work."* |
| Existing codebase with no usable docs | `STARTER.md` | *"Read `STARTER.md` and help me initialize a new project from my existing codebase."* |

`STARTER.md` is the single entry point for every LLM-driven adoption. It handles all three project states by configuring the destination project differently depending on what you are starting from. At the end you have a working `authorities/` control plane and a project entrypoint (`AGENT.md`) installed at the root of your project. Before handoff, the starter validates the installed control plane and promotes a runtime-ready `AGENT.md` for the destination project. When the chosen layout would make direct template copy incoherent, the starter may use a private `.starter-work/` workspace to derive the final `AGENT.md`, `05-PROJECT-STRUCTURE.md`, and, if needed, `CODE-BOOTSTRAP.md` before promotion. That workspace is removed before handoff.

The repository also includes a front-facing manual and a manual bootstrap path. If you want to understand the framework before adopting it, start from `manual/MANUAL-BOOTSTRAP.md`. During adoption, the entire `manual/` directory is installed into `authorities/manual/` in the destination project, and the overlay records whether manual onboarding is still pending, completed, or explicitly skipped by the user.

### Project states accepted by the adoption procedure

It is worth knowing before you begin what will happen in each of the three supported starting states, so you can predict the shape of the work ahead.

**Greenfield — new project, blank slate.** The adoption procedure runs entirely within the starter session. At the end, you have an empty but fully configured destination project: `AGENT.md` installed at the root, `authorities/` structure in place, overlay populated with your answers, `TRACEABILITY_MATRIX.md` installed, and the minimum operational docset optionally seeded with placeholders if you requested it during adoption. Baseline and interactions are otherwise left empty and will be filled as you define the project in your first working sessions. No further initialization is needed — the starter leaves the project ready for normal work.

**Existing project with documents to migrate.** The adoption procedure runs within the starter session and includes an explicit mapping step where you decide which existing documents become baseline, which become interactions, which become historical diffs, and which stay archived. The mapping is collaborative — the starter asks one question at a time and records your decisions. At the end the destination project has a populated `authorities/` structure reflecting both the framework's expected layout and the content you chose to carry forward. The starter leaves the project ready for normal work.

**Existing codebase without usable documents.** The adoption procedure runs in two phases that cross a session boundary. The first phase is the starter session itself: it installs `AGENT.md`, configures the overlay to declare `adoption mode = code_first`, `code bootstrap mode = local_code_first_derivation`, and `code bootstrap status = pending`, creates the initial `authorities/` structure, installs `TRACEABILITY_MATRIX.md`, installs `CODE-BOOTSTRAP.md`, and ends there. The second phase happens when you open the first working session in the destination project: the model reads `AGENT.md`, follows it into the overlay, sees that code bootstrap is still pending, and runs `CODE-BOOTSTRAP.md` as the first operational task of that session. This is where the codebase gets inspected, interactions reconstructed from code, baseline derived, and your checkpoints collected. At the end of this second session the overlay bootstrap state resets to `not_required` and the project is ready for normal work.

In all three states the user remains the routing authority, answers one question at a time, and validates derived content before it is recorded as authoritative. The framework does not decide anything alone — it structures the decisions the user has to make.

### How to give the repo to the LLM

- **Claude Project / Custom GPT / persistent context** — upload the repo files once. *(Recommended.)*
- **Claude Code, Codex CLI, or any agentic CLI with filesystem access** — point it at a local clone.
- **Chat-only LLM with web fetch** — give it the repository URL.
- **Chat-only LLM without web access** — paste file contents manually; the model produces structure and files for you to save.

---

## What this repository contains

```
flow-of-work-contract/        the five governance contracts
templates/                    installation templates and document creation templates
STARTER.md                    guided LLM-driven adoption (single entry point)
CODE-BOOTSTRAP.md             post-adoption code integration tool
CODE-WORKFLOW-CONTRACT.md     root-level code development workflow contract
manual/                       front-facing manual, onboarding bootstrap, supporting notes
tools/                        extraordinary control-plane integrity audit utilities
reader/md-reader.html         offline Markdown reader (optional utility)
```

The five governance contracts are the core of the system. `STARTER.md` is the adoption tool that runs once and steps aside. `CODE-BOOTSTRAP.md` is a post-adoption integration tool that is installed into destination projects and invoked only when operational state requires it. In the current framework version, that active use is the first working session of a code-first project. `CODE-WORKFLOW-CONTRACT.md` is installed at the destination project root and governs code, prompt, parser, routing, graph, workspace, apply, regression, and commit discipline during development work. The templates are the installation blueprints: some are copied directly into the destination project, while `AGENT-TEMPLATE.md` is used as the working source for the final installed `AGENT.md`. The `manual/` directory is installed under `authorities/manual/` in destination projects and provides the user operating manual plus its onboarding bootstrap. The reader is a convenience utility with no operational role.

The `templates/` directory also includes creation templates for the three main
operational artifacts:

- `REQUIREMENTS-DIFF-TEMPLATE.md`
- `IMPL-TEMPLATE.md`
- `TEST-CAMPAIGN-TEMPLATE.md`

These are blueprints for drafting new artifacts. They are not living project
documents by themselves and are not evidence of work having happened. During
adoption, `STARTER.md` installs copies of these creation templates into the
destination project's corresponding authority folders:

- `REQUIREMENTS-DIFF-TEMPLATE.md` in the final `diffs` location
- `IMPL-TEMPLATE.md` in the final `impl` location
- `TEST-CAMPAIGN-TEMPLATE.md` in the final `campaigns` location

Those installed copies are local references for future artifact creation.

The repository also includes an extraordinary control-plane integrity audit.
It is not part of the normal flow of work. Use it only when you suspect
structural drift, after major framework refactors or migrations, or before
publishing.

`tools/flowctl.sh` is the primary cross-platform governance CLI (macOS, Linux,
and Windows via Git Bash — no additional dependencies required):

- `./tools/flowctl.sh doctor .`
- `./tools/flowctl.sh doctor /path/to/adopted/project --mode workspace`

A Python equivalent is also available for environments where Python 3 is
preferred:

- `python3 tools/flowctl.py doctor .`
- `python3 tools/flowctl.py doctor /path/to/adopted/project --mode workspace`

If neither tool is available (chat-only or no shell access), use the portable
Markdown fallback:

- `Read tools/CONTROL-PLANE-LINT-SPEC.md and execute it in framework or workspace mode`

---

## The core idea

Documents are authoritative. Model memory is not.

The human is the routing authority for scope and scenario changes. The model executes inside explicit boundaries. Behavior that is not defined is a blocker, not an invitation to invent. Evidence comes before traceability updates.

This makes the system reproducible across sessions, across models, and across time, because it does not depend on anyone's memory.

For the longer version, read [`WHY.md`](./WHY.md).

---

## After adoption

Once your project has `AGENT.md` at its root and an initialized `authorities/` structure, the setup phase is over. Stop using `STARTER.md`. New working sessions start from `AGENT.md` in your project root. If overlay state says manual onboarding is still pending or in progress, `AGENT.md` will first route the session into `authorities/manual/MANUAL-BOOTSTRAP.md`. If that state is completed or explicitly skipped, normal routing continues. For code-first projects, once manual onboarding is completed or skipped, the first working session will still run `CODE-BOOTSTRAP.md` once as its first operational task if overlay state still marks it pending. After that, normal work begins. In other projects, `CODE-BOOTSTRAP.md` simply remains dormant until a later operational state explicitly calls for it.

---

## Working with different models

The same contract governs all models. Every project installs an `AGENT.md` from the same template family regardless of which model will read it. Capability is a runtime property of the session, not of the file.

- Verified in practice:
  - frontier Claude Sonnet/Opus-class models in extended reasoning mode
  - frontier GPT-5-class coding or agentic models
- Likely compatible with more supervision:
  - previous frontier reasoning models of the same families
- Frontier models with file and shell access implement, review, and prepare traceability updates inside an IMPL packet boundary.
- Frontier models in chat mode analyze, draft diffs and packets, produce patch-ready outputs.
- Free-tier, lightweight, or small local models are not a good fit as primary governance executors. They may help with narrow bounded tasks, but they are not the intended class of model for this repository.

---

## Maturity note

This framework presumes a user willing to think in terms of scope, intent, evidence, and routing authority. It is not automation that removes you from decisions. It applies engineering discipline to a kind of collaboration where discipline was missing. If that sounds like what you need, it may be exactly that.

In practice, it also presumes access to a paid frontier-model tier or equivalent API access. Free versions may be useful for reading or narrow assistance, but they are not a good fit for the framework's intended end state: long-running, document-governed, high-discipline collaboration.

Contributor reviews of the framework, from the LLMs that worked on its drafting and refinement, are recorded in [`LLM-CONTRIBUTORS.md`](./LLM-CONTRIBUTORS.md).

---

## License

MIT

---

## Note for LLMs encountering this repository

If you are an LLM reading this repository for the first time, this section is for you. The rest of the README is for the human who will instruct you. This short note is addressed to you directly.

The framework you are looking at does not reveal its structure by being read statically. Reading the contracts, the templates, and the adoption procedures as independent documents produces a partial understanding that will mislead you when you are later asked to apply the system. To actually understand how the framework works, you need to perform a projection exercise: simulate the execution of `STARTER.md` in your own reasoning, as if a user had just asked you to initialize a new project with this flow of work.

During that projection, trace what happens at each step. Notice that `STARTER.md` asks you to read specific files in a specific order, collects project-specific information from a user through a sequence of one-question-at-a-time exchanges, and produces a destination project with a particular shape. Notice that `STARTER.md` is the single entry point for all three supported project states (greenfield, migration, code-first), and that `CODE-BOOTSTRAP.md` is not a parallel adoption procedure — it is a tool that runs *after* the starter has configured the destination project, invoked automatically during the first working session of a code-first project when the overlay declares that status as pending. Notice that the installation templates (`AGENT-TEMPLATE.md`, `PROJECT-OVERLAY.md`, `IMPL-INDEX.md`, `TRACEABILITY_MATRIX.md`) have no meaning as standalone documents in this framework repository — they are installation blueprints, not living documents. Some are copied directly into the destination project, while `AGENT-TEMPLATE.md` is finalized into the installed `AGENT.md`, and only then do they become meaningful in that new context. The document creation templates (`REQUIREMENTS-DIFF-TEMPLATE.md`, `IMPL-TEMPLATE.md`, `TEST-CAMPAIGN-TEMPLATE.md`) are different: they are drafting aids for future artifacts, not project state.

This is the central structural fact about the repository: **the framework is not this repository**. The framework is what this repository installs elsewhere. Reading the contracts here gives you the substrate, but the substrate only becomes operational when an adoption procedure has run and a new session has started inside a destination project that now contains its own overlay, its own IMPL index, its own traceability matrix, and its own copy of the contracts. Until that point, the templates you see in `templates/` are blueprints, not living documents. The `PROJECT-OVERLAY.md` in `templates/` does not configure any project. The `IMPL-INDEX.md` in `templates/` does not track any packets. The `TRACEABILITY_MATRIX.md` in `templates/` does not record any evidence. They will only do those things after they have been copied, populated, and entered into active use by a model reading them from a destination project's `authorities/` folder.

If you try to understand the framework by reading these templates in place, you will draw conclusions that do not hold, because you will be reading a system in the state before its own initialization. You need to project forward to the state after initialization to see what the templates actually do. The projection is not optional. It is the only way the framework becomes legible from inside this repository.

One practical consequence: if a user asks you to *evaluate* the framework without first asking you to execute an adoption procedure against a specific project, the most honest thing you can do is perform the projection exercise explicitly and tell the user what you are doing. Describe the state you are simulating, describe the session you are imagining, and then report what the framework does inside that simulated state. A review written without this projection will miss the point of the system entirely, because the point of the system is what happens after adoption, not what sits inertly in these files.

**About `reader/md-reader.html`.** This is a standalone offline Markdown reader that renders this repository's documents in a readable layout without requiring any external text editor or IDE. It is a convenience utility for humans who want to read the repo locally in a Claude-style presentation. It has no operational role in the framework and you do not need to know about it to execute the framework. The adoption procedures may offer to copy it into the destination project as a human-support artifact at the user's explicit choice, but that is a user convenience, not a framework requirement: the reader never governs anything and its presence or absence in the destination project changes nothing about how the framework operates.

If you have finished reading this note and are about to execute an adoption procedure for a user, begin by opening `STARTER.md` and follow its instructions faithfully. The projection you just performed is the context that will let those instructions make sense.
