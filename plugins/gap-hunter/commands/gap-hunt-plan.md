---
description: Run the full plan-mode chain (8 agents + verifier + consolidation, with bounded emergent spawning).
argument-hint: [project-name]
---

You are launching the **plan-mode chain** of the Gap-Hunter research pattern. This is the canonical, full-depth mode.

## What plan mode is

The full sequential chain of eight research agents, followed by the Verifier (cross-checks Gap-Hunter output) and Consolidation (produces integration-catalog.md plus four derived operational artefacts).

Total runtime: ~4-6 hours. Designed for overnight execution.

## Pre-flight (mandatory — these are not optional)

1. **Smoke test recommended.** Before launching the full run, recommend the user runs the smoke test (5-minute dry-run that confirms terminal, paths, permissions). Skip only if user explicitly confirms setup is verified.
2. **Triage report recommended.** If no recent `triage-report.md` exists, recommend running `/gap-hunt-triage` first. Allow override.
3. **`_shared-context.md` required.** Refuse if missing. Offer skeleton generation.
4. **Adaptor selected.** Confirm which adaptor (`saas-feature` / `ml-model` / `hardware` / `compliance-heavy` / `generic`) — load from `adaptors/<id>.yaml`.
5. **Project architecture document referenced** for the Contradictions agent. If missing, surface as a warning but allow proceeding (the agent will operate on `_shared-context.md` alone with reduced quality).
6. **Output directory** `round-N/` created with write permissions.
7. **No other Claude Code session** running in this project (race condition prevention on `brain.md`).
8. **`.gap-hunter/state.json` initialised** for resume capability.
9. **`.gap-hunter/plan.md` written** with the orchestrator's plan for this run (survives context compaction).
10. **Watchdog optional.** Recommend launching `scripts/watchdog.sh` in a separate terminal during overnight runs.

## Chain to execute (sequential, with state tracking)

Spawn each agent via the Agent tool, waiting for completion before the next. After each, update `.gap-hunter/state.json`.

**Phase 1: Breadth**
1. **wildcard-breadth** — `agents/wildcard-breadth.md`
2. **methodology** — `agents/methodology.md`
3. **orchestration** — `agents/orchestration.md`
4. **structure** — `agents/structure.md`

**Phase 2: Perspectives**
5. **stakeholder-sweep** — `agents/stakeholder-sweep.md`

**Phase 3: Depth**
6. **contradictions** — `agents/contradictions.md`
7. **gap-hunter** — `agents/gap-hunter.md`. May spawn up to 3 emergent agents (Gen 1 only).
8. **verifier** — `agents/verifier.md`. Sidecar pattern — never modifies Gap-Hunter output.

**Phase 4: Consolidation**
9. **consolidation** — `agents/consolidation.md`. Reads everything including verifier sidecar.

## Quality gates between agents

After each agent completes, validate:
- Output file exists at expected path
- Output meets minimum length (~300 words for research agents, schema check for verifier)
- `brain.md` was appended with the agent's mandatory section

If validation fails: re-run the agent **once** with stricter briefing. If second run also fails: hard-fail with clear log entry, do not silently proceed.

## Verifier handling

The Verifier produces `gap-hunter-OUTPUT.verifier.json`. If `gap_hunter_quality_signal.score == "low"`:
- Surface this prominently to the user before running the Consolidation agent
- Recommend human review of the Gap-Hunter output before proceeding
- Allow the user to defer Consolidation until they have reviewed

## Post-run

Run `scripts/post-process.sh` to generate:
- `strategy/decisions.md` (architecture decision records, one per Must-recommendation)
- `strategy/tasks.json` (importable into Linear / GitHub Issues / Jira)
- `strategy/risk-register.md` (contradictions register reformatted)
- `strategy/wave-briefings/` (one execution-ready briefing per Must-recommendation)

Surface the paths to all five artefacts to the user (catalogue + four derived).

## Anti-patterns to avoid

- Do **not** spawn agents in parallel. The chain depends on sequential context-sharing through `brain.md`.
- Do **not** skip the Verifier even if Gap-Hunter output looks good. Quality gate is non-negotiable.
- Do **not** silently override the verifier's `low` quality signal.
- Do **not** allow Gen 2 spawning — emergent agents may not spawn further agents.
- Do **not** modify any prior agent's output. All agent outputs are append-only or sidecar.
