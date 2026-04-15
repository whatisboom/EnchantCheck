#!/usr/bin/env bash
# Validates that .toc and .xml manifests are in sync with the files on disk.
#   1. Every entry in every *.toc points at a real file
#   2. Every <Script file="..."/> and <Include file="..."/> in addon-owned .xml resolves
#   3. Every non-Libs .lua is referenced by some manifest (no orphans)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

errors=0
refs_file="$(mktemp)"
trap 'rm -f "$refs_file"' EXIT

norm() { printf '%s\n' "${1//\\//}"; }

# ---- 1. .toc references resolve ----
for toc in *.toc; do
  [[ -f "$toc" ]] || continue
  lineno=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    lineno=$((lineno+1))
    trimmed="${line#"${line%%[![:space:]]*}"}"
    [[ -z "$trimmed" ]] && continue
    [[ "$trimmed" == \#* ]] && continue
    path="$(norm "$trimmed")"
    printf '%s\n' "$path" >> "$refs_file"
    if [[ ! -f "$path" ]]; then
      echo "ERROR: $toc:$lineno references missing file: $path"
      errors=$((errors+1))
    fi
  done < "$toc"
done

# ---- 2. .xml references resolve (addon-owned only) ----
while IFS= read -r xml; do
  dir="$(dirname "$xml")"
  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    ref_norm="$(norm "$ref")"
    if [[ "$dir" == "." ]]; then
      resolved="$ref_norm"
    else
      resolved="$dir/$ref_norm"
    fi
    printf '%s\n' "$resolved" >> "$refs_file"
    if [[ ! -f "$resolved" ]]; then
      echo "ERROR: $xml references missing file: $ref (resolved: $resolved)"
      errors=$((errors+1))
    fi
  done < <(grep -oE '(Script|Include)[[:space:]]+file="[^"]+"' "$xml" | sed -E 's/.*file="([^"]+)".*/\1/')
done < <(find . -name "*.xml" -not -path "./Libs/*" -not -path "./.git/*" -not -path "./deprecated/*" | sed 's|^\./||')

# ---- 3. orphan .lua check (exclude Libs/, deprecated/, scripts/) ----
while IFS= read -r lua; do
  lua_norm="$(norm "$lua")"
  if ! grep -Fxq "$lua_norm" "$refs_file"; then
    echo "ERROR: orphan .lua not referenced by any manifest: $lua_norm"
    errors=$((errors+1))
  fi
done < <(find . -name "*.lua" \
  -not -path "./Libs/*" \
  -not -path "./.git/*" \
  -not -path "./deprecated/*" \
  -not -path "./scripts/*" | sed 's|^\./||')

if (( errors > 0 )); then
  echo ""
  echo "Manifest validation FAILED: $errors error(s)"
  exit 1
fi

echo "Manifest validation OK"
