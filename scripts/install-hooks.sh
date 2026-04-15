#!/usr/bin/env bash
set -euo pipefail
repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

hook="$repo_root/.git/hooks/pre-commit"
target="../../scripts/pre-commit.sh"

chmod +x scripts/validate-manifests.sh scripts/pre-commit.sh scripts/install-hooks.sh

if [[ -e "$hook" || -L "$hook" ]]; then
  rm "$hook"
fi
ln -s "$target" "$hook"
echo "Installed pre-commit hook -> scripts/pre-commit.sh"
