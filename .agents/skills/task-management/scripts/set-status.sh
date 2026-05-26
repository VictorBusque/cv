#!/usr/bin/env bash
# set-status.sh — Update task status with transition validation
# Usage: set-status.sh <task-id> <new-status> [--branch BRANCH] [--result RESULT]
# Auto-sets finished_at on done/cancelled, updates updated_at.
set -euo pipefail

TASKS_DIR="$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null)/tasks/workitems"

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
num=$(echo "$raw_id" | tr -d 'task-')
num=$((10#$num))
id_padded=$(printf "%03d" "$num")
filepath="$TASKS_DIR/task-${id_padded}.md"

[ -f "$filepath" ] || { echo "Error: task file not found: $filepath" >&2; exit 1; }

# Get current status
current=$(grep -m1 '^status:' "$filepath" | sed 's/^status: *//')

# Validate transition
case "$current" in
  done|cancelled)
    echo "Error: task is already $current (terminal state)" >&2; exit 1 ;;
esac

# Update status
sed -i "0,/^status:.*/{s|^status:.*|status: $NEW_STATUS|}" "$filepath"

# Update timestamp
updated=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
sed -i "0,/^updated_at:.*/{s|^updated_at:.*|updated_at: \"$updated\"|}" "$filepath"

# Handle terminal states
if [[ "$NEW_STATUS" == "done" || "$NEW_STATUS" == "cancelled" ]]; then
  sed -i "0,/^finished_at:.*/{s|^finished_at:.*|finished_at: \"$updated\"|}" "$filepath"
fi

# Handle branch
if [[ -n "$BRANCH" ]]; then
  sed -i "0,/^branch:.*/{s|^branch:.*|branch: \"$BRANCH\"|}" "$filepath"
fi

# Handle result
if [[ -n "$RESULT" ]]; then
  sed -i "0,/^result:.*/{s|^result:.*|result: \"$RESULT\"|}" "$filepath"
fi

echo "$filepath"
