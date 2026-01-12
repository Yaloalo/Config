#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

message="${1:-chore: sync configs}"
changes="$(git status --porcelain=v1 2>/dev/null)"

if [[ -z "$changes" ]]; then
  echo "No changes to commit."
  exit 0
fi

git add -A
git commit -m "$message"
git push
