# Curriculum Vitae — Víctor Busqué Somacarrera

[![Build & Release](../../actions/workflows/build.yml/badge.svg)](../../actions/workflows/build.yml)

> AI Technical Leader · 8+ years in NLP & Generative AI · Barcelona, Spain

The LaTeX source for my CV/résumé, compiled to PDF via XeLaTeX.

## Quick Start

```bash
make              # build PDF (or ./build.sh)
make clean        # remove artifacts
make check        # build & verify
make convert      # build HTML + Markdown (requires pandoc)
make html         # HTML only
make md           # Markdown only
make hooks        # activate git hooks
```

**Requirements:** `xelatex`, `texlive-fonts-extra`, `fontawesome5`.

For HTML/Markdown export: `pandoc` ([install](https://pandoc.org/installing.html)).

The compiled PDF lands at `out/main.pdf`. HTML and Markdown go to `out/main.html` and `out/main.md`.

## Git Hooks

Two hooks are included in `.githooks/`:

| Hook | What it does |
|---|---|
| `pre-commit` | Verifies `main.tex` compiles when changed |
| `commit-msg` | Enforces [conventional commits](#commit-conventions) format |

Activate both with:

```bash
make hooks   # or: git config core.hooksPath .githooks
```

### Commit Conventions

All commit messages must follow the format `<type>: <description>` (max 72 chars).

| Type | Use for |
|---|---|
| `cv` | CV content changes (bullets, roles, skills…) |
| `ci` | CI/CD workflow changes |
| `docs` | README, comments |
| `chore` | .gitignore, tooling, editor config |
| `fix` | Fix typos, broken formatting |
| `refactor` | Restructure without content change |

Examples:
```
cv: added new dLocal bullet point
ci: updated release workflow
docs: updated README
```

## CI & Releases

### On every Pull Request

1. Builds the PDF to verify `main.tex` compiles
2. Converts to HTML and Markdown (if pandoc available)
3. Downloads the latest release PDF and generates a **visual diff** (page images) uploaded as an artifact — review before merging

### On merge to `main`

1. Builds the PDF in a TeX Live container
2. Converts to HTML and Markdown (if pandoc available)
3. Auto-versions it as `vYYYY.MM.N` (e.g. `v2026.05.1`)
4. Generates release notes from conventional commit messages since the last release
5. Creates a GitHub Release with the versioned PDF, `llms.txt` (Markdown), and release notes attached

Download the latest PDF from the [Releases page](../../releases).

### llms.txt

Each release includes `llms.txt` — a Markdown version of the CV optimized for LLM consumption. The latest version is always at:

```
https://github.com/VictorBusque/cv/releases/latest/download/llms.txt
```

To serve it from your domain (e.g. `victorbusque.com/llms.txt`), set up a redirect:

- **Cloudflare:** Page Rule → URL Match `victorbusque.com/llms.txt` → Forwarding URL (301) to the GitHub URL
- **nginx:** `location = /llms.txt { return 301 https://github.com/VictorBusque/cv/releases/latest/download/llms.txt; }`
- **Netlify:** `_redirects` file → `/llms.txt https://github.com/VictorBusque/cv/releases/latest/download/llms.txt 301`

## Structure

```
main.tex                      # Single-file LaTeX source (preamble + content)
build.sh                      # Build & clean script (supports: build, clean, convert)
convert.sh                    # LaTeX → HTML/Markdown converter (requires pandoc)
Makefile                      # make build / clean / check / convert / md / html / hooks
LICENSE                       # MIT license
.githooks/pre-commit          # Build verification before commits
.githooks/commit-msg          # Conventional commit enforcement
.github/workflows/build.yml   # CI: validate PRs, build & release on merge
.github/PULL_REQUEST_TEMPLATE.md  # PR checklist template
.github/dependabot.yml        # Automated GitHub Actions dependency updates
.editorconfig                 # Editor consistency rules
AGENTS.md                     # AI agent instructions for editing this repo
out/                          # Build artifacts (gitignored): PDF, HTML, Markdown
```

## Editing

Everything lives in `main.tex`. Sections are separated by clear `%-----------SECTION-----------` comments:

| Section | Description |
|---|---|
| **Heading** | Name, phone, email, LinkedIn, website, location |
| **Professional Summary** | One-paragraph positioning statement |
| **Experience** | Reverse-chronological: dLocal → Rollio → Raona |
| **Projects** | Personal projects (EstoEsLegal, ClaimsProtocol) |
| **Skills** | AI & LLMs / Engineering / Cloud & Infrastructure |
| **Education** | UPC degree, certifications, languages |

### Custom macros

| Macro | Purpose |
|---|---|
| `\resumeItem{...}` | Bullet point |
| `\resumeSubheading{...}{...}{...}{...}` | Company/role heading (4 args) |
| `\resumeProjectHeading{...}{...}` | Project heading (2 args) |
| `\resumeItemListStart / End` | Bullet list wrapper |
| `\resumeSubHeadingListStart / End` | Section list wrapper |

### Formatting conventions

- **Bold** metrics and impact: `\textbf{\$2M+}`, `\textbf{78\%}`
- Dates as three-letter month abbreviations: `Dec. 2023`
- Stack lines as `\small{\textbf{Stack:} ...}` at the end of each company block

## License

[MIT](./LICENSE)
