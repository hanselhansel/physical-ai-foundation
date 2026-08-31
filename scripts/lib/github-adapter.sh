#!/bin/bash

github_repo_json() {
  repo_name=$1
  gh repo view "hanselhansel/$repo_name" --json id,name,url,viewerPermission,defaultBranchRef,description 2>/dev/null
}

github_repo_id() {
  repo_name=$1
  json=$(github_repo_json "$repo_name") || return 1
  printf '%s' "$json" | jq -r '.id'
}

github_current_identity() {
  old_name=$1
  new_name=$2
  if json=$(github_repo_json "$new_name"); then
    printf '%s' "$json" | jq -r '[.id, .name, .viewerPermission] | join("|")'
    return 0
  fi
  json=$(github_repo_json "$old_name") || return 1
  printf '%s' "$json" | jq -r '[.id, .name, .viewerPermission] | join("|")'
}

github_rename_repository() {
  old_name=$1
  new_name=$2
  gh repo rename "$new_name" --repo "hanselhansel/$old_name" --yes
}

github_update_description() {
  repo_name=$1
  description=$2
  gh repo edit "hanselhansel/$repo_name" --description "$description"
}

github_repo_description() {
  repo_name=$1
  json=$(github_repo_json "$repo_name") || return 1
  printf '%s' "$json" | jq -r '.description // ""'
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
