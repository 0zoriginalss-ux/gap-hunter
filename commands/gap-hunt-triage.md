---
description: Fast diagnostic — should you run the Gap-Hunter pattern, and which mode fits?
argument-hint: [project-name]
---

You are launching the **Triage agent** for the Gap-Hunter research pattern.

## Inputs to gather

1. The user's brief — what question or initiative do they want researched? If they did not provide one with the command, ask now in one sentence.
2. `_shared-context.md` — project context. If it does not exist, ask the user whether to:
   - Skip it (triage will be less informed but possible)
   - Generate a skeleton based on a few questions
   - Cancel until shared-context is written
3. Any prior `triage-report.md` in the project — if it exists and is recent (last 7 days), inform the user and ask whether to re-run or use the existing report.

## Pre-flight (mandatory)

Before invoking the agent:
- Confirm the working directory is correct
- Create `round-1/` if it does not exist (or `round-N/` for the next round if prior rounds exist)
- Confirm no other Claude Code session is running in this project

## Invocation

Spawn the Triage agent via the Agent tool, using the briefing at `agents/triage.md`. Pass:
- The user's brief
- Path to `_shared-context.md` (if exists)
- Path to prior `triage-report.md` (if exists)
- Adaptor configuration if pre-selected by user (otherwise the agent will recommend one)

The Triage agent should complete in approximately 10 minutes. Wait for completion.

## Post-run

When the Triage agent returns:

1. Read the generated `triage-report.md`
2. Surface the recommendation prominently to the user:
   - If `do-not-run` → present the recommended alternative path and stop
   - If `plan` / `explore` / `validate` → ask the user whether to proceed with that mode now, defer, or override
3. If proceeding, route to the appropriate `/gap-hunt-<mode>` command, passing the triage report as a hint

## Anti-patterns to avoid

- Do **not** silently default to running the pattern. The triage agent is allowed to recommend NOT running.
- Do **not** override the agent's recommendation without surfacing it to the user.
- Do **not** invoke other agents in parallel during triage. Triage is single-agent and fast.
