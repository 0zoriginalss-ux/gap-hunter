#!/usr/bin/env bash
# Gap-Hunter Watchdog
#
# Monitors brain.md mtime. If no append for STALE_THRESHOLD seconds, fires
# a system notification. Catches the most common silent failure mode:
# an agent hangs while the orchestrator waits.
#
# Usage:
#   ./scripts/watchdog.sh                  # uses default threshold (1800s = 30min)
#   ./scripts/watchdog.sh --threshold 900  # 15 minutes
#   ./scripts/watchdog.sh --check-every 60 # check interval (default 60s)

set -euo pipefail

THRESHOLD=1800
CHECK_INTERVAL=60
BRAIN_PATH="${BRAIN_PATH:-./brain.md}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --threshold) THRESHOLD="$2"; shift 2 ;;
    --check-every) CHECK_INTERVAL="$2"; shift 2 ;;
    --brain) BRAIN_PATH="$2"; shift 2 ;;
    -h|--help)
      grep '^#' "$0" | head -20
      exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ ! -f "$BRAIN_PATH" ]]; then
  echo "brain.md not found at $BRAIN_PATH" >&2
  exit 1
fi

echo "Watchdog active."
echo "  Watching: $BRAIN_PATH"
echo "  Stale threshold: ${THRESHOLD}s"
echo "  Check interval: ${CHECK_INTERVAL}s"
echo ""
echo "Press Ctrl-C to stop."
echo ""

NOTIFIED_STALE=false

notify() {
  local title="$1"
  local body="$2"

  if command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"$body\" with title \"$title\""
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "$title" "$body"
  elif command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -Command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null; [System.Windows.Forms.MessageBox]::Show('$body', '$title')" >/dev/null 2>&1 || true
  else
    echo "[$(date '+%H:%M:%S')] $title — $body"
  fi
}

while true; do
  if [[ ! -f "$BRAIN_PATH" ]]; then
    notify "Gap-Hunter Watchdog" "brain.md disappeared — orchestrator may have crashed."
    sleep "$CHECK_INTERVAL"
    continue
  fi

  # Cross-platform mtime
  if stat -c %Y "$BRAIN_PATH" >/dev/null 2>&1; then
    MTIME=$(stat -c %Y "$BRAIN_PATH")
  else
    MTIME=$(stat -f %m "$BRAIN_PATH")
  fi

  NOW=$(date +%s)
  AGE=$((NOW - MTIME))

  if (( AGE > THRESHOLD )); then
    if ! $NOTIFIED_STALE; then
      MINUTES=$((AGE / 60))
      notify "Gap-Hunter Watchdog" "brain.md has been stale for ${MINUTES} minutes — an agent may be stuck."
      NOTIFIED_STALE=true
    fi
  else
    if $NOTIFIED_STALE; then
      notify "Gap-Hunter Watchdog" "brain.md activity resumed."
      NOTIFIED_STALE=false
    fi
  fi

  sleep "$CHECK_INTERVAL"
done
