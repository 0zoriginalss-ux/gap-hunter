#!/usr/bin/env bash
# Gap-Hunter Resume Helper
#
# Inspects .gap-hunter/state.json and reports what would be resumed.
# The actual resume is orchestrated by the /gap-hunt-resume slash command;
# this script provides a quick state inspection for the user.
#
# Usage:
#   ./scripts/resume.sh                  # show resume status
#   ./scripts/resume.sh --json           # raw JSON output
#   ./scripts/resume.sh --validate       # also validate output files exist for completed agents

set -euo pipefail

STATE_FILE="${STATE_FILE:-./.gap-hunter/state.json}"
JSON_OUTPUT=false
VALIDATE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON_OUTPUT=true; shift ;;
    --validate) VALIDATE=true; shift ;;
    --state) STATE_FILE="$2"; shift 2 ;;
    -h|--help)
      grep '^#' "$0" | head -10
      exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ ! -f "$STATE_FILE" ]]; then
  echo "No state file found at $STATE_FILE" >&2
  echo "Nothing to resume. Start a fresh run with: ./scripts/init.sh" >&2
  exit 1
fi

if $JSON_OUTPUT; then
  cat "$STATE_FILE"
  exit 0
fi

# Pretty output requires jq for clean parsing; fall back to grep if missing
if command -v jq >/dev/null 2>&1; then
  MODE=$(jq -r '.mode' "$STATE_FILE")
  ADAPTOR=$(jq -r '.adaptor' "$STATE_FILE")
  STARTED=$(jq -r '.started_at' "$STATE_FILE")
  LAST_UPDATE=$(jq -r '.last_updated_at' "$STATE_FILE")
  COMPLETED_COUNT=$(jq -r '.completed_agents | length' "$STATE_FILE")
  PENDING_COUNT=$(jq -r '.pending_agents | length' "$STATE_FILE")
  LAST_CHECKPOINT=$(jq -r '.last_checkpoint // "none"' "$STATE_FILE")

  echo "Gap-Hunter run state"
  echo "  Mode: $MODE"
  echo "  Adaptor: $ADAPTOR"
  echo "  Started: $STARTED"
  echo "  Last update: $LAST_UPDATE"
  echo "  Last checkpoint: $LAST_CHECKPOINT"
  echo ""
  echo "  Completed agents ($COMPLETED_COUNT):"
  jq -r '.completed_agents[] | "    - \(.id) (\(.completed_at))"' "$STATE_FILE"
  echo ""
  echo "  Pending agents ($PENDING_COUNT):"
  jq -r '.pending_agents[] | "    - \(.)"' "$STATE_FILE"

  if $VALIDATE; then
    echo ""
    echo "  Validating output files for completed agents..."
    INVALID=0
    while IFS= read -r path; do
      if [[ -f "$path" && -s "$path" ]]; then
        echo "    OK: $path"
      else
        echo "    MISSING or EMPTY: $path"
        INVALID=$((INVALID+1))
      fi
    done < <(jq -r '.completed_agents[].output_path' "$STATE_FILE")

    if (( INVALID > 0 )); then
      echo ""
      echo "  WARNING: $INVALID completed agent(s) have missing or empty output files."
      echo "  Resume will need to re-run those agents."
    fi
  fi

  echo ""
  echo "To resume the run:"
  echo "  claude --model opus --dangerously-skip-permissions"
  echo "  > /gap-hunt resume"
else
  echo "jq not installed - showing raw state:"
  cat "$STATE_FILE"
fi
