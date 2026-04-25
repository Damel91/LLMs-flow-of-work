# IMPL-[ID]-[SLUG]

**Version:** 0.1
**Status:** Template reference
**Created:** YYYY-MM-DD
**Governing diff:** [REQUIREMENTS_DIFF_* / none]
**Governing baseline:** [baseline requirement references]
**Related requirements:** [requirement IDs]

> This is a bounded execution packet.
> It is not product law and not acceptance evidence.
> When installed in a destination project, this file is a category reference
> for creating new `IMPL-*` packets. Copy it, rename the copy, replace all
> placeholders, and leave this template unchanged.

---

## 1. Goal

State the implementation objective in one or two paragraphs.

The goal must describe one coherent initiative. If unrelated objectives appear
here, split the work into separate IMPL packets.

---

## 2. Scope

### In Scope

- [file, module, behavior, doc, or runtime path]

### Out Of Scope

- [nearby behavior intentionally not touched]

### Protected Areas

- [protected subsystem or `none`]

If a protected area must be touched, stop and get explicit user approval before
execution.

---

## 3. Governing Documents Read

Record the documents that define this packet.

| Document | Reason |
|---|---|
| [path] | [why it governs this packet] |

Minimum expected set:

- `authorities/PROJECT-OVERLAY.md`
- relevant contract files
- relevant baseline documents
- governing `REQUIREMENTS_DIFF_*`, if product scope is changing
- current `TRACEABILITY_MATRIX.md`

---

## 4. Behavioral Definition Gate

State whether behavior is sufficiently defined.

**Gate status:** [clear / blocked]
**Authority type:** [requirements_diff / use_case / sequence / user_instruction / working_code_reference / not_applicable]
**Authority reference:** [document path + section, explicit user instruction, or declared reference code path]
**Runtime/user-visible behavior affected:** [yes / no]
**Fallback/error behavior affected:** [yes / no / out_of_scope]

The gate is clear only if the packet can answer all required behavioral
questions from an authoritative source:

- behavior owner
- runtime or user-visible outcome
- relevant inputs, events, or triggers
- output, schema, state transition, or side effect
- fallback, error, or clarification behavior, unless explicitly out of scope

If blocked, record the missing behavior and stop implementation.

| Missing behavior | Why docs are insufficient | Required decision |
|---|---|---|
| [behavior] | [gap] | [narrow user question or reference needed] |

---

## 5. Implementation Plan

Plan only the work inside this packet boundary.

| Step | Action | Expected files |
|---|---|---|
| 1 | [action] | [paths] |
| 2 | [action] | [paths] |

---

## 6. Expected File Changes

| Path | Change type | Reason |
|---|---|---|
| [path] | [create / modify / delete] | [why this file changes] |

---

## 7. Self-Check Boundary

List what the active model can verify before handoff.

- [static check]
- [unit or local test]
- [model-side review target]
- [manual inspection target]

Also state what cannot be validated by the model and must go to campaign or
user acceptance.

---

## 8. Test And Handoff Plan

**Readiness target:** [ready for validation handoff / not ready yet / blocked]

**Campaign constructibility expectation:** [constructible / not yet constructible / unknown]

Expected campaign:

- `TestCampaign-[ID]-[SLUG].md` or `TBD`

Required evidence before matrix update:

- [test campaign]
- [code references plus model review for conservative Partial]
- [explicit user acceptance]

---

## 9. Traceability Impact

Expected matrix movement after evidence exists.

| Requirement ID | Expected status | Evidence needed |
|---|---|---|
| [ID] | [Implemented / Partial / Gap] | [campaign or review basis] |

Do not update `TRACEABILITY_MATRIX.md` during execution unless the project has
explicit evidence sufficient for the target status.

---

## 10. Execution Notes

Record concise implementation notes as work proceeds.

- [note]

Do not turn this section into a chat transcript.

---

## 11. Model Review

Before handoff, review changed code/docs against:

- governing diff or accepted baseline
- this packet scope
- behavior-definition gate
- test/handoff contract

Findings:

| Severity | Finding | File / evidence | Resolution |
|---|---|---|---|
| [High / Medium / Low] | [finding] | [path or doc] | [fixed / deferred / accepted risk] |

If no findings remain, state that explicitly and list residual risks.

---

## 12. Closure

**Execution status:** [not started / in progress / implemented / blocked / cancelled]

**Handoff status:** [not ready / ready for validation handoff / deferred because campaign not constructible]

**Residual risks:**

- [risk or none]

**Next step:**

- [continue implementation / open follow-up IMPL / open campaign / update matrix from evidence / stop]
