# Changelog

All notable changes to the Gap-Hunter Pattern.

This project follows [Semantic Versioning](https://semver.org/). Pattern versions track architectural changes, not documentation tweaks.

---

## [1.1.0] — 2026-05-03

Minor release tightening the slash-command surface so each command name maps directly to the pattern's promises. Agent behaviour is unchanged.

### Final command surface (5 commands)

| Command | What it does |
|---|---|
| `/gap-hunter:go` | The main event — full overnight research before you commit to build |
| `/gap-hunter:honestfilter` | The honest filter — checks if the pattern fits, can recommend skipping it entirely |
| `/gap-hunter:mini` | The mini version of `go` — reduced 3-agent chain when scope isn't fixed yet |
| `/gap-hunter:verify` | Reality-check after shipping one wave |
| `/gap-hunter:resume` | Continue an interrupted run |

### Changed (from v1.0.2)

| v1.0.2 | v1.1.0 |
|---|---|
| `/gap-hunter:research` | `/gap-hunter:go` |
| `/gap-hunter:scan` | `/gap-hunter:honestfilter` |
| `/gap-hunter:explore` | `/gap-hunter:mini` |
| `/gap-hunter:verify` | unchanged |
| `/gap-hunter:resume` | unchanged |
| `/gap-hunter:go` (was a pass-through dispatcher) | removed — `go` is now the main event itself |

### Why

The v1.0.2 surface mixed functional descriptors (`research`, `verify`) with a meta-router (`go`). The router added zero value (`go research` is no shorter than `research`). Two of the names didn't carry the pattern's promise — `scan` reads as "look around", but the actual function is "decide whether to commit a night to this pattern" (the **honest filter**, the differentiator). `research` is generic — every research tool runs research; what makes this one distinctive is that it's the **main event** of pre-execution decision hardening.

The 1.1.0 surface fixes both: `go` now BE the main event (one command, one launch), and `honestfilter` markets the pattern's most distinctive promise directly in the command name.

### Notes

- This rename happened within 24 hours of the v1.0 public launch. No known external users at the time of the change. Going forward, command-surface changes will require a major version bump per the policy below.
- Scripts (`init`, `post-process`) updated for the new mode names. State files written by older versions (`triage`, `explore`, `plan`, `validate`) remain readable — `post-process` recognises both old and new mode names where the validation pattern differs.

---

## [1.0.2] — 2026-05-03

Patch release renaming the slash commands for clarity. Behaviour is unchanged.

### Changed
- **Command names simplified.** Each command now describes its function directly, no `gap-hunt-` prefix:

  | Old | New |
  |---|---|
  | `/gap-hunter:gap-hunt-triage` | `/gap-hunter:scan` |
  | `/gap-hunter:gap-hunt-explore` | `/gap-hunter:explore` |
  | `/gap-hunter:gap-hunt-plan` | `/gap-hunter:research` |
  | `/gap-hunter:gap-hunt-validate` | `/gap-hunter:verify` |
  | `/gap-hunter:gap-hunt-resume` | `/gap-hunter:resume` |
  | `/gap-hunter:gap-hunt` | `/gap-hunter:go` |

- Command file descriptions rewritten to be one-line direct ("Quick check — should you run this pattern at all?" instead of "Fast diagnostic"). Autocomplete now tells you what each command does at a glance.
- README slash-command table, SKILL.md slash-command list, scripts (`init.sh`/`init.ps1`/`resume.sh`/`resume.ps1`/`post-process.sh`/`post-process.ps1`), and internal cross-references in command files updated to the new names.

State files written by older versions (`mode: triage` / `plan` / `validate`) remain readable — only the user-facing command names changed.

---

## [1.0.1] — 2026-05-02

Patch release surfacing three bugs caught during pre-public test runs (T1–T2). All were silent failures with substantive impact, hence patched before public visibility.

### Fixed
- **Triage agent: stop verifying adaptor YAML files on disk.** The agent was claiming installed adaptors (e.g. `ml-model.yaml`) were "missing" because it looked in the user's working directory instead of the plugin install path. New anti-slop rule makes the canonical adaptor list reference-only and explicitly prohibits filesystem checks. Recommended adaptor is now name-only.
- **post-process scripts: `grep -c \|\| echo 0` produced `"0\n0"` strings**, breaking arithmetic comparisons silently. Replaced with `2>/dev/null || true` plus `${VAR:-0}` defensive fallback in both `post-process.sh` and `.ps1`.
- **post-process scripts: mode-blind validation.** Strict-mode checks hardcoded plan-mode patterns (`^# ADR-`, `^### RISK-`), reporting "0 errors / 0 warnings" on explore-mode output even when validation was effectively skipped (explore produces DPRs/Trunk-Decisions, not ADRs). Both scripts now read `mode` from `.gap-hunter/state.json` and apply mode-appropriate regex.

---

## [1.0.0] — 2026-05-02

Initial public release.

### Architecture
- Sequential agent chain with append-only `brain.md` shared context
- Dedicated Gap-Hunter meta-agent for blind-spot detection
- Verifier agent with sidecar pattern for cross-validation
- Bounded emergent spawning (max 3 follow-ups, Gen 1 only)
- Persistent orchestrator plan for context-compaction resilience

### Modes
- `triage` — fast diagnostic that can recommend NOT running the pattern
- `explore` — reduced 3-agent chain for early-stage scope mapping
- `plan` — full 8-agent chain for pre-execution research
- `validate` — post-wave hardening chain with delta document output

### Agents
- Triage (single-agent diagnostic)
- Wildcard-Breadth, Methodology, Orchestration, Structure (breadth phase)
- Stakeholder-Sweep (perspectives phase)
- Contradictions, Gap-Hunter, Verifier (depth phase)
- Consolidation (synthesis phase, produces 5 artefacts)

### Adaptors
- `saas-feature` — multi-tenant SaaS feature work
- `ml-model` — model training, deployment, retraining
- `hardware` — embedded, IoT, robotics, consumer electronics
- `compliance-heavy` — healthcare, finance, regulated sectors
- `generic` — domain-agnostic fallback

### Outputs
- `integration-catalog.md` — synthesised research catalogue
- `decisions.md` — architecture decision records
- `tasks.json` — importable into Linear, GitHub Issues, Jira
- `risk-register.md` — trackable risks with owner slots
- `wave-briefings/` — execution-ready briefings

### Operational tooling
- `scripts/init.sh` and `init.ps1` — interactive setup
- `scripts/smoke-test.sh` and `smoke-test.ps1` — pre-launch verification
- `scripts/watchdog.sh` and `watchdog.ps1` — heartbeat monitor
- `scripts/resume.sh` and `resume.ps1` — state inspection for resume
- `scripts/post-process.sh` and `post-process.ps1` — artefact validation
- `dashboard.html` — single-file local live view

### Documentation
- `docs/pattern.md` — full architectural description
- `docs/anti-patterns.md` — six rejected approaches with reasoning
- `docs/extending.md` — Living brain.md, Context-Hardening Chain, multi-AI integration
- `docs/adaptors.md` — guide for writing custom adaptors
- `docs/competitive-landscape.md` — positioning analysis

---

## Roadmap

### v1.1 — Adaptive Coach (planned)

A per-user coaching agent that learns recurring blind spots over multiple runs. Reads `.gap-hunter/memory/` (false-positives, override patterns, validation outcomes) and feeds personalised priors into the Triage agent. The pattern stays the same; the system learns the user.

Designed as opt-in and local-only — consistent with the existing privacy posture.

---

## Versioning policy

- **Major (X.0.0)** — incompatible architectural changes (chain composition, output schema, mode semantics)
- **Minor (1.X.0)** — new agents, new adaptors, new modes (additive)
- **Patch (1.0.X)** — bug fixes, documentation improvements, agent briefing refinements
