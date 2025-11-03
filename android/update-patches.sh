#!/bin/bash

set -xe

[ $# -eq 1 ]
BASE=$1

SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
ROOT_DIR="${SCRIPT_DIR}/.."
REV_PARSED_BASE="$(git rev-parse "${BASE}")"
PATCHES_DIR="${SCRIPT_DIR}/patches"

rm -rf "${PATCHES_DIR}"

i=0
while [[ "$(git -C "${ROOT_DIR}" rev-parse HEAD~"${i}")" != "${REV_PARSED_BASE}" ]]; do
    patch="$(git -C "${ROOT_DIR}" log --format=%s -n 1 HEAD~"${i}")"
    mkdir -p "${PATCHES_DIR}/${patch}"
    git -C "${ROOT_DIR}" diff HEAD~"${i}" ^HEAD~"$((i + 1))" src \
        > "${PATCHES_DIR}/${patch}/full.patch"
    for source in $(git -C "${ROOT_DIR}" diff HEAD~"${i}" ^HEAD~"$((i + 1))" --stat --format= src | head -n-1 | sed 's/^ \([^ ]*\) *|.*/\1/')
    do
        mkdir -p "${PATCHES_DIR}/${patch}/${source}"
        git -C "${ROOT_DIR}" diff HEAD~"${i}" ^HEAD~"$((i + 1))" -- "${source}" \
            > "${PATCHES_DIR}/${patch}/${source}/patch"
    done
    i=$((i + 1))
done
