# Physical AI Foundation Sprint: Progress

Updated: 2026-08-31

## Completed

### Repo setup
- [x] Renamed `pai-warehouse-sim` to `pai-warehouse-deployment`.
- [x] Updated READMEs across all four repos to reflect the PM / deployment / solutions focus.
- [x] Created local Docker-based ROS 2 Humble environment for middleware learning.
- [x] Created Open-RMF + Docker environment for fleet orchestration simulation.
- [x] Added compute setup decision: no cloud GPU rental, no hardware, local Mac + Docker.

### Core deployment artifacts (warehouse-deployment)
- [x] Vendor matrix: Symbotic, AutoStore, Locus Robotics, 6 River Systems, Exotec.
- [x] Case study: Walmart + Symbotic regional distribution center deployment.
- [x] PRD: AMR deployment for a mid-market 3PL e-commerce warehouse.
- [x] Integration architecture: WMS + AMR fleet in a 3PL warehouse.
- [x] Deployment checklist and runbook.
- [x] Deployment playbook: synthesized guide for warehouse AMR deployments.
- [x] Sub-domain analysis: AMR fleet orchestration.
- [x] Open-RMF office demo scaffolding:
  - `docker/open-rmf/Dockerfile` and launch scripts.
  - `sim/open-rmf-office-demo/README.md` with component map and warehouse interpretation.
  - `sim/open-rmf-office-demo/office-demo-notes.md` running-notes template.

### Open-source contribution
- [x] Submitted PR to `Pouya-Mansournia/warehouse-amr-ros2` adding `docs/DEPLOYMENT_CONSIDERATIONS.md`.
- [x] PR URL: https://github.com/Pouya-Mansournia/warehouse-amr-ros2/pull/1
- [x] Status: Awaiting maintainer review. Follow-up in 7-10 days.
- [x] Logged in `pai-lerobot-contrib/docs/contributions.md`.

### Public posts and community
- [x] 12-post X series drafted and in backlog.
- [x] Networking target list and outreach templates in `pai-community/networking/`.
- [ ] Public posts and outreach paused for this sprint.

## In progress / next

- [ ] Run the Open-RMF office demo inside Docker on Mac.
- [ ] Fill in `sim/open-rmf-office-demo/office-demo-notes.md` with observations.
- [ ] Stretch: add a custom task, warehouse map interpretation, or WMS-to-RMF bridge sketch.
- [ ] Update integration architecture and playbook with RMF-specific observations.
- [ ] Written retrospective: not yet reached.

## Open decisions

1. What is the first task to run after the demo launches? (Patrol task is documented as the starting point.)
2. Should the stretch milestone be a custom task, a warehouse map annotation, or a WMS-to-RMF bridge sketch? (Recommend: custom task first, then map annotation.)
3. When should we follow up on the pending open-source PR? (Recommend: 7-10 days after submission.)
