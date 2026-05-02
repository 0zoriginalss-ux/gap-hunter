# Adaptors Guide

An adaptor is a YAML file that pre-populates domain-specific defaults for a research run — stakeholder lists, methodology focus, contradiction-detection emphasis, and source-quality filters. It is the difference between every run starting from zero and every run starting from the right rough position for its domain.

Five adaptors ship with the pattern. Writing your own takes ~30 minutes and dramatically improves output quality for your specific context.

---

## When to write a custom adaptor

You should write a custom adaptor if any of these apply:

- Your domain is not well represented by the five shipped adaptors
- Your team runs the pattern repeatedly on similar projects (an adaptor amortises across runs)
- Your stakeholder list, methodology focus, or contradiction emphasis is materially different from the shipped defaults
- Your source-quality preferences are domain-specific (e.g. you trust certain regulators, distrust certain analyst firms)

You should **not** write a custom adaptor if:

- You will run the pattern only once or twice on this domain
- The `generic` adaptor produces good results already
- Your domain is genuinely a mix and no single adaptor fits — use `generic` and let the agents handle the diversity

---

## Adaptor structure

```yaml
adaptor:
  id: <kebab-case identifier>
  name: <Human-readable name>
  description: <One-paragraph what this adaptor is for>

stakeholders:
  default:
    - id: <stakeholder_id>
      lens: "<one-sentence what this stakeholder cares about>"
  optional:
    - id: <stakeholder_id>
      lens: "<one-sentence what this stakeholder cares about>"
      include_if: "<concrete condition>"

methodology_focus:
  emphasise:
    - <methodology_id>
  deprioritise:
    - <methodology_id>

contradiction_emphasis:
  now: ["<contradiction theme>", ...]
  mid: ["<contradiction theme>", ...]
  long: ["<contradiction theme>", ...]

default_mode_recommendation: triage | explore | plan | validate

structure_techniques_likely_relevant:
  - <technique_id>

source_quality_filters:
  prefer:
    - <source_category>
  avoid:
    - <source_category>
```

---

## Section-by-section guidance

### `stakeholders.default`

The stakeholders the Stakeholder-Sweep agent always considers for this domain. Aim for 6-9 — fewer misses key perspectives, more dilutes attention.

The `lens` is the most important field. Write it as a short sentence that captures what the stakeholder is **actually** evaluating against, not what they nominally do. "Compliance officer" is a role; "evidence generation, control framework mapping, audit-readiness" is a lens.

### `stakeholders.optional`

Stakeholders included only when a condition fires. The `include_if` field is read by the orchestrator and surfaced to the user during `init`.

Examples:
- `include_if: "Project handles personal data of EU residents"` — DPO triggers
- `include_if: "Healthcare, criminal justice, employment, or other high-stakes domain"` — ethics board triggers
- `include_if: "Selling into EU or jurisdictions with environmental hardware regulation"` — environmental compliance triggers

Keep conditions concrete. Vague conditions ("project is regulated") force the user to interpret; concrete conditions ("project handles personal data of EU residents") are decidable.

### `methodology_focus`

Two lists. `emphasise` tells the Methodology agent which framework families to dig into first. `deprioritise` tells it which families are unlikely to be relevant for this domain (so the agent does not spend research budget on them).

Use methodology IDs that map to recognisable categories — `feature_flag_management`, `model_card_documentation`, `failure_mode_and_effects_analysis`. The agent infers the specifics; you point it at the right neighbourhood.

### `contradiction_emphasis`

Three time horizons (`now`, `mid`, `long`), each a list of themes the Contradictions agent should pay attention to for this domain. These are hints, not constraints — the agent will surface contradictions outside these themes if they appear.

Themes are short noun phrases: "Tenant isolation in new feature vs. existing RLS policies", "Drift detection threshold vs. retraining cost". Specific enough to direct attention, general enough to apply across projects in the domain.

### `default_mode_recommendation`

What the Triage agent suggests as the starting mode for this domain when other axes are inconclusive. For most domains, `plan` is correct.

### `structure_techniques_likely_relevant`

Pre-loaded list of structure techniques the Structure agent should evaluate first. Same pattern as methodology focus — point the agent at the right neighbourhood.

### `source_quality_filters`

What kinds of sources to trust and distrust. The agents read this when deciding which web search results to weigh. Keep entries categorical, not specific URLs:

- Prefer: `peer_reviewed_papers`, `engineering_blogs_with_concrete_data`, `regulatory_authority_guidance`, `incident_reports`
- Avoid: `vendor_marketing_pages`, `generic_listicles`, `paywalled_analyst_reports_without_excerpt`

If your domain has trust signals that are not category-level (e.g. "trust this specific regulator's bulletins, distrust this specific vendor's whitepapers"), document them in your shared-context, not the adaptor. Adaptors should generalise.

---

## Validating a new adaptor

Before adding a new adaptor to your team's standard set:

### 1. Run it against an existing decision
Pick a project decision your team made in the last 6-12 months. Write a `_shared-context.md` that reflects what you knew at the time. Run the pattern with your new adaptor in `plan` mode.

Compare the recommendations to the decision your team actually made. Did the catalogue surface concerns you ended up wishing you had considered? Did it miss concerns that turned out to matter?

### 2. Run it against a current decision
Use the new adaptor on a real upcoming decision. After the first wave ships, run `validate` mode. The validate output is the strongest signal of whether the adaptor's emphasis was right.

### 3. Iterate
If the adaptor consistently misses a stakeholder, add them. If it overweighs a methodology that turns out to be irrelevant, deprioritise. Adaptors evolve; treat the file as living.

---

## Sharing your adaptor

If your adaptor would help others, contribute it back. PR against the repository with:

1. The `adaptors/<your-adaptor>.yaml` file
2. An example run in `examples/<your-domain-example>/` showing the adaptor in use
3. A short addition to the README's adaptor table

Adaptors should be domain-general, not company-specific. If your adaptor encodes "we use Tool X and only Tool X", that is shared-context, not an adaptor. The adaptor should help any team in the domain.

---

## Common mistakes

### Stakeholders that are roles, not lenses

Bad:
```yaml
- id: ceo
  lens: "Strategic alignment"
```

Good:
```yaml
- id: ceo
  lens: "Whether this aligns with the current quarter's narrative to the board, and whether it consumes engineering capacity that was promised elsewhere"
```

### Methodology focus that is too generic

Bad:
```yaml
emphasise:
  - best_practices
  - good_documentation
```

Good:
```yaml
emphasise:
  - feature_flag_management
  - tenant_aware_logging
  - billing_metering
```

### Contradiction emphasis that is too aspirational

Bad:
```yaml
long:
  - "future-proofing"
  - "scalability"
```

Good:
```yaml
long:
  - "AI Act high-risk classification triggers"
  - "Quantum-readiness of cryptographic choices"
  - "Vendor lock-in cost when migrating to alternative providers"
```

The agents work from concrete prompts. Vague themes produce vague output.

---

## Examples to reference

The five shipped adaptors illustrate different emphases:

- [`adaptors/saas-feature.yaml`](../adaptors/saas-feature.yaml) — multi-tenant concerns, billing, customer tiers
- [`adaptors/ml-model.yaml`](../adaptors/ml-model.yaml) — data, eval methodology, ethics, drift
- [`adaptors/hardware.yaml`](../adaptors/hardware.yaml) — supply chain, certification, manufacturing reality
- [`adaptors/compliance-heavy.yaml`](../adaptors/compliance-heavy.yaml) — control mapping, audit trail, evidence
- [`adaptors/generic.yaml`](../adaptors/generic.yaml) — minimal opinionation as a fallback
