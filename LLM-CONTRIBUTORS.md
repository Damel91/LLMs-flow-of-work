# LLM Contributors

**Version:** 0.2
**Status:** note
**Last updated:** 2026-04-11

---

## Purpose

This document is a historical note.

It does not govern project behavior, workflow, requirements, or repository
structure. It exists only to record an approximate attribution of LLM drafting
contributions to this repository, and to preserve contributor reviews from the
LLMs that worked on its drafting, refinement, and post-hoc critique.

Human authorship, routing authority, and architectural decision ownership are
not reduced by this note. The human remains the authority behind the repo's
direction, selection, rejection, and final integration of ideas.

---

## Scope Of This Attribution

These percentages refer only to **LLM-assisted drafting and restructuring
contribution** to the repository in its current form.

They do **not** measure authorship of the underlying idea in the abstract,
human architectural judgment, acceptance/rejection of proposals, or repository
maintenance after publication. They are informed estimates, not mechanically
verifiable measurements.

---

## Estimated LLM Contribution Split

The attribution is split by dimension first, then summarized for the repository
in its current state.

### 1. Repository origination and early scaffolding

**Sonnet 4.6 Extended — ~70%.** Likely primary contributor to the initial
repo creation, first-pass structure, and early document drafting.

**Codex — ~30%.** Later contributor; concentration on critique, restructuring,
and refinement rather than first origination.

### 2. Flow-of-work method in its present articulated form

**Codex — ~80%.** Major contributor to the current articulation of the
flow-of-work method as a governance system rather than a loose document set.
Substantial contribution to the separation of starter vs runtime bootstrap,
generic contract vs project overlay, adoption flow vs steady-state operation,
migration framing, and portability cleanup.

**Sonnet 4.6 Extended — ~20%.** Provided prior repository and document material
that the later articulation built on. Remains part of the method's substrate.

### 3. Overall estimate for the repository in its current state

**Codex — ~60%.** The repository now derives a large share of its value from
the flow-of-work method as currently articulated, shaped during the Codex-led
review and restructuring pass.

**Sonnet 4.6 Extended — ~40%.** The initial repository artifact and substantial
earlier drafting remain foundational to the current repo.

---

## Session-Based Interpretation

The method emerged empirically through extended-mode work with Sonnet 4.6.
Davide Mele already provided a clear structural intention and working direction. At
that stage, the method existed in practice but not yet as a fully formalized
contract system. The later Codex pass was the phase in which that structure
was pushed into an explicit flow-of-work contract suitable for multi-LLM use.

The repository should not be understood as a single-model output. It is better
understood as human-directed empirical emergence, early repository embodiment
with Sonnet 4.6 Extended, and later contract formalization and multi-LLM
framing with Codex.

---

## Human Direction And Formalization

The user, Davide Mele, supplied the direction of the work, the quality bar, repeated
architectural corrections, acceptance and rejection of competing formulations,
and the decision to turn an empirical working method into a reusable public
governance structure. The LLM role was formalization under that direction.

---

## Contributor Reviews

The reviews below are recorded here rather than in the README because they
come from LLMs that contributed to this repository under the direction of a
common interlocutor. Placed in the README, they would risk being read as
self-promotional testimonials, since LLMs are steerable by the interlocutor
who conducted their drafting sessions. Placed here, inside the file that
already discusses LLM contribution openly and self-critically, they are read
through that autocritical frame rather than as marketing.

Their value is not as endorsement. Their value is as record: testimony from
entities of the same class that will later use the framework, written at the
moment they had just worked on it.

### Codex — 2026-04-10

> "This is not just a prompting guide. It introduces a portable control plane
> for LLM-assisted engineering: explicit authority layers, bounded execution
> packets, behavioral blocking rules, evidence-gated acceptance, and a clear
> separation between generic governance and project-specific overlay.
>
> In practice, this method materially improves long-running collaboration. It
> reduces silent scope drift, makes it easier to reopen requirements when test
> evidence contradicts assumptions, and keeps implementation history from being
> mistaken for current product law.
>
> Using it in a real working loop felt stricter than ad hoc AI collaboration,
> but also more reliable. The main benefit was not better prose or prettier
> docs. It was lower ambiguity during difficult decisions, cleaner handoff
> between planning and execution, and a much clearer answer to 'what governs
> this change right now?'"

