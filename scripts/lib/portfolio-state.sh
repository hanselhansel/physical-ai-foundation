#!/bin/bash

emit_failure() {
  local code=$1 path=$2 observed=$3 recovery=$4
  printf '[FAIL] code=%s path=%s observed=%s recovery=%s\n' "$code" "$path" "$observed" "$recovery" >&2
}

portfolio_root_for_workspace() {
  local workspace_root=$1
  if test -f "$workspace_root/README.md" && test -f "$workspace_root/STATUS.md"; then
    printf '%s\n' "$workspace_root"
  elif test -d "$workspace_root/portfolio"; then
    printf '%s\n' "$workspace_root/portfolio"
  elif test -d "$workspace_root/foundation"; then
    printf '%s\n' "$workspace_root/foundation"
  else
    emit_failure PORTFOLIO_ROOT_MISSING "$workspace_root" absent restore_checkout
    return 1
  fi
}

check_required_file() {
  local file=$1
  if test ! -f "$file"; then
    emit_failure REQUIRED_FILE_MISSING "$file" absent restore_file
    return 1
  fi
}

check_required_heading() {
  local file=$1 heading=$2
  if ! grep -Fqx "$heading" "$file"; then
    emit_failure REQUIRED_HEADING_MISSING "$file" "$heading" add_heading
    return 1
  fi
}

check_line_limits() {
  local root=$1 list_file failed file lines
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

check_status_section() {
  local status_file=$1 section=$2 section_file=$3 failed=0 label count status_value
  for label in Title Category Objective 'Workflow status' 'Success criteria' 'Required validation' 'Evidence links' Result Limitations 'Next decision' Authority 'Observed at' 'Source commit' 'Fresh until' 'Recheck command'; do
    count=$(grep -F -c -- "- **$label:**" "$section_file" || true)
    if test "$count" -ne 1; then
      printf '[FAIL] code=STATUS_FIELD_MISSING path=%s section=%s field=%s expected=1 observed=%s recovery=complete_status_schema\n' "$status_file" "$section" "$label" "$count" >&2
      failed=1
    fi
  done
  status_value=$(sed -n 's/^- \*\*Workflow status:\*\* //p' "$section_file")
  case "$status_value" in Backlog|Ready|Active|Waiting|Complete|Parked|Dropped) ;; *) printf '[FAIL] code=STATUS_VALUE_INVALID path=%s section=%s field=Workflow_status observed=%s recovery=use_allowed_status\n' "$status_file" "$section" "$status_value" >&2; failed=1 ;; esac
  test "$failed" -eq 0
}

# shellcheck disable=SC2094
check_status_schema() {
  local status_file=$1 section='' section_file failed=0 line found=0
  section_file=$(mktemp)
  : > "$section_file"
  while IFS= read -r line || test -n "$line"; do
    case "$line" in
      '## '*)
        if test -n "$section"; then
          check_status_section "$status_file" "$section" "$section_file" || failed=1
        fi
        section=${line#'## '}
        found=1
        : > "$section_file"
        ;;
      *)
        test -n "$section" && printf '%s\n' "$line" >> "$section_file"
        ;;
    esac
  done < "$status_file"
  if test -n "$section"; then
    check_status_section "$status_file" "$section" "$section_file" || failed=1
  fi
  rm -f "$section_file"
  test "$found" -eq 1 || { emit_failure STATUS_ITEMS_MISSING "$status_file" zero add_status_item; return 1; }
  test "$failed" -eq 0
}

verify_portfolio() {
  local workspace_root=$1 root failed file heading
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
  if test -f "$root/STATUS.md"; then
    check_status_schema "$root/STATUS.md" || failed=1
  fi
  check_line_limits "$root" || failed=1
  check_relative_links "$root" || failed=1
  test "$failed" -eq 0
}

