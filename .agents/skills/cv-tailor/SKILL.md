---
name: cv-tailor
description: Tailor the CV to a specific job posting. Fetches a job URL, extracts key requirements, compares against main.tex, and proposes targeted edits to align the CV with the job description. Use when the user wants to customize their CV for a job application.
---

# CV Tailor

Tailor `main.tex` to a specific job posting by analyzing requirements and suggesting targeted edits.

## Workflow

### 1. Fetch the Job Posting

Use the internet skill to fetch the job posting URL:

```bash
python3 /root/.agents/skills/internet/fetch.py <JOB_URL>
```

If the URL fails with the fetch script, try:
```bash
curl -s "https://markdown.new/<JOB_URL>"
```

### 2. Extract Key Requirements

From the job posting, extract and categorize:

- **Required skills** — technologies, languages, frameworks explicitly mentioned
- **Preferred/nice-to-have skills** — secondary technologies
- **Key responsibilities** — core duties and expected impact areas
- **Themes/values** — company culture keywords, mission alignment (e.g., "startup mindset", "cross-functional", "ownership")
- **Seniority level** — Staff, Senior, Lead, etc.

### 3. Analyze Current CV

Read `main.tex` and identify:

- **Matches** — skills/experience already present that align with the job
- **Gaps** — required skills or themes not clearly reflected
- **Opportunities** — bullets that could be reworded to better match the job's language
- **Reorder candidates** — bullets or sections where changing order would foreground the most relevant experience

### 4. Propose Targeted Edits

Present edits in this format:

```
### Edit 1: Professional Summary
**Why:** [reason]
**Change:** [specific edit to main.tex]
```

Types of edits to consider (in priority order):

1. **Professional Summary** — Adjust to echo the job's language and highlight the most relevant qualifications
2. **Bullet reordering** — Move the most relevant bullets to the top within each role
3. **Bullet rewriting** — Reframe existing achievements to use the job's keywords (without fabricating anything)
4. **Skills section** — Ensure all matching skills from the job are listed; reorder to front-load the most relevant
5. **Section emphasis** — If the job emphasizes projects over experience or vice versa, suggest structural changes

### Rules

- **Never fabricate** experience, metrics, or skills that aren't already in the CV
- **Preserve all LaTeX macros** (`\resumeItem`, `\resumeSubheading`, `\resumeProjectHeading`, etc.)
- **Keep bullets concise** and impact-focused (metric → action → context)
- **Bold key metrics** with `\textbf{...}`
- **Dates** use three-letter month abbreviations (e.g., `Dec. 2023`)
- If the job requires skills not present in the CV at all, **flag them as gaps** rather than adding them
- Apply edits using the `edit` tool, not by rewriting the entire file

### 5. Build & Verify

After applying edits, build the CV:

```bash
cd /root/docs/cv && ./build.sh
```

Report the result to the user.
