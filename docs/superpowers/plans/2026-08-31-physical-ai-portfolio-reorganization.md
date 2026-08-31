# Physical AI Portfolio Reorganization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the Physical AI workspace into the approved Portfolio, Projects, Contributions, Outreach, and Forks model without losing Git history, breaking public links, or overstating validation.

**Architecture:** `physical-ai-portfolio` becomes the cross-repository control plane. Independent execution repositories remain authoritative for their artifacts and evidence. Content changes land before GitHub repository renames and local directory moves, then a final portfolio reconciliation records the verified result.

**Tech Stack:** Git, GitHub CLI, Markdown, shell verification, Codex local projects

---

## Pre-execution review gate

Run the gstack autoplan workflow against this plan and the approved design before Task 1. Apply only in-scope decisions. Record any required scope escalation before implementation begins.

## File map

### Portfolio repository

- Modify: `README.md`, public landing page and MECE repository map.
- Create: `STATUS.md`, current portfolio items and evidence state.
- Create: `ROADMAP.md`, ordered milestones and activation gates.
- Create: `docs/decisions/2026-08-31-portfolio-reorganization.md`, before-and-after migration record.
- Create: `docs/templates/portfolio-item.md`, reusable status record.
- Create: `docs/templates/runtime-experiment.md`, reusable runtime evidence record.
- Delete: `docs/progress.md`, after its useful content moves to `STATUS.md` and `ROADMAP.md`.
- Preserve: `docs/decisions/compute-setup.md` and `docs/x-posts/warehouse-amr-deployment-series.md`.

### Contributions repository

- Modify: `README.md`, contribution-track contract and current contribution link.
- Modify: `docs/contributions.md`, separate submission execution from upstream outcome.

### Outreach repository

- Modify: `README.md`, outreach-track contract, parked state, and restart condition.
- Preserve: `networking/target-list.md` and `networking/message-templates.md`.

### Warehouse project repository

- Modify: `README.md`, project contract, accurate artifact map, validation state, reproduction entry points, and portfolio link.
- Preserve: all existing research, runbooks, Docker files, and simulation files.

## Task 1: Capture and verify the migration baseline

**Files:**
- Create: `docs/decisions/2026-08-31-portfolio-reorganization.md`

- [ ] **Step 1: Recheck live Git state for all repositories**

Run from `/Users/hansel`:

```bash
for repo in foundation warehouse-deployment lerobot-contrib community forks/warehouse-amr-ros2; do
  path="/Users/hansel/conductor/repos/physical-ai/$repo"
  git -C "$path" status --short --branch
  git -C "$path" rev-parse HEAD
  git -C "$path" rev-parse refs/remotes/origin/main 2>/dev/null || true
  git -C "$path" ls-remote origin refs/heads/main
  git -C "$path" remote -v
done
```

Expected: clean worktrees; local, cached, and live `main` match for owned repositories; the fork contribution branch remains distinct from `main`.

- [ ] **Step 2: Recheck rename exceptions and external dependencies**

Run:

```bash
for repo in foundation warehouse-deployment lerobot-contrib community; do
  path="/Users/hansel/conductor/repos/physical-ai/$repo"
  find "$path" -path '*/.git' -prune -o \( -path '*/.github/workflows/*' -o -name CNAME -o -name action.yml -o -name action.yaml \) -print
done
gh pr view https://github.com/Pouya-Mansournia/warehouse-amr-ros2/pull/1 --json state,url,headRefName,baseRefName,mergeStateStatus
```

Expected: no Pages or repository-hosted Action files; upstream PR `#1` is open and resolvable.

- [ ] **Step 3: Write the baseline decision record**

Record the approved taxonomy, official GitHub rename caveats, every old path and remote, every baseline HEAD, the upstream PR URL, the absence of Pages and hosted Actions, and the rule that old repository names must not be reused.

- [ ] **Step 4: Verify and commit the baseline**

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

