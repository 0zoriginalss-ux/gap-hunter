---
description: Auto-pick the right mode for your situation. Routes to scan / explore / research / verify / resume based on argument.
argument-hint: <scan|explore|research|verify|resume> [project-name]
---

You are routing a Gap-Hunter pattern invocation. The user passed: `$ARGUMENTS`.

## Routing logic

Parse the first token of `$ARGUMENTS`:

- **`scan`** → invoke `/gap-hunter:scan` with the remaining arguments
- **`explore`** → invoke `/gap-hunter:explore` with the remaining arguments
- **`research`** → invoke `/gap-hunter:research` with the remaining arguments
- **`verify`** → invoke `/gap-hunter:verify` with the remaining arguments
- **`resume`** → invoke `/gap-hunter:resume` with the remaining arguments
- **No argument or unknown argument** → show the menu below and ask which mode to use

## Menu (when no valid mode argument)

If the user did not specify a clear mode, present this menu and ask which fits:

```
Gap-Hunter Pattern — choose a mode:

scan      — Should you run this pattern at all? Quick check (~10 min). Recommended for new users.
explore   — Scope isn't fixed yet. Reduced 3-agent chain (~1-2h).
research  — Scope is locked, time to commit. Full 8-agent chain with emergent spawning (~4-6h).
verify    — After your first execution wave. Reality-check chain (~2-3h).
resume    — Continue an interrupted run.

Not sure? Run: /gap-hunter:scan
```

After the user picks a mode, route to the appropriate sub-command.

## Pre-flight checks (before routing to any mode)

Before launching any mode, confirm:

1. The user has prepared `_shared-context.md` (project context, invariants, current phase). If not, ask them to write one or offer to generate a skeleton.
2. The output directory `round-N/` exists or can be created.
3. For modes other than `scan`: a recent triage report exists, OR the user has explicitly confirmed they want to skip the scan.
4. Any other Claude Code sessions in this project are closed (prevents race conditions on `brain.md`).

If any pre-flight check fails, surface it before launching. Do not silently proceed.
