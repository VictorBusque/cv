#!/usr/bin/env bash
# set-field.sh — Update any frontmatter field on a task
# Usage: set-field.sh <task-id> <field> <value>
# Example: set-field.sh 3 priority high
#          set-field.sh 3 assignee human
#          set-field.sh 3 depends_on "[1, 2]"
#          set-field.sh 3 branch "feat/login"
set -euo pipefail

source "$(dirname "$0")/task-utils.sh"

if [[ $# -lt 3 ]]; then
  echo "Usage: set-field.sh <task-id> <field> <value>" >&2
  exit 1
fi

raw_id="$1"; shift
FIELD="$1"; shift
VALUE="$*"

# Resolve task file
filepath=$(resolve_task_file "$raw_id")

# Update the field (first occurrence only, within frontmatter)
fm_set "$filepath" "$FIELD" "$VALUE"

# Always bump updated_at
touch_updated "$filepath"

echo "$filepath"
