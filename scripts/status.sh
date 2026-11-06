#!/usr/bin/env bash
set -euo pipefail

if [ -t 1 ]; then
    BOLD=$'\033[1m'; GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
else
    BOLD=''; GREEN=''; RED=''; YELLOW=''; NC=''
fi

TARGET="${1:-.}"
TARGET="${TARGET//\\//}"
cd "$TARGET"

shopt -s nullglob
for dir in */; do
    dir="${dir%/}"
    if [ -d "$dir/.git" ]; then
        printf '%b===> %s%b\n' "$BOLD" "$dir" "$NC"
        (cd "$dir" && git status --short --branch)
        echo
    fi
done
shopt -u nullglob