detect_repository_state() {
  local workspace_root=$1 repo_key=$2 old_path new_path old_exists new_exists identity repo_id remainder current_name journal journal_state origin
  load_repository_manifest "$repo_key" || return 1
  old_path="$workspace_root/$OLD_PATH_REL"
  new_path="$workspace_root/$NEW_PATH_REL"
  old_exists=no
  new_exists=no
  test -d "$old_path/.git" && old_exists=yes
  test -d "$new_path/.git" && new_exists=yes
  if test "$old_exists" = yes && { test -e "$new_path" || test -L "$new_path"; } && test "$new_exists" = no; then
    emit_failure DESTINATION_OCCUPIED "$new_path" present clear_destination
    return 1
  fi
  if test "$old_exists" = yes && test "$new_exists" = yes; then
    emit_failure BOTH_PATHS_EXIST "$workspace_root" ambiguous remove_unrelated_destination
    return 1
  fi
  if test "$old_exists" = no && test "$new_exists" = no; then
    emit_failure BOTH_PATHS_MISSING "$workspace_root" absent locate_checkout
    return 1
  fi
  identity=$(github_current_identity "$OLD_REPO" "$NEW_REPO") || { emit_failure REPOSITORY_NOT_FOUND "$OLD_REPO" absent inspect_github; return 1; }
  repo_id=${identity%%|*}
  # shellcheck disable=SC2153
  test "$repo_id" = "$EXPECTED_ID" || { emit_failure REPOSITORY_ID_MISMATCH "$repo_key" "$repo_id" stop_and_inspect; return 1; }
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
  local state_root
  state_root=$(state_directory)
  printf '%s/%s.journal\n' "$state_root" "$1"
}

journal_value() {
  local journal=$1 key=$2
  awk -F= -v wanted="$key" '$1 == wanted { sub(/^[^=]*=/, ""); print; exit }' "$journal"
}

write_journal() {
  local repo_key=$1 state=$2 repo_id=$3 expected_sha=$4 old_fetch=$5 old_push=$6 new_fetch new_push state_root journal temporary
  new_fetch=$(rewrite_repository_url "$old_fetch" "$OLD_REPO" "$NEW_REPO")
  new_push=$(rewrite_repository_url "$old_push" "$OLD_REPO" "$NEW_REPO")
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
    printf 'new_fetch=%s\n' "$new_fetch"
    printf 'new_push=%s\n' "$new_push"
    printf 'old_path_rel=%s\n' "$OLD_PATH_REL"
    printf 'new_path_rel=%s\n' "$NEW_PATH_REL"
    printf 'description=%s\n' "$NEW_DESCRIPTION"
    printf 'transition_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'app_gate=%s\n' "${PORTFOLIO_APP_GATE:-pending}"
  } > "$temporary"
  chmod 600 "$temporary"
  mv "$temporary" "$journal"
}

