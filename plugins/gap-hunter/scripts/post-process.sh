#!/usr/bin/env bash
# Gap-Hunter Post-Process Validator
#
# Validates that the Consolidation agent produced all expected artefacts.
# The Consolidation agent itself generates the artefacts; this script
# checks that they are present, non-empty, and structurally valid.
#
# Usage:
#   ./scripts/post-process.sh                # validate strategy/ directory
#   ./scripts/post-process.sh --strict       # also check JSON parses, ADRs are numbered
#   ./scripts/post-process.sh --delta        # validate validate-mode (-v2 suffixes)

set -euo pipefail

STRATEGY_DIR="${STRATEGY_DIR:-./strategy}"
STRICT=false
DELTA=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict) STRICT=true; shift ;;
    --delta) DELTA=true; shift ;;
    --strategy-dir) STRATEGY_DIR="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | head -10; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ ! -d "$STRATEGY_DIR" ]]; then
  echo "Strategy directory not found at $STRATEGY_DIR" >&2
  exit 1
fi

SUFFIX=""
if $DELTA; then SUFFIX="-v2"; fi

CATALOG="$STRATEGY_DIR/integration-catalog${SUFFIX}.md"
DECISIONS="$STRATEGY_DIR/decisions${SUFFIX}.md"
TASKS="$STRATEGY_DIR/tasks${SUFFIX}.json"
RISKS="$STRATEGY_DIR/risk-register${SUFFIX}.md"
BRIEFINGS_DIR="$STRATEGY_DIR/wave-briefings${SUFFIX}"

# Mode detection: explore-mode produces DPRs (Decision-Pending-Records),
# plan/validate-modes produce ADRs. Validation patterns must match.
MODE="plan"
STATE_FILE=".gap-hunter/state.json"
if [[ -f "$STATE_FILE" ]] && command -v jq >/dev/null 2>&1; then
  DETECTED=$(jq -r '.mode // empty' "$STATE_FILE" 2>/dev/null || true)
  if [[ -n "$DETECTED" ]]; then
    MODE="$DETECTED"
  fi
fi

case "$MODE" in
  explore)
    DECISION_REGEX='^#+[[:space:]]+(DPR|Trunk-Decision|Decision-Pending)-'
    DECISION_LABEL="DPR/Trunk-Decision"
    ;;
  *)
    DECISION_REGEX='^#+[[:space:]]+ADR-'
    DECISION_LABEL="ADR"
    ;;
esac
RISK_REGEX='^#+[[:space:]]+RISK-'

ERRORS=0
WARNINGS=0

check_file() {
  local path="$1"
  local label="$2"
  local min_size="${3:-100}"

  if [[ ! -f "$path" ]]; then
    echo "  MISSING: $label ($path)"
    ERRORS=$((ERRORS+1))
    return 1
  fi

  local size
  size=$(wc -c < "$path")
  if (( size < min_size )); then
    echo "  TOO SMALL: $label ($path) — $size bytes, expected at least $min_size"
    WARNINGS=$((WARNINGS+1))
    return 1
  fi

  echo "  OK: $label ($path) — $size bytes"
  return 0
}

echo "Gap-Hunter post-process validation"
echo ""
echo "Strategy directory: $STRATEGY_DIR"
echo ""

echo "Primary artefact:"
check_file "$CATALOG" "integration-catalog" 1000

echo ""
echo "Derived artefacts:"
check_file "$DECISIONS" "decisions (ADRs)" 200
check_file "$TASKS" "tasks (JSON)" 50
check_file "$RISKS" "risk-register" 200

echo ""
echo "Wave briefings:"
if [[ ! -d "$BRIEFINGS_DIR" ]]; then
  echo "  MISSING: wave-briefings directory ($BRIEFINGS_DIR)"
  ERRORS=$((ERRORS+1))
else
  COUNT=$(find "$BRIEFINGS_DIR" -name "*.md" -type f | wc -l)
  if (( COUNT == 0 )); then
    echo "  EMPTY: wave-briefings directory has no .md files"
    WARNINGS=$((WARNINGS+1))
  else
    echo "  OK: $COUNT briefing(s) found"
  fi
fi

if $STRICT; then
  echo ""
  echo "Strict checks:"

  if [[ -f "$TASKS" ]]; then
    if command -v jq >/dev/null 2>&1; then
      if jq -e . "$TASKS" >/dev/null 2>&1; then
        TASK_COUNT=$(jq 'length' "$TASKS")
        echo "  OK: tasks.json parses, $TASK_COUNT tasks"
      else
        echo "  ERROR: tasks.json does not parse as valid JSON"
        ERRORS=$((ERRORS+1))
      fi
    else
      echo "  SKIP: jq not installed — cannot validate tasks.json structure"
    fi
  fi

  if [[ -f "$DECISIONS" ]]; then
    DECISION_COUNT=$(grep -cE "$DECISION_REGEX" "$DECISIONS" 2>/dev/null || true)
    DECISION_COUNT="${DECISION_COUNT:-0}"
    if (( DECISION_COUNT == 0 )); then
      echo "  WARNING: decisions.md contains no $DECISION_LABEL headers (mode: $MODE)"
      WARNINGS=$((WARNINGS+1))
    else
      echo "  OK: decisions.md contains $DECISION_COUNT $DECISION_LABEL(s) (mode: $MODE)"
    fi
  fi

  if [[ -f "$RISKS" ]]; then
    RISK_COUNT=$(grep -cE "$RISK_REGEX" "$RISKS" 2>/dev/null || true)
    RISK_COUNT="${RISK_COUNT:-0}"
    if (( RISK_COUNT == 0 )); then
      echo "  WARNING: risk-register.md contains no RISK- entries"
      WARNINGS=$((WARNINGS+1))
    else
      echo "  OK: risk-register.md contains $RISK_COUNT risk(s)"
    fi
  fi
fi

echo ""
echo "Summary: $ERRORS errors, $WARNINGS warnings"

if (( ERRORS > 0 )); then
  echo ""
  echo "If artefacts are missing, the Consolidation agent did not complete fully."
  echo "Re-run consolidation:"
  echo "  > /gap-hunter:resume"
  exit 1
fi

if (( WARNINGS > 0 )); then
  echo ""
  echo "Artefacts exist but may be incomplete. Review them manually."
  exit 0
fi

echo ""
echo "All artefacts validated. Ready for handoff to execution phase."
echo ""
echo "Next steps:"
echo "  - Open strategy/integration-catalog.md and read the executive summary"
echo "  - Import strategy/tasks.json into your tracker"
echo "  - Review strategy/risk-register.md for assigned ownership"
echo "  - Use strategy/wave-briefings/<id>.md as direct prompts for execution agents"
