# Research Brain — Workspace Dashboards

**Initialised:** 2026-04-12 22:14
**Mode:** plan
**Adaptor:** saas-feature

This file is **append-only**. Every agent in the chain appends a section.
After the chain completes, this file remains open during execution for
ongoing findings, blockers, and deviations.

---

## Agent 1: Wildcard-Breadth (COMPLETED 2026-04-12 22:48)

### Findings
- The B2B SaaS pricing landscape in 2026 has shifted strongly toward usage-based and hybrid models for analytics and dashboard features specifically; per-seat is increasingly seen as a friction point that suppresses internal sharing
- The "share-of-wallet" framing dominates analyst commentary — pricing should track the share of customer value the feature represents, not the per-user delivery cost
- Recent post-mortems from at least three named SaaS companies show per-aggregated-source pricing creates a perverse incentive: customers limit integrations to control cost, defeating the feature's value proposition
- Workspace-level flat pricing is gaining traction at companies whose feature creates network effects within a customer's team
- A subset of the market is moving to "value-tier" pricing that bundles dashboard features into plan tiers rather than metering them — simpler to communicate, harder to game

### Open Questions
- What is the actual usage distribution we expect — concentrated power-users or broadly accessed?
- How are competitors in the same buyer ICP currently pricing similar features?
- Does our existing per-seat core pricing constrain what we can do with feature pricing?

## Agent 2: Methodology (COMPLETED 2026-04-12 23:24)

### Findings
- **Per-seat pricing for analytics features:** Best documented adoption examples come from horizontal SaaS (Notion, Linear) where dashboard usage is genuinely per-user. Failure mode: in collaborative settings, per-seat suppresses the network effect the feature is meant to create. Adoption cost is low (existing infrastructure) but customer pushback in deal cycles is documented at three named companies
- **Per-workspace flat pricing:** Documented success at vertical-SaaS companies serving teams (Pitch, Loom). Failure mode: revenue does not scale with deeper adoption; large workspaces extract disproportionate value. Stack-fit with our Stripe setup is excellent — Stripe natively supports per-workspace as "per-customer" billing
- **Per-aggregated-source pricing:** Stripe-native via metered billing. Three documented post-mortems (Datadog-style metering, Mixpanel data tier transitions) show this model triggers customer cost-management behaviour that undermines product value. Stack-fit is moderate — billing accuracy on integration counts has been a class of bug at multiple companies
- **Hybrid (workspace + tier-based seat caps):** Emerging pattern at companies that started per-seat and want to evolve. Reduces friction without abandoning seat-based revenue. Documented at one comparable-size B2B SaaS in the past 9 months
- **Flat-rate (bundled into plans):** Simplest to communicate. Failure mode: leaves money on the table for customers who would have paid more, and creates pressure to invent new paid features. Adoption-cost is low

### Open Questions
- How does Stripe handle mid-cycle workspace-pricing changes for existing per-seat customers?
- Is there evidence on customer willingness-to-pay differences between these models in our specific buyer ICP?

### Stakeholder Reactions (relevant)
- Sales team would prefer hybrid or workspace-flat models — easier to quote in deal negotiations
- Finance team flagged that per-source metering accuracy has been a class of audit findings at peer companies

## Agent 3: Orchestration (COMPLETED 2026-04-13 00:02)

### Findings
- The handoff between feature usage and billing system is the most-failed integration seam: events lost in transit, double-counted, or attributed to the wrong workspace. Three documented post-mortems involve metered-billing customers being over-charged or under-charged due to event-pipeline failures
- Companies running hybrid models typically use a "billing event ledger" pattern — every billable event is appended to an immutable log with idempotency keys, and the billing system polls or subscribes to the log rather than receiving events directly. This creates an audit trail and survives transient failures
- For per-workspace pricing, the orchestration is dramatically simpler — workspace creation triggers a Stripe customer creation, no per-event metering needed
- Our existing Stripe webhook integration has had two incidents in the last 18 months (recorded in our internal incident log); adding metered billing increases the surface area for similar issues

