#!/usr/bin/env bash
# uninstall.sh — Remove PaperClaw symlinks from global Claude directory
# Usage: ./uninstall.sh
#
# Removes only symlinks that point INTO this repository.
# Real files and symlinks pointing elsewhere are left untouched.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_CLAUDE="${HOME}/.claude"
DST_SKILLS="${GLOBAL_CLAUDE}/skills"
DST_AGENTS="${GLOBAL_CLAUDE}/agents"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[uninstall]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC}      $*"; }

removed=0

# ── Remove helper ─────────────────────────────────────────────────────────────
remove_if_ours() {
    local dst="$1"

    [[ -L "${dst}" ]] || return 0  # not a symlink — skip

    local target
    target="$(readlink "${dst}")"

    # Only remove if the symlink points into this repository
    if [[ "${target}" == "${REPO_DIR}"* ]]; then
        rm "${dst}"
        log "Removed  ${dst} → ${target}"
        (( removed++ )) || true
    else
        warn "Skipped  ${dst} → ${target} (not ours)"
    fi
}

# ── Skills ────────────────────────────────────────────────────────────────────
if [[ -d "${DST_SKILLS}" ]]; then
    shopt -s nullglob
    for item in "${DST_SKILLS}"/paperclaw*; do
        [[ -e "${item}" || -L "${item}" ]] && remove_if_ours "${item}"
    done
    shopt -u nullglob
fi

# ── Agents ────────────────────────────────────────────────────────────────────
if [[ -d "${DST_AGENTS}" ]]; then
    shopt -s nullglob
    for item in "${DST_AGENTS}"/paperclaw*; do
        [[ -e "${item}" || -L "${item}" ]] && remove_if_ours "${item}"
    done
    shopt -u nullglob
fi

log "Done. Removed ${removed} symlink(s)."
