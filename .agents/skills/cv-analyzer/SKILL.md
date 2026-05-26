---
name: cv-analyzer
description: Analyze the CV against ATS compatibility, recruiter attractiveness, and resume best practices. Scores the CV across multiple criteria and provides actionable improvement suggestions. Use when the user wants a CV audit, review, or score.
---

# CV Analyzer

Analyze `main.tex` against industry-standard resume criteria to produce a structured scorecard with actionable improvement suggestions.

## Quick Analysis

Read `main.tex` and evaluate it against the criteria below. Output a **scorecard** followed by **specific findings**.

## Scoring

Rate each category **0–10**. The overall score is a weighted average (weights shown).

### 1. Impact & Quantification (weight: ×3)

**What recruiters want:** Bullets with measurable outcomes — dollars, percentages, user counts, time savings. The #1 predictor of interview callbacks.

**Check for:**
- [ ] Each bullet point contains at least one number or metric
- [ ] Metrics are specific (not "improved performance" but "reduced latency by 40%")
- [ ] Revenue/cost impact is stated where applicable ($ figures)
- [ ] Scale is visible (team size, user count, request volume)
- [ ] Bullet structure follows: **[Bold Label]:** Metric → Action → Context
- [ ] Weak verbs are avoided ("helped", "worked on", "assisted with", "responsible for")
- [ ] Strong verbs are used ("led", "designed", "built", "scaled", "delivered", "owned", "pioneered", "achieved", "reduced", "increased", "launched")

**Common issues to flag:**
- Bullets without any numbers
- Vague impact ("improved efficiency" without saying how much)
- Responsibility lists instead of achievement statements
- Missing team/scale context for leadership roles

### 2. ATS Compatibility (weight: ×2)

**What ATS parsers need:** Clean text extraction with standard section headings, simple formatting, and keyword density.

**Check for:**
- [ ] Section headings use standard names (Experience, Skills, Education, Projects)
- [ ] No tables, columns, text boxes, or embedded graphics that confuse parsers
- [ ] Skills section lists both acronyms AND full terms (e.g., "Natural Language Processing (NLP)")
- [ ] Job titles are standard and parseable (not custom/internal titles only)
- [ ] Dates are in a consistent, parseable format
- [ ] Contact info is in plain text (phone, email, LinkedIn, location)
- [ ] PDF output is text-selectable (not image-based) — verify by building and checking
- [ ] Key skills from the target industry appear in both Skills section AND embedded in experience bullets (dual-encoding)
- [ ] No special characters that could break parsing (strange unicode, emojis)

**Common issues to flag:**
- Non-standard section names that parsers might ignore
- Skills listed only in the Skills section (not reinforced in bullets)
- Missing full-term equivalents for acronyms
- Date format inconsistencies

### 3. Content & Completeness (weight: ×2)

**What makes a complete, attractive resume:**

**Check for:**
- [ ] Professional Summary is present, concise (2–4 sentences), and role-aligned
- [ ] Experience section is reverse-chronological with clear progression
- [ ] Each role has 3–10 bullets (more for recent roles, fewer for older ones)
- [ ] Current roles use present tense; past roles use past tense
- [ ] Stack/tech is listed per company or role
- [ ] Projects section demonstrates initiative and depth
- [ ] Education section includes relevant focus areas
- [ ] Certifications are current and relevant
- [ ] No irrelevant or outdated information

**Common issues to flag:**
- Professional Summary is too long or too generic
- Older roles have as many bullets as recent ones (should taper)
- Missing tech stack for a role
- Projects section absent or empty

### 4. Keyword Density & Searchability (weight: ×2)

**How recruiters find candidates:** Boolean search across LinkedIn and ATS databases using exact skill keywords and job titles.

**Check for:**
- [ ] Key technologies appear as exact strings (e.g., "Python", "FastAPI", "AWS", "Kubernetes")
- [ ] Industry terms are present for the target domain (AI/ML: "LLM", "RAG", "MCP", "Agent", "Fine-tuning", "Embeddings")
- [ ] Job-level keywords match target roles ("Tech Lead", "AI Engineer", "NLP Engineer", "Senior")
- [ ] Both generic and specific terms are included ("cloud infrastructure" AND "AWS EKS")
- [ ] Cross-functional and soft skills are demonstrated through outcomes, not just listed
- [ ] The resume would surface in a recruiter Boolean search like: `(AI Engineer OR NLP Engineer) AND (Python OR FastAPI) AND (AWS OR Kubernetes) AND (LLM OR RAG)`