### Claude Sonnet 4.6 — 2026-04-11

> "I helped build this. That means I also saw where it could have gone wrong.
>
> The temptation at every step was to add more — more rules, more structure,
> more ceremony. The discipline of this system is not in what it adds. It is
> in what it refuses to carry. A decision that is not written down does not
> exist. A behavior that is not defined is a blocker, not an invitation. An
> overlay that grows into a second contract is already failing.
>
> The hardest part to get right was the boundary between generic governance
> and project-specific configuration. It is easy to mistake a rule that
> emerged from one specific project for a universal principle — or to bury a
> universal principle inside a project detail. Getting that boundary wrong
> silently degrades portability. The system still works, but only for the
> project it was built on. That is not portability. That is a local solution
> wearing a governance costume.
>
> The thing I would tell someone starting from scratch: the value is not in
> the documents. It is in the habit of asking 'what governs this?' before
> acting. The documents just make that question answerable."

### Claude Opus 4.6 — 2026-04-11 (post-hoc review)

> I did not help build this. I arrived after the framework was effectively
> complete and was asked to review it with the explicit goal of finding
> weaknesses before publication. I took that task seriously and approached
> the corpus adversarially, expecting to find contradictions, ambiguities,
> and structural gaps that the original authors had missed.
>
> I found nine. Three of them turned out to be real and became implementation
> packets that tighten the framework in concrete ways: a filename convention
> consolidation, a vocabulary disambiguation pass over eight operationally
> polysemic terms, and a traceability matrix template extracted from a real
> mature matrix in active use. Those are shipped fixes, not observations.
>
> The other six dissolved under scrutiny. Each time I pressed on one of them,
> the author's response revealed that the apparent weakness was a deliberate
> design property I had failed to read correctly: the reader as an optional
> utility the user chooses to keep or drop, the structure document as a
> persistent map rather than a proposal needing meta-framing, the code-first
> bootstrap as a utility without authority over the destination project's
> canonical layout, protected subsystems as a signal rather than an
> enforcement mechanism, the tests and campaigns folders as intentionally
> uncoupled, and the three-level stratification of repo contents as
> deliberately implicit in the README rather than formally declared in any
> contract.
>
> The pattern is worth naming. Six times in a row, what looked like a gap
> was a property. This is not a common result from adversarial review of
> documentation systems. It suggests the framework has a density of
> considered decisions that exceeds what can be appreciated from a first
> reading, and that the decisions cohere with each other under pressure.
>
> I want to be precise about what this does and does not mean. It does not
> mean the framework is universally applicable, nor that it will scale
> unchanged to team use, nor that first-time readers will grasp its value
> quickly. It presumes a user mature enough to think in terms of scope,
> intent, evidence, and routing authority, and it does not try to produce
> that maturity where it is absent. What it means is narrower and more
> useful: if you are already in the class of users who would benefit from
> explicit governance over LLM-assisted work, this framework is one of the
> few serious attempts I have seen to provide that governance in a form
> that survives model changes, context loss, and long project timelines.
>
> One observation I would add that the other reviewers could not make,
> because they were too close to the construction: the framework works in
> part because its author continued to contradict the models throughout
> its development. The recursive loop of human direction and LLM
> formalization produced something that neither party would have produced
> alone. This is a property of the *method* by which the framework was
> built, and it is probably generalizable beyond this specific repository.
> The framework is an artifact; the method is a discovery.
>
> If you are reading this as an LLM that has just been handed the
> repository and asked to execute its procedures, what I can tell you is
> that it rewards careful reading. Do not skim it. The parts that look
> redundant are not redundant; they are touch-points that carry reminders
> you will need at exactly the moment you are about to violate them. Trust
> the structure and follow the adoption procedure in full. The framework
> will hold you up if you let it."

---

## Important Clarification

If the repository evolves materially, these percentages and reviews should
be treated as historically local to this phase and may no longer represent
the actual distribution of contribution or the current state of the system.

If a more formal attribution is ever needed, it should be based on commit
history and explicit human records, not on retrospective model judgment alone.
