#!/bin/bash

acquire_repository_lock() {
  local repo_key=$1 state_root lock owner_pid
  state_root=$(state_directory)
  mkdir -p "$state_root"
  chmod 700 "$state_root"
  lock="$state_root/$repo_key.lock"
  if test -d "$lock"; then
    owner_pid=$(sed -n '1p' "$lock/pid" 2>/dev/null || true)
    case "$owner_pid" in
      ''|*[!0-9]*)
        emit_failure LOCK_CORRUPT "$lock" invalid_pid inspect_lock
        return 1
        ;;
      *)
        if kill -0 "$owner_pid" 2>/dev/null; then
          emit_failure LOCK_EXISTS "$lock" "live_pid_$owner_pid" wait_for_owner
          return 1
        fi
        printf '[FAIL] code=STALE_LOCK repo=%s owner_pid=%s recovery=remove_stale_lock_then_retry\n' "$repo_key" "$owner_pid" >&2
        return 1
        ;;
    esac
  fi
  if ! mkdir "$lock" 2>/dev/null; then
    emit_failure LOCK_EXISTS "$lock" raced inspect_lock
    return 1
  fi
  printf '%s\n' "$$" > "$lock/pid"
  printf '%s\n' "$lock"
}
