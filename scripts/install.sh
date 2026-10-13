#!/usr/bin/env bash
#
# Install the job-application-writer skill bundle into any agent's skills directory.
#
# The bundle is eight skills, not one: the orchestrator delegates to six pipeline
# skills plus a humanizer pass, and it stops with an error if any of them is
# missing. This script always installs the complete closure.
#
# Usage:
#   scripts/install.sh                       # install globally to ~/.agents/skills
#   scripts/install.sh --list-targets        # show supported target presets
#   scripts/install.sh --target claude       # ~/.claude/skills
#   scripts/install.sh --target ./my-skills  # any directory
#   scripts/install.sh --dry-run            # show the plan, change nothing
#   scripts/install.sh --force              # overwrite existing skill directories
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/.agents/skills"

# The complete runtime closure. Order is pipeline order and is only for output.
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

TARGET=""
FORCE=0
DRY_RUN=0

usage() { sed -n '2,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

list_targets() {
  cat <<'EOF'
Named targets:

  global     ~/.agents/skills          agents-standard default (Hermes, Codex, and compatible agents)
  project    ./.agents/skills          project-local, resolved from the current directory
  claude     ~/.claude/skills          Claude Code
  cursor     ~/.cursor/skills          Cursor
  codex      ~/.codex/skills           Codex CLI
  gemini     ~/.gemini/skills          Gemini CLI
  opencode   ~/.config/opencode/skills OpenCode

Any other value is used verbatim as a destination directory.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -t|--target) TARGET="${2:-}"; shift 2 ;;
    -f|--force)  FORCE=1; shift ;;
    -n|--dry-run) DRY_RUN=1; shift ;;
    --list-targets) list_targets; exit 0 ;;
    -h|--help)   usage; exit 0 ;;
    *) echo "error: unknown option: $1" >&2; echo >&2; usage >&2; exit 2 ;;
  esac
done

[ -d "$SRC" ] || { echo "error: bundle not found at $SRC" >&2; exit 1; }

case "${TARGET:-global}" in
  global)   DEST="$HOME/.agents/skills" ;;
  project)  DEST="$(pwd)/.agents/skills" ;;
  claude)   DEST="$HOME/.claude/skills" ;;
  cursor)   DEST="$HOME/.cursor/skills" ;;
  codex)    DEST="$HOME/.codex/skills" ;;
  gemini)   DEST="$HOME/.gemini/skills" ;;
  opencode) DEST="$HOME/.config/opencode/skills" ;;
  "")       DEST="$HOME/.agents/skills" ;;
  *)        DEST="$TARGET" ;;
esac

[ "${DRY_RUN}" -eq 1 ] && PREFIX="would install" || PREFIX="installing"

echo "Source:  $SRC"
echo "Target:  $DEST"
echo

if [ "$FORCE" -eq 0 ]; then
  clash=0
  for s in "${SKILLS[@]}"; do
    if [ -d "$DEST/$s" ]; then
      echo "  exists  $s" >&2
      clash=1
    fi
  done
  if [ "$clash" -eq 1 ]; then
    echo >&2
    echo "Refusing to overwrite. Re-run with --force to replace existing skills," >&2
    echo "or choose another target with --target." >&2
    exit 1
  fi
fi

if [ "$DRY_RUN" -eq 0 ]; then
  mkdir -p "$DEST"
fi

for s in "${SKILLS[@]}"; do
  [ -f "$SRC/$s/SKILL.md" ] || { echo "error: bundle incomplete, missing $s/SKILL.md" >&2; exit 1; }
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  $PREFIX  $s"
  else
    rm -rf "${DEST:?}/${s:?}"
    cp -R "$SRC/$s" "$DEST/$s"
    find "$DEST/$s" -name '.DS_Store' -delete 2>/dev/null || true
    echo "  installed  $s"
  fi
done

if [ "$DRY_RUN" -eq 1 ]; then
  echo
  echo "Dry run. Nothing was written."
  exit 0
fi

# Post-install verification: every skill present with a readable SKILL.md.
fail=0
for s in "${SKILLS[@]}"; do
  [ -r "$DEST/$s/SKILL.md" ] || { echo "  MISSING  $s/SKILL.md" >&2; fail=1; }
done

if [ "$fail" -ne 0 ]; then
  echo >&2
  echo "Install finished with errors: the closure is incomplete and the skill will not run." >&2
  exit 1
fi

echo
echo "Verified: all 8 skills present in $DEST"
echo
cat <<EOF
Next steps

  1. Set up the workspace the skill reads from. It expects:
       $HOME/agent-workspace/job-research/inputs/career-experiance/career-experiance.md
       $HOME/agent-workspace/job-research/inputs/roles/<role-file>
     See docs/WORKSPACE.md - the filename spelling matters.

  2. Restart your agent so it rescans its skills directory.

  3. Ask for an application by naming the role file:
       "write my application for <role-file>"

Documentation: docs/INSTALL.md, docs/WORKSPACE.md, docs/PIPELINE.md
EOF
