# The Gap-Hunter Pattern

> A multi-agent research strategy that finds the blind spots before you build them.

## TL;DR

Before any major execution phase, there is a research gap. The naive approach (one prompt, one agent) is too shallow; the over-engineered approach (parallel agent armies, trigger rules, blackboard coordination) collapses under its own complexity.

**Gap-Hunter is the middle ground.** A sequential chain of specialised research agents shares context through a single append-only file (`brain.md`). At the end of the chain, a dedicated **meta-agent — the Gap-Hunter** — explicitly searches for missed topics, unanswered questions, and contradictions, then spawns a bounded number of follow-up agents to close the highest-severity gaps.

**Core insight:** adaptivity does not belong in the orchestrator (where it becomes complex and bug-prone), but in a dedicated single-responsibility meta-agent.

The pattern produces an `integration-catalog.md` plus three derived artefacts (`decisions.md`, `risk-register.md`, `wave-briefings/`) that hand off cleanly into your next execution phase — no manual synthesis needed.

---

## The Problem

You are about to start a non-trivial piece of work — a feature, an architectural decision, a system migration. You suspect there are unknowns: methodologies you have not considered, stakeholder perspectives you have not anticipated, regulatory shifts you have not priced in, contradictions between decisions you have already made.

**You have three options:**

1. **Skip the research.** Build, then re-build when you discover what you missed. The default. Often expensive.
2. **Run a single deep prompt.** "Tell me everything I should know about X." Returns a generic, surface-level list. Misses the interesting blind spots — the ones that don't surface unless you ask the right follow-up.
3. **Build a parallel agent army.** Spawn fifteen agents with persona simulations, blackboard coordination, multi-file message passing. Spend a week debugging race conditions. Get marginally better output than option 2.

Gap-Hunter is option 4: structured enough to surface the blind spots, simple enough to run in a single overnight batch with `--dangerously-skip-permissions`.

---

## The Four Modes

The pattern is not one-size-fits-all. Different situations call for different depths.

### `triage` — Should you even run this?

A single fast agent (~10 minutes) reads your brief and project context, scores it on five axes, and recommends a mode — including the recommendation **not to run the full pattern at all**.

**Use when:** you are unsure whether your situation warrants the overhead, or you are new to the pattern and want guidance.

**Output:** `triage-report.md` with mode recommendation, suggested adaptor, pre-populated stakeholder list, and alternative paths if the pattern is overkill.

The triage agent is explicitly allowed (and encouraged) to recommend simpler paths: a single web search, a single deep prompt, splitting your question, or talking to a human expert.

### `explore` — Before you have decided scope

A reduced chain (3 agents: Wildcard-Breadth, Stakeholder-Sweep, Gap-Hunter) maps the landscape and surfaces what you do not yet know.

**Use when:** you are at the very beginning of an initiative — the question itself is still fuzzy, and you need to know what questions to ask before committing to a direction.

**Output:** lighter `integration-catalog.md` focused on landscape mapping and stakeholder reactions, no execution-ready briefings yet.

### `plan` — Before execution

The full chain (8 agents + bounded emergent spawning + verifier + consolidation). This is the canonical mode.

**Use when:** scope is clear, you are about to commit to architecture or build, and the cost of being wrong is significant.

**Output:** full `integration-catalog.md` with execution-ready briefings, contradictions register across three time horizons, decision records, risk register, importable task list.

### `validate` — After your first execution wave

A small follow-up chain (3-4 agents) focused on the delta between what the original research recommended and what reality actually showed.

**Use when:** you have shipped your first wave from a `plan` run and want to harden assumptions before the next wave.

**Output:** `integration-catalog-v2.md` as a delta document, not a replacement.

---

## The Architecture

### Terminal setup

A single terminal running an orchestrator that sequentially spawns sub-agents through the Agent tool. The orchestrator stays "dumb" — it follows the chain. The intelligence lives in the agents themselves, especially the meta-agents.

```bash
claude --model opus --dangerously-skip-permissions
```

Launch prompt — one sentence, **not** the briefing content itself:

```
Read <PATH>/ORCHESTRATOR-BRIEFING.md and execute it as your initial task.
```

