# Shared Context — Workspace Dashboards

**Date initialised:** 2026-04-12
**Adaptor:** saas-feature
**Intended mode:** plan

## Brief

We are launching a new feature: shared workspace dashboards that aggregate data from multiple connected sources (Slack, GitHub, Linear). Customers want a single place to see activity across their tooling. The feature is announced for 2026-05-24.

The decision we need to make before building: how do we price and meter this feature? The four candidate models are:
1. Per-seat — charge per user with dashboard access
2. Per-workspace — flat rate per workspace using the feature
3. Per-aggregated-source — charge by number of connected sources
4. Flat-rate — included in existing plans, no additional charge

Each model has implications for billing infrastructure, customer expectations, contract structure, and how we track adoption. We also need to understand which model best matches the value the feature actually delivers.

## System invariants

- Multi-tenant architecture with row-level security on PostgreSQL
- Stripe is the existing billing provider; switching is not on the table for this feature
- All customer-facing pricing changes require six weeks of advance notice (contractual)
- Tenant data isolation is non-negotiable (SOC2 Type II audit)
- Append-only audit log for all admin actions
- Feature flags via internal system (LaunchDarkly was rejected last quarter)

## Stakeholders

Pre-populated from adaptor: `saas-feature` (see `adaptors/saas-feature.yaml`)

Additional stakeholders for this project:
- Customer success team (manages the existing 12 enterprise accounts that drive 60% of revenue)
- Pricing committee (cross-functional, meets monthly)

## Current phase

Pre-execution. Engineering has prototyped the dashboard rendering. The pricing decision blocks the billing-integration milestone, which blocks public launch.

## Project architecture document

`docs/architecture-overview.md` (in the main project repo, not duplicated here)

## Notes for the chain

- We have already rejected LaunchDarkly (decision Q1 2026) — do not re-suggest external feature-flag platforms
- The CEO has stated a preference for "value-aligned pricing" but has not defined what that means concretely
- Existing customers are on a per-seat model for the core product; pricing inconsistency is a real concern
- We have not surveyed customers about willingness-to-pay for this feature
