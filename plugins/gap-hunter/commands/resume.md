---
description: Continue an interrupted run from the last completed agent.
argument-hint: [project-name]
---

You are resuming an interrupted Gap-Hunter run.

## When this is needed

A run can be interrupted by:
- Rate limit hit
- Network failure
- Manual cancellation
- Agent crash
- Context window saturation

Without resume, the user loses the entire run. With resume, the orchestrator picks up at the next pending agent.

## Pre-flight (mandatory)

1. **State file required.** Confirm `.gap-hunter/state.json` exists. If not, refuse — there is nothing to resume.
2. **brain.md required.** Confirm `brain.md` exists with at least one completed agent section. If not, the original run did not produce any state worth resuming — recommend starting fresh.
3. **Confirm chain mode.** Read from `.gap-hunter/state.json` which mode was running (explore / plan / validate). The resume must continue in the same mode.
4. **Plan persistence.** Read `.gap-hunter/plan.md` for the orchestrator plan if context was compacted.

## State file schema

`.gap-hunter/state.json`:

```json
{
  "version": "1.0",
  "mode": "explore | plan | validate",
  "adaptor": "<adaptor id>",
  "round": <integer>,
  "started_at": "YYYY-MM-DDTHH:MM:SSZ",
  "last_updated_at": "YYYY-MM-DDTHH:MM:SSZ",
  "completed_agents": [
    { "id": "wildcard-breadth", "completed_at": "...", "output_path": "..." },
    ...
  ],
  "pending_agents": ["methodology", "orchestration", ...],
  "emergent_spawns": [
    { "id": "...", "spawned_by": "gap-hunter", "completed": false }
  ],
  "last_checkpoint": "<agent id>"
}
```

## Resume logic

1. Load `state.json`
2. Determine the next pending agent based on the chain order for the recorded mode
3. Verify the prior agent's output file exists and is non-empty
4. If verification fails for the last completed agent, mark it as failed and re-run that agent before proceeding
5. Continue the chain from the next pending agent
6. Update `state.json` after each agent completes

## Special cases

### Gap-Hunter was interrupted mid-spawn
If `state.json` shows the Gap-Hunter completed but emergent spawns are incomplete:
- Inspect each emergent spawn's output path
- Resume the incomplete ones
- Do not allow new spawns (the Gap-Hunter already finalised its decision)

### Verifier was interrupted
If the Verifier was interrupted, re-run from scratch (Verifier is single-pass and cheap to redo).

### Consolidation was interrupted
If Consolidation was running when interrupted, re-run it. Consolidation is idempotent over the same inputs.

### State file is corrupt
If `state.json` cannot be parsed, surface the error to the user and offer:
- Manual reconstruction from `brain.md` (slower but possible)
- Fresh restart (loses progress)

## Anti-patterns to avoid

- Do **not** re-run already-completed agents unless their output files are missing or invalid.
- Do **not** silently start a fresh run if state is corrupt. Surface the issue and let the user decide.
- Do **not** change the chain mode mid-resume. If the user wants a different mode, they should start a new run.
- Do **not** modify `brain.md` in place during resume. Append-only still applies.
