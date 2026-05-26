#!/usr/bin/env bash
# build-board.sh — Generate a self-contained tasks/index.html
# Reads all workitems/task-*.md, embeds them as JSON, produces index.html.
# Usage: build-board.sh [--open]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null)"
WORKITEMS_DIR="${REPO_ROOT}/tasks/workitems"
OUTPUT="${REPO_ROOT}/tasks/index.html"
TEMPLATE="${SCRIPT_DIR}/board-template.html"

if [ ! -f "$TEMPLATE" ]; then
  echo "Error: template not found: $TEMPLATE" >&2; exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

# Use Python to parse all task .md files into a JSON blob,
# then inject it into the HTML template replacing the placeholder line.
python3 - "$WORKITEMS_DIR" "$TEMPLATE" "$OUTPUT" <<'PYEOF'
import os, json, re, sys

workitems_dir = sys.argv[1]
template_path = sys.argv[2]
output_path = sys.argv[3]

tasks = []

if os.path.isdir(workitems_dir):
    for fname in sorted(os.listdir(workitems_dir)):
        if not fname.startswith("task-") or not fname.endswith(".md"):
            continue
        filepath = os.path.join(workitems_dir, fname)
        with open(filepath, "r") as f:
            content = f.read()

        parts = content.split("---", 2)
        if len(parts) < 3:
            continue

        fm_text = parts[1].strip()
        body = parts[2].strip()

        # Parse frontmatter
        task = {}
        for line in fm_text.split("\n"):
            if ":" in line:
                key, val = line.split(":", 1)
                val = val.strip()
                if val.startswith('"') and val.endswith('"'):
                    val = val[1:-1]
                if val.startswith("["):
                    try: val = json.loads(val)
                    except: val = []
                if val == "null":
                    val = None
                if key.strip() == "id":
                    try: val = int(val)
                    except: pass
                task[key.strip()] = val

        # Parse body sections
        sections = {"context": "", "plan": "", "log": ""}
        current = None
        for line in body.split("\n"):
            stripped = line.strip()
            if stripped == "## Context": current = "context"; continue
            elif stripped == "## Plan": current = "plan"; continue
            elif stripped == "## Log": current = "log"; continue
            elif stripped.startswith("## ") and current: current = None; continue
            if current is not None:
                sections[current] += line + "\n"

        # Parse plan checklist
        plan_items = []
        for line in sections["plan"].strip().split("\n"):
            line = line.strip()
            if not line: continue
            m = re.match(r'- \[([ xX])\]\s*(.*)', line)
            if m:
                plan_items.append({"checked": m.group(1).lower() == 'x', "text": m.group(2)})
            elif line.startswith("- "):
                plan_items.append({"checked": False, "text": line[2:]})

        # Parse log entries
        log_entries = []
        entry = None
        for line in sections["log"].strip().split("\n"):
            m = re.match(r'###\s*(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2})\s*[-—]\s*(.*)', line)
            if m:
                if entry: log_entries.append(entry)
                entry = {"timestamp": m.group(1), "author": m.group(2).strip(), "message": ""}
            elif entry and line.startswith("> "):
                entry["message"] += line[2:] + "\n"
            elif entry and line.strip():
                entry["message"] += line + "\n"
        if entry:
            log_entries.append(entry)
        for e in log_entries:
            e["message"] = e["message"].strip()

        task["plan_items"] = plan_items
        task["log_entries"] = log_entries
        task["context_text"] = sections["context"].strip()
        tasks.append(task)

# Read template
with open(template_path, "r") as f:
    html = f.read()

# Inject data
data_js = "const TASKS = " + json.dumps(tasks, ensure_ascii=False) + ";"
html = html.replace("// __TASK_DATA__", data_js)

with open(output_path, "w") as f:
    f.write(html)

print(f"Built: {output_path} ({len(tasks)} tasks)")
PYEOF

# Optionally open in browser
if [[ "${1:-}" == "--open" ]]; then
  xdg-open "$OUTPUT" 2>/dev/null || open "$OUTPUT" 2>/dev/null || echo "(Could not auto-open browser)"
fi
