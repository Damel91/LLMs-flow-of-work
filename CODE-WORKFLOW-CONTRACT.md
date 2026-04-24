# Code Workflow Contract

**Version:** 0.1
**Status:** working_draft
**Last updated:** 2026-04-25

---

## 0. Purpose

This document governs how code development work is executed inside an adopted
project.

It exists because real LLM-assisted coding does not fail only at the product
requirements layer. It also fails at the execution layer:

- the model bypasses planning and writes from raw user intent
- prompts and parsers drift apart
- generated code is treated as accepted before validation
- live campaigns are used to discover predictable bugs
- small local fixes silently expand into workflow changes
- output contracts are patched heuristically instead of being defined
- workspace validation and final apply are confused

This contract defines the operational discipline for those code-development
failures.

It does not define product behavior. It does not replace requirements,
diffs, IMPL packets, or test campaigns.

---

## 1. Quick Rules

1. No non-trivial code change starts without an active `IMPL-*`.
2. Product behavior changes require a governing `REQUIREMENTS_DIFF_*` first.
3. Prompt changes are code changes when runtime behavior depends on them.
4. Prompt output format and parser behavior must be treated as one contract.
5. Do not bypass planning, refinement, task-unit, or artifact stages when the
   system defines them.
6. The executor must receive structured execution input, not raw user intent,
   when the architecture provides a planning layer.
7. Prefer contract correction over parser heuristics when a model-owned output
   format is wrong or ambiguous.
8. Use parser or runtime leniency only when the accepted contract explicitly
   allows that tolerance.
9. Validate in the safest available workspace or staging boundary before
   applying to the live repo.
10. Do not treat workspace validation as final acceptance.
11. Known blockers must be fixed before campaign handoff.
12. Repeated failures on the same seam require targeted regression coverage.

---

## 2. Authority Relationship

This document governs execution discipline for code and prompt changes.

Authority order during code work:

1. `AGENT.md` for session entry and routing
2. `authorities/PROJECT-OVERLAY.md` for project-specific constraints
3. `authorities/flow-of-work-contract/*` for generic workflow law
4. this document for code-development execution discipline
5. active `REQUIREMENTS_DIFF_*`, if product scope is changing
6. accepted baseline and interaction docs
7. active `IMPL-*`
8. `TestCampaign-*` evidence
9. `TRACEABILITY_MATRIX.md` factual status

If this document conflicts with a project-specific overlay rule, stop and ask
the user which rule should govern before coding.

---

## 3. What Counts As Code Work

For this contract, code work includes:

- source code changes
- prompt changes
- parser changes
- routing or graph-node changes
- model-output schema changes
- workspace, apply, or staging lifecycle changes
- test harness and regression changes
- configuration changes that affect runtime behavior

Prompt files are not "just text" when runtime behavior depends on them.
Changing a prompt that controls schema, routing, planning, coder output,
review, or clarification is a behavioral code change.

---

## 4. Pre-Implementation Gate

Before editing code, the active model must confirm:

- request classification is clear
- governing diff exists if product scope changes
- active `IMPL-*` exists for non-trivial work
- behavior-definition gate is clear
- protected subsystems are not touched without approval
- expected files and runtime surfaces are known
- self-check boundary is explicit
- validation handoff target is known or intentionally deferred

If any item is missing, stop and resolve it before implementation.

---

## 5. Planning And Executor Boundary

If the project architecture has a planning, refinement, artifact, or task-unit
stage, the executor must not be fed raw user intent directly.

The expected flow is:

1. classify request
2. resolve target
3. derive or select planning artifact / task unit
4. execute from that structured input
5. validate bounded output
6. review result
7. apply only through the accepted apply path, if one exists

Retries are local recovery only. They are not a substitute for planning or
context discovery.

If execution cannot obtain a valid task unit or equivalent artifact, the model
must stop rather than invent one silently.

---

## 6. Prompt And Parser Contract Rule

When a model output is parsed by code, the prompt and parser form a single
runtime contract.

Before changing either side, identify:

- producer prompt
- parser or consumer function
- exact expected format
- tolerated whitespace or fencing, if any
- retry or rejection behavior
- failure message
- test surface

