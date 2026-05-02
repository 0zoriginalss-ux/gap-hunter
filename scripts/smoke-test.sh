#!/usr/bin/env bash
# Gap-Hunter Smoke Test
#
# 5-minute dry-run that confirms terminal, paths, permissions, and Claude Code
# setup are working correctly BEFORE you launch a real overnight run.
#
# What this checks:
#   1. Required files from init.sh exist (_shared-context.md, brain.md, ORCHESTRATOR-BRIEFING.md)
#   2. The plugin scripts directory is reachable
#   3. The launch command is constructable
#   4. (Manual step) Claude Code can read _shared-context.md without errors
#
# Usage:
#   ./scripts/smoke-test.sh

set -euo pipefail

PROJECT_DIR="$(pwd)"
ERRORS=0
WARNINGS=0

echo ""
echo "Gap-Hunter Smoke Test"
echo ""

# --- Check 1: init.sh artefacts ---

echo "[1/4] Checking that init.sh artefacts are present..."

REQUIRED_FILES=(
  "_shared-context.md"
  "brain.md"
  "ORCHESTRATOR-BRIEFING.md"
  ".gap-hunter/state.json"
)

for f in "${REQUIRED_FILES[@]}"; do
  if [[ -f "$PROJECT_DIR/$f" ]]; then
    echo "    OK: $f"
  else
    echo "    MISSING: $f"
    ERRORS=$((ERRORS+1))
  fi
done

if [[ ! -d "$PROJECT_DIR/round-1" ]]; then
  echo "    MISSING: round-1/ directory"
  ERRORS=$((ERRORS+1))
else
  echo "    OK: round-1/ exists"
fi

# --- Check 2: shared-context has been edited (not still at template defaults) ---

echo ""
echo "[2/4] Checking that _shared-context.md has been customised..."

if [[ -f "$PROJECT_DIR/_shared-context.md" ]]; then
  if grep -q "(describe what phase the project is in" "$PROJECT_DIR/_shared-context.md"; then
    echo "    WARNING: _shared-context.md still contains the 'Current phase' placeholder."
    echo "             Edit it before running the pattern, or the chain will run on incomplete context."
    WARNINGS=$((WARNINGS+1))
  else
    echo "    OK: 'Current phase' placeholder has been replaced"
  fi

  if grep -q "(any project-specific guidance for the agents" "$PROJECT_DIR/_shared-context.md"; then
    echo "    OK: 'Notes for the chain' placeholder still present (acceptable — optional)"
  fi
fi

# --- Check 3: scripts are reachable ---

echo ""
echo "[3/4] Checking plugin scripts..."

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

EXPECTED_SCRIPTS=(
  "scripts/init.sh"
  "scripts/watchdog.sh"
  "scripts/resume.sh"
  "scripts/post-process.sh"
)

for s in "${EXPECTED_SCRIPTS[@]}"; do
  if [[ -f "$PLUGIN_ROOT/$s" ]]; then
    echo "    OK: $s"
  else
    echo "    MISSING: $s"
    ERRORS=$((ERRORS+1))
  fi
done

# --- Check 4: agent briefings ---

echo ""
echo "[4/4] Checking agent briefings..."

REQUIRED_AGENTS=(
  "agents/triage.md"
  "agents/wildcard-breadth.md"
  "agents/methodology.md"
  "agents/orchestration.md"
  "agents/structure.md"
  "agents/stakeholder-sweep.md"
  "agents/contradictions.md"
  "agents/gap-hunter.md"
  "agents/verifier.md"
  "agents/consolidation.md"
)

for a in "${REQUIRED_AGENTS[@]}"; do
  if [[ -f "$PLUGIN_ROOT/$a" ]]; then
    echo "    OK: $a"
  else
    echo "    MISSING: $a"
    ERRORS=$((ERRORS+1))
  fi
done

# --- Summary ---

echo ""
echo "Summary: $ERRORS errors, $WARNINGS warnings"

if (( ERRORS > 0 )); then
  echo ""
  echo "Smoke test failed. Resolve the missing files before launching a real run."
  echo "If init.sh has not been run yet, run it first:"
  echo "    $PLUGIN_ROOT/scripts/init.sh"
  exit 1
fi

# --- Manual step instructions ---

cat <<EOF

Static checks passed.

Now do the live check (2 minutes):

  1. Open a fresh terminal in this directory ($PROJECT_DIR)
  2. Run:

       claude --model opus --dangerously-skip-permissions

  3. At the prompt, type:

       Read $PROJECT_DIR/_shared-context.md and summarise it in three sentences.

  4. If the summary returns within ~30 seconds and no permission errors appear,
     your setup is verified. End the session and open a fresh terminal for the
     real run.

  5. If you see permission errors:
     - Confirm you launched with --dangerously-skip-permissions
     - Confirm no other Claude Code session is running in this directory
     - Confirm the project directory is not inside a permission-restricted parent

EOF

if (( WARNINGS > 0 )); then
  echo "Note: $WARNINGS warning(s) above. Review _shared-context.md before launching."
fi
