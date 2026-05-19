#!/bin/bash
# =============================================================================
# build_distribution.sh — Assemble a Hermes profile distribution from source
# =============================================================================
#
# Combines the layered source (core/ + general/ + modules/<vertical>/) into a
# single self-contained Hermes profile distribution directory, ready for:
#
#     hermes profile install <output-dir>
#
# Source layout:                Distribution layout (output):
#
# ceo-asistani/                 distributions/<name>/
# ├── core/skills/*.md          ├── distribution.yaml   (from modules/<v>/)
# ├── general/skills/*.md       ├── SOUL.md             (from modules/<v>/)
# └── modules/<v>/              ├── config.yaml         (from modules/<v>/)
#     ├── distribution.yaml     ├── mcp.json            (from modules/<v>/)
#     ├── SOUL.md               ├── cron/               (from modules/<v>/)
#     ├── config.yaml           ├── README.md
#     ├── mcp.json              └── skills/
#     ├── cron/                     ├── <name>/SKILL.md  ← from core/skills/*.md
#     └── skills/*.md               ├── <name>/SKILL.md  ← from general/skills/*.md
#                                   └── <name>/SKILL.md  ← from modules/<v>/skills/*.md
#
# Each source .md becomes <name>/SKILL.md inside a directory (Hermes convention).
#
# Usage:
#   bash deploy/build_distribution.sh <vertical> [--output <dir>] [--force]
#
# Examples:
#   bash deploy/build_distribution.sh hotel
#       → distributions/otel-asistani/
#   bash deploy/build_distribution.sh acente --output /tmp/build-acente
#
# Architecture reference: docs/ARCHITECTURE.md §3, §11
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
    cat <<EOF
Usage: $0 <vertical> [--output <dir>] [--force]

Arguments:
  <vertical>        Module name in modules/ (hotel | acente | ...)

Options:
  --output <dir>    Output directory (default: distributions/<dist-name>)
  --force           Overwrite existing output directory
  --quiet           Suppress per-file output

Examples:
  $0 hotel
  $0 acente --output /tmp/acente-build
EOF
    exit 1
}

[[ $# -lt 1 ]] && usage

VERTICAL="$1"
shift

OUTPUT_DIR=""
FORCE=false
QUIET=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output) OUTPUT_DIR="$2"; shift 2 ;;
        --force)  FORCE=true; shift ;;
        --quiet)  QUIET=true; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown arg: $1"; usage ;;
    esac
done

log() { $QUIET || echo "$@"; }

# -----------------------------------------------------------------------------
# Validate vertical
# -----------------------------------------------------------------------------

MODULE_DIR="$REPO_ROOT/modules/$VERTICAL"
[[ ! -d "$MODULE_DIR" ]] && { echo "ERROR: modules/$VERTICAL/ not found"; exit 2; }

DIST_MANIFEST="$MODULE_DIR/distribution.yaml"
[[ ! -f "$DIST_MANIFEST" ]] && { echo "ERROR: $DIST_MANIFEST not found"; exit 2; }

# Read distribution name from manifest (simple yaml grep — no parser dep)
DIST_NAME=$(grep '^name:' "$DIST_MANIFEST" | awk '{print $2}' | tr -d '"' | head -1)
[[ -z "$DIST_NAME" ]] && { echo "ERROR: 'name:' not found in $DIST_MANIFEST"; exit 2; }

# Resolve output dir
[[ -z "$OUTPUT_DIR" ]] && OUTPUT_DIR="$REPO_ROOT/distributions/$DIST_NAME"

# -----------------------------------------------------------------------------
# Header
# -----------------------------------------------------------------------------

log "========================================================================="
log " build_distribution.sh"
log "========================================================================="
log " Vertical    : $VERTICAL"
log " Dist name   : $DIST_NAME"
log " Source      : $MODULE_DIR"
log " Output      : $OUTPUT_DIR"
log "========================================================================="

# -----------------------------------------------------------------------------
# Prepare output dir
# -----------------------------------------------------------------------------

if [[ -d "$OUTPUT_DIR" ]]; then
    if $FORCE; then
        log " ⚠ removing existing $OUTPUT_DIR"
        rm -rf "$OUTPUT_DIR"
    else
        echo "ERROR: $OUTPUT_DIR already exists — use --force to overwrite"
        exit 3
    fi
fi

mkdir -p "$OUTPUT_DIR/skills" "$OUTPUT_DIR/cron"

