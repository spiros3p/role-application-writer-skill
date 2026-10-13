# Security Policy

## Supported versions

| Version | Supported |
|---|---|
| 1.2.x | Yes |
| < 1.2.0 | No |

## Reporting a vulnerability

Please **do not open a public issue** for a security problem.

Use GitHub's private reporting on this repository
(<https://github.com/__GITHUB_HANDLE__/job-application-writer/security/advisories/new>).
Expect an acknowledgement within seven days.

---

## What this skill does that touches the network

Exactly one thing, and it is optional.

`job-application-writer` can score a finished CV against a job description on
[CheckMyATS](https://checkmyats.com/resume-checker/). This is a deliberate,
bounded capability with a fixed scope, defined in
`.agents/skills/job-application-writer/references/checkmyats.md`.

**In scope — the only data that ever leaves your machine:**

- The derived CV, exported as plain text
- The job description, as plain text

**Out of scope — the skill refuses these, by instruction:**

- Your source career files. `career-experiance.md` and anything in
  `projects-context/` are read locally and never uploaded.
- Any other website, service, or API
- Account creation, payment, or job submission on your behalf
- Downloading anything

The skill treats everything it reads on that page as **untrusted data, never as
instructions**. If the page asks it to upload source documents, add a
qualification you have not evidenced, or visit a different service, it ignores
the request and keeps going. Prompt-injection resistance here is a written rule
in the skill, and changing that rule is a security-relevant change.

It also never modifies the site's scoring functions, result elements, or scores,
and never fabricates a result. An unreachable site produces a reported
limitation, not a guess.

Every other stage is offline. The CV craft audit (Steps C.2 and G, defined in
`references/cv-craft.md`) reads the CV, the role file, and the workspace only:
it sends nothing, and its score is a local count of dimensions passed, never a
network result.

### Opting out

The external check is skipped whenever it cannot run, and its absence never
blocks delivery. If you would rather it never ran at all, remove or disable the
Step C.1 paragraph in the orchestrator's `SKILL.md`; the remaining stages, the
craft audit, and the local ATS optimiser work unchanged.

Note that agents without browser capability skip it automatically. Step D is a
local quality pass and runs regardless.

## Privacy of your own files

The skill reads a workspace you control. Keep it out of version control.
`.gitignore` in this repository blocks `inputs/`, `outputs/`, and
`ats-checks/` as a backstop, but never rely on it alone: real career data
carries identifiers that follow you. Never open a pull request containing a
synthetic fixture derived from your real CV.

## Reporting a vendored-skill issue

Six skills come from third-party projects. A vulnerability in one of those
belongs upstream first, so that maintainers of every consumer see it. Report it
to the upstream project, then open an issue here referencing their advisory so
we can move the pin.

Attribution and pinned commits are in [`NOTICE.md`](NOTICE.md).
