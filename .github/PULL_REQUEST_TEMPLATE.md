## What this changes

<!-- One paragraph. What does this PR do, concretely? -->

## Why

<!-- The problem this solves or the value it adds. -->

## Type of change

- [ ] Bug fix
- [ ] Documentation
- [ ] New example run
- [ ] Adaptor addition or refinement
- [ ] Agent briefing refinement
- [ ] New agent (requires prior issue discussion)
- [ ] New mode or architectural change (requires prior issue discussion)

## Design principles affected

<!-- The pattern preserves five principles. Indicate any this PR touches:

  1. Adaptivity in a single dedicated meta-agent
  2. Sequential composition for compounding insight
  3. Append-only shared state
  4. Bounded recursion
  5. Honest filters (triage can say "no")

  Mark with [x] any principle this change strengthens, weakens, or restructures.
  If you mark "weakens", justify the trade-off in the description below. -->

- [ ] (1) Adaptivity in a single dedicated meta-agent
- [ ] (2) Sequential composition for compounding insight
- [ ] (3) Append-only shared state
- [ ] (4) Bounded recursion
- [ ] (5) Honest filters

## How this was tested

<!-- For documentation changes: not applicable.
     For everything else: describe the test. Smoke test? Full run? Validate against an example?

     Pattern changes that have not been run end-to-end at least once will not be merged. -->

## What you considered and rejected

<!-- For non-trivial changes: list one or two alternatives you considered and rejected,
     with reasoning. This mirrors the pattern's own design discipline (see docs/anti-patterns.md). -->

## Linked issue

<!-- Closes #NNN -->

## Checklist

- [ ] I have read [`CONTRIBUTING.md`](../CONTRIBUTING.md)
- [ ] My change does not violate any of the five design principles, or the trade-off is justified above
- [ ] Documentation is updated where relevant
- [ ] If a new agent or adaptor: example run is included or referenced
- [ ] If a pattern change: discussed in an issue before this PR
