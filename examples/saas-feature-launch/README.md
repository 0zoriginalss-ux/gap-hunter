# Example: SaaS Feature Launch

A canonical run of the Gap-Hunter pattern in `plan` mode using the `saas-feature` adaptor. This example is **fully populated** — every artefact the chain produces is here.

## The brief

A B2B SaaS product is about to ship a new feature: shared workspace dashboards that aggregate data from multiple connected sources (Slack, GitHub, Linear). The team needs to decide how to price and meter the feature — per-seat, per-workspace, per-aggregated-source, or flat-rate. Each option has implications for billing, customer expectations, and contract structure.

The team has six weeks until announced launch.

## Files in this example

- [`_shared-context.md`](_shared-context.md) — the project context the chain ran on
- [`brain.md`](brain.md) — full append-only research log
- [`strategy/integration-catalog.md`](strategy/integration-catalog.md) — synthesised catalogue
- [`strategy/decisions.md`](strategy/decisions.md) — architecture decision records
- [`strategy/tasks.json`](strategy/tasks.json) — importable task list
- [`strategy/risk-register.md`](strategy/risk-register.md) — trackable risks
- [`strategy/wave-briefings/`](strategy/wave-briefings/) — execution-ready briefings

## What to read first

If you want to understand what the pattern produces, start with [`strategy/integration-catalog.md`](strategy/integration-catalog.md). It is the synthesis output and the document that hands off to the execution phase.

If you want to see how the chain reasoned its way there, read [`brain.md`](brain.md) top to bottom. Each section is one agent's contribution.

## Anonymisation note

Specific company names, customer references, and internal codenames have been replaced with placeholders. The technical decisions and reasoning are preserved.
