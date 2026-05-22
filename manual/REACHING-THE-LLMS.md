# Reaching the LLMs

*User operating manual for this flow of work.*

---

## Before You Read

This manual is not for someone who wants to ship software by chatting
casually with an LLM and hoping the conversation stays coherent.

It is for someone willing to do real engineering work with an LLM over
time:

- multiple sessions
- changing scope
- non-trivial validation
- real project history
- explicit decisions

If that is not your goal, this repository will feel heavier than it is
worth.

If that is your goal, the point of this manual is simple: to teach you
how to use the framework without treating the model's memory, confidence,
or fluency as a substitute for engineering control.

---

## What This Framework Actually Solves

Most serious LLM projects do not fail because the model is incapable.
They fail because the collaboration has no control system.

Typical failure modes:

- decisions live only in chat history
- scope changes during implementation without being named
- requirements drift because nobody recorded what changed
- code packets close, but no one can say what has actually been accepted
- the traceability matrix becomes optimistic instead of factual
- later sessions cannot tell what is history and what is still governing

This framework solves those problems by separating five core authorities that
are usually mixed together:

- stable product structure
- current contract change
- bounded execution
- validation evidence
- factual status

The names used here are:

- baseline
- `REQUIREMENTS_DIFF_*`
- `IMPL-*`
- `TestCampaign-*`
- `TRACEABILITY_MATRIX.md`

That separation is the core of the method.

The framework also keeps a few navigation and support documents beside those
authorities:

- `REQUIREMENTS_DIFF_INDEX.md` names the active diff head
- `IMPL-INDEX.md` names execution state and packet families
- `REVIEW-INDEX.md` and `REVIEW-*` preserve active clarification or review holds
- `TEST-CAMPAIGN-INDEX.md` helps find current, accepted, partial, and deferred
  campaigns
- `TEST-ENVIRONMENT-STARTUP.md` records repeatable setup for live or integration
  campaigns

Those documents do not replace the five core authorities. They make the
authorities findable and keep unresolved holds from living only in chat.

---

## The Mental Model

If you remember only one page of this manual, remember this section.

### Baseline is the bone structure

The baseline is the stable shape of the product:

- core functional requirements
- core non-functional requirements
- use cases
- sequence meaning

It is not supposed to absorb every accepted change forever.

### A diff is contract evolution

A `REQUIREMENTS_DIFF_*` is where product scope changes are introduced,
clarified, corrected, and later preserved as history.

It does two things:

- governs the current initiative
- remains a durable historical contract record after acceptance

The baseline stays stable. The diff tells you what changed.

### An IMPL is bounded execution

An `IMPL-*` packet is not product law. It is the bounded unit of work
that implements a coherent slice of change.

It answers:

- what is being executed now
- what is in scope
- what is out of scope
- what must be checked before handoff

### A campaign is behavioral authority

A `TestCampaign-*` is not an implementation plan.
It is the evidence artifact that says what actually happened when the
behavior was exercised.

This is the point where the system stops talking about intention and
starts talking about observed behavior.

### The matrix is factual, not aspirational

The traceability matrix is not a roadmap and not a lifecycle board.
It is the factual state register.

It answers:

- what is implemented
- what is partially realized
- what is still missing
- what evidence supports those claims

It must not answer:

- what you hope to do later
- what packet is in progress
- what the team plans to revisit

Those belong elsewhere.

---

## The User's Role

The model is not the routing authority.
You are.

That does not mean you must know more than the model technically.
It means you decide:

- whether something is a scope change
- whether behavior is defined or missing
- whether a campaign result is acceptable
- whether a recommendation is in scope or premature
- whether a new diff should be opened

If you let the model route because it sounds confident, the project will
slowly stop being yours.

Your job is not to out-reason the model on every technical detail.
Your job is to keep authority over:

- scope
- acceptance
- history
- tradeoffs

That includes a judgment the model cannot make for you: whether a campaign
produced authoritative evidence on live surfaces or only something that looked
well-formed. The model can propose that a campaign is sufficient. It must not
decide on its own that a formally tidy campaign has the epistemic weight needed
for acceptance.

---

## The Core Operating Rules

The whole framework reduces to a small number of operating rules.

### 1. Nothing important lives only in chat

If a decision matters, it must land in the right document.

Not:

- "we agreed on it last week"
- "the model remembers"
- "it was obvious from the conversation"

A decision that is not written is not stable.

### 2. Scope changes before code

When product behavior changes, open or amend a `REQUIREMENTS_DIFF_*`
before implementation.

