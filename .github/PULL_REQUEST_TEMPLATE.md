<!-- Keep this short. A reviewer should be able to tell what changed in under a minute. -->

## What changed

<!-- One paragraph on the behavioural change, not the implementation.
     "Step C.1 now stops after one revision when the score regresses" is useful.
     "Moved a condition" is not. -->

## Where

<!-- Which files, and which stage of the pipeline they affect. -->

- [ ] Orchestrator (`job-application-writer`)
- [ ] A vendored skill — see the note below
- [ ] Packaging (`scripts/`, `bundle.json`, `.claude-plugin/`, workflows)
- [ ] Docs only

## If you touched a vendored skill

Seven of the eight skills are pinned to upstream commits and **must not be
edited in place**; a sync will discard the change silently.

- [ ] Not applicable, or:
- [ ] This is a fork. The new skill has a distinct name, `bundle.json` declares
      `"origin": "fork"` with a link to the upstream it diverges from, and the
      PR description says why a fork was necessary instead of an upstream PR.

## Version bump

`./scripts/validate.sh --strict` fails if `CHANGELOG.md` has no section for the
current `VERSION`. Choose one:

- [ ] **Behavioural change** — bump required (minor or patch, per `CONTRIBUTING.md`)
- [ ] **Packaging or docs only** — no bump needed
- [ ] Version already bumped in this branch

<!-- If you bumped: state the bump and the command used. -->

## Checklist

- [ ] `./scripts/validate.sh --strict` passes
- [ ] `CHANGELOG.md` updated
- [ ] `NOTICE.md` updated if any upstream code changed
- [ ] `bundle.json` updated if any skill was added, removed, or renamed
- [ ] Tested with a **synthetic** workspace. No real CV, name, or employer appears
      anywhere in this PR, including in fixtures.
- [ ] If the Step C.1 policy changed: all nine regression cases in
      `references/checkmyats.md` walked, with outcomes recorded

## Verification

<!-- How you checked this actually works. The skills are prose, so "it installs"
     is a weak claim on its own. Say what you ran and what you observed. -->

```
