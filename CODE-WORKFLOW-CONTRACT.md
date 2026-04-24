# Code Workflow Contract

**Version:** 0.2
**Status:** working_draft
**Last updated:** 2026-04-25

---

## 0. Purpose

This document defines good coding rules for an LLM or human working on a real
codebase.

Its scope is code-bounded:

- how code should be changed
- how refactors should be kept clean
- how fallback behavior should be treated
- how open technical questions should be handled
- how tests should be interpreted
- how commits should be used to preserve work state

It is not a product behavior document. It does not decide what the software
should do. It regulates how code is written once the work target is known.

---

## 1. Core Principle

Passing a test is not enough.

Code is acceptable only when it is also logically coherent, maintainable,
bounded to the actual problem, and written in a way that can survive future
extension.

The goal is not to reach the first passing state. The goal is to reach the
simplest correct state that leaves the codebase healthier, not more fragile.

Do not camouflage success. If the visible effect is correct but the code is
fragile, duplicated, over-specific, or hard to reason about, state that plainly
instead of presenting the result as good engineering.

---

## 2. Work Definition Before Code

Before writing or editing code, the worker must know:

- what change is being made
- why it is being made
- which behavior or technical problem it addresses
- which files or modules are expected to change
- which adjacent areas are intentionally out of scope
- what must be tested or inspected before the work is considered complete

Use the active implementation document, when one exists, to define what must be
done. Do not replace that definition with memory, intuition, or an apparently
obvious shortcut.

If the work definition is incomplete, stop and clarify it before coding.

---

## 3. Good Laziness vs Bad Laziness

Good laziness is valuable.

It means:

- choosing the simplest solution that solves the real problem
- avoiding unnecessary abstractions
- avoiding needless rewrites
- deleting complexity when it no longer serves the system
- preferring clear code over clever code

Bad laziness is not acceptable.

It means:

- coding before the open question is understood
- adding passive code to make a test pass quickly
- leaving dead branches because removing them requires thought
- adding fallback behavior because deciding the real behavior is harder
- hiding uncertainty behind generic handlers
- accepting a local patch that makes future maintenance worse

Open questions require attention and discussion, not passive code.

---

## 4. No Invented Fallbacks

Do not invent fallback functions, fallback branches, silent recovery paths, or
default behavior unless explicitly requested or already established by the
existing design.

Fallbacks are behavior. They are not harmless technical glue.

Before adding a fallback, identify:

- what failure it handles
- who depends on it
- whether the fallback result is safe or merely convenient
- whether it hides a bug that should be fixed instead
- whether the user or existing design actually asked for it

If the answer is unclear, do not add the fallback. Ask for the intended
behavior.

Error handling is not the same as fallback invention.

Good error handling:

- makes failure explicit
- preserves useful diagnostic information
- protects callers from undefined state
- follows the existing error model of the codebase

Bad fallback handling:

- silently returns a convenient default
- hides a defect that should be fixed
- turns missing behavior into implicit behavior
- makes the caller believe the operation succeeded when it did not

---

## 5. No Dead Code Or Dead Flow

Refactoring must remove obsolete code paths.

Use a delete-first mindset during refactors. When a new flow replaces an old
one, first identify what can be removed, then add only what is still needed.

Do not leave behind:

- unused functions
- unreachable branches
- obsolete parameters
- stale comments
- abandoned files
- old prompt paths
- disabled tests that no longer represent a real future target
- compatibility shims that nobody intends to support

Temporary compatibility code is allowed only when it has:

- a clear purpose
- a bounded lifetime
- a removal condition
- a visible note explaining why it exists

Dead code is not neutral. It misleads the next reader and gives future models
false surfaces to reason from.

---

## 6. Refactor Discipline

A refactor must preserve or deliberately improve behavior.

Before refactoring, state the refactor goal:

- remove duplication
- isolate responsibility
- simplify control flow
- improve naming
- separate concerns
- prepare a specific future change

During refactoring:

- keep the patch as small as the goal allows
- avoid mixing refactor and feature behavior unless explicitly planned
- remove old flows when the new flow replaces them
- update tests that describe the old structure
- avoid broad rewrites whose benefit is only aesthetic

After refactoring, inspect for dead paths and duplicated responsibility.

---

## 7. Generalization And Reuse

Code should be oriented toward reasonable generalization and reuse.

This does not mean abstract everything.

It means:

- avoid one-off special cases when a small general rule would be clearer
- keep reusable behavior in one place
- avoid duplicating logic across files
- name functions by the concept they implement, not only by the immediate bug
- avoid hardcoding the current example when the code obviously represents a
  broader case
- keep interfaces stable when possible

Small abstraction rule:

- abstract when there are at least two real uses, or when the underlying rule is
  already stable and clearly broader than the current example
- do not create an abstraction only because it might be useful later
- do not keep copy-pasted logic when reuse is already evident

Premature abstraction is bad. So is narrow code that forces the next worker to
patch the same idea again somewhere else.

---

## 8. Prompt, Parser, And Configuration Code

Prompt files, parser code, routing code, configuration, and test harnesses are
part of the codebase when they affect runtime behavior.

