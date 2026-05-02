# Wave Briefing: Implement per-workspace flat pricing for dashboards feature

**Source:** Integration Catalogue Section 5, Must-1
**Linked task:** GH-001
**Linked risks:** RISK-002

## Goal
Ship per-workspace flat pricing for the dashboards feature on the announced 2026-05-24 launch date, with the new pricing applying only to new customers and to existing customers who explicitly opt in.

## Scope
- In scope: extending workspace creation to register a feature-level subscription line item with Stripe; admin UI to view dashboards-feature billing line; opt-in flow for existing customers
- Out of scope: any changes to per-seat core product billing; any pricing changes for existing customers without their opt-in; metered or hybrid pricing (covered separately)

## Invariants to preserve
- Multi-tenant row-level security on PostgreSQL (no cross-workspace data leakage in billing line items)
- Stripe-native billing only (no parallel billing infrastructure)
- SOC2 audit trail intact (every billing event written to append-only audit log)
- Six-week notice for any future pricing changes (contractual)
- Existing customer billing unchanged unless they opt in

## Dependencies
- GH-003 must complete before final implementation commit (CEO conversation)
- Pricing committee approval on the specific dollar amount per workspace
- Stripe customer-level subscription line items (already supported, no new Stripe configuration)
- Workspace state-machine extension for billing-feature-active state

## Adoption-filter check
- **Invariants:** Pass — see invariants list above
- **Slot-fit:** Existing workspace creation slot. Modest extension to register Stripe subscription line item.
- **Pilot-run:** Two-week implementation, one-week pilot with the three design-partner accounts. Rollback path: deactivate the line item at workspace level, no billing impact on rollback.

## Stop conditions
- If GH-003 surfaces a CEO requirement that invalidates per-workspace pricing → pause and re-consult Integration Catalogue
- If GH-005 (contract audit) surfaces clauses that constrain feature pricing for existing customers → pause and reconsider opt-in mechanism
- If billing event accuracy in pilot shows >0.1% error rate → pause and resolve before public launch

## Definition of done
- Per-workspace billing line item creates correctly for new workspace + dashboards activation
- Pilot with 3 design-partner accounts: 7 days of usage with zero billing errors
- Audit log verified to capture every dashboards-feature billing state change
- Customer-success comms template reviewed by pricing committee (GH-006)
- Rollback procedure tested in staging
