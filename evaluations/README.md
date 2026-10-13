# Evaluations

Behavioural records for this skill, oldest first. The skill is Markdown
instructions an agent follows, so behaviour cannot be unit-tested: these
documents are how a change is checked against what the pipeline is supposed to
do. `scripts/check-rules.sh` guards the text; these guard the behaviour.

| Artifact | Version | Scope |
|---|---|---|
| `snapshot-1.0.0/SKILL.md` | 1.0.0 | the skill text before the external ATS work |
| `snapshot-before-ats-20260917-134012/SKILL.md` | pre-1.1.0 | snapshot taken before the Step C.1 policy landed |
| `snapshot-1.1.0/SKILL.md`, `snapshot-1.1.0/references/checkmyats.md` | 1.1.0 | the last full copy of the installed skill, archived before the installed `SKILL.md` became a pointer into this repository |
| `behavioral-regression-v1.1.0.md` | 1.1.0 | scenario-by-scenario evaluation of the C.1 / CheckMyATS policy |

A 1.2.0 behavioural record is not written yet. It needs to cover the CV craft
audit (Steps C.2 and G), the measurement-parity rule, and the compression pass.

## The workspace link

`~/.agents/workspaces/job-application-writer/` is a symlink to this directory.
The agent workspace for this skill therefore resolves into the repository
instead of holding a second copy that goes stale. Anything the workspace tooling
writes (evaluations, drafts, snapshots) lands here and shows up in `git status`,
which is the point: one source of truth, nothing silently duplicated.

It points at this directory rather than at the repository root on purpose. A
cleanup of a workspace directory is routine, and a `rm -rf` aimed at the
repository root would take the skill source with it.

To aim it at the repository root instead:

```bash
rm ~/.agents/workspaces/job-application-writer
ln -s ~/agent-workspace/role-application-writer ~/.agents/workspaces/job-application-writer
```
