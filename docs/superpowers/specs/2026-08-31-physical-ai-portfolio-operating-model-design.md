# Physical AI Portfolio Operating Model

Date: 2026-08-31
Status: Approved design

## Context

The Physical AI workspace is a long-running learning and portfolio program. It uses warehouse and logistics as the first domain and develops knowledge through research, product and deployment design, simulations, open-source contributions, and external communication.

The workspace currently contains four portfolio repositories and one external fork under a shared local directory. The repositories are clean and independently versioned, but their names and responsibilities use different classification axes. The current umbrella name, `foundation`, can mean introductory learning, shared infrastructure, or portfolio governance. Several READMEs and repository descriptions have also drifted from the files and work that now exist.

The Open Robotics Middleware Framework office demo is one learning exercise inside this larger system. It is not the objective of the portfolio. The portfolio needs a durable operating model before that experiment is treated as complete.

## Goals

- Give every repository one clear and non-overlapping purpose.
- Make the complete Physical AI portfolio understandable from one public entry point.
- Separate workflow status, validation, and external outcomes.
- Require linked evidence before milestones are called complete.
- Keep project-specific work in the repository that owns it.
- Preserve independent Git histories and upstream contribution workflows.
- Make the next action clear when work resumes in a later session.
- Use a flagship experiment charter to select the first full evidence cycle. Open-RMF is the current candidate.

## Non-goals

- Do not combine the repositories into a monorepo.
- Do not add Git submodules.
- Do not create a new Git repository at the local `physical-ai/` parent directory.
- Do not move project evidence into the portfolio control plane.
- Do not run or repair Open-RMF as part of the portfolio reorganization.
- Do not activate publishing, outreach, hardware work, GPU training, or customer discovery in this project.
- Do not rewrite the history of the external warehouse AMR fork.

## Alternatives considered

### Documentation patch only

Fixing stale links and names would be fast, but it would not establish an authority model or completion standard. Status would drift again.

### Portfolio control plane with independent execution repositories

This is the approved approach. One repository governs the portfolio while independent repositories own projects, contributions, and outreach. It preserves history and keeps boundaries explicit.

### Monorepo consolidation

A monorepo would simplify local navigation but would disrupt existing histories, blur the external contribution workflow, and add migration work without improving the current learning cycle.

## Approved taxonomy

Repositories are classified by their primary relationship to the Physical AI portfolio. This is a repository-purpose taxonomy, not an artifact taxonomy.

| Category | Definition | Examples |
|---|---|---|
| Portfolio | Governs and explains the complete body of work | Repository map, roadmap, cross-project status, decisions, synthesis |
| Projects | Work owned and developed as portfolio projects | Warehouse deployment, future manipulation or inspection projects |
| Contributions | Work submitted to projects owned by others | Open-RMF, ROS 2, Nav2, Isaac, or Foxglove contributions |
| Outreach | Public material used to publish, connect, or collect public feedback | Posts, generic target categories, talks, and public derivatives |
| Forks | Mechanical working copies of repositories owned by others | `warehouse-amr-ros2` fork |

Classification rules:

- Work owned by Hansel belongs in Projects.
- Work proposed to an externally owned project belongs in Contributions.
- Material that communicates work externally belongs in Outreach.
- Information that governs multiple categories belongs in Portfolio.
- A Git working copy of external code stays in Forks and is not represented as an owned portfolio project.

Project-specific learning stays with its project. Contribution-specific learning stays with the contribution. Cross-project synthesis belongs in Portfolio. Public derivatives belong in Outreach.

Private names, contact history, messages, meeting notes, and non-public feedback never belong in the public Outreach repository.

## Approved names and local structure

The word `foundation` is retired from repository and sprint names. The overall program is the Physical AI Portfolio.

```text
physical-ai/
├── portfolio/
│   └── GitHub: physical-ai-portfolio
├── projects/
│   └── warehouse-deployment/
│       └── GitHub: pai-warehouse-deployment
├── contributions/
│   └── GitHub: pai-contributions
├── outreach/
│   └── GitHub: pai-outreach
└── forks/
    └── warehouse-amr-ros2/
```

Approved renames:

| Current | New |
|---|---|
| GitHub `physical-ai-foundation` | GitHub `physical-ai-portfolio` |
| Local `foundation/` | Local `portfolio/` |
| GitHub `pai-lerobot-contrib` | GitHub `pai-contributions` |
| Local `lerobot-contrib/` | Local `contributions/` |
| GitHub `pai-community` | GitHub `pai-outreach` |
| Local `community/` | Local `outreach/` |
| Local `warehouse-deployment/` | Local `projects/warehouse-deployment/` |

The GitHub name `pai-warehouse-deployment` and the local `forks/` structure remain unchanged.

