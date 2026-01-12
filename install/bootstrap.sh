#!/usr/bin/env bash
set -euo pipefail

REPO_URL=${REPO_URL:-"https://github.com/Yaloalo/Config"}
BRANCH=${BRANCH:-"main"}
tmp=""

main() {
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/config-install.XXXXXX")
  trap 'tmp_clean="${tmp:-}"; if [ -n "$tmp_clean" ]; then rm -rf "$tmp_clean"; fi' EXIT

  if ! command -v git >/dev/null 2>&1 && command -v pacman >/dev/null 2>&1; then
    echo "git not found; attempting to install via pacman..."
    sudo pacman -Sy --needed git
  fi

  if ! command -v git >/dev/null 2>&1; then
    echo "git is required to clone $REPO_URL; please install git and rerun." >&2
    exit 1
  fi

  echo "Cloning dotfiles from $REPO_URL (branch: $BRANCH)..."
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$tmp/Config"

  echo "Running installer from $tmp/Config/install/install.sh"
  bash "$tmp/Config/install/install.sh" "$@"
}

main "$@"
