# TestCampaign-[ID]-[SLUG]

**Version:** 0.1
**Status:** Draft
**Date:** YYYY-MM-DD
**Governing IMPL:** [IMPL-*]
**Governing diff:** [REQUIREMENTS_DIFF_* / none]
**Covered requirements:** [requirement IDs]
**Executor:** [manual user / autonomous same-environment LLM / mixed]

> This is an evidence artifact.
> It is not an implementation plan and not a requirements document.

---

## 1. Purpose

State what behavior this campaign validates.

The campaign must be derived from use cases, sequences, requirement IDs, and
packet-specific regressions. It must not be derived only from changed files.

---

## 2. Readiness And Constructibility

**Readiness for validation handoff:** [ready / not ready / blocked]

**Campaign constructibility:** [constructible / not constructible / partial]

Reason:

- [why a campaign result will be interpretable]
- [what this campaign can prove]
- [what this campaign cannot prove]

If constructibility is not clear, do not use this campaign as authoritative
acceptance evidence.

---

## 3. Scope

### In Scope

- [validated behavior]
- [use case or sequence]
- [regression seam]

### Out Of Scope

- [behavior not validated here]

---

## 4. Environment

| Item | Value |
|---|---|
| Project root | [path] |
| Runtime surface | [API / UI / CLI / local harness / other] |
| Test command or action | [command or manual action] |
| Backend / service dependencies | [dependencies or none] |
| Initial state | [clean state / existing state / fixture] |
| Reset or setup procedure | [procedure or none] |

Record whether the campaign uses live surfaces, stubs, probes, or deterministic
local harnesses. Stub/probe-heavy results are support evidence unless the
contract declares that surface authoritative.

---

## 5. Covered Contract

| Source | Covered item |
|---|---|
| Requirement | [ID and short summary] |
| Use case / sequence | [name] |
| IMPL packet | [packet objective or regression] |
| Prior bug / campaign | [reference or none] |

---

## 6. Test Matrix

| Test | Purpose | Steps | Expected result | Actual result | Status |
|---|---|---|---|---|---|
| T0 | Environment preflight | [steps] | [expected] | [observed] | [PASS / FAIL / PARTIAL / NOT RUN] |
| T1 | Main behavior | [steps] | [expected] | [observed] | [PASS / FAIL / PARTIAL / NOT RUN] |
| T2 | Regression / edge case | [steps] | [expected] | [observed] | [PASS / FAIL / PARTIAL / NOT RUN] |

Separate executed tests from non-executed tests. Do not mark a test `PASS`
unless it was actually exercised.

---

## 7. Evidence Log

Record concrete evidence.

| Evidence | Location / output | Notes |
|---|---|---|
| [log, command output, screenshot, user observation] | [path or quoted short result] | [why it matters] |

Avoid long pasted logs. Summarize and point to the artifact when possible.

---

## 8. Failure Triage

If any test fails or is partial, classify the failure.

| Failed / partial item | Classification | Consequence |
|---|---|---|
| [test] | [implementation bug / dependent follow-up / independent issue / scope issue / doc drift] | [same IMPL / IMPL-X.1 / new IMPL / successor diff / docs update] |

If the implementation matches the governing diff but the intended behavior is
wrong, classify as a scope issue and open a superseding diff.

---

## 9. Result

**Campaign result:** [PASS / FAIL / PARTIAL / DEFERRED]

Summary:

- [what was validated]
- [what remains unvalidated]
- [whether acceptance is recommended]

---

## 10. Traceability Recommendation

Recommend factual matrix movement only from campaign evidence.

| Requirement ID | Recommended status | Evidence |
|---|---|---|
| [ID] | [Implemented / Partial / Gap] | [test IDs or evidence references] |

Do not introduce matrix states outside `Implemented`, `Partial`, and `Gap`.

---

## 11. Acceptance Record

**Acceptance authority:** [user / delegated model / not accepted]

**Decision:** [accepted / rejected / accepted with constraints / deferred]

**Decision note:**

[short factual note]
