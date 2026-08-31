#!/bin/bash
set -euo pipefail

TEST_DIR=$(cd "$(dirname "$0")" && pwd)
RUNNER=$(cd "$TEST_DIR/.." && pwd)/portfolio-migration.sh
PASS_COUNT=0
FAIL_COUNT=0

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf '[PASS] %s\n' "$1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf '[FAIL] %s\n' "$1" >&2
}

make_fixture() {
  fixture_root=$1
  portfolio_root="$fixture_root/foundation"
  mkdir -p "$portfolio_root/docs/templates"
  printf '# Portfolio\n\n## Portfolio\n## Projects\n## Contributions\n## Outreach\n## Forks\n' > "$portfolio_root/README.md"
  printf '# Status\n\n## Migration\n\n- **Title:** Migration\n- **Category:** Portfolio\n- **Objective:** Test\n- **Workflow status:** Active\n- **Success criteria:** Green\n- **Required validation:** Runtime\n- **Evidence links:** none\n- **Result:** pending\n- **Limitations:** none\n- **Next decision:** run\n- **Authority:** fixture\n- **Observed at:** now\n- **Source commit:** abc\n- **Fresh until:** later\n- **Recheck command:** test\n' > "$portfolio_root/STATUS.md"
  printf '# Roadmap\n' > "$portfolio_root/ROADMAP.md"
  printf '# Item\n' > "$portfolio_root/docs/templates/portfolio-item.md"
  printf '# Experiment\n' > "$portfolio_root/docs/templates/runtime-experiment.md"
}

run_verify() {
  workspace_root=$1
  "$RUNNER" verify --workspace-root "$workspace_root"
}

make_git_repo() {
  repo=$1
  git -C "$repo" init -q -b main
  git -C "$repo" config user.name Test
  git -C "$repo" config user.email test@example.com
  printf 'fixture\n' > "$repo/tracked.txt"
  git -C "$repo" add tracked.txt
  git -C "$repo" commit -q -m fixture
  git -C "$repo" remote add origin https://github.com/hanselhansel/physical-ai-foundation.git
}

make_git_repo_with_bare_origin() {
  repo=$1
  bare=$2
  git init -q --bare "$bare"
  git -C "$repo" init -q -b main
  git -C "$repo" config user.name Test
  git -C "$repo" config user.email test@example.com
  printf 'fixture\n' > "$repo/tracked.txt"
  git -C "$repo" add tracked.txt
  git -C "$repo" commit -q -m fixture
  git -C "$repo" remote add origin "$bare"
  git -C "$repo" push -q -u origin main
}

make_fake_gh() {
  bin_dir=$1
  mkdir -p "$bin_dir"
  # shellcheck disable=SC2016
  printf '%s\n' '#!/bin/bash' 'set -eu' 'printf "%s\n" "$*" >> "$FAKE_GH_LOG"' 'if test "$1 $2" = "auth status"; then exit 0; fi' 'if test "$1 $2" = "repo view"; then' '  case "$3" in' '    hanselhansel/physical-ai-foundation) printf "%s\n" "{\"id\":\"R_kgDOUJNXtg\",\"name\":\"physical-ai-foundation\",\"url\":\"https://github.com/hanselhansel/physical-ai-foundation\",\"viewerPermission\":\"ADMIN\",\"defaultBranchRef\":{\"name\":\"main\"}}"; exit 0 ;;' '    hanselhansel/physical-ai-portfolio) exit 1 ;;' '  esac' 'fi' 'if test "$1 $2" = "repo rename"; then exit 0; fi' 'exit 1' > "$bin_dir/gh"
  chmod +x "$bin_dir/gh"
}

