# Physical AI Portfolio Status

Updated: 2026-08-31

The execution repository owns detailed evidence. This file holds concise cross-project summaries.

## Portfolio reorganization

- **Title:** Physical AI portfolio reorganization
- **Category:** Portfolio
- **Objective:** Establish the approved repository-purpose structure without losing history or breaking links.
- **Workflow status:** Complete
- **Success criteria:** Approved names, paths, repository contracts, links, and verification gates are live and reconciled.
- **Required validation:** Review-validated, runtime-validated migration checks, and decision-validated completion.
- **Evidence links:** [Design](docs/superpowers/specs/2026-08-31-physical-ai-portfolio-operating-model-design.md), [plan](docs/superpowers/plans/2026-08-31-physical-ai-portfolio-reorganization.md), [baseline](docs/decisions/2026-08-31-portfolio-reorganization.md).
- **Result:** Portfolio, Contributions, Outreach, and Warehouse are renamed or moved as approved. All four migration journals report `VERIFIED`, and canonical links and local paths are reconciled.
- **Limitations:** Previous GitHub names remain redirects and must not be reused. Private migration journals remain local operator evidence.
- **Next decision:** Select and write the flagship experiment charter.
- **Authority:** Portfolio repository and live GitHub refs.
- **Observed at:** 2026-08-31
- **Source commit:** `af03bcdd77d8ba0c2216f786ec6b2703f792d5e4` on live `physical-ai-portfolio/main` before this reconciliation.
- **Fresh until:** 2026-09-01
- **Recheck command:** `for key in portfolio contributions outreach warehouse; do bash scripts/portfolio-migration.sh status "$key"; done`
- **Active project:** Yes
- **Candidate experiment:** None

## Warehouse evidence audit

- **Title:** Warehouse deployment evidence audit
- **Category:** Projects
- **Objective:** Determine which written warehouse artifacts are safe to present as validated portfolio evidence.
- **Workflow status:** Ready
- **Success criteria:** Each artifact names its validation method, limitations, evidence, and next decision.
- **Required validation:** Source-validated and review-validated.
- **Evidence links:** [Warehouse project](https://github.com/hanselhansel/pai-warehouse-deployment).
- **Result:** Seven written artifacts exist. Their evidence has not yet been audited under the new standard.
- **Limitations:** Existing completion checkboxes recorded creation, not a fresh evidence audit.
- **Next decision:** Begin after the portfolio migration and flagship experiment charter.
- **Authority:** Warehouse project repository.
- **Observed at:** 2026-08-31
- **Source commit:** `aa11e3a70cd085073550509665276f095bf92643`
- **Fresh until:** 2026-09-30
- **Recheck command:** `git -C ../projects/warehouse-deployment log -1 --format=%H`
- **Active project:** No
- **Candidate experiment:** Open-RMF office demo, runtime unvalidated

## Upstream warehouse AMR contribution

- **Title:** Deployment considerations contribution
- **Category:** Contributions
- **Objective:** Add real-warehouse deployment guidance to an existing ROS 2 AMR project.
- **Workflow status:** Waiting
- **Success criteria:** Contribution submitted with a clear upstream outcome recorded.
- **Required validation:** Review-validated submission and externally validated upstream outcome.
- **Evidence links:** [Upstream PR #1](https://github.com/Pouya-Mansournia/warehouse-amr-ros2/pull/1).
- **Result:** Submission complete. Upstream outcome open.
- **Limitations:** Maintainer timing is outside this portfolio's control.
- **Next decision:** Follow up on 2026-09-07 if no maintainer response.
- **Authority:** Upstream GitHub pull request.
- **Observed at:** 2026-08-31
- **Source commit:** `20c2ff7750a8`
- **Fresh until:** 2026-09-07
- **Recheck command:** `gh pr view https://github.com/Pouya-Mansournia/warehouse-amr-ros2/pull/1 --json state,updatedAt,reviewDecision`

## Warehouse AMR X series

- **Title:** Warehouse AMR X post series
- **Category:** Outreach
- **Objective:** Convert validated warehouse deployment lessons into public posts.
- **Workflow status:** Parked
- **Success criteria:** Every quantitative claim is source-validated and wording is approved for publication.
- **Required validation:** Source-validated and review-validated.
- **Evidence links:** [Draft series](docs/x-posts/warehouse-amr-deployment-series.md).
- **Result:** Twelve drafts exist. They are not publication-ready.
- **Limitations:** Quantitative claims do not yet have a claim-level source table.
- **Next decision:** Restart only after a validated flagship case is approved for external communication.
- **Authority:** Portfolio Outreach gate.
- **Observed at:** 2026-08-31
- **Source commit:** `097bcd2`
- **Fresh until:** 2026-09-30
- **Recheck command:** `git log -1 --format=%H -- docs/x-posts/warehouse-amr-deployment-series.md`

## Networking materials

- **Title:** Physical AI networking materials
- **Category:** Outreach
- **Objective:** Maintain public generic targets and reusable outreach messages.
- **Workflow status:** Parked
- **Success criteria:** Public materials remain free of private relationship records.
- **Required validation:** Review-validated and privacy-reviewed.
- **Evidence links:** [Current Outreach repository](https://github.com/hanselhansel/pai-outreach).
- **Result:** Generic target categories and message templates exist.
- **Limitations:** Outreach is not active in this project.
- **Next decision:** Restart after a validated case is approved for external communication.
- **Authority:** Outreach repository.
- **Observed at:** 2026-08-31
- **Source commit:** `d2fdb09034d8ffda8f1aafeba740ab5ee8bdab37`
- **Fresh until:** 2026-09-30
- **Recheck command:** `git -C ../outreach status --short --branch`

## Compute decision

- **Title:** Local compute for the current portfolio cycle
- **Category:** Portfolio
- **Objective:** Avoid unnecessary cloud or hardware spending before runtime requirements justify it.
- **Workflow status:** Complete
- **Success criteria:** Decision, rationale, limitations, and revisit conditions are recorded.
- **Required validation:** Decision-validated.
- **Evidence links:** [Compute setup decision](docs/decisions/compute-setup.md).
- **Result:** Local Mac and Docker selected. No GPU rental or hardware purchase authorized.
- **Limitations:** Open-RMF runtime performance has not been validated on this host.
- **Next decision:** Revisit when a selected experiment requires unavailable compute.
- **Authority:** Portfolio decision record.
- **Observed at:** 2026-08-31
- **Source commit:** `1cb414e`
- **Fresh until:** 2026-09-30
- **Recheck command:** `git log -1 --format=%H -- docs/decisions/compute-setup.md`
