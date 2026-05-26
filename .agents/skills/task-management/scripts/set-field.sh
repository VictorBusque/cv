#!/usr/bin/env bash
# set-field.sh — Update any frontmatter field on a task
# Usage: set-field.sh <task-id> <field> <value>
# Example: set-field.sh 3 priority high
#          set-field.sh 3 assignee human
#          set-field.sh 3 depends_on "[1, 2]"
#          set-field.sh 3 branch "feat/login"
set -euo pipefail

TASKS_DIR="$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null)/tasks/workitems"

if [[ $# -lt 3 ]]; then
  echo "Usage: set-field.sh <task-id> <field> <value>" >&2
  exit 1
fi

raw_id="$1"; shift
FIELD="$1"; shift
VALUE="$*"

# Resolve task file
num=$(echo "$raw_id" | tr -d 'task-')
num=$((10#$num))
id_padded=$(printf "%03d" "$num")
filepath="$TASKS_DIR/task-${id_padded}.md"

[ -f "$filepath" ] || { echo "Error: task file not found: $filepath" >&2; exit 1; }

# Update the field (first occurrence only, within frontmatter)
sed -i "0,/^${FIELD}:.*/{s|^${FIELD}:.*|${FIELD}: ${VALUE}|}" "$filepath"

# Always bump updated_at
updated=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
sed -i "0,/^updated_at:.*/{s|^updated_at:.*|updated_at: \"$updated\"|}" "$filepath"

echo "$filepath"
