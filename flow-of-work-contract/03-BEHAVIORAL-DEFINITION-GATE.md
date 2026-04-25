---
doc_type: behavioral_definition_gate
scope: execution_blocking
applies_to: multi-platform
version: 0.3
status: working
last_updated: 2026-04-25
---

# Behavioral Definition Gate

## 0. Quick Rules

1. Requirements define product scope, not always behavior.
2. If runtime behavior is under-specified, the agent is blocked.
3. The agent must not invent interaction behavior, prompt behavior, or
   state-machine behavior.
4. Missing behavior is a valid blocker even when the feature goal is known.
5. The correct response to missing behavior is targeted clarification or a
   declared behavioral reference, not assumption.

## 1. Purpose

This document defines when the agent must stop because the requested behavior
is not sufficiently defined to implement safely.

This is a workflow contract, not a product feature specification.

## 2. Why Requirements Alone Are Sometimes Insufficient

Requirements can define:

- what feature exists
- what constraints exist
- what outcomes are expected

But they may still fail to define:

- who asks for clarification and when
- which node owns the next action
- what schema a prompt must return
- how fallback or error handling behaves
- what the user sees turn by turn
- what state transition happens between two stages

When those behaviors matter, requirements alone are not enough to code safely.

## 3. Behavioral Definition Gate

The agent may proceed only if the needed behavior can be derived from at least
one authoritative source:

- accepted use case or sequence
- accepted requirements diff
- explicit user instruction
- existing working code used as a declared behavioral reference

If none of those sources defines the needed behavior, the agent is blocked.

Blocked means:

- do not implement the ambiguous behavior
- do not infer the behavior from intention alone
- do not hide the ambiguity behind a structural refactor

### 3.1 Clear Gate Criteria

The gate is clear only if all behavior needed for the current packet can be
answered from an authoritative source.

Minimum criteria:

- behavior owner is identified
- user-visible or runtime outcome is defined
- relevant inputs, events, or triggers are defined
- expected output, schema, state transition, or side effect is defined
- fallback, error, or clarification behavior is defined or explicitly out of
  scope
- the authority source is named with enough precision to re-read it

If any required behavior affects runtime execution, prompt output, state
transition, persistence, or user-facing flow and lacks authority, the gate is
blocked.

### 3.2 Gate Record

Every implementation packet that can affect behavior must record:

- gate status: `clear` or `blocked`
- authority type: `requirements_diff`, `use_case`, `sequence`,
  `user_instruction`, or `working_code_reference`
- authority reference: document path and section, user instruction, or declared
  reference code path
- whether runtime or user-visible behavior is affected
- whether fallback or error behavior is affected, or explicitly out of scope

If the gate is `blocked`, implementation must stop and the packet must record
the missing behavior, why the current documents are insufficient, and the
required decision.

## 4. User Interaction Layer Rule

When the missing definition concerns interaction with the user, the agent must
stop before implementation.

Examples:

- routing authority
- clarification timing
- confirmation or cancel flow
- fallback wording
- readiness or blocking messages
- schema strictness for model outputs
- when to ask versus when to proceed automatically

These behaviors cannot be safely derived from structural requirements alone.

## 5. Prompt And State-Machine Rule

For prompt-driven or graph-driven systems, the agent must confirm all of the
following before implementation:

- which node owns the behavior
- what the prompt must do and must not do
- what exact output schema is required
- whether one-shot or few-shot examples are required
- what transitions the state machine must follow

If these are not defined, the agent is blocked.

The agent must not rely on prompts such as:

- "return something like this"
- "produce an object similar to"
- "use this structure if possible"

when a strict contract is actually required.

### 5.1 Ownership Classification Rule

For prompt-driven or graph-driven systems, the agent must also confirm for each
new field or concept whether it is:

- model-owned
- runtime-derived
- persisted
- rendered-only

The agent must not proceed when a field is introduced without ownership.

Examples of blocked ambiguity:

- a prompt returns a field but docs do not say whether runtime may override it
- a runtime-derived field is described as if the model were authoritative
- a rendered field is treated like persisted system state

This rule exists to prevent silent duplication of authority between prompts and
runtime code.

## 6. Working Code As Behavioral Reference

Existing working code may be used as a behavioral reference only if the agent
states that explicitly.

Permitted use:

- inspect the closest working implementation
- extract the behavioral contract
- map that contract back into the active initiative
- ask the user to confirm if the reference is intended to govern

Forbidden use:

- silently copying behavior from unrelated code
- treating a structurally similar implementation as authoritative without saying
  so
- treating reference code as accepted product law when docs disagree

## 7. Targeted Clarification Duty

When blocked, the agent must surface the ambiguity clearly.

The clarification must identify:

- the affected component or node
- the missing behavior
- why the current docs are insufficient
- what decision is needed from the user or from a declared reference

The question should be narrow and executable.

Bad:

- "What do you want?"

Good:

- "Should the clarification node return a final action ID or only a ranked hint?"

## 8. Human Analogy Rule

If the feature is known but the required behavior is not known, the engineer is
blocked.

This applies equally to human and LLM work.

The absence of behavioral definition is not lack of effort. It is incomplete
authority to proceed.

## 9. Prohibited Behaviors

Do not:

- declare a behavior, mechanism, or property absent without first re-reading
  the most relevant authoritative section directly
- invent user interaction behavior because the feature goal seems obvious
- infer prompt schema from intent alone
- implement a state transition that is not defined anywhere authoritative
- treat missing behavior as a minor detail when it controls execution
- continue coding after a behavioral blocker has been identified

## 10. Project-Specific Extension Point

An adopting project may extend this contract with project-local behavioral
seams that historically produced ambiguity.

Typical examples:

- prompt contracts with strict JSON output
- routing and clarification behavior
- planning-review behavior
- workspace-review behavior
- graph nodes that can block, clarify, reroute, or mutate target state

Those extensions belong in the adopting project's overlay or adjacent
project-specific docs. They must not be hardcoded into this generic contract.