Treat them with the same discipline as source code:

- no unreviewed behavior changes
- no dead prompt paths
- no stale examples that teach the wrong output shape
- no parser leniency that accepts undefined behavior
- no configuration change without understanding its runtime effect

If a prompt produces output consumed by code, the prompt and parser must agree
on a realistic format. Do not solve that mismatch by adding vague heuristics
unless tolerance itself is the intended behavior.

---

## 9. Boundary Of A Patch

Every patch must have a clear boundary.

Before editing, identify:

- target files
- target functions or components
- expected side effects
- files that should not change

A patch is suspicious when it:

- rewrites more code than the problem requires
- changes naming and behavior together without need
- edits unrelated files
- introduces new architecture to solve a local issue
- makes broad formatting changes inside a behavioral patch
- changes tests to match broken code instead of fixing the code

When the needed change is larger than expected, stop and state why the boundary
must expand.

---

## 10. Tests Are Necessary But Not Sufficient

Tests prove only what they actually cover.

Do not infer code quality from a green test alone.

After tests pass, still inspect:

- whether the code expresses the intended logic cleanly
- whether the implementation is reusable enough for the problem class
- whether the patch introduced hidden coupling
- whether the test was weakened to pass
- whether the test is too coupled to current implementation details
- whether the test only covers the example and not the rule
- whether dead or contradictory code remains

If a test passes but the code is logically poor, the work is not done.

Test integrity matters. A good test protects behavior, a rule, or a regression
seam. It should not freeze incidental implementation details unless those
details are themselves the behavior being protected.

---

## 11. Regression Discipline

When the same defect area appears more than once, add or update a targeted
regression test.

Do this before relying on another broad or live test cycle.

The regression should protect the specific failure mode, not merely increase
test count.

Good regression coverage is:

- narrow enough to fail for the bug it protects
- stable enough to run repeatedly
- named or commented clearly enough to explain the protected behavior
- connected to the changed code path

If deterministic regression is not possible, document why and use the closest
repeatable check available.

---

## 12. Runtime State And Generated Files

Runtime state matters when it affects behavior.

Before committing or discarding generated files, caches, local databases,
workspace files, indexes, snapshots, or build artifacts, determine whether they
are:

- source of truth
- reproducible generated output
- temporary execution state
- test fixture
- accidental residue

Do not commit generated state by accident.
Do not delete state blindly if it is needed to reproduce behavior.

If a code change requires a cache, index, graph, or workspace refresh, treat
that refresh as part of the work.

After work that touches runtime state, verify cleanup explicitly:

- temporary workspace files are removed or intentionally retained
- caches or indexes are refreshed when needed
- local databases or snapshots are either source-of-truth, fixture, or ignored
- generated files are not left ambiguous

---

## 13. Commit Discipline

Use git as a safety mechanism during serious work.

Commit at least:

- after creating a requirements diff or equivalent scope-change document
- after every code change that significantly changes behavior
- after each completed implementation cycle
- after each completed test campaign or equivalent validation cycle
- after important cleanup that removes dead code or obsolete flow

Commit rules:

- commit coherent semantic units
- use conventional commit naming unless the project says otherwise
- do not mix unrelated work in the same commit
- inspect staged files before committing
- do not commit accidental generated state
- do not rewrite history without explicit approval

Local commits are not acceptance. They are checkpoints that protect the work.

---

## 14. Discussion Triggers

Stop coding and discuss when:

- a fallback seems necessary but was not requested
- the requested behavior is not technically or semantically defined
- a simple fix would leave dead code behind
- a test can be made to pass by weakening the code or the test
- the patch boundary expands beyond the original target
- there are two plausible designs with different future costs
- the code passes but does not look logically clean
- the worker is about to add passive code just to close the task
- the worker cannot explain why the solution is generally correct
- runtime state cleanup is uncertain

These are not interruptions. They are part of good coding.

---

## 15. Prohibited Behaviors

Do not:

- invent fallback behavior
- leave dead code or dead flow after refactoring
- patch around an open question instead of resolving it
- use tests as proof of logical code quality
- weaken tests to match bad code
- implement broad rewrites without a stated reason
- hide uncertainty in generic handlers
- duplicate logic instead of extracting a reusable rule when reuse is obvious
- over-abstract a single case without a stable rule
- present a fragile passing result as good code
- leave runtime state cleanup ambiguous
- commit unrelated changes together
- treat local commits as acceptance
- treat "it works now" as equivalent to "it is well designed"

---

## 16. Closure Rule

Coding work can be considered technically closed only when:

- the intended change is implemented
- no known dead code or obsolete flow remains from the change
- no invented fallback was introduced
- tests or checks appropriate to the change have been run, or the absence of
  such checks is explicitly stated
- the code has been reviewed for logic, reuse, and maintainability
- runtime state and generated files have been handled deliberately
- the worker can explain in two to five lines why the design is correct, not
  only which files changed
- the relevant commit checkpoint has been created when git is in use

If the code passes tests but fails the logic, reuse, or cleanup review, it is
not technically closed.
