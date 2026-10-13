# Skill similarity report — role-application-writer (job-application-writer bundle)

- Skills compared: 8 (28 possible pairs; 12 scored after clustering)
- Threshold: 70%
- Shortlisted: 0 pairs (phase 1) → 0 pairs (phase 2)
- Deep-read rescore performed on the top 4 pairs regardless, since phase 2 did
  not gate on a shortlist
- Dropped below threshold: 12 pairs, all listed below with scores
- Special tags found: 1 `router` (`job-application-writer`), 0 stubs, 0 fixtures,
  0 disabled, 0 wrappers

**Constraint that governs every conclusion below.** Seven of the eight skills are
vendored from third-party projects and pinned to a commit in `bundle.json`.
Removal and merge are therefore *not available* for them in this repository: an
in-place change is discarded on the next upstream sync, and the orchestrator's own
`SKILL.md` names each one in a fixed pipeline stage. The two merge recipes at the
end are written for the report's completeness and are **informational only**.
Acting on either means forking upstream first.

## Clustering

Skills were grouped by purpose before scoring, not brute-forced.

| Cluster | Skills |
|---|---|
| C1 — resume content | `job-description-analyzer`, `resume-tailor`, `resume-bullet-writer` |
| C2 — ATS and layout | `resume-ats-optimizer`, `resume-formatter` |
| C3 — orchestration | `job-application-writer` (router; compared against all seven) |
| C4 — cover letter | `cover-letter-generator` |
| C5 — prose finish | `humanizer` |

Every skill appears in at least one cluster. No skill was left unscored except
where a cluster of one left no plausible partner.

## Flagged pairs

**None.** No pair reached 70% in phase 1, so no pair was shortlisted and no
removal suggestion is made. There are no duplicate suspects in this bundle.

The highest-scoring pairs, for reference:

| Pair | Phase 1 | Phase 2 | Edge A | Edge B |
|---|---|---|---|---|
| `job-description-analyzer` / `resume-ats-optimizer` | 62.5 | 50.0 | Scores the *candidate* against the posting; extracts requirements, gaps, and red flags | Scores the *document* against a parser and the posting; emits a compatibility checklist |
| `resume-ats-optimizer` / `resume-formatter` | 52.5 | 56.2 | Keyword match and ATS parsing failure diagnosis | Layout: margins, fonts, spacing, visual hierarchy |
| `resume-tailor` / `resume-bullet-writer` | 46.3 | 47.5 | Selects and reorders the material that fits the role | Rewrites individual bullets using XYZ / STAR / CAR frameworks |
| `job-application-writer` / `resume-ats-optimizer` | 46.3 | 41.3 | Runs the pipeline and owns the budgets and the report | Performs the local ATS quality pass it is delegated |

Scoring anchors: purpose 50% (same job = 100, adjacent in the same domain = 50,
unrelated = 0), triggers 25%, wording overlap 25%.

## All scored pairs (phase 1 → phase 2 where deep-read)

| Pair | Phase 1 | Phase 2 | Outcome |
|---|---|---|---|
| `job-description-analyzer` / `resume-ats-optimizer` | 62.5 | 50.0 | dropped, deep-read |
| `resume-ats-optimizer` / `resume-formatter` | 52.5 | 56.2 | dropped, deep-read |
| `resume-tailor` / `resume-bullet-writer` | 46.3 | 47.5 | dropped, deep-read |
| `job-application-writer` / `resume-ats-optimizer` | 46.3 | 41.3 | dropped, deep-read |
| `job-description-analyzer` / `resume-tailor` | 48.8 | — | dropped |
| `job-application-writer` / `cover-letter-generator` | 48.8 | — | dropped |
| `resume-tailor` / `cover-letter-generator` | 45.0 | — | dropped |
| `job-application-writer` / `job-description-analyzer` | 40.0 | — | dropped |
| `job-application-writer` / `resume-tailor` | 38.8 | — | dropped |
| `job-application-writer` / `resume-bullet-writer` | 38.8 | — | dropped |
| `job-application-writer` / `resume-formatter` | 37.5 | — | dropped |
| `humanizer` / any | ≤ 25.0 | — | dropped, no plausible partner |

Phase 2 was run on the top four because the two highest pairs carry genuine
content overlap worth measuring, not only headline overlap.

