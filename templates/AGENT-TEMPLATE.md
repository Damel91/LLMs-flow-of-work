# [Project Name] — Agent Entrypoint

This file is the runtime entrypoint for models working inside an adopted
project.

Replace every `[placeholder]` before use.

---

## 1. Runtime Boot

Before normal work, read:

1. `authorities/PROJECT-OVERLAY.md`
2. `CODE-WORKFLOW-CONTRACT.md`

From the overlay, use:

- sec. 1-3 for project identity, adoption mode, language, and scope
- overlay sec. 8 for manual-bootstrap state
- overlay sec. 9 for code-bootstrap state
- sec. 10 for installed document locations
- sec. 11 for available `flowctl.sh` commands

If `PROJECT-OVERLAY.md`, `CODE-WORKFLOW-CONTRACT.md`, or the contract index at
`authorities/flow-of-work-contract/00-INDEX.md` is missing, stop normal runtime
work. Do not recreate control-plane files from memory; route the user to the
framework `STARTER.md`.

---

## 2. Bootstrap Routing

Inspect overlay sec. 8 before overlay sec. 9.

Run `authorities/manual/MANUAL-BOOTSTRAP.md` if:

- `manual bootstrap status` is `pending` or `in-progress`

If manual bootstrap runs, stop normal work until it returns control. Then reload
the overlay before checking code-bootstrap state.

Run `CODE-BOOTSTRAP.md` if both are true:

- `code bootstrap mode` is not `not_required`
- `code bootstrap status` is `pending` or `in-progress`

If code bootstrap runs, stop normal work until it returns control. Use the
overlay as the activation source of truth for both bootstrap paths.

---

## 3. Operational Orientation

Use overlay sec. 11 tooling instead of duplicating navigation logic here.

Recommended flow:

1. Use the runtime state command when current mode or active state is
   unclear.
2. Use the route command when the next runtime path is unclear.
3. Use the active diff command before implementation planning when the active
   `REQUIREMENTS_DIFF_INDEX.md` target is unclear.
4. Use the location command or overlay sec. 10 to resolve installed document
   locations.
5. Read only the governing documents needed for the requested work:
   - the contract index and relevant contracts
   - `CODE-WORKFLOW-CONTRACT.md` for code, prompt, parser, routing, graph,
     workspace, apply, regression, or commit work
   - the active requirement diff, if one exists
   - overlapping review holds, active IMPL packets, and linked campaigns when
     they affect the request
6. Before handoff, use the handoff command or the relevant checks declared in
   overlay sec. 11.

---

## 4. Hard Stops

- Docs govern product intent and workflow.
- No non-trivial work without an active `IMPL-*`.
- Do not infer the active diff from filenames or recency; use the index/tooling.
- `TRACEABILITY_MATRIX.md` is factual state only. Update it only from evidence.
- If behavior is not defined, stop and ask instead of inventing it.
- For prompts, routing, clarification, planning, or graph transitions, inspect
  the declared behavioral reference before proceeding.
