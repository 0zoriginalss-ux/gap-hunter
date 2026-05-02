---
description: Run the Gap-Hunter research pattern. Routes to triage / explore / plan / validate based on argument.
argument-hint: <triage|explore|plan|validate|resume> [project-name]
---

You are routing a Gap-Hunter pattern invocation. The user passed: `$ARGUMENTS`.

## Routing logic

Parse the first token of `$ARGUMENTS`:

- **`triage`** → invoke `/gap-hunt-triage` with the remaining arguments
- **`explore`** → invoke `/gap-hunt-explore` with the remaining arguments
- **`plan`** → invoke `/gap-hunt-plan` with the remaining arguments
- **`validate`** → invoke `/gap-hunt-validate` with the remaining arguments
- **`resume`** → invoke `/gap-hunt-resume` with the remaining arguments
- **No argument or unknown argument** → show the menu below and ask which mode to use

## Menu (when no valid mode argument)

If the user did not specify a clear mode, present this menu and ask which fits:

```
Gap-Hunter Pattern — choose a mode:

triage    — Should you run this pattern? Fast diagnostic (~10 min). Recommended for new users.
explore   — Before scope is fixed. Reduced 3-agent chain (~1-2h).
plan      — Before execution. Full 8-agent chain with emergent spawning (~4-6h).
validate  — After your first execution wave. Hardening chain (~2-3h).
resume    — Continue an interrupted run.

Not sure? Run: /gap-hunt triage
```

After the user picks a mode, route to the appropriate sub-command.

## Pre-flight checks (before routing to any mode)

Before launching any mode, confirm:

1. The user has prepared `_shared-context.md` (project context, invariants, current phase). If not, ask them to write one or offer to generate a skeleton.
2. The output directory `round-N/` exists or can be created.
3. For modes other than `triage`: a recent triage report exists, OR the user has explicitly confirmed they want to skip triage.
4. Any other Claude Code sessions in this project are closed (prevents race conditions on `brain.md`).

If any pre-flight check fails, surface it before launching. Do not silently proceed.
