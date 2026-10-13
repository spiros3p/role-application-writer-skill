# Workspace

`job-application-writer` reads from a workspace you control and writes results
back into it. Nothing is fetched from the network except the optional ATS score.

## Location

```
~/agent-workspace/job-research/
```

The path is fixed in the skill. If you keep your workspace elsewhere, symlink it
rather than editing the skill:

```bash
mkdir -p ~/agent-workspace
ln -s /your/actual/path ~/agent-workspace/job-research
```

## Layout

```
~/agent-workspace/job-research/
├── inputs/
│   ├── career-experiance/
│   │   └── career-experiance.md     REQUIRED
│   ├── roles/                       REQUIRED
│   │   ├── <company>-<role>.md
│   │   ├── applied/                 IGNORED ENTIRELY
│   │   └── archived/                IGNORED ENTIRELY
│   ├── cover-letters/               optional
│   └── projects-context/            optional
└── outputs/
    └── applications/                written by the skill
```

## The filename spelling

**`career-experiance` is spelled that way on purpose.** It appears three times:
the directory name, the file name, and the path the skill resolves. It is not a
typo in this repository's documentation, and correcting it breaks the skill.

```bash
mkdir -p ~/agent-workspace/job-research/inputs/career-experiance
$EDITOR ~/agent-workspace/job-research/inputs/career-experiance/career-experiance.md
```

The skill stops with a clear message if this file is missing. It will not guess,
and it will not start from a partial record.

### What goes in it

One all-in-one experience file holding everything you might cite: every role,
project, technology, and number. It is the **sole source for CV content**, so
the more complete it is, the better the tailoring.

```markdown
## Acme Corp — Senior Software Engineer (2023–present)
- Cut CI pipeline runtime from 12 min to 2 min by parallelising the test matrix
- Migrated 40 services to Kubernetes with zero downtime across 6 releases
- Mentored 3 engineers; two promoted within a year

## Project: orderbook
- Rust matching engine, 120k orders/sec on a single `c7i.4xlarge`
- Owned end to end: design, implementation, on-call, postmortems
```

Numbers matter enormously. Every metric in the output comes from this file, and
the skill is forbidden from inventing one. A bare claim like "improved
developer productivity" earns nothing; "12 min to 2 min" is the whole point.

## `inputs/roles/`

One file per job listing, named however you like. The file name is what you
pass when you ask for an application.

```bash
$EDITOR ~/agent-workspace/job-research/inputs/roles/fullstack-developer-aerospacelab.md
```

The **role file is the only accepted input.** Pasted ad text and URLs are
rejected by design: routing every claim back to a file you can audit is what
makes the output trustworthy. If the named file is missing, the skill lists the
available role files and asks.

Move a listing into `applied/` or `archived/` once you are done with it. Those
directories are skipped completely: never read, never suggested.

## `inputs/cover-letters/` — optional

Past letters, used only as a **voice and register reference**. Closest domain
wins, most recent breaks a tie.

This is how the output stops sounding like a template. If your past letters are
stiff, your new one will be stiff, and the skill will not notice that this is a
problem.

## `inputs/projects-context/` — optional

Extra project evidence for things that never made it into a CV. Name the files
worth considering when you ask for an application, or let the skill pick the ones
whose domain matches the role.

```bash
# or just say:
write my application for fullstack-developer-aerospacelab,
and use the orderbook and payments-gateway projects
```

## Output

Each run writes one directory:

```
outputs/applications/<company>-<role-slug>/
├── <First>_<Last>-CV-<role-slug>.md
├── cover-letter.md
├── cv-audit.md              the seven-dimension craft rubric, at C.2 and at G
└── ats-checks/
    ├── initial.txt          faithful plain-text export of the content-final CV
    ├── role.txt             the complete role description
    ├── revision-1.txt       only when a revision was made
    ├── revision-2.txt
    ├── final.txt            post-formatting, post-humanizing
    └── report.md            scores, edits, gaps, warnings, input hashes
```

The slug is the company and role, lowercased, spaces to hyphens, other
punctuation stripped: `payflip-senior-software-engineer`.

## Keeping it private

This workspace contains your career record in one file. Keep it out of version
control. If you initialised a repo there, add at least:

```gitignore
outputs/
cache/
.DS_Store
```

The root `.gitignore` of this repository already blocks `inputs/`, `outputs/`,
and `career-experiance.md`, which covers the case where you work inside a
checkout of it.

## Troubleshooting

**"The workspace exists with `inputs/career-experiance/career-experiance.md`"**
The path is wrong somewhere. Check the spelling twice. `experience` will not
work.

**"If an external skill's directory is missing, stop and report which one"**
The bundle is incomplete. Re-run `scripts/install.sh --force`. All eight skills
must be present together.

**"list the available role files"**
Your file is in `applied/` or `archived/`, both of which are ignored entirely.
Move it up one level.

**Everything is reported as a gap**
Your experience file is thin on evidence. The skill will not fill holes, which
is the feature. Add projects and numbers to `career-experiance.md`.
