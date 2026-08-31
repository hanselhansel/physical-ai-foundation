#!/bin/bash

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
