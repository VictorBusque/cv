#!/usr/bin/env bash
# list-tasks.sh — Display a board view of all tasks
# Usage: list-tasks.sh [--all] [--status STATUS] [--assignee ASSIGNEE]
# Default: shows only non-done/non-cancelled tasks. --all shows everything.
set -euo pipefail

TASKS_DIR="$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null)/tasks/workitems"

ALL=false
FILTER_STATUS=""
FILTER_ASSIGNEE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --all)       ALL=true; shift ;;
    --status)    FILTER_STATUS="$2"; shift 2 ;;
    --assignee)  FILTER_ASSIGNEE="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [ ! -d "$TASKS_DIR" ] || [ -z "$(ls "$TASKS_DIR"/task-*.md 2>/dev/null)" ]; then
  echo "No tasks found."
  exit 0
fi

# Priority sort weight
prio_weight() {
  case "$1" in
    critical) echo 0 ;;
    high)     echo 1 ;;
    medium)   echo 2 ;;
    low)      echo 3 ;;
    *)        echo 4 ;;
  esac
}

# Status emoji
status_icon() {
  case "$1" in
    open)      echo "⚪" ;;
    doing)     echo "🔵" ;;
    review)    echo "🟠" ;;
    done)      echo "✅" ;;
    blocked)   echo "🟣" ;;
    cancelled) echo "❌" ;;
    *)         echo "❓" ;;
  esac
}

# Assignee label
assignee_label() {
  case "$1" in
    agent) echo "🤖" ;;
    human) echo "👤" ;;
    both)  echo "🤖👤" ;;
    *)     echo "❓" ;;
  esac
}

# Collect tasks for sorting
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

count=0
done_count=0
active_count=0

for f in "$TASKS_DIR"/task-*.md; do
  [ -f "$f" ] || continue

  task_id=$(grep -m1 '^id:' "$f" | sed 's/^id: *//')
  title=$(grep -m1 '^title:' "$f" | sed 's/^title: *"//;s/"$//')
  status=$(grep -m1 '^status:' "$f" | sed 's/^status: *//')
  priority=$(grep -m1 '^priority:' "$f" | sed 's/^priority: *//')
  assignee=$(grep -m1 '^assignee:' "$f" | sed 's/^assignee: *//')
  depends=$(grep -m1 '^depends_on:' "$f" | sed 's/^depends_on: *//')

  if [[ "$status" == "done" || "$status" == "cancelled" ]]; then
    (( done_count++ )) || true
    if [[ "$ALL" != "true" && -z "$FILTER_STATUS" ]]; then
      continue
    fi
  else
    (( active_count++ )) || true
  fi

  [[ -n "$FILTER_STATUS" && "$status" != "$FILTER_STATUS" ]] && continue
  [[ -n "$FILTER_ASSIGNEE" && "$assignee" != "$FILTER_ASSIGNEE" ]] && continue

  # Sort: blocked first, then priority desc, then id asc
  blocked_first="1"
  [[ "$status" == "blocked" ]] && blocked_first="0"
  sort_key="${blocked_first}$(prio_weight "$priority")_$(printf '%05d' "$task_id")"

  icon=$(status_icon "$status")
  alabel=$(assignee_label "$assignee")
  id_padded=$(printf "%03d" "$task_id")

  line="  #$id_padded $icon ${status^^} [$alabel]  $title"

  if [[ "$depends" != "[]" && "$depends" != "" ]]; then
    clean_deps=$(echo "$depends" | tr -d '[]')
    line="${line}
        ↳ depends on ${clean_deps}"
  fi

  echo "${sort_key}@@@${line}" >> "$tmpdir/tasks.txt"
  (( count++ )) || true
done

if [[ "$count" -eq 0 ]]; then
  echo "No matching tasks found."
  exit 0
fi

echo "📋 Tasks ($count shown)"
echo ""

sort -t'@' -k1,1 "$tmpdir/tasks.txt" | while IFS='' read -r line; do
  # Strip sort key (everything before and including the @@@ separator)
  echo "${line#*@@@}"
done

echo ""
total=$(( done_count + active_count ))
echo "✅ $done_count done | 🔵 $active_count active | 📦 $total total"
