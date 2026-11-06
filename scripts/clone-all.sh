#!/usr/bin/env bash
#
# Clone (or update) every JiffyCRM repository into a single folder.
#
# Usage:
#   ./scripts/clone-all.sh                 # creates ./jiffy
#   ./scripts/clone-all.sh /path/to/jiffy  # custom location
#
set -euo pipefail

# ---------- colors ----------
if [ -t 1 ]; then
    RED=$'\033[0;31m'
    GREEN=$'\033[0;32m'
    YELLOW=$'\033[1;33m'
    BLUE=$'\033[0;34m'
    CYAN=$'\033[0;36m'
    BOLD=$'\033[1m'
    NC=$'\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; BOLD=''; NC=''
fi

# ---------- repo list (name|clone-url) ----------
# Add new services here as they are created.
REPOS=(
    "overview|https://github.com/JiffyCRM/overview.git"
    "ui|https://github.com/JiffyCRM/ui.git"
)

# ---------- target folder ----------
if [ -n "${1:-}" ]; then
    # User gave an explicit path
    TARGET="$1"
else
    # Default: create a "jiffy" folder next to the current overview repo
    # (i.e. sibling of the overview directory)
    TARGET="$(cd .. && pwd)/jiffy"
fi
# Normalize Windows-style backslashes
TARGET="${TARGET//\\//}"
if [ ! -d "$TARGET" ]; then
    mkdir -p "$TARGET"
    printf '%bCreated target folder: %s%b\n' "$GREEN" "$TARGET" "$NC"
fi

# Resolve to an absolute path without relying on realpath (not available everywhere).
cd "$TARGET"
TARGET_ABS="$(pwd)"
printf '%bWorking in: %s%b\n\n' "$CYAN" "$TARGET_ABS" "$NC"

cloned=0
pulled=0
skipped=0
failed=0

for entry in "${REPOS[@]}"; do
    name="${entry%%|*}"
    url="${entry#*|}"

    printf '%b===> %s%b\n' "$BOLD" "$name" "$NC"

    if [ -d "$name/.git" ]; then
        printf '  %bPulling latest changes...%b\n' "$BLUE" "$NC"
        if git -C "$name" pull --ff-only; then
            pulled=$((pulled + 1))
            printf '  %bUpdated.%b\n' "$GREEN" "$NC"
        else
            printf '  %bFast-forward failed, attempting regular pull...%b\n' "$YELLOW" "$NC"
            if git -C "$name" pull; then
                pulled=$((pulled + 1))
                printf '  %bUpdated.%b\n' "$GREEN" "$NC"
            else
                failed=$((failed + 1))
                printf '  %bPull failed.%b\n' "$RED" "$NC"
            fi
        fi
    elif [ -d "$name" ]; then
        skipped=$((skipped + 1))
        printf '  %bFolder exists but is not a git repo - skipping.%b\n' "$YELLOW" "$NC"
    else
        printf '  %bCloning %s...%b\n' "$BLUE" "$url" "$NC"
        if git clone "$url" "$name"; then
            cloned=$((cloned + 1))
            printf '  %bCloned.%b\n' "$GREEN" "$NC"
        else
            failed=$((failed + 1))
            printf '  %bClone failed.%b\n' "$RED" "$NC"
        fi
    fi
    echo
done

printf '%bSummary:%b cloned=%d pulled=%d skipped=%d failed=%d\n' \
    "$BOLD" "$NC" "$cloned" "$pulled" "$skipped" "$failed"

if [ "$failed" -gt 0 ]; then
    exit 1
fi
