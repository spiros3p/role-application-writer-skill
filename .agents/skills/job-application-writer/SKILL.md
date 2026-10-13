---
name: job-application-writer
description: >-
  Write a complete job application for one role — a full ATS-compatible CV plus
  a tailored cover letter — by running a fixed six-skill pipeline
  (job-description-analyzer, resume-tailor, resume-bullet-writer,
  resume-ats-optimizer, cover-letter-generator, resume-formatter) over the
  job-research workspace, finished with a humanizer pass on both files, and
  audited against a seven-dimension CV craft rubric. Use when
  the user names a role file and wants the application pair, asks to apply for a
  specific job, or wants a tailored CV and cover letter produced together.
version: 1.2.0
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
---

# Job Application Writer

Orchestrator. One target role → ATS-compatible CV + tailored cover letter +
CV craft audit. Six external skills run in fixed sequence, each fed explicit
workspace inputs. CV held to the craft standard in `references/cv-craft.md`.
Both written files finished by a humanizer pass. Between Steps C and D, run
CheckMyATS against the CV and full role description; read
`references/checkmyats.md` first — browser procedure, standing permission,
bounded revision policy, evidence requirements.

Workspace root: `~/agent-workspace/job-research/`

- `inputs/career-experiance/career-experiance.md` — experience file. Sole source
  for CV content.
- `inputs/cover-letters/` — past cover letters. Voice/attitude reference only.
- `inputs/projects-context/` — extra project evidence. Use domain-matching files.
- `inputs/roles/<role-file>` — target role listing. File name prompted from the
  user every run. `inputs/roles/applied/` and `inputs/roles/archived/` ignored
  entirely: never read, never offered as candidates.

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

- Workspace exists with `inputs/career-experiance/career-experiance.md` and
  `inputs/roles/` holding at least one role file outside `applied/` and
  `archived/`. Missing folder: stop, say so, never invent files.
- Invoke each external skill by reading its `SKILL.md` and following it with the
  inputs named below. Missing dependency directory: stop, name it, produce
  nothing.

## Inputs (what the user provides per run)

1. **Role file name** — prompted every run. Resolved strictly as
   `inputs/roles/<name>`. Missing file: stop, list available role files
   (excluding `applied/` and `archived/`), ask which. Pasted ad text and URLs
   rejected — the role file is the only source.
2. **(Optional) Target projects** — files in `projects-context/` to consider.
   Omitted: the agent picks domain-matching ones.
3. **(Optional) Tone override** — default "confident, technical, fluent." Say
   "more formal" / "warmer" / "shorter" to change it.

## Outputs (what the agent produces)

One directory per run,
`outputs/applications/<company>-<role-slug>/`, containing:

| Output | File | Format |
|---|---|---|
| Complete CV, ATS compatible | `<First>_<Last>-CV-<role-slug>.md` (e.g. `Spyridon_Peppas-CV-fullstack-developer-aerospacelab.md`) | markdown, ≤750 words (under 2 A4 pages in PDF form), with an Interests section (see Step B) |
| Tailored cover letter | `cover-letter.md` | markdown |
| CV craft audit | `cv-audit.md` | markdown; seven-dimension rubric scored at Step C.2 and again at Step G, with repairs applied and residual failures named |
| External ATS evidence | `ats-checks/` | TXT inputs and scan records; `report.md` summarizes scores, source-backed edits, gaps, warnings |

CV title line: `# <Name> - <Role as named in the application>`. CV header
whitelist: name, role-matched title, email, city, GitHub, LinkedIn. Banned
from the header: phone numbers, work-authorization/sponsorship remarks,
portfolio links.

Slug rule: `<company>-<role-slug>` lowercased, spaces become `-`, other
punctuation stripped. Example:
`outputs/applications/payflip-senior-software-engineer/`.

## Procedure

Follow every step in order. Never skip, however impatient the user — the
discipline is the point.

0. **Resolve the role.** Read `inputs/roles/<name>` from the user's file name.
   Missing: stop, list available role files (excluding `applied/` and
   `archived/`), ask. Extract: title, company, must-haves, nice-to-haves,
   domain keywords.
1. **Load base materials.** Read `career-experiance.md` end to end, keep in
   context — every project, tech, metric. Read every file under
   `cover-letters/` (voice reference) and the relevant files under
   `projects-context/`.
2. **Step A — job-description-analyzer.** Read its `SKILL.md`, follow with the
   role file as input. Keep for downstream steps: match score,
   required/preferred keyword lists, gaps, cover-letter talking points.
