---
name: commit-helper
description: Help commit CV changes with proper conventional commit format. Analyzes the diff, suggests a commit message, and handles git add and commit. Use when the user wants to commit their CV changes.
---

# Commit Helper

Analyze the current diff and create a well-formed conventional commit for CV repo changes.

## Conventional Commit Format

This repo enforces `<type>: <description>` (max 72 chars on the first line).

### Valid Types

| Type | When to use |
|------|-------------|
| `cv` | Changes to CV content (bullet points, summary, skills, etc.) |
| `ci` | Changes to CI/CD workflows, build scripts |
| `docs` | Changes to README, AGENTS.md, documentation |
| `chore` | Maintenance tasks (gitignore, dependencies, tooling) |
| `fix` | Bug fixes (broken LaTeX, build errors) |
| `refactor` | Restructuring without changing content (formatting, macro changes) |

### Examples

```
cv: add incident intelligence bullet to dLocal role
cv: update professional summary for AI platform focus
cv: reorder dLocal bullets to foreground platform work
ci: update release workflow container image
docs: add skill documentation
refactor: extract common heading macro
```

## Workflow

### 1. Analyze the Diff

```bash
cd /root/docs/cv
git diff main.tex
```

If nothing is staged, also check:
```bash
git status
```

### 2. Determine Type

Map the changes to the correct type:
- Changes inside `\section{EXPERIENCE}`, `\section{PROJECTS}`, `\section{SKILLS}`, `\section{EDUCATION}`, or `\section{PROFESSIONAL SUMMARY}` → `cv`
- Changes to `.github/workflows/`, `build.sh`, `Makefile` → `ci`
- Changes to `.md` files → `docs`
- Changes to `.githooks/`, `.gitignore`, tooling → `chore`
- Fixing broken LaTeX or build errors → `fix`
- Reformatting without content changes → `refactor`

### 3. Craft the Message

Rules:
- Use the imperative mood ("add" not "added", "update" not "updated")
- Be specific about what changed and where
- If multiple unrelated changes, consider suggesting the user split into separate commits
- Max 72 characters on the first line
- If a longer explanation is needed, use a multi-line commit:
  ```
  cv: restructure dLocal experience section
  
  - Split tech lead role into two bullet groups
  - Add incident intelligence achievement
  - Reorder bullets for impact
  ```

### 4. Stage and Commit

```bash
# Stage the relevant files
git add <files>

# Commit with the message
git commit -m "<message>"
```

If the user wants a multi-line commit message, use:
```bash
git commit -m "type: short description" -m "First detail line" -m "Second detail line"
```

### 5. Handle Hook Failures

The pre-commit hook builds `main.tex` if it changed. If the build fails:
- Report the xelatex errors
- Suggest fixes
- Do NOT bypass hooks

The commit-msg hook validates the format. If it rejects the message:
- Adjust the message to match `<type>: <description>`
- Ensure it's ≤ 72 characters