Include the portfolio purpose, warehouse/logistics starting domain, PM/deployment/solutions focus, MECE taxonomy, repository table, authority boundaries, current priority, and links to `STATUS.md` and `ROADMAP.md`. Use the approved future GitHub names.

- [ ] **Step 2: Create the status record**

Create entries for portfolio reorganization, Open-RMF validation, warehouse evidence audit, upstream warehouse AMR contribution, X posts, networking materials, and compute decision. Use only the approved statuses. Each entry must include objective, success criteria, required validation, evidence, result, limitations, next decision, and last verified date.

- [ ] **Step 3: Create the roadmap**

Define this order: portfolio reorganization, Open-RMF design, Open-RMF runtime validation, warehouse artifact integration, retrospective, then outreach activation. State the gate between each milestone.

- [ ] **Step 4: Create the shared templates**

The portfolio-item template contains every required status field. The runtime-experiment template contains environment, exact versions and digests, commands, expected and observed behavior, logs, screenshots, failures, interpretation, downstream changes, and next decision.

- [ ] **Step 5: Remove the superseded progress file**

Delete `docs/progress.md` only after every still-current fact has a destination in `STATUS.md` or `ROADMAP.md`.

- [ ] **Step 6: Run focused control-plane checks**

Run:

```bash
test -f README.md && test -f STATUS.md && test -f ROADMAP.md
test -f docs/templates/portfolio-item.md && test -f docs/templates/runtime-experiment.md
test ! -e docs/progress.md
rg -n '^## (Portfolio|Projects|Contributions|Outreach|Forks)' README.md
rg -n 'Backlog|Ready|Active|Waiting|Complete|Parked|Dropped' STATUS.md
git diff --check
find . -path './.git' -prune -o -type f -print0 | xargs -0 wc -l | awk '$1 >= 400 {print; bad=1} END {exit bad}'
```

Expected: all required files exist, the old progress file is absent, required categories and statuses are present, no whitespace errors, and every file remains below 400 lines.

- [ ] **Step 7: Commit the control plane**

```bash
git add README.md STATUS.md ROADMAP.md docs/templates docs/progress.md
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
! rg -n 'Track contributions in `\.\./foundation' README.md
git add README.md docs/contributions.md
git commit -m "docs: align repository with contributions track"
```

## Task 4: Align the Outreach track

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Create an isolated Outreach worktree**

Create branch `chore/portfolio-taxonomy` from verified `main` in a global worktree under `/Users/hansel/.config/superpowers/worktrees/pai-community/`.

- [ ] **Step 2: Rewrite the README**

Name the track “Physical AI Outreach.” Define publishing, networking, events, and external feedback as its boundary. Mark the track Parked. Set the restart condition to completion of a validated portfolio case approved for external communication. Link the existing target list and message templates without sending anything.

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

Describe the project’s portfolio purpose, warehouse/3PL scope, learning goals, non-goals, exact artifact map, Docker and simulation entry points, current validation state, next Open-RMF milestone, and link to `physical-ai-portfolio`. Do not claim the Open-RMF runtime has succeeded.

- [ ] **Step 3: Verify file references and commit**

Run:

```bash
for file in docs/vendor-matrix.md docs/case-study-walmart-symbotic.md docs/prd-warehouse-amr-deployment.md docs/integration-architecture.md docs/deployment-checklist.md docs/playbook.md docs/amr-fleet-orchestration.md RUNBOOK_OPENRMF.md sim/open-rmf-office-demo/README.md sim/open-rmf-office-demo/office-demo-notes.md; do test -f "$file"; done
git diff --check
git add README.md
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

Use `git worktree remove` from each main checkout, then `git worktree prune`. Confirm no branch is checked out outside its main checkout before moving directories.

- [ ] **Step 2: Rename GitHub repositories**

Run:

```bash
gh repo rename physical-ai-portfolio --repo hanselhansel/physical-ai-foundation --yes
gh repo rename pai-contributions --repo hanselhansel/pai-lerobot-contrib --yes
gh repo rename pai-outreach --repo hanselhansel/pai-community --yes
```

Expected: the three new repository URLs resolve and the old URLs redirect. Do not recreate the old names.

- [ ] **Step 3: Update local remote URLs**

Run before moving the checkouts:

```bash
git -C /Users/hansel/conductor/repos/physical-ai/foundation remote set-url origin https://github.com/hanselhansel/physical-ai-portfolio.git
git -C /Users/hansel/conductor/repos/physical-ai/lerobot-contrib remote set-url origin https://github.com/hanselhansel/pai-contributions.git
git -C /Users/hansel/conductor/repos/physical-ai/community remote set-url origin https://github.com/hanselhansel/pai-outreach.git
```

Verify each with `git remote -v`.

- [ ] **Step 4: Move clean local checkouts**

Verify that none of the four destinations exists, then run:

```bash
mkdir -p /Users/hansel/conductor/repos/physical-ai/projects
mv /Users/hansel/conductor/repos/physical-ai/foundation /Users/hansel/conductor/repos/physical-ai/portfolio
mv /Users/hansel/conductor/repos/physical-ai/lerobot-contrib /Users/hansel/conductor/repos/physical-ai/contributions
mv /Users/hansel/conductor/repos/physical-ai/community /Users/hansel/conductor/repos/physical-ai/outreach
mv /Users/hansel/conductor/repos/physical-ai/warehouse-deployment /Users/hansel/conductor/repos/physical-ai/projects/warehouse-deployment
```

Use explicit absolute paths. Do not use recursive deletion, globs, or unresolved variables.

- [ ] **Step 5: Update GitHub descriptions**

Run:

```bash
gh repo edit hanselhansel/physical-ai-portfolio --description "Control plane and public index for Hansel's Physical AI projects, contributions, evidence, and roadmap."
gh repo edit hanselhansel/pai-contributions --description "Open-source contributions across Open-RMF, ROS 2, Nav2, Isaac, Foxglove, and Physical AI deployment tooling."
gh repo edit hanselhansel/pai-outreach --description "Physical AI publishing, outreach, networking, and external feedback."
gh repo edit hanselhansel/pai-warehouse-deployment --description "Warehouse Physical AI portfolio project: AMR deployment research, WMS integration, playbooks, and reproducible Open-RMF experiments."
```

- [ ] **Step 6: Verify redirects, histories, and project access**

Confirm old and new GitHub URLs, local HEAD preservation, clean worktrees, updated remotes, upstream PR access, and Codex project discovery. No saved Codex project currently points directly at the moving repositories, so no project registration rewrite is expected.

## Task 9: Reconcile final portfolio status

**Files:**
- Modify: `STATUS.md`
- Modify: `docs/decisions/2026-08-31-portfolio-reorganization.md`

- [ ] **Step 1: Create a final reconciliation branch**

From verified live `physical-ai-portfolio/main`, create `docs/portfolio-migration-reconciliation` in an isolated global worktree.

- [ ] **Step 2: Record the verified result**

Mark portfolio reorganization Complete only after all acceptance checks pass. Add new paths, new remotes, final live main commits, redirect results, preserved upstream PR, limitations, and the next decision to design the Open-RMF validation cycle.

- [ ] **Step 3: Verify, commit, ship, and land**

Run focused Markdown, line-limit, remote, and link checks. Commit the reconciliation. Run `/ship` exactly, followed by `/land-and-deploy` exactly.

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

Confirm the MECE names, control-plane files, repository contracts, status model, evidence templates, redirect behavior, upstream PR, and saved-project access. Confirm Open-RMF remains the next unvalidated runtime milestone.

- [ ] **Step 3: Remove temporary worktrees and report completion**

Remove only the worktrees created by this plan after their branches have landed. Prune worktree metadata. Do not delete branches or repositories unless a later explicit cleanup decision requires it.
