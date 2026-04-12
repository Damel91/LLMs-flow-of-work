# Why This Exists

## The Problem

Working with LLMs on real software projects over weeks or months produces
a specific kind of failure that is not obvious at first.

The model is capable. The code it produces is often good. But somewhere
around the third or fourth week, something breaks — not in the code, but
in the process. You lose track of why a decision was made. The model
starts reinventing things that were already decided. A new session
produces answers that contradict previous ones. You spend time explaining
context that should already be established.

This is not a model capability problem. It is a governance problem.

---

## Why Common Approaches Do Not Scale

**The autonomous multi-agent approach** gives the model too much authority.
Agents make decisions without a clear record of why. Traceability dissolves.
When something goes wrong — and it will — you cannot tell whether the failure
is in the code, the model behavior, or the decisions the model made on your
behalf. Token costs compound. The system becomes opaque.

**The giant system prompt approach** tries to put all context in one place.
It does not survive context loss. When the model's window fills up or a new
session starts, the carefully crafted prompt becomes stale. The model
interpolates. Behavior drifts. The prompt grows to compensate, making the
problem worse.

**The autocomplete approach** keeps the model too narrow. It produces
code but not decisions. You end up doing all the architectural reasoning
yourself and using the model only for syntax. This works but wastes the
model's actual capability.

Then there is **vibe coding**, which is what most people actually do when
they sit down with an LLM to build something. You describe roughly what
you want, accept what comes back, iterate on feel. It is the honest shape
of collaboration when nobody has handed you a protocol. And in the short
term it works — which is why so many people are doing it, and why they
should not be judged for it. The problem is not the practice. The problem
is that in its ungoverned form it has no way to carry intent across
sessions, no way to separate what was decided from what was improvised,
no way to reopen a question without reopening everything. After a few
weeks the project is a pile of code that nobody understands — including
the model that wrote it, including you. The mood that produced it cannot
produce its next chapter, because the mood was never the authority to
begin with.

The framework this repository describes is not the opposite of vibe
coding. Structurally it is the same kind of activity: a human who does
not write every line collaborates with a model that does, to produce
software. The difference is that vibe coding in its ungoverned form
collapses past the first pleasant afternoon, and what this repository
offers is a governed form of the same activity — one that can survive
weeks, re-opened sessions, model changes, and honest disagreement.
Call it disciplined vibe coding if that helps. The name matters less
than the property: collaboration that lasts.

---

## Where This Came From

I started from the opposite conviction. A month and a half ago I assumed
that models were about to replace programmers, and I spent weeks pushing
frontier models as hard as I could to see where they would break. What I
found was not what I expected. The models were good — often better than
I was on narrow technical sub-problems. But as projects grew past a few
sessions, something in the collaboration itself started to rot. The
models were not the failing part. The collaboration was.

So I stopped asking *what can the model do?* and started asking *what does
the collaboration need in order not to collapse?*. Every time a session
went badly, I traced back what had actually failed. It was almost never a
capability limit. It was usually that a decision had been made, not
recorded, then contradicted in a later session; or a behavior had never
been defined, and each session had improvised a different version of it;
or a piece of evidence had been assumed present when nobody had actually
produced it.

I started writing those failures down, and writing down the rules that
would have prevented each one. Over time the rules stopped being rules
and became contracts. The contracts stopped being notes and became a
system. The system is what you are reading now.

I did not design this framework in advance. I extracted it from repeated
empirical failure, while correcting LLMs that were trying to help me
build it and would have converged on something less rigorous if left to
their own priors. The recursive loop of human direction and model
formalization is itself part of the method. It produced something that
neither side would have produced alone.

---

## What This Is

This repository contains a flow-of-work contract — a small set of documents
that define how a human and one or more LLMs collaborate on a real software
project without losing control of it.

The core idea is simple:

- documents are authoritative, not model memory
- the human is the routing authority for scope and scenario changes
- the model executes inside explicit boundaries
- behavior that is not defined is a blocker, not an invitation to invent
- evidence comes before traceability updates

The contract is portable. It works with different models at different
capability levels. It survives context loss because it is designed to be
re-read, not remembered. It scales to long projects because governance
is structural, not dependent on anyone's memory.

---

## What This Is Not

This is not a prompt engineering library.
This is not a multi-agent framework.
This is not specific to any programming language or domain.
This is not a replacement for engineering judgment.

It is the control structure around LLM-assisted work.

It is also, worth saying plainly, not a tool that works automatically
because you have an LLM next to it. The contracts use vocabulary —
scope, boundary, evidence, routing authority, behavioral definition —
that is not part of anyone's standard training. A first-time reader
who has built software for twenty years can still miss the distinctions
the framework depends on, because those distinctions belong to a class
of work that did not exist as a formal discipline until very recently.
The same is true in the other direction: a reader who has never
shipped a line of production code can grasp the framework just as well,
or better, once the vocabulary is in hand. This is not a matter of
prior engineering maturity. It is a matter of operating inside a
specific protocol, and the protocol is learnable — but it has to be
learned.

---

## Who This Is For

Anyone working on a non-trivial software project with LLM assistance
who has experienced the governance failure described above and wants
a structured alternative that does not require autonomous agents or
proprietary tooling.

The contract is a starting point, not a prescription. The project-specific
overlay shows how it can be adapted for a concrete project. You will adapt
it for yours.

---

## The Manual

This repository is published together with a companion manual that
explains how to operate inside the framework day to day. It is the
human-side operating guide for the collaboration — the vocabulary, the
reflexes, the decisions that belong to you and the ones you delegate.

The manual is not an introductory guide for casual use. It is the
formalization of a way of working that, as far as I know, has not been
written down anywhere else, because the work it describes is too new
to have acquired a literature. Senior engineers will find it useful for
the same reason first-time users will: nobody has been trained in the
routing protocol of a long-running LLM collaboration, because nobody
teaches it yet.

If you want to study the framework before adoption, start from
`manual/MANUAL-BOOTSTRAP.md`. If you adopt the framework into a real
project, the entire `manual/` directory is installed under
`authorities/manual/`, and the overlay records whether guided manual
onboarding is pending, completed, or explicitly skipped by the user.

Reading only the contracts gives you the structure. Reading the manual
gives you the operating discipline that makes the structure usable
without friction.
