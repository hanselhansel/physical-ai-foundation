#!/bin/bash
# shellcheck disable=SC2034

load_repository_manifest() {
  repo_key=$1
  case "$repo_key" in
    portfolio)
      OLD_PATH_REL=foundation
      NEW_PATH_REL=portfolio
      OLD_REPO=physical-ai-foundation
      NEW_REPO=physical-ai-portfolio
      RENAME_REMOTE=yes
      NEW_DESCRIPTION="Control plane and public index for Hansel's Physical AI projects, contributions, evidence, and roadmap."
      ;;
    contributions)
      OLD_PATH_REL=lerobot-contrib
      NEW_PATH_REL=contributions
      OLD_REPO=pai-lerobot-contrib
      NEW_REPO=pai-contributions
      RENAME_REMOTE=yes
      NEW_DESCRIPTION='Open-source contributions across Open-RMF, ROS 2, Nav2, Isaac, Foxglove, and Physical AI deployment tooling.'
      ;;
    outreach)
      OLD_PATH_REL=community
      NEW_PATH_REL=outreach
      OLD_REPO=pai-community
      NEW_REPO=pai-outreach
      RENAME_REMOTE=yes
      NEW_DESCRIPTION='Physical AI publishing, outreach, networking, and external feedback.'
      ;;
    warehouse)
      OLD_PATH_REL=warehouse-deployment
      NEW_PATH_REL=projects/warehouse-deployment
      OLD_REPO=pai-warehouse-deployment
      NEW_REPO=pai-warehouse-deployment
      RENAME_REMOTE=no
      NEW_DESCRIPTION='Warehouse Physical AI portfolio project: AMR deployment research, WMS integration, playbooks, and reproducible Open-RMF experiments.'
      ;;
    *)
      printf '[FAIL] code=UNKNOWN_REPOSITORY repo=%s recovery=use_known_key\n' "$repo_key" >&2
      return 1
      ;;
  esac
}

repository_keys() {
  printf '%s\n' portfolio contributions outreach warehouse
}