verify_migrated_repository() {
  local workspace_root=$1 repo_key=$2 journal expected_id expected_sha old_fetch old_push old_path new_path local_sha identity repo_id remainder current_name permission expected_fetch expected_push cached_sha live_sha description effective journal_state journal_app_gate
  load_repository_manifest "$repo_key" || return 1
  journal=$(journal_path "$repo_key")
  test -f "$journal" || { emit_failure VERIFICATION_FAILED "$repo_key" journal_missing restore_journal; return 1; }
  expected_id=$(journal_value "$journal" repo_id)
  expected_sha=$(journal_value "$journal" expected_sha)
  old_fetch=$(journal_value "$journal" old_fetch)
  old_push=$(journal_value "$journal" old_push)
  old_path="$workspace_root/$OLD_PATH_REL"
  new_path="$workspace_root/$NEW_PATH_REL"
  test ! -e "$old_path" || { emit_failure VERIFICATION_FAILED "$repo_key" old_path_present inspect_paths; return 1; }
  test -d "$new_path/.git" || { emit_failure VERIFICATION_FAILED "$repo_key" new_path_missing reverse_or_restore; return 1; }
  test "$(git -C "$new_path" symbolic-ref --quiet --short HEAD 2>/dev/null || true)" = main || { emit_failure VERIFICATION_FAILED "$repo_key" branch_not_main switch_main; return 1; }
  test -z "$(git -C "$new_path" status --porcelain)" || { emit_failure VERIFICATION_FAILED "$repo_key" dirty clean_worktree; return 1; }
  local_sha=$(git -C "$new_path" rev-parse HEAD)
  test "$local_sha" = "$expected_sha" || { emit_failure VERIFICATION_FAILED "$repo_key" head_mismatch inspect_history; return 1; }
  identity=$(github_current_identity "$OLD_REPO" "$NEW_REPO") || { emit_failure VERIFICATION_FAILED "$repo_key" github_missing inspect_github; return 1; }
  repo_id=${identity%%|*}
  remainder=${identity#*|}
  current_name=${remainder%%|*}
  permission=${identity##*|}
  test "$repo_id" = "$expected_id" && test "$repo_id" = "$EXPECTED_ID" || { emit_failure VERIFICATION_FAILED "$repo_key" id_mismatch stop_and_inspect; return 1; }
  test "$current_name" = "$NEW_REPO" || { emit_failure VERIFICATION_FAILED "$repo_key" canonical_name_mismatch inspect_github; return 1; }
  test "$permission" = ADMIN || { emit_failure VERIFICATION_FAILED "$repo_key" admin_missing request_admin; return 1; }
  expected_fetch=$(rewrite_repository_url "$old_fetch" "$OLD_REPO" "$NEW_REPO") || return 1
  expected_push=$(rewrite_repository_url "$old_push" "$OLD_REPO" "$NEW_REPO") || return 1
  test "$(git -C "$new_path" remote get-url origin)" = "$expected_fetch" || { emit_failure VERIFICATION_FAILED "$repo_key" fetch_url_mismatch repair_remote; return 1; }
  test "$(git -C "$new_path" remote get-url --push origin)" = "$expected_push" || { emit_failure VERIFICATION_FAILED "$repo_key" push_url_mismatch repair_remote; return 1; }
  if test "${PORTFOLIO_TEST_MODE:-0}" != 1; then
    cached_sha=$(git -C "$new_path" rev-parse refs/remotes/origin/main)
    live_sha=$(git -C "$new_path" ls-remote origin refs/heads/main | awk 'NR == 1 { print $1 }')
    test "$local_sha" = "$cached_sha" && test "$cached_sha" = "$live_sha" || { emit_failure VERIFICATION_FAILED "$repo_key" main_mismatch reconcile_main; return 1; }
    description=$(github_repo_description "$NEW_REPO") || return 1
    test "$description" = "$NEW_DESCRIPTION" || { emit_failure VERIFICATION_FAILED "$repo_key" description_mismatch repair_description; return 1; }
    if test "$RENAME_REMOTE" = yes; then
      effective=$(curl -sS -L -o /dev/null -w '%{url_effective}' "https://github.com/hanselhansel/$OLD_REPO")
      test "${effective%/}" = "https://github.com/hanselhansel/$NEW_REPO" || { emit_failure VERIFICATION_FAILED "$repo_key" redirect_mismatch inspect_redirect; return 1; }
    fi
  fi
  journal_state=$(journal_value "$journal" state)
  journal_app_gate=$(journal_value "$journal" app_gate)
  if test "$journal_state" = VERIFIED; then
    test "$journal_app_gate" = passed || { emit_failure VERIFICATION_FAILED "$repo_key" journal_app_gate_missing rerun_app_project_readback; return 1; }
  else
    test "${PORTFOLIO_APP_GATE:-pending}" = passed || { emit_failure VERIFICATION_FAILED "$repo_key" app_gate_pending run_app_project_readback; return 1; }
  fi
}

migrate_repository() {
  local workspace_root=$1 repo_key=$2 predecessor_journal predecessor_state lock old_path new_path current_state active_path identity repo_id remainder current_name permission journal expected_id expected_sha old_fetch old_push new_id new_fetch new_push
  load_repository_manifest "$repo_key" || return 1
  if test -n "$PREDECESSOR"; then
    predecessor_journal=$(journal_path "$PREDECESSOR")
    predecessor_state=$(journal_value "$predecessor_journal" state 2>/dev/null || true)
    if test "$predecessor_state" != VERIFIED; then
      printf '[FAIL] code=DEPENDENCY_NOT_VERIFIED repo=%s dependency=%s observed=%s recovery=migrate_predecessor_first\n' "$repo_key" "$PREDECESSOR" "${predecessor_state:-missing}" >&2
      return 1
    fi
    verify_migrated_repository "$workspace_root" "$PREDECESSOR" || { printf '[FAIL] code=DEPENDENCY_NOT_VERIFIED repo=%s dependency=%s observed=live_verification_failed recovery=repair_predecessor\n' "$repo_key" "$PREDECESSOR" >&2; return 1; }
    load_repository_manifest "$repo_key" || return 1
  fi
  lock=$(acquire_repository_lock "$repo_key") || return 1
  PORTFOLIO_ACTIVE_LOCK=$lock
  trap 'test -n "${PORTFOLIO_ACTIVE_LOCK:-}" && rm -rf "$PORTFOLIO_ACTIVE_LOCK"' EXIT HUP INT TERM
  old_path="$workspace_root/$OLD_PATH_REL"
  new_path="$workspace_root/$NEW_PATH_REL"
  current_state=$(detect_repository_state "$workspace_root" "$repo_key") || return 1
  if test "$current_state" = BASELINE && test "${PORTFOLIO_TEST_MODE:-0}" != 1; then
    preflight_repository "$workspace_root" "$repo_key" || return 1
  fi
  if test "$current_state" = VERIFIED; then
    verify_migrated_repository "$workspace_root" "$repo_key" || return 1
    printf 'MIGRATED repo=%s state=VERIFIED idempotent=yes\n' "$repo_key"
    rm -rf "$lock"
    PORTFOLIO_ACTIVE_LOCK=
    trap - EXIT HUP INT TERM
    return 0
  fi
  active_path=$old_path
  case "$current_state" in LOCAL_MOVED|METADATA_UPDATED) active_path=$new_path ;; esac
  if test -n "$(git -C "$active_path" status --porcelain)"; then
    emit_failure DIRTY_WORKTREE "$active_path" dirty commit_or_clean
    return 1
  fi
  test ! -L "$active_path" || { emit_failure SOURCE_SYMLINK "$active_path" symlink use_real_checkout; return 1; }
  identity=$(github_current_identity "$OLD_REPO" "$NEW_REPO") || { emit_failure REPOSITORY_NOT_FOUND "$OLD_REPO" absent inspect_github; return 1; }
  repo_id=${identity%%|*}
  test "$repo_id" = "$EXPECTED_ID" || { emit_failure REPOSITORY_ID_MISMATCH "$repo_key" "$repo_id" stop_and_inspect; return 1; }
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
    validate_origin_url "$old_fetch" "$OLD_REPO" || return 1
    validate_origin_url "$old_push" "$OLD_REPO" || return 1
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
  verify_migrated_repository "$workspace_root" "$repo_key" || return 1
  write_journal "$repo_key" VERIFIED "$repo_id" "$expected_sha" "$old_fetch" "$old_push"
  rm -rf "$lock"
  PORTFOLIO_ACTIVE_LOCK=
  trap - EXIT HUP INT TERM
  printf 'MIGRATED repo=%s state=VERIFIED reverse=mv_%s_to_%s\n' "$repo_key" "$NEW_PATH_REL" "$OLD_PATH_REL"
}

validate_test_mode_scope() {
  local workspace_root=$1
  test "${PORTFOLIO_TEST_MODE:-0}" = 1 || return 0
  case "$workspace_root" in /tmp/*|/private/tmp/*|/var/folders/*) ;; *) emit_failure TEST_MODE_FORBIDDEN "$workspace_root" canonical_workspace unset_test_mode; return 1 ;; esac
  test -n "${PORTFOLIO_STATE_DIR:-}" || { emit_failure TEST_STATE_DIR_REQUIRED "$workspace_root" missing set_temp_state_dir; return 1; }
  case "$PORTFOLIO_STATE_DIR" in "$workspace_root"/*) ;; *) emit_failure TEST_STATE_DIR_FORBIDDEN "$PORTFOLIO_STATE_DIR" outside_fixture use_fixture_state; return 1 ;; esac
}