make_stateful_fake_gh() {
  bin_dir=$1
  mkdir -p "$bin_dir"
  # shellcheck disable=SC2016
  printf '%s\n' '#!/bin/bash' 'set -eu' 'printf "%s\n" "$*" >> "$FAKE_GH_LOG"' 'current=$(cat "$FAKE_GH_STATE")' 'repo_id=${FAKE_GH_ID:-R_kgDOUJNXtg}' 'if test "$1 $2" = "auth status"; then exit 0; fi' 'if test "$1 $2" = "repo view"; then' '  requested=${3#hanselhansel/}' '  test "$requested" = "$current" || exit 1' '  printf "{\"id\":\"%s\",\"name\":\"%s\",\"url\":\"https://github.com/hanselhansel/%s\",\"viewerPermission\":\"ADMIN\",\"defaultBranchRef\":{\"name\":\"main\"}}\n" "$repo_id" "$current" "$current"' '  exit 0' 'fi' 'if test "$1 $2" = "repo rename"; then' '  printf "%s\n" "$3" > "$FAKE_GH_STATE"' '  exit 0' 'fi' 'if test "$1 $2" = "repo edit"; then exit 0; fi' 'exit 1' > "$bin_dir/gh"
  chmod +x "$bin_dir/gh"
}

test_399_lines_passes() {
  root=$(mktemp -d)
  make_fixture "$root"
  awk 'BEGIN { for (i = 1; i <= 399; i++) print "line" }' > "$root/foundation/under-limit.md"
  if run_verify "$root" >/dev/null 2>&1; then
    pass '399-line file passes'
  else
    fail '399-line file should pass'
  fi
  rm -rf "$root"
}

test_400_lines_fails_without_total_row_false_positive() {
  root=$(mktemp -d)
  make_fixture "$root"
  awk 'BEGIN { for (i = 1; i <= 400; i++) print "line" }' > "$root/foundation/at-limit.md"
  output=$(run_verify "$root" 2>&1 || true)
  if printf '%s' "$output" | grep -q 'FILE_TOO_LONG.*at-limit.md.*observed=400'; then
    pass '400-line file fails with its own path'
  else
    fail '400-line file did not produce the expected labelled failure'
  fi
  if printf '%s' "$output" | grep -q 'total'; then
    fail 'line check evaluated an aggregate total row'
  else
    pass 'line check has no aggregate total row'
  fi
  rm -rf "$root"
}

test_migrate_dry_run_has_zero_mutations() {
  root=$(mktemp -d)
  mkdir -p "$root/foundation"
  make_git_repo "$root/foundation"
  fake_bin="$root/fake-bin"
  make_fake_gh "$fake_bin"
  export FAKE_GH_LOG="$root/gh.log"
  : > "$FAKE_GH_LOG"
  output=$(PATH="$fake_bin:$PATH" PORTFOLIO_STATE_DIR="$root/state" "$RUNNER" migrate-one portfolio --workspace-root "$root" 2>&1 || true)
  if printf '%s' "$output" | grep -q 'DRY_RUN.*repo=portfolio.*state=BASELINE'; then
    pass 'dry run reports the baseline state'
  else
    fail 'dry run did not report the baseline state'
  fi
  if test -d "$root/foundation" && test ! -e "$root/portfolio" && ! grep -q '^repo rename' "$FAKE_GH_LOG"; then
    pass 'dry run performs zero mutations'
  else
    fail 'dry run mutated GitHub or the filesystem'
  fi
  rm -rf "$root"
}

test_migrate_apply_reaches_verified() {
  root=$(mktemp -d)
  mkdir -p "$root/foundation"
  make_git_repo "$root/foundation"
  fake_bin="$root/fake-bin"
  make_stateful_fake_gh "$fake_bin"
  export FAKE_GH_LOG="$root/gh.log"
  export FAKE_GH_STATE="$root/gh.state"
  printf 'physical-ai-foundation\n' > "$FAKE_GH_STATE"
  : > "$FAKE_GH_LOG"
  state_dir="$root/state"
  if PATH="$fake_bin:$PATH" PORTFOLIO_STATE_DIR="$state_dir" PORTFOLIO_APP_GATE=passed PORTFOLIO_TEST_MODE=1 "$RUNNER" migrate-one portfolio --workspace-root "$root" --apply >/dev/null 2>&1; then
    apply_status=0
  else
    apply_status=$?
  fi
  remote=$(git -C "$root/portfolio" remote get-url origin 2>/dev/null || true)
  state=$(awk -F= '$1 == "state" { print $2 }' "$state_dir/portfolio.journal" 2>/dev/null || true)
  if test "$apply_status" -eq 0 && test -d "$root/portfolio/.git" && test ! -e "$root/foundation" && test "$remote" = 'https://github.com/hanselhansel/physical-ai-portfolio.git' && test "$state" = VERIFIED; then
    pass 'apply migrates one repository to VERIFIED'
  else
    fail "apply did not reach VERIFIED status=$apply_status remote=$remote state=$state"
  fi
  if grep -q '^repo rename physical-ai-portfolio' "$FAKE_GH_LOG" && grep -q '^repo edit hanselhansel/physical-ai-portfolio' "$FAKE_GH_LOG"; then
    pass 'apply renamed and updated repository metadata'
  else
    fail 'apply did not call rename and metadata operations'
  fi
  rm -rf "$root"
}