### Open Questions
- How would a billing event ledger fit into our current system architecture? It is a new component
- What is the operational cost of running metered billing reliably at our scale?

## Agent 4: Structure (COMPLETED 2026-04-13 00:38)

### Findings
- A decision table covering the four pricing models against five criteria (revenue alignment, billing complexity, customer friction, audit risk, communication simplicity) reveals workspace-flat and hybrid as the only options that score 3+ across all criteria
- The state machine for "workspace billing state" (free / trial / paid / past_due / cancelled) is identical for per-workspace and hybrid models. Per-source adds a sixth state ("metering paused") not present in the other models
- Lightweight DDD analysis suggests "workspace" is the natural billing aggregate, regardless of pricing model — even per-seat pricing is fundamentally per-workspace with a multiplier
- ADR-style documentation of the decision will be essential — this is the kind of decision that gets revisited every 9-12 months as the feature evolves
- A pre-mortem exercise (imagine it is one year later, the model failed, why?) is feasible in 30 minutes and is recommended before final commit

### Open Questions
- Should we build the billing-event-ledger pattern even for the workspace-flat model? It might be over-engineering for the simpler case
- Is there precedent for changing pricing models mid-cycle, and what does customer churn look like when teams do that?

## Agent 5: Stakeholder-Sweep (COMPLETED 2026-04-13 01:18)

### Findings
- **Pilot customers (3 of the 12 enterprise accounts agreed to be design partners)** care most about predictability of cost. Variable pricing (per-source metered) is a significant friction. They want to enable the feature broadly without billing surprises
- **Enterprise IT** at two of the pilot accounts requires per-workspace pricing visibility for their procurement systems. Per-seat creates per-user reporting they cannot easily aggregate for board-level reporting
- **End users** within customer organisations are largely indifferent to the pricing model — they care that the feature is available and works
- **Sales team** strongly prefers per-workspace or hybrid — it is easier to quote, easier to predict expansion revenue, and avoids the seat-counting negotiations that consume time in deal cycles
- **Customer success** flags that any change in pricing structure for existing customers requires careful communication. The 12 enterprise accounts have varying contractual terms, and a unilateral pricing change would damage trust
- **Finance/billing** prefers per-workspace from an operational standpoint — fewer events to reconcile, fewer audit findings, simpler revenue recognition
- **Compliance** is essentially neutral on pricing model but flags that our SOC2 audit will examine billing accuracy. Per-source metering creates the largest audit surface
- **Sales engineering** at one account has already objected to per-source pricing in a discovery call (recorded in CRM)

### Open Questions
- What is the actual structure of existing enterprise contracts — do they constrain how we can price new features?

### Stakeholder Reactions
- Strong cross-stakeholder convergence on per-workspace or hybrid models
- Cross-stakeholder conflict: sales wants pricing flexibility for deal closing; finance wants pricing predictability for forecasting

## Agent 6: Contradictions (COMPLETED 2026-04-13 01:54)

### Findings
- **Now (current phase):** The CEO's preference for "value-aligned pricing" without a concrete definition is a contradiction with the team's need to ship in six weeks. Without resolving what "value-aligned" means, every choice can be re-litigated
- **Now:** Per-seat pricing on the core product creates a contradiction with workspace-flat pricing on the new feature. Customers will ask "why is the dashboard one model when everything else is per-seat?". This is a communication contradiction, not a technical one
- **Now:** The six-week timeline contradicts the operational requirement to build a billing-event ledger if metered billing is chosen. Per-workspace ships in two weeks; per-source ships in six weeks if everything goes well, eight weeks more realistically
- **Mid (6-12 months):** The feature is announced for May 2026; the next pricing review cycle is January 2027. Whatever model we choose now, we are committed to for at least 8 months. Contradiction: we are choosing a long-cycle commitment based on incomplete data
- **Mid:** Hybrid pricing creates an enterprise upgrade path (workspace-flat for SMB, hybrid for enterprise). Pure workspace-flat does not. Contradiction with our stated intent to move upmarket in 2026
- **Long (2+ years):** EU AI Act phases will trigger if dashboards become significantly AI-augmented (next-quarter roadmap item). Per-source metering may then need to extend to AI-generated content, adding complexity. Contradiction: we are choosing a billing model that will need to extend to AI features we have not yet designed

