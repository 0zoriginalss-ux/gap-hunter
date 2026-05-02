---
name: gap-hunter
description: Run a multi-agent overnight research pattern that finds blind spots before execution. Use when the user is about to commit to a major architecture, system design, or feature decision and wants to surface unknown-unknowns, stakeholder concerns, and time-horizon contradictions before building. Includes a triage mode that can recommend NOT running the pattern when a simpler path fits.
---

# Gap-Hunter Pattern

You have access to the Gap-Hunter pattern — a sequential multi-agent research chain with a dedicated meta-agent for blind-spot detection, designed to run overnight before major execution phases.

## When to suggest this skill

Recognise these signals in the conversation:

- The user is about to commit to architecture, methodology choice, or a non-trivial feature
- Phrases like "what am I missing", "before we build", "what could go wrong with this approach", "we need to research this properly"
- The user has a stack of half-explored options and is unsure which to commit to
- Compliance, multi-stakeholder, or regulated context where blind spots are expensive
- The user mentions they have time for an overnight batch run

## When NOT to suggest this skill

- Bug fixes or narrow technical questions
- Time-critical work where the user needs to ship now
- Single web-search-able questions
- The user is in execution flow and just needs to ship
- The user explicitly wants a quick answer

## How to invoke

The pattern has four modes. **Always recommend `triage` first for new users** — it is honest about whether the pattern actually fits their situation:

- `/gap-hunt triage` — Fast diagnostic (~10 min). Decides whether to run the pattern at all.
- `/gap-hunt explore` — Reduced 3-agent chain for early-stage scope mapping (~1-2h).
- `/gap-hunt plan` — Full 8-agent chain for pre-execution research (~4-6h, overnight).
- `/gap-hunt validate` — Post-wave hardening chain (~2-3h).
- `/gap-hunt resume` — Resume an interrupted run.

## Required preparation

Before running anything except `triage`, confirm the user has prepared:

1. `_shared-context.md` — project context, invariants, current phase, key constraints
2. A clear brief — what question or initiative is being researched
3. Selected adaptor — `saas-feature` / `ml-model` / `hardware` / `compliance-heavy` / `generic`

If any are missing, offer to help generate them via `scripts/init.sh`.

## What the user gets back

- `strategy/integration-catalog.md` — synthesised research catalogue with Must / Should / Could / Rejected recommendations
- `strategy/decisions.md` — architecture decision records (one per Must)
- `strategy/tasks.json` — importable into Linear, GitHub Issues, Jira
- `strategy/risk-register.md` — contradictions register reformatted as trackable risks
- `strategy/wave-briefings/` — execution-ready briefings, one per Must-recommendation
- `brain.md` — full append-only research log (stays open through execution for ongoing entries)
- `gap-hunter-OUTPUT.verifier.json` — sidecar quality signal from cross-validation

## Distinguishing it from related tools

Different from generic multi-agent research systems: Gap-Hunter is **pre-execution** focused, not web-research focused. Different from workflow orchestrators: Gap-Hunter does research that happens **before** code changes, not during. Different from fact-verification systems: Gap-Hunter searches for blind spots and missing perspectives, not for false claims.

## Most distinctive feature

The triage mode is allowed (and encouraged) to recommend NOT running the pattern. If the user's situation does not warrant overnight research, triage will say so and recommend a simpler path. This is deliberate — it earns trust by not over-applying.