Do not let code become the first place where scope takes shape.

### 3. Undefined behavior is a blocker

If the model needs to decide behavior and no document authorizes that
decision, stop.

The correct responses are:

- define it
- defer it
- narrow scope

The wrong response is: let the model invent something plausible.

### 4. Execution closure is not acceptance

A closed `IMPL-*` means bounded execution is complete.
It does **not** mean the requirement is accepted.

That distinction becomes critical on longer projects.

### 5. Evidence governs factual status

The matrix moves from evidence.

Not from:

- confidence
- code review alone
- "it looks done"
- a closed packet by itself

### 6. History must stay readable

Older diffs are not scratchpads.
Once a newer diff exists on the same change line, the older one becomes
history.

This is how the framework prevents silent rewriting of project history.

---

## The Main Documents And Their Jobs

You do not need to memorize every file in the repository.
You do need to know what each layer is for.

### Baseline documents

These define the stable product skeleton:

- accepted requirements
- accepted non-functional requirements
- stable use-case layer
- stable sequence meaning

Use them to understand what the project is.

### `REQUIREMENTS_DIFF_*`

Use these when:

- adding features
- changing workflows
- correcting scope
- refining a previously accepted change

Use them to understand what changed and why.

### `IMPL-*`

Use these to understand:

- the current bounded execution slice
- what files are touched
- what the packet is expected to prove before handoff

### `REVIEW-INDEX.md` and `REVIEW-*`

Use these when a question, risk, acceptance hold, or packet-boundary concern
must survive beyond the current conversation.

They tell you:

- what is still unresolved
- whether it blocks all work or only a specific slice
- which IMPL, campaign, or acceptance path is affected

A review is not an implementation packet and not evidence. It is a hold or
clarification record.

### `TestCampaign-*`

Use these to understand:

- what behavior was exercised
- by whom
- under what conditions
- with what outcome

### `TEST-CAMPAIGN-INDEX.md`

Use this to navigate campaign state.

It tells you:

- which campaigns belong to the active diff or IMPL family
- which campaigns are accepted, partial, deferred, or historical
- which active reviews constrain campaign interpretation

The index is not evidence. Open the campaign document for the actual evidence.

### `TEST-ENVIRONMENT-STARTUP.md`

Use this when live or integration campaigns need repeatable startup, preflight,
reset, inspection, or shutdown.

It is a reusable helper, not a campaign result.

### `TRACEABILITY_MATRIX.md`

Use this when returning to the project after context loss.

It tells you:

- what is accepted
- what is conservatively partial
- what is missing

### `IMPL-INDEX.md`

Use this to navigate execution history.
It is the lifecycle ledger, not the matrix.

---

## How To Start A Real Project

### Greenfield

Use `STARTER.md`.

The starter installs the control plane, asks the structural questions,
and finalizes the installed `AGENT.md`.

Do not improvise the framework installation by copying random files.

### Existing project with documents

Use `STARTER.md` in migration mode.

If the existing docs are already meaningful, this is usually better than
pretending the code has no documentation and forcing a full code-first
derivation.

### Existing project with little or unreliable documentation

Use `STARTER.md` with `code_first`, then let `CODE-BOOTSTRAP.md` derive
the initial documentation structure.

The code bootstrap is not magic.
It is a controlled conversion step from under-documented code into the
contractual structure of this framework.

---

## The Working Loop

This is the normal rhythm once a project is adopted.

### Step 1. Read the control plane

At the start of a session, the model should enter through `AGENT.md`,
then read:

- the overlay
- the contracts
- the matrix
- the active diff index and current relevant diff
- the IMPL index and active IMPL history
- review and campaign indexes when they reference the active scope

This is how sessions become resumable instead of conversationally
fragile.

### Step 2. Classify the request

Ask one question first:

Is this changing what the product should do, or only fixing / completing
what it already should do?

If it changes the product contract:

- open or amend a diff

If it stays within accepted contract:

- go to IMPL directly

### Step 3. Bound execution

Open an `IMPL-*` packet for the slice that can be executed coherently.

Do not bundle unrelated work just to reduce document count.

### Step 4. Execute and self-check

Let the model:

- implement
- run local checks
- review its own changes

But do not confuse this with acceptance.

If the self-check exposes a question that cannot be resolved inside the current
packet, put it in a `REVIEW-*` record instead of leaving it as chat memory.

### Step 5. Decide whether a meaningful campaign is possible

This is where the real world gets less tidy.

The key question is not:

- "is the packet finished?"

