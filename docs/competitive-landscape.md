# Competitive Landscape

Snapshot of comparable tools and patterns in the multi-agent research space, with positioning analysis. Maintained as part of the project so positioning stays grounded as the ecosystem evolves.

## Direct competitors

### HadiFrt20/deepresearch
- **Type:** Claude Code plugin, autonomous overnight, multi-agent
- **Adoption:** small (very recent)
- **Architecture:** 80-120 atomic micro-tasks, 4 subagents (researcher, adversary, planner, evaluator), 7 commands
- **Core innovation:** Adversarial Verification — every factual claim is attacked by a dedicated adversary agent, claims that survive get a trust score, sidecar pattern preserves original outputs
- **Use-case focus:** Fact research and provenance ("is this claim true? what is the source?")
- **Output:** `final-report.md` + `provenance-chain.json`

**Difference to Gap-Hunter:** DeepResearch asks "is X true?" — Gap-Hunter asks "what are we missing entirely?". Different axis. The adversary attacks claims; the gap-hunter searches for blind spots. Complementary, not replacing.

### barkain/claude-code-workflow-orchestration
- **Type:** Claude Code plugin
- **Adoption:** moderate
- **Focus:** Workflow orchestration for implementation, **not research**
- **Architecture:** 8 specialised agents (tech-lead, codebase-analyzer, code-reviewer, etc.), Plan-Mode integration, Wave synchronisation, two execution modes (subagent / team)

**Difference to Gap-Hunter:** Different use-case. Workflow-orchestration drives code changes; Gap-Hunter drives research that happens **before** code changes.

## Indirect competitors / overlapping concepts

### Anthropic's official Multi-Agent Research System
- **Architecture:** Lead-agent + 3-5 parallel subagents
- **Performance:** 90.2% better than single-agent Opus on internal evals; reduces research time up to 90%
- **Verification:** LLM-as-Judge + human review + dedicated citation agent
- **Critical caveat:** ~15x token consumption vs. chat — economically viable only for high-value tasks

**Difference to Gap-Hunter:** Anthropic's system is **web-search research** ("research X for me"). Gap-Hunter is **pre-execution research** ("what am I missing before I build?"). Anthropic produces an output for user consumption. Gap-Hunter produces a briefing for the next execution phase.

### Karpathy's AutoResearch Pattern
- **Architecture:** Iterative eval-driven self-improvement, pass-rate tracking, prompt mutation, auto-improve loops overnight
- **Focus:** improving an agent's behaviour over many runs

**Difference to Gap-Hunter:** AutoResearch improves the *tool itself* iteratively via evals. Gap-Hunter produces a research artefact for a single concrete project. Different domain.

### wshobson/agents (large agent collection)
- **Adoption:** very high — the established library in this space
- **Content:** 184 agents across 25 categories, 16 workflow-orchestrators, "Conductor Plugin" for Context→Spec→Plan→Implement

**Difference to Gap-Hunter:** Buffet vs. menu. wshobson is a collection — the user assembles their own pattern. Gap-Hunter delivers an opinionated, documented pattern with anti-patterns. Complementary.

## Capability matrix

| Capability | Gap-Hunter | DeepResearch | Anthropic Native | Workflow-Orch |
|---|---|---|---|---|
| Triage mode ("should you run this?") | ✓ | ✗ | ✗ | ✗ |
| Gap-Hunter meta-agent (blind-spot search) | ✓ | ✗ | ✗ | ✗ |
| Anti-patterns as core documentation | ✓ | ✗ | ✗ | ✗ |
| Adoption filter (3-pass) | ✓ | ✗ | ✗ | ✗ |
| Living shared-context post-research | ✓ | ✗ | ✗ | ✗ |
| Stakeholder-sweep (1 agent vs. N personas) | ✓ | n/a | n/a | n/a |
| Operational derived artefacts (decisions/tasks/risks/briefings) | ✓ (4) | partial (1) | partial | n/a |
| Phase-based modes (triage/explore/plan/validate) | ✓ | execution-modes | adaptive | 2 modes |
| Adversarial fact verification | ✗ (by design) | ✓ | partial | ✗ |
| Self-improvement cycle | ✗ | ✓ | ✗ | ✗ |
| Web research orientation | secondary | primary | primary | n/a |
| Pre-execution research orientation | primary | n/a | n/a | n/a |

## What we adopt from competitors

**From DeepResearch:**
1. **Sidecar pattern for Verifier output** — original agent output stays untouched, verifier writes alongside in `*.verifier.json`. Clean audit trail.
2. **JSON-schema validation for agent outputs** — beyond a length check. Schema per agent type. One re-run on schema violation, then hard-fail.
3. **"NOT_FOUND over invention"** — explicit anti-hallucination rule across all agent briefings.

**From Anthropic Native:**
4. **Persistent orchestrator plan** — when context exceeds 200k and gets compacted, the plan must survive externally. Stored in `.gap-hunter/plan.md`.
5. **Citation-agent as optional step** — for adaptors that emphasise sourcing (compliance-heavy especially).
6. **Token-cost transparency** — be honest about overhead in the docs.

**From Workflow-Orchestration:**
7. **Two-stage decomposition** (planning before execution) — already partially in `init`, made explicit.

## What we deliberately do NOT adopt

**Adversarial verification (DeepResearch).** Tempting, but wrong use-case. Adversaries attack factual claims; pre-execution research is about methodology choice, stakeholder coverage, architecture trade-offs — there is no objective "truth" to attack. Adopting this would distort the verifier into something that fights ghosts.

**Self-improvement cycle (Karpathy / DeepResearch).** Improve-loops require many repetitions with measurable evals. A single pre-execution research run on a concrete project has no automatable eval baseline.

**184-agent buffet (wshobson).** We deliberately ship an opinionated pattern with documented rationale, not a library. More agents = less clarity about the core insight.

## Positioning

| Tool | Promises | We promise |
|---|---|---|
| DeepResearch | "Here are the verified facts" | "Here are the gaps in your plan" |
| Anthropic Native | "Deeper research" | "Pre-execution research with operational output" |
| AutoResearch | "Self-improving agent" | "One-shot run with immediately usable output" |
| Workflow-Orchestration | "Orchestrate your code changes" | "Ask the right questions before the code changes" |

**Differentiator most likely to drive adoption:** the triage mode. No other tool ships with an honest "you might not need me" filter. That earns trust faster than feature breadth ever could.

## Sources

- HadiFrt20/deepresearch — github.com/HadiFrt20/deepresearch
- Anthropic Engineering Blog — anthropic.com/engineering/multi-agent-research-system
- MindStudio AutoResearch Analysis — mindstudio.ai/blog/karpathy-autoresearch-pattern-claude-code-skills
- barkain/claude-code-workflow-orchestration — github.com/barkain/claude-code-workflow-orchestration
- wshobson/agents — github.com/wshobson/agents
- Anthropic Multi-Agent Sessions Docs — platform.claude.com/docs/en/managed-agents/multi-agent
