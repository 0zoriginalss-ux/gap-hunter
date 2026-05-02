# Wave Briefing: Resolve CEO definition of "value-aligned pricing"

**Source:** Integration Catalogue Section 5, Must-3
**Linked task:** GH-003
**Linked risks:** RISK-001

## Goal
Convert the CEO's stated preference for "value-aligned pricing" into either a concrete decision criterion the team can apply, or an explicit deferral acknowledging that the preference is a long-term aspiration rather than a current criterion.

## Scope
- In scope: one focused conversation, one written outcome, documentation in ADR-003
- Out of scope: re-running the pricing analysis based on speculative interpretations of the preference

## Invariants to preserve
- The team must not block launch on indefinite definition. If the CEO defers, the team proceeds with ADR-001 and notes the deferral in writing.
- The conversation outcome is written down within 5 business days, not held verbally and forgotten.
- The CEO's preference is treated as input, not as a veto — if the definition that emerges contradicts the chain's strong stakeholder convergence, the team surfaces the contradiction explicitly rather than silently overriding either side.

## Dependencies
- CEO calendar
- The integration catalogue read by the CEO before the conversation (or at least Section 5)

## Adoption-filter check
- **Invariants:** Pass — pure conversation
- **Slot-fit:** Existing executive-decision-record slot
- **Pilot-run:** Not applicable — this is a single conversation

## Stop conditions
- If the CEO requests a fundamentally different pricing analysis based on the definition → re-consult the chain rather than executing on the new direction
- If the conversation has not happened by 2026-04-22 → proceed with ADR-001 and document the deferral

## Definition of done
- One of the following written outcomes exists:
  1. A concrete definition of "value-aligned pricing" that the team can apply to the M-1 decision (e.g. "value-aligned means pricing should track number of integrated sources because that is the value driver")
  2. An explicit deferral: "value-aligned pricing is a long-term aspiration; for the M-1 decision, the team proceeds with per-workspace flat pricing"
- Outcome documented in ADR-003
- Pricing committee informed
