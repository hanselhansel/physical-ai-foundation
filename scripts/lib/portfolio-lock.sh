#!/bin/bash

acquire_repository_lock() {
  repo_key=$1
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
        rm -rf "$lock"
        printf '[RECOVER] code=STALE_LOCK_CLEARED repo=%s owner_pid=%s\n' "$repo_key" "$owner_pid" >&2
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
