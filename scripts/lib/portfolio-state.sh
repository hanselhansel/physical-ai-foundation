#!/bin/bash

emit_failure() {
  code=$1
  path=$2
  observed=$3
  recovery=$4
  printf '[FAIL] code=%s path=%s observed=%s recovery=%s\n' "$code" "$path" "$observed" "$recovery" >&2
}

portfolio_root_for_workspace() {
  workspace_root=$1
  if test -d "$workspace_root/portfolio"; then
    printf '%s\n' "$workspace_root/portfolio"
  elif test -d "$workspace_root/foundation"; then
    printf '%s\n' "$workspace_root/foundation"
  else
    emit_failure PORTFOLIO_ROOT_MISSING "$workspace_root" absent restore_checkout
    return 1
  fi
}

check_required_file() {
  file=$1
  if test ! -f "$file"; then
    emit_failure REQUIRED_FILE_MISSING "$file" absent restore_file
    return 1
  fi
}

check_required_heading() {
  file=$1
  heading=$2
  if ! grep -Fqx "$heading" "$file"; then
    emit_failure REQUIRED_HEADING_MISSING "$file" "$heading" add_heading
    return 1
  fi
}

check_line_limits() {
  root=$1
  list_file=$(mktemp)
  find "$root" -path '*/.git' -prune -o -type f \( -name '*.md' -o -name '*.sh' \) -print > "$list_file"
  failed=0
  while IFS= read -r file; do
    lines=$(wc -l < "$file" | tr -d ' ')
    if test "$lines" -ge 400; then
      emit_failure FILE_TOO_LONG "$file" "$lines" split_file
      failed=1
    fi
  done < "$list_file"
  rm -f "$list_file"
  test "$failed" -eq 0
}

verify_portfolio() {
  workspace_root=$1
  root=$(portfolio_root_for_workspace "$workspace_root") || return 1
  failed=0
  for file in README.md STATUS.md ROADMAP.md docs/templates/portfolio-item.md docs/templates/runtime-experiment.md; do
    check_required_file "$root/$file" || failed=1
  done
  if test -f "$root/README.md"; then
    for heading in '## Portfolio' '## Projects' '## Contributions' '## Outreach' '## Forks'; do
      check_required_heading "$root/README.md" "$heading" || failed=1
    done
  fi
  check_line_limits "$root" || failed=1
  test "$failed" -eq 0
}

preflight_repository() {
  workspace_root=$1
  repo_key=$2
  load_repository_manifest "$repo_key" || return 1
  path="$workspace_root/$OLD_PATH_REL"
  test -d "$path/.git" || { emit_failure SOURCE_MISSING "$path" absent restore_checkout; return 1; }
  branch=$(git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null || true)
  test "$branch" = main || { printf '[FAIL] code=BRANCH_NOT_MAIN repo=%s observed=%s recovery=switch_main\n' "$repo_key" "$branch" >&2; return 1; }
  if test -n "$(git -C "$path" status --porcelain)"; then
    printf '[FAIL] code=DIRTY_WORKTREE repo=%s observed=dirty recovery=commit_or_clean\n' "$repo_key" >&2
    return 1
  fi
  local_sha=$(git -C "$path" rev-parse HEAD)
  cached_sha=$(git -C "$path" rev-parse refs/remotes/origin/main 2>/dev/null || true)
  live_sha=$(git -C "$path" ls-remote origin refs/heads/main | awk 'NR == 1 { print $1 }')
  test -n "$cached_sha" || { printf '[FAIL] code=CACHED_MAIN_MISSING repo=%s recovery=fetch_origin_main\n' "$repo_key" >&2; return 1; }
  test "$local_sha" = "$cached_sha" || { printf '[FAIL] code=LOCAL_CACHED_MISMATCH repo=%s expected=%s observed=%s recovery=reconcile_main\n' "$repo_key" "$cached_sha" "$local_sha" >&2; return 1; }
  test "$cached_sha" = "$live_sha" || { printf '[FAIL] code=STALE_CACHED_MAIN repo=%s expected=%s observed=%s recovery=fetch_then_restart\n' "$repo_key" "$live_sha" "$cached_sha" >&2; return 1; }
  identity=$(github_current_identity "$OLD_REPO" "$NEW_REPO") || { printf '[FAIL] code=GITHUB_REPO_MISSING repo=%s recovery=inspect_github\n' "$repo_key" >&2; return 1; }
  permission=${identity##*|}
  test "$permission" = ADMIN || { printf '[FAIL] code=ADMIN_REQUIRED repo=%s observed=%s recovery=request_admin\n' "$repo_key" "$permission" >&2; return 1; }
  printf '[PASS] repo=%s branch=main sha=%s permission=ADMIN\n' "$repo_key" "$local_sha"
}

preflight_workspace() {
  workspace_root=$1
  only_key=$2
  for tool in git gh jq rg; do
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

detect_repository_state() {
  workspace_root=$1
  repo_key=$2
  load_repository_manifest "$repo_key" || return 1
  old_path="$workspace_root/$OLD_PATH_REL"
  new_path="$workspace_root/$NEW_PATH_REL"
  old_exists=no
  new_exists=no
  test -d "$old_path/.git" && old_exists=yes
  test -d "$new_path/.git" && new_exists=yes
  if test "$old_exists" = yes && test "$new_exists" = yes; then
    emit_failure BOTH_PATHS_EXIST "$workspace_root" ambiguous remove_unrelated_destination
    return 1
  fi
  if test "$old_exists" = no && test "$new_exists" = no; then
    emit_failure BOTH_PATHS_MISSING "$workspace_root" absent locate_checkout
    return 1
  fi
  identity=$(github_current_identity "$OLD_REPO" "$NEW_REPO") || { emit_failure REPOSITORY_NOT_FOUND "$OLD_REPO" absent inspect_github; return 1; }
  remainder=${identity#*|}
  current_name=${remainder%%|*}
  if test "$new_exists" = yes; then
    journal=$(journal_path "$repo_key")
    if test -f "$journal"; then
      journal_state=$(journal_value "$journal" state)
      case "$journal_state" in VERIFIED|METADATA_UPDATED|LOCAL_MOVED) printf '%s\n' "$journal_state"; return 0 ;; esac
    fi
    printf 'LOCAL_MOVED\n'
    return 0
  fi
  origin=$(git -C "$old_path" remote get-url origin)
  if test "$current_name" = "$OLD_REPO"; then
    printf 'BASELINE\n'
  elif test "$current_name" = "$NEW_REPO"; then
    case "$origin" in
      *"$NEW_REPO"*) printf 'ORIGIN_UPDATED\n' ;;
      *) printf 'REMOTE_RENAMED\n' ;;
    esac
  else
    emit_failure UNEXPECTED_REPOSITORY_NAME "$repo_key" "$current_name" inspect_github
    return 1
  fi
}

