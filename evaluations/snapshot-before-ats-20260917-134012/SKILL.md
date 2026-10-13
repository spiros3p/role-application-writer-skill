---
name: job-application-writer
description: >-
  Write a complete job application for one role — a full ATS-compatible CV plus
  a tailored cover letter — by running a fixed six-skill pipeline
  (job-description-analyzer, resume-tailor, resume-bullet-writer,
  resume-ats-optimizer, cover-letter-generator, resume-formatter) over the
  job-research workspace, finished with a humanizer pass on both files. Use when
  the user names a role file and wants the application pair, asks to apply for a
  specific job, or wants a tailored CV and cover letter produced together.
version: 1.0.0
author: Spyridon Peppas, Hermes Agent
license: MIT
platforms:
  - macos
  - linux
  - windows
metadata:
  hermes:
    tags:
      - job-search
      - writing
      - cover-letter
      - cv
      - ats
    related_skills:
      - job-description-analyzer
      - resume-tailor
      - resume-bullet-writer
      - resume-ats-optimizer
      - cover-letter-generator
      - resume-formatter
      - humanizer
disabled: true
---

# Job Application Writer

Orchestrator skill. Produces two files for one target role: a complete
ATS-compatible CV and a tailored cover letter. Runs six external skills in
a fixed sequence, feeding each step explicit inputs from the workspace,
then finishes both files with a humanizer pass.

Workspace root: `~/agent-workspace/job-research/`

- `inputs/career-experiance/career-experiance.md` — all-in-one experience
  file. Sole source for CV content.
- `inputs/cover-letters/` — past cover letters. Voice and attitude
  reference only.
- `inputs/projects-context/` — extra project evidence. Use files whose
  domain matches the role.
- `inputs/roles/<role-file>` — target role listing. The file name is
  prompted from the user on every run. `inputs/roles/applied/` and
  `inputs/roles/archived/` are ignored entirely: never read from them,
  never offer them as candidates.

## When to Use

- The user names a role file and wants the full application pair (CV +
  cover letter).
- The user says "apply for this role", "write my application for X", or
  wants a tailored CV and cover letter produced together.
- The same pipeline must run every time so output quality stays
  consistent.

Don't use for: mass-generating generic applications, cold emails without
a specific role file, interview prep, or CV-only / letter-only requests
(run the relevant external skill directly for those).

## Prerequisites

- The workspace exists with `inputs/career-experiance/career-experiance.md`
  and `inputs/roles/` containing at least one role file outside
  `applied/` and `archived/`. If a folder is missing, stop and say so —
  never invent files.
- Each external skill is invoked by reading its `SKILL.md` and following
  it with the inputs named below. If an external skill's directory is
  missing, stop and report which one before producing anything.

## Inputs (what the user provides per run)

1. **Role file name** — prompted every run. Resolved strictly as
   `inputs/roles/<name>`. If the file is missing, stop: list the
   available role files (excluding `applied/` and `archived/`) and ask
   which one to use. Pasted ad text and URLs are not accepted — the role
   file is the only source.
2. **(Optional) Target projects** — names of files in
   `projects-context/` to consider. If not given, the agent picks the
   ones whose domain matches the role.
3. **(Optional) Tone override** — default is "confident, technical,
   fluent." Say "more formal" / "warmer" / "shorter" to change it.

## Outputs (what the agent produces)

One directory per run,
`outputs/applications/<company>-<role-slug>/`, containing:

| Output | File | Format |
|---|---|---|
| Complete CV, ATS compatible | `<First>_<Last>-CV-<role-slug>.md` (e.g. `Spyridon_Peppas-CV-fullstack-developer-aerospacelab.md`) | markdown, ≤750 words so it fits under 2 A4 pages in PDF form, with an Interests section (see Step B) |
| Tailored cover letter | `cover-letter.md` | markdown |

CV title line: `# <Name> - <Role as named in the application>`. CV header
whitelist: name, role-matched title, email, city, GitHub, LinkedIn. Banned
from the header: phone numbers, work-authorization and sponsorship remarks,
portfolio links.

Slug rule: `<company>-<role-slug>` lowercased, spaces become `-`, all
other punctuation stripped. Example:
`outputs/applications/payflip-senior-software-engineer/`.

## Procedure

Follow every step in order. Do not skip steps even if the user seems
impatient — the discipline is the point.

0. **Resolve the role.** Take the file name from the user, read
   `inputs/roles/<name>`. Missing file: stop, list available role files
   (excluding `applied/` and `archived/`), ask. Pull out: title,
   company, must-haves, nice-to-haves, domain keywords.
1. **Load base materials.** Read `career-experiance.md` end to end and
   keep it in context — every project, every tech, every metric. Read
   every file under `cover-letters/` (voice reference) and the relevant
   files under `projects-context/`.
2. **Step A — job-description-analyzer.** Read its `SKILL.md` and follow
   it with the role file as input. Keep for downstream steps: match
   score, required/preferred keyword lists, gaps, cover-letter talking
   points.