The key question is:

- "is enough behavior in place that a campaign result would be interpretable?"

Sometimes yes.
Often on real projects, not yet.

### Step 6. Update factual status conservatively

If the packet is closed but no meaningful campaign exists yet, the
matrix may still move conservatively:

- `Partial` can mean "implemented and self-checked, awaiting first
  authoritative campaign"

That is not final acceptance.
It is a factual conservative state.

### Step 7. Run campaign when behavior is mature enough

When enough behavior has accumulated, open a `TestCampaign-*`.

The campaign validates behavior against:

- use cases
- sequence meaning
- packet-specific regressions

not just against changed files.

If the campaign uses a real runtime surface, reference the environment startup
helper when one exists. If the result is `PARTIAL`, `FAIL`, or accepted with
constraints, record a blocker ledger and update the campaign index.

### Step 8. Let evidence settle the status

After campaign:

- `Implemented` if behavior is authoritatively validated
- `Partial` if still constrained, incomplete, or only partly covered
- new `Gap` or `Partial` rows if the campaign revealed a scope issue and
  a new diff is opened
- campaign index updated to reflect result and acceptance state
- review index updated if the campaign opens or resolves a hold

---

## The Important Distinction: Handoff Readiness vs Campaign Constructibility

These are not the same thing.

### Handoff readiness

This means:

- the current packet has no known blockers
- the model has completed what it can responsibly self-check

### Campaign constructibility

This means:

- enough behavior exists to exercise a coherent scenario
- a failure would be interpretable
- the campaign would validate something meaningful, not merely prove the
  system is unfinished

A packet can be handoff-ready while the broader behavior family is still
not campaign-constructible.

That state is normal on larger projects.

---

## How To Read `Partial`

This is the most important matrix concept to understand correctly.

`Partial` does **not** mean one single thing.
In this framework it can mean either:

1. implemented, self-checked, awaiting first authoritative campaign
2. already validated, but still drifting, incomplete, or constrained

Why keep the same word for both?

Because the matrix is intentionally coarse.
It is not a lifecycle tracker.

The important thing is that the note column makes the reason explicit.

Good `Partial` notes:

- implemented in code; awaiting first authoritative campaign
- validated for main flow; export path still missing
- pass on happy path; locale fallback still constrained

Bad `Partial` notes:

- maybe okay
- likely works
- pending
- planned

Those are lifecycle or opinion, not factual status.

There is a separate but related campaign result called `PARTIAL`.

A `PARTIAL` campaign can be accepted only when the campaign separates:

- what passed
- what failed or was not run
- which blockers remain
- where each blocker is routed next

That routing belongs in the campaign blocker ledger and campaign index. The
matrix only records the factual requirement status that the accepted evidence
supports.

---

## How To Handle Scope Issues Found By Campaign

This case matters because it happens often.

A campaign can reveal two very different kinds of failure.

### Case A: implementation bug

The diff was correct.
The code did not do what the diff required.

Then:

- open fix IMPL work
- validate again
- update matrix from the corrected evidence

### Case B: scope issue

The code did what the diff said.
The diff itself was wrong, incomplete, or no longer wanted.

Then:

- keep the campaign as evidence
- open a superseding `REQUIREMENTS_DIFF_*`
- keep existing matrix rows factual if they still describe the repo
- introduce new or corrected requirement IDs as `Gap` by default, or
  `Partial` if some corrected behavior already exists
- use a `REVIEW-*` hold when the right next step is a decision or boundary
  clarification rather than immediate implementation

Do **not** invent new matrix states like:

- pending
- deferred
- superseded-in-progress

That lifecycle nuance belongs in the diff and IMPL layers.

If the campaign shows that the IMPL packet itself had the wrong boundary, do
not patch around it casually. Preserve valid decisions, mark the old packet as
absorbed or superseded in the IMPL index, and create the corrected packet or
implementation family.

---

## How To Treat Diffs Over Time

This is one of the rules that keeps the framework audit-friendly.

### Only the head diff is editable

If `REQUIREMENTS_DIFF_INDEX.md` names a diff as the active head for the current
initiative, you can still amend that diff.

### Opening a successor freezes the predecessor

The moment a newer diff exists for the same change line, the older diff
becomes history.

You do not go back and rewrite it.

Why?

Because after a successor exists, rewriting the older diff rewrites the
history of what the project believed at that time.

### Reverting is additive, not historical rollback

If you want to return to an older behavior, open a new successor diff and
register it as the active head in `REQUIREMENTS_DIFF_INDEX.md`.

