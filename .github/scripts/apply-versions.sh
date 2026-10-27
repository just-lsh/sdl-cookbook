#!/usr/bin/env bash
# Moves the submodules to the commits chosen by check-updates.sh and checks
# them out, including their nested submodules, at depth 1.
#
# Usage: apply-versions.sh [--commit]
#   --commit  Commit every update as "feat(<library>): update to <label>".
#
# Environment:
#   VERSIONS  The versions output of check-updates.sh (<path> <commit> <label>).

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

commit=false
if [ "${1:-}" = "--commit" ]; then
    commit=true
fi

while read -r path sha label; do
    [ -n "$path" ] || continue
    if [ "$(git ls-tree HEAD "$path" | awk '{ print $3 }')" = "$sha" ]; then
        continue
    fi
    git update-index --cacheinfo "160000,$sha,$path"
    if [ "$commit" = "true" ]; then
        git commit --quiet -m "feat($path): update to $label"
    fi
done <<<"$VERSIONS"

git submodule update --init --recursive --depth 1
