# Contributing to Gap-Hunter Pattern

Thank you for considering a contribution. This document keeps the project's design discipline intact while making it easy to add value.

## Before contributing

Read these first:
- [`README.md`](README.md) — what the pattern is and is not
- [`docs/pattern.md`](docs/pattern.md) — the full architectural description
- [`docs/anti-patterns.md`](docs/anti-patterns.md) — six approaches that were tried and rejected, with reasoning

The pattern is **deliberately small**. It will stay small. Most contributions add depth, not breadth — better adaptors, better documentation, better examples, sharper agent briefings. Adding agents, modes, or commands requires strong justification.

## Types of contribution

### Bug fixes
Always welcome. Open an issue first if the bug is non-trivial; small fixes can go straight to PR.

### Documentation improvements
Always welcome. Documentation that helps a new user reach a successful run faster is high value.

### New adaptors
Welcome if the adaptor is domain-general (not company-specific). See [`docs/adaptors.md`](docs/adaptors.md). Include an example run in `examples/` showing the adaptor in use.

### Better example runs
Welcome. Examples are how potential users decide whether the pattern fits. A high-quality anonymised real run is more valuable than three synthetic ones.

### New agents
Requires discussion. Open an issue using the **Pattern Variation** template before writing code. Most domain-specific perspectives are better served by the existing Stakeholder-Sweep with a custom adaptor than by a new agent.

### New modes
Strongly resist this. Four modes (triage / explore / plan / validate) cover the situations that arise. Adding a fifth dilutes the user's mental model.

### Architectural changes to the chain
Requires discussion and a clear win over the current design. The existing design is the result of rejecting five alternatives — see [`docs/anti-patterns.md`](docs/anti-patterns.md). Make your case.

## Design principles to preserve

When evaluating a proposed change, the maintainers will check it against these principles. If the change weakens any of them, the bar for accepting it is high.

1. **Adaptivity lives in a single dedicated meta-agent.** Not in the orchestrator's rule engine. Not in distributed coordination. The Gap-Hunter exists for this reason.
2. **Sequential composition for compounding insight.** Parallelism is reserved for genuinely independent work, not for splitting research questions.
3. **Append-only shared state.** A single `brain.md`. No multi-file message passing. No file locks.
4. **Bounded recursion.** Hard caps on emergent spawning, runtime, and agent count.
5. **Honest filters.** The triage mode is allowed (and encouraged) to recommend NOT running the pattern.

A change that violates a principle is not automatically rejected — but it must be argued for explicitly, with the trade-offs made visible.

## Development workflow

### Setting up

```bash
git clone https://github.com/0zoriginalss-ux/gap-hunter
cd gap-hunter
# No build step. The plugin is markdown, YAML, and shell scripts.
```

### Running locally

Test changes by running the pattern on a small example. The smoke test (5-minute dry run) verifies your local installation works:

```bash
./scripts/init.sh                    # generate test setup
claude --model opus --dangerously-skip-permissions
> Read _shared-context.md and summarise it in three sentences.
```

If the summary returns without errors, your local plugin works.

### Testing changes to agents

Edit the agent briefing in `agents/<agent>.md`. Run the pattern in `triage` mode to test the change without a full overnight run. If the change affects only one agent, you can run that agent in isolation by spawning it manually:

```
claude --model opus --dangerously-skip-permissions
> Read agents/<your-agent>.md and execute it as your task. Use _shared-context.md and brain.md as context.
```

## Pull request guidelines

### Before opening a PR

- Open an issue first for non-trivial changes
- Run the smoke test locally
- For adaptor or example contributions, include an example run that demonstrates the change

### PR description

Use the [pull request template](.github/PULL_REQUEST_TEMPLATE.md). Explain:

1. What the change does
2. Which design principle it touches (if any)
3. What you considered and rejected (mirror the anti-patterns section)
4. How you tested it

### What gets fast-tracked

- Documentation fixes
- Typo fixes
- New examples that follow the established structure
- Adaptor refinements (additions to existing adaptors)

### What gets discussed first

- New agents
- New modes
- Architectural changes
- New adaptors (initial version)

## Code of conduct

Be direct, be specific, be honest. The maintainers will treat you the same way.

If you disagree with a maintainer's decision, argue the substance. If the disagreement persists, the maintainers' decision stands and you are welcome to fork — that is what MIT is for.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
