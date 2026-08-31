#!/bin/bash
set -euo pipefail

TEST_DIR=$(cd "$(dirname "$0")" && pwd)
RUNNER=$(cd "$TEST_DIR/.." && pwd)/portfolio-migration.sh
# shellcheck disable=SC1091
. "$TEST_DIR/test-helpers.sh"
passed=0
failed=0

pass() { passed=$((passed + 1)); printf '[PASS] %s\n' "$1"; }
fail() { failed=$((failed + 1)); printf '[FAIL] %s\n' "$1" >&2; }

setup_portfolio_fixture() {
  root=$1
  mkdir -p "$root/foundation"
  make_git_repo "$root/foundation"
  fake_bin="$root/fake-bin"
  make_stateful_fake_gh "$fake_bin"
  export FAKE_GH_LOG="$root/gh.log" FAKE_GH_STATE="$root/gh.state"
  printf 'physical-ai-foundation\n' > "$FAKE_GH_STATE"
  : > "$FAKE_GH_LOG"
}

make_docs_fixture() {
  root=$1
  mkdir -p "$root/foundation/docs/templates"
  printf '# Portfolio\n\n## Portfolio\n## Projects\n## Contributions\n## Outreach\n## Forks\n' > "$root/foundation/README.md"
  printf '# Status\n\n## Item\n\n- **Title:** Item\n- **Category:** Portfolio\n- **Objective:** Test\n- **Workflow status:** Active\n- **Success criteria:** Green\n- **Required validation:** Runtime\n- **Evidence links:** none\n- **Result:** pending\n- **Limitations:** none\n- **Next decision:** run\n- **Authority:** fixture\n- **Observed at:** now\n- **Source commit:** abc\n- **Fresh until:** later\n- **Recheck command:** test\n' > "$root/foundation/STATUS.md"
  printf '# Roadmap\n' > "$root/foundation/ROADMAP.md"
  printf '# Item\n' > "$root/foundation/docs/templates/portfolio-item.md"
  printf '# Experiment\n' > "$root/foundation/docs/templates/runtime-experiment.md"
}

test_app_gate_blocks_verified() {
  root=$(mktemp -d)
  setup_portfolio_fixture "$root"
  output=$(PATH="$fake_bin:$PATH" PORTFOLIO_STATE_DIR="$root/state" PORTFOLIO_TEST_MODE=1 "$RUNNER" migrate-one portfolio --workspace-root "$root" --apply 2>&1 || true)
  state=$(awk -F= '$1 == "state" { print $2 }' "$root/state/portfolio.journal")
  if printf '%s' "$output" | grep -q 'APP_GATE_PENDING' && test "$state" = METADATA_UPDATED; then pass 'app gate blocks VERIFIED'; else fail 'app gate did not block VERIFIED'; fi
  rm -rf "$root"
}

test_ssh_remote_is_preserved() {
  root=$(mktemp -d)
  setup_portfolio_fixture "$root"
  git -C "$root/foundation" remote set-url origin git@github.com:hanselhansel/physical-ai-foundation.git
  PATH="$fake_bin:$PATH" PORTFOLIO_STATE_DIR="$root/state" PORTFOLIO_APP_GATE=passed PORTFOLIO_TEST_MODE=1 "$RUNNER" migrate-one portfolio --workspace-root "$root" --apply >/dev/null 2>&1
  remote=$(git -C "$root/portfolio" remote get-url origin)
  if test "$remote" = git@github.com:hanselhansel/physical-ai-portfolio.git; then pass 'SSH remote protocol is preserved'; else fail 'SSH remote protocol changed'; fi
  rm -rf "$root"
}

test_test_mode_rejected_for_canonical_workspace() {
  output=$(PORTFOLIO_TEST_MODE=1 PORTFOLIO_STATE_DIR=/tmp/not-canonical "$RUNNER" verify --workspace-root /Users/hansel/conductor/repos/physical-ai 2>&1 || true)
  if printf '%s' "$output" | grep -q 'TEST_MODE_FORBIDDEN'; then pass 'test mode is rejected for canonical workspace'; else fail 'test mode bypassed canonical safety'; fi
}

test_status_revalidates_healthy_verified_state() {
  root=$(mktemp -d)
  setup_portfolio_fixture "$root"
  PATH="$fake_bin:$PATH" PORTFOLIO_STATE_DIR="$root/state" PORTFOLIO_APP_GATE=passed PORTFOLIO_TEST_MODE=1 "$RUNNER" migrate-one portfolio --workspace-root "$root" --apply >/dev/null 2>&1
  output=$(PATH="$fake_bin:$PATH" PORTFOLIO_STATE_DIR="$root/state" PORTFOLIO_APP_GATE=passed PORTFOLIO_TEST_MODE=1 "$RUNNER" status portfolio --workspace-root "$root")
  if printf '%s' "$output" | grep -q 'state=VERIFIED'; then pass 'status revalidates healthy VERIFIED state'; else fail 'healthy VERIFIED state failed readback'; fi
  rm -rf "$root"
}

test_verify_rejects_broken_relative_link() {
  root=$(mktemp -d)
  make_docs_fixture "$root"
  printf '\n[Missing](docs/missing.md)\n' >> "$root/foundation/README.md"
  output=$("$RUNNER" verify --workspace-root "$root" 2>&1 || true)
  if printf '%s' "$output" | grep -q 'BROKEN_RELATIVE_LINK'; then pass 'verify rejects broken relative Markdown links'; else fail 'verify accepted a broken relative Markdown link'; fi
  rm -rf "$root"
}

test_app_gate_blocks_verified
test_ssh_remote_is_preserved
test_test_mode_rejected_for_canonical_workspace
test_status_revalidates_healthy_verified_state
test_verify_rejects_broken_relative_link
printf 'tests=%s failures=%s\n' "$((passed + failed))" "$failed"
test "$failed" -eq 0
