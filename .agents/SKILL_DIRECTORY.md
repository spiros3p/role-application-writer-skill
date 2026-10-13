# Bundled Skills

The eight skills in this bundle, one row each. Every skill is a directory
containing a `SKILL.md` plus any supporting files. To use one, read its
`SKILL.md` first and follow it.

These skills are vendored verbatim. `job-application-writer` is original work;
the rest are third-party MIT skills pinned to a commit and credited in
[`../NOTICE.md`](../NOTICE.md). Editing a vendored file in place will be lost on
the next upstream sync. See [`../CONTRIBUTING.md`](../CONTRIBUTING.md).

**Origin** decides what may change. `manual` is ours and may be edited. An
`upstream:<repo>` origin is pinned: do not edit, move the pin instead.

Format: `<origin>, <skill>, <short description>, <dir path>`

manual, job-application-writer, Orchestrate the six-skill pipeline producing an ATS CV plus tailored cover letter per role, .agents/skills/job-application-writer
upstream:Paramchoudhary/ResumeSkills, job-description-analyzer, Analyze a job posting into match score keyword lists gaps and cover-letter talking points, .agents/skills/job-description-analyzer
upstream:Paramchoudhary/ResumeSkills, resume-tailor, Tailor the CV to one posting within hard word and role budgets, .agents/skills/resume-tailor
upstream:Paramchoudhary/ResumeSkills, resume-bullet-writer, Rewrite weak resume bullets into achievement statements with sourced metrics, .agents/skills/resume-bullet-writer
upstream:Paramchoudhary/ResumeSkills, resume-ats-optimizer, Improve ATS compatibility and keyword match locally without external calls, .agents/skills/resume-ats-optimizer
upstream:Paramchoudhary/ResumeSkills, cover-letter-generator, Write a personalised cover letter for one role from the user's own record, .agents/skills/cover-letter-generator
upstream:Paramchoudhary/ResumeSkills, resume-formatter, Apply ATS-safe formatting and clean scannable layout to a finished CV, .agents/skills/resume-formatter
upstream:blader/humanizer, humanizer, Strip AI writing patterns and restore real voice then scan for banned tokens, .agents/skills/humanizer

## Supporting files

| Skill | Files beyond `SKILL.md` |
|---|---|
| `job-application-writer` | `references/checkmyats.md` — **required.** Defines the Step C.1 external scoring procedure, permission scope, revision policy, and evidence rules. Without it the orchestrator points at a document that is not there. `references/cv-craft.md` — **required.** The CV craft standard and the seven-dimension rubric applied at Step C.2 and re-checked at Step G |
| `humanizer` | `LICENSE`, `agents/openai.yaml` |

## Pipeline order

`job-application-writer` runs these in a fixed sequence. Each stage consumes the
previous one's output; reordering changes the result.

```
job-application-writer          orchestrator
  A  job-description-analyzer
  B  resume-tailor
  C  resume-bullet-writer
  C.2 CV craft audit           (internal rubric; one repair pass)
  C.1 CheckMyATS measurement   (external; bounded, optional)
  D  resume-ats-optimizer
  E  cover-letter-generator
  F  resume-formatter
  H  humanizer                  finish pass
  G  final CV craft check       (read-only, on the delivered file)
```

C.2 runs before C.1, and G runs after H: the stage labels identify stages, not
chronology.

See [`../docs/PIPELINE.md`](../docs/PIPELINE.md) for budgets, thresholds, and the
regression cases behind the Step C.1 policy.
