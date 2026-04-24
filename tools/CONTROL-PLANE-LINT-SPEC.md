# CONTROL-PLANE-LINT-SPEC

This document is the runtime-neutral version of the control-plane integrity
audit.

Use it when:

- the active model cannot run `python3`
- the workspace is available only through chat, web fetch, pasted files, or a
  non-Python tool environment
- you still want the same structural checks performed explicitly
- you are doing an extraordinary repository-integrity check, not normal
  initiative work

This spec does not replace the mechanical validator in
`tools/control_plane_lint.py`.
It mirrors its minimum checks in a form that any sufficiently capable model can
execute by reading the target repository.

This audit is not part of the normal flow of work.
Do not run it by default in every session.

---

## 1. Purpose

Validate structural coherence of either:

1. the framework repository itself (`framework` mode)
2. an adopted project workspace (`workspace` mode)

This lint does **not** judge:

- whether requirements are good
- whether a campaign is epistemically valid in substance
- whether the traceability matrix is honest in the merit of its contents
- whether a design decision is correct

It checks only structural and state coherence.

Use it mainly:

- before publishing the framework
- after structural refactors of the control plane
- after migrations or adoptions that may have gone wrong
- when routing, overlay state, or declared paths look suspicious

---

## 2. Required Output Format

When executing this spec, always return:

1. `Mode`
2. `Target`
3. `Errors`
4. `Warnings`
5. `Summary`

Rules:

- every failure must be classified as either `error` or `warning`
- if no issues exist, state `Errors: none` and `Warnings: none`
- the `Summary` must explicitly say whether the target passes structural lint
- do not silently fix files during lint execution

---

## 3. Execution Rules

Before checking anything:

1. state which mode you are running: `framework` or `workspace`
2. state the target path or target repository you are evaluating
3. read only the files needed for the chosen mode
4. do not infer missing file contents from memory
5. if a required file is absent, emit an `error` instead of guessing

During execution:

- do not rewrite files
- do not normalize invalid values silently
- do not promote a warning to pass/fail prose without listing it

---

## 4. Framework Mode

Use this mode when the target is the framework repository itself.

### 4.1 Required Files

The framework repo must contain at least:

- `README.md`
- `STARTER.md`
- `CODE-BOOTSTRAP.md`
- `CODE-WORKFLOW-CONTRACT.md`
- `WHY.md`
- `templates/AGENT-TEMPLATE.md`
- `templates/PROJECT-OVERLAY.md`
- `templates/IMPL-INDEX.md`
- `templates/TRACEABILITY_MATRIX.md`
- `templates/REQUIREMENTS-DIFF-TEMPLATE.md`
- `templates/IMPL-TEMPLATE.md`
- `templates/TEST-CAMPAIGN-TEMPLATE.md`
- `manual/MANUAL-BOOTSTRAP.md`
- `manual/REACHING-THE-LLMS.md`
- `flow-of-work-contract/00-INDEX.md`
- `flow-of-work-contract/01-LLM-SESSION-CONTRACT.md`
- `flow-of-work-contract/02-DOCSET-GOVERNANCE-CONTRACT.md`
- `flow-of-work-contract/03-BEHAVIORAL-DEFINITION-GATE.md`
- `flow-of-work-contract/04-TEST-AND-HANDOFF-CONTRACT.md`
- `flow-of-work-contract/05-PROJECT-STRUCTURE.md`

If one is missing: `error`.

### 4.2 Forbidden Residuals

The framework repo must not contain or reference stale names such as:

- `MANUAL-STARTER.md`
- `starter_manual`
- `templates/AGENT.md`
- `AGENT-TEMPORARY-COMPACT.md`
- `PROJECT-OVERLAY-TEMPORARY-CODE-BOOTSTRAP.md`
- `CODE-BOOTSTRAP-TEMPORARY-INTEGRATION.md`

Rule:

- if the stale name appears as a live framework reference, emit an `error`
- if it appears only inside an IMPL packet as historical discussion, that is
  allowed

