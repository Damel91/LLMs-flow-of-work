# [Project Name] — Agent Entrypoint

This file is the runtime entrypoint for models working inside an adopted
project.

Replace every `[placeholder]` before use.

---

## 1. Initialization Check

Before normal work, verify that the project is initialized.

Check for:

- `CODE-WORKFLOW-CONTRACT.md`
- `authorities/PROJECT-OVERLAY.md`
- `authorities/flow-of-work-contract/00-INDEX.md`

Then read `authorities/PROJECT-OVERLAY.md` sec. 1, sec. 2, and sec. 10.
Use the document map to resolve installed locations before checking
location-adaptable files.

Resolve at least:

- `TRACEABILITY_MATRIX.md`
- `IMPL-INDEX.md`
- `REQUIREMENTS_DIFF_INDEX.md`
- the installed campaigns location

If any required file is missing, or if the project name is still
`[Project Name]`, or if a resolved required control-plane file is missing, the
project is not initialized.

If the project is not initialized:

- stop normal runtime work
- do not recreate control-plane files from memory
- state that this entrypoint is runtime-first, not adoption-first
- route the user to the framework repo:
  - `STARTER.md` for guided adoption
  - `STARTER.md` in `code_first` mode if the project starts from existing code

---

## 2. Manual Bootstrap Handoff

Before code bootstrap or the normal read sequence, inspect overlay sec. 8.

Run `authorities/manual/MANUAL-BOOTSTRAP.md` if:

- `manual bootstrap status` is `pending` or `in-progress`

If so:

- stop the normal read sequence
- execute `authorities/manual/MANUAL-BOOTSTRAP.md` as the first operational task
- use the overlay as the activation source of truth

Otherwise continue.

---

## 3. Code Bootstrap Handoff

Before the normal read sequence, inspect overlay sec. 9.

Run `CODE-BOOTSTRAP.md` if both are true:

- `code bootstrap mode` is not `not_required`
- `code bootstrap status` is `pending` or `in-progress`

If so:

- stop the normal read sequence
- execute `CODE-BOOTSTRAP.md` as the first operational task
- use the overlay as the activation source of truth

Otherwise continue.

---

## 4. Read First

Read in this order:

1. `authorities/PROJECT-OVERLAY.md`
2. `authorities/flow-of-work-contract/00-INDEX.md`
3. continue through the contract set in the order declared by `00-INDEX.md`
4. `CODE-WORKFLOW-CONTRACT.md`
5. the installed `TRACEABILITY_MATRIX.md` location declared by the overlay
6. the installed `IMPL-INDEX.md` location declared by the overlay
7. the installed `REQUIREMENTS_DIFF_INDEX.md` location declared by the overlay
8. active `REQUIREMENTS_DIFF_*` named by the diff index, if present
9. active `IMPL-*` in the installed impl location, if present
10. `TestCampaign-*` linked by the active IMPL or active diff, if present

Use the overlay and installed structure as the source of truth for adapted
locations.

---

## 5. Hard Stops

- Docs govern product intent and workflow.
- No non-trivial work without an active `IMPL-*`.
- Code, prompt, parser, routing, and graph changes follow
  `CODE-WORKFLOW-CONTRACT.md`.
- `TRACEABILITY_MATRIX.md` is factual state only. Update it only from evidence.
- If behavior is not defined, stop and ask instead of inventing it.
- For prompts, routing, clarification, planning, or graph transitions, inspect
  the declared behavioral reference before proceeding.
