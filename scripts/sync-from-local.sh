#!/usr/bin/env bash
#
# Maintainer-only: re-materialize .agents/skills/ from the author's local
# skill install, stripping the local-only `disabled: true` convention line.
#
# The checked-in bundle is the single source of truth for this repository.
# This script exists so a maintainer can regenerate it byte-for-byte from
# ~/.agents/skills/ after editing a skill locally. Contributors do not need it.
#
# Usage:
#   scripts/sync-from-local.sh              # sync from ~/.agents/skills
#   SKILLS_SRC=/path/to/skills scripts/sync-from-local.sh
#   scripts/sync-from-local.sh --check      # report drift, change nothing
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${SKILLS_SRC:-$HOME/.agents/skills}"
DEST="$REPO_ROOT/.agents/skills"
CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

# The full runtime closure of job-application-writer. Order is pipeline order:
# orchestrator, six pipeline skills, then the humanizer finish pass.
SKILLS=(
  job-application-writer
  job-description-analyzer
  resume-tailor
  resume-bullet-writer
  resume-ats-optimizer
  cover-letter-generator
  resume-formatter
  humanizer
)

[ -d "$SRC" ] || { echo "error: source skill dir not found: $SRC" >&2; exit 1; }

# Strip the local install's `disabled: true` line, but ONLY inside the
# YAML frontmatter block (between the first two `---` lines) and ONLY when it
# is an exact whole-line match. Body prose mentioning the word is left alone.
strip_disabled() {
  awk '
    NR == 1 && $0 == "---" { in_fm = 1; print; next }
    in_fm  && $0 == "---" { in_fm = 0; print; next }
    in_fm  && $0 == "disabled: true" { next }
    { print }
  ' "$1"
}

status=0
for s in "${SKILLS[@]}"; do
  src="$SRC/$s"
  dst="$DEST/$s"

  if [ ! -d "$src" ]; then
    echo "MISSING  $s  (not found at $src)" >&2
    status=1
    continue
  fi
  if [ ! -f "$src/SKILL.md" ]; then
    echo "BROKEN   $s  (no SKILL.md at $src)" >&2
    status=1
    continue
  fi

  tmp="$dst.SKILL.md.tmp"

  if [ "$CHECK_ONLY" -eq 1 ]; then
    # Compare without writing: streamed copy through the same transform.
    if diff -q <(strip_disabled "$src/SKILL.md") "$dst/SKILL.md" >/dev/null 2>&1; then
      echo "IN SYNC  $s"
    else
      echo "DRIFT    $s  (repo copy differs from $src)" >&2
      status=1
    fi
    continue
  fi

  mkdir -p "$dst"
  rsync -a --delete --exclude='.DS_Store' --exclude='.gitkeep' "$src/" "$dst/"
  strip_disabled "$src/SKILL.md" > "$tmp"
  mv "$tmp" "$dst/SKILL.md"
  echo "SYNCED   $s"
done

if [ "$CHECK_ONLY" -eq 1 ]; then
  [ "$status" -eq 0 ] && echo "OK: no drift between $SRC and $DEST" || echo "DRIFT FOUND" >&2
  exit "$status"
fi

echo
echo "Bundle written to $DEST"
echo "Next: scripts/validate.sh"
exit "$status"