3. **Step B — resume-tailor.** Read its `SKILL.md`, follow with the analyzer
   output plus `career-experiance.md`. Produces the tailored CV draft and the
   keyword plan. Hard CV budgets on top of that skill's guidance: Professional
   Summary ≤40 words; Education ≤2 lines; at most 4 roles in Experience, at
   most 3 bullets each; whole file ≤750 words.
   **Relevance filter:** drop any role with zero skill or keyword
   overlap with the target (e.g. pure electrical-installation work for
   a software role). Name every dropped role in the final report —
   no silent cuts. **Interests choice happens
   here:** pick at least one interest grounded in
   `career-experiance.md`, written as a reviewer hook — true, interesting,
   invites follow-up in an interview or informal conversation, not angled at
   the target role. Pipes down into the final CV's Interests
   section. Write the whole draft to the craft standard in
   `references/cv-craft.md`: positioning, summary shape, bullet
   construction, skills grouping settle here, before the bullets are polished.
4. **Step C — resume-bullet-writer.** Read its `SKILL.md`, follow on the
   draft's bullets. Strengthen wording and metrics using only
   numbers present in the source materials — never invent metrics. The
   craft standard in `references/cv-craft.md` governs the result: result
   first, mechanism second, exact tool names, one primary metric per
   bullet.
5. **Step C.2 — CV craft audit.** Read `references/cv-craft.md`, run its
   seven-dimension rubric on the Step C draft: positioning, summary
   shape, bullet construction, impact tier, progression and dates, skills
   grouping, structure and parity. One bounded repair pass, fixing every
   failed dimension that workspace evidence supports. A dimension that
   fails for want of evidence stays failed, reported as a gap — the
   rubric never licenses a claim. Stage labels are identifiers, not
   chronology: C.2 runs before C.1. Write the scored rubric table, the
   repairs, and any residual failures to `cv-audit.md` in the run
   directory. A low count never blocks delivery.
6. **Step C.1 — CheckMyATS.** Follow `references/checkmyats.md`. Scan the
   content-final draft — the Step C.2 output — with the full role description
   first. Initial
   score **>=80, including exactly 80 and scores above 92**: no
   CheckMyATS-driven edits. Initial score **<80**: revision loop opens, target
   **80–92 inclusive**, not 100, stop at the first in-range result. At most
   **2 revised drafts**, each rescanned. Add only relevant missing keywords
   supported by workspace evidence; stop earlier if nothing supported remains
   or progress stalls. A revision overshooting 92: stop and report it, never
   degrade truthful content to force a lower score. Keep the best valid draft.
   Unreached target or unreachable site never blocks the application: continue
   and report the warning. Never substitute an invented score.
7. **Step D — resume-ats-optimizer.** Read its `SKILL.md`, follow against the
   retained draft plus the role keywords. Iterate at most 2
   passes on reported failures. Keep its assessment separate from the
   measured CheckMyATS score; label any model-derived score as an estimate.
   Never restart C.1 or pursue 100. An initial CheckMyATS pass skips only
   C.1 score-driven editing, not the normal downstream quality steps.
8. **Step E — cover-letter-generator.** Read its `SKILL.md`, follow
   with the analyzer output, `career-experiance.md`, the relevant
   `projects-context/` files, and the `cover-letters/` file closest in
   target domain as voice reference (most recent is the tiebreaker,
   never the primary signal). Draft per that skill's structure: hook
   opening, body anchored to concrete projects with verbatim metrics,
   confident closing.
9. **Step F — resume-formatter.** Read its `SKILL.md`, follow on
   the final CV draft for the layout and formatting pass.
10. **humanizer final touch.** Runs by default on both exported files
   every run. Read the `humanizer` SKILL.md, apply it to the CV file
   and `cover-letter.md`, using the closest-domain past letter for
   voice calibration where the humanizer supports it. Then run a
   mechanical banned-token scan over both files: em dashes (—), plus
   the humanizer's AI-vocabulary list (delve, moreover, additionally,
   furthermore, pivotal, landscape, tapestry, and the like). Any hit
   forces another humanizer pass on that file, at most 2 passes, then
   stop and report remaining residue in the final report.
