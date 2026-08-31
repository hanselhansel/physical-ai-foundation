# Physical AI portfolio reorganization

Date: 2026-08-31
Status: Approved, implementation active

## Decision

Adopt the repository-purpose taxonomy approved in the operating-model design:

- Portfolio governs the cross-repository map, roadmap, status, and decisions.
- Projects own portfolio work and evidence.
- Contributions track work proposed to externally owned projects.
- Outreach contains public communication only.
- Forks are working copies of externally owned code.

The user approved the full migration after the autoplan review. Private discovery remains outside Project A. Open-RMF remains an unvalidated candidate behind a flagship experiment charter.

## Current-practice evidence

Checked on 2026-08-31:

- GitHub redirects repository web and Git traffic after a rename.
- GitHub recommends updating local remote URLs after a rename.
- GitHub Pages URLs and calls to repository-hosted Actions are rename exceptions.
- Reusing an old repository name breaks its redirect.
- GitHub recommends a README in every repository and branch-based changes for owned repositories.

Sources:

- [Renaming a repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository)
- [Managing remote repositories](https://docs.github.com/en/get-started/git-basics/managing-remote-repositories)
- [Repository practices](https://docs.github.com/en/repositories/creating-and-managing-repositories/best-practices-for-repositories)
- [About repository READMEs](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes)

No owned repository contains a GitHub Pages `CNAME`, repository-hosted Action manifest, or tracked GitHub Actions workflow as of the baseline check.

## Baseline repository inventory

The read-only migration preflight passed on 2026-08-31.

| Key | Old local path | Old GitHub name | Immutable GitHub ID | Baseline main |
|---|---|---|---|---|
| Portfolio | `foundation/` | `physical-ai-foundation` | `R_kgDOUJNXtg` | `0a2f2e52094cfb0c639b1b1530cc8f3cfe366d93` |
| Contributions | `lerobot-contrib/` | `pai-lerobot-contrib` | `R_kgDOUJNX_Q` | `589868b710278642f0fa133b102f8486b377dea1` |
| Outreach | `community/` | `pai-community` | `R_kgDOUJNYJg` | `b91b56b2455c531a6bcec596f6b41dcb173feafe` |
| Warehouse | `warehouse-deployment/` | `pai-warehouse-deployment` | `R_kgDOUJNX2Q` | `aa11e3a70cd085073550509665276f095bf92643` |

For every owned repository, local `main`, cached `origin/main`, and live GitHub `main` matched at baseline. The three new GitHub names did not exist.

## Planned destinations

| Key | New local path | New GitHub name |
|---|---|---|
| Portfolio | `portfolio/` | `physical-ai-portfolio` |
| Contributions | `contributions/` | `pai-contributions` |
| Outreach | `outreach/` | `pai-outreach` |
| Warehouse | `projects/warehouse-deployment/` | `pai-warehouse-deployment` |

The workspace root is `/Users/hansel/conductor/repos/physical-ai` on a Darwin ARM64 Mac. The local workspace README baseline SHA-256 is `74aac42ca450f39fef97e98a431675796387e455ee66871c5f11d4a03e8846ab`.

## External continuity

The upstream contribution remains:

- PR: [Pouya-Mansournia/warehouse-amr-ros2#1](https://github.com/Pouya-Mansournia/warehouse-amr-ros2/pull/1)
- State: Open at baseline
- Head: `docs/deployment-considerations`
- Base: `main`

The external fork stays under `forks/warehouse-amr-ros2/` and is not renamed.

## Saved project inventory

The Codex app project list had no saved project rooted directly at any moving repository. The saved `/Users/hansel` project remains above the moving paths. App-level readback is still required after each local move.

## Safety model

Each repository migrates independently through:

```text
BASELINE
  -> REMOTE_RENAMED
  -> ORIGIN_UPDATED
  -> LOCAL_MOVED
  -> METADATA_UPDATED
  -> VERIFIED
```

The runner uses immutable GitHub IDs, exact main commits, separate fetch and push URLs, an atomic per-repository lock, and a private journal outside all moving checkouts. Remote rename recovery proceeds forward. Local moves remain reversible using the recorded source and destination.

The old repository names must not be reused.

## Privacy boundary

The public Outreach repository may contain generic target categories, public posts, talks, reusable messages, and public feedback. It must not contain personal names, contact history, direct messages, meeting notes, contact exports, or non-public feedback.

Migration inventory output records counts and boolean results. It does not record credentials, tokens, webhook URLs, environment values, or private relationship data.

## Next action

All four migration lanes are `VERIFIED`. Update the remaining leaf READMEs to canonical links, then rerun final reconciliation before starting the flagship experiment charter.

## Current verified lane state

| Purpose | Canonical GitHub repository | Canonical local path | Baseline main before reconciliation |
|---|---|---|---|
| Portfolio | `hanselhansel/physical-ai-portfolio` | `portfolio/` | `af03bcdd77d8ba0c2216f786ec6b2703f792d5e4` |
| Contributions | `hanselhansel/pai-contributions` | `contributions/` | `a58203be4dfbd3c651e28d607264dba272e44597` |
| Outreach | `hanselhansel/pai-outreach` | `outreach/` | `d2fdb09034d8ffda8f1aafeba740ab5ee8bdab37` |
| Warehouse project | `hanselhansel/pai-warehouse-deployment` | `projects/warehouse-deployment/` | `856a63e424f4bca2156d2cbe507e0595fe4647b2` |

All four private migration journals reached `VERIFIED`. GitHub readback retained the same immutable repository IDs through the renames. The old names remain redirects and must not be reused. The Codex saved-project readback found no project rooted directly at a moved path. The external warehouse AMR pull request remained accessible and open. The local workspace index was reconciled to the new structure with SHA-256 `80a19a6d96d13d6ff0538f3903717c33e54ff9c38c0f0968682bdc1bdbd122c2`.

Canonical leaf README reconciliation remains open. Contributions and Warehouse still link to `physical-ai-foundation`; Outreach also retains pre-migration `pai-community` wording. Project A remains Active until those links are updated and the final reconciliation gate passes.
