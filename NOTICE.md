# Third-Party Notices

`job-application-writer` is an orchestrator. It delegates the actual writing work
to seven other skills, and six of those are derived from third-party projects.
Both upstream projects are MIT licensed, which permits redistribution provided the
copyright notice travels with the code. This file records that obligation.

The orchestrator itself — [`.agents/skills/job-application-writer/`](.agents/skills/job-application-writer),
its [reference document](.agents/skills/job-application-writer/references/checkmyats.md),
and the repository's distribution code — are original work by Spyridon Peppas and
are covered by the root [LICENSE](LICENSE).

---

## ResumeSkills

**Upstream:** <https://github.com/Paramchoudhary/ResumeSkills>
**Pinned at:** `74ae19e7c62b0516d1c298328e5544976c12da5d` (branch `main`)
**License:** MIT — `Copyright (c) 2026 Resume Skills`
**Upstream license text:** <https://github.com/Paramchoudhary/ResumeSkills/blob/main/LICENSE>

Six bundled skills are derived from this repository:

| Skill | Upstream path | Local modifications |
|---|---|---|
| `job-description-analyzer` | `skills/job-description-analyzer/SKILL.md` | `description` re-folded to a YAML block scalar |
| `resume-tailor` | `skills/resume-tailor/SKILL.md` | none — byte-identical |
| `resume-bullet-writer` | `skills/resume-bullet-writer/SKILL.md` | `description` re-folded to a YAML block scalar |
| `resume-ats-optimizer` | `skills/resume-ats-optimizer/SKILL.md` | `description` re-folded to a YAML block scalar |
| `cover-letter-generator` | `skills/cover-letter-generator/SKILL.md` | `description` re-folded to a YAML block scalar; trigger phrases appended to the description text |
| `resume-formatter` | `skills/resume-formatter/SKILL.md` | none — byte-identical |

**What "re-folded to a YAML block scalar" means.** Upstream writes long
`description:` values on a single unfolded line. This bundle writes the same text
using YAML's `>-` folded block style, wrapping at a column width. The parsed
string value is identical; only the file's line breaks differ. No wording was
changed.

Every local copy additionally drops the `disabled: true` line, which is a
convention of the maintainer's private agent-skill install and is not part of any
upstream project. See [docs/CONTRIBUTING-notes](docs/VERSIONING.md) for why.

Upstream ships roughly twenty further skills. Only the six the orchestrator
actually invokes are bundled here; nothing else from ResumeSkills is included.

---

## humanizer

**Upstream:** <https://github.com/blader/humanizer>
**Pinned at:** `225a6f39ac85f76ee48dbad772ea4abe4ed6c9d8` (branch `main`)
**License:** MIT — `Copyright (c) 2025 Siqi Chen`
**Bundled license file:** [`.agents/skills/humanizer/LICENSE`](.agents/skills/humanizer/LICENSE)

The skill version carried here is `2.5.1`, ported into the Hermes agents bundle
by Hermes Agent. The upstream `LICENSE` file is retained verbatim inside the
skill directory, which satisfies the MIT notice requirement for that component
independently of this repository's root `LICENSE`.

---

## Third-party services

No third-party service is bundled or vendored. The skill optionally loads a CV
and a job description into <https://checkmyats.com/resume-checker/> to score ATS
compatibility. Nothing is transmitted unless a user runs the skill, and the
skill treats page content as untrusted data rather than instructions.

See [SECURITY.md](SECURITY.md) for the scope limits the skill enforces around
that call.

---

## Updating a pin

Upstream commits are pinned in [`bundle.json`](bundle.json) under
`skills[].upstream.ref`. To move to a newer upstream release, bump the ref,
re-copy the affected `SKILL.md`, update the table above, and note the change in
[`CHANGELOG.md`](CHANGELOG.md).
