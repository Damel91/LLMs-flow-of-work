# Traceability Matrix

**Version:** 0.2
**Status:** working_draft
**Last updated:** 2026-04-12
**Revision note:** Initial empty matrix. Will be populated from factual
implementation evidence and authoritative `TestCampaign-*` outcomes.

---

## 0. Purpose

This document is the cross-cutting factual state register for the project.

It records, for each requirement defined in the canonical baseline and in the
currently tracked requirement diffs, the current factual implementation status
and the evidence that supports that status.

It is **not** a planning document. It is **not** a roadmap. It is **not** an
intent register. It moves only when evidence exists. A row says `Implemented`
because a `TestCampaign-*` accepted by the user demonstrated the behavior, or
because the project explicitly allows an equivalent acceptance bar. A row may
say `Partial` when code references and model review establish a conservative
factual state even before the first authoritative campaign has happened.

If you find yourself wanting to mark something `Implemented` because the work
"is done" but no evidence has been gathered, stop. The matrix is not where
that belongs.

This document lives at the root of `authorities/` because it references all
layers simultaneously — baseline, interactions, diffs, IMPL packets, and
campaigns. See `flow-of-work-contract/05-PROJECT-STRUCTURE.md` section 5.

---

## 1. Status Legend

| Status | Meaning |
|---|---|
| `Implemented` | Present in the current repo and accepted by authoritative evidence |
| `Partial` | Present in the current repo, but still conservative: either awaiting first authoritative campaign, or already validated but still drifting / incomplete / constrained |
| `Gap` | Required by the currently tracked requirement set but not yet implemented |

These are the only three states. They are deliberately coarse.

Finer-grained progress (Open / In progress / Planned / Implemented / Merged
/ Superseded / etc.) belongs to the installed `IMPL-INDEX.md` at the
project's actual implementation-packet location. The matrix
records repo reality against requirements, not packet lifecycle.

If a requirement has multiple sub-aspects with different statuses, prefer
`Partial` and explain the breakdown in the Notes column. Do not invent a
fourth status.

Do not introduce lifecycle labels such as `pending`, `deferred`, or `planned`
as matrix statuses. Those belong to diff / IMPL management, not to factual
requirement state.

---

## 2. Functional Traceability

| ID(s) | Requirement summary | IMPL packet(s) | Behavior gate | Primary evidence | Status | Notes |
|---|---|---|---|---|---|---|
| `FR-XXX-01` | [one-line summary of the requirement] | `IMPL-NN`, `IMPL-NN.M` | clear | `path/to/file.ext`, `path/to/other.ext` | Implemented | [concise factual note, citing authoritative test evidence] |
| `FR-XXX-02`, `FR-XXX-03` | [grouped requirements covered by the same change] | `IMPL-NN` | clear | `path/to/file.ext` | Partial | [implemented in code; awaiting first authoritative campaign, or describe validated drift / missing coverage] |
| `FR-YYY-01` | [requirement not yet implemented] | — | not_applicable | — | Gap | [optional: pointer to the diff that introduced it] |

**Column conventions:**

- **ID(s)** — one or more requirement IDs from the canonical baseline or
  from the currently tracked `REQUIREMENTS_DIFF_*` set. Group IDs in a single row only
  when they were realized by the same coordinated change and share the same
  status. Do not group merely for compactness.
- **Requirement summary** — one short line. Not the full requirement text.
  The canonical document is the source of truth for the wording; this column
  is just a reading aid.
- **IMPL packet(s)** — every IMPL packet that contributed to the current
  state of this row, in chronological order. Multiple packets are normal for
  long-lived requirements. Use `—` if the requirement has not yet been
  touched by any packet.
- **Behavior gate** — `clear`, `blocked`, or `not_applicable`. Use
  `not_applicable` only when no linked packet has attempted behavioral
  implementation yet, or when the row records a purely documentary state that
  cannot affect runtime, prompt output, state transition, persistence, or
  user-facing flow. A row must not become `Implemented` if a linked packet has
  behavior gate `blocked`.
- **Primary evidence** — the file paths or artifacts that materialize the
  requirement in the current repo. For `Implemented` and `Partial` rows this
  field is required. For `Gap` rows it is `—`.
- **Status** — one of the three values from the legend.
- **Notes** — concise factual annotations. Acceptable content: test
  references (e.g. `T4 PASS in TestCampaign-IMPL-25`), known constraints,
  scoped follow-ups, whether a `Partial` row is still awaiting first
  authoritative campaign, and which superseding diff governs a changed area.
  Unacceptable content: future intent, opinions, planning, speculation.

---

## 3. Non-Functional Traceability

| ID(s) | Requirement summary | IMPL packet(s) | Primary evidence | Status | Notes |
|---|---|---|---|---|---|
| `NFR-XXX-01` | [one-line summary] | `IMPL-NN` | `path/to/file.ext` | Implemented | |
| `NFR-GOV-01` | [governance non-functional, often without IMPL] | — | [installed non-functional baseline document] | Implemented | Realized by the contract itself, not by code |

Non-functional rows often have no IMPL packet because they describe
properties of the system as a whole (governance, observability posture,
maintainability constraints). When this is the case, the IMPL column is `—`
and the Primary evidence column points at the document or configuration that
embodies the property.

---

## 4. Highest-Priority Gaps