## Authority boundaries

| Information | Authoritative location |
|---|---|
| Repository inventory and purpose | `physical-ai-portfolio` |
| Current cycle and next portfolio priority | `physical-ai-portfolio` |
| Cross-project milestone status | `physical-ai-portfolio` with evidence links |
| Warehouse documents, code, simulations, and results | `pai-warehouse-deployment` |
| Detailed experiment records | The project where the experiment ran |
| Contribution execution and lessons | `pai-contributions` |
| Third-party source code | The attributed fork |
| Public writing, networking, and external feedback | `pai-outreach` |
| Cross-project decisions and retrospectives | `physical-ai-portfolio` |

The portfolio repository links to evidence. It does not duplicate project files, logs, screenshots, or research.

## Workflow status model

Every portfolio item has exactly one workflow status.

| Status | Meaning |
|---|---|
| Backlog | Captured but not selected |
| Ready | Scope, success criteria, and required evidence are defined |
| Active | Work is currently happening |
| Waiting | The next action depends on an external event or prerequisite |
| Complete | Success criteria are met and evidence is linked |
| Parked | Intentionally paused with a reason and restart condition |
| Dropped | Intentionally ended with the decision preserved |

`Scaffolded` is a result, not a status. A created environment that has not run successfully remains Active with a result such as “scaffolding created, runtime unvalidated.”

## Validation model

Validation is recorded separately from workflow status. An item may require one or more methods.

| Validation | Used for |
|---|---|
| Source-validated | Market research, vendor claims, and case studies |
| Review-validated | Requirements, architecture, playbooks, and runbooks |
| Runtime-validated | Code, containers, simulations, and integrations |
| Externally validated | Maintainer acceptance, user feedback, or real conversations |
| Decision-validated | A recorded continuation, change, pause, or stop decision |

External outcomes are also separate. A submitted contribution may have completed its execution task while its upstream outcome remains open, merged, declined, or closed.

## Completion gate

A portfolio item may be marked Complete only when:

1. The intended output exists.
2. Its success criteria are met.
3. All required validation has occurred.
4. Evidence is linked from the portfolio status record.
5. Failures and limitations are recorded.
6. A next decision is stated.
7. The portfolio control plane reflects the current result.

A created file, green command, merged internal pull request, open dashboard, or submitted upstream pull request is not sufficient on its own.

## Portfolio item record

Required labels are: Title, Category, Objective, Workflow status, Success criteria, Required validation, Evidence links, Result, Limitations, Next decision, Authority, Observed at, Source commit, Fresh until, and Recheck command. Optional labels are Active project and Candidate experiment. Each item has exactly one workflow status.

The first version remains Markdown. A generated registry or database is unnecessary for the current portfolio size.

## Runtime experiment evidence

A runtime experiment records:

- Date and host environment.
- Exact dependency, image, or build version and digest.
- Architecture and compatibility notes.
- Exact commands.
- Expected behavior.
- Observed behavior.
- Logs and screenshots.
- Failures and recoveries.
- Interpretation.
- The portfolio artifact changed by the findings.
- The next experiment, change, pause, or stop decision.

## Portfolio control-plane structure

```text
physical-ai-portfolio/
├── README.md
├── STATUS.md
├── ROADMAP.md
└── docs/
    ├── decisions/
    ├── retrospectives/
    └── templates/
```

Responsibilities:

| Location | Responsibility |
|---|---|
| `README.md` | Purpose, taxonomy, repository map, and current focus |
| `STATUS.md` | Current state of active, waiting, parked, and recently completed work |
| `ROADMAP.md` | Ordered future milestones, gates, and dependencies |
| `docs/decisions/` | Cross-project decisions and revisit conditions |
| `docs/retrospectives/` | Lessons that apply across projects |
| `docs/templates/` | Shared experiment and evidence record formats |

Useful content from `docs/progress.md` moves into `STATUS.md` and `ROADMAP.md`. The old progress file is removed after migration so that status has one source of truth.

## Execution-repository contract

Every owned project README answers:

1. What is this project?
2. Why is it in the portfolio?
3. What will it teach or demonstrate?
4. What is in scope and out of scope?
5. What artifacts exist?
6. What has been validated, and how?
7. How can someone reproduce the work?
8. What is the next milestone?
9. Where is the master portfolio record?

The project repository remains authoritative for details and evidence.

## Cross-repository workflow

```text
Select milestone in Portfolio
            ↓
Define success and evidence requirements
            ↓
Work in the owning Project or Contribution repository
            ↓
Record results and limitations there
            ↓
Update downstream artifacts there
            ↓
Link committed evidence from Portfolio STATUS
            ↓
Record the next decision
            ↓
Optionally create an Outreach artifact
```

