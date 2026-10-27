#!/usr/bin/env bash
# Compares every submodule pin with upstream and decides whether to release.
#
# Libraries with releases follow their newest release-3.* tag; SDL_shadercross
# has none and follows main. Only a new tag triggers a release (or FORCE=true);
# SDL_shadercross is then updated along with it.
#
# Environment:
#   FORCE           "true" to release even without a new tag.
#   GITHUB_OUTPUT   Set by GitHub Actions; without it the outputs go to stdout.
#
# Outputs:
#   release   true or false
#   version   Release tag: dev-YYYY-MM, then dev-YYYY-MM.1, .2, ... within a month
#   versions  One line per submodule: <path> <commit> <label>
#   changes   One line per updated submodule: <path> <old label> <new label>

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

tagged=(SDL SDL_image SDL_mixer SDL_ttf SDL_net)
untagged=(SDL_shadercross)

# Prints "<commit> <tag>" for the remote tags matching a pattern. Annotated
# tags are peeled to the commit they point to.
remote_tags() {
    git ls-remote --tags "$1" "$2" | awk '
        { ref = $2; sub("^refs/tags/", "", ref) }
        sub(/\^\{\}$/, "", ref) { peeled[ref] = $1; next }
        { direct[ref] = $1 }
        END { for (r in direct) print (r in peeled ? peeled[r] : direct[r]), r }'
}

pinned_commit() {
    git ls-tree HEAD "$1" | awk '{ print $3 }'
}

versions=""
changes=""
new_tag=false

for lib in "${tagged[@]}"; do
    url=$(git config -f .gitmodules "submodule.$lib.url")
    pinned=$(pinned_commit "$lib")
    tags=$(remote_tags "$url" 'refs/tags/release-3.*')
    if [ -z "$tags" ]; then
        echo "error: no release-3.* tags found for $lib" >&2
        exit 1
    fi
    latest=$(awk '{ print $2 }' <<<"$tags" | sort -V | tail -n 1)
    latest_commit=$(awk -v t="$latest" '$2 == t { print $1 }' <<<"$tags")
    current=$(awk -v c="$pinned" '$1 == c { print $2 }' <<<"$tags" | sort -V | tail -n 1)
    current=${current:-${pinned:0:7}}

    versions+="$lib $latest_commit $latest"$'\n'
    if [ "$latest_commit" != "$pinned" ]; then
        changes+="$lib $current $latest"$'\n'
        new_tag=true
    fi
done

release=$new_tag
if [ "${FORCE:-false}" = "true" ]; then
    release=true
fi

for lib in "${untagged[@]}"; do
    url=$(git config -f .gitmodules "submodule.$lib.url")
    pinned=$(pinned_commit "$lib")
    head=$(git ls-remote "$url" refs/heads/main | awk '{ print $1 }')
    if [ "$release" = "true" ] && [ "$head" != "$pinned" ]; then
        versions+="$lib $head main@${head:0:7}"$'\n'
        changes+="$lib main@${pinned:0:7} main@${head:0:7}"$'\n'
    else
        versions+="$lib $pinned main@${pinned:0:7}"$'\n'
    fi
done

month=$(date -u +%Y-%m)
last=$(git ls-remote --tags origin "refs/tags/dev-$month*" |
    sed -nE "s#.*refs/tags/dev-$month(\.([0-9]+))?\$#\2#p" |
    awk '{ n = ($0 == "" ? 0 : $0) + 1; if (n > max) max = n } END { print max + 0 }')
if [ "$last" -eq 0 ]; then
    version="dev-$month"
else
    version="dev-$month.$last"
fi

out=${GITHUB_OUTPUT:-/dev/stdout}
{
    echo "release=$release"
    echo "version=$version"
    printf 'versions<<EOF\n%sEOF\n' "$versions"
    printf 'changes<<EOF\n%sEOF\n' "$changes"
} >>"$out"
