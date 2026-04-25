# Requirements Diff Index

**Status:** installed diff navigation index
**Last updated:** YYYY-MM-DD

> This file is installed in an adopted project as
> `authorities/diffs/REQUIREMENTS_DIFF_INDEX.md`.
> It is a pointer and ledger. It is not a product requirements diff,
> implementation packet, or evidence artifact.

---

## 1. Purpose

This file identifies the active requirements diff for the adopted project.

Individual `REQUIREMENTS_DIFF_*` files may keep historical status fields after
implementation, acceptance, or supersession. Do not infer the active diff from:

- the highest version number;
- the latest modified file;
- the file currently open in an editor;
- stale `Status` fields inside a diff file.

Use this index to answer:

- which diff governs the current initiative;
- which diff is the editable head of a change line;
- which diffs are accepted or historical records;
- which implementation family belongs to the active diff.

The `Current Active Diff` table is the authoritative source for the current
active diff. Do not duplicate that state in this file header or in the project
overlay.

---

## 2. Active Diff Contract

Only one requirements diff may be active for implementation planning at a time.
The ledger may contain multiple change lines, but only one row may be marked as
the active implementation target.

The active diff:

- governs the current product scope change;
- is read before any root `IMPL-*` for that initiative;
- defines which baseline or interaction documents may be temporarily stale;
- opens or names the implementation family that executes it;
- does not become accepted baseline or factual implementation evidence just
  because it is listed here.

If no scope-changing work is active, keep `Active diff` set to `none`.

---

## 3. Current Active Diff

| Field | Value |
|---|---|
| Active diff | none |
| Active state | none |
| Change line | none |
| Implementation family | none |
| Required first propagation | none |
| Acceptance evidence | none |
| Baseline or interaction refresh target | none |

---

## 4. Diff Ledger

| Diff | Change line | State in index | Role |
|---|---|---|---|
| none | none | none | No active or historical diffs have been registered yet |

Use `State in index` values such as:

- `active head`
- `parked draft`
- `superseded history`
- `accepted history`
- `rejected history`

Older diffs remain auditable history. They should not be edited once a
successor becomes the current head.

---

## 5. Update Rules

Update this file when:

1. a new `REQUIREMENTS_DIFF_*` is opened for active scope work;
2. an active diff is split and a child diff becomes the implementation target;
3. a successor diff freezes a predecessor as history;
4. a diff is accepted through test-campaign evidence;
5. active work is paused and no diff should govern current implementation;
6. an `IMPL-*` family changes which diff it executes.

Do not update `TRACEABILITY_MATRIX.md` just because this index changes. The
matrix moves only from accepted evidence.
