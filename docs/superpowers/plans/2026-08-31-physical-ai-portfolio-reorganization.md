<!-- /autoplan restore point: /Users/hansel/.gstack/projects/hanselhansel-physical-ai-foundation/docs-physical-ai-portfolio-design-autoplan-restore-20260831-020441.md -->
# Physical AI Portfolio Reorganization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the Physical AI workspace into the approved Portfolio, Projects, Contributions, Outreach, and Forks model without losing Git history, breaking public links, or overstating validation.

**Architecture:** `physical-ai-portfolio` becomes the cross-repository control plane. Independent execution repositories remain authoritative for their artifacts and evidence. Content changes land before GitHub repository renames and local directory moves, then a final portfolio reconciliation records the verified result.

**Tech Stack:** Git, GitHub CLI, Markdown, shell verification, Codex local projects

**Review state:** APPROVED_AUTOPLAN. User approved option A on 2026-08-31.

---

## Pre-execution review gate

Run the gstack autoplan workflow against this plan and the approved design before Task 1. Apply only in-scope decisions. Record any required scope escalation before implementation begins.

## File map

### Portfolio repository

- Modify: `README.md`, audience-first landing page and repository-purpose map.
- Create: `STATUS.md`, current portfolio items and evidence state.
- Create: `ROADMAP.md`, ordered milestones and activation gates.
- Create: `docs/decisions/2026-08-31-portfolio-reorganization.md`, before-and-after migration record.
- Create: `docs/templates/portfolio-item.md`, reusable status record.
- Create: `docs/templates/runtime-experiment.md`, reusable runtime evidence record.
- Create: `scripts/portfolio-migration.sh`, Bash 3.2-compatible CLI copied to a neutral directory before moves.
- Create: `scripts/lib/portfolio-manifest.sh`, explicit repositories, paths, IDs, URLs, descriptions, and dependencies.
- Create: `scripts/lib/portfolio-state.sh`, state detection, lock, journal, redaction, and filesystem safety.
- Create: `scripts/lib/github-adapter.sh`, scoped GitHub queries, rename, identity, permission, and redirect checks.
- Create: `scripts/lib/portfolio-preflight.sh` and `scripts/lib/portfolio-lock.sh`, mutation gates and lock handling.
- Create: `scripts/tests/test-portfolio-migration.sh`, temporary-fixture regression tests.
- Delete: `docs/progress.md`, after its useful content moves to `STATUS.md` and `ROADMAP.md`.
- Modify: `docs/decisions/compute-setup.md`, correct paths and unverified runtime wording.
- Modify: `docs/x-posts/warehouse-amr-deployment-series.md`, mark Parked and remove the publication schedule.

### Contributions repository

- Modify: `README.md`, contribution-track contract and current contribution link.
- Modify: `docs/contributions.md`, separate submission execution from upstream outcome.

### Outreach repository

- Modify: `README.md`, public outreach contract, parked state, privacy boundary, and restart condition.
- Modify: `networking/target-list.md`, keep private contact tracking outside Git.
- Preserve: `networking/message-templates.md`.
- Create: `.gitignore`, block likely private contact exports.

### Warehouse project repository

- Modify: `README.md`, project contract, accurate artifact map, validation state, reproduction entry points, and portfolio link.
- Modify paths only: `RUNBOOK_OPENRMF.md`, `docker/README.md`, and `docker/open-rmf/README.md`.
- Preserve: all remaining research, Docker, and simulation content.

### Local workspace index

- Modify outside Git: `/Users/hansel/conductor/repos/physical-ai/README.md`; record before-and-after hashes in the sanitized receipt.

## Executor contract

Run inside Codex Desktop with authenticated `git`, `gh`, `rg`, and gstack `/ship` plus `/land-and-deploy`. The migration host is this Darwin ARM64 Mac and the workspace root is `/Users/hansel/conductor/repos/physical-ai`. Every task names its repository or script. Missing tools, failed auth, a dirty worktree, an occupied destination, or a mismatched live ref is a hard stop with no mutation.

## Task 1: Capture and verify the migration baseline

**Files:**
- Create: `docs/decisions/2026-08-31-portfolio-reorganization.md`

- [ ] **Step 1: Write failing migration-script tests**

