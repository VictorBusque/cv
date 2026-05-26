---
name: section-editor
description: Structured editing of CV sections in main.tex. Provides operations like adding bullets, roles, companies, projects, or updating skills without requiring LaTeX knowledge. Use when the user wants to add or modify specific sections of the CV.
---

# Section Editor

Structured operations for editing `main.tex` without requiring direct LaTeX knowledge. Each operation preserves the file's formatting conventions and LaTeX macros.

## File

All edits target `/root/docs/cv/main.tex`.

## Structure Reference

The CV has these sections in order:

1. **HEADING** — Name, contact info (inside `\begin{center}...\end{center}`)
2. **PROFESSIONAL SUMMARY** — Tagline + paragraph
3. **EXPERIENCE** — Companies (dLocal → Rollio → Raona), each with roles and bullets
4. **PROJECTS** — Personal projects
5. **SKILLS** — Grouped skill list
6. **EDUCATION** — Degree and certifications

## Operations

### Add a Bullet Point

**Where:** Inside any `\resumeItemListStart ... \resumeItemListEnd` block.

**Template:**

```latex
\resumeItem{<content>}
```

**Rules:**

- Bold key phrases/metrics: `\textbf{300+}` or `\textbf{AI Platform:}`
- Keep concise and impact-focused: metric → action → context
- Place after the last `\resumeItem` in the target block, before `\resumeItemListEnd`

**Example:**

```latex
\resumeItem{\textbf{Cost Optimization:} Reduced LLM inference costs by \textbf{40\%} through intelligent model routing and prompt caching.}
```

### Add a New Role

**Where:** Inside a company block, after the last role's `\resumeItemListEnd` and before the Stack line.

**Template:**

```latex
    \vspace{2pt}
    \textit{<Title>} \hfill \small <Start Month>. <Start Year> -- <End Month>. <End Year>
    \resumeItemListStart
        \resumeItem{<first bullet>}
    \resumeItemListEnd
```

**Rules:**

- Add `\vspace{2pt}` before the role line
- Dates use three-letter month abbreviations: `Jan.`, `Feb.`, `Mar.`, `Apr.`, `May`, `Jun.`, `Jul.`, `Aug.`, `Sep.`, `Oct.`, `Nov.`, `Dec.`
- Use `Present` for current roles
- Place before the Stack line of the company

### Add a New Company

**Where:** Inside the EXPERIENCE section's `\resumeSubHeadingListStart ... \resumeSubHeadingListEnd`, in reverse-chronological order (newest first).

**Template:**

```latex
    % --- <COMPANY NAME> ---
    \item
    \textbf{\Large <Company Name> (<Ticker>)} \hfill \textbf{<Start Month>. <Start Year> -- <End>}

    \vspace{2pt}
    \textit{<Title>} \hfill \small <Start Month>. <Start Year> -- <End Month>. <End Year>
    \resumeItemListStart
        \resumeItem{<first bullet>}
    \resumeItemListEnd
    \small{\textbf{Stack:} <tech list separated by commas, grouped by category>.}
```

**Rules:**

- Add `\vspace{10pt}` between companies
- Comment with `% --- COMPANY ---`
- Newest company first
- Stack line groups: language, framework, cloud/infra (ends with a period)

### Add a New Project

**Where:** Inside the PROJECTS section's `\resumeSubHeadingListStart ... \resumeSubHeadingListEnd`.

**Template:**

```latex
      \resumeProjectHeading
        {\textbf{\href{<URL>}{<Name>}} $|$ \emph{<type>}}{<Month>. <Year> -- <End>}
        \resumeItemListStart
          \resumeItem{<description>}
        \resumeItemListEnd
```

**Rules:**

- Place in reverse-chronological order (newest first)
- Use `\emph{Personal project}` for personal projects, `\emph{Open Source}` for OSS, etc.

### Update Skills

The skills section uses a single `\item` with `\\` line breaks between groups:

```latex
\textbf{<Group Name>:} <comma-separated values> \\
```

To add a skill, append it to the appropriate group's comma-separated list. To add a new group, add a new line with `\\` before the closing `}}`.

### Update Professional Summary

Two parts to edit:

1. **Tagline** (the `\textit{...}` centered line):

```latex
\centering\textit{<tagline>}\\[4pt]
```

2. **Body paragraph** (the paragraph after `\raggedright`):

```latex
AI Technical Leader with 8+ years...
```

## Safety

- Always use the `edit` tool with exact text matching — never rewrite the entire file
- Verify LaTeX structure is balanced after edits (matching `\begin`/`\end`, braces)
- Build after edits to verify:
  ```bash
  cd /root/docs/cv && ./build.sh
  ```
- If the build fails, check for: unmatched braces, missing `\\`, unclosed environments, or special characters not escaped (use `\&`, `\%`, `\$`, `\#`, `\_` in text)
