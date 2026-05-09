# Review Index

**Status:** active review navigation index
**Last updated:** YYYY-MM-DD

> This file is installed in an adopted project as the review navigation index,
> normally at `authorities/reviews/REVIEW-INDEX.md`.
> It is not an implementation packet and not test evidence.

---

## Purpose

This file tracks active clarification and review notes that may affect current
implementation, validation, or acceptance decisions.

Reviews preserve unresolved questions, suspected cross-slice defects,
acceptance holds, and packet-boundary concerns until they are answered.

Use `REVIEW-TEMPLATE.md` when creating a new review.

---

## Reading Rule

During bootstrap, read this index after the active requirements diff and before
working on any affected `IMPL-*` packet.

If an entry is `active` and its scope overlaps the requested work, read the
linked review before implementation, test planning, acceptance updates, or
traceability updates.

---

## Active Reviews

| Review ID | Scope | Status | Blocking level | Review document |
|---|---|---|---|---|
| none | none | closed | advisory | none |

---

## Status Meanings

| Status | Meaning |
|---|---|
| `active` | The review contains an unresolved question or risk that must be read before affected work proceeds. |
| `answered` | The question has been answered, but resulting implementation or documentation work may still be pending. |
| `closed` | The review has been resolved, any required follow-up has landed, and no active hold remains. |

---

## Blocking Levels

| Level | Meaning |
|---|---|
| `global block` | No related implementation should proceed until the review is resolved. |
| `targeted hold` | Only the named slice, IMPL, campaign, or acceptance path is held. |
| `advisory` | Read before work, but it does not block implementation or validation. |

---

## Closed Reviews

| Review ID | Scope | Status | Closed date | Review document |
|---|---|---|---|---|
| none | none | closed | none | none |

---

## Update Rules

Update this index when:

1. a new review is opened;
2. a review changes blocking level;
3. a review is answered;
4. a review is closed;
5. a campaign or IMPL is linked to or released from a review hold.

Do not use this index as a substitute for campaign evidence or requirement
status. It is a navigation and hold register.