Use isolated `HOME`, `GH_CONFIG_DIR`, a temporary workspace, local bare repos, and fake `gh`/`git` adapters first in `PATH`. Cover zero-mutation dry-run, successful apply, failure and resume after each transition, wrong repository ID, auth errors, dirty and diverged refs, linked worktrees, concurrent and stale locks, SSH/HTTPS remotes, symlink or occupied destinations, 399/400-line boundaries, description failure, and the warehouse no-rename lane. Expected first run: FAIL because the runner does not exist.

- [ ] **Step 2: Implement the fail-closed runner**

Use Bash 3.2-compatible syntax and `set -euo pipefail`; do not use `eval`, `flock`, GNU-only path tools, or associative arrays. Provide `preflight`, `status`, `migrate-one`, and `verify`. Copy the runner and libraries to a neutral temporary directory before mutation. Store a mode-0600 journal and atomic directory lock under `/Users/hansel/.local/state/physical-ai-portfolio-migration`. Model `BASELINE → REMOTE_RENAMED → ORIGIN_UPDATED → LOCAL_MOVED → METADATA_UPDATED → VERIFIED` using immutable GitHub ID, admin permission, expected main SHA, fetch/push URLs, paths, description, and timestamps. Query only allowlisted fields, redact private values, and require `--apply`.

- [ ] **Step 3: Run baseline verification**

Commit the green runner and tests as `chore: add fail-closed portfolio migration runner`. Then run `bash scripts/portfolio-migration.sh preflight` against canonical main checkouts while reporting linked worktrees separately. Expected: labelled PASS rows for tools, auth, host, paths, immutable IDs, admin permission, local/cached/live main equality, target-name availability, rename exceptions, upstream PR, and a sanitized old-name inventory.

- [ ] **Step 4: Write the baseline decision record**

Record the approved taxonomy, official GitHub rename caveats, every old path and remote, every baseline HEAD, the upstream PR URL, the absence of Pages and hosted Actions, and the rule that old repository names must not be reused.

- [ ] **Step 5: Verify and commit the baseline**

Run:

```bash
git diff --check
git add docs/decisions/2026-08-31-portfolio-reorganization.md
git commit -m "docs: record portfolio migration baseline"
```

Expected: one focused commit on `docs/physical-ai-portfolio-design`.

## Task 2: Build the portfolio control plane

**Files:**
- Modify: `README.md`
- Create: `STATUS.md`
- Create: `ROADMAP.md`
- Create: `docs/templates/portfolio-item.md`
- Create: `docs/templates/runtime-experiment.md`
- Delete: `docs/progress.md`

- [ ] **Step 1: Rewrite the public landing page**

Lead with the current flagship work, evidence state, and next decision. Then include the portfolio purpose, warehouse/logistics starting domain, PM/deployment/solutions focus, repository-purpose taxonomy, authority boundaries, and links to `STATUS.md` and `ROADMAP.md`. Use current resolvable URLs until Task 8; new URLs land during reconciliation.

- [ ] **Step 2: Create the status record**

Create entries for portfolio reorganization, warehouse evidence audit, upstream contribution, parked X posts, networking materials, and compute decision. Each summary contains active project, status, evidence link, result, next decision, candidate experiment, authority, observed time, source commit, freshness limit, and recheck command. Detailed validation stays in the owning repository.

- [ ] **Step 3: Create the roadmap**

Define this order: portfolio reorganization, flagship experiment charter, Open-RMF or alternative design, runtime validation, warehouse artifact integration, retrospective, then outreach activation. State the gate between each milestone. Limit work to one active build, one active validation, and external waiting items.

- [ ] **Step 4: Create the shared templates**

The portfolio-item template uses the canonical labels in the approved design. The runtime-experiment template contains environment, exact versions and digests, commands, expected and observed behavior, logs, screenshots, failures, interpretation, downstream changes, and next decision.

- [ ] **Step 5: Repair preserved portfolio documents**

Correct the compute path and replace unobserved performance wording. Mark the X series `Parked, not publication-ready`, remove its schedule, and state that quantitative claims require source validation before publishing.

- [ ] **Step 6: Remove the superseded progress file**

Delete `docs/progress.md` only after every still-current fact has a destination in `STATUS.md` or `ROADMAP.md`.

