#!/usr/bin/env bash
#
# Bump the bundle version everywhere it is recorded.
#
# The version lives in four files that must never disagree:
#   VERSION                                            canonical
#   bundle.json                     .version            manifest
#   bundle.json                     .skills[0].version  orchestrator entry
#   .claude-plugin/plugin.json      .version            Claude Code plugin manifest
#   .agents/skills/job-application-writer/SKILL.md       frontmatter version
#
# This script edits all of them and prints what to do next. It does NOT commit,
# tag, or push - those stay manual by design.
#
# Usage:
#   scripts/bump-version.sh patch           1.1.0 -> 1.1.1
#   scripts/bump-version.sh minor           1.1.0 -> 1.2.0
#   scripts/bump-version.sh major           1.1.0 -> 2.0.0
#   scripts/bump-version.sh 2.0.0-rc.1      explicit
#   scripts/bump-version.sh patch --dry-run
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

DRY_RUN=0
ARG=""
for a in "$@"; do
  case "$a" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help) sed -n '2,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) ARG="$a" ;;
  esac
done

[ -n "$ARG" ] || { echo "error: pass major, minor, patch, or an explicit version" >&2; exit 2; }

OLD=$(tr -d '[:space:]' < VERSION)
[ -n "$OLD" ] || { echo "error: VERSION is empty" >&2; exit 1; }

case "$ARG" in
  major) NEW=$(printf '%s' "$OLD" | awk -F. '{print $1+1".0.0"}') ;;
  minor) NEW=$(printf '%s' "$OLD" | awk -F. '{print $1"."$2+1".0"}') ;;
  patch) NEW=$(printf '%s' "$OLD" | awk -F. '{print $1"."$2"."$3+1}') ;;
  *[!0-9a-zA-Z.+-]*) echo "error: '$ARG' is not a valid version" >&2; exit 2 ;;
  *) NEW="$ARG" ;;
esac

printf '%s' "$NEW" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$' \
  || { echo "error: computed version '$NEW' is not valid semver" >&2; exit 1; }

[ "$OLD" = "$NEW" ] && { echo "error: already at $OLD" >&2; exit 1; }

# Awk programs live in temp files so no shell quoting has to survive the trip.
AWK_DIR=$(mktemp -d)
trap 'rm -rf "$AWK_DIR"' EXIT

cat > "$AWK_DIR/bundle.awk" <<'AWK'
index($0, "  \"version\": ")   && index($0, old) { sub(old, new) }
index($0, "      \"version\": ") && index($0, old) { sub(old, new) }
{ print }
AWK

cat > "$AWK_DIR/plugin.awk" <<'AWK'
index($0, "  \"version\": ") && index($0, old) { sub(old, new) }
{ print }
AWK

cat > "$AWK_DIR/skill.awk" <<'AWK'
NR == 1 && $0 == "---" { infm = 1; print; next }
infm && $0 == "---"   { infm = 0; print; next }
infm && !done && $0 == "version: " old { print "version: " new; done = 1; next }
{ print }
AWK

echo "version bump: $OLD -> $NEW"
echo

if [ "$DRY_RUN" -eq 1 ]; then
  echo "  VERSION"
  echo "  bundle.json            (.version, .skills[0].version)"
  echo "  .claude-plugin/plugin.json  (.version)"
  echo "  .agents/skills/job-application-writer/SKILL.md  (frontmatter)"
  echo
  echo "Dry run. Nothing was written."
  exit 0
fi

printf '%s\n' "$NEW" > VERSION
echo "  updated VERSION"

bump_json() {
  awk -v old="$OLD" -v new="$NEW" -f "$1" "$2" > "$2.bak" \
    && mv "$2.bak" "$2" \
    || { mv "$2.bak" "$2" 2>/dev/null || true; echo "error: failed rewriting $2" >&2; exit 1; }
  echo "  updated $2"
}

bump_json "$AWK_DIR/bundle.awk" bundle.json
bump_json "$AWK_DIR/plugin.awk" .claude-plugin/plugin.json

SKILL=.agents/skills/job-application-writer/SKILL.md
awk -v old="$OLD" -v new="$NEW" -f "$AWK_DIR/skill.awk" "$SKILL" > "$SKILL.bak" \
  && mv "$SKILL.bak" "$SKILL" \
  || { mv "$SKILL.bak" "$SKILL" 2>/dev/null || true; echo "error: failed rewriting $SKILL" >&2; exit 1; }
echo "  updated $SKILL"

echo
echo "Verify with:  scripts/validate.sh --strict"
echo
echo "Then finish the release by hand:"
echo
echo "  1. Add a CHANGELOG.md section for $NEW (validate.sh checks for it):"
echo "       ## [$NEW] - $(date +%Y-%m-%d)"
echo
echo "  2. git add -A && git commit -m 'release: v$NEW'"
echo "  3. git tag -a v$NEW -m 'v$NEW'"
echo "  4. git push origin main --follow-tags"
echo
echo "Pushing the tag is what triggers the release workflow."
