---
description: Reality-check after shipping one wave. Reconciles research assumptions with what actually happened.
argument-hint: [project-name]
---

You are launching the **validate-mode chain** of the Gap-Hunter research pattern.

## What validate mode is

A small follow-up chain (3-5 agents) that runs **after** the user has shipped at least one execution wave from a prior `plan` run. It reconciles the original research assumptions with what reality actually showed during execution, and produces a delta catalogue (`integration-catalog-v2.md`) — not a replacement.

Total runtime: ~2-3 hours.

## Pre-flight (mandatory)

1. **Prior `plan` run required.** Confirm `strategy/integration-catalog.md` exists from a prior `plan` run. Refuse if missing — validate mode without prior research has nothing to validate against.
2. **Living brain.md present.** Confirm `brain.md` exists and has been appended to during execution (look for sections after the original Consolidation completion). If `brain.md` was not appended during execution, validate mode will be less useful — surface this as a warning.
3. **Execution wave actually completed.** Ask the user to confirm at least one Must-recommendation from the original catalogue has been shipped. If nothing has shipped, validate is premature — recommend deferring.
4. **`_shared-context.md` updated.** Recommend the user updates the shared-context to reflect what changed during the wave.
5. **Output directory** `round-N+1/` created (next round number after the original `plan` run).

## Chain to execute (sequential)

Spawn each agent in order. Each agent's briefing is the same as in `plan` mode, but with the explicit instruction to focus on **delta** — what changed, what was wrong, what needs revisiting.

1. **wildcard-breadth (delta)** — focus on what is new in the landscape since the original run, especially anything that contradicts the original recommendations.
2. **contradictions (delta)** — re-evaluate the contradictions register from the original run. Which materialised during execution? Which turned out to be non-issues? What new contradictions emerged?
3. **gap-hunter** — search specifically for gaps that surfaced during execution. May spawn up to 2 emergent agents (reduced from 3 in plan mode).
4. **verifier** — sidecar over the new gap-hunter output.
5. **consolidation (delta)** — produces `strategy/integration-catalog-v2.md` formatted as a **delta document**, not a replacement. Sections:
   - What we got right (Must-recommendations that survived)
   - What we got wrong (downgraded or rejected post-execution)
   - What we missed (new Must / Should items)
   - Updated contradictions register
   - Updated risk register

## Persistence

- Append to existing `brain.md` — do not start a new file. Section header: `## Validate Run N — [date]`.
- Persist plan to `.gap-hunter/plan.md` (overwrite previous plan).
- Update `.gap-hunter/state.json` with validate-run completion.

## Post-run

Run `scripts/post-process.sh --delta` to generate:
- `strategy/decisions-v2.md` (delta over previous decisions)
- `strategy/tasks-v2.json`
- `strategy/risk-register-v2.md`
- `strategy/wave-briefings-v2/`

The original artefacts are **not overwritten**. Both versions remain available for comparison.

## Anti-patterns to avoid

- Do **not** run the full plan-mode chain. Validate is intentionally scoped down.
- Do **not** overwrite the original `integration-catalog.md`. Always produce a `-v2` delta document.
- Do **not** run validate without execution evidence. The pattern needs reality-feedback to validate against.
- Do **not** spawn 3 emergent agents — validate caps at 2 (reduced budget for a smaller chain).