### Open Questions
- What does "value-aligned pricing" mean to the CEO, concretely?

## Agent 7: Gap-Hunter (COMPLETED 2026-04-13 02:32)

### Findings
- **Must-fill-now: We have no willingness-to-pay data for this feature.** Every prior agent assumed pricing models perform differently in the market, but none have evidence on what our specific customers would actually pay. This is the single most expensive blind spot — choosing the model without WTP data is a coin flip dressed up as analysis
- **Must-fill-now: Customer contract structure has not been examined.** Stakeholder-Sweep flagged it; nobody followed up. If existing enterprise contracts have most-favoured-customer clauses or pricing-stability commitments, the analysis above is constrained in ways nobody documented
- **Must-fill-now: The CEO's "value-aligned pricing" preference is a non-decided constraint.** It surfaces as a gap because every recommendation defers to something the CEO has not defined. We need to either define it or explicitly note that the team will choose without it
- **Should-fill: Competitor pricing for comparable features has not been mapped.** Wildcard-Breadth gave macro patterns; nobody pulled specific competitor pricing pages for the buyer ICP
- **Should-fill: The "AI augmentation in next-quarter roadmap" surfaced in Contradictions but was not researched. If it is significant, billing model choice changes
- **Nice-to-have: Customer success team's pricing-change communication template was referenced but not produced. If we change pricing for new customers (not existing), the comms strategy still matters
- **Spawned 2 emergent agents:** (a) WTP research — surveyed comparable B2B SaaS WTP data and structured-interview templates the team can use with the 3 design-partner customers; (b) Contract structure review — surveyed common B2B contract clauses that constrain feature pricing, with a checklist

### Open Questions
- Did the spawned WTP research yield enough to act on, or do we need to interview customers ourselves?
- The contract structure review is a checklist — actually applying it to our 12 enterprise contracts is a manual step still pending

### Emergent Spawns
- WTP-research-spawn → round-1/wtp-research-OUTPUT.md → completed
- Contract-structure-spawn → round-1/contract-structure-OUTPUT.md → completed

## Agent 8: Verifier (COMPLETED 2026-04-13 02:51)

### Findings (sidecar saved to round-1/gap-hunter-OUTPUT.verifier.json)
- 6 gap claims from Gap-Hunter; 5 confirmed, 1 partial, 0 false positives, 0 unverifiable
- The "competitor pricing not mapped" claim was downgraded to `partial` — the Wildcard-Breadth output included three named competitors with pricing model mentions, but specific pricing tiers were not captured. The gap is real but smaller than the Gap-Hunter implied
- Quality signal for Gap-Hunter output: **high** (false-positive rate 0%, evidence solid, severity assignments calibrated)

### Open Questions
- None

## Agent 9: Consolidation (COMPLETED 2026-04-13 03:42)

### Findings
- Top recommendation: **per-workspace pricing for the dashboards feature, with a clear escalation path to hybrid for enterprise tier in the next pricing cycle**. Rationale: simplest billing model, lowest audit surface, best stakeholder alignment, ships in two weeks. The hybrid path preserves the option to move upmarket without committing now
- Three Must-recommendations, four Should-recommendations, one Could, two Rejected — see catalogue
- Verifier quality signal: high

### Open Questions
- The CEO's "value-aligned pricing" preference is documented as an open item requiring human decision before final commit
- WTP interviews with 3 design-partner customers are recommended but not blocking if the team is willing to commit on current evidence
