---
description: Run the reduced explore-mode chain (3 agents) for early-stage scope mapping.
argument-hint: [project-name]
---

You are launching the **explore-mode chain** of the Gap-Hunter research pattern.

## What explore mode is

A reduced chain of three agents — Wildcard-Breadth, Stakeholder-Sweep, Gap-Hunter — plus the Verifier and Consolidation agents at the end. Total runtime ~1-2 hours.

This mode is for situations where scope is not yet fixed. It maps the landscape and surfaces what the user does not yet know — without committing to deep dives on specific methodologies.

## Pre-flight (mandatory)

1. Confirm `_shared-context.md` exists. If not, refuse and ask the user to write one (offer skeleton).
2. Recommend the user runs `/gap-hunt-triage` first if they have not. Allow override.
3. Create or confirm `round-N/` output directory.
4. Confirm no other Claude Code session is running in this project.
5. Initialise `brain.md` with the project header if it does not exist.
6. Initialise `.gap-hunter/state.json` for resume capability.

## Chain to execute (sequential)

Spawn each agent via the Agent tool, in this order, waiting for completion before the next:

1. **wildcard-breadth** — using `agents/wildcard-breadth.md`
2. **stakeholder-sweep** — using `agents/stakeholder-sweep.md`
3. **gap-hunter** — using `agents/gap-hunter.md`. May spawn up to 3 emergent agents.
4. **verifier** — using `agents/verifier.md`. Sidecar pattern.
5. **consolidation** — using `agents/consolidation.md`. Produces lighter integration-catalog.md focused on landscape mapping.

After each agent completes, update `.gap-hunter/state.json` with the completion status.

## Persistence

Persist the orchestrator plan to `.gap-hunter/plan.md` before starting. If the conversation context is compacted mid-run, the plan survives externally.

## Post-run

Run `scripts/post-process.sh` to generate derived artefacts:
- `decisions.md` (lighter set, since explore-mode is pre-decision)
- `tasks.json`
- `risk-register.md`
- `wave-briefings/`

Surface the integration-catalog.md path to the user.

## Anti-patterns to avoid

- Do not run all three breadth agents (Methodology, Orchestration, Structure) — that is `plan` mode, not `explore`.
- Do not skip the Verifier even if the Gap-Hunter found few gaps. The verifier confirms the few it found.
- Do not produce execution-ready briefings in explore mode. The catalogue is landscape-focused.
