# job-application-writer

Write a complete job application for one role: a full ATS-compatible CV plus a
tailored cover letter, produced by a fixed stage pipeline, audited against a CV
craft standard at build time and again on the delivered file, and finished by a
humanizer pass.

You give it a role file. It reads your real career record, scores the fit,
tailors the CV to the role, checks it against an ATS, writes the cover letter in
your own voice, and reports exactly what it could not source.

Nothing is invented. Every project, employer, year, and metric in the output
traces back to a file you control, and anything the evidence does not support is
surfaced in the report instead of fabricated.

---

## What is in the box

This is a **bundle of eight skills**, not a single one. The orchestrator
delegates to the other seven and stops with an error if any of them is missing,
so they install and travel together.

| Skill | Role in the pipeline |
|---|---|
| `job-application-writer` | Orchestrator. Owns the procedure, the budgets, the CV craft standard, and the report |
| `job-description-analyzer` | Stage A. Scores the fit and extracts keywords, gaps, and talking points |
| `resume-tailor` | Stage B. Tailors the CV and picks the Interests hook |
| `resume-bullet-writer` | Stage C. Rewrites bullets around real metrics |
| `resume-ats-optimizer` | Stage D. Local ATS quality pass, capped at two iterations |
| `cover-letter-generator` | Stage E. Writes the letter in your closest past register |
| `resume-formatter` | Stage F. ATS-safe layout |
| `humanizer` | Finish. Strips AI-writing tells, then a banned-token scan |

Six of these come from third-party MIT projects, vendored so the bundle works
offline and offline-installed. Full attribution and pinned commits are in
[`NOTICE.md`](NOTICE.md).

---

## Requirements

- An agent that reads skills from a directory (`~/.agents/skills/`,
  `~/.claude/skills/`, `.cursor/skills/`, and many others). Works with Claude
  Code, Codex, Cursor, Gemini CLI, OpenCode, Hermes, and anything else that
  follows the `SKILL.md` convention.
- A workspace holding your career record and the role listings. The skill
  refuses to invent any of these.
- Bash and `jq` if you want to use the bundled tooling. The skill itself needs
  neither.
- Optional: a browser agent, used only for the external ATS score. Without one,
  the pipeline still runs and reports that score as unavailable.

---

## Install

### Option 1 — the installer (recommended)

```bash
git clone https://github.com/spiros3p/job-application-writer.git
cd job-application-writer
./scripts/install.sh --list-targets   # see where each agent keeps skills
./scripts/install.sh --target global  # or: claude, cursor, codex, gemini, opencode, project
```

`--target` also accepts any directory path if your agent is not on the list.
Add `--dry-run` to preview, `--force` to replace an existing install.

### Option 2 — Claude Code plugin

```bash
git clone https://github.com/spiros3p/job-application-writer.git
claude --plugin-dir ./job-application-writer
```

The repository is a valid plugin root. `.claude-plugin/plugin.json` registers
all eight skills from `.agents/skills/`. Validate it yourself with
`claude plugin validate ./job-application-writer`.

### Option 3 — copy it yourself

```bash
cp -R job-application-writer/.agents/skills/* ~/.agents/skills/
```

Copy **all eight**. The orchestrator checks for its dependencies and stops if any
is absent.

---

## Set up your workspace

The skill reads a workspace rooted at `~/agent-workspace/job-research/`:

```
~/agent-workspace/job-research/
├── inputs/
│   ├── career-experiance/
│   │   └── career-experiance.md      <- required. Your single source of truth.
│   ├── roles/                        <- required. One file per job listing.
│   ├── cover-letters/                <- optional. Past letters, for voice.
│   └── projects-context/             <- optional. Extra project evidence.
└── outputs/
    └── applications/                 <- written by the skill
```

> **The misspelling is not a typo in this README.** The skill looks for
> `career-experiance`, with that spelling, and stops if it is absent. Rename the
> directory and the skill will not find your files. See
> [`docs/WORKSPACE.md`](docs/WORKSPACE.md).

`inputs/roles/applied/` and `inputs/roles/archived/` are ignored entirely: never
read, never offered as candidates.

---

## Run it

Name the role file. That is the whole interface.

```
write my application for fullstack-developer-aerospacelab
```

Optional, per run:

- **Target projects** — name files in `projects-context/` to consider. Left
  unspecified, the agent picks the ones whose domain matches the role.
- **Tone override** — default is "confident, technical, fluent". Say "more
  formal", "warmer", or "shorter" to change it.

