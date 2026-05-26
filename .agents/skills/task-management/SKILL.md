---
name: task-management
description: Create and manage task files under tasks/workitems/ to track work, blockers, and progress. Use when the user gives a multi-step task, asks to track progress, or wants to see the task board.
---

# Task Management Skill

Create and manage task files under `tasks/workitems/` to track work, blockers, and progress.
A self-contained `tasks/index.html` Kanban board can be generated to visualize everything.

Used by the coding agent (pi) and the supervisor (Víctor) as a shared execution log.

## When to Use

- When the user gives you a multi-step or non-trivial task.
- When the user says "create a task", "track this", "what's the status", "show tasks", or "board".
- At the start of any complex piece of work, proactively offer to create a task.
- When you need to hand off a decision or blocker to the supervisor.
- **Don't** create tasks for trivial one-off edits (typos, single-line fixes).

## File Layout

```
tasks/
├── index.html              ← Self-contained Kanban board (generated, open in browser)
└── workitems/
    ├── task-001.md          ← Task files live here
    ├── task-002.md
    └── ...
```

## Scripts

Located in `.agents/skills/task-management/scripts/`. Always prefer scripts over manual file editing for structural operations.

| Script           | Purpose                                  | When to use                                     |
| ---------------- | ---------------------------------------- | ----------------------------------------------- |
| `create-task.sh` | Create a new task file with next auto-ID | New task                                        |
| `add-comment.sh` | Append a log entry to a task             | Any progress update, question, or decision      |
| `set-status.sh`  | Transition status with validation        | Starting, finishing, blocking, cancelling       |
| `set-field.sh`   | Update any single frontmatter field      | Changing priority, assignee, branch, depends_on |
| `list-tasks.sh`  | Terminal board view of all tasks         | Quick status check in the terminal              |
| `build-board.sh` | Generate `tasks/index.html` Kanban board | After task changes, to update the visual board  |

### Script Details

#### `create-task.sh [--title TITLE] [--priority P] [--assignee A] [--status S]`

Creates `tasks/workitems/task-NNN.md` with frontmatter and body skeleton. Prints the file path. Defaults: `status=open`, `priority=medium`, `assignee=agent`.

After running, use the `edit` tool to fill in `description`, `## Context`, and `## Plan`.

#### `add-comment.sh <task-id> [--author AUTHOR] "message"`

Appends a timestamped log entry. Author defaults to `agent`. Víctor's entries use `--author human`.

#### `set-status.sh <task-id> <status> [--branch B] [--result R]`

Validates the transition. Terminal states (`done`, `cancelled`) auto-set `finished_at`. Optional `--branch` and `--result`.

Status lifecycle:

```
open ──→ doing ──→ review ──→ done
  │         │
  │         └──→ blocked ──→ doing
  └──→ cancelled
```

Terminal states cannot be left (`done`/`cancelled` are final).

#### `set-field.sh <task-id> <field> <value>`

Updates any frontmatter field. Always bumps `updated_at`. Examples:

```bash
set-field.sh 3 priority high
set-field.sh 3 assignee human
set-field.sh 3 depends_on "[1, 2]"
set-field.sh 3 branch "feat/login"
```

#### `list-tasks.sh [--all] [--status S] [--assignee A]`

Terminal board view sorted by: blocked first → priority → ID. Default hides done/cancelled. Use `--all` to see everything.

#### `build-board.sh [--open]`

Generates a self-contained `tasks/index.html` that embeds all task data as JSON. No server needed — just open the file in a browser. Uses Python to parse frontmatter and inject data into the HTML template at `scripts/board-template.html`.

Run this after any task mutations to update the board. Or pass `--open` to also open it in the browser.

## Workflow

### Creating a task

1. Run `create-task.sh` with title and priority.
2. Use `edit` to fill in `description`, `## Context`, and `## Plan` with `- [ ]` check items.
3. Print a summary to the user.

### Working on a task

1. `set-status.sh <id> doing`
2. `add-comment.sh <id> "Starting work on..."`
3. As you complete plan items, use `edit` to change `- [ ]` to `- [x]`.
4. Log meaningful progress with `add-comment.sh`.
5. If blocked: `set-status.sh <id> blocked`, `set-field.sh <id> assignee human`, `add-comment.sh <id> "Blocked because..."`.

### Completing a task

1. `set-status.sh <id> done --result "Commit abc123: added rate limiting"`
2. `add-comment.sh <id> "Done. Implemented sliding window rate limiter."`

### Updating the board

1. `build-board.sh` to regenerate `tasks/index.html`.
2. The user can open it directly from the file system — no server needed.

### Cancelling

1. `set-status.sh <id> cancelled`
2. `add-comment.sh <id> "Cancelled: superseded by task-NNN."`

## Task File Format

Each task is a Markdown file with YAML frontmatter:

```markdown
---
id: 1
title: "Short imperative description"
description: ""
status: open
priority: medium
assignee: agent
depends_on: []
created_at: "2026-05-26T08:00:00Z"
updated_at: "2026-05-26T08:00:00Z"
finished_at: null
branch: null
result: null
---

## Context

Why this task exists, what triggered it, links to discussions.

## Plan

- [ ] Step 1
- [ ] Step 2
- [ ] Step 3

## Log

### 2026-05-26 08:00 — agent

> Task created.
```

### Field Reference

| Field         | Type          | Values                                                    | Description                      |
| ------------- | ------------- | --------------------------------------------------------- | -------------------------------- |
| `id`          | int           | auto                                                      | Matches filename number          |
| `title`       | string        | —                                                         | Short, imperative                |
| `description` | string        | —                                                         | What and why                     |
| `status`      | enum          | `open`, `doing`, `review`, `done`, `blocked`, `cancelled` | Current state                    |
| `priority`    | enum          | `low`, `medium`, `high`, `critical`                       | Default: `medium`                |
| `assignee`    | enum          | `agent`, `human`, `both`                                  | Who acts next                    |
| `depends_on`  | list[int]     | e.g. `[1, 3]`                                             | Blocking task IDs                |
| `created_at`  | ISO 8601      | auto                                                      | Creation timestamp               |
| `updated_at`  | ISO 8601      | auto                                                      | Last modification                |
| `finished_at` | ISO 8601/null | auto                                                      | Set on done/cancelled            |
| `branch`      | string/null   | —                                                         | Git branch if applicable         |
| `result`      | string/null   | —                                                         | Outcome: commit SHA, PR, summary |

### Body Sections

| Section     | Purpose                                                  |
| ----------- | -------------------------------------------------------- |
| **Context** | Background, motivation, links. Written once at creation. |
| **Plan**    | Checklist of steps. Check off with `[x]` as you go.      |
| **Log**     | Append-only chronological journal. Never delete entries. |

## Aliases

| User says                                                  | Action                                                      |
| ---------------------------------------------------------- | ----------------------------------------------------------- |
| "create a task", "track this", "new task"                  | `create-task.sh`                                            |
| "tasks", "show tasks", "what's pending", "status", "board" | `list-tasks.sh`                                             |
| "update task N", "mark doing", "log progress"              | `set-status.sh` + `add-comment.sh`                          |
| "close task N", "done with N", "finish N"                  | `set-status.sh N done --result "..."`                       |
| "cancel task N", "drop N"                                  | `set-status.sh N cancelled`                                 |
| "block task N", "need help with N"                         | `set-status.sh N blocked` + `set-field.sh N assignee human` |
| "rebuild board", "update board", "refresh board"           | `build-board.sh`                                            |
