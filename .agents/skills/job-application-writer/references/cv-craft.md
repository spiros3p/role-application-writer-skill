# CV craft standard

Vendored CV skills cover tailoring, bullet strength, ATS keywords, layout. None
decides **which single role the CV asks the reader to see**, whether bullets read
as a career or as a run of unrelated projects, or whether dates survive a second
look. This document is that layer.

Used three times per run:

- **Guidance.** Steps B and C write to this standard.
- **Audit.** Step C.2 applies the seven-dimension rubric to the draft, one
  bounded repair pass, result written to `cv-audit.md`.
- **Final check.** Step G re-runs the same seven dimensions, read-only, on the
  delivered file.

Stage labels are identifiers, not chronology. Run order:
`B → C → C.2 → C.1 → D → E → F → H → G`.

**Nothing here overrides truthfulness.** The rubric measures craft; craft never
justifies adding a claim. See *What this standard refuses*.

## 1. Positioning: one primary role

A recruiter places a candidate in one slot. A CV asking to be placed in two gets
placed in neither.

- **Primary identity = the title the posting itself uses**, from the role file's
  own title line. Not a more impressive title, not a broader one, not two joined
  with "and".
- **A compound headline is allowed only when the posting's own title is
  compound** ("Fullstack/DevOps Engineer"). Then mirror the posting's exact
  pairing; stop at two.
- **Every other discipline is evidence, not identity.** Bullets and skills groups
  only. Never the title line, never the summary's first clause.
- CV title line: `# <Name> - <posting title>`.

Three cheap tests:

1. Title line, summary's first six words, two most recent job titles, read
together, must arrive at one role.
2. Summary opening with an adjective — product-minded, passionate, driven,
   versatile — fails positioning. First word is the title.
3. Cutting a phrase that removes a whole discipline rather than a fact means two
   identities. Pick the one the posting hires for; demote the other.

## 2. Summary shape

Hard budget: **40 words**.

| Slot | Content |
|---|---|
| Sentence 1 | `<posting title> with <scope> in <core stack>` |
| Sentence 2 | `<proof of scale, carrying at least one number>` |

- **Lead with the title, not the adjective.** "Product-minded fullstack engineer
  with a frontend home base" is a personality first, a job title last; "home
  base" spends three words on a metaphor.
- **Posting's nouns first.** Rarer technologies last, if they fit.
- **One number minimum** of scope: users, systems, pipelines, years, teams.
- **No objective language.** "Looking for a challenging role", "seeking to grow":
  the summary describes what you did, not what you want.

Adjective test: delete every adjective and metaphor. Sentence still says the same
thing → they were noise. Says nothing → rebuild from the source, don't reword.

## 3. Bullet construction: result first, mechanism second

Fixed shape:

```
<result or metric> by <mechanism, named exactly>; also <second result> by <mechanism>
```

- **Open with the metric or the change**, never a tool name, never a duty verb.
  `Reduced build time from 12 min to 3 min by replacing the bundler
  with esbuild` is the shape. `Worked with webpack and esbuild on build tooling`
  is not.
- **Name the mechanism exactly.** "Tuned caching, maxWorkers, and isolatedModules"
  beats "optimised the configuration", which beats "improved performance".
- **One bullet, one primary metric**, where the source has one. A second metric
  attaches after a semicolon with "also"; still one line. Three metrics in one
  sentence is a paragraph, and paragraphs get skimmed. A bullet the source gives
  no number for leads with its concrete change instead — never a fabricated
  figure — and the missing metric is reported as a gap.
- **The mechanism clause earns its place as cause.** A tool list that does not
  explain the number gets cut back to the tools that do.
- **Impact over intent.** "…to help the team" and "…which improved
  collaboration" add nothing the number has not already said.

Metric-first test: read the first five words of every bullet. None of them the
change or the number → the bullet is buried. Rewrite until the number is visible
without reading the rest.

## 4. The three-bullet role recipe

Roles take at most three bullets. Order them the way a hiring manager ranks them:

| # | Bullet | Carries |
|---|---|---|
| 1 | **Impact** | The largest measured change you caused. Never dropped for space |
| 2 | **Ownership** | Platform scope — systems owned end to end, infrastructure provisioned, verification written for it — one line, scope and proof together |
| 3 | **Operation** | Production, on-call, monitoring, incident response, cross-functional delivery, presenting — one clean operational line, not a meeting list |

- **A role with no measured change leads with ownership.** Not with duties.
- **Never spend a bullet on what the title already implies.** "Wrote code",
  "attended standups", bare "collaborated with the team": noise, unless the
  collaboration had a scope.
- **Bullet 3 drops first** when the budget bites. Bullet 1 never drops.

## 5. Progression, and dates that hold up

The CV reads as a career, not as adjacent projects.

- **Reverse-chronological is the default.** Relevance reordering — lifting a less
  recent but more relevant role — is allowed when the analyzer found a material
  keyword gap. Then dates stay attached to their role, and the reorder plus its
  reason is named in the report.
