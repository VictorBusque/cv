#!/usr/bin/env bash
# create-task.sh — Create a new task file
# Usage: create-task.sh [--title TITLE] [--priority P] [--assignee A] [--status S]
# All args optional; missing ones default. Prints the created file path.
set -euo pipefail

TASKS_DIR="$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null)/tasks/workitems"
mkdir -p "$TASKS_DIR"

# Defaults
TITLE=""
PRIORITY="medium"
ASSIGNEE="agent"
STATUS="open"

while [[ $# -gt 0 ]]; do
  case $1 in
    --title)     TITLE="$2"; shift 2 ;;
    --priority)  PRIORITY="$2"; shift 2 ;;
    --assignee)  ASSIGNEE="$2"; shift 2 ;;
    --status)    STATUS="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

# Validate enums
[[ "$PRIORITY" =~ ^(low|medium|high|critical)$ ]] || { echo "Invalid priority: $PRIORITY" >&2; exit 1; }
[[ "$ASSIGNEE" =~ ^(agent|human|both)$ ]] || { echo "Invalid assignee: $ASSIGNEE" >&2; exit 1; }
[[ "$STATUS" =~ ^(open|doing|review|done|blocked|cancelled)$ ]] || { echo "Invalid status: $STATUS" >&2; exit 1; }

# Find next ID
next_id=1
for f in "$TASKS_DIR"/task-*.md; do
  [ -f "$f" ] || continue
  base=$(basename "$f" .md)
  num=${base#task-}
  num=$((10#$num))
  (( num >= next_id )) && next_id=$((num + 1))
done

id_padded=$(printf "%03d" "$next_id")
now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Fallback title
[ -z "$TITLE" ] && TITLE="Task #$id_padded"

filepath="$TASKS_DIR/task-${id_padded}.md"

cat > "$filepath" <<EOF
---
id: $next_id
title: "$TITLE"
description: ""
status: $STATUS
priority: $PRIORITY
assignee: $ASSIGNEE
depends_on: []
created_at: "$now"
updated_at: "$now"
finished_at: null
branch: null
result: null
---

## Context



## Plan



## Log

### $(date +"%Y-%m-%d %H:%M") — agent
> Task created.
EOF

echo "$filepath"