# -----------------------------------------------------------------------------
# [1/4] Copy distribution metadata
# -----------------------------------------------------------------------------

log ""
log "[1/4] Distribution metadata..."

for f in distribution.yaml SOUL.md config.yaml mcp.json; do
    if [[ -f "$MODULE_DIR/$f" ]]; then
        cp "$MODULE_DIR/$f" "$OUTPUT_DIR/$f"
        log "  ✓ $f"
    else
        log "  ⚠ $f missing — skipped"
    fi
done

# Copy cron jobs if any
if [[ -d "$MODULE_DIR/cron" ]]; then
    cp -r "$MODULE_DIR/cron/." "$OUTPUT_DIR/cron/" 2>/dev/null || true
    log "  ✓ cron/ jobs"
fi

# -----------------------------------------------------------------------------
# [2/4] Wrap skills: .md → <name>/SKILL.md
# -----------------------------------------------------------------------------

wrap_skills() {
    local src_dir="$1"
    local layer="$2"
    local count=0

    [[ ! -d "$src_dir" ]] && return

    for skill in "$src_dir"/*.md; do
        [[ ! -f "$skill" ]] && continue
        local name
        name=$(basename "$skill" .md)
        mkdir -p "$OUTPUT_DIR/skills/$name"
        cp "$skill" "$OUTPUT_DIR/skills/$name/SKILL.md"
        count=$((count + 1))
    done
    log "  ✓ $layer: $count skill(s) wrapped"
}

log ""
log "[2/4] Wrapping skills (single .md → <name>/SKILL.md directory form)..."

wrap_skills "$REPO_ROOT/core/skills"     "core"
wrap_skills "$REPO_ROOT/general/skills"  "general"
wrap_skills "$MODULE_DIR/skills"         "$VERTICAL"

# -----------------------------------------------------------------------------
# [3/4] Generate README for the distribution
# -----------------------------------------------------------------------------

log ""
log "[3/4] Writing distribution README..."

cat > "$OUTPUT_DIR/README.md" <<EOF
# $DIST_NAME — Hermes Profile Distribution

Built by \`deploy/build_distribution.sh $VERTICAL\` at $(date -Iseconds).

This is an **assembled, install-ready** Hermes profile distribution.
Do not edit files here directly — they will be regenerated on next build.
Source lives at:

- \`core/\` — L1 shared office skills
- \`general/\` — L2 shared SME skills
- \`modules/$VERTICAL/\` — L3 vertical-specific skills + distribution metadata

## Install

\`\`\`bash
hermes profile install $OUTPUT_DIR --alias
\`\`\`

…or from a git remote (if this directory is committed and pushed):

\`\`\`bash
hermes profile install github.com/<org>/<repo>/distributions/$DIST_NAME --alias
\`\`\`

## Configure

After install, fill in API keys:

\`\`\`bash
cp ~/.hermes/profiles/$DIST_NAME/.env.EXAMPLE ~/.hermes/profiles/$DIST_NAME/.env
# Edit .env to add OPENROUTER_API_KEY (or ANTHROPIC_API_KEY) + WhatsApp + ...
\`\`\`

See \`distribution.yaml\` \`env_requires:\` for the full list.

## Update

When \`build_distribution.sh\` produces a new version (bump version in
\`modules/$VERTICAL/distribution.yaml\`), reinstall:

\`\`\`bash
hermes profile update $DIST_NAME
\`\`\`

User-owned files (\`memories/\`, \`sessions/\`, \`.env\`, \`auth.json\`) are
preserved across updates.

## References

- Architecture: \`docs/ARCHITECTURE.md\`
- Product PRD: \`docs/PRD-$VERTICAL-asistani.md\`
EOF

log "  ✓ README.md"

# -----------------------------------------------------------------------------
# [4/4] Summary
# -----------------------------------------------------------------------------

SKILL_COUNT=$(find "$OUTPUT_DIR/skills" -name "SKILL.md" | wc -l)
TOTAL_BYTES=$(du -sb "$OUTPUT_DIR" | cut -f1)

log ""
log "========================================================================="
log " ✓ Distribution built"
log "========================================================================="
log "   Output      : $OUTPUT_DIR"
log "   Skills      : $SKILL_COUNT"
log "   Size        : $TOTAL_BYTES bytes"
log ""
log " Next:"
log "   hermes profile install $OUTPUT_DIR --alias"
log "========================================================================="