- [ ] **Step 7: Run focused control-plane checks**

Run `bash scripts/tests/test-portfolio-migration.sh`, `bash scripts/tests/test-portfolio-safety.sh`, and `bash scripts/portfolio-migration.sh verify`. Expected: all fixtures pass, required files and every required heading are checked individually, no aggregate `wc` row is evaluated, no whitespace error exists, and every Markdown or script file remains below 400 lines.

- [ ] **Step 8: Commit the control plane**

```bash
git add README.md STATUS.md ROADMAP.md docs/templates docs/decisions/compute-setup.md docs/x-posts/warehouse-amr-deployment-series.md docs/progress.md
git commit -m "docs: establish Physical AI portfolio control plane"
```

## Task 3: Align the Contributions track

**Files:**
- Modify: `README.md`
- Modify: `docs/contributions.md`

- [ ] **Step 1: Create an isolated Contributions worktree**

Create branch `chore/portfolio-taxonomy` from verified `main` in a global worktree under `/Users/hansel/.config/superpowers/worktrees/pai-lerobot-contrib/`.

- [ ] **Step 2: Rewrite the README**

Name the track “Physical AI Contributions.” Define its scope as work proposed to externally owned projects. List target ecosystems, link to the contribution log, state what belongs elsewhere, and link to `physical-ai-portfolio`.

- [ ] **Step 3: Correct the contribution record**

Keep the existing upstream PR facts. Add separate fields for execution status `Submitted` and upstream outcome `Open, awaiting maintainer review`. Preserve the follow-up date rule.

- [ ] **Step 4: Verify and commit**