Do not reactivate an older diff directly.

---

## The Most Common Mistakes

### Treating a packet as acceptance

This is the most common mistake on long projects.

Fix:

- packet closure means execution closure
- campaign evidence means behavioral authority

### Letting the baseline become a changelog

If you force every accepted change into the baseline, the baseline
becomes hard to read and the diff history becomes less useful.

Fix:

- keep baseline stable
- let diffs preserve contract evolution
- refresh canonically only when curation helps readability

### Turning the matrix into a project board

As soon as you add lifecycle semantics to the matrix, you degrade the
clarity of factual status.

Fix:

- keep lifecycle in diffs and IMPL index
- keep factual status in the matrix

### Opening campaigns too early

If a campaign is not yet interpretable, it generates noise instead of
evidence.

A campaign can also be cleanly written and still fail to prove the behavior you
actually care about if it only touches stubs, probes, or other non-authoritative
surfaces.

Fix:

- ask whether the behavior slice is meaningful enough to validate yet
- check whether the campaign exercises live surfaces, real state, and the
  actual integration path
- treat stub/probe-heavy campaigns as support evidence unless the contract says
  those surfaces are authoritative

### Letting the model invent undefined behavior

This remains the single best way to accumulate silent drift.

Fix:

- undefined behavior blocks
- it does not auto-complete

---

## What Changes With Different Model Types

The framework is model-neutral, but the way you operate it changes with
tooling.

### Execution-capable model

Examples:

- Codex CLI
- Claude Code-like tools

Use these when possible.
They can:

- read the repo
- edit files
- run tests
- maintain the documents with lower friction

Use this class of model for broad root IMPL families, schema migrations,
cross-module refactors, prompt/state-machine changes, graph/runtime work, and
final severe reviews before live campaigns.

If a packet chain was produced by another model, have an execution-capable
frontier model review the chain against the active diff, code surfaces, matrix,
review holds, and campaign path before implementation starts.

### Analysis-only model

Examples:

- chat-only sessions without repo access

These can still operate the method, but more slowly.
You will need to:

- paste evidence manually
- move files yourself
- treat implementation claims as drafts until applied

### Small local models

Do not let them own governance, architecture, or traceability.
Use them only for narrow bounded work.

Good tasks for this class:

- summarize a single document
- fill a template section from already-approved input
- classify a small list
- perform a local mechanical edit under a frontier-model plan

Bad tasks for this class:

- deciding packet boundaries
- interpreting live campaign authority
- changing product scope
- owning schema, routing, prompt, graph, or config architecture

---

## Minimal Glossary

### Baseline

The stable bone structure of the project.
Not a full changelog of every accepted evolution.

### `REQUIREMENTS_DIFF_*`

The contract-change layer.
Active while governing new scope.
Historical after acceptance.

### `IMPL-*`

The bounded execution packet.
Not the product contract.

### `TestCampaign-*`

The evidence artifact.
Not the implementation plan.

### `TRACEABILITY_MATRIX.md`

The factual requirement-state register.
Not the project board.

### `REVIEW-INDEX.md`

The navigation register for active review holds and clarification records.
Read it before touching a scope it says is held.

### `REVIEW-*`

A durable review or clarification record.
Not an IMPL packet and not evidence.

### `TEST-CAMPAIGN-INDEX.md`

The campaign navigation register.
It helps find campaign state, but the individual campaign document remains the
evidence artifact.

### `TEST-ENVIRONMENT-STARTUP.md`

Reusable live or integration campaign setup.
Not a campaign result.

### Blocker ledger

The table inside a partial or failed campaign that names each blocker, its
classification, resolution, and destination.

### `Implemented`

Authoritatively validated by evidence.

### `Partial`

Either:

- implemented and awaiting first authoritative campaign
- or validated but still constrained / incomplete

### `Gap`

Required by the currently tracked requirement set but not implemented.

### Head diff

The editable diff named by `REQUIREMENTS_DIFF_INDEX.md` as the active head for
the current initiative.

### Successor diff

A newer diff that freezes the predecessor into history.

### Canonical refresh

Optional curation of baseline and/or interaction documents to improve
readability after accepted changes.
Not an automatic merge step.

---

## Final Advice

If you use this framework seriously, two things will happen.

First, the project will feel slower at the beginning.
That is normal.
You are paying for explicitness.

Second, the project will get easier to resume, review, and correct as it
grows.
That is the payoff.

The framework does not make the model smarter.
It makes the collaboration less fragile.

That is the whole point.
