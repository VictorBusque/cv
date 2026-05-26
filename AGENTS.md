# AGENTS.md — CV Management

This repo contains the CV/résumé of **Víctor Busqué Somacarrera** as a single LaTeX file (`main.tex`).

## Project Overview

- **Source:** `main.tex` — the sole LaTeX document. Built with XeLaTeX (uses `fontawesome5`, `tgheros`).
- **Build:** `./build.sh` or `make build` compiles `main.tex` → `out/main.pdf` (two-pass XeLaTeX).
- **Clean:** `./build.sh clean` or `make clean` removes the `out/` directory.
- **Check:** `make check` builds and verifies success.
- **Pre-commit hook:** `.githooks/pre-commit` — runs build check when `main.tex` is modified.
- **Commit-msg hook:** `.githooks/commit-msg` — enforces conventional commit format (`<type>: <description>`).
- **Hooks activation:** `make hooks` or `git config core.hooksPath .githooks`.
- **Repo:** `git@github.com:VictorBusque/cv.git`

## Structure Conventions

- Everything lives in `main.tex` (preamble, custom commands, content).
- Sections are marked with clear `%-----------SECTION-----------` comments.
- Custom macros (`\resumeItem`, `\resumeSubheading`, `\resumeProjectHeading`, etc.) handle formatting — use them, don't fight them.
- Stack lines are plain `\small{\textbf{Stack:} ...}` at the end of a company block.

## Section Order

1. **HEADING** — Name, contact info (phone, email, LinkedIn, website, location).
2. **PROFESSIONAL SUMMARY** — `\section{PROFESSIONAL SUMMARY}`, single paragraph.
3. **EXPERIENCE** — `\section{EXPERIENCE}`, companies in reverse-chronological order (dLocal → Rollio → Raona). Each company has roles with date ranges and `\resumeItem` bullets.
4. **PROJECTS** — `\section{PROJECTS}`, reverse-chronological.
5. **TECHNICAL SKILLS** — `\section{TECHNICAL SKILLS}`, grouped by AI Stack / Engineering / Infrastructure.
6. **EDUCATION & CERTIFICATIONS** — `\section{EDUCATION \& CERTIFICATIONS}`.

## Editing Guidelines

### Adding a new bullet point
Insert a `\resumeItem{...}` inside the appropriate `\resumeItemListStart ... \resumeItemListEnd` block. Wrap bold key phrases with `\textbf{...}`.

### Adding a new role
Copy an existing role block (the `\textit{Title} \hfill \small DateRange` + `\resumeItemListStart ... \resumeItemListEnd`). Update title, dates, and bullets.

### Adding a new company
Copy an entire company block (from `\item \begin{tabular*...` to the stack line). Place it in the correct chronological position within `\resumeSubHeadingListStart ... \resumeSubHeadingListEnd`.

### Adding a new project
Copy a `\resumeProjectHeading{...}` block inside the Projects section.

### Formatting rules
- **Bold** metrics and impact numbers: `\textbf{\$2M+}`, `\textbf{78\%}`.
- Dates use three-letter month abbreviations: `Dec. 2023`, `Oct. 2024`.
- Stack lines list tech separated by commas, grouped by category.
- Keep bullets concise and impact-focused (metric → action → context).

## Building

### Local

```bash
make              # build PDF (or ./build.sh)
make clean        # remove artifacts
make check        # build & verify
```

Two git hooks in `.githooks/`:

- **`pre-commit`** — verifies the build when `main.tex` is changed.
- **`commit-msg`** — enforces conventional commit format: `<type>: <description>`.

Valid types: `cv`, `ci`, `docs`, `chore`, `fix`, `refactor`.

Activate with:

```bash
make hooks   # or: git config core.hooksPath .githooks
```

If `xelatex` fails, check that `texlive-fonts-extra` and `fontawesome5` are installed.

### CI (GitHub Actions)

**On Pull Requests:** `.github/workflows/build.yml` builds the PDF to validate compilation. If a previous release exists, it generates a **visual diff** (page-by-page PNG comparison) uploaded as an artifact for review before merging.

**On merge to `main`:**

1. Builds `main.tex` → `out/main.pdf` (two-pass XeLaTeX) inside a `danteev/texlive:latest` container.
2. Computes the next **auto-version** tag in `YYYY.MM.N` format (e.g. `2026.05.1`, `2026.05.2`).
   - `YYYY.MM` = year and month of the commit date.
   - `N` = patch number, auto-incremented by counting existing tags with the same prefix.
3. Generates release notes from conventional commit messages since last tag.
4. Creates a **GitHub Release** tagged `v<version>` with the versioned PDF (`Victor_Busque_CV_<version>.pdf`) and release notes attached.

Releases are listed at: `https://github.com/VictorBusque/cv/releases`

## Working with the Internet Skill

Use the **internet skill** for tasks that benefit from web data:

- **Job description tailoring:** Fetch a job posting URL → extract requirements → compare against current CV content → suggest targeted edits or rewording of bullets.
- **Company research:** Search for a target company's tech stack, recent news, or values to align the Professional Summary or bullet points.
- **Skill trend checks:** Search for trending skills or keywords in a domain (e.g., "LLM agent frameworks 2026") to ensure the Skills section stays current.
- **Salary benchmarking:** Search for salary data for a role/location to inform negotiation talking points (not for the CV itself, but useful context).
- **LinkedIn profile alignment:** Fetch the LinkedIn profile to cross-check that the CV and LinkedIn tell a consistent story.

### Example flow: Tailor CV to a job posting
1. User provides a job URL.
2. Fetch the page: `curl -s "https://markdown.new/<JOB_URL>"`
3. Extract key requirements, technologies, and themes.
4. Read `main.tex` and identify gaps or areas to strengthen.
5. Propose targeted edits (reorder bullets, adjust wording, add relevant keywords) using the formatting rules above.
6. Apply edits, rebuild with `./build.sh`.

## Output

- **Local:** compiled PDF goes to `out/main.pdf`.
- **CI:** each `main` push produces a GitHub Release (tag `vYYYY.MM.N`) with `Victor_Busque_CV_YYYY.MM.N.pdf` attached.
- Do not commit `out/` contents unless explicitly asked — it's a build artifact.