### 4.3 AGENT Template Checks

Check `templates/AGENT-TEMPLATE.md`.

It must:

- inspect overlay sec. 8 before sec. 9
- route to `authorities/manual/MANUAL-BOOTSTRAP.md`
- route to `CODE-BOOTSTRAP.md`
- read or reference `CODE-WORKFLOW-CONTRACT.md`

If ordering or routing is missing: `error`.

### 4.4 Overlay Template Checks

Check `templates/PROJECT-OVERLAY.md`.

It must contain:

- `## 8. Manual Onboarding State`
- `## 9. Code Bootstrap State`
- `## 10. Document Location Map`

It must also define fields for:

- `Manual bootstrap status`
- `Manual readiness level`
- `Manual override acknowledged`
- `Code bootstrap mode`
- `Code bootstrap status`
- `Code bootstrap source type`
- `Code bootstrap requested output`

Missing section or field: `error`.

### 4.5 STARTER Checks

Check `STARTER.md`.

It must:

- include `authorities/manual/*` in the required install set
- include `CODE-WORKFLOW-CONTRACT.md` in the required install set
- include the three category templates in the required install set:
  - `REQUIREMENTS-DIFF-TEMPLATE.md` at the final `diffs` location
  - `IMPL-TEMPLATE.md` at the final `impl` location
  - `TEST-CAMPAIGN-TEMPLATE.md` at the final `campaigns` location
- include `STARTER.md` in the non-install set
- describe overlay sec. 8 routing before overlay sec. 9 routing in the final
  handoff logic

If any of these fail: `error`.

### 4.6 Structure Contract Checks

Check `flow-of-work-contract/05-PROJECT-STRUCTURE.md`.

It must:

- declare `authorities/manual/`
- declare `CODE-WORKFLOW-CONTRACT.md` as a root-level steady-state file
- declare the three category templates in the canonical destination folders
- describe `STARTER.md` as temporary adoption-only root file, not steady-state
  control plane

If missing: `error`.

---

## 5. Workspace Mode

Use this mode when the target is an adopted project workspace.

### 5.1 Required Files

The adopted workspace must contain at least:

- `AGENT.md`
- `CODE-BOOTSTRAP.md`
- `CODE-WORKFLOW-CONTRACT.md`
- `authorities/PROJECT-OVERLAY.md`
- `authorities/TRACEABILITY_MATRIX.md`
- `authorities/flow-of-work-contract/00-INDEX.md`
- `authorities/manual/MANUAL-BOOTSTRAP.md`
- `authorities/manual/REACHING-THE-LLMS.md`

If one is missing: `error`.

### 5.2 Runtime AGENT Checks

Check `AGENT.md`.

It must **not** still contain template-only adoption logic such as:

- `## 1. Initialization Check`
- routing text back to `STARTER.md`
- framework-repo adoption fallback language
- unresolved `[Project Name]` placeholder text

If any of these remain: `error`.

It must reference `CODE-WORKFLOW-CONTRACT.md`.
If missing: `error`.

### 5.3 Overlay State Checks

Check `authorities/PROJECT-OVERLAY.md`.

The following fields must exist and hold valid values:

- `Adoption mode`
- `Adoption procedure`
- `Manual bootstrap status`
- `Manual readiness level`
- `Manual override acknowledged`
- `Code bootstrap mode`
- `Code bootstrap status`
- `Code bootstrap source type`
- `Code bootstrap requested output`
- `Procedure completed`

Valid values:

- `Adoption mode`:
  - `greenfield`
  - `migration`
  - `code_first`
  - `unknown`
- `Adoption procedure`:
  - `starter_guided`
  - `unknown`
- `Manual bootstrap status`:
  - `pending`
  - `in-progress`
  - `completed`
  - `skipped_by_user`
  - `unknown`
- `Manual readiness level`:
  - `not_started`
  - `basic`
  - `operational`
  - `unknown`
- `Manual override acknowledged`:
  - `yes`
  - `no`
  - `unknown`
