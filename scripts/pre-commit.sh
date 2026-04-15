#!/usr/bin/env bash
set -euo pipefail
repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if git diff --cached --name-only --diff-filter=ACMRD | grep -qE '\.(toc|xml|lua)$'; then
  bash scripts/validate-manifests.sh
fi