state_directory() {
  printf '%s\n' "${PORTFOLIO_STATE_DIR:-/Users/hansel/.local/state/physical-ai-portfolio-migration}"
}

journal_path() {
  state_root=$(state_directory)
  printf '%s/%s.journal\n' "$state_root" "$1"
}

journal_value() {
  journal=$1
  key=$2
  awk -F= -v wanted="$key" '$1 == wanted { sub(/^[^=]*=/, ""); print; exit }' "$journal"
}

write_journal() {
  repo_key=$1
  state=$2
  repo_id=$3
  expected_sha=$4
  old_fetch=$5
  old_push=$6
  state_root=$(state_directory)
  mkdir -p "$state_root"
  chmod 700 "$state_root"
  journal=$(journal_path "$repo_key")
  temporary="$journal.tmp.$$"
  {
    printf 'repo=%s\n' "$repo_key"
    printf 'state=%s\n' "$state"
    printf 'repo_id=%s\n' "$repo_id"
    printf 'expected_sha=%s\n' "$expected_sha"
    printf 'old_fetch=%s\n' "$old_fetch"
    printf 'old_push=%s\n' "$old_push"
  } > "$temporary"
  chmod 600 "$temporary"
  mv "$temporary" "$journal"
}

rewrite_repository_url() {
  url=$1
  old_name=$2
  new_name=$3
  case "$url" in
    *"/$old_name.git") printf '%s%s.git\n' "${url%/"$old_name".git}/" "$new_name" ;;
    *"/$old_name") printf '%s%s\n' "${url%/"$old_name"}/" "$new_name" ;;
    *":$old_name.git") printf '%s%s.git\n' "${url%:"$old_name".git}:" "$new_name" ;;
    *) emit_failure UNEXPECTED_REMOTE_URL "$url" unexpected inspect_remote; return 1 ;;
  esac
}

acquire_repository_lock() {
  repo_key=$1
  state_root=$(state_directory)
  mkdir -p "$state_root"
  chmod 700 "$state_root"
  lock="$state_root/$repo_key.lock"
  if ! mkdir "$lock" 2>/dev/null; then
    emit_failure LOCK_EXISTS "$lock" present inspect_lock
    return 1
  fi
  printf '%s\n' "$$" > "$lock/pid"
  printf '%s\n' "$lock"
}