test_dirty_worktree_stops_before_remote_mutation() {
  root=$(mktemp -d)
  mkdir -p "$root/foundation"
  make_git_repo "$root/foundation"
  printf 'dirty\n' >> "$root/foundation/tracked.txt"
  fake_bin="$root/fake-bin"
  make_stateful_fake_gh "$fake_bin"
  export FAKE_GH_LOG="$root/gh.log" FAKE_GH_STATE="$root/gh.state"
  printf 'physical-ai-foundation\n' > "$FAKE_GH_STATE"
  : > "$FAKE_GH_LOG"
  output=$(PATH="$fake_bin:$PATH" PORTFOLIO_STATE_DIR="$root/state" PORTFOLIO_APP_GATE=passed PORTFOLIO_TEST_MODE=1 "$RUNNER" migrate-one portfolio --workspace-root "$root" --apply 2>&1 || true)
  if printf '%s' "$output" | grep -q 'DIRTY_WORKTREE' && ! grep -q '^repo rename' "$FAKE_GH_LOG" && test -d "$root/foundation"; then
    pass 'dirty worktree stops before mutation'
  else
    fail 'dirty worktree did not fail closed'
  fi
  rm -rf "$root"
}

test_resume_after_remote_rename() {
  root=$(mktemp -d)
  mkdir -p "$root/foundation"
  make_git_repo "$root/foundation"
  fake_bin="$root/fake-bin"
  make_stateful_fake_gh "$fake_bin"
  export FAKE_GH_LOG="$root/gh.log" FAKE_GH_STATE="$root/gh.state"
  printf 'physical-ai-portfolio\n' > "$FAKE_GH_STATE"
  : > "$FAKE_GH_LOG"
  if PATH="$fake_bin:$PATH" PORTFOLIO_STATE_DIR="$root/state" PORTFOLIO_APP_GATE=passed PORTFOLIO_TEST_MODE=1 "$RUNNER" migrate-one portfolio --workspace-root "$root" --apply >/dev/null 2>&1; then
    status=0
  else
    status=$?
  fi
  if test "$status" -eq 0 && test -d "$root/portfolio/.git" && ! grep -q '^repo rename' "$FAKE_GH_LOG"; then
    pass 'remote-renamed state resumes forward without a second rename'
  else
    fail "remote-renamed state did not resume status=$status"
  fi
  rm -rf "$root"
}

test_preflight_fails_on_dirty_canonical_main() {
  root=$(mktemp -d)
  mkdir -p "$root/foundation"
  make_git_repo_with_bare_origin "$root/foundation" "$root/origin.git"
  printf 'dirty\n' >> "$root/foundation/tracked.txt"
  fake_bin="$root/fake-bin"
  make_stateful_fake_gh "$fake_bin"
  export FAKE_GH_LOG="$root/gh.log" FAKE_GH_STATE="$root/gh.state"
  printf 'physical-ai-foundation\n' > "$FAKE_GH_STATE"
  : > "$FAKE_GH_LOG"
  output=$(PATH="$fake_bin:$PATH" PORTFOLIO_STATE_DIR="$root/state" "$RUNNER" preflight --workspace-root "$root" --only portfolio 2>&1 || true)
  if printf '%s' "$output" | grep -q 'DIRTY_WORKTREE.*repo=portfolio'; then
    pass 'preflight fails closed on dirty canonical main'
  else
    fail 'preflight did not reject dirty canonical main'
  fi
  rm -rf "$root"
}