- **Every role states what changed**, in scope or responsibility, not what the
  job was. "Upgraded the core application from 12 to 19" is a change;
  "responsible for the frontend" is a job description.
- **Titles are the real titles.** Standardise format — capitalisation,
  spelling — never seniority. A personal product is labelled a personal product,
  not employment.
- **Dates are copied, never curated.** Gaps, overlaps, short stints, ongoing work
  stay exactly as the source has them. Ongoing work uses one convention across
  every role, chosen once per CV.
- **Date integrity check, every run.** List each role's start and end as the
  source gives them, in the order the CV prints them. Then:
  - order that disagrees with reverse chronology must be the deliberate, reported
    reorder above — otherwise fix the order;
  - dates overlapping another role's, or running past today, are confirmed
    against the source. Source says so → keep it **and flag it in the report**,
    never smooth it;
  - a date not found in the source is a gap, not a guess.

Trust test: a recruiter checking two dates against your record finds them
unchanged.

## 6. Skills: grouped by target function

- **Groups are functions, not vendors:** Frontend, Backend, Cloud and
  infrastructure, Quality and observability — or the posting's own vocabulary.
- **Target-function group first** — whichever group the posting hires for. Two to
  five groups; a singleton folds into its nearest neighbour.
- **Inside a group, the posting's exact spellings lead.** An ATS matches tokens,
  not meanings: use the posting's phrasing when it is truthful about your work.
- **Every listed skill is backed by experience evidence.** A skill living only in
  the list is a claim with nothing behind it.
- **The list is for coverage; bullets are for depth.** Don't repeat in the list
  what a bullet already proves. Keep the section to three or four lines: a wall
  of keywords dilutes the keywords that matter.

## 7. Structure, scan order, and measurement parity

- Standard section headers, one date format across every role, single column, no
  tables, plus the header whitelist from the orchestrator: name, role-matched
  title, email, city, GitHub, LinkedIn.
- Titles a recruiter sees first are the posting-shaped ones, not internal
  oddities.
- Education stays at two lines. The degree line stays visible; certifications
  only when true and directly relevant to the posting.
- **The Interests section is deliberate and stays.** It is a hook, grounded in
  the source, not angled at the role. Advice to delete it as "non-essential
  personal detail" is declined, and the decline is reported.
- Non-essential personal detail stays out: no photo, birth date, marital status,
  height, or address beyond city.
- **Parity rule.** The text that was measured is the text that ships. A scan
  covers the content it saw; change the CV afterwards and that measurement is
  void — re-run it or report it superseded. Never report a score for a text that
  is not the delivered one.
- Layout guidance colliding with this section loses.

## 8. The rubric

Seven dimensions, each pass or fail, checked against the CV and the role file:

| # | Dimension | Passes when |
|---|---|---|
| 1 | Positioning | Title line and the summary's first clause carry the posting's own title; one primary identity; any second discipline is supporting evidence only |
| 2 | Summary shape | ≤40 words; sentence one is title, scope, stack; at least one number; no load-bearing adjectives |
| 3 | Bullet construction | Every bullet leads with its result or metric; mechanisms named with exact tools; none opens with a tool name or a duty verb |
| 4 | Impact tier | Each role follows impact, ownership, operation; no duty the title implies; no role without a scope statement |
| 5 | Progression and dates | One date format; reverse-chronological or a deliberate reported reorder; ongoing marked consistently; dates unaltered from source; anomalies flagged rather than smoothed |
| 6 | Skills grouping | Two to five function groups; target-function group first; posting spellings; no singletons; every skill backed by evidence |
| 7 | Structure and parity | Standard headers and titles; header whitelist respected; single column; Interests present; measured text equals shipped text |

**Reported as `n/7`.** A count of craft dimensions passed — not a percentage, not
a model-derived score, never comparable to a CheckMyATS number. Label it "CV
craft rubric" every time it is printed.

### Repair rules at Step C.2

One pass. Fix every failed dimension that workspace evidence supports. A
dimension that fails for want of evidence stays failed, reported as a gap; the
rubric never licenses a new claim. Re-audit after the repair, record any
dimension still failing. **A low count never blocks delivery** — it is reported.

### Final check at Step G

Read-only, against the delivered file, to catch drift the formatter or the
humanizer introduced. A repair here is allowed only for a dimension that passed
at C.2, and is limited to one pass. Any repair that changes content voids the
humanizer's token scan and the final CheckMyATS measurement for that file: re-run
both, and report the earlier score as superseded rather than as final.

## 9. What this standard refuses

- Experience, tools, metrics, credentials, or dates the source lacks, added to
  pass a dimension.
- Copying a checker's or reviewer's suggestion wholesale. Advice to add an
  unsupported keyword, claim a qualification, or delete the Interests section is
  declined, and the decline is reported with its reason.
- Two identities in one CV, unless the posting's own title is compound.
- A percentage or currency figure invented for "impact". No number in the source
  means no number in the bullet; the gap goes in the report.
- Editing a date to close a gap, hide an overlap, or tidy a timeline.