**Why a read pattern, not a paste pattern.** Orchestrator briefings reach 15k+ tokens with embedded sub-agent briefings. Pasting that into the main terminal burns context and triggers token warnings. Reading the briefing on demand lets the orchestrator pass sub-agent briefings directly through the Agent tool — without ever holding the full content in its own context window.

### Pre-flight smoke test (mandatory)

Before the real run, a 5-minute test confirms the setup works.

1. Start the terminal as above
2. Prompt: `Read <PATH>/_shared-context.md and summarise it in three sentences.`
3. If you get a summary and no permission errors → setup is good
4. End the session, close the terminal
5. Open a fresh terminal for the real run

This prevents the failure mode of discovering a permission or path issue three hours into the run. Costs effectively nothing, saves the night.

### The chain (full `plan` mode)

**Phase 1 — Breadth**

1. **Wildcard-Breadth** — Ultra-wide question ("What is the state of the art in [domain] in [month/year]?"), no narrowing, maps the landscape.
2. **Methodology** — Deep dive into the well-known frameworks and pattern sets in your domain.
3. **Orchestration** — How others combine multiple AI tools intelligently for similar work.
4. **Structure** — Pre-implementation mapping techniques (state machines, flow diagrams, lightweight DDD, etc.).

**Phase 2 — Perspectives**

5. **Stakeholder-Sweep** — A single agent covers all relevant stakeholder perspectives in one output (compliance, legal, pilot customer, enterprise IT, end user, competitor, etc.). Deliberately **not** six separate persona agents — see anti-patterns.

**Phase 3 — Depth**

6. **Contradictions** — Identifies conflicts across three time horizons:
   - **Now** (current phase): architecture lock-ins that will break later, tooling decisions with migration cost
   - **Mid** (6-12 months): scaling contradictions, enterprise-upgrade path conflicts
   - **Long** (2+ years): regulatory drift, business-model contradictions

7. **Gap-Hunter** *(the core innovation)*:
   - Reads ALL prior outputs + `brain.md` + the contradictions output
   - Explicitly searches for:
     - Topics nobody addressed (blind spots)
     - Open questions in `brain.md` that remained unanswered
     - Inconsistencies between agent outputs
     - Stakeholder perspectives nobody anticipated
     - Tools and techniques mentioned multiple times but never explored in depth
   - Outputs a gap list with severity (**must-fill-now / should-fill / nice-to-have**)
   - **Spawns up to 3 follow-up agents** for must-fill-now gaps (Gen 1 only — no recursive spawning)
   - Should-fill and nice-to-have are documented in the final catalogue as "known open gaps"

8. **Verifier** *(quality gate)*:
   - Reads the Gap-Hunter output and cross-checks every claimed gap against `brain.md`
   - Flags false positives — gaps that are not actually gaps
   - Prevents the failure mode where the Gap-Hunter hallucinates issues to justify spawning follow-ups

**Phase 4 — Consolidation**

9. **Consolidation** — Pulls all outputs (initial + emergent) into the final `integration-catalog.md` with seven sections:
   1. Technique catalogue
   2. Adoption-filter check (invariants / slot-fit / pilot-run, see below)
   3. Contradictions register (three time horizons)
   4. Stakeholder digest
   5. Top recommendations bucketed as Must / Should / Could / Rejected, each with an execution-ready briefing
   6. Emergent-spawn log: "what we almost forgot"
   7. Methodology log: lessons learned for the next iteration of the chain

A post-process step then derives `decisions.md` (architecture decision records), `tasks.json` (importable into your project tracker), and `risk-register.md` from the catalogue.

---

## Shared Context: `brain.md`

A single append-only file, sectioned by agent:

```markdown
# Research Brain — [Project Name]

## Agent 1: Wildcard-Breadth (COMPLETED YYYY-MM-DD HH:MM)
### Findings
- ...
### Open Questions
- ...

## Agent 2: Methodology (COMPLETED)
### Findings
- ...
### Open Questions
- ...
### Stakeholder Reactions (if relevant)
- ...
```

Every agent:
- **Reads `brain.md` at the start** (as context)
- **Writes at the end** in three mandatory sections: `Findings` / `Open Questions` / `Stakeholder Reactions` (when relevant)

