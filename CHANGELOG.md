# Changelog

## [0.1.0.3] - 2026-08-31

### Changed

- The [portfolio landing page](README.md), [status](STATUS.md), and [migration decision](docs/decisions/2026-08-31-portfolio-reorganization.md) now record all four repository lanes as `VERIFIED` while keeping the remaining leaf-link reconciliation explicit.
- The next portfolio action is now to canonicalize the remaining leaf README links and rerun final reconciliation.

### For contributors

- Expected app-gate stops now remove the active migration lock without emitting a Bash `unbound variable` cleanup error.
- A regression assertion now requires clean app-gate termination.

## [0.1.0.2] - 2026-08-31

### For contributors

- Migration functions now keep repository keys and transient state local, so nested predecessor verification preserves the caller's active lane.
- A regression assertion now protects the caller's repository key across nested verification.

## [0.1.0.1] - 2026-08-31

### Fixed

- You can now persist each repository's app-level readback in its private migration journal, so a verified predecessor lane does not require an unrelated current-shell flag.
- You can now revalidate healthy `VERIFIED` status using the journaled app gate. See the [operator commands](README.md#migration-operator-commands).

## [0.1.0.0] - 2026-08-31

### Added

- You can now navigate a public Physical AI Portfolio landing page with cross-project [status](STATUS.md), a [roadmap](ROADMAP.md), and reusable evidence templates.
- You can now trace the approved Portfolio, Projects, Contributions, Outreach, and Forks structure through the [operating-model design](docs/superpowers/specs/2026-08-31-physical-ai-portfolio-operating-model-design.md) and [implementation plan](docs/superpowers/plans/2026-08-31-physical-ai-portfolio-reorganization.md).
- You can now use a fail-closed repository migration CLI with immutable GitHub identity checks, private journals, atomic locks, dependency ordering, app-level gates, and resumable state transitions. See the [operator commands](README.md#migration-operator-commands).
- You can now verify migration, schema, identity, remotes, locks, app gates, and relative links with twenty-seven regression assertions.
- You can now inspect a dated [migration baseline](docs/decisions/2026-08-31-portfolio-reorganization.md) preserving repository IDs, commits, external contribution continuity, and current-practice sources.

### Changed

- The [landing page](README.md) now replaces the old Foundation sprint framing with an evidence-first Portfolio control plane.
- Open-RMF is now classified as an unvalidated candidate behind a flagship experiment charter in the [roadmap](ROADMAP.md).
- The [warehouse AMR post series](docs/x-posts/warehouse-amr-deployment-series.md) is now Parked and not publication-ready.
- The [local compute decision](docs/decisions/compute-setup.md) now distinguishes container availability from observed runtime performance.

### Fixed

- Verification now prevents aggregate line counts and duplicate status fields from masking validation failures.
- Migration now stops on wrong repository IDs, disallowed origins, occupied destinations, stale or live locks, unsafe test-mode use, broken links, and stale `VERIFIED` journals.
- Migration now preserves SSH or HTTPS remote protocols and enforces sequential repository dependencies.