- `Code bootstrap mode`:
  - `not_required`
  - `local_code_first_derivation`
  - `external_source_integration`
  - `unknown`
- `Code bootstrap status`:
  - `not_required`
  - `pending`
  - `in-progress`
  - `completed`
  - `unknown`
- `Code bootstrap source type`:
  - `local_project`
  - `filesystem_repo`
  - `git_repo`
  - `url`
  - `web_research`
  - `archive`
  - `pasted_code`
  - `none`
  - `unknown`
- `Code bootstrap requested output`:
  - `not_required`
  - `bootstrap_docs_only`
  - `understanding_only`
  - `integration_recommendation`
  - `new_impl_required`
  - `implementation_candidate`
  - `unknown`
- `Procedure completed`:
  - `yes`
  - `no`
  - `in-progress`

Invalid or missing value: `error`.

### 5.4 Overlay Consistency Rules

Apply these rules:

1. If `manual bootstrap status = skipped_by_user`, then
   `manual override acknowledged` must be `yes`.
   Otherwise: `error`.

2. If `manual bootstrap status = completed`, then
   `manual readiness level` must be `basic` or `operational`.
   Otherwise: `error`.

3. If `code bootstrap mode = not_required`, then
   `code bootstrap status` should be `not_required` or `unknown`.
   Otherwise: `error`.

4. If `code bootstrap status = not_required`, then
   `code bootstrap mode` should be `not_required` or `unknown`.
   Otherwise: `error`.

5. If `code bootstrap mode = local_code_first_derivation`, then
   `adoption mode` must be `code_first`.
   Otherwise: `error`.

6. If `code bootstrap mode = local_code_first_derivation`, then
   `code bootstrap source type` should be `local_project` or `unknown`.
   Otherwise: `error`.

7. If `code bootstrap mode = external_source_integration`, then
   `code bootstrap source type` must not be `none` or `local_project`.
   Otherwise: `error`.

8. If `procedure completed = yes`, the overlay should not still leave core
   adoption fields at `unknown`.
   Remaining `unknown` values: `error`.

### 5.5 Document Location Map Checks

Check `## 10. Document Location Map`.

It must contain rows for:

- `Requirements baseline`
- `Interactions`
- `Requirement diffs`
- `Implementation packets`
- `Implementation packet index`
- `Test campaigns`
- `Traceability matrix`

For each row:

- if `Actual location = default`, use the default location
- otherwise use the declared actual path
- if the chosen path still contains placeholder text, emit `error`
- if the chosen path does not exist, emit `error`

Then verify the category creation templates exist at the resolved category
locations:

- `REQUIREMENTS-DIFF-TEMPLATE.md` in the resolved `Requirement diffs` location
- `IMPL-TEMPLATE.md` in the resolved `Implementation packets` location
- `TEST-CAMPAIGN-TEMPLATE.md` in the resolved `Test campaigns` location

If a category template is missing: `error`.

### 5.6 Workspace Pass Condition

The workspace passes only if:

- all required files exist
- `AGENT.md` is runtime-ready rather than template-like
- overlay fields are valid
- overlay cross-field rules hold
- the declared document map resolves to existing paths

---

## 6. Model-Executable Prompts

Use these prompts when you want another model to execute this spec directly.

### Framework mode

`Read tools/CONTROL-PLANE-LINT-SPEC.md and execute it in framework mode against this repository. Return Mode, Target, Errors, Warnings, and Summary only. Do not edit files.`

### Workspace mode

`Read tools/CONTROL-PLANE-LINT-SPEC.md and execute it in workspace mode against this adopted project. Return Mode, Target, Errors, Warnings, and Summary only. Do not edit files.`

---

## 7. Relation To The Python Validator

`tools/control_plane_lint.py` is the mechanical implementation.

This spec is the portable fallback.

If both are available, prefer the Python validator for repeatability.
If Python is unavailable, use this spec and report the result explicitly as a
model-executed integrity audit rather than a mechanical one.
