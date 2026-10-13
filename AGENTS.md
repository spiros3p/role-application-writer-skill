# AGENTS.md

Instructions for coding agents working in this repository.

This repository is a **distribution repo**. It vendors eight agent skills and the
tooling that installs, validates, and releases them. It contains no application
code and no build step.

## What this repository is

`job-application-writer` is an agent skill: Markdown instructions that tell an AI
agent how to produce a job application. The skill itself is the product. Your job
when working here is to keep the bundle installable, honest about provenance, and
reproducibly versioned.

## Ground rules

1. **Do not edit a vendored skill in place.** Seven of the eight skills come from
   third-party projects and are pinned to a commit in `bundle.json`. Edits are
   lost on the next upstream sync. Change the orchestrator, or move the pin.
2. **Version bumps are mechanical.** `scripts/bump-version.sh` rewrites five
   version fields and nothing else. Never hand-edit a version, and never change
   skill content as part of a bump.
3. **Run the gate.** `scripts/validate.sh --strict` must pass before any commit
   that touches the bundle. CI runs the same command.
4. **Never commit real career data.** Test with synthetic workspaces only.
5. **Do not fabricate results.** The skill's most important property is that it
   refuses to invent metrics, scores, or experience. Changes must not weaken it.
6. **Do not quietly weaken a rule.** `scripts/check-rules.sh` pins the
   load-bearing phrases and the rubric's shape, and the release gate runs it. If
   a rule genuinely has to change, change it deliberately, keep the inventory in
   step, and say why in the changelog.

<!-- project-skills:managed -->
## Agent Skills

Copied to `.agents/skills/` (index: `.agents/SKILL_DIRECTORY.md`). Use these before improvising.

| Skill | Path | Use it when | Entry conditions | Produces | Notes |
|---|---|---|---|---|---|
| job-application-writer | `.agents/skills/job-application-writer` | The user names a role file and wants the full application pair, says "apply for this role", or wants a tailored CV and cover letter together | Workspace exists with `inputs/career-experiance/career-experiance.md` and at least one role file outside `applied/` and `archived/`; all seven dependency skills present | CV and cover letter under `outputs/applications/<company>-<role-slug>/`, plus `cv-audit.md` and `ats-checks/report.md` | Orchestrator. Runs the seven below and stops if any is missing. Also `references/checkmyats.md` and `references/cv-craft.md`, both required |
| job-description-analyzer | `.agents/skills/job-description-analyzer` | Analyzing a job posting to get a match score and the keyword list before anything is written | — | Match score, required and preferred keyword lists, gaps, and an application strategy | — |
| resume-tailor | `.agents/skills/resume-tailor` | Tailoring a CV to one specific posting | — | Tailored resume draft, held to truthful claims only | Hard budgets from the orchestrator apply on top: 750 words, 40-word summary, 2-line education, 4 roles, 3 bullets each |
| resume-bullet-writer | `.agents/skills/resume-bullet-writer` | Strengthening weak resume bullets | — | Achievement-focused statements carrying metrics and impact | Sourced metrics only; never invent a number |
| resume-ats-optimizer | `.agents/skills/resume-ats-optimizer` | Improving ATS compatibility and keyword match as a local quality pass | — | ATS compatibility and keyword match assessment | Keep its assessment separate from the measured CheckMyATS score; model-derived scores are estimates. Two-pass limit |
| cover-letter-generator | `.agents/skills/cover-letter-generator` | The user asks for a cover letter, application letter, or motivation letter for a specific role | — | Personalised cover letter drafted from a resume and job description | Voice reference comes from the closest-domain past letter, not from generic templates |
| resume-formatter | `.agents/skills/resume-formatter` | Applying ATS-friendly formatting and clean scannable layout | — | Formatted CV with ATS-safe layout | Runs at stage F, after content is final and before the humanizer |
| humanizer | `.agents/skills/humanizer` | Text needs AI-isms stripped and a real voice restored | — | Humanized text | Third-party MIT, `blader/humanizer`. Carries its own `LICENSE`. Last stage; followed by a banned-token scan |

## Composition rules

- `job-application-writer` is the entry point. Reach the other seven through it, never directly, unless the user explicitly asks for a single skill's job.
- `job-description-analyzer → resume-tailor`: the analyzer's match score, keyword lists, gaps, and talking points are the tailor's input. Nothing tailors against an unanalyzed posting.
- `resume-tailor → resume-bullet-writer`: bullets are rewritten on the tailored draft, not on the raw record.
- `resume-bullet-writer → resume-ats-optimizer`: the optimizer runs on the retained post-C.1 draft, never on a superseded revision.
- `resume-tailor → cover-letter-generator`: needs analyzer output, the experience file, the relevant project files, and the closest-domain past letter for voice.
- `resume-tailor → resume-bullet-writer → resume-ats-optimizer`: the craft audit (C.2) runs on the bullet-written draft and repairs it once before the external ATS measurement (C.1) sees anything, so the score always covers the content-final text. The label order is not the run order.
- `resume-formatter → humanizer`: formatting completes before the finish pass, and the finish pass is not optional.
- `humanizer → final craft check (G)`: the same seven dimensions are re-run read-only on the delivered file to catch drift. A repair there is bounded to one pass and, because it changes content, voids the humanizer scan and the final ATS measurement for that file.
- `job-application-writer` has no standalone form: all seven dependencies must be present or the run stops and names the missing one.
- Heavyweight, save for when it is worth it: the external CheckMyATS call at Step C.1 is the only network access in the whole pipeline. Its unavailability is reported and never blocks delivery.
- Content changes are versioned separately from packaging changes. Behavioural edits are a `minor` or `patch` bump; CI, scripts, and docs need none.

<!-- /project-skills:managed -->

## Repository map

```
.agents/skills/       the eight skills, verbatim
.agents/SKILL_DIRECTORY.md   generated index: origin, purpose, supporting files
scripts/install.sh    install the bundle into any agent's skills directory
scripts/validate.sh   release gate: version agreement, closure, frontmatter, licensing
scripts/check-rules.sh       release gate: load-bearing rule phrases and rubric shape
scripts/bump-version.sh      SemVer bump across all version sources
scripts/sync-from-local.sh   maintainer only: re-materialise from ~/.agents/skills
evaluations/          behavioural records per version, and the target of the
                      agent workspace symlink (see evaluations/README.md)
docs/                 install, workspace, pipeline, versioning
bundle.json           manifest with pinned upstream commits and per-skill provenance
.claude-plugin/       Claude Code plugin manifest
```

## Working here

```bash
./scripts/validate.sh --strict      # must pass before committing
./scripts/check-rules.sh            # rule inventory on its own
./scripts/sync-from-local.sh --check  # only if you maintain from ~/.agents/skills
./scripts/install.sh --dry-run --target claude
```

Never run `git init`, commit, tag, or push in this repository unless asked.