**One file, sequential writes, zero race conditions.** No multi-file blackboard, no file locks, no message-queue protocol.

### Living `brain.md` (after the chain ends)

The chain closes the research run, but `brain.md` itself does **not** close. It stays append-only and open for:

- **Execution agents** during the wave that follows (they append findings, blockers, deviations)
- **You, manually**, when decisions during execution refer back to research
- **Follow-up research chains** (e.g. a `validate` run) as an extension entry

The artefact grows with the project, stays auditable, and late decisions remain retrospectively traceable. Research is a snapshot; reality emerges during execution. A living `brain.md` closes that gap.

**Rule:** even after the chain ends, append-only still applies. No edits, no deletions.

---

## The Adoption Filter

Every technique that survives the research must pass three checks before adoption — so integration is woven, not bolted on.

### 1. Invariants

Does the technique violate a non-negotiable system invariant — append-only audit, RLS isolation, TDD requirement, file-length limits, framework constraints? If yes → reject, regardless of how clever the technique is.

### 2. Slot-fit

Does the technique fit into an existing slot in the system (pre-commit pipeline, design-spec phase, review pipeline)? If yes → adopt. If no → honestly evaluate whether a new slot is justified or whether you would just be adding redundancy.

### 3. Pilot-run

Test the technique once in a real wave before promoting it to the standard process. **No process change based on theoretical reasoning alone.** Did it work? Did it slow things down? Did it break something else?

---

## Bounded Recursion: Guard-Rails

Without limits, any system that allows emergent spawning will explode. The limits:

| Limit | Value | Why |
|---|---|---|
| Max agent count | 12 (8 initial + 3 emergent + 1 consolidation) | Overnight runnable, budget-controllable |
| Max runtime | 6 hours | Overnight reality |
| Spawn depth | 1 generation | Gap-Hunter spawns Gen 1; Gen 1 agents do not spawn further |
| Output quality gate | Schema check + minimum length | One re-run on failure, then hard-fail with clear log |
| Modes | 4 (triage / explore / plan / validate) | Match depth to situation |

### Resume capability

The pattern writes a state file (`.gap-hunter/state.json`) tracking which agents have completed. On crash or rate-limit interruption, `resume` skips completed agents and continues. No lost nights.

### Watchdog

A heartbeat script monitors `brain.md` modification time. If the file is stale for more than 30 minutes (no agent has written), it fires a system notification. The most common silent failure (an agent hangs while the orchestrator waits) becomes visible.

---

## Anti-Patterns: What was rejected and why

### 1. Parallel agent army without a chain

**Idea:** eight agents in parallel, maximum time savings.
**Problem:** no learning effect between agents, redundant research (every agent re-investigates the basics), the orchestrator cannot calibrate between outputs.
**Replaced by:** sequential chain with `brain.md` context-sharing.

### 2. Six separate persona agents (stakeholder theatre)

**Idea:** one agent per persona — compliance officer, GDPR lawyer, pilot customer, enterprise IT, works council, competitor.
**Problem:** the model plays self-invented roles; the differences between outputs are marginal. More theatre than insight. Costs ×6 with little upside.
**Replaced by:** a single Stakeholder-Sweep agent that covers all perspectives in one output.

### 3. Divergence-then-convergence phase split

**Idea:** three divergence agents (broad) → synthesis → four convergence agents (narrow).
**Problem:** sounds clean, operationally produces no measurable quality difference. A single agent can move from divergent to convergent on its own.
**Replaced by:** Wildcard-Breadth as agent 1, focused research from agent 2 onward.

### 4. Five-trigger rule engine for emergent spawning

**Idea:** an orchestrator with detailed conditional rules ("if X then spawn Y").
**Problem:** too many guard-rails create bugs. The orchestrator can decide on its own. More importantly, rules never cover all the emergent cases.
**Replaced by:** Gap-Hunter as a dedicated meta-agent with a single clear responsibility (adaptivity = single-responsibility agent).

### 5. Full blackboard coordination (multi-file messaging)

**Idea:** `questions-queue.md` + `answers-log.md` + `brain.md` as a message-passing protocol between parallel terminals.
**Problem:** file-lock chaos, race conditions, debugging nightmare. There is no native file watcher in the runtime. Protocol design overhead exceeds the benefit.
**Replaced by:** a single append-only `brain.md` in a sequential chain.

