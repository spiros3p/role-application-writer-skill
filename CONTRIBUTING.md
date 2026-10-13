# Contributing

Thanks for helping. This repository is small, and the rules below exist to keep
one specific promise: **the skill in your agent behaves the same as the skill in
everyone else's.**

## The one rule that matters most

Do not edit a vendored third-party skill in place.

Six of the eight skills are vendored from [`Paramchoudhary/ResumeSkills`](https://github.com/Paramchoudhary/ResumeSkills)
and one from [`blader/humanizer`](https://github.com/blader/humanizer). They are
pinned to a specific commit, recorded in `bundle.json` and attributed in
`NOTICE.md`. If you "improve" one, the next upstream sync silently discards your
work and the pin no longer describes what is shipped.

Instead:

1. **Want to change how the bundle behaves?** Change
   `job-application-writer`. It is the orchestrator and it is original work.
2. **Want a change that belongs upstream?** Send it to the upstream project, then
   bump the pin here (see below).
3. **Genuinely need a forked pipeline skill?** Add it under a new name, say so
   loudly in the PR description, and declare it in `bundle.json` with
   `"origin": "fork"` and a link to the upstream it diverges from.

## Updating an upstream pin

```bash
# 1. note the new upstream commit
# 2. replace only the affected SKILL.md, then record the change:
#    - bundle.json:  skills[].upstream.ref
#    - NOTICE.md:    the pinned commit and the local-modification table
#    - CHANGELOG.md: which skills moved and what changed
```

The only deliberate difference from upstream is that long `description:` values
are re-folded into YAML block scalars. That is a formatting convention, not an
edit: the parsed string is identical. Keep it.

## Version policy

| Change | Bump |
|---|---|
| Pipeline behaviour, budgets, reporting, thresholds | `minor` |
| A fix that changes output for an existing workspace | `patch` |
| Typo fixes in prose, docs, or comments | `patch` |
| Packaging only: CI, scripts, README, docs | `none` — or `patch` if it changes how users install |
| Removing a skill, or renaming one | `major` |

Skill behaviour is the product. A reader upgrading from 1.0.0 to 1.1.0 should
be able to predict the difference in output from the changelog alone.

## Before you open a pull request

```bash
./scripts/validate.sh --strict
```

It checks version agreement across all four sources, bundle closure, frontmatter
sanity, license attribution, and packaging hygiene. CI runs the same command, so
a red build is a failing check, not a formality.

Also confirm:

- [ ] `CHANGELOG.md` has an entry under `Unreleased`
- [ ] Any new or renamed skill is declared in `bundle.json`
- [ ] Any new upstream code is credited in `NOTICE.md`
- [ ] `scripts/install.sh` still installs the complete closure, verified by
      installing into a scratch directory and running the skill's prerequisite
      check

## Verifying a change actually works

The skills are prose instructions, not executable code, so "it compiles" means
little here. Two checks carry real signal:

1. **Dry-run the installer** into a temporary directory and confirm all eight
   skills land with their supporting files intact.
2. **Walk the procedure.** Read your edited `SKILL.md` against the inputs it
   claims and check each numbered step is actually reachable from the text. A
   step that depends on an ambiguity will fail silently at a user's desk.

The orchestrator's `references/checkmyats.md` carries nine regression cases for
the ATS scoring policy. If you touch that policy, walk every case and record the
outcome.

## Never use real CVs as test fixtures

If you need to test, synthesise a workspace. Real career data belongs in nobody's
repository, including a private one.

## Commit and PR style

Short imperative subject: `fix: stop C.1 loop when the site returns 0`.

Describe the behavioural change in the body, not the implementation. "Step C.1
now stops after one revision when the score regresses, matching reference
regression case 5" is useful; "moved a condition" is not.

## Code of conduct

Participation is governed by [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).
