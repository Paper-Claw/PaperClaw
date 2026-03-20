#!/usr/bin/env bash
# install.sh — Sync PaperClaw skills/agents into Claude Code global directory
# Usage: ./install.sh [--skip-pull] [--dry-run]
#
# Behavior:
#   1. git pull --rebase unless --skip-pull is passed
#   2. Create symlinks for every item under .claude/skills/* → ~/.claude/skills/
#   3. Create symlinks for every item under .claude/agents/* → ~/.claude/agents/
#
#   Existing symlinks are updated (removed and re-created).
#   Existing non-symlink files/dirs are NOT overwritten — a warning is printed instead.

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_DIR

readonly GLOBAL_CLAUDE="${HOME}/.claude"
readonly SRC_SKILLS="${REPO_DIR}/.claude/skills"
readonly SRC_AGENTS="${REPO_DIR}/.claude/agents"

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── Flags ─────────────────────────────────────────────────────────────────────
SKIP_PULL=false
DRY_RUN=false

# ── Logging ───────────────────────────────────────────────────────────────────
log()  { echo -e "${GREEN}[install]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC}   $*"; }
err()  { echo -e "${RED}[error]${NC}  $*" >&2; }
info() { echo -e "${BLUE}[info]${NC}   $*"; }

# ── Argument Parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-pull)
            SKIP_PULL=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--skip-pull] [--dry-run]"
            echo ""
            echo "Options:"
            echo "  --skip-pull    Skip git pull (useful for local development)"
            echo "  --dry-run      Show what would be done without making changes"
            echo "  -h, --help     Show this help message"
            exit 0
            ;;
        *)
            err "Unknown option: $1"
            echo "Usage: $0 [--skip-pull] [--dry-run]"
            exit 1
            ;;
    esac
done

if [[ "$DRY_RUN" == true ]]; then
    info "Running in dry-run mode (no changes will be made)"
fi

# ── Git Update ────────────────────────────────────────────────────────────────
if [[ "$SKIP_PULL" == false ]]; then
    log "Pulling latest changes from remote..."
    cd "${REPO_DIR}"
    current_branch="$(git rev-parse --abbrev-ref HEAD)"

    if [[ "$DRY_RUN" == true ]]; then
        info "Would run: git pull --rebase --autostash origin ${current_branch}"
    else
        if git remote get-url origin &>/dev/null; then
            git pull --rebase --autostash origin "${current_branch}" || {
                warn "git pull failed (no upstream tracking ref?). Use --skip-pull to skip."
                exit 1
            }
            log "Repository updated to $(git rev-parse --short HEAD) (${current_branch})"
        else
            warn "No remote 'origin' found — skipping pull"
        fi
    fi
    cd - > /dev/null
fi

# ── Link Helper ───────────────────────────────────────────────────────────────
link_item() {
    local src="$1"
    local dst="$2"
    local name
    name="$(basename "${src}")"

    if [[ ! -e "${src}" ]]; then
        warn "Source not found, skipping: ${src}"
        return
    fi

    if [[ -L "${dst}" ]]; then
        local current_target
        current_target="$(readlink "${dst}")"
        if [[ "$DRY_RUN" == true ]]; then
            info "Would update: ${dst} → ${src} (currently → ${current_target})"
        else
            rm "${dst}"
            ln -s "${src}" "${dst}"
            log "Updated  ${name}"
        fi
    elif [[ -e "${dst}" ]]; then
        warn "Skipped  ${name} (exists as real file/dir — remove manually to install)"
    else
        if [[ "$DRY_RUN" == true ]]; then
            info "Would create: ${dst} → ${src}"
        else
            ln -s "${src}" "${dst}"
            log "Linked   ${name}"
        fi
    fi
}

# ── Process Directory ─────────────────────────────────────────────────────────
process_directory() {
    local src_dir="$1"
    local dst_dir="$2"
    local label="$3"

    if [[ ! -d "${src_dir}" ]]; then
        warn "Source directory not found: ${src_dir}"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "Would ensure directory exists: ${dst_dir}"
    else
        mkdir -p "${dst_dir}"
    fi

    local items=()
    while IFS= read -r -d '' item; do
        items+=("$item")
    done < <(find "${src_dir}" -maxdepth 1 -name 'paperclaw*' -print0 2>/dev/null | sort -z)

    if [[ ${#items[@]} -eq 0 ]]; then
        warn "No paperclaw* ${label} found in ${src_dir}"
        return
    fi

    log "Installing ${label}..."
    for item in "${items[@]}"; do
        link_item "${item}" "${dst_dir}/$(basename "${item}")"
    done
}

# ── Main Installation ─────────────────────────────────────────────────────────
log "Installing PaperClaw to ${GLOBAL_CLAUDE}..."

process_directory "${SRC_SKILLS}" "${GLOBAL_CLAUDE}/skills" "skills"
process_directory "${SRC_AGENTS}" "${GLOBAL_CLAUDE}/agents" "agents"

log "Done! Run './uninstall.sh' to remove all symlinks."