The role file is the only accepted input. Pasted ad text and URLs are rejected
by design, so every claim in the output stays traceable.

---

## What you get

One directory per run, `outputs/applications/<company>-<role-slug>/`:

| Output | File |
|---|---|
| Complete ATS-compatible CV | `<First>_<Last>-CV-<role-slug>.md` |
| Tailored cover letter | `cover-letter.md` |
| CV craft audit | `cv-audit.md` — the seven-dimension rubric at build time and on the delivered file |
| ATS evidence | `ats-checks/` with TXT inputs, scan records, and `report.md` |

Hard constraints the skill enforces on the CV: 750 words maximum, a 40-word
professional summary, at most four roles with three bullets each, and a header
limited to name, role-matched title, email, city, GitHub, and LinkedIn. Phone
numbers, work-authorisation remarks, and portfolio links are excluded on
purpose, because they break parsers and invite screening friction.

Before the CV is measured, it is held to a seven-dimension craft standard: one
primary role identity matching the posting's own title, a summary that opens
with the title rather than an adjective, result-first bullets with the exact
mechanism named second, a three-bullet recipe per role (impact, ownership,
operation), dates copied from your record and never curated, skills grouped by
the function the posting hires for, and measurement parity, so the text that was
scored is the text that ships. Every dimension is reported as `n/7` in
`cv-audit.md`, and a dimension that cannot be passed with your own evidence is
reported as a gap rather than papered over.

The chat reply reports both file paths, the initial and final ATS scores (or an
explicit unavailability), the revision count, the separate Step D assessment,
dropped roles, unsupported keywords, and anything the evidence could not cover.

---

## The external ATS check

Between bullet writing and the ATS optimiser, the skill scores the CV against the
role description on [CheckMyATS](https://checkmyats.com/resume-checker/).

- It is **optional**. No browser, a changed page, or an unreachable site produces
  a reported limitation, never a blocked application and never an invented
  score.
- A score of 80 or above triggers **no** edits. Below 80, at most two revisions
  are made, each targeting 80 to 92, adding only keywords your own files support.
- A CheckMyATS score is that site's heuristic. It is not an employer's ATS
  result and not a promise of interviews.

**Privacy.** Only the derived CV and the job description are loaded, and only
when you run the skill. Your source career files are never uploaded. The skill
carries a fixed scope for this call and will not visit another site, create an
account, or submit anything on your behalf. Page content is treated as untrusted
data rather than instructions. Details in [`SECURITY.md`](SECURITY.md) and
[`docs/PIPELINE.md`](docs/PIPELINE.md).

---

## Repository layout

```
.
├── .agents/skills/            the eight skills, verbatim
├── .agents/SKILL_DIRECTORY.md generated index of the bundle
├── .claude-plugin/            Claude Code plugin manifest
├── scripts/
│   ├── install.sh             install the bundle into any agent
│   ├── validate.sh            release gate, runs in CI
│   ├── bump-version.sh        SemVer bump across all version sources
│   └── sync-from-local.sh     maintainer: re-materialise from ~/.agents/skills
├── docs/                      install, workspace, pipeline, versioning
├── AGENTS.md                  how agents in this repo discover the bundle
├── VERSION                    canonical bundle version
├── bundle.json                machine-readable manifest with pinned provenance
└── CHANGELOG.md
```

---

## Versioning and releases

The bundle follows [SemVer](https://semver.org/), and the version lives in
`VERSION` with three mirrors that `scripts/validate.sh` keeps in agreement: the
manifest, the plugin manifest, and the orchestrator's own frontmatter.

```bash
./scripts/validate.sh --strict        # must pass before tagging
./scripts/bump-version.sh minor
# add the CHANGELOG section, then:
git commit -m "release: v1.2.0"
git tag -a v1.2.0 -m "v1.2.0"
git push origin main --follow-tags    # tag push triggers the release workflow
```

Version bumps are mechanical and never alter skill content. Read
[`docs/VERSIONING.md`](docs/VERSIONING.md) before releasing.

---

## Contributing

Issues and pull requests are welcome. See [`CONTRIBUTING.md`](CONTRIBUTING.md)
for the rules that matter most: skill content changes are versioned separately
from packaging changes, and vendored third-party skills must not be edited
in place.

## License

MIT, © 2026 Spyridon Peppas. See [`LICENSE`](LICENSE).

Bundled third-party skills remain under their own MIT licenses; see
[`NOTICE.md`](NOTICE.md).
