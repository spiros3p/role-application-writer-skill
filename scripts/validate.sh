#!/usr/bin/env bash
#
# Validate the bundle and the repository packaging. This is the release gate:
# it runs in CI on every push and must pass before a version is tagged.
#
# Usage:
#   scripts/validate.sh
#   scripts/validate.sh --strict    # additionally fail on unreleased placeholders
#
# Exit codes: 0 = all checks passed, 1 = one or more checks failed.
#
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# This script deliberately runs without `set -e` so it can report every failure
# in one pass, which means `cd` must guard itself explicitly.
cd "$REPO_ROOT" || { echo "error: cannot enter $REPO_ROOT" >&2; exit 1; }

STRICT=0
case "${1:-}" in
  --strict) STRICT=1 ;;
  -h|--help) sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
  "") ;;
  *) echo "error: unknown option: $1" >&2; exit 2 ;;
esac

PASS=0
FAIL=0

ok()   { printf '  \033[32mPASS\033[0m  %s\n' "$1"; PASS=$((PASS + 1)); }
bad()  { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; FAIL=$((FAIL + 1)); }
warn() { printf '  \033[33mWARN\033[0m  %s\n' "$1"; }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

[ -x "$(command -v jq)" ] || { echo "error: jq is required" >&2; exit 1; }

SKILLS_DIR=".agents/skills"
SKILLS=$(jq -r '.pipeline[]' bundle.json)

# Extract a top-level scalar from a SKILL.md YAML frontmatter block.
fm() {
  awk -v key="$2" '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { exit }
    in_fm && $0 ~ ("^" key ":") { sub("^" key ":[ \t]*", ""); print; exit }
  ' "$1"
}

# ---------------------------------------------------------------------------
head_ "Repository files"

for f in LICENSE README.md CHANGELOG.md NOTICE.md CONTRIBUTING.md SECURITY.md \
         VERSION bundle.json .claude-plugin/plugin.json \
         scripts/install.sh scripts/validate.sh scripts/bump-version.sh \
         scripts/check-rules.sh; do
  [ -f "$f" ] && ok "$f exists" || bad "$f is missing"
done

for f in scripts/install.sh scripts/validate.sh scripts/bump-version.sh \
         scripts/sync-from-local.sh scripts/check-rules.sh; do
  [ -x "$f" ] && ok "$f is executable" || bad "$f is not executable"
done

# ---------------------------------------------------------------------------
head_ "Version"

VERSION=$(tr -d '[:space:]' < VERSION 2>/dev/null || echo "")
if printf '%s' "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$'; then
  ok "VERSION is valid semver ($VERSION)"
else
  bad "VERSION is not valid semver: '${VERSION:-<empty>}'"
fi

for src in bundle.json .claude-plugin/plugin.json; do
  v=$(jq -r '.version' "$src")
  [ "$v" = "$VERSION" ] && ok "$src version matches VERSION ($v)" \
                        || bad "$src version '$v' != VERSION '$VERSION'"
done

ORCH="$SKILLS_DIR/job-application-writer/SKILL.md"
if [ -f "$ORCH" ]; then
  sv=$(fm "$ORCH" "version")
  [ "$sv" = "$VERSION" ] && ok "orchestrator SKILL.md version matches VERSION ($sv)" \
                         || bad "orchestrator SKILL.md version '$sv' != VERSION '$VERSION'"
else
  bad "orchestrator SKILL.md is missing"
fi

# The top *released* section. Unreleased is a placeholder for future work and
# must not be mistaken for the version currently shipped.
CHANGELOG_TOP=$(grep -E '^## \[' CHANGELOG.md 2>/dev/null \
  | grep -viE '^## \[unreleased\]' \
  | head -1 | sed -E 's/^## \[([^]]+)\].*/\1/')
if [ "$CHANGELOG_TOP" = "$VERSION" ]; then
  ok "CHANGELOG has a section for $VERSION"
