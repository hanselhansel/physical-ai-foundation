#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck disable=SC1091
. "$SCRIPT_DIR/lib/portfolio-state.sh"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/lib/portfolio-manifest.sh"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/lib/github-adapter.sh"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/lib/portfolio-lock.sh"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/lib/portfolio-preflight.sh"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/lib/portfolio-links.sh"

usage() {
  printf 'usage: %s {preflight|status|migrate-one|verify} [options]\n' "$0" >&2
  exit 64
}

command_name=${1:-}
test -n "$command_name" || usage
shift

workspace_root=/Users/hansel/conductor/repos/physical-ai
repo_key=
apply=no
only_key=
if test "$command_name" = migrate-one || test "$command_name" = status; then
  repo_key=${1:-}
  test -n "$repo_key" || usage
  shift
fi
while test "$#" -gt 0; do
  case "$1" in
    --workspace-root)
      test "$#" -ge 2 || usage
      workspace_root=$2
      shift 2
      ;;
    --apply)
      apply=yes
      shift
      ;;
    --only)
      test "$#" -ge 2 || usage
      only_key=$2
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

validate_test_mode_scope "$workspace_root"

case "$command_name" in
  verify)
    verify_portfolio "$workspace_root"
    ;;
  migrate-one)
    state=$(detect_repository_state "$workspace_root" "$repo_key") || exit 65
    if test "$apply" = no; then
      printf 'DRY_RUN repo=%s state=%s\n' "$repo_key" "$state"
      exit 0
    fi
    if test "${PORTFOLIO_NEUTRAL:-0}" != 1; then
      neutral=$(mktemp -d)
      cp -R "$SCRIPT_DIR/." "$neutral"
      cd "$workspace_root"
      exec env PORTFOLIO_NEUTRAL=1 "$neutral/portfolio-migration.sh" migrate-one "$repo_key" --workspace-root "$workspace_root" --apply
    fi
    migrate_repository "$workspace_root" "$repo_key"
    ;;
  status)
    state=$(detect_repository_state "$workspace_root" "$repo_key") || exit 65
    if test "$state" = VERIFIED; then
      verify_migrated_repository "$workspace_root" "$repo_key" || exit 65
    fi
    printf 'STATUS repo=%s state=%s\n' "$repo_key" "$state"
    ;;
  preflight)
    preflight_workspace "$workspace_root" "$only_key"
    ;;
  *)
    usage
    ;;
esac
