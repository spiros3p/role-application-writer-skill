# Installation

## Before you start

You need an agent that discovers skills from a directory and reads `SKILL.md`.
If you are not sure, clone this repository and check
[`.agents/SKILL_DIRECTORY.md`](../.agents/SKILL_DIRECTORY.md): each row names a
skill, what it does, and where it lives.

## The rule

**Install all eight skills together.**

`job-application-writer` is an orchestrator. It reads the other seven skills'
`SKILL.md` files at run time and stops with an explicit error if any directory is
missing. A partial install is not a degraded experience, it is a broken one.

Every method below installs the complete bundle.

---

## Method 1 — the installer

```bash
git clone https://github.com/__GITHUB_HANDLE__/job-application-writer.git
cd job-application-writer

./scripts/install.sh --list-targets
```

| Target | Installs to |
|---|---|
| `global` *(default)* | `~/.agents/skills/` |
| `project` | `./.agents/skills/` from the current directory |
| `claude` | `~/.claude/skills/` |
| `cursor` | `~/.cursor/skills/` |
| `codex` | `~/.codex/skills/` |
| `gemini` | `~/.gemini/skills/` |
| `opencode` | `~/.config/opencode/skills/` |

Then:

```bash
./scripts/install.sh --target claude
```

Useful flags:

- `--dry-run` — print the plan, write nothing
- `--force` — replace existing skill directories
- any path — `./scripts/install.sh --target ~/somewhere/else/skills`

Without `--force` the installer refuses to overwrite and names what already
exists. That is deliberate; a silent overwrite of a skill you edited locally is
a bad afternoon.

The installer verifies the closure after copying and exits non-zero if any
skill or its supporting files are missing.

---

## Method 2 — Claude Code plugin

```bash
git clone https://github.com/__GITHUB_HANDLE__/job-application-writer.git
claude --plugin-dir ./job-application-writer
```

The repository is a valid plugin root: `.claude-plugin/plugin.json` declares the
metadata and points the skill scanner at `.agents/skills/`.

Validate it locally before you trust it:

```bash
claude plugin validate ./job-application-writer
```

To add it as a marketplace, point a marketplace entry at this repository. The
plugin name is `job-application-writer` and its version tracks `VERSION`, so
Claude Code keeps users on the version they installed until you change it.

---

## Method 3 — copy manually

```bash
cp -R job-application-writer/.agents/skills/* ~/.agents/skills/
```

Use `cp -R`, not `cp -R *.md`. Several skills carry supporting files:

```
job-application-writer/references/checkmyats.md   <- required, defines Step C.1
job-application-writer/references/cv-craft.md     <- required, defines Steps C.2 and G
humanizer/LICENSE
humanizer/agents/openai.yaml
```

Losing either reference leaves the orchestrator pointing at a document that is
not there.

---

## Verify

```bash
ls ~/.agents/skills/job-application-writer/
# SKILL.md
# references/
```

```bash
for s in job-application-writer job-description-analyzer resume-tailor \
         resume-bullet-writer resume-ats-optimizer cover-letter-generator \
         resume-formatter humanizer; do
  [ -f ~/.agents/skills/$s/SKILL.md ] && echo "ok   $s" || echo "MISS $s"
done
```

All eight must print `ok`.

Then set up the workspace ([`WORKSPACE.md`](WORKSPACE.md)) and restart your
agent so it rescans its skills directory.

---

## Upgrading

```bash
cd job-application-writer
git pull
./scripts/install.sh --target <same target> --force
```

Or, without the clone, pull a single release archive and extract:

```bash
curl -sSL https://github.com/__GITHUB_HANDLE__/job-application-writer/archive/refs/tags/v1.1.0.tar.gz \
  | tar xz && cp -R job-application-writer-1.1.0/.agents/skills/* ~/.agents/skills/
```

Pin a tag if you need reproducibility. `--force` replaces the whole directory,
so any local edits you made to an installed copy are lost. Keep local edits in
your own fork, not in the install directory.

---

## Uninstalling

```bash
for s in job-application-writer job-description-analyzer resume-tailor \
         resume-bullet-writer resume-ats-optimizer cover-letter-generator \
         resume-formatter humanizer; do
  rm -rf ~/.agents/skills/$s
done
```

For Claude Code, remove the plugin instead:

```bash
claude plugin uninstall job-application-writer
```

Your workspace under `~/agent-workspace/job-research/` is untouched by either.
Delete it separately if you want it gone.

---

## After installing

1. Create the workspace layout. See [`WORKSPACE.md`](WORKSPACE.md).
2. Fill in `inputs/career-experiance/career-experiance.md` with every role,
   project, and number you would cite.
3. Drop one job listing into `inputs/roles/`.
4. Restart the agent.
5. Ask by role file name: `write my application for <role-file>`.
