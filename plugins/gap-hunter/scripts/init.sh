#!/usr/bin/env bash
# Gap-Hunter Pattern — interactive setup
#
# Generates shared-context.md, ORCHESTRATOR-BRIEFING.md, brain.md skeleton,
# and state file for a new run. Designed to bring a new user from zero to
# launch-ready in under 5 minutes.
#
# Usage:
#   ./scripts/init.sh                 # interactive
#   ./scripts/init.sh --domain saas   # skip domain question, use named adaptor
#   ./scripts/init.sh --quiet         # use defaults silently (advanced)

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$(pwd)"

# ---------- Helpers ----------

prompt() {
  local label="$1"
  local default="${2:-}"
  local response
  if [[ -n "$default" ]]; then
    read -r -p "$label [$default]: " response
    echo "${response:-$default}"
  else
    read -r -p "$label: " response
    echo "$response"
  fi
}

choose() {
  local label="$1"
  shift
  local options=("$@")
  echo "$label" >&2
  local i=1
  for opt in "${options[@]}"; do
    echo "  $i) $opt" >&2
    i=$((i+1))
  done
  local pick
  read -r -p "Choice (1-${#options[@]}): " pick
  if [[ ! "$pick" =~ ^[0-9]+$ ]] || (( pick < 1 || pick > ${#options[@]} )); then
    echo "Invalid choice." >&2
    return 1
  fi
  echo "${options[$((pick-1))]}"
}

# ---------- Greeting ----------

cat <<'EOF'

  Gap-Hunter Pattern — Interactive Setup

  This will generate the files needed to launch a research run.
  Estimated time: 3-5 minutes.

  Tip: if you are unsure whether to run the pattern at all,
  start with /gap-hunter:honestfilter instead — it will tell you honestly.

EOF

# ---------- Project name ----------

PROJECT_NAME="$(prompt "Project name (used in shared-context header)" "$(basename "$PROJECT_DIR")")"

# ---------- Brief ----------

echo ""
echo "Briefly describe what you want researched (2-3 sentences):"
echo "(Press Ctrl-D when done)"
BRIEF="$(cat)"

if [[ -z "$BRIEF" ]]; then
  echo "Brief is empty. Setup cannot proceed." >&2
  exit 1
fi

# ---------- Adaptor selection ----------

echo ""
ADAPTOR="$(choose "Pick the adaptor closest to your project:" \
  "saas-feature" \
  "ml-model" \
  "hardware" \
  "compliance-heavy" \
  "generic")"

ADAPTOR_FILE="$PLUGIN_ROOT/adaptors/$ADAPTOR.yaml"
if [[ ! -f "$ADAPTOR_FILE" ]]; then
  echo "Adaptor file not found: $ADAPTOR_FILE" >&2
  exit 1
fi

# ---------- Mode preference ----------

echo ""
MODE="$(choose "Which mode do you intend to run?" \
  "go (the main event — full pre-execution chain, ~4-6h overnight)" \
  "honestfilter (unsure if you should run at all? this decides for you, ~10 min)" \
  "mini (scope is open, reduced chain, ~1-2h)" \
  "verify (post-wave reality check, requires prior go run)")"
MODE="${MODE%% *}"

# ---------- System invariants ----------

echo ""
echo "List up to 5 system invariants (non-negotiables) for this project."
echo "Examples: 'append-only audit log required', 'GDPR-compliant', 'must support SSO'"
echo "One per line. Press Ctrl-D when done."
INVARIANTS="$(cat)"

# ---------- Stakeholders override ----------

echo ""
echo "The $ADAPTOR adaptor pre-populates these stakeholders:"
grep -A 1 '^  default:' "$ADAPTOR_FILE" | grep '    - id:' | sed 's/    - id: /  - /' || true
echo ""
read -r -p "Add additional stakeholders? (comma-separated, or empty to skip): " EXTRA_STAKEHOLDERS

# ---------- Output paths ----------

ROUND_DIR="$PROJECT_DIR/round-1"
GH_DIR="$PROJECT_DIR/.gap-hunter"
STRATEGY_DIR="$PROJECT_DIR/strategy"

mkdir -p "$ROUND_DIR" "$GH_DIR" "$STRATEGY_DIR"

# ---------- Generate _shared-context.md ----------

cat > "$PROJECT_DIR/_shared-context.md" <<EOF
# Shared Context — $PROJECT_NAME

**Date initialised:** $(date +%Y-%m-%d)
**Adaptor:** $ADAPTOR
**Intended mode:** $MODE

## Brief

$BRIEF

## System invariants

$INVARIANTS

## Stakeholders

Pre-populated from adaptor: \`$ADAPTOR\` (see \`$ADAPTOR_FILE\`)

Additional stakeholders for this project:
$([[ -n "$EXTRA_STAKEHOLDERS" ]] && echo "$EXTRA_STAKEHOLDERS" | tr ',' '\n' | sed 's/^/- /' || echo "(none)")

## Current phase

(describe what phase the project is in — discovery / planning / execution / validation)

## Project architecture document

(path to architecture doc if one exists, otherwise omit)

## Notes for the chain

(any project-specific guidance for the agents — e.g. "we have already rejected Tool X for reason Y, do not re-suggest it")
EOF

echo ""
echo "Generated: _shared-context.md"

# ---------- Generate brain.md ----------

cat > "$PROJECT_DIR/brain.md" <<EOF
# Research Brain — $PROJECT_NAME

**Initialised:** $(date '+%Y-%m-%d %H:%M')
**Mode:** $MODE
**Adaptor:** $ADAPTOR

This file is **append-only**. Every agent in the chain appends a section.
After the chain completes, this file remains open during execution for
ongoing findings, blockers, and deviations.

---

EOF

echo "Generated: brain.md (empty, ready for first agent)"

# ---------- Generate state.json ----------

cat > "$GH_DIR/state.json" <<EOF
{
  "version": "1.0",
  "mode": "$MODE",
  "adaptor": "$ADAPTOR",
  "round": 1,
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "last_updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "completed_agents": [],
  "pending_agents": [],
  "emergent_spawns": [],
  "last_checkpoint": null
}
EOF

echo "Generated: .gap-hunter/state.json"

# ---------- Generate ORCHESTRATOR-BRIEFING.md ----------

cat > "$PROJECT_DIR/ORCHESTRATOR-BRIEFING.md" <<EOF
# Orchestrator Briefing — $PROJECT_NAME

**Mode:** $MODE
**Adaptor:** $ADAPTOR
**Initialised:** $(date '+%Y-%m-%d %H:%M')

## Your task

You are the orchestrator for a Gap-Hunter pattern run in **$MODE** mode.

1. Read \`_shared-context.md\` for project context and invariants
2. Read \`adaptors/$ADAPTOR.yaml\` for domain-specific stakeholder list and methodology focus
3. Run the chain for $MODE mode (see below)
4. After each agent completes, update \`.gap-hunter/state.json\`
5. After the full chain, run \`scripts/post-process.sh\` to generate derived artefacts

## Chain for $MODE mode

(The slash command \`/gap-hunter:$MODE\` will execute this. Defer to that command.)

## Persistence rules

- \`brain.md\` is append-only — every agent adds a section, never modifies existing ones
- \`gap-hunter-OUTPUT.md\` is never modified after the Gap-Hunter writes it (Verifier uses sidecar)
- \`.gap-hunter/state.json\` is updated after every agent completion
- \`.gap-hunter/plan.md\` is overwritten with the current orchestrator plan (survives context compaction)

## Stop conditions

- Any agent fails twice in a row → hard-fail, surface to user, do not silently proceed
- Verifier reports \`gap_hunter_quality_signal.score == "low"\` → surface prominently before Consolidation
- User explicitly cancels → write current state to \`.gap-hunter/state.json\` for resume capability

## Inputs available

- \`_shared-context.md\` — project context
- \`brain.md\` — research log (append-only)
- \`adaptors/$ADAPTOR.yaml\` — domain configuration
- \`agents/<agent-id>.md\` — agent briefings
- \`.gap-hunter/state.json\` — run state

## Output paths

- \`round-1/<agent-id>-OUTPUT.md\` — per-agent outputs
- \`strategy/integration-catalog.md\` — final consolidation
- \`strategy/decisions.md\`, \`tasks.json\`, \`risk-register.md\`, \`wave-briefings/\` — derived artefacts (post-process)
EOF

echo "Generated: ORCHESTRATOR-BRIEFING.md"

# ---------- Final guidance ----------

cat <<EOF

  Setup complete.

  Next steps:

  1. Review and edit \`_shared-context.md\` — fill in current phase, architecture doc path,
     and project-specific notes for the chain.

  2. Run the smoke test (5 minutes, recommended before overnight runs):

     claude --model opus --dangerously-skip-permissions
     > Read $PROJECT_DIR/_shared-context.md and summarise it in three sentences.

     If the summary comes back without permission errors, setup is verified.
     End the session and open a fresh terminal for the real run.

  3. Launch the run:

     claude --model opus --dangerously-skip-permissions
     > /gap-hunter:$MODE

  4. (Optional, recommended for overnight runs) Launch the watchdog in a separate terminal:

     ./scripts/watchdog.sh

     It will notify you if no agent has appended to brain.md in the last 30 minutes.

  Files generated:
    _shared-context.md
    brain.md
    ORCHESTRATOR-BRIEFING.md
    .gap-hunter/state.json
    round-1/         (output directory)
    strategy/        (final artefact directory)

EOF