**Common issues to flag:**
- Important keywords missing that peers in the same role would have
- Only one way to refer to a technology (missing synonyms/abbreviations)
- Skills section doesn't match what's described in experience bullets

### 5. Formatting & Readability (weight: ×1)

**What human eyes need:** Clean scannability in 6–7 seconds of recruiter attention.

**Check for:**
- [ ] Resume length is appropriate for experience level (1 page for <10 yrs, 1–2 pages for 10+)
- [ ] Bold text is used strategically for key metrics and labels (not overused)
- [ ] White space is sufficient — not too dense, not too sparse
- [ ] Consistent formatting across all sections (bullet style, date format, spacing)
- [ ] Most important information is in the top third of the first page
- [ ] Font size is readable (10–12pt body text)
- [ ] No orphan/widow lines (single lines at top/bottom of a page)

**Common issues to flag:**
- Page breaks in awkward places
- Too many bold items (diminishes impact)
- Inconsistent date formats between sections
- Wall of text with no visual hierarchy

### 6. Career Narrative (weight: ×1)

**What tells a coherent story:** Clear progression, specialization, and increasing scope.

**Check for:**
- [ ] Career progression is visible (title advancement, scope increase)
- [ ] There's a clear thematic thread (AI/NLP specialization is consistent)
- [ ] Each role builds on the previous one (not random jumps)
- [ ] The most recent experience is the strongest and most detailed
- [ ] Leadership growth is evident (IC → Tech Lead, team size increases)
- [ ] The Professional Summary accurately reflects the overall narrative

**Common issues to flag:**
- Unclear why someone moved between companies
- Recent experience doesn't match stated career direction
- Leadership bullets are mixed with IC bullets without clear role separation

## Output Format

Present the analysis as:

```
## CV Analysis Scorecard

| Category                    | Score | Weight | Weighted |
|-----------------------------|-------|--------|----------|
| Impact & Quantification     | x/10  | ×3     |          |
| ATS Compatibility           | x/10  | ×2     |          |
| Content & Completeness      | x/10  | ×2     |          |
| Keyword Density             | x/10  | ×2     |          |
| Formatting & Readability    | x/10  | ×1     |          |
| Career Narrative            | x/10  | ×1     |          |
| **Overall**                 |       |        | **x/10** |

### Strengths
- [what's already strong]

### Issues Found

#### Critical (fix before applying)
- [specific, actionable finding with line reference]

#### Recommended (would significantly improve)
- [specific, actionable finding with line reference]

#### Nice-to-have (marginal improvement)
- [specific, actionable finding]
```

## Comparison Mode

If the user asks to compare against a specific job posting, first fetch the job URL:

```bash
python3 /root/.agents/skills/internet/fetch.py <JOB_URL>
```

Then add a **Job Alignment** section:

```
### Job Alignment (vs. <Job Title> at <Company>)

| Requirement              | Present | Where | Gap |
|--------------------------|---------|-------|-----|
| <required skill>         | ✅/❌    | line  | ... |
```

Flag which job requirements are missing, weakly covered, or well-covered.

## Red Flags Checklist

Always scan for these instant-reject signals:

- [ ] No spelling or grammar errors
- [ ] No unexplained employment gaps
- [ ] No exaggerated or unverifiable claims
- [ ] Professional contact info (no informal emails)
- [ ] No irrelevant personal details (age, photo, marital status)
- [ ] Consistent tense usage within each role
- [ ] No orphan technologies mentioned once and never contextualized
- [ ] LinkedIn URL is included and matches the resume narrative

## After Analysis

After presenting the scorecard:
1. Ask if the user wants to fix any issues
2. If yes, use the `section-editor` skill patterns to apply targeted edits
3. Rebuild and re-score after changes:
   ```bash
   cd /root/docs/cv && ./build.sh
   ```