This section is a narrative-ordered list of the most urgent gaps and
partials, with enough context to act on them. It is **not** a duplicate of
the rows above with `Gap` or `Partial` status — it is a curated reading
order for someone returning to the project after a context loss.

Suggested format: numbered list, each item starts with a short label in
bold, then one to three sentences of context, ending with the requirement
ID(s) in parentheses.

Example:

1. **[Short label of the gap]** — [one to three sentences explaining what
   the current state is, why it matters, and what would close it]
   (`FR-XXX-NN`).

2. **[Next gap label]** — [explanation] (`FR-YYY-NN`, `NFR-ZZZ-NN`).

If the project has no gaps or partials worth surfacing, write `none`.
Do not pad this section.

---

## 5. Latest Campaign Evidence Summary

**Optional section.** Use it when the most recent `TestCampaign-*`
introduced multiple test cases worth recording inline for quick reference.
Otherwise omit it — the campaign document itself is the primary evidence.

When used, the format is:

**TestCampaign-[ID] — [short description] ([date])**

| Test | Result | Notes |
|---|---|---|
| T0 — [test name] | PASS / FAIL / PARTIAL | [one-line factual note] |
| T1 — [test name] | PASS | |

If the campaign produced sub-packets or follow-ups, also include:

| Packet | Topic | Outcome |
|---|---|---|
| `IMPL-NN.M` | [topic] | [resolution summary] |

This section should be replaced or pruned when a new campaign supersedes
the previous one. Do not let it accumulate historical campaigns — that is
what the installed campaign documents are for.

---

## 6. Update Reminders

> **This section is a non-authoritative working reminder.**
> If it conflicts with `flow-of-work-contract/02-DOCSET-GOVERNANCE-CONTRACT.md`
> or `flow-of-work-contract/04-TEST-AND-HANDOFF-CONTRACT.md`, the contracts
> win. Its purpose is to let the active model recall the matrix update
> discipline at the moment it is about to act on this file, without
> re-reading all the contracts during an ongoing session.

### 6.1 When the matrix may be updated

- After a `TestCampaign-*` has been executed and accepted by the user.
- After code references together with a model code review establish a factual
  conservative state, typically for a `Partial` row awaiting first authoritative
  campaign.
- After an explicit user decision to record a status change.

### 6.2 When the matrix must NOT be updated

- Before evidence exists.
- During an IMPL packet execution, in anticipation of completion.
- Based on model self-check alone, without code references plus review,
  `TestCampaign-*` evidence, or explicit user acceptance.
- To express future intent, planning, or roadmap state.

### 6.3 What constitutes evidence

- A `TestCampaign-*` document with executed steps, recorded outputs, and
  a user-acceptance marker. This is the default and preferred form.
- Reachable code references together with a model code review may support a
  conservative `Partial` row before the first authoritative campaign. This is
  not the default path to `Implemented`.
- For non-functional governance rows, the existence of the canonical
  document or contract that embodies the property may itself be evidence.
  In this case the Primary evidence column points at that document.
- For implementation rows, code references must be reachable file paths
  in the current repo. A path that no longer resolves is a matrix
  failure, not a valid row.

### 6.4 Revision note convention

Every time the matrix is updated, increment the version, update the
`Last updated` date, and rewrite the `Revision note` to summarize what
changed and which evidence drove the change.

The revision note should answer two questions:
1. Which `TestCampaign-*`, code-review basis, or user decision drove this update?
2. Which rows were added, modified, or moved between statuses?

A revision note that says only "updated matrix" is not acceptable.

### 6.5 Drift between matrix and reality

If a row's Primary evidence path no longer resolves, or if a `Partial`
note describes a constraint that has since been removed, the matrix is
in drift. Drift must be corrected at the next session that touches the
affected area, by an explicit update with a new revision note. Drift is
not silently fixed.

---

## 7. Relationship to Other Documents

| Document | Role with respect to the matrix |
|---|---|
| Installed baseline requirement set | Source of truth for the stable bone structure IDs and wording. Matrix references, never duplicates. |
| Installed `REQUIREMENTS_DIFF_*` set | Introduces and supersedes requirement IDs. New IDs may appear as `Gap` by default, or `Partial` if code already partly realizes the corrected behavior. |
| Installed interaction document | Defines the scenarios that `TestCampaign-*` exercises, subject to scoped supersession by the governing active diff. The matrix does not duplicate scenarios. |
| Installed `IMPL-*` packet set | Cited in the IMPL packet(s) column. Packet lifecycle state is separate (see `IMPL-INDEX.md`). |
| Installed `TestCampaign-*` set | The primary form of evidence. Section 5 of this matrix may inline a recent campaign summary. |
| `authorities/PROJECT-OVERLAY.md` | Declares the actual location of this file if the project adapted the default structure. |

---

## 8. Project Adaptation

If the project has adapted the default structure (see
`flow-of-work-contract/05-PROJECT-STRUCTURE.md` section 6), record the
actual location of this matrix in `authorities/PROJECT-OVERLAY.md`
section 10.

If the project uses requirement IDs in a different scheme than the
`FR-XXX-NN` / `NFR-XXX-NN` shown in the examples above, document the
scheme in `authorities/PROJECT-OVERLAY.md` and apply it consistently in
this matrix. The matrix structure does not depend on any specific ID
format — it depends only on the existence of stable, unique IDs.
