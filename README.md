# Physical AI Portfolio

Hansel's learning and evidence portfolio for Physical AI product, deployment, integration, and solutions engineering. Warehouse and logistics are the first domain.

## Start here

- **Active project:** [Portfolio reorganization](docs/decisions/2026-08-31-portfolio-reorganization.md).
- **Current checkpoint:** Design and migration baseline approved. Repository content is being aligned. No GitHub repository has been renamed or moved yet.
- **Evidence state:** [Status](STATUS.md) distinguishes written, reviewed, runtime, and external evidence.
- **Next decision:** Ship and land the aligned repository content, then execute the verified migration lanes.
- **Candidate experiment:** Open Robotics Middleware Framework (Open-RMF) office demo. Runtime unvalidated. A flagship experiment charter must select it before execution.

See [ROADMAP.md](ROADMAP.md) for ordering and gates.

## Portfolio

The Portfolio repository is the public entry point and cross-repository control plane. It owns the repository map, roadmap, cross-project status, decisions, and retrospectives. It links to evidence but does not copy project logs or results.

Current GitHub repository: [hanselhansel/physical-ai-foundation](https://github.com/hanselhansel/physical-ai-foundation). The approved destination is `physical-ai-portfolio`; the current URL remains authoritative until the migration is verified.

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

## Decisions and working documents

- [Compute setup](docs/decisions/compute-setup.md)
- [Portfolio operating-model design](docs/superpowers/specs/2026-08-31-physical-ai-portfolio-operating-model-design.md)
- [Portfolio reorganization plan](docs/superpowers/plans/2026-08-31-physical-ai-portfolio-reorganization.md)
- [Migration baseline](docs/decisions/2026-08-31-portfolio-reorganization.md)
- [Parked warehouse AMR X series](docs/x-posts/warehouse-amr-deployment-series.md)
