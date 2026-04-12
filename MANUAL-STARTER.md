# MANUAL STARTER

This document is the manual, human-first alternative to `STARTER.md`.

Use it when:

- you do not want to drive adoption through an LLM-guided procedure
- you want to adopt the destination project yourself
- you want a compact operational checklist for manual setup

This file is not part of the final operational control plane.
Like `STARTER.md`, it is an adoption tool only.

---

## 0. Recommended Way To Read This

Open `reader/md-reader.html` in a browser.

Then load, in this order:

1. `MANUAL-STARTER.md`
2. `flow-of-work-contract/05-PROJECT-STRUCTURE.md`
3. `templates/PROJECT-OVERLAY.md`
4. `templates/AGENT-TEMPLATE.md`
5. `templates/TRACEABILITY_MATRIX.md`
6. `CODE-BOOTSTRAP.md`
7. `manual/REACHING-THE-LLMS.md`
8. `manual/MANUAL-BOOTSTRAP.md`

The reader is optional, but it is the intended human-support tool for reading
these documents offline and in sequence.

---

## 1. Decide The Adoption Mode

Choose one:

- `greenfield`
- `migration`
- `code_first`

Use `code_first` when the project already exists in code but lacks usable
authoritative documents.

---

## 2. Install The Session Entrypoint

Use as working source:

- `templates/AGENT-TEMPLATE.md` -> `AGENT.md`

This repository uses one session entrypoint file in adopted projects.
Runtime capability is a property of the session, not of the filename.

Do not hand off the raw template unchanged.
The installed `AGENT.md` must become the final runtime entrypoint only after
you validate the destination control plane.

---

## 3. Create The Core Structure

Create in the destination project:

- `authorities/`
- `authorities/flow-of-work-contract/`
- `authorities/manual/`
- `authorities/impl/`

Then install:

- `templates/PROJECT-OVERLAY.md` -> `authorities/PROJECT-OVERLAY.md`
- `templates/TRACEABILITY_MATRIX.md` -> `authorities/TRACEABILITY_MATRIX.md`
- `flow-of-work-contract/*` -> `authorities/flow-of-work-contract/`
- `manual/*` -> `authorities/manual/`
- `templates/IMPL-INDEX.md` -> `authorities/impl/IMPL-INDEX.md`
- `CODE-BOOTSTRAP.md` -> `CODE-BOOTSTRAP.md`

Optional human-support artifacts:

- `reader/`
- `beginning/STARTER-DIFF.md`

If your desired final structure would require a derived `AGENT.md`, a rewritten
`05-PROJECT-STRUCTURE.md`, or a private staging workspace to keep the bootstrap
coherent, stop here and use `STARTER.md` instead. This manual path is for
direct-copy-compatible adoption.

---

## 4. Fill The Overlay

Populate `authorities/PROJECT-OVERLAY.md` with:

- project name
- adoption mode
- adoption procedure = `starter_manual`
- conversation language
- documentation language
- protected subsystems
- system perimeter
- behavioral reference
- document location map if the structure is adapted

For runtime context, also record any already-known values that will remain
useful in later sessions:

- primary code roots
- primary test command
- primary run/dev command
- runtime ecosystem
- initial architecture intent
- accepted working assumptions

Persist these values only in the overlay.
Do not duplicate them into `AGENT.md`.

Also record the initial manual-onboarding state:

- if the user has not yet worked through the manual:
  - `manual bootstrap status = pending`
  - `manual readiness level = not_started`
  - `last manual checkpoint = none`
  - `manual override acknowledged = no`
- if the user already understands the framework at a basic level:
  - `manual bootstrap status = completed`
  - `manual readiness level = basic`
  - `last manual checkpoint = The Core Operating Rules`
  - `manual override acknowledged = no`
- if the user already understands it operationally:
  - `manual bootstrap status = completed`
  - `manual readiness level = operational`
  - `last manual checkpoint = Final Advice`
  - `manual override acknowledged = no`
- if the user explicitly wants to skip guided onboarding:
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

---

## 5. Create The Minimum Operational Docset

If you want the minimum operational docset immediately:

- for `greenfield` or `migration`, create:
  - `authorities/baseline/REQUIREMENTS.md`
  - `authorities/baseline/REQUIREMENTS_FUNCTIONAL.md`
  - `authorities/baseline/REQUIREMENTS_NON_FUNCTIONAL.md`
  - `authorities/interactions/USE_CASES_AND_SEQUENCES.md`
