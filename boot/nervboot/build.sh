#!/usr/bin/env bash
# Build nerv-boot.efi with the star theme: upstream nervboot at a pinned
# commit plus star-theme.patch (adds `theme star|eva` to nerv.conf).
#   build.sh [workdir]   prints the path of the built nerv-boot.efi
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
work="${1:-${XDG_CACHE_HOME:-$HOME/.cache}/nervboot}"
upstream=https://codeberg.org/GuillotineMelody/nervboot.git
base=ba5bc2a

if [[ ! -d "$work/.git" ]]; then
    git clone -q "$upstream" "$work"
fi
git -C "$work" fetch -q origin
git -C "$work" checkout -q --detach "$base"
git -C "$work" -c user.name=build -c user.email=build@localhost am -q "$here/star-theme.patch"
(cd "$work" && cargo build --release >&2)
echo "$work/target/x86_64-unknown-uefi/release/nerv-boot.efi"
