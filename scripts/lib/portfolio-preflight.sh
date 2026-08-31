#!/bin/bash

preflight_repository() {
  workspace_root=$1
  repo_key=$2
  load_repository_manifest "$repo_key" || return 1
  path="$workspace_root/$OLD_PATH_REL"
  new_path="$workspace_root/$NEW_PATH_REL"
  test ! -L "$path" || { emit_failure SOURCE_SYMLINK "$path" symlink use_real_checkout; return 1; }
  test -d "$path/.git" || { emit_failure SOURCE_MISSING "$path" absent restore_checkout; return 1; }
  if test "$OLD_PATH_REL" != "$NEW_PATH_REL" && { test -e "$new_path" || test -L "$new_path"; }; then
    emit_failure DESTINATION_OCCUPIED "$new_path" present clear_destination
    return 1
  fi
  worktree_count=$(git -C "$path" worktree list --porcelain | grep -c '^worktree ' || true)
  test "$worktree_count" -eq 1 || { printf '[FAIL] code=UNEXPECTED_WORKTREE repo=%s observed=%s recovery=remove_task_worktrees\n' "$repo_key" "$worktree_count" >&2; return 1; }
  branch=$(git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null || true)
  test "$branch" = main || { printf '[FAIL] code=BRANCH_NOT_MAIN repo=%s observed=%s recovery=switch_main\n' "$repo_key" "$branch" >&2; return 1; }
  if test -n "$(git -C "$path" status --porcelain)"; then
    printf '[FAIL] code=DIRTY_WORKTREE repo=%s observed=dirty recovery=commit_or_clean\n' "$repo_key" >&2
    return 1
  fi
  local_sha=$(git -C "$path" rev-parse HEAD)
  fetch_url=$(git -C "$path" remote get-url origin)
  push_url=$(git -C "$path" remote get-url --push origin)
  validate_origin_url "$fetch_url" "$OLD_REPO" || return 1
  validate_origin_url "$push_url" "$OLD_REPO" || return 1
  cached_sha=$(git -C "$path" rev-parse refs/remotes/origin/main 2>/dev/null || true)
  live_sha=$(git -C "$path" ls-remote origin refs/heads/main | awk 'NR == 1 { print $1 }')
  test -n "$cached_sha" || { printf '[FAIL] code=CACHED_MAIN_MISSING repo=%s recovery=fetch_origin_main\n' "$repo_key" >&2; return 1; }
  test "$local_sha" = "$cached_sha" || { printf '[FAIL] code=LOCAL_CACHED_MISMATCH repo=%s expected=%s observed=%s recovery=reconcile_main\n' "$repo_key" "$cached_sha" "$local_sha" >&2; return 1; }
  test "$cached_sha" = "$live_sha" || { printf '[FAIL] code=STALE_CACHED_MAIN repo=%s expected=%s observed=%s recovery=fetch_then_restart\n' "$repo_key" "$live_sha" "$cached_sha" >&2; return 1; }
  identity=$(github_current_identity "$OLD_REPO" "$NEW_REPO") || { printf '[FAIL] code=GITHUB_REPO_MISSING repo=%s recovery=inspect_github\n' "$repo_key" >&2; return 1; }
  repo_id=${identity%%|*}
  # shellcheck disable=SC2153
  test "$repo_id" = "$EXPECTED_ID" || { printf '[FAIL] code=REPOSITORY_ID_MISMATCH repo=%s expected=%s observed=%s recovery=stop_and_inspect\n' "$repo_key" "$EXPECTED_ID" "$repo_id" >&2; return 1; }
  permission=${identity##*|}
  test "$permission" = ADMIN || { printf '[FAIL] code=ADMIN_REQUIRED repo=%s observed=%s recovery=request_admin\n' "$repo_key" "$permission" >&2; return 1; }
  printf '[PASS] repo=%s branch=main sha=%s permission=ADMIN\n' "$repo_key" "$local_sha"
}

preflight_workspace() {
  workspace_root=$1
  only_key=$2
  for tool in git gh jq rg curl; do
    command -v "$tool" >/dev/null 2>&1 || { emit_failure TOOL_MISSING "$tool" absent install_tool; return 1; }
  done
  gh auth status >/dev/null 2>&1 || { emit_failure GH_AUTH auth failed login; return 1; }
  failed=0
  if test -n "$only_key"; then
    preflight_repository "$workspace_root" "$only_key" || failed=1
  else
    for key in $(repository_keys); do
      preflight_repository "$workspace_root" "$key" || failed=1
    done
  fi
  test "$failed" -eq 0
}
