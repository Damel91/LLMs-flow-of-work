---
doc_type: validation_execution_contract
scope: validation_execution
applies_to: multi-platform
version: 0.2
status: working
last_updated: 2026-05-23
---

# Validation Execution Contract

## 0. Quick Rules

1. Tests must be designed to find defects, not to confirm that the patch looks
   plausible.
2. A campaign must include adversarial, worst-case, edge, regression, and
   negative/error paths when those paths are relevant to the changed behavior.
3. Expected results must be written before execution and must not be weakened
   after observing failures.
4. Live campaigns must use the real acceptance surface unless the campaign
   explicitly targets a diagnostic surface.
5. Deterministic harnesses are valid evidence only when they exercise the real
   behavior or a deliberately bounded unit seam.
6. A failed or partial test is useful evidence. Do not hide it by changing the
   test boundary after execution.
7. If a campaign exposes blockers, open or continue fixing `IMPL-*` packets and
   add regression coverage before rerunning the relevant campaign slice.
8. Full documentation alignment follows accepted campaign evidence, not mere
   code completion.
9. Traceability matrix updates follow accepted campaign evidence, not packet
   implementation.
10. Validation must not be used to hide incomplete execution. If a packet is
    only scaffolded or partial, the campaign must say so and test the completed
    subset or route the remaining implementation first.
11. Scaffold validation is support evidence only. It cannot close the packet
    unless a later completion ledger converts the scaffold into `Implemented`,
    `Partial` with accepted residual routing, or another explicit terminal
    state.

## 1. Purpose

This contract governs how deterministic and live validation campaigns are
designed and executed.

It exists because LLM-assisted workflows can produce tests that are technically
green but epistemically weak: tests that exercise the easy path, avoid the real
surface, use mocks too broadly, or silently redefine success after seeing the
result.

The validation executor must therefore think like a skeptical reviewer. The
question is not "can this pass?" The question is "what would prove this still
breaks?"

The same skepticism applies before execution reaches validation. A campaign is
not a tool for making a partially completed chain look finished. If the packet
completion ledger shows scaffolded, partial, blocked, or deferred work, the
campaign must be scoped to that factual state or validation handoff must wait.

Do not create a scaffold-only campaign as a substitute for completion. It may
record that useful structure exists, but the packet remains active until the
remaining behavior is routed and resolved.

## 2. Campaign Design Standard

Every campaign must start from the governing requirements, use cases,
sequences, packet objectives, previous blockers, and known regression seams.

It must not be built only from changed files or from the easiest command that
can produce a green result.

Minimum design questions:

1. What is the main behavior that must work?
2. What is the worst credible input, state, repository shape, or user path for
   this behavior?
3. What previously failed and must not regress?
4. What setup or environment problem could create a false pass?
5. What negative/error behavior proves validation is strict?
6. What evidence would distinguish implementation bug, scope issue,
   environment issue, and documentation drift?
7. Does the governing packet claim full completion, partial completion, or only
   scaffolding, and is the campaign scoped to that factual state?

If these questions cannot be answered, the campaign is not constructible yet.

## 3. Pass-Bias Prohibition

The executor must not:

- choose only happy-path tests when riskier paths are available;
- replace the real acceptance surface with a probe unless the probe is the
  target surface;
- mark a test `PASS` when it did not execute;
- remove or weaken expected results after observing failures;
- ignore a failed setup step and continue as if the campaign were valid;
- use a mock or fixture that bypasses the behavior under test;
- count "server starts" as acceptance for a workflow requirement;
- treat absence of an exception as proof of semantic correctness;
- update traceability to `Implemented` because code was written but not
  accepted through evidence.
- accept a skeleton implementation by testing only the thin path that the
  skeleton already covers;
- convert model effort, elapsed time, or long-chain progress into evidence of
  completion.

If a test was poorly designed and cannot prove anything meaningful, record it
as weak or invalid evidence instead of converting it into success.

## 4. Required Test Shape

When applicable, a campaign should include:

| Test kind | Purpose |
|---|---|
| Preflight | Proves the environment can produce interpretable evidence |
| Main path | Proves the intended success behavior |
| Worst-case / adversarial path | Exercises the path most likely to reveal a false implementation |
| Regression path | Reproduces a previously observed blocker or bug |
| Negative / error path | Proves invalid input or unsafe state is rejected or diagnosed correctly |
| Persistence / state path | Proves state, indexes, cache, graph, database, or files are coherent after the operation |
| Scope / isolation path | Proves unrelated sessions, repositories, workspaces, or surfaces are not contaminated |

The exact rows depend on the changed behavior. Omitting a relevant test kind
requires a written reason in the campaign.

## 5. Deterministic Harness Rules

Deterministic tests may be unit tests, integration tests, CLI probes, scripted
API calls, or project-specific harnesses.

They should be preferred for:

- reproduced bugs;
- parser, graph, schema, storage, and deterministic routing behavior;
- regression protection after live failures;
- narrow safety boundaries where live validation would be noisy.

They must not be used to avoid the real behavior. A deterministic test that
passes because it mocks away the risky component is support evidence only.

## 6. Live Campaign Rules

Live campaigns should use the real surface that users, operators, or future
agents will rely on.

When live validation requires setup, reset, preflight, model availability,
server startup, or shutdown, use the installed `TEST-ENVIRONMENT-STARTUP.md`
helper unless the campaign explicitly explains why it does not apply.

Live evidence must record:

- runtime surface used;
- commands or user actions;
- inputs;
- relevant outputs or observations;
- logs or artifact paths when useful;
- deviations from the standard startup/reset path.

Do not use lower-level diagnostic surfaces as the primary live evidence unless
the requirement is specifically about that diagnostic surface.

## 7. Failure And Fix Loop

If a campaign is `FAIL` or `PARTIAL`:

1. keep the campaign as evidence;
2. classify each blocker;
3. route each blocker to the same packet, a dependent follow-up, a new IMPL,
   a successor diff, or documentation-only correction;
4. add or update deterministic regression coverage for repeated or reproduced
   defects;
5. rerun the relevant deterministic and/or live campaign slice after the fix.

Do not do full documentation alignment while acceptance blockers remain.

When the relevant rerun is green, all acceptance tests are `PASS`, and no
blockers remain, the campaign is accepted evidence by default unless its
acceptance record explicitly requires manual user acceptance. If the campaign
declares the user as the sole acceptance authority, user acceptance is still
required.

## 8. Documentation Alignment Consequence

Packet implementation completion and campaign acceptance have different
documentation consequences.

After each implemented packet:

- update the packet status and evidence notes;
- update `IMPL-INDEX.md`;
- update active review or hold records only if the packet resolves them;
- record deterministic self-checks or residual risk;
- do not perform full documentation alignment;
- do not update `TRACEABILITY_MATRIX.md` as accepted reality.

After an accepted campaign:

- update the campaign result and acceptance record;
- update `TEST-CAMPAIGN-INDEX.md`;
- update `TRACEABILITY_MATRIX.md` from accepted evidence;
- update `REQUIREMENTS_DIFF_INDEX.md`, review index, blocker ledger, or
  canonical docs only where the evidence changes their factual state;
- preserve unresolved blockers by routing them to fixing packets or a successor
  diff instead of erasing them.

This keeps implementation progress separate from accepted product reality.
