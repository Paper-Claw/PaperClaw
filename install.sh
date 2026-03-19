#!/usr/bin/env bash
# install.sh — Sync PaperClaw skills/agents into global Claude directory
# Usage: ./install.sh [--skip-pull]
#
# Behavior:
#   1. git pull --rebase (force-sync with remote) unless --skip-pull is passed
#   2. Create symlinks for every item under .claude/skills/* → ~/.claude/skills/
#   3. Create symlinks for every item under .claude/agents/* → ~/.claude/agents/
#   Existing symlinks are updated (removed and re-created).
#   Existing non-symlink files/dirs are NOT overwritten — a warning is printed instead.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_CLAUDE="${HOME}/.claude"
SRC_SKILLS="${REPO_DIR}/.claude/skills"
SRC_AGENTS="${REPO_DIR}/.claude/agents"
DST_SKILLS="${GLOBAL_CLAUDE}/skills"
DST_AGENTS="${GLOBAL_CLAUDE}/agents"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[install]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC}   $*"; }
err()  { echo -e "${RED}[error]${NC}  $*"; }

# ── 1. Git pull ──────────────────────────────────────────────────────────────
if [[ "${1:-}" != "--skip-pull" ]]; then
    log "Pulling latest changes from remote…"
    cd "${REPO_DIR}"
    git fetch --all --prune
    CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    git reset --hard "origin/${CURRENT_BRANCH}"
    log "Repository updated to $(git rev-parse --short HEAD) (${CURRENT_BRANCH})"
    cd - > /dev/null
fi

# ── 2. Link helper ───────────────────────────────────────────────────────────
link_item() {
    local src="$1"   # absolute path to source
    local dst="$2"   # absolute path to desired symlink

    # Skip if source does not exist
    [[ -e "${src}" ]] || { warn "Source not found, skipping: ${src}"; return; }

    if [[ -L "${dst}" ]]; then
        # Existing symlink — always update
        rm "${dst}"
        ln -s "${src}" "${dst}"
        log "Updated  ${dst} → ${src}"
    elif [[ -e "${dst}" ]]; then
        # Real file or directory — do not overwrite
        warn "Skipped  ${dst} (exists as a real file/dir — remove it manually to install)"
    else
        ln -s "${src}" "${dst}"
        log "Linked   ${dst} → ${src}"
    fi
}

# ── 3. Skills ────────────────────────────────────────────────────────────────
mkdir -p "${DST_SKILLS}"
if [[ -d "${SRC_SKILLS}" ]]; then
    shopt -s nullglob
    items=("${SRC_SKILLS}"/paperclaw*)
    shopt -u nullglob
    if [[ ${#items[@]} -eq 0 ]]; then
        warn "No paperclaw* skills found in ${SRC_SKILLS}"
    else
        for item in "${items[@]}"; do
            name="$(basename "${item}")"
            link_item "${item}" "${DST_SKILLS}/${name}"
        done
    fi
else
    warn "No skills directory found at ${SRC_SKILLS}"
fi

# ── 4. Agents ────────────────────────────────────────────────────────────────
mkdir -p "${DST_AGENTS}"
if [[ -d "${SRC_AGENTS}" ]]; then
    shopt -s nullglob
    items=("${SRC_AGENTS}"/paperclaw*)
    shopt -u nullglob
    if [[ ${#items[@]} -eq 0 ]]; then
        warn "No paperclaw* agents found in ${SRC_AGENTS}"
    else
        for item in "${items[@]}"; do
            name="$(basename "${item}")"
            link_item "${item}" "${DST_AGENTS}/${name}"
        done
    fi
else
    warn "No agents directory found at ${SRC_AGENTS}"
fi

log "Done. Run './uninstall.sh' to remove all symlinks created by this script."
