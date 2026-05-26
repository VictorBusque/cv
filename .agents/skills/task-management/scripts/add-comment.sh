#!/usr/bin/env bash
# add-comment.sh — Append a log entry to a task
# Usage: add-comment.sh <task-id> [--author AUTHOR] "message"
# task-id can be NNN, task-NNN, or just N.
set -euo pipefail

source "$(dirname "$0")/task-utils.sh"

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
filepath=$(resolve_task_file "$raw_id")

# Append log entry
cat >> "$filepath" <<EOF

### $(now_local) — $AUTHOR
> $MESSAGE
EOF

# Bump updated_at
touch_updated "$filepath"

echo "$filepath"