```bash
git diff --check
test -r README.md
if rg -n 'Track contributions in `\.\./foundation' README.md; then exit 1; else test "$?" -eq 1; fi
git add README.md docs/contributions.md
git commit -m "docs: align repository with contributions track"
```

## Task 4: Align the Outreach track

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Create an isolated Outreach worktree**

Create branch `chore/portfolio-taxonomy` from verified `main` in a global worktree under `/Users/hansel/.config/superpowers/worktrees/pai-community/`.

- [ ] **Step 2: Rewrite the README**

Name the track “Physical AI Outreach.” Define publishable posts, generic networking targets, events, and public feedback as its boundary. Explicitly exclude personal names, contact history, direct messages, meeting notes, and non-public feedback. Mark the track Parked and link the existing generic target list and templates without sending anything.

Update the target-list tracking section to direct private relationship records outside the public repo without naming or inspecting a private store. Add ignore rules for contact exports and test that no tracked file matches the private-record patterns.

- [ ] **Step 3: Verify and commit**

```bash
git diff --check
rg -n 'Parked|restart|target-list|message-templates' README.md
git add README.md
git commit -m "docs: align repository with outreach track"
```

## Task 5: Align the Warehouse Project track

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Create an isolated Warehouse worktree**

Create branch `chore/portfolio-contract` from verified `main` in a global worktree under `/Users/hansel/.config/superpowers/worktrees/pai-warehouse-deployment/`.

- [ ] **Step 2: Rewrite the README**

Describe the project’s portfolio purpose, warehouse/3PL scope, learning goals, non-goals, exact artifact map, Docker and simulation entry points, current validation state, candidate Open-RMF experiment, and current portfolio URL. Repair old absolute paths in the three path-bearing runbooks without changing runtime behavior.

- [ ] **Step 3: Verify file references and commit**

Run:

```bash
missing=0; for file in docs/vendor-matrix.md docs/case-study-walmart-symbotic.md docs/prd-warehouse-amr-deployment.md docs/integration-architecture.md docs/deployment-checklist.md docs/playbook.md docs/amr-fleet-orchestration.md RUNBOOK_OPENRMF.md sim/open-rmf-office-demo/README.md sim/open-rmf-office-demo/office-demo-notes.md; do test -f "$file" || { echo "missing:$file"; missing=1; }; done; test "$missing" -eq 0
git diff --check
git add README.md RUNBOOK_OPENRMF.md docker/README.md docker/open-rmf/README.md
git commit -m "docs: define warehouse project portfolio contract"
```

## Task 6: Review and repair the complete content change

- [ ] **Step 1: Run one consolidated implementation review**

Compare all four branches against their live bases. Check taxonomy consistency, authority boundaries, status truthfulness, old-name handling, link targets, line limits, and absence of unrelated edits.

- [ ] **Step 2: Perform one repair cycle**

Fix every material finding, rerun the focused checks in Tasks 2 through 5, and commit each repository’s repair separately.

## Task 7: Ship and land the content branches

- [ ] **Step 1: Ship each repository exactly through gstack**

Run `/ship` in this order: Contributions, Outreach, Warehouse Project, Portfolio. Preserve every release check and stop only for the user-defined material exceptions.

- [ ] **Step 2: Land each repository exactly through gstack**

Run `/land-and-deploy` for each resulting PR in the same order. These documentation repositories have no configured deployment, so the workflow must still merge, reconcile, and verify live GitHub state.

- [ ] **Step 3: Confirm live main commits**

For every repository, compare local `main`, cached `origin/main`, and live `refs/heads/main`. Expected: all three match the merged commit.

## Task 8: Rename GitHub repositories and move local checkouts

- [ ] **Step 1: Remove completed global worktrees**

Use the recorded allowlist of worktrees created by this plan. Remove only an allowlisted clean worktree whose branch is merged. Abort on any unexpected linked worktree, then prune metadata.

- [ ] **Step 2: Migrate Portfolio end to end**

From the stable parent directory, run the neutral copied runner with `migrate-one portfolio --apply`, then invoke status by the new absolute path. Verify immutable ID, redirect, remote, clean HEAD, destination, metadata, journal, and reverse local move before `VERIFIED`.

- [ ] **Step 3: Migrate Contributions end to end**

Run the neutral runner for Contributions. Do not start unless Portfolio is `VERIFIED`.

- [ ] **Step 4: Migrate Outreach end to end**

Run the neutral runner for Outreach. Do not start unless Contributions is `VERIFIED`.

- [ ] **Step 5: Move the Warehouse project**

Run the neutral runner for Warehouse. This lane changes the local path and description without renaming GitHub. Do not start unless Outreach is `VERIFIED`.

- [ ] **Step 6: Verify redirects, histories, and project access**

Confirm old and new URLs, immutable IDs, local HEAD preservation, clean worktrees, remotes, descriptions, upstream PR, privacy separation, and zero unexplained old-name matches. Use the Codex app project-list query as a separate app-level gate and record IDs and path readback; the shell runner must not claim that result.

## Task 9: Reconcile final portfolio status

**Files:**
- Modify: `STATUS.md`
- Modify: `docs/decisions/2026-08-31-portfolio-reorganization.md`
- Modify in leaf reconciliation branches: Contributions, Outreach, and Warehouse READMEs.

- [ ] **Step 1: Create a final reconciliation branch**

From verified live `physical-ai-portfolio/main`, create `docs/portfolio-migration-reconciliation` in an isolated global worktree.

- [ ] **Step 2: Record the verified result**

Mark portfolio reorganization Complete only after all acceptance checks pass. Add new paths, new URLs, final live main commits, redirect results, preserved upstream PR, limitations, and the next decision to write a flagship experiment charter before choosing Open-RMF or an alternative.

- [ ] **Step 3: Verify, commit, ship, and land**

Canonicalize links in all affected repositories, update the local workspace README with a recorded hash, and run focused checks. Ship and land each reconciliation branch through `/ship` then `/land-and-deploy` exactly.

## Task 10: Final reconciliation and cleanup

- [ ] **Step 1: Verify every final repository**

Expected structure:

```text
/Users/hansel/conductor/repos/physical-ai/portfolio
/Users/hansel/conductor/repos/physical-ai/projects/warehouse-deployment
/Users/hansel/conductor/repos/physical-ai/contributions
/Users/hansel/conductor/repos/physical-ai/outreach
/Users/hansel/conductor/repos/physical-ai/forks/warehouse-amr-ros2
```

For each owned repository, local `main`, cached `origin/main`, and live GitHub `main` must match. All worktrees must be clean. Report any preserved unrelated state.

- [ ] **Step 2: Verify portfolio acceptance criteria**

Confirm the names, repository-purpose boundaries, control-plane files, status model, evidence templates, redirect behavior, upstream PR, and saved-project access. A reader must identify the current flagship work, evidence state, and next decision from the README in under 60 seconds. Confirm Open-RMF remains an unvalidated candidate, not a proven flagship case.

- [ ] **Step 3: Remove temporary worktrees and report completion**

Remove only the worktrees created by this plan after their branches have landed. Prune worktree metadata. Do not delete branches or repositories unless a later explicit cleanup decision requires it.

## Autoplan decision audit

Full CEO review: `/Users/hansel/.gstack/projects/hanselhansel-physical-ai-foundation/ceo-plans/2026-08-31-physical-ai-portfolio-reorganization.md`.

| # | Phase | Decision | Class | Principle | Result |
|---|---|---|---|---|---|
| 1 | CEO | Lead with evidence before governance | Mechanical | Explicit | Added |
| 2 | CEO | Exclude private relationship records from public Outreach | Mechanical | Complete | Added |
| 3 | CEO | Keep detailed status in leaf repositories | Mechanical | DRY | Added |
| 4 | CEO | Publish only links that resolve now | Mechanical | Explicit | Added |
| 5 | CEO | Migrate one repository at a time | Mechanical | Pragmatic | Added |
| 6 | CEO | Full migration versus thin pilot | User Challenge | User sovereignty | Full migration approved |
| 7 | CEO | Private discovery before flagship selection | User Challenge | User sovereignty | Outside Project A |
| 8 | CEO | Repository-purpose taxonomy versus deliverable taxonomy | User Challenge | User sovereignty | Repository-purpose retained |
| 9 | CEO | Open-RMF as next candidate versus select flagship first | User Challenge | User sovereignty | Candidate behind charter |
| 10 | DX | Add fail-closed migration runner and tests | Mechanical | Complete | Added |
| 11 | DX | Separate active project, next decision, and candidate experiment | Mechanical | Explicit | Added |
| 12 | DX | Replace batch moves with resumable repository lanes | Mechanical | Pragmatic | Added |
| 13 | DX | Update stale compute and X-post paths and states | Mechanical | Complete | Added |
| 14 | DX | Add freshness authority and recheck fields | Mechanical | Explicit | Added |
| 15 | Eng | Use neutral runner and private journal outside moving repos | Mechanical | Explicit | Added |
| 16 | Eng | Bind transitions to immutable GitHub identity | Mechanical | Complete | Added |
| 17 | Eng | Split Bash 3.2 modules below 400 lines | Mechanical | Pragmatic | Added |
| 18 | Eng | Test adapters in isolated fake GitHub and Git fixtures | Mechanical | Complete | Added |
| 19 | Eng | Repair every path-bearing warehouse file | Mechanical | Complete | Added |
| 20 | Eng | Reconcile canonical links in every leaf repo | Mechanical | Complete | Added |
| 21 | Eng | Verify saved projects through the app-level query | Mechanical | Explicit | Added |
| 22 | Eng | Keep full migration blocked until user challenges resolve | Mechanical | Safety | Added |

Full Engineering test plan: `/Users/hansel/.gstack/projects/hanselhansel-physical-ai-foundation/hansel-docs-physical-ai-portfolio-design-eng-review-test-plan-20260831-103500.md`.

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|---|---|---|---:|---|---|
| CEO Review | `/plan-ceo-review` | Scope and strategy | 1 | CLEAR | 9 decisions resolved, full migration retained |
| Codex Review | `/codex review` | Independent voice | 0 | ABSORBED | Codex voices ran inside CEO, DX, and Eng phases |
| Eng Review | `/plan-eng-review` | Architecture and tests | 1 | CLEAR | 8 issues folded, 0 critical gaps, approved to execute |
| Design Review | `/plan-design-review` | UI and UX | 0 | SKIPPED | No UI scope |
| DX Review | `/plan-devex-review` | Developer experience | 1 | CLEAR | 3.5/10 to planned 8.6/10, TTHW over 5m to under 2m |

**CROSS-MODEL:** Codex and independent subagents agreed on scope risk, migration state safety, privacy, and drift controls.

**VERDICT:** CEO + DX + ENG CLEARED. Ready to implement the approved full migration.

NO UNRESOLVED DECISIONS