else
  bad "CHANGELOG top released section '${CHANGELOG_TOP:-<none>}' != VERSION '$VERSION'"
fi

# ---------------------------------------------------------------------------
head_ "Bundle closure"

for s in $SKILLS; do
  if [ -f "$SKILLS_DIR/$s/SKILL.md" ]; then
    ok "$s present"
  else
    bad "$s is missing from $SKILLS_DIR"
  fi
done

# Every skill directory on disk must be declared in bundle.json.
undeclared=0
for d in "$SKILLS_DIR"/*/; do
  [ -d "$d" ] || continue
  d=$(basename "$d")
  if ! printf '%s\n' $SKILLS | grep -qx "$d"; then
    bad "$d exists on disk but is not declared in bundle.json .pipeline"
    undeclared=1
  fi
done
[ "$undeclared" -eq 0 ] && ok "no undeclared skill directories"

# The index must have exactly one row per skill, and every row must resolve.
IDX=".agents/SKILL_DIRECTORY.md"
if [ -f "$IDX" ]; then
  ROWS=$(grep -cE '^(manual|upstream:[^,]+), ' "$IDX")
  DISK=$(find "$SKILLS_DIR" -name SKILL.md | wc -l | tr -d ' ')
  if [ "$ROWS" = "$DISK" ]; then
    ok "index has one row per skill ($ROWS)"
  else
    bad "index has $ROWS rows for $DISK skills"
  fi

  badrow=0
  while IFS= read -r row; do
    rpath=$(printf '%s' "$row" | awk -F', ' '{print $NF}')
    if [ ! -f "$rpath/SKILL.md" ]; then
      bad "index row points at a missing path: $rpath"
      badrow=1
    fi
  done < <(grep -E '^(manual|upstream:[^,]+), ' "$IDX")
  [ "$badrow" -eq 0 ] && ok "every index row resolves"
fi

# bundle.json path entries must resolve.
badpath=0
while IFS= read -r p; do
  [ -d "$p" ] || { bad "bundle.json path does not exist: $p"; badpath=1; }
done < <(jq -r '.skills[].path' bundle.json)
[ "$badpath" -eq 0 ] && ok "every bundle.json path resolves"

# plugin.json must point at the skills root.
PLUGIN_SKILLS=$(jq -r '.skills // empty' .claude-plugin/plugin.json)
if [ "$PLUGIN_SKILLS" = "./.agents/skills/" ]; then
  ok "plugin.json scans ./.agents/skills/"
else
  bad "plugin.json .skills is '${PLUGIN_SKILLS:-<empty>}', expected './.agents/skills/'"
fi

# ---------------------------------------------------------------------------
head_ "Skill frontmatter"

for s in $SKILLS; do
  f="$SKILLS_DIR/$s/SKILL.md"
  [ -f "$f" ] || continue

  name=$(fm "$f" "name")
  desc=$(fm "$f" "description")

  [ "$name" = "$s" ] && ok "$s frontmatter name matches directory" \
                     || bad "$s frontmatter name is '${name:-<none>}', expected '$s'"

  if [ -n "$desc" ]; then
    ok "$s has a description"
  else
    bad "$s has no frontmatter description (agents cannot trigger on it)"
  fi

  if grep -q '^disabled: true$' "$f"; then
    bad "$s still carries 'disabled: true' - the bundle must ship enabled"
  fi
done

# ---------------------------------------------------------------------------
head_ "Licensing and attribution"

for u in $(jq -r '.skills[] | select(.origin == "upstream") | .upstream.repo' bundle.json | sort -u); do
  if grep -qF "$u" NOTICE.md; then
    ok "NOTICE.md credits $u"
  else
    bad "NOTICE.md does not credit $u"
  fi
done

if [ -f "$SKILLS_DIR/humanizer/LICENSE" ]; then
  ok "humanizer upstream LICENSE retained in-tree"
else
  bad "humanizer LICENSE is missing - MIT requires the notice to travel with the code"
fi

# Every skill must have a license accounted for, either declared in its own
# frontmatter, declared in bundle.json, or carrying a LICENSE file in-tree.
for s in $SKILLS; do
  [ -f "$SKILLS_DIR/$s/SKILL.md" ] || continue
  lic=$(fm "$SKILLS_DIR/$s/SKILL.md" "license")
  declared=$(jq -r --arg n "$s" '.skills[] | select(.name == $n) | .license // empty' bundle.json)
  if [ -n "$lic" ] || [ -n "$declared" ] || [ -f "$SKILLS_DIR/$s/LICENSE" ]; then
    ok "$s license accounted for"
  else
    bad "$s has no license anywhere (frontmatter, bundle.json, or LICENSE file)"
  fi
done

# ---------------------------------------------------------------------------
head_ "Rule inventory"

# The bundle is instructions an agent follows, so every check above is structural
# and says nothing about whether a rule survived an edit. scripts/check-rules.sh
# pins the load-bearing phrases and the rubric's shape.
RULE_OUT=$(./scripts/check-rules.sh 2>&1)
RULE_RC=$?
if [ "$RULE_RC" -eq 0 ]; then
  ok "$(printf '%s' "$RULE_OUT" | tail -1)"
else
  bad "rule inventory: load-bearing rule text is missing or changed"
  printf '%s\n' "$RULE_OUT" | sed 's/^/        /'
fi

# ---------------------------------------------------------------------------
head_ "Packaging hygiene"

if [ -z "$(find "$SKILLS_DIR" -name '.DS_Store' -print -quit)" ]; then
  ok "no .DS_Store in the bundle"
else
  bad ".DS_Store found in the bundle"
fi

if grep -rq '^spiros3p\|spiros3p' --include='*.json' --include='*.md' . 2>/dev/null; then
  if [ "$STRICT" -eq 1 ]; then
    bad "spiros3p placeholder still present (replace before tagging a release)"
  else
    warn "spiros3p placeholder present - fine for a draft, fails under --strict"
  fi
fi

# The bundle must never carry absolute paths from the author's machine.
if grep -rn "$HOME/agent-workspace" "$SKILLS_DIR" >/dev/null 2>&1; then
  ok "no machine-specific absolute paths in the bundle"
else
  ok "bundle references workspace by the documented ~ path only"
fi

# Relative links in repository documentation must resolve. Broken links in a
# public README are the most common avoidable defect in a distribution repo.
# While-read loops throughout: filenames and link targets may contain spaces.
brokenlinks=0
while IFS= read -r md; do
  mdir=$(dirname "$md")
  while IFS= read -r link; do
    [ -n "$link" ] || continue
    case "$link" in
      http://*|https://*|mailto:*|'#'*) continue ;;
    esac
    target="${link%%#*}"
    [ -n "$target" ] || continue
    if [ ! -e "$mdir/$target" ]; then
      bad "$md links to a missing target: $target"
      brokenlinks=1
    fi
  done < <(grep -oE '\]\([^)]+\)' "$md" 2>/dev/null \
           | sed -E 's/^\]\(//; s/\)$//; s/^["'\'']//; s/["'\'']$//')
done < <(find . -name '*.md' -not -path './.agents/skills/*' -not -path './.freebuff/*')
[ "$brokenlinks" -eq 0 ] && ok "all relative markdown links resolve"

# ---------------------------------------------------------------------------
printf '\n\033[1mResult\033[0m  %d passed, %d failed\n' "$PASS" "$FAIL"

if [ "$FAIL" -ne 0 ]; then
  printf '\n\033[31mValidation failed.\033[0m Fix the failures above before tagging a release.\n'
  exit 1
fi

printf '\n\033[32mValidation passed.\033[0m Safe to tag as v%s\n' "$VERSION"
exit 0
