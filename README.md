# Physical AI Portfolio

Hansel's learning and evidence portfolio for Physical AI product, deployment, integration, and solutions engineering. Warehouse and logistics are the first domain.

## Start here

- **Active project:** [Portfolio reorganization](docs/decisions/2026-08-31-portfolio-reorganization.md).
- **Current checkpoint:** The Portfolio repository is renamed, moved, and `VERIFIED`. Contributions, Outreach, and Warehouse remain at `BASELINE`.
- **Evidence state:** [Status](STATUS.md) distinguishes written, reviewed, runtime, and external evidence.
- **Next decision:** Land the scoped runner-variable fix, then migrate Contributions, Outreach, and Warehouse in dependency order.
- **Candidate experiment:** Open Robotics Middleware Framework (Open-RMF) office demo. Runtime unvalidated. A flagship experiment charter must select it before execution.

See [ROADMAP.md](ROADMAP.md) for ordering and gates.
See the [changelog](CHANGELOG.md) for release history.

## Portfolio

The Portfolio repository is the public entry point and cross-repository control plane. It owns the repository map, roadmap, cross-project status, decisions, and retrospectives. It links to evidence but does not copy project logs or results.

Current GitHub repository: [hanselhansel/physical-ai-portfolio](https://github.com/hanselhansel/physical-ai-portfolio). The previous `physical-ai-foundation` URL redirects here and must not be reused.

## Projects

Projects are portfolio work owned by Hansel.

| Project | Purpose | Evidence state |
|---|---|---|
| [Warehouse deployment](https://github.com/hanselhansel/pai-warehouse-deployment) | Warehouse AMR research, requirements, WMS integration, deployment playbooks, Docker environments, and simulation exercises | Written artifacts exist. Open-RMF runtime remains unvalidated. |

Detailed project status and evidence stay in the project repository.

## Contributions

Contributions are work proposed to projects owned by others.

Current GitHub repository: [hanselhansel/pai-lerobot-contrib](https://github.com/hanselhansel/pai-lerobot-contrib). The approved destination is `pai-contributions`.

The current contribution is [warehouse-amr-ros2 pull request #1](https://github.com/Pouya-Mansournia/warehouse-amr-ros2/pull/1). Submission is complete. The upstream outcome is waiting for maintainer review.

## Outreach

Outreach contains public communication: publishable posts, generic target categories, talks, reusable messages, and public feedback.

Current GitHub repository: [hanselhansel/pai-community](https://github.com/hanselhansel/pai-community). The approved destination is `pai-outreach`.

Private names, contact history, direct messages, meeting notes, contact exports, and non-public feedback do not belong in the public Outreach repository. Outreach remains Parked until a validated case is approved for external communication.

## Forks

Forks are mechanical working copies of externally owned code. They are not represented as projects owned by Hansel.

The current fork is [hanselhansel/warehouse-amr-ros2](https://github.com/hanselhansel/warehouse-amr-ros2), used for the open upstream contribution.

## Operating rules

- One active build and one active validation lane are allowed. External waiting items do not consume either lane.
- A milestone is Complete only when its success criteria and required evidence are linked.
- Execution repositories are authoritative for their own artifacts and evidence.
- Status claims include an authority, observation time, source commit, freshness limit, and recheck command.
- Local, cached, and live Git state are compared before and after cross-repository changes.

## Migration operator commands

The migration CLI is fail-closed. `migrate-one` reports a dry run unless `--apply` is present.

Validate this isolated checkout without changing GitHub or the filesystem:

```bash
bash scripts/portfolio-migration.sh verify --workspace-root "$PWD"
```

Run the read-only preflight against the canonical workspace, inspect a lane, or preview one migration:

```bash
bash scripts/portfolio-migration.sh preflight
bash scripts/portfolio-migration.sh status portfolio
bash scripts/portfolio-migration.sh migrate-one portfolio
```

After aligned content lands and preflight passes, apply one dependency-ordered lane at a time:

```bash
bash scripts/portfolio-migration.sh migrate-one portfolio --apply
```

The apply command can rename a GitHub repository and move its local checkout. Follow the [migration plan](docs/superpowers/plans/2026-08-31-physical-ai-portfolio-reorganization.md) and verify each lane before starting the next.

The first apply run may stop at `APP_GATE_PENDING` after the GitHub rename and local move. Complete the Codex app saved-project readback, then rerun the same lane with the gate result:

```bash
PORTFOLIO_APP_GATE=passed bash scripts/portfolio-migration.sh migrate-one portfolio --apply
```

When the lane reaches `VERIFIED`, the runner records `app_gate=passed` in that repository's private journal. Later status checks and dependent lanes reuse the journaled result. They do not require an unrelated current shell to set the flag again.

## Decisions and working documents

- [Compute setup](docs/decisions/compute-setup.md)
- [Portfolio operating-model design](docs/superpowers/specs/2026-08-31-physical-ai-portfolio-operating-model-design.md)
- [Portfolio reorganization plan](docs/superpowers/plans/2026-08-31-physical-ai-portfolio-reorganization.md)
- [Migration baseline](docs/decisions/2026-08-31-portfolio-reorganization.md)
- [Portfolio item template](docs/templates/portfolio-item.md)
- [Runtime experiment template](docs/templates/runtime-experiment.md)
- [Parked warehouse AMR X series](docs/x-posts/warehouse-amr-deployment-series.md)
