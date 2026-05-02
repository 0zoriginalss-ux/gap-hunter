# Integration Catalogue — Workspace Dashboards

**Project:** Workspace Dashboards Feature
**Mode run:** plan
**Adaptor:** saas-feature
**Run date:** 2026-04-13
**Verifier quality signal:** high

---

## Executive summary

The team has four candidate pricing models for a new dashboard feature, a six-week timeline, and one undefined constraint (the CEO's "value-aligned pricing" preference). The chain converges strongly on **per-workspace pricing** as the immediate choice, with an explicit hybrid escalation path reserved for the enterprise tier in the next pricing cycle. The strongest open item is the absence of willingness-to-pay data — addressable in two weeks of structured customer interviews if the team chooses to invest, defensible to ship without if they don't.

---

## 1. Technique catalogue

| Technique | Source agent(s) | Maturity | Stack-fit | Adoption-filter pre-check |
|---|---|---|---|---|
| Per-seat dashboard pricing | Wildcard, Methodology | Mature; declining adoption | Compatible (existing infra) | Slot-fit: existing seat infra; pilot-runnable: yes |
| Per-workspace flat pricing | Methodology, Stakeholder, Contradictions | Mature; rising adoption | Excellent — Stripe native | Slot-fit: existing customer-level billing; pilot-runnable: yes |
| Per-aggregated-source metered | Methodology | Mature; documented failure modes | Moderate — adds metering | Slot-fit: NEW component (event ledger); pilot-runnable: yes but heavier |
| Hybrid (workspace + tiered seat caps) | Methodology, Contradictions | Emerging; ~12 months of adoption | Compatible | Slot-fit: extension of workspace; pilot-runnable: yes |
| Flat-rate (bundled) | Wildcard | Mature; suppresses revenue | Compatible | Slot-fit: existing plan structure; pilot-runnable: yes |
| Billing event ledger pattern | Orchestration | Mature in industry; new for us | New component | Slot-fit: NEW; pilot-runnable: only as part of metered model |

## 2. Adoption-filter check (top candidates)

### Per-workspace flat pricing
- **Invariants:** Pass. Multi-tenant RLS preserved. Stripe-native. SOC2 audit-friendly (one billing event per workspace state change, low audit surface).
- **Slot-fit:** Existing slot. Workspace creation already triggers a Stripe customer; this extends with a feature-level subscription line item.
- **Pilot-runnable:** Yes. Two-week implementation, one-week pilot with 3 design partners.

### Hybrid (workspace + tiered seat caps)
- **Invariants:** Pass. Same as workspace-flat plus the option of seat-cap enforcement.
- **Slot-fit:** Existing slot, with modest extension for cap enforcement.
- **Pilot-runnable:** Yes. Three-week implementation if launched alongside workspace-flat for SMB tier.

### Per-aggregated-source metered
- **Invariants:** Risk to "billing accuracy" invariant due to documented metering failure modes. Audit surface increase (not a hard violation but flagged).
- **Slot-fit:** New slot. Requires billing event ledger as new architectural component.
- **Pilot-runnable:** Yes but heavier — 5-6 week implementation, plus operational burden.

## 3. Contradictions register

### Now (current phase)
- **C-NOW-1:** CEO "value-aligned pricing" preference is undefined. Severity: Moderate. Resolution paths: (1) define before commit, (2) document as deferred constraint and proceed.
- **C-NOW-2:** Per-seat core pricing vs. workspace-flat feature pricing creates customer-facing inconsistency. Severity: Moderate. Resolution paths: (1) prepare a clear FAQ explaining the rationale, (2) consider hybrid to align partly with seat model.
- **C-NOW-3:** Six-week timeline vs. metered billing operational complexity. Severity: Critical if metered chosen. Resolution paths: (1) choose per-workspace, (2) defer launch.

### Mid (6-12 months)
- **C-MID-1:** Long-cycle commitment with incomplete data. Severity: Moderate. Resolution paths: (1) explicit re-evaluation point in January 2027 review.
- **C-MID-2:** Pure workspace-flat constrains enterprise upgrade path. Severity: Moderate. Resolution paths: (1) explicit hybrid plan for enterprise tier, (2) accept and address in next cycle.

### Long (2+ years)
- **C-LONG-1:** AI Act and AI-augmented dashboards. Severity: Currently low, will escalate. Resolution paths: (1) design billing model to extend cleanly to AI-generated content, (2) defer until AI features are scoped.

## 4. Stakeholder digest

**By stakeholder:**
- Pilot customers (3 design partners): want predictability — per-workspace preferred
- Enterprise IT: requires per-workspace visibility for procurement
- End users: indifferent
- Sales: prefers workspace or hybrid for deal-cycle ease
- Customer success: any change to existing customers needs careful comms
- Finance/billing: per-workspace minimises operational and audit burden
- Compliance: neutral on model, flags metered as audit risk

**Cross-stakeholder conflicts:**
- Sales (wants flexibility) vs. Finance (wants predictability) — resolvable through hybrid model with clearly-defined caps
- CEO (undefined "value-aligned") vs. team (needs to ship) — requires resolution before final commit

**Unresolved stakeholder concerns:**
- Customer success has not produced the change-comms template
- Pricing committee has not formally approved any of the four candidate models

## 5. Top recommendations

### Must

#### M-1: Adopt per-workspace flat pricing for the dashboards feature at launch
- **Goal:** Ship a pricing model that aligns stakeholder concerns, fits existing infrastructure, and meets the timeline.
- **Scope:** New feature only. Existing customers on per-seat core pricing remain unchanged.
- **Invariants to preserve:** Multi-tenant isolation, Stripe-native billing, SOC2 audit trail, six-week notice for any future pricing changes.
- **Dependencies:** Stripe customer-level subscription line items (already supported), workspace state machine extension.

#### M-2: Document an explicit hybrid escalation path for enterprise tier in the January 2027 review
- **Goal:** Preserve the upmarket move without committing to it now.
- **Scope:** Documentation only at this stage; no implementation.
- **Invariants to preserve:** The hybrid plan must be designed to coexist with workspace-flat, not replace it.
- **Dependencies:** Pricing committee sign-off on the escalation framework.

#### M-3: Resolve the "value-aligned pricing" definition with the CEO before final commit
- **Goal:** Convert an undefined constraint into either a concrete requirement or an acknowledged deferral.
- **Scope:** One conversation, one written outcome.
- **Invariants to preserve:** The team must not block on indefinite definition; if the CEO defers, document and proceed.
- **Dependencies:** CEO calendar.

### Should

#### S-1: Conduct WTP interviews with 3 design-partner customers in the next two weeks
- Defensible to ship without, but the data improves the M-2 hybrid framework.

#### S-2: Audit the 12 enterprise contracts for pricing-stability and most-favoured-customer clauses
- Flagged by Gap-Hunter as a gap; manual review needed before any enterprise-tier change.

#### S-3: Build the customer-success comms template for the pricing change to new customers
- Even though existing customers are unchanged, the new model requires clear external communication.

#### S-4: Map specific competitor pricing for two named competitors in the buyer ICP
- Partial information today; one afternoon of work to complete.

### Could

- Build a billing event ledger preemptively. Useful if the AI-augmented roadmap materialises in 2026, otherwise premature.

### Rejected

- **Per-aggregated-source metered:** Creates customer-facing cost-management friction that undermines feature value (multiple post-mortems). Adds audit risk. Misses the timeline.
- **Flat-rate bundled:** Leaves revenue on the table. Creates pressure to invent new paid features.

## 6. Emergent-spawn log

The Gap-Hunter spawned two follow-up agents:

1. **WTP research spawn** — surfaced comparable B2B SaaS WTP data and produced an interview template the team can apply to design partners. The chain almost shipped without a WTP signal at all.
2. **Contract structure spawn** — produced a checklist of common contract clauses that constrain feature pricing. The Stakeholder-Sweep flagged this as relevant; without the spawn it would have been a deferred concern.

What the initial chain almost missed: **the absence of WTP data was treated as a known gap by every prior agent, but only the Gap-Hunter classified it as `must-fill-now` and triggered actual research**. Without the meta-step, the team would have shipped a defensible-on-paper analysis that had no customer-side validation.

## 7. Methodology log

- **High-value agents on this run:** Stakeholder-Sweep, Contradictions, Gap-Hunter. Cross-stakeholder conflicts and emergent spawns drove the recommendations.
- **Lower-value agents:** Structure agent's output overlapped with what Methodology already covered. Briefing could be sharpened to reduce overlap on small-decision runs.
- **Verifier quality signal:** High. Zero false positives, severity assignments held up.
- **Chain convergence:** Strong. Per-workspace surfaced as the leading candidate by Agent 2 and held through the rest of the chain.
- **Suggestions for next run:** For pricing-decision-class research, consider adding a competitor-pricing-pull as a structured Wildcard sub-task rather than relying on the agent's general search. The Methodology agent's output would be sharper with that input.

## Open items still requiring human judgement

1. CEO conversation on "value-aligned pricing" definition (M-3)
2. Pricing committee approval of M-1 and the M-2 escalation framework
3. Decision on whether to invest two weeks in WTP interviews (S-1) before launch or accept the data gap

## Sources

(Aggregated from agent outputs, deduplicated. URLs preserved in individual agent output files in `round-1/`.)