11. **Step G — final CV craft check.** Re-run the seven dimensions from
    `references/cv-craft.md`, read-only, against the delivered file. Catches
    drift the formatter or the humanizer introduced. Record the
    second count and the dimensions checked in `cv-audit.md`. A repair is
    allowed only for a dimension that passed at C.2, one pass maximum, and
    any repair that changes content voids the humanizer token scan and the
    final CheckMyATS measurement for that file: re-run both and report the
    earlier score as superseded.
12. **Save the CV and cover letter** to
    `outputs/applications/<company>-<role-slug>/` via `write_file`.
    `cv-audit.md` is written into the same directory at Step C.2 and updated
    at Step G.
13. **Verify.** Confirm saved files and the Interests section. After
    formatting and humanizing, run one measurement-only CheckMyATS scan of
    the final CV's faithful TXT export with the same role description. Never
    reopen the revision loop. Exact TXT and role hashes matching an earlier
    completed scan: reuse it. Record unavailable results as unavailable, not
    zero, and distinguish the final result from any earlier draft score. See
    the reference for freshness checks and evidence storage.
14. **Report.** In chat: one-paragraph summary, both written files' absolute
    paths, CV craft rubric counts from Step C.2 and Step G with any dimension
    still failing, initial and final CheckMyATS scores (or unavailable),
    revision count, separate Step D assessment, ATS report and audit paths.
    Report unsupported keywords, dropped roles, unmet target or overshoot,
    superseded measurements, website failures, and every other evidence gap.

## Voice rules (the "knows what they're talking about" standard)

Non-negotiable unless the user explicitly overrides tone.

- **Concrete over abstract.** "Cut test pipeline from 10+ min to 1-3
  min" beats "improved developer productivity."
- **Stack-named, not generic.** Tools, versions, services named.
- **No hedging.** Cut "I believe," "I feel," "I think I can." State it.
- **Short sentences when stakes are high.** One metric, one line.
- **No buzzword salads.** Generic-list words ("passionate," "driven,"
  "synergy") are banned.
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
  output. Finished applications live only under `outputs/applications/`.
- **Role file only.** No pasted ad text, no URLs. A missing file stops
  the run.
- **humanizer always runs.** Step 10 is not optional and needs no
  separate user ask. The old "only on request" rule is dead.
- **Don't reorder the pipeline.** Analyzer before tailor, optimizer
  before cover letter, formatter before humanizer. Each step consumes
  the previous step's output. C.2 runs before C.1, and G runs after H;
  the labels are identifiers, not chronology.
- **One identity per CV.** Title line and summary's first clause carry
  the posting's own title. A second discipline is evidence, never a
  competing headline; a compound headline is allowed only when the
  posting's own title is compound.
- **Result first, tool second.** No bullet opens with a tool name or a
  duty verb. The metric goes in front of the mechanism that produced it.
- **Dates are copied, never curated.** Overlaps, gaps, and ongoing work
  are flagged in the report, never smoothed in the CV.
- **Never report a score for a different text.** Change the CV after a
  measurement and that measurement is void: re-run it or label the old
  number superseded.

## Verification

- All three files exist at the expected paths (verified with
  `read_file`): `<First>_<Last>-CV-<role-slug>.md`, `cover-letter.md`, and
  `cv-audit.md`.
- CV is ≤750 words, title line follows `# <Name> - <Role>` and carries the
  posting's own title, header has no phone, no authorization/sponsorship
  remark, no portfolio link. Summary ≤40 words, Education ≤2 lines.
- Positioning holds: one primary identity, no second discipline competing
  in the header or the summary's first clause.
- The craft rubric is scored on all seven dimensions at Step C.2 and again
  at Step G, or a dimension records why it could not be checked. Residual
  failures are reported as gaps, never quietly fixed.
- Parity holds: the text the final CheckMyATS scan measured is the text
  that ships. Any measurement taken before a later CV edit is labelled
  superseded, never reported as final.
- CV names only real projects, employers, tech, and metrics from
  workspace sources, and contains a non-empty Interests section.
- CheckMyATS initial/final scores or explicit unavailability recorded
  separately from Step D's assessment. Completed scans have fresh result
  evidence and input hashes. An initial score >=80 causes zero C.1 edits.
- An initial score <80 permits at most 2 C.1 revisions targeting 80–92;
  each added keyword has an evidence source. Final verification is
  measurement-only. Step D keeps its separate 2-pass limit.
- Banned-token scan clean (or residue reported) after at most 2
  humanizer passes per file.
- Dropped-as-irrelevant roles named in the report.
- The chat reply includes both absolute paths, separately labelled ATS
  results, the ATS report path, warnings, and a one-paragraph summary.
