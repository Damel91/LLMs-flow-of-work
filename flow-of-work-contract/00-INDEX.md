---
doc_type: flow_of_work_contract_index
scope: development_control
applies_to: multi-platform
version: 0.1
status: working_draft
last_updated: 2026-04-25
---

# Flow Of Work Contract Index

## 0. Purpose

This folder contains the stable contract set for LLM-assisted engineering in
this repository.

Use this folder when restoring context, opening a new initiative, or resolving
workflow ambiguity.

The contracts in this folder are generic. Project-specific configuration lives
in `authorities/PROJECT-OVERLAY.md`. Read the overlay before the contracts.

## 1. Reading Order

Read in this order:

1. `authorities/PROJECT-OVERLAY.md`
2. `authorities/flow-of-work-contract/00-INDEX.md`
3. `authorities/flow-of-work-contract/01-LLM-SESSION-CONTRACT.md`
4. `authorities/flow-of-work-contract/02-DOCSET-GOVERNANCE-CONTRACT.md`
5. `authorities/flow-of-work-contract/03-BEHAVIORAL-DEFINITION-GATE.md`
6. `authorities/flow-of-work-contract/04-TEST-AND-HANDOFF-CONTRACT.md`
7. `authorities/flow-of-work-contract/05-PROJECT-STRUCTURE.md`

## 2. Document Roles

| Document | Primary question |
|---|---|
| `authorities/PROJECT-OVERLAY.md` | What are the project-specific constraints, language settings, and protected subsystems? |
| `00-INDEX.md` | What is the contract set and in what order should it be read? |
| `01-LLM-SESSION-CONTRACT.md` | How must an LLM session be conducted? |
| `02-DOCSET-GOVERNANCE-CONTRACT.md` | Which document layer governs and how do layers synchronize? |
| `03-BEHAVIORAL-DEFINITION-GATE.md` | When is the agent blocked because behavior is not defined? |
| `04-TEST-AND-HANDOFF-CONTRACT.md` | When is a packet ready for validation and how is evidence produced? |
| `05-PROJECT-STRUCTURE.md` | Where do documents and project files go? |

## 3. Authority Note

These files define workflow law.

They do not replace:

- `authorities/baseline/REQUIREMENTS*` for product intent
- `authorities/interactions/USE_CASES_AND_SEQUENCES.md` for scenario meaning
- `authorities/diffs/REQUIREMENTS_DIFF_INDEX.md` for selecting the active diff
- `authorities/diffs/REQUIREMENTS_DIFF_*` for active scope evolution
- `authorities/impl/IMPL-*` for bounded execution
- `authorities/campaigns/TestCampaign-*` for evidence
- `authorities/TRACEABILITY_MATRIX.md` for accepted factual state