test_verify_accepts_direct_portfolio_checkout() {
  root=$(mktemp -d)
  make_fixture "$root"
  if "$RUNNER" verify --workspace-root "$root/foundation" >/dev/null 2>&1; then
    pass 'verify accepts an isolated portfolio checkout root'
  else
    fail 'verify rejected an isolated portfolio checkout root'
  fi
  rm -rf "$root"
}

test_verify_rejects_missing_status_field() {
  root=$(mktemp -d)
  make_fixture "$root"
  grep -v '^- \*\*Fresh until:' "$root/foundation/STATUS.md" > "$root/foundation/STATUS.tmp"
  mv "$root/foundation/STATUS.tmp" "$root/foundation/STATUS.md"
  if output=$(run_verify "$root" 2>&1); then
    status=0
  else
    status=$?
  fi
  if test "$status" -ne 0 && printf '%s' "$output" | grep -q 'STATUS_FIELD_MISSING.*Fresh until'; then
    pass 'verify rejects a status item missing a required field'
  else
    fail 'verify accepted a status item with a missing required field'
  fi
  rm -rf "$root"
}

test_wrong_repository_id_stops_before_mutation() {
  root=$(mktemp -d)
  mkdir -p "$root/foundation"
  make_git_repo "$root/foundation"
  fake_bin="$root/fake-bin"
  make_stateful_fake_gh "$fake_bin"
  export FAKE_GH_LOG="$root/gh.log" FAKE_GH_STATE="$root/gh.state" FAKE_GH_ID=R_unrelated
  printf 'physical-ai-foundation\n' > "$FAKE_GH_STATE"
  : > "$FAKE_GH_LOG"
  output=$(PATH="$fake_bin:$PATH" PORTFOLIO_STATE_DIR="$root/state" PORTFOLIO_APP_GATE=passed PORTFOLIO_TEST_MODE=1 "$RUNNER" migrate-one portfolio --workspace-root "$root" --apply 2>&1 || true)
  unset FAKE_GH_ID
  if printf '%s' "$output" | grep -q 'REPOSITORY_ID_MISMATCH' && ! grep -q '^repo rename' "$FAKE_GH_LOG" && test -d "$root/foundation"; then
    pass 'wrong immutable repository ID stops before mutation'
  else
    fail 'wrong immutable repository ID was not rejected'
  fi
  rm -rf "$root"
}

test_verified_journal_does_not_override_corrupt_live_state() {
  root=$(mktemp -d)
  mkdir -p "$root/foundation"
  make_git_repo "$root/foundation"
  fake_bin="$root/fake-bin"
  make_stateful_fake_gh "$fake_bin"
  export FAKE_GH_LOG="$root/gh.log" FAKE_GH_STATE="$root/gh.state"
  printf 'physical-ai-foundation\n' > "$FAKE_GH_STATE"
  : > "$FAKE_GH_LOG"
  PATH="$fake_bin:$PATH" PORTFOLIO_STATE_DIR="$root/state" PORTFOLIO_APP_GATE=passed PORTFOLIO_TEST_MODE=1 "$RUNNER" migrate-one portfolio --workspace-root "$root" --apply >/dev/null 2>&1
  printf 'physical-ai-foundation\n' > "$FAKE_GH_STATE"
  git -C "$root/portfolio" remote set-url origin https://github.com/hanselhansel/physical-ai-foundation.git
  output=$(PATH="$fake_bin:$PATH" PORTFOLIO_STATE_DIR="$root/state" PORTFOLIO_APP_GATE=passed PORTFOLIO_TEST_MODE=1 "$RUNNER" migrate-one portfolio --workspace-root "$root" --apply 2>&1 || true)
  if printf '%s' "$output" | grep -q 'VERIFICATION_FAILED'; then
    pass 'VERIFIED journal is revalidated against live state'
  else
    fail 'VERIFIED journal bypassed corrupt live state'
  fi
  rm -rf "$root"
}