### 6. Integrating external multi-agent tools mid-run

**Idea:** swarm-intelligence tools for "better" stakeholder simulation, plugged into the chain.
**Problem:** setup overhead dwarfs the gain. If the tool fails mid-run, the night is lost. Most such tools simulate opinions from seed text — structured hallucination, not external fact.
**Replaced by:** in-chain Stakeholder-Sweep. External tools remain optional and isolated, never on the critical research path.

---

## When to use — and when not to

### Use when

- You are about to commit to a major execution phase (architecture, system design, significant feature)
- The unknown-unknowns risk is high (new domain, new technology combination, regulated context)
- You have time for an overnight batch (this is not a real-time tool)
- The cost of being wrong on the upcoming decision is meaningful

### Do **not** use when

- The change is small and the scope is clear
- The bug fix is time-critical (no research phase fits)
- The research question is narrow enough for a single web search and a single deep prompt
- You are in execution flow and just need to ship

The triage mode exists precisely to make this judgement for you when you are unsure.

---

## From Research to Execution

After the consolidation agent produces `integration-catalog.md`, the post-process step generates four derived artefacts:

- **`decisions.md`** — architecture decision records, one per Must-recommendation. Each ADR is self-contained: context, decision, consequences, alternatives considered.
- **`tasks.json`** — structured task list, importable into Linear, GitHub Issues, Jira, or any tracker that accepts JSON. One task per Must / Should item with priority, dependencies, and adoption-filter notes.
- **`risk-register.md`** — the contradictions register reformatted as trackable risks with owner slots, severity, and mitigation options.
- **`wave-briefings/`** — one execution-ready briefing per Must-recommendation. Each briefing is a complete sub-agent prompt: goal, scope, invariants, dependencies. You can paste it directly into a fresh terminal and start an execution wave.

These four outputs make the research **operational**, not just informational. The pattern is designed to replace the manual synthesis step that usually sits between research and execution.

---

## Glossary

- **Brain orchestrator** — the main terminal instance that thinks strategically and spawns sub-agents, but does no execution work itself.
- **Sub-agent** — a Claude process spawned through the Agent tool with isolated context and a single defined task.
- **Append-only file** — a file modified only by adding new lines or sections, never by overwriting existing content. Eliminates race conditions and prevents information loss.
- **Emergent spawn** — a sub-agent spawned at runtime by another agent (here: the Gap-Hunter), not present in the initial plan.
- **Adoption filter** — a three-pass evaluation grid for foreign techniques (invariants / slot-fit / pilot-run). Prevents foreign-body integration.
- **Stakeholder-Sweep** — a single agent that covers all relevant stakeholder perspectives in one output, instead of one agent per stakeholder. The anti-persona-theatre pattern.
- **Living `brain.md`** — the shared context file remains open after the research chain ends. Execution agents and the operator continue appending so the artefact grows with the project.
- **Wave briefing** — an execution-ready prompt derived from a Must-recommendation. Self-contained: goal, scope, invariants, dependencies. Drops directly into an execution sub-agent.
- **Smoke test** — a 5-minute dry run before the real orchestrator launch. Verifies terminal, paths, and permissions before a night is at stake.
- **Adaptor** — a domain configuration (SaaS feature / ML model / hardware / compliance-heavy / generic) that pre-populates stakeholder lists, methodology focus, and compliance domains for the run.

---

## Why the pattern works

Three design principles do most of the work:

### 1. Single responsibility for adaptivity

The orchestrator is "dumb" — it executes the chain. The Gap-Hunter is "smart" — it finds what is missing. This separation prevents rule-engine bugs and keeps the orchestrator simple enough to actually run reliably.

### 2. Sequentiality beats parallelism for compounding insight

Agent N has the outputs of agents 1 through N-1 as input. This enables refinement, deduplication, and build-up. Parallelism saves wall time but loses these compositional effects entirely.

### 3. Append-only beats distributed state

A single `brain.md` as shared context eliminates race conditions, file locks, and protocol-design overhead. The blackboard pattern is powerful, but not without infrastructure cost — and that cost is rarely justified for an overnight batch.
