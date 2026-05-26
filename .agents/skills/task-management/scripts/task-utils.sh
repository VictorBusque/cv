#!/usr/bin/env bash
# task-utils.sh — Shared utilities for task-management scripts
# Source this file: source "$(dirname "$0")/task-utils.sh"
# Provides portable frontmatter editing via perl (works on macOS + Linux).

# Resolve TASKS_DIR from any script that sources this.
# The sourcing script must be inside scripts/ for this to work.
_TASK_UTILS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASKS_DIR="$(git -C "$_TASK_UTILS_SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null)/tasks/workitems"

# fm_set <file> <field> <value>
# Updates the first occurrence of `field:` in YAML frontmatter.
# Uses perl for portability (no sed -i differences between macOS/Linux).
fm_set() {
  local file="$1" field="$2" value="$3"
  perl -i -pe 's{^'"$field"':\s*.*}{'"$field"': '"$value"'} && $done++' "$file"
}

# fm_set_quoted <file> <field> <value>
# Same as fm_set but wraps value in double quotes.
fm_set_quoted() {
  local file="$1" field="$2" value="$3"
  perl -i -pe 's{^'"$field"':\s*.*}{'"$field"': \"'"$value"'\"} && $done++' "$file"
}

# fm_get <file> <field>
# Prints the value of a frontmatter field (unquoted).
fm_get() {
  local file="$1" field="$2"
  local val
  val=$(grep -m1 "^${field}:" "$file" | sed "s/^${field}: *//")
  # Strip surrounding quotes if present
  val="${val#\"}"
  val="${val%\"}"
  echo "$val"
}

# resolve_task_file <raw_id>
# Prints the full path to the task file. Exits on missing.
resolve_task_file() {
  local raw_id="$1"
  local num
  num=$(echo "$raw_id" | tr -d 'task-')
  num=$((10#$num))
  local id_padded
  id_padded=$(printf "%03d" "$num")
  local filepath="${TASKS_DIR}/task-${id_padded}.md"
  if [ ! -f "$filepath" ]; then
    echo "Error: task file not found: $filepath" >&2
    exit 1
  fi
  echo "$filepath"
}

# now_utc — prints current UTC timestamp in ISO 8601
now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# now_local — prints current local timestamp for log entries
now_local() {
  date +"%Y-%m-%d %H:%M"
}

# touch_updated <file> — bumps updated_at timestamp
touch_updated() {
  fm_set_quoted "$1" "updated_at" "$(now_utc)"
}
