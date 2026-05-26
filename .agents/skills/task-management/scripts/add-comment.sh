#!/usr/bin/env bash
# add-comment.sh — Append a log entry to a task
# Usage: add-comment.sh <task-id> [--author AUTHOR] "message"
# task-id can be NNN, task-NNN, or just N.
set -euo pipefail

TASKS_DIR="$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null)/tasks/workitems"

if [[ $# -lt 2 ]]; then
  echo "Usage: add-comment.sh <task-id> [--author AUTHOR] \"message\"" >&2
  exit 1
fi

raw_id="$1"; shift

# Parse author
AUTHOR="agent"
if [[ "$1" == "--author" ]]; then
  AUTHOR="$2"; shift 2
fi

MESSAGE="$*"

[ -z "$MESSAGE" ] && { echo "Error: empty message" >&2; exit 1; }

# Resolve task file
num=$(echo "$raw_id" | tr -d 'task-')
num=$((10#$num))
id_padded=$(printf "%03d" "$num")
filepath="$TASKS_DIR/task-${id_padded}.md"

[ -f "$filepath" ] || { echo "Error: task file not found: $filepath" >&2; exit 1; }

now=$(date +"%Y-%m-%d %H:%M")

# Append log entry
cat >> "$filepath" <<EOF

### $now — $AUTHOR
> $MESSAGE
EOF

# Update updated_at in frontmatter (simple sed)
updated=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
sed -i "0,/^updated_at:.*/{s|^updated_at:.*|updated_at: \"$updated\"|}" "$filepath"

echo "$filepath"
