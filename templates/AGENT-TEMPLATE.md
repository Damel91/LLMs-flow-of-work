# [Project Name] — Agent Entrypoint

This file is the runtime entrypoint for models working inside an adopted
project.

Replace every `[placeholder]` before use.

---

## 1. Initialization Check

Before normal work, verify that the project is initialized.

Check for:

- `authorities/PROJECT-OVERLAY.md`
- `authorities/flow-of-work-contract/00-INDEX.md`
- `authorities/TRACEABILITY_MATRIX.md`

Then read `authorities/PROJECT-OVERLAY.md` sec. 1, sec. 2, and sec. 10 if
structure was adapted.

Resolve the installed `IMPL-INDEX.md` location from the overlay when the
document map declares an adapted impl path. Otherwise use the default
`authorities/impl/IMPL-INDEX.md`.

If any required file is missing, or if the project name is still
`[Project Name]`, or if the installed `IMPL-INDEX.md` is missing, the project
is not initialized.

If the project is not initialized:

- stop normal runtime work
- do not recreate control-plane files from memory
- state that this entrypoint is runtime-first, not adoption-first
- route the user to the framework repo:
  - `STARTER.md` for guided adoption
  - `MANUAL-STARTER.md` for manual adoption
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
4. `authorities/TRACEABILITY_MATRIX.md`
5. the installed `IMPL-INDEX.md` location declared by the overlay
6. active `REQUIREMENTS_DIFF_*` in the installed diff location, if present
7. active `IMPL-*` in the installed impl location, if present
8. latest relevant `TestCampaign-*` in the installed campaigns location

Use the overlay and installed structure as the source of truth for adapted
locations.

---

## 5. Hard Stops

- Docs govern product intent and workflow.
- No non-trivial work without an active `IMPL-*`.
- `TRACEABILITY_MATRIX.md` is factual state only. Update it only from evidence.
- If behavior is not defined, stop and ask instead of inventing it.
- For prompts, routing, clarification, planning, or graph transitions, inspect
  the declared behavioral reference before proceeding.
