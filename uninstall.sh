#!/usr/bin/env bash
# uninstall.sh — Remove PaperClaw symlinks from Claude Code global directory
# Usage: ./uninstall.sh [--dry-run]
#
# Removes only symlinks that point INTO this repository.
# Real files and symlinks pointing elsewhere are left untouched.

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_DIR

readonly GLOBAL_CLAUDE="${HOME}/.claude"

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── Flags ─────────────────────────────────────────────────────────────────────
DRY_RUN=false

# ── State ─────────────────────────────────────────────────────────────────────
declare -i REMOVED_COUNT=0

# ── Logging ───────────────────────────────────────────────────────────────────
log()  { echo -e "${GREEN}[uninstall]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC}      $*"; }
info() { echo -e "${BLUE}[info]${NC}      $*"; }

# ── Argument Parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --dry-run    Show what would be removed without making changes"
            echo "  -h, --help   Show this help message"
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1" >&2
            echo "Usage: $0 [--dry-run]"
            exit 1
            ;;
    esac
done

if [[ "$DRY_RUN" == true ]]; then
    info "Running in dry-run mode (no changes will be made)"
fi

# ── Remove Helper ─────────────────────────────────────────────────────────────
remove_if_ours() {
    local dst="$1"

    [[ -L "${dst}" ]] || return 0

    local target
    local resolved_target
    target="$(readlink "${dst}")"
    resolved_target="$(readlink -f "${dst}" || true)"

    if [[ "${resolved_target}" == "${REPO_DIR}"* ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            info "Would remove: ${dst} → ${target}"
        else
            rm "${dst}"
            log "Removed  $(basename "${dst}")"
        fi
        (( REMOVED_COUNT += 1 ))
    else
        info "Skipping $(basename "${dst}") (points elsewhere)"
    fi
}

# ── Process Directory ─────────────────────────────────────────────────────────
process_directory() {
    local dir="$1"

    if [[ ! -d "${dir}" ]]; then
        info "Directory not found: ${dir}"
        return
    fi

    local items=()
    while IFS= read -r -d '' item; do
        items+=("$item")
    done < <(find "${dir}" -maxdepth 1 -name 'paperclaw*' -print0 2>/dev/null | sort -z)

    for item in "${items[@]}"; do
        [[ -e "${item}" || -L "${item}" ]] && remove_if_ours "${item}"
    done
}

# ── Main Uninstallation ───────────────────────────────────────────────────────
log "Removing PaperClaw symlinks..."

process_directory "${GLOBAL_CLAUDE}/skills"
process_directory "${GLOBAL_CLAUDE}/agents"

if [[ $REMOVED_COUNT -eq 0 ]]; then
    info "No PaperClaw symlinks found to remove"
else
    log "Done! Removed ${REMOVED_COUNT} symlink(s)."
fi