test_lane_dependency_blocks_out_of_order_migration() {
  root=$(mktemp -d)
  mkdir -p "$root/community"
  make_git_repo "$root/community"
  fake_bin="$root/fake-bin"
  make_stateful_fake_gh "$fake_bin"
  export FAKE_GH_LOG="$root/gh.log" FAKE_GH_STATE="$root/gh.state" FAKE_GH_ID=R_kgDOUJNYJg
  printf 'pai-community\n' > "$FAKE_GH_STATE"
  : > "$FAKE_GH_LOG"
  output=$(PATH="$fake_bin:$PATH" PORTFOLIO_STATE_DIR="$root/state" PORTFOLIO_APP_GATE=passed PORTFOLIO_TEST_MODE=1 "$RUNNER" migrate-one outreach --workspace-root "$root" --apply 2>&1 || true)
  unset FAKE_GH_ID
  if printf '%s' "$output" | grep -q 'DEPENDENCY_NOT_VERIFIED.*contributions' && ! grep -q '^repo rename' "$FAKE_GH_LOG"; then
    pass 'lane dependency blocks out-of-order migration'
  else
    fail 'out-of-order migration did not fail on predecessor state'
  fi
  rm -rf "$root"
}

test_status_schema_validates_each_item_independently() {
  root=$(mktemp -d)
  make_fixture "$root"
  printf '%s\n' '- **Fresh until:** duplicate' '## Second' '- **Title:** Second' '- **Category:** Portfolio' '- **Objective:** Test' '- **Workflow status:** Active' '- **Success criteria:** Green' '- **Required validation:** Runtime' '- **Evidence links:** none' '- **Result:** pending' '- **Limitations:** none' '- **Next decision:** run' '- **Authority:** fixture' '- **Observed at:** now' '- **Source commit:** def' '- **Recheck command:** test' >> "$root/foundation/STATUS.md"
  output=$(run_verify "$root" 2>&1 || true)
  if printf '%s' "$output" | grep -q 'STATUS_FIELD_MISSING.*section=Second.*Fresh until'; then
    pass 'status schema validates every item independently'
  else
    fail 'duplicate status field masked a missing field in another item'
  fi
  rm -rf "$root"
}

test_stale_lock_is_recovered_safely() {
  root=$(mktemp -d)
  mkdir -p "$root/foundation" "$root/state/portfolio.lock"
  make_git_repo "$root/foundation"
  printf '999999\n' > "$root/state/portfolio.lock/pid"
  fake_bin="$root/fake-bin"
  make_stateful_fake_gh "$fake_bin"
  export FAKE_GH_LOG="$root/gh.log" FAKE_GH_STATE="$root/gh.state"
  printf 'physical-ai-foundation\n' > "$FAKE_GH_STATE"
  : > "$FAKE_GH_LOG"
  output=$(PATH="$fake_bin:$PATH" PORTFOLIO_STATE_DIR="$root/state" PORTFOLIO_APP_GATE=passed PORTFOLIO_TEST_MODE=1 "$RUNNER" migrate-one portfolio --workspace-root "$root" --apply 2>&1 || true)
  if printf '%s' "$output" | grep -q 'STALE_LOCK_CLEARED' && printf '%s' "$output" | grep -q 'state=VERIFIED'; then
    pass 'stale lock is cleared only after owner liveness check'
  else
    fail 'stale lock had no safe recovery path'
  fi
  rm -rf "$root"
}

test_399_lines_passes
test_400_lines_fails_without_total_row_false_positive
test_migrate_dry_run_has_zero_mutations
test_migrate_apply_reaches_verified
test_dirty_worktree_stops_before_remote_mutation
test_resume_after_remote_rename
test_preflight_fails_on_dirty_canonical_main
test_verify_accepts_direct_portfolio_checkout
test_verify_rejects_missing_status_field
test_wrong_repository_id_stops_before_mutation
test_verified_journal_does_not_override_corrupt_live_state
test_lane_dependency_blocks_out_of_order_migration
test_status_schema_validates_each_item_independently
test_stale_lock_is_recovered_safely

printf 'tests=%s failures=%s\n' "$((PASS_COUNT + FAIL_COUNT))" "$FAIL_COUNT"
test "$FAIL_COUNT" -eq 0
