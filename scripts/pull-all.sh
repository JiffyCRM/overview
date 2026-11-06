#!/usr/bin/env bash
#
# Pull latest changes in every service folder.
#
# Usage:
#   ./scripts/pull-all.sh            # operates on current directory
#   ./scripts/pull-all.sh /path/to/jiffy
#
set -euo pipefail

if [ -t 1 ]; then
    RED=$'\033[0;31m'
    GREEN=$'\033[0;32m'
    YELLOW=$'\033[1;33m'
    BLUE=$'\033[0;34m'
    BOLD=$'\033[1m'
    NC=$'\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; BOLD=''; NC=''
fi

if [ -n "${1:-}" ]; then
    TARGET="$1"
elif [ "$(basename "$(pwd)")" = "overview" ]; then
    TARGET=".."
else
    TARGET="./JiffyCRM"
fi
TARGET="${TARGET//\\//}"

if [ ! -d "$TARGET" ]; then
    printf '%bTarget folder does not exist: %s%b\n' "$RED" "$TARGET" "$NC"
    exit 1
fi

cd "$TARGET"
TARGET_ABS="$(pwd)"
printf '%bPulling all service folders in: %s%b\n\n' "$BOLD" "$TARGET_ABS" "$NC"

pulled=0
skipped=0
failed=0

shopt -s nullglob
for dir in */; do
    dir="${dir%/}"
    if [ -d "$dir/.git" ]; then
        printf '%b===> %s%b\n' "$BOLD" "$dir" "$NC"
        printf '  %bPulling...%b\n' "$BLUE" "$NC"
        if git -C "$dir" pull --ff-only; then
            pulled=$((pulled + 1))
            printf '  %bUpdated.%b\n' "$GREEN" "$NC"
        else
            printf '  %bFast-forward failed, attempting regular pull...%b\n' "$YELLOW" "$NC"
            if git -C "$dir" pull; then
                pulled=$((pulled + 1))
                printf '  %bUpdated.%b\n' "$GREEN" "$NC"
            else
                failed=$((failed + 1))
                printf '  %bPull failed.%b\n' "$RED" "$NC"
            fi
        fi
        echo
    else
        skipped=$((skipped + 1))
    fi
done
shopt -u nullglob

printf '%bSummary:%b pulled=%d skipped=%d failed=%d\n' \
    "$BOLD" "$NC" "$pulled" "$skipped" "$failed"

if [ "$failed" -gt 0 ]; then
    exit 1
fi
