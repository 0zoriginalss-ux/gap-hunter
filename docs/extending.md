# Extending the Pattern

Optional capabilities that go beyond the core chain. None are required for a successful run; each addresses a specific situation that arises in mature use of the pattern.

---

## Living `brain.md`

The chain closes the research run. `brain.md` itself does **not** close.

After Consolidation completes, the file remains append-only and open. Three append patterns surface in practice:

### Execution-agent appends
During the wave that follows the research, execution agents write findings, blockers, and deviations to the same `brain.md`. Section header convention: `## Execution Wave N — [date]`. The agent appends what changed, what was wrong, what surprised. The research artefact grows with the project.

### Operator manual appends
When you make a mid-execution decision that refers back to research, append a short note: `## Operator Note YYYY-MM-DD`. The note records what you decided and why, with a reference back to the relevant research section. Six months later this is the audit trail that explains why the architecture looks the way it does.

### Follow-up chain appends
A `validate` run appends `## Validate Run N — [date]`. A subsequent `plan` run on a follow-up question appends `## Round 2: [topic] — [date]`. The same file accumulates the project's full research history.

### The rule
**Even after Chain end, append-only still applies.** No edits. No deletions. No "cleanup". The value of the pattern depends on the audit trail being intact.

If the file becomes too long for practical reading, generate a summary file (`brain-summary.md`) and link forward — but `brain.md` itself stays whole.

---

## Context-Hardening Chain

After your first execution wave from a `plan` run, the original `integration-catalog.md` carries assumptions that have now been tested against reality. A small follow-up chain — the **Context-Hardening Chain** — reconciles the two.

This is what `validate` mode runs.

The relationship matters: **broad landscape research and detail hardening are different cognitive modes**. Combining them in the initial run dilutes both. Run the catalogue against reality first, then sharpen.

### Scope
- What did we get right? Which Must-recommendations survived?
- What did we get wrong? Which were downgraded post-execution? Which Should items turned out to be Must, and vice versa?
- What did we miss? What new contradictions surfaced during execution?

### Agents
Three to five agents, not seven. The breadth was already covered.

### Output
`integration-catalog-v2.md` formatted as a **delta document**, not a replacement. Both versions remain in the project for comparison.

### When to skip
Many projects never need it. If your first wave shipped cleanly and the catalogue's recommendations all held up, validate mode is unnecessary. The decision to run it is an honest reflection on whether you actually have new evidence to feed in.

---

## Multi-AI integration

The base pattern uses Claude only. Some teams have access to additional AI tools (Codex, GPT-5, Gemini, local models) and want to integrate them.

The pattern accommodates this **without** changing the core chain. Multi-AI lives at two specific seams:

### Adversarial review of the integration catalogue
After Consolidation produces `integration-catalog.md`, run a separate AI tool over the catalogue with an adversarial prompt: "Find weaknesses in these recommendations. Where would a hostile reviewer push back?". Capture the output as `integration-catalog-adversarial-review.md`. Compare and reconcile manually before the wave starts.

This adds a second perspective at low cost (one external call) without disturbing the chain.

### Specialised research seams
Some research questions are better handled by tools with different strengths:
- Static security analysis (Semgrep, Snyk) — feed findings into the Contradictions agent's `now` horizon
- Code-base inspection (specialised code-search tools) — feed findings into the Structure agent
- Domain-specific research (academic search tools, regulatory databases) — feed findings into the Methodology agent

The integration is always **tool produces a file → agent reads the file as input**. The chain itself stays sequential and Claude-driven.

### What to avoid
Spawning external tools mid-chain in a way that creates a critical-path dependency on an outside service. If the external tool is unavailable, the chain should still complete. External findings are inputs, not blockers.

---

## Custom adaptors

The five shipped adaptors (`saas-feature`, `ml-model`, `hardware`, `compliance-heavy`, `generic`) cover a wide range, but every project has specifics. Writing a custom adaptor is a 30-60 minute exercise. See [`adaptors.md`](adaptors.md).

---

## Custom agents

The shipped agents are opinionated. Adding a domain-specific agent (e.g. a "Cryptography Review" agent for security-critical projects, a "Localisation Review" agent for products entering new markets) is supported.

### Where to slot a new agent
Most custom agents fit between Stakeholder-Sweep and Contradictions, or between Contradictions and Gap-Hunter. They consume the chain's accumulated `brain.md` context and add a domain-specific perspective.

### What the agent must do
1. Read `brain.md` and prior agent outputs
2. Produce an output following the standard schema (Findings / Open Questions / Stakeholder Reactions if relevant)
3. Append to `brain.md` with a `## Agent N: [name] (COMPLETED)` header
4. Honour the anti-slop rules (NOT_FOUND over invention, no marketing language, evidence with quotes)

### What the agent must NOT do
- Spawn sub-agents (only Gap-Hunter has this privilege, capped at 3)
- Modify prior outputs
- Skip the brain.md append

### Testing a new agent
Run it once on a real project before adding it to the default chain. Evaluate: did it surface insight that the existing chain missed? If not, it adds cost without adding value.

---

## Context-window considerations

For very large projects, the context window can saturate during the Consolidation step (which reads everything). Mitigations:

### Persisted plan
The orchestrator persists its plan to `.gap-hunter/plan.md` after each major step. If context is compacted mid-run, the plan survives externally and resume can pick up coherently.

### Summarisation between phases
Between Phase 1 (Breadth) and Phase 2 (Perspectives), the orchestrator can write a `phase-1-summary.md` that compresses the four breadth outputs to ~500 words. Phase 2 agents read the summary as context instead of the four full outputs. The full outputs remain on disk for the Gap-Hunter and Consolidation steps.

This is opt-in — for most runs it is unnecessary.

### Splitting Consolidation
For unusually large runs, Consolidation can be split into two passes: Pass 1 produces the catalogue and the Must / Should buckets; Pass 2 produces the derived artefacts (decisions, tasks, risks, briefings). Each pass has its own context window.

---

## Pattern-level memory

Across multiple runs of the pattern on the same project (initial `plan`, then `validate`, then a second `plan` on a follow-up question), patterns emerge in the user's own blind spots. A team that consistently misses compliance considerations on its first sweep, for example, can learn to start its briefs differently.

The Gap-Hunter pattern itself does not currently formalise this learning. A directory `.gap-hunter/memory/` is reserved for future per-user pattern-evolution data — false-positive logs, validation outcomes, recurring blind-spot themes — which would let later runs adjust their priors.

This is a roadmap item, not a v1.0 feature.
