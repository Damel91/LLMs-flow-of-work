# Test Environment Startup

**Status:** reusable helper template
**Scope:** [project / subsystem / campaign family]
**Language policy:** [documentation language]

> This is a reusable environment helper for live or integration campaigns.
> It is not an implementation plan and not acceptance evidence by itself.

---

## Purpose

Use this helper before any live `TestCampaign-*` that depends on a real runtime
environment.

This document standardizes:

- clean-state reset;
- service startup;
- health verification;
- acceptance surface;
- inspection endpoints or commands;
- shutdown.

---

## When To Use This Helper

Use it when the campaign requires:

- [real server/API/UI/CLI];
- [real local or remote service dependency];
- [real persisted state];
- [real target repository or data set].

Do not use it when the campaign intentionally uses isolated unit tests, prompt
probes, or stubs.

---

## Runtime Assumptions

| Item | Value |
|---|---|
| Project root | `[path or project variable]` |
| Primary command runner | `[python / node / cargo / make / other]` |
| Config file | `[path or none]` |
| Local service URL | `[URL or none]` |
| Remote service URL | `[URL or none]` |
| Required environment variables | `[names only, no secrets]` |

Do not record secrets in this document.

---

## Environment Constraints

Record known constraints that affect how campaigns are run.

| Constraint | Interpretation | Required action |
|---|---|---|
| [sandbox networking unavailable] | [environment issue, not product defect] | [run outside sandbox / use approved runner] |
| [service already running] | [reuse or restart?] | [rule] |

---

## Standard Reset

If the campaign requires a clean runtime state, reset:

- `[state path or resource]`;
- `[state path or resource]`.

Expected post-reset state:

- [state expectation].

If reset is destructive, require explicit user approval before execution.

---

## Standard Startup

Run:

```bash
[startup command]
```

Expected successful startup indicators:

- [log line, health status, or process state].

Non-blocking warnings:

- [warning or none].

Blocking startup failures:

- [failure or none].

---

## Standard Preflight

| Step | Command / action | Expected result |
|---|---|---|
| Health | `[command]` | [expected status] |
| Fresh session / fixture | `[command]` | [expected output] |
| Optional ingest / seed | `[command]` | [expected output] |

---

## Acceptance Surface Rule

For user-facing live campaigns, use the real primary user surface:

- [API endpoint / UI flow / CLI command].

Do not use lower-level diagnostic surfaces as the primary acceptance path
unless the campaign explicitly targets that diagnostic surface.

---

## Inspection Surfaces

| Surface | Command / path | Use |
|---|---|---|
| Logs | `[command or path]` | [when to inspect] |
| Metrics | `[command or path]` | [when to inspect] |
| State store | `[command or path]` | [when to inspect] |

---

## Recommended Campaign Sequence

1. Reset runtime state if the campaign requires a clean environment.
2. Start required services.
3. Run health/preflight checks.
4. Prepare fresh sessions, fixtures, or target data.
5. Execute campaign-specific tests through the acceptance surface.
6. Inspect logs/metrics/state only when needed to interpret results.
7. Record evidence in the active `TestCampaign-*` document.
8. Shut down services explicitly if this helper started them.
9. Update traceability only after campaign evidence is stable and accepted.

---

## Standard Shutdown

Run:

```bash
[shutdown command]
```

Expected result:

- [process/service exits or returns to original state].

---

## Known Environment Behaviors

| Symptom | Interpretation | Campaign classification guidance |
|---|---|---|
| [symptom] | [environment / product / dependency] | [how to classify] |

