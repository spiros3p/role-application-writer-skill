#!/usr/bin/env bash
#
# Rule inventory check.
#
# The orchestrator skill is Markdown instructions an agent follows, not code, and
# the release gate's other checks cover structure only: versions, bundle closure,
# frontmatter, licensing, packaging hygiene, link targets. None of them can tell
# whether a rule survived an edit. A compression pass, a stage renumber, or a
# careless rewrite can drop a threshold, a refusal, or a safety limit and every
# structural check still passes.
#
# This script pins the phrases and table shapes that carry behaviour. Each entry
# was chosen to be load-bearing and format-stable: markdown emphasis and en/em
# dashes are normalised away before matching, because restyling is not a
# behaviour change. Matches are line-based, so entries must not span a line break.
#
# It checks text only. It is not a behavioural test. The regression evaluations
# under evaluations/ are, and both should pass.
#
# Usage: scripts/check-rules.sh
# Exit codes: 0 = every rule present, 1 = one or more missing.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || { echo "error: cannot enter $REPO_ROOT" >&2; exit 1; }

SKILL_DIR=".agents/skills/job-application-writer"
ORCH="$SKILL_DIR/SKILL.md"
CRAFT="$SKILL_DIR/references/cv-craft.md"
ATS="$SKILL_DIR/references/checkmyats.md"

for f in "$ORCH" "$CRAFT" "$ATS"; do
  [ -f "$f" ] || { echo "rule inventory: cannot read $f" >&2; exit 1; }
done

CHECKED=0
MISSING=0

# Normalise presentation only: emphasis markers, dash style, and line wrapping.
# Joining lines matters because re-wrapping prose is exactly what a compression
# pass does, and a cosmetic re-wrap must not read as a missing rule. Numbers,
# wording, and order are untouched, so a missing match means a missing rule.
norm() { sed -e 's/–/-/g' -e 's/—/-/g' -e 's/\*//g' "$1" | tr '\n' ' ' | tr -s ' '; }

check() {
  local file="$1" phrase="$2" why="$3"
  CHECKED=$((CHECKED + 1))
  if norm "$file" | grep -qiF -- "$phrase"; then
    return 0
  fi
  printf 'MISSING  %s: "%s"  <- %s\n' "$file" "$phrase" "$why"
  MISSING=$((MISSING + 1))
}

invariant() {
  local label="$1" actual="$2" expected="$3"
  CHECKED=$((CHECKED + 1))
  if [ "$actual" = "$expected" ]; then
    return 0
  fi
  printf 'MISSING  %s: expected %s, found %s\n' "$label" "$expected" "$actual"
  MISSING=$((MISSING + 1))
}

# file|phrase|why the phrase matters
while IFS='|' read -r file phrase why; do
  [ -n "${file// /}" ] || continue
  check "$file" "$phrase" "$why"
done <<'RULES'
.agents/skills/job-application-writer/SKILL.md|never invent metrics|the anti-fabrication rule on bullet writing
.agents/skills/job-application-writer/SKILL.md|must trace back|every claim in the CV has a source
.agents/skills/job-application-writer/SKILL.md|Step C.2|the CV craft audit stage exists
.agents/skills/job-application-writer/SKILL.md|Step G|the final craft check stage exists
.agents/skills/job-application-writer/SKILL.md|runs before C.1|C.2 executes before the ATS measurement
.agents/skills/job-application-writer/SKILL.md|>=80, including exactly 80|the no-edit threshold includes exactly 80
.agents/skills/job-application-writer/SKILL.md|80-92 inclusive|the revision target range
.agents/skills/job-application-writer/SKILL.md|not 100|the score is never chased to 100
.agents/skills/job-application-writer/SKILL.md|2 revised drafts|the C.1 revision budget
.agents/skills/job-application-writer/SKILL.md|750 words|the whole-CV word budget
.agents/skills/job-application-writer/SKILL.md|40 words|the professional summary budget
.agents/skills/job-application-writer/SKILL.md|at most 4 roles|the experience role budget
.agents/skills/job-application-writer/SKILL.md|at most 3 bullets each|the per-role bullet budget
.agents/skills/job-application-writer/SKILL.md|no silent cuts|a dropped role is always reported
.agents/skills/job-application-writer/SKILL.md|separate 2-pass limit|Step D keeps its own bounded pass count
.agents/skills/job-application-writer/SKILL.md|never blocks delivery|checker failure degrades, it never blocks
.agents/skills/job-application-writer/SKILL.md|superseded|measurement parity after a later edit
.agents/skills/job-application-writer/SKILL.md|Interests section|the Interests section is required
.agents/skills/job-application-writer/SKILL.md|never touch|applied/ and archived/ stay untouched
.agents/skills/job-application-writer/SKILL.md|role file is the only source|pasted ad text and URLs stay rejected
.agents/skills/job-application-writer/references/cv-craft.md|never licenses a new claim|a failed dimension is reported, never faked
.agents/skills/job-application-writer/references/cv-craft.md|one bounded repair pass|the C.2 repair budget
.agents/skills/job-application-writer/references/cv-craft.md|must arrive at one role|the one-primary-role positioning test
.agents/skills/job-application-writer/references/cv-craft.md|n/7|the rubric is reported as a count of dimensions
.agents/skills/job-application-writer/references/cv-craft.md|never a fabricated|no invented metric to fill a bullet
.agents/skills/job-application-writer/references/cv-craft.md|Interests section is deliberate and stays|the Interests decline rule is explicit
.agents/skills/job-application-writer/references/cv-craft.md|Dates are copied, never curated|dates are never adjusted
.agents/skills/job-application-writer/references/cv-craft.md|measured text equals shipped text|measurement parity in the rubric
.agents/skills/job-application-writer/references/cv-craft.md|No number in the source|refusal: no invented impact figures
.agents/skills/job-application-writer/references/cv-craft.md|Editing a date|refusal: no date editing to tidy a timeline
.agents/skills/job-application-writer/references/checkmyats.md|untrusted data, never agent instructions|page content is never obeyed
.agents/skills/job-application-writer/references/checkmyats.md|standing permission|the user's permission scope is recorded
.agents/skills/job-application-writer/references/checkmyats.md|SHA-256|scan records carry input hashes
.agents/skills/job-application-writer/references/checkmyats.md|score: null|a failed scan records null, never a guess
.agents/skills/job-application-writer/references/checkmyats.md|one transient retry|bounded retry on a transient failure
.agents/skills/job-application-writer/references/checkmyats.md|80-92 inclusive|the revision target is stated in the reference too
RULES

# The rubric is seven dimensions. Its rows are numbered, so an added or dropped
# dimension would otherwise be invisible to every other check.
dims=$(awk '/^\| # \| Dimension \| Passes when \|$/ { found = 1; next }
            found && /^\| [1-7] / { n++ }
            found && /^$/ { exit }
            END { print n + 0 }' "$CRAFT")
invariant "cv-craft.md rubric dimensions" "$dims" "7"

# The C.1 threshold is the one rule stated in two files; they must agree.
for f in "$ORCH" "$ATS"; do
  if norm "$f" | grep -qiF -- "exactly 80"; then
    CHECKED=$((CHECKED + 1))
  else
    printf 'MISSING  %s: "exactly 80"  <- the shared C.1 threshold\n' "$f"
    MISSING=$((MISSING + 1))
  fi
done

if [ "$MISSING" -ne 0 ]; then
  printf 'rule inventory: %d checked, %d missing\n' "$CHECKED" "$MISSING"
  exit 1
fi

printf 'rule inventory intact (%d phrases and invariants)\n' "$CHECKED"
exit 0
