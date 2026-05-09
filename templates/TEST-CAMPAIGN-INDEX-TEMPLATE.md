# Test Campaign Index

**Status:** active campaign navigation index
**Last updated:** YYYY-MM-DD

> This file is installed in an adopted project as the campaign navigation
> index, normally at `authorities/campaigns/TEST-CAMPAIGN-INDEX.md`.
> It is not acceptance evidence. Individual `TestCampaign-*` documents remain
> the evidence artifacts.

---

## Purpose

This file tracks test campaign discovery and operational status.

Use it to answer:

- which campaign belongs to the active diff or IMPL family;
- which campaigns are accepted, partial, deferred, or historical;
- which evidence level each campaign reached;
- whether an active review constrains campaign interpretation.

Use `TEST-CAMPAIGN-TEMPLATE.md` when creating a new campaign.

---

## Reading Rule

During bootstrap, read this index after `IMPL-INDEX.md` and before opening
individual `TestCampaign-*` files.

When working on an active diff, read the campaign rows for the active IMPL
family first, then open the linked campaign document for evidence details.

If a campaign row references an active review, read the installed
`REVIEW-INDEX.md` and the linked review before changing acceptance status or
traceability.

---

## State Fields

| Field | Meaning |
|---|---|
| Campaign result | Result declared by the campaign document: `PASS`, `FAIL`, `PARTIAL`, `DEFERRED`, or `not created`. |
| Acceptance state | Whether the campaign result has been accepted by the user or another explicit authority. |
| Evidence level | Highest evidence surface represented. |
| Review links | Active reviews that constrain interpretation of this campaign. |

---

## Evidence Levels

Use the most specific applicable label:

| Evidence level | Meaning |
|---|---|
| `unit` | Automated unit-level checks only. |
| `deterministic local` | Local deterministic harnesses or integration tests. |
| `empirical model probe` | Model-facing probe without full runtime surface. |
| `live server` | Real running service/API/server surface. |
| `live UI` | Real user interface or desktop/browser surface. |
| `manual observation` | Human-observed result that is not fully automated. |
| `mixed` | Multiple evidence types; summarize in Notes. |

Do not let evidence level imply acceptance. Acceptance state is separate.

---

## Current Active Diff Campaign Planning

| Scope | Campaign | Campaign result | Acceptance state | Evidence level | Review links | Notes |
|---|---|---|---|---|---|---|
| `[REQUIREMENTS_DIFF_* / none]` | `[TestCampaign-* / not created]` | not created | not accepted | planned: [evidence level] | none | [what this campaign must cover before the active diff can be accepted] |

---

## Active Implementation Family Campaigns

| IMPL / family | Campaign | Campaign result | Acceptance state | Evidence level | Review links | Notes |
|---|---|---|---|---|---|---|
| `[IMPL-N]` | `[TestCampaign-IMPL-N.md / none]` | not created | not accepted | planned | none | [campaign intent] |

---

## Accepted Campaigns

| Campaign | Governing scope | Campaign result | Acceptance state | Evidence level | Notes |
|---|---|---|---|---|---|
| `[TestCampaign-*]` | `[diff / IMPL / full chain]` | PASS | accepted YYYY-MM-DD | [level] | [short factual note] |

---

## Partial / Deferred Campaigns

Use this section when a campaign result produced explicit residual blockers.

| Campaign | Accepted subset | Residual blockers | Routing | Notes |
|---|---|---|---|---|
| `[TestCampaign-*]` | [what was accepted] | [blocker IDs or none] | [same IMPL / follow-up / new IMPL / successor diff] | [short factual note] |

---

## Active Reviews Affecting Campaigns

| Review ID | Affected campaign | Effect |
|---|---|---|
| none | none | No active review hold. |

---

## Historical Campaign Inventory

This inventory lists campaign files currently present. Historical rows are
path-level discovery entries unless they are part of the active IMPL family.

| Campaign document | Family / scope | Index state |
|---|---|---|
| `[TestCampaign-*]` | [scope] | [active / accepted / historical inventory / superseded] |

---

## Update Rules

Update this index when:

1. a new `TestCampaign-*` file is created;
2. a campaign result changes;
3. user acceptance state changes;
4. a campaign is linked to or released from an active review;
5. a new active IMPL family becomes current;
6. a partial campaign routes blockers into follow-up work.

Do not use this index to move requirement status. Move the installed
`TRACEABILITY_MATRIX.md` only from accepted evidence.
