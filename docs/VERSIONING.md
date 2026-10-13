# Versioning

## The model

The bundle carries **one** version number. It describes the whole set of eight
skills plus the packaging, because that is what a user actually installs.

It is [SemVer](https://semver.org/): `MAJOR.MINOR.PATCH`.

```
1.1.0
│ │ └── patch:  a fix that changes output for an existing workspace
│ └──── minor:  a change in pipeline behaviour, budgets, or reporting
└────── major:  removing or renaming a skill, or anything that breaks a run
```

A change confined to CI, scripts, README, or docs needs no bump at all.

### Why one number and not eight

The six vendored skills are pinned to upstream commits and carry their own
versions, which are recorded in `bundle.json`. Those versions describe their
upstream, not what you installed. What you installed is the bundle, and the
bundle has one number.

The one exception is the orchestrator: it is original work, so its `version:`
frontmatter in `SKILL.md` is bumped by hand along with everything else. It is
one of the four places the number lives.

---

## The four places the version lives

They must always agree. `scripts/validate.sh` fails the build when they drift.

| # | File | Field |
|---|---|---|
| 1 | `VERSION` | the whole file, canonical |
| 2 | `bundle.json` | `.version` |
| 3 | `bundle.json` | `.skills[0].version` (the orchestrator entry) |
| 4 | `.claude-plugin/plugin.json` | `.version` |
| 5 | `.agents/skills/job-application-writer/SKILL.md` | frontmatter `version:` |

`scripts/bump-version.sh` rewrites all of them together. It edits line by line,
so the diff is exactly those five lines and nothing else. It never touches skill
content, never commits, and never tags.

`CHANGELOG.md` must have a section for the current version. The validator checks
this too, which is the reason it will not let you tag a release you did not
write down.

---

## Releasing

```bash
# 1. make your changes, with an entry under Unreleased in CHANGELOG.md

# 2. the gate
./scripts/validate.sh --strict

# 3. bump
./scripts/bump-version.sh minor        # or: major | patch | 2.0.0-rc.1

# 4. write the changelog section the validator asked for
#    ## [1.2.0] - 2026-10-04

# 5. validate again, now that the changelog matches
./scripts/validate.sh --strict

# 6. commit and tag
git add -A
git commit -m "release: v1.2.0"
git tag -a v1.2.0 -m "v1.2.0"
git push origin main --follow-tags
```

Pushing the tag is what triggers `.github/workflows/release.yml`, which
publishes a GitHub release with the changelog section and the bundled skills as
a downloadable archive.

### Before the very first push

Two things are placeholders and must be replaced, or `--strict` will fail:

- `__GITHUB_HANDLE__` in `bundle.json`, `.claude-plugin/plugin.json`,
  `README.md`, `docs/INSTALL.md`, `SECURITY.md`
- your repository URL, so the release workflow's archive is built correctly

---

## Tagging

`v<version>`, annotated, matching `VERSION` exactly.

```bash
git tag -a v1.2.0 -m "v1.2.0"
```

The workflow triggers on tag push and reads the version from the tag. It refuses
to publish a tag that disagrees with `VERSION`, so a mismatched tag fails the
build instead of shipping a release labelled with the wrong number.

Never move a published tag. A correction is a new patch release.

---

## Branches

`main` is the released line. Tags are cut from `main` and never from a feature
branch.

Use branches for work in progress and open a pull request. CI runs the full
validation on every branch, so a broken bundle never reaches `main`.

---

## Updating a vendored upstream

Moving a pin is its own kind of change and deserves its own patch bump, so
users can see exactly which third-party revision they received.

```bash
# 1. find the new upstream commit
git ls-remote https://github.com/Paramchoudhary/ResumeSkills main

# 2. replace only the affected SKILL.md, then update:
#    - bundle.json   skills[].upstream.ref
#    - NOTICE.md     the pinned commit, and the local-modification table
#    - CHANGELOG.md  which skills moved and what changed

# 3. release
./scripts/validate.sh --strict
./scripts/bump-version.sh patch
```

The one intentional difference from upstream is that long `description:` values
are re-folded into YAML block scalars. That is formatting, not editing: the
parsed string is identical. Keep it, and keep it out of the modification table,
because it is a convention rather than a change.

Upstream releases roughly twenty skills. Only the six the orchestrator invokes
are vendored. Do not add the rest "while we are here": they enlarge the
maintenance surface without changing what the bundle does.

---

## What users pin against

Reproducible installs:

```bash
# a release tarball
curl -sSL https://github.com/__GITHUB_HANDLE__/job-application-writer/archive/refs/tags/v1.1.0.tar.gz \
  | tar xz && cp -R job-application-writer-1.1.0/.agents/skills/* ~/.agents/skills/
```

Or, for Claude Code, the plugin version, which tracks `VERSION`.

Follow `main` if you want to be first and accept breakage. The `Unreleased`
section of the changelog is the only honest description of what is on `main`.