The clearest evidence that these are not duplicates is that the orchestrator
already treats them as distinct: `job-application-writer` gives each one a fixed
stage, and its own "Don't use for" clause explicitly defers single-skill work
("CV-only / letter-only requests — run the relevant external skill directly").

## Consolidation candidates (complementary overlap)

Two pairs sit below the duplicate bar but cover one coherent job between them.
Both are blocked by the vendoring constraint stated at the top.

| Pair | Purpose score | Union job | Proposed name |
|---|---|---|---|
| `resume-ats-optimizer` / `resume-formatter` | 60 | Make a resume survive an ATS and read well to a human | `resume-ats-formatter` |
| `resume-tailor` / `resume-bullet-writer` | 55 | Write and tailor the resume's content for one role | `resume-content-tailor` |

### `resume-ats-formatter`

**Purpose line.** Take a finished resume and make it pass an applicant tracking
system and read cleanly to a human, diagnosing parsing failures and fixing the
content and layout that cause them.

**Source map.**

- From `resume-ats-optimizer`: the ATS problem framing, the compatibility
  checklist (file format, fonts, section headers, contact information), the
  keyword optimisation process, and keyword-match scoring.
- From `resume-formatter`: document setup (page length, margins, font selection,
  spacing), the dual-audience framing, the ATS-safe formatting rules, and visual
  hierarchy and whitespace guidance.
- Overlap, stated once: both carry an ATS compatibility checklist covering file
  format, fonts, section headers, and contact information. Keep the union in a
  single section. This is the largest genuine duplication in the bundle.
- Conflicts: `resume-ats-optimizer` treats formatting as one factor in a
  keyword score; `resume-formatter` treats formatting as the deliverable. The
  merged skill keeps keyword optimisation as the primary output and formatting as
  the remediation applied to it. `resume-formatter`'s framing loses.

**Trigger union.** "ATS", "not getting interviews", "resume not working",
"optimize resume", "keyword optimization", "format resume", "resume layout",
"resume design", "clean resume", "professional format".

**After merge (not executable here).** Remove both sources via add-skill Mode D.
Dangling references: `job-application-writer/SKILL.md` steps 5 and 7;
`.agents/SKILL_DIRECTORY.md` rows; the `AGENTS.md` managed table; the
`Composition rules` chain lines; `bundle.json` `pipeline` and `skills[]`;
`docs/PIPELINE.md` stages D and F; the `README.md` bundle table; `CHANGELOG.md`.
Requires an upstream fork or a maintained divergence, both of which break the
pin recorded in `bundle.json`.

### `resume-content-tailor`

**Purpose line.** Turn an experience record into a CV tailored to one posting,
selecting what to emphasise and rewriting the bullets so each one carries a
sourced metric.

**Source map.**

- From `resume-tailor`: the tailoring philosophy, the audit-then-adjust
  process, and the section-by-section guide (professional summary, skills
  reordering, experience section).
- From `resume-bullet-writer`: the X-Y-Z, STAR, and CAR frameworks, the power
  verbs tables, and the weak-to-strong bullet examples.
- Overlap, stated once: `resume-tailor` already includes "modify bullet points to
  match job requirements". The merged skill keeps bullet rewriting in
  `resume-bullet-writer`'s fuller form and drops the thin version.
- Conflicts: `resume-tailor` selects bullets by role relevance;
  `resume-bullet-writer` rewrites them for impact. The merged skill keeps both
  as sequential steps and states that order explicitly, since
  `resume-tailor`'s own text already says to run the analyzer first.

**Trigger union.** "tailor resume", "customize resume", "target role",
"specific job", "match job description", "improve my bullets", "make my resume
stronger", "quantify my achievements", "results-driven".

**After merge (not executable here).** Remove both sources via add-skill Mode D.
Dangling references: `job-application-writer/SKILL.md` steps 3 and 4;
`.agents/SKILL_DIRECTORY.md` rows; the `AGENTS.md` managed table and chain
lines; `bundle.json` `pipeline` and `skills[]`; `docs/PIPELINE.md` stages B and
C; the `README.md` bundle table; `CHANGELOG.md`. Requires an upstream fork.

## Count summary

- Removals suggested: **0**
- Merges proposed: **2** (both informational; blocked by the pin)
- Expected final skill count: **8** (unchanged)

## Method note

Report-only, as specified. Exactly this file was written. No skill directory was
deleted, moved, or edited, and `SKILL_DIRECTORY.md` was not touched. All inputs
were synthetic: no CV, career history, or real job posting was read.
