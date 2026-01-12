#!/usr/bin/env bash
set -euo pipefail

REPO_URL=${REPO_URL:-"https://github.com/Yaloalo/Config"}
BRANCH=${BRANCH:-"main"}
tmp=""

main() {
  local archive repo_dir
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/config-install.XXXXXX")
  archive="$tmp/config.tar.gz"
  trap 'if [ -n "$tmp" ]; then rm -rf "$tmp"; fi' EXIT

  echo "Downloading dotfiles from $REPO_URL (branch: $BRANCH) with wget..."
  wget -qO "$archive" "$REPO_URL/archive/refs/heads/$BRANCH.tar.gz"

  echo "Extracting archive..."
  tar -xzf "$archive" -C "$tmp"
  repo_dir=$(find "$tmp" -maxdepth 1 -type d -name "Config*" | head -n1)

  if [[ -z "$repo_dir" ]]; then
    echo "Could not locate extracted repository directory under $tmp" >&2
    exit 1
  fi

  echo "Running installer from $repo_dir/install/install.sh"
  bash "$repo_dir/install/install.sh" "$@"
}

main "$@"