Evidence is committed in the execution repository before the portfolio declares the milestone Complete.

## Contribution workflow

A contribution keeps two related records:

- Execution: commit, branch, pull request, and review fixes.
- Upstream outcome: open, merged, declined, or closed.

Submitting a pull request can complete the execution task. The portfolio item remains Waiting until the upstream outcome changes or a defined follow-up limit is reached. Forks do not receive portfolio governance files.

## Initial status reclassification

The migration records current facts without inventing new validation.

| Existing work | Initial classification |
|---|---|
| Open-RMF Docker files | Active; scaffolding created; runtime unvalidated |
| Open-RMF notes template | Active; observations not recorded |
| Warehouse research documents | Evidence audit required before assigning Complete |
| Upstream warehouse AMR pull request | Waiting; submission complete; upstream outcome open |
| Twelve X posts | Parked; drafts exist |
| Networking materials | Parked; restart condition must be recorded |
| Compute decision | Complete; decision and revisit conditions exist |

## Migration design

### Phase 1: Safety preflight

- Compare each local HEAD, cached remote, and live remote.
- Confirm clean worktrees.
- Record current paths, remote URLs, active branches, and HEAD commits.
- Identify Codex or Conductor projects and active tasks that depend on current paths.
- Confirm the external warehouse AMR pull request is accessible.
- Defer a local directory move if its registered consumers cannot be updated safely.

### Phase 2: Build the control plane

On a branch in the current foundation repository:

- Replace the README with the portfolio landing page.
- Add `STATUS.md` and `ROADMAP.md`.
- Preserve cross-project decisions.
- Add experiment and evidence templates.
- Migrate useful progress content.
- Remove stale references to nonexistent directories.
- Review and merge before renaming the repository.

After the content is merged, rename the GitHub repository, update its local remote, rename the local directory, and verify history and redirects.

### Phase 3: Rename Contributions and Outreach

For each repository independently:

1. Create a branch.
2. Rewrite the README for the approved boundary.
3. Fix internal links.
4. Review and merge.
5. Rename the GitHub repository.
6. Update the local remote.
7. Move the local checkout.
8. Reopen it and verify status and history.

### Phase 4: Introduce the Projects layer

- Rewrite and land the warehouse README and path-bearing documentation at the current path.
- Create the local `projects/` directory.
- Move the clean warehouse checkout to `projects/warehouse-deployment/`.
- Keep the GitHub repository name `pai-warehouse-deployment`.
- Correct outdated filenames, simulation descriptions, and GitHub metadata.
- Update portfolio links after the new path is verified.
- Update the unversioned local `physical-ai/README.md` and record its before-and-after hashes in the migration receipt.

The `forks/` directory remains unchanged.

### Phase 5: Populate initial status

Apply the approved workflow and validation model. This phase changes classification, not historical facts.

### Phase 6: Verify migration

The migration is complete only when:

- Every local repository is clean.
- Expected HEAD commits are preserved apart from intended migration commits.
- Live remotes use the approved names.
- Old GitHub URLs redirect.
- The external pull request still resolves.
- Portfolio links open committed artifacts.
- No tracked files are lost.
- Codex and Conductor can open every saved project.
- The resulting structure matches the approved taxonomy.

Each repository uses its own branch and reviewed commit. Nothing is committed directly to `main`.

## Drift prevention

At the start and end of cross-repository work:

- Compare local HEAD, cached remote, and live remote.
- Confirm clean worktrees before moving or renaming directories.
- Verify portfolio links resolve to committed evidence.
- Update last-verified dates only after live checks.
- Keep at most one active build and one active validation; externally waiting items do not consume either lane.
- Do not mark a milestone complete from scaffolding or unobserved runtime behavior.

When the portfolio and an execution repository disagree, the execution repository is authoritative for its artifacts and evidence. The portfolio is then corrected to link to that state.

## Project decomposition

This design governs Project A, the portfolio reorganization.

Project B begins with a flagship experiment charter after Project A passes its migration checks. If Open-RMF is selected, it receives a separate design and plan covering supported images, ARM64 compatibility, the current RMF web architecture, runbook corrections, runtime evidence, warehouse interpretation, and the next decision.

Outreach activation is a later project. It begins only after the portfolio contains validated work suitable for external communication.

## Acceptance criteria

Project A succeeds when:

- The approved names and MECE structure are in place.
- `physical-ai-portfolio` is the clear public entry point.
- Repository responsibilities and authority boundaries are explicit.
- Current work is classified using the approved status model.
- Evidence requirements are documented and reusable.
- All repository histories, external links, and saved project access survive migration.
- Open-RMF is represented honestly as an unvalidated candidate behind the flagship experiment charter.