3. **Step B — resume-tailor.** Read its `SKILL.md` and follow it with
   the analyzer output plus `career-experiance.md`. Produces the
   tailored CV draft and the keyword plan. Hard CV budgets apply on top
   of that skill's guidance: Professional Summary ≤40 words; Education
   ≤2 lines; at most 4 roles in Experience, at most 3 bullets each;
   whole file ≤750 words.
   **Relevance filter:** drop any role with zero skill or keyword
   overlap with the target (e.g. pure electrical-installation work for
   a software role). Every dropped role is named in the final report —
   no silent cuts. **Interests choice happens
   here:** pick at least one interest grounded in
   `career-experiance.md` and write it as a reviewer hook — an
   interesting, true fact about the person that invites follow-up in an
   interview or informal conversation, not angled at the target role.
   The choice pipes down the workflow into the final CV's Interests
   section.
4. **Step C — resume-bullet-writer.** Read its `SKILL.md` and follow it
   on the draft's bullets. Strengthen wording and metrics using only
   numbers present in the source materials — never invent metrics.
5. **Step D — resume-ats-optimizer.** Read its `SKILL.md` and follow it
   against the draft plus the role keywords. Iterate at most 2 passes
   on reported failures, then stop and report the final score either
   way — no endless loop.
6. **Step E — cover-letter-generator.** Read its `SKILL.md` and follow
   it with the analyzer output, `career-experiance.md`, the relevant
   `projects-context/` files, and the `cover-letters/` file closest in
   target domain as voice reference (most recent is the tiebreaker,
   never the primary signal). Draft per that skill's structure: hook
   opening, body anchored to concrete projects with verbatim metrics,
   confident closing.
7. **Step F — resume-formatter.** Read its `SKILL.md` and follow it on
   the final CV draft for the layout and formatting pass.
8. **humanizer final touch.** Runs by default on both exported files
   every run. Read the `humanizer` SKILL.md and apply it to the CV file
   and `cover-letter.md`, using the closest-domain past letter for
   voice calibration where the humanizer supports it. Then run a
   mechanical banned-token scan over both files: em dashes (—), plus
   the humanizer's AI-vocabulary list (delve, moreover, additionally,
   furthermore, pivotal, landscape, tapestry, and the like). Any hit
   forces another humanizer pass on that file, at most 2 passes, then
   stop and report remaining residue in the final report.
9. **Save both files** to `outputs/applications/<company>-<role-slug>/`
   via `write_file`.
10. **Verify.** `read_file` both saved files back and confirm they
    match. Confirm the CV contains the Interests section and the final
    ATS score is on record.
11. **Report.** In the chat: one paragraph summary, both absolute
    paths, the final ATS score, and anything that could not be sourced
    from workspace materials (gaps the user should know about).

## Voice rules (the "knows what they're talking about" standard)

Non-negotiable unless the user explicitly overrides tone.

- **Concrete over abstract.** "Cut test pipeline from 10+ min to 1-3
  min" beats "improved developer productivity."
- **Stack-named, not generic.** Name tools, versions, services.
- **No hedging.** Cut "I believe," "I feel," "I think I can." State it.
- **Short sentences when stakes are high.** A metric line is a single
  line.
- **No buzzword salads.** If a word could sit on a generic list
  ("passionate," "driven," "synergy"), it is banned.
- **Mirror the closest past letter's register.** Warm-professional, not
  stiff. The humanizer pass enforces this last.

## Pitfalls

- **Don't invent.** Every project, employer, year, metric, and tech in
  both files must trace back to `career-experiance.md` or a
  `projects-context/` file. Unevidenced role requirements get surfaced
  in the report, never fabricated.
- **Don't echo the job ad.** Restating requirements wastes space. Show,
  don't restate.
- **Interests must be experience-grounded.** An interest with no anchor
  in `career-experiance.md` is cut, however charming. Role relevance is
  not required; truth is.
- **Never touch `applied/` or `archived/`.** Not as input, not as
  output. Finished applications live only under
  `outputs/applications/`.
- **Role file only.** No pasted ad text, no URLs. A missing file stops
  the run.
- **humanizer always runs.** Step 8 is not optional and needs no
  separate user ask. The old "only on request" rule is dead.
- **Don't reorder the pipeline.** Analyzer before tailor, optimizer
  before cover letter, formatter before humanizer. Each step consumes
  the previous step's output.

## Verification

- Both files exist at the expected paths (verified with `read_file`):
  `<First>_<Last>-CV-<role-slug>.md` plus `cover-letter.md`.
- CV is ≤750 words, title line follows `# <Name> - <Role>`, header
  contains no phone, no authorization/sponsorship remark, no portfolio
  link. Summary ≤40 words, Education ≤2 lines.
- CV names only real projects, employers, tech, and metrics from
  workspace sources, and contains a non-empty Interests section.
- Final ATS score recorded and reported, after at most 2 optimizer
  passes.
- Banned-token scan clean (or residue reported) after at most 2
  humanizer passes per file.
- Dropped-as-irrelevant roles named in the report.
- The chat reply includes both absolute paths, the ATS score, and a
  one-paragraph summary.