migrate_repository() {
  workspace_root=$1
  repo_key=$2
  load_repository_manifest "$repo_key" || return 1
  lock=$(acquire_repository_lock "$repo_key") || return 1
  trap 'rm -rf "$lock"' EXIT HUP INT TERM
  old_path="$workspace_root/$OLD_PATH_REL"
  new_path="$workspace_root/$NEW_PATH_REL"
  current_state=$(detect_repository_state "$workspace_root" "$repo_key") || return 1
  if test "$current_state" = VERIFIED; then
    printf 'MIGRATED repo=%s state=VERIFIED idempotent=yes\n' "$repo_key"
    rm -rf "$lock"
    trap - EXIT HUP INT TERM
    return 0
  fi
  active_path=$old_path
  case "$current_state" in LOCAL_MOVED|METADATA_UPDATED) active_path=$new_path ;; esac
  if test -n "$(git -C "$active_path" status --porcelain)"; then
    emit_failure DIRTY_WORKTREE "$active_path" dirty commit_or_clean
    return 1
  fi
  identity=$(github_current_identity "$OLD_REPO" "$NEW_REPO") || { emit_failure REPOSITORY_NOT_FOUND "$OLD_REPO" absent inspect_github; return 1; }
  repo_id=${identity%%|*}
  remainder=${identity#*|}
  current_name=${remainder%%|*}
  permission=${identity##*|}
  test "$permission" = ADMIN || { emit_failure ADMIN_REQUIRED "$current_name" "$permission" request_admin; return 1; }
  journal=$(journal_path "$repo_key")
  if test -f "$journal"; then
    expected_id=$(journal_value "$journal" repo_id)
    test "$expected_id" = "$repo_id" || { emit_failure REPOSITORY_ID_MISMATCH "$NEW_REPO" "$repo_id" stop_and_inspect; return 1; }
    expected_sha=$(journal_value "$journal" expected_sha)
    old_fetch=$(journal_value "$journal" old_fetch)
    old_push=$(journal_value "$journal" old_push)
  else
    expected_sha=$(git -C "$active_path" rev-parse HEAD)
    old_fetch=$(git -C "$active_path" remote get-url origin)
    old_push=$(git -C "$active_path" remote get-url --push origin)
    write_journal "$repo_key" "$current_state" "$repo_id" "$expected_sha" "$old_fetch" "$old_push"
  fi
  if test "$current_state" = BASELINE && test "$RENAME_REMOTE" = yes; then
    github_rename_repository "$OLD_REPO" "$NEW_REPO"
    identity=$(github_current_identity "$OLD_REPO" "$NEW_REPO") || return 1
    new_id=${identity%%|*}
    test "$new_id" = "$repo_id" || { emit_failure REPOSITORY_ID_MISMATCH "$NEW_REPO" "$new_id" stop_and_inspect; return 1; }
    current_state=REMOTE_RENAMED
    write_journal "$repo_key" "$current_state" "$repo_id" "$expected_sha" "$old_fetch" "$old_push"
  elif test "$current_state" = BASELINE; then
    current_state=REMOTE_RENAMED
    write_journal "$repo_key" "$current_state" "$repo_id" "$expected_sha" "$old_fetch" "$old_push"
  fi
  if test "$current_state" = REMOTE_RENAMED; then
    new_fetch=$(rewrite_repository_url "$old_fetch" "$OLD_REPO" "$NEW_REPO") || return 1
    new_push=$(rewrite_repository_url "$old_push" "$OLD_REPO" "$NEW_REPO") || return 1
    git -C "$old_path" remote set-url origin "$new_fetch"
    git -C "$old_path" remote set-url --push origin "$new_push"
    current_state=ORIGIN_UPDATED
    write_journal "$repo_key" "$current_state" "$repo_id" "$expected_sha" "$old_fetch" "$old_push"
  fi
  if test "$current_state" = ORIGIN_UPDATED; then
    test ! -e "$new_path" || { emit_failure DESTINATION_OCCUPIED "$new_path" present choose_empty_destination; return 1; }
    mkdir -p "$(dirname "$new_path")"
    mv "$old_path" "$new_path"
    test "$(git -C "$new_path" rev-parse HEAD)" = "$expected_sha" || { emit_failure HEAD_CHANGED "$new_path" changed reverse_move; return 1; }
    current_state=LOCAL_MOVED
    write_journal "$repo_key" "$current_state" "$repo_id" "$expected_sha" "$old_fetch" "$old_push"
  fi
  if test "$current_state" = LOCAL_MOVED; then
    github_update_description "$NEW_REPO" "$NEW_DESCRIPTION"
    current_state=METADATA_UPDATED
    write_journal "$repo_key" "$current_state" "$repo_id" "$expected_sha" "$old_fetch" "$old_push"
  fi
  if test "${PORTFOLIO_APP_GATE:-pending}" != passed; then
    emit_failure APP_GATE_PENDING "$repo_key" pending run_app_project_readback
    return 1
  fi
  write_journal "$repo_key" VERIFIED "$repo_id" "$expected_sha" "$old_fetch" "$old_push"
  rm -rf "$lock"
  trap - EXIT HUP INT TERM
  printf 'MIGRATED repo=%s state=VERIFIED reverse=mv_%s_to_%s\n' "$repo_key" "$NEW_PATH_REL" "$OLD_PATH_REL"
}
