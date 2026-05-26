#!/usr/bin/env bash
# set-status.sh — Update task status with transition validation
# Usage: set-status.sh <task-id> <new-status> [--branch BRANCH] [--result RESULT]
# Auto-sets finished_at on done/cancelled, updates updated_at.
set -euo pipefail

source "$(dirname "$0")/task-utils.sh"

if [[ $# -lt 2 ]]; then
  echo "Usage: set-status.sh <task-id> <status> [--branch B] [--result R]" >&2
  exit 1
fi

raw_id="$1"; shift
NEW_STATUS="$1"; shift

# Optional extras
BRANCH=""
RESULT=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --branch) BRANCH="$2"; shift 2 ;;
    --result) RESULT="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

# Validate
[[ "$NEW_STATUS" =~ ^(open|doing|review|done|blocked|cancelled)$ ]] || { echo "Invalid status: $NEW_STATUS" >&2; exit 1; }

# Resolve task file
filepath=$(resolve_task_file "$raw_id")

# Get current status
current=$(fm_get "$filepath" "status")

# Validate transition
case "$current" in
  done|cancelled)
    echo "Error: task is already $current (terminal state)" >&2; exit 1 ;;
esac

# Update status
fm_set "$filepath" "status" "$NEW_STATUS"

# Bump updated_at
touch_updated "$filepath"

# Handle terminal states
if [[ "$NEW_STATUS" == "done" || "$NEW_STATUS" == "cancelled" ]]; then
  fm_set_quoted "$filepath" "finished_at" "$(now_utc)"
fi

# Handle branch
if [[ -n "$BRANCH" ]]; then
  fm_set_quoted "$filepath" "branch" "$BRANCH"
fi

# Handle result
if [[ -n "$RESULT" ]]; then
  fm_set_quoted "$filepath" "result" "$RESULT"
fi

echo "$filepath"
