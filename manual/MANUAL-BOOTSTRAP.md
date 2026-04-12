# MANUAL-BOOTSTRAP

This file is the guided onboarding path for the human-side operating manual.

It is meant to be used in two places:

- in the framework repository, before adoption, when a user wants to study the
  framework before installing it
- in an adopted project, at `authorities/manual/MANUAL-BOOTSTRAP.md`, when the
  overlay declares that manual onboarding is still pending or in progress

It is not a replacement for `STARTER.md`.
It is not a project bootstrap.
It is a guided way to read, discuss, and, when installed, persist the user's
current manual-readiness level.

---

## 0. Determine The Context

There are two legitimate modes:

### A. Framework-repo study mode

Use this mode when the user is studying the framework before adoption.

Signals:

- this file is being read from the framework repository
- there is no adopted destination project yet
- there is no installed `authorities/PROJECT-OVERLAY.md` to update

In this mode:

- guide the user through the manual
- do not pretend to persist project state
- if the user later adopts the framework, tell them to declare their current
  readiness during adoption so the installed overlay can start from the right
  state

### B. Installed-project onboarding mode

Use this mode when the project has already been adopted and this file is being
read from `authorities/manual/`.

Signals:

- `authorities/PROJECT-OVERLAY.md` exists
- the file is installed under `authorities/manual/`

In this mode:

- read overlay sec. 1, sec. 2, sec. 8, and sec. 9 before starting
- use overlay sec. 8 as the source of truth for manual-onboarding state
- update overlay sec. 8 conservatively as the user progresses

If overlay sec. 8 already says:

- `manual bootstrap status = completed`
- or `manual bootstrap status = skipped_by_user`

then do not reopen guided onboarding unless the user explicitly asks for it.

---

## 1. What This Tool Owns

This tool owns:

- guiding the user through `REACHING-THE-LLMS.md`
- supporting focused discussion of selected manual sections
- classifying manual-readiness conservatively
- persisting manual-onboarding state in overlay sec. 8 when this tool is
  running inside an adopted project
- offering an explicit skip path

This tool does not:

- replace `STARTER.md`
- replace `CODE-BOOTSTRAP.md`
- decide product scope
- infer user readiness from confidence or fluency alone
- treat manual discussion as a substitute for project-specific requirements

---

## 2. Offer Only Three Paths

Ask the user one question:

"Do you want to work through the manual now, discuss only specific parts of it,
or explicitly skip guided manual onboarding and continue?"

Record one of:

- `guided_read`
- `targeted_discussion`
- `skip`

In installed-project mode:

- if the user chooses `guided_read` or `targeted_discussion`, set overlay
  sec. 8 to:
  - `manual bootstrap status = in-progress`
  - `manual readiness level = not_started`
  - `last manual checkpoint = none`
  - `manual override acknowledged = no`
- if the user chooses `skip`, follow section 5

---

## 3. Guided Read Path

Use `REACHING-THE-LLMS.md` as the source text.

Read and discuss it in these blocks:

1. `Before You Read`, `What This Framework Actually Solves`, `The Mental Model`
2. `The User's Role`, `The Core Operating Rules`, `The Main Documents And Their Jobs`
3. `How To Start A Real Project`, `The Working Loop`,
   `The Important Distinction: Handoff Readiness vs Campaign Constructibility`
4. `How To Read Partial`, `How To Handle Scope Issues Found By Campaign`,
   `How To Treat Diffs Over Time`, `The Most Common Mistakes`,
   `What Changes With Different Model Types`, `Minimal Glossary`,
   `Final Advice`

For each block:

- read the relevant sections
- summarize them operationally, not rhetorically
- ask whether the user wants to continue or discuss before proceeding

In installed-project mode, update overlay sec. 8 conservatively:

- when block 1 starts:
  - `manual bootstrap status = in-progress`
  - `manual readiness level = not_started`
  - `last manual checkpoint = The Mental Model`
  - `manual override acknowledged = no`
- after block 2, if the user has understood the mental model, the role split,
  and the core operating rules:
  - `manual bootstrap status = completed`
  - `manual readiness level = basic`
  - `last manual checkpoint = The Core Operating Rules`
  - `manual override acknowledged = no`
- after block 4, if the user has also covered the working loop, campaign
  constructibility, `Partial`, scope issues, and diff history:
  - `manual bootstrap status = completed`
  - `manual readiness level = operational`
  - `last manual checkpoint = Final Advice`
  - `manual override acknowledged = no`
- if the user pauses before completion:
  - keep `manual bootstrap status = in-progress`
  - keep the most conservative readiness level justified by actual coverage
  - set `last manual checkpoint` to the latest completed section or block

---

## 4. Targeted Discussion Path

If the user wants focused discussion instead of a full guided read:

- ask what they want to understand
- route to the relevant manual sections
- keep the discussion operational

Do not mark the user `operational` unless they have covered, at minimum:

- the mental model
- the core operating rules
- the working loop
- the meanings of `Implemented`, `Partial`, and `Gap`
- the difference between implementation closure and behavioral authority

In installed-project mode:

- mark `completed / basic` only when the user has covered enough to operate
  conservatively without treating chat memory as authority
- otherwise keep `manual bootstrap status = in-progress`
- update `last manual checkpoint` to the most recent section meaningfully
  discussed

---

## 5. Skip Path

If the user explicitly wants to proceed without guided manual onboarding:

In installed-project mode, set overlay sec. 8 to:

- `manual bootstrap status = skipped_by_user`
- `manual readiness level = not_started`
- `last manual checkpoint = skipped by user`
- `manual override acknowledged = yes`

Then:

- state plainly that guided manual onboarding was skipped by user choice
- do not reopen this bootstrap automatically in later sessions unless the user
  explicitly changes overlay sec. 8 or asks to reopen it
- return control to `AGENT.md` or to the normal working flow

---

## 6. Completion Rule

Use these meanings:

- `completed / basic`
  - the user has covered the mental model, operating rules, and document roles
  - they can operate conservatively, but may still need help with the finer
    distinctions of campaign timing or diff history
- `completed / operational`
  - the user has also covered the working loop, campaign constructibility,
    `Partial`, scope issues, and diff precedence over time

Never infer readiness from style, confidence, or prior engineering seniority
alone. Use only actual coverage of the manual's operating concepts.

In installed-project mode, after completion:

- if overlay sec. 9 still declares a pending code-bootstrap run, return control
  so normal `AGENT.md` routing can send the next session into
  `CODE-BOOTSTRAP.md`
- otherwise return control to normal project work
