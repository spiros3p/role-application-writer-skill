# Changelog

All notable changes to **job-application-writer** are documented here.

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
The bundle version in [`VERSION`](VERSION) is the canonical number; every
release is tagged `v<version>` and matches the orchestrator skill's own
`version:` frontmatter field.

## [Unreleased]

### Added

- **`scripts/check-rules.sh`, wired into the release gate.** The bundle is
  instructions an agent follows, so every other gate check is structural and
  none of them can tell whether a rule survived an edit: a compression pass or a
  careless rewrite can drop a threshold or a refusal and the build stays green.
  The new check pins the load-bearing phrases (budgets, thresholds, refusal
  rules, the measurement-parity rule) and the rubric's seven-dimension shape.
  Markdown emphasis, dash style and line wrapping are normalised away first, so
  restyling and re-compressing raise no false alarm. Verified to fire on a
  reworded phrase, a dropped rubric dimension and a changed C.1 threshold, and
  to stay quiet on a re-wrapped paragraph.

### Changed

- **`evaluations/` is now the skill's agent workspace.** The v1.1.0 behavioural
  regression record and the two earlier skill snapshots moved out of
  `~/.agents/workspaces/job-application-writer/` into the repository, and that
  workspace path is now a symlink to `evaluations/`. The workspace resolves
  into the repo instead of holding a second copy that drifts out of date. It
  points at the subdirectory rather than the repository root on purpose: a
  workspace  cleanup is routine, and a `rm -rf` aimed at the root would take the
  skill source with it.

- **The installed skill is now a pointer, not a copy.** The file agents load
  at `~/.agents/skills/job-application-writer/SKILL.md` contains only the path
  to the repository copy, so the installed skill can no longer drift out of
  date. The last full installed copy (1.1.0) was archived first as
  `evaluations/snapshot-1.1.0/` — it existed nowhere else, including the git
  history.

## [1.2.0] - 2026-10-13

Adds a CV craft layer. The ATS axis already measured keyword coverage; nothing
measured whether the CV asks to be read as one role, whether the bullets read as
a career, or whether the dates hold up. This release adds that standard, applies
it as a bounded audit before the external measurement, and re-checks it on the
delivered file.

### Added

- **`references/cv-craft.md`.** The CV craft standard: positioning (one primary
  role, the posting's own title, compound only when the posting is), summary
  shape, result-first bullet construction, the three-bullet recipe per role
  (impact, ownership, operation), the progression and date-integrity rules,
  function-grouped skills, the structure and measurement-parity rules, and the
  seven-dimension rubric — plus the list of things the standard refuses.
- **Step C.2 — CV craft audit.** One bounded repair pass on the Step C draft,
  offline, scored `n/7`. A dimension that cannot be passed with workspace
  evidence stays failed and is reported as a gap. A low count never blocks
  delivery.
- **Step G — final CV craft check.** The same seven dimensions, read-only, on
  the delivered file, to catch drift the formatter or the humanizer introduced.
- **`cv-audit.md`.** Per-application craft evidence, alongside the existing
  `ats-checks/` directory: both rubric counts, repairs applied, and residual
  failures.

### Changed

- **The measured draft is now the content-final draft.** CheckMyATS is taken
  after the Step C.2 audit, so the score always covers the text the pipeline has
  settled on. The C.1 thresholds, the 80–92 target, and the two-revision budget
  are unchanged.
- **Measurement parity is enforced.** A measurement taken before a later CV edit
  is void and is reported as superseded rather than carried forward. A Step G
  repair that changes content re-runs the humanizer scan and the final
  CheckMyATS measurement for that file.
- **The report and the chat reply** now carry the two craft rubric counts, the
  residual failing dimensions, and any superseded measurement, alongside the
  scores they already carried.
- **Stage labels are documented as identifiers, not chronology.** The run order
  is `B → C → C.2 → C.1 → D → E → F → H → G`.

### Notes

- No vendored skill was edited; the craft layer lives in the orchestrator and
  its references, so the upstream pins stand.
- The rubric is deliberately not a numeric optimisation target. It has no
  ceiling, no chasing score, and no licence to invent evidence to pass a
  dimension.
- The orchestrator and both references were compressed for agent reading
  (about 7% fewer words) with the rules from the `caveman-compress` skill.
  Headings, fenced code, inline code, paths, thresholds, and the full rule set
  are unchanged; the pre-compression text is in the skill's out-of-tree backup
  directory and the bundle gate still passes.

## [1.1.0] - 2026-10-03

First public release of the bundle. The skill itself had reached 1.1.0 through
private development; this entry records the change that separated it from 1.0.0
plus the packaging that makes it distributable.

### Added

- **Step C.1 — external ATS scoring.** Between bullet writing and the ATS
  optimizer, the pipeline now measures the CV against the full role description
  on CheckMyATS and, when the initial score is below 80, revises toward an
  80–92 target. The revision budget is capped at two drafts, each rescanned,
  and only keywords supported by workspace evidence may be added.
- **`references/checkmyats.md`.** New reference document defining the browser
  procedure, the standing permission and its scope limits, the bounded revision
  policy, the evidence a completed scan must record, and nine regression cases.
- **`ats-checks/` output directory.** Per-application evidence: faithful TXT
  exports of the CV and role description, a scan record per measurement with
  SHA-256 input hashes, and a `report.md` summarising scores, source-backed
  edits, gaps, and warnings.
- **Measurement-only final verification.** After formatting and humanizing, one
  final CheckMyATS scan records the delivered CV's score without reopening the
  revision loop. Results may be reused only when both input hashes match.
- **Distribution repository.** Installer, validator, and version-bump tooling,
  a machine-readable bundle manifest with pinned upstream provenance, Claude Code
  plugin manifest, CI gate, and release workflow.

### Changed

- **Step D (resume-ats-optimizer) is now explicitly separate from the measured
  score.** Its assessment is reported on its own and any model-derived score is
  labelled an estimate. It may make normal quality corrections but must not
  launch a second external optimisation loop or pursue 100.
- **Reporting.** The chat reply now carries the initial and final CheckMyATS
  scores (or an explicit unavailability), the revision count, the separate Step D
  assessment, the ATS report path, dropped roles, unsupported keywords, and
  website failures.
- **Degradation is explicit.** Failure to reach the target, or to reach the site
  at all, never blocks delivery. The limitation is reported rather than hidden,
  and an unavailable result is recorded as unavailable — never as zero.

### Security

- Page content from CheckMyATS is treated as untrusted data, never as agent
  instructions. A page that asks for source uploads, unsupported qualifications,
  or a different service is ignored.
- Standing permission is scoped to loading the derived CV and the role
  description. It does not extend to other sites, account creation, payment, job
  submission, or sending whole career-source files.

### Notes

- Versions before 1.0.0 were developed privately and are not tracked here. The
  1.0.0 to 1.1.0 delta is the substantive change; everything else in this
  repository is new packaging.
