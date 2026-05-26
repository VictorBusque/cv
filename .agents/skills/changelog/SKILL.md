---
name: changelog
description: Generate and preview changelog entries from conventional commit messages. Shows commits since the last tag and formats them as a changelog. Use when the user wants to preview or manually generate changelog content.
---

# Changelog

Generate and preview changelog entries from conventional commits since the last release tag.

## Context

The CI pipeline auto-generates `CHANGELOG.md` on each push to `main`. This skill lets you **preview** what the changelog will look like before merging, or manually generate it if needed.

Versioning follows `YYYY.MM.N` format (e.g., `2026.05.1`, `2026.05.2`).

## Commands

### Preview Upcoming Changelog

Show what the next changelog entry would contain:

```bash
cd /root/docs/cv
PREV_TAG=$(git tag --sort=-version:refname | head -1)
echo "Changes since ${PREV_TAG}:"
echo ""
git log "${PREV_TAG}..HEAD" --pretty=format:"- %s" --no-merges
```

### Preview Next Version Number

```bash
cd /root/docs/cv
PREFIX=$(date +%Y.%m)
COUNT=$(git tag -l "${PREFIX}.*" | wc -l | tr -d ' ')
PATCH=$((COUNT + 1))
echo "Next version: ${PREFIX}.${PATCH}"
```

### View Existing Changelog

```bash
cat /root/docs/cv/CHANGELOG.md
```

### View All Releases

```bash
cd /root/docs/cv
git tag --sort=-version:refname
```

### View Commits in a Specific Release

```bash
cd /root/docs/cv
# Commits between two tags
git log v2026.04.1..v2026.05.1 --pretty=format:"- %s" --no-merges
```

## Manual Changelog Generation

If you need to manually create or update `CHANGELOG.md` (e.g., for a dry run):

```bash
cd /root/docs/cv

DATE=$(date +%Y-%m-%d)
PREFIX=$(date +%Y.%m)
COUNT=$(git tag -l "${PREFIX}.*" | wc -l | tr -d ' ')
PATCH=$((COUNT + 1))
VERSION="${PREFIX}.${PATCH}"

PREV_TAG=$(git tag --sort=-version:refname | head -1)
if [ -n "$PREV_TAG" ]; then
  NOTES=$(git log "${PREV_TAG}"..HEAD --pretty=format:"- %s" --no-merges)
else
  NOTES=$(git log --pretty=format:"- %s" --no-merges)
fi

ENTRY="## v${VERSION} (${DATE})"$'\n\n'"${NOTES}"

if [ -f CHANGELOG.md ]; then
  # Prepend new entry
  {
    echo "# Changelog"
    echo ""
    echo "$ENTRY"
    echo ""
    sed '1,/^# Changelog/d' CHANGELOG.md | sed '1,/^$/d'
  } > CHANGELOG.md.new
  mv CHANGELOG.md.new CHANGELOG.md
else
  {
    echo "# Changelog"
    echo ""
    echo "$ENTRY"
  } > CHANGELOG.md
fi

echo "✅ CHANGELOG.md updated with v${VERSION}"
```

## Grouping Commits by Type

For a more structured preview, group commits by their type:

```bash
cd /root/docs/cv
PREV_TAG=$(git tag --sort=-version:refname | head -1)
RANGE="${PREV_TAG}..HEAD"

echo "### CV Changes"
git log "$RANGE" --grep="^cv:" --pretty=format:"- %s" --no-merges

echo ""
echo "### CI/Build"
git log "$RANGE" --grep="^ci:" --pretty=format:"- %s" --no-merges

echo ""
echo "### Documentation"
git log "$RANGE" --grep="^docs:" --pretty=format:"- %s" --no-merges

echo ""
echo "### Other"
git log "$RANGE" --grep="^chore:\|^fix:\|^refactor:" --pretty=format:"- %s" --no-merges
```

## Notes

- `CHANGELOG.md` is auto-updated by CI on merge to `main` — manual edits are usually only for preview purposes
- Do not commit `CHANGELOG.md` manually unless the user explicitly asks
- The release workflow also creates a GitHub Release with the changelog body
- Releases: `https://github.com/VictorBusque/cv/releases`