- for `code_first`, create only:
  - `authorities/baseline/`
  - `authorities/interactions/`

Populate created files with minimal placeholder structure only.
Do not invent requirements during adoption.
Do not derive code-first baseline or interaction content here.

---

## 6. Existing Project Migration

If `adoption mode = migration`, manually decide:

- what becomes `baseline`
- what becomes `interactions`
- what becomes `diffs`
- what becomes `impl`
- what becomes `campaigns`
- what remains archive only

Do not silently promote old material into authoritative folders.
Map intentionally.

If this mapping is too complex to do manually, use `STARTER.md` instead of
this file.

---

## 7. Code-First Handoff

If `adoption mode = code_first`, do not run `CODE-BOOTSTRAP.md` during
manual adoption itself.

Instead:

- finish installing `AGENT.md` and the control-plane structure
- leave overlay section 9 with:
  - `code bootstrap mode = local_code_first_derivation`
  - `code bootstrap status = pending`
- start the first working session from `AGENT.md`
- let that session run `CODE-BOOTSTRAP.md` as its first operational task

---

## 8. Finalize The Installed AGENT

Before handoff, validate the installed control plane.

Check at least:

- `authorities/PROJECT-OVERLAY.md` exists and project identity is no longer
  `[Project Name]`
- `authorities/flow-of-work-contract/00-INDEX.md` exists
- `authorities/TRACEABILITY_MATRIX.md` exists
- `authorities/manual/MANUAL-BOOTSTRAP.md` exists
- `authorities/manual/REACHING-THE-LLMS.md` exists
- `authorities/impl/IMPL-INDEX.md` exists
- overlay sec. 8 declares a non-placeholder manual onboarding state
- if `manual bootstrap status = skipped_by_user`, overlay sec. 8 declares:
  - `manual override acknowledged = yes`
- if `adoption mode = code_first`, overlay sec. 9 declares:
  - `code bootstrap mode = local_code_first_derivation`
  - `code bootstrap status = pending`
- otherwise overlay sec. 9 declares:
  - `code bootstrap mode = not_required`
  - `code bootstrap status = not_required`

If these checks do not pass, do not hand off the project as ready.
Fix the destination control plane first.

After these checks pass, finalize `AGENT.md` as the runtime entrypoint.

The final installed `AGENT.md` should:

- keep the manual-bootstrap handoff
- keep the code-bootstrap handoff
- keep the normal read order
- keep only essential runtime hard stops
- remove the template-only `Initialization Check` section
- remove the template-only adoption fallback routing to `STARTER.md` and
  `MANUAL-STARTER.md`
- keep no adoption-procedure logic once the destination control plane has been
  validated successfully

---

## 9. Install Set

Required install set:

- `AGENT.md`
- `authorities/PROJECT-OVERLAY.md`
- `authorities/TRACEABILITY_MATRIX.md`
- `authorities/flow-of-work-contract/*`
- `authorities/manual/*`
- `authorities/impl/IMPL-INDEX.md`
- `CODE-BOOTSTRAP.md`
- any minimum operational docs you explicitly chose to create

Optional human-support set:

- `reader/`
- `beginning/STARTER-DIFF.md`

Do not copy into the destination project as operational files:

- `STARTER.md`
- `MANUAL-STARTER.md`
- `README.md`
- `WHY.md`
- `LLM-CONTRIBUTORS.md`
- temporary review, preparation, or probe files that belong to this framework
  repository

---

## 10. When Adoption Is Complete

The destination project is adopted when it has:

- the finalized runtime `AGENT.md` at root
- `authorities/PROJECT-OVERLAY.md`
- `authorities/TRACEABILITY_MATRIX.md`
- `authorities/flow-of-work-contract/*`
- `authorities/manual/*`
- `authorities/impl/IMPL-INDEX.md`
- `CODE-BOOTSTRAP.md`

After that point:

- stop using `STARTER.md`
- stop using `MANUAL-STARTER.md`
- start each new working session from `AGENT.md` in the destination project
- if `adoption mode = code_first`, let the first working session complete
  `CODE-BOOTSTRAP.md` before normal initiative work

---

## 11. If You Need A Guided Path

Use `STARTER.md` instead when you want:

- an LLM-guided adoption sequence
- explicit migration help
- structured documentation mapping
- an adoption record created for you