If the model consistently produces a format that the parser rejects, first ask:

- is the prompt asking for an impractical or unstable format?
- is the parser stricter than the accepted contract?
- is the tolerated format already evident from real model output?

Correction rule:

- if the producer is model-owned and the prompt output format is the problem,
  correct the prompt contract when possible
- if the parser rejects an accepted or unavoidable model format, correct the
  parser contract
- do not add broad heuristics just to make one observed output pass
- do not rely on hidden whitespace tricks as the governing fix

Strictness is good only when the contract is realistic and testable.

---

## 7. Patch Boundary Rule

Generated code changes must stay inside the authorized target boundary.

Use the narrowest safe patch form:

- symbol-level replacement when the task is symbol-scoped
- file-level replacement only when the IMPL explicitly authorizes it
- multi-file change only when the packet scope requires it

Reject or reroute output that:

- rewrites a full file when only a region was authorized
- changes unrelated behavior
- introduces unrequested architecture
- repairs nearby code without an accepted lateral-issue path
- changes generated docs or authority files outside packet scope

Lateral issues may be recorded only if the project defines where they go and
when they may be promoted.

---

## 8. Workspace, Apply, And Live Repo Boundary

When the project has a workspace or pending-apply mechanism:

- generated output is validated in workspace first
- the live repo is not touched during workspace validation
- apply is a separate explicit step
- apply must refresh any runtime index, vector store, graph state, or cached
  representation that depends on changed files
- temporary workspace files must be cleaned up after successful apply

Do not claim final repo mutation when only workspace validation happened.
Do not claim workspace safety when the live repo was modified directly.

---

## 9. Testing And Regression Discipline

Use the test and handoff contract for acceptance, but apply these execution
rules during code work:

- run deterministic local checks when available and relevant
- do not open a live campaign while predictable blockers remain
- do not use live campaign execution as exploratory debugging
- when the same seam fails repeatedly, add or update a targeted regression
  before the next live campaign
- if no standard test tool exists, use the best deterministic harness available

For prompt/parser seams, regression coverage may be:

- parser unit tests
- prompt-output fixture tests
- graph-routing probes
- live model probes, when deterministic tests cannot cover the behavior alone

Live model probes support evidence. They do not replace deterministic
regressions when deterministic coverage is possible.

---

## 10. Review Before Handoff

Before declaring code work ready, review against:

- active diff or accepted baseline
- active `IMPL-*`
- behavior-definition gate
- this code workflow contract
- test and handoff contract
- changed prompts and parsers as a pair

The review must surface:

- out-of-scope changes
- untested parser or prompt assumptions
- missing regressions
- workspace/apply lifecycle risks
- traceability claims made too early

No findings is a valid result only if stated explicitly with residual risks.

---

## 11. Commit Discipline

If the project uses git and the user has requested local commits:

- commit coherent semantic units
- use conventional commit naming unless the project says otherwise
- do not mix unrelated dirty work into the same commit
- do not commit generated state unless the user or project explicitly wants it
- do not amend or rewrite history without explicit approval

Critical phases may require more frequent local commits than normal. This is a
state-management decision, not acceptance evidence.

---

## 12. Prohibited Behaviors

Do not:

- implement from raw user intent when a planning artifact is required
- treat prompt editing as lower-risk than code editing
- change parser behavior without identifying the prompt contract it consumes
- add broad heuristics when a precise contract correction is available
- claim an apply succeeded from workspace validation alone
- update traceability from code completion alone
- run a campaign to find bugs already known from review
- silently expand scope because a nearby issue is visible
- keep retrying the same failing seam without adding targeted regression
- bypass the user on protected subsystems or scenario changes

---

## 13. Closure Rule

Code work can be considered execution-closed only when:

- the active packet scope has been implemented or explicitly reduced
- model-side review is complete
- predictable blockers are resolved or explicitly routed
- required local checks have run or are explicitly not available
- workspace/apply state is clear
- any traceability movement is deferred until evidence unless conservative
  `Partial` is explicitly justified

Execution closure is not acceptance.

Acceptance still belongs to `TestCampaign-*` evidence, explicit user decision,
or the project-specific acceptance bar declared in the overlay.
