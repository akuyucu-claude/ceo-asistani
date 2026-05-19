#!/bin/bash
# =============================================================================
# setup_customer.sh — Hermes-native customer onboarding (slim v2)
# =============================================================================
#
# Provisions one customer on a Hermes-equipped VM.
#
# Flow (5 steps — slimmed from v1's 9 steps because Hermes handles much
# natively):
#
#   [1] Validate inputs + module list
#   [2] Build Hermes profile distribution from source (build_distribution.sh)
#   [3] Install distribution into Hermes (hermes profile install)
#   [4] Initialize customer business vault from vault-schema (our concern)
#   [5] Deploy dashboard + nginx (our concern) + print operator checklist
#
# Hermes natively handles:
#   - Profile creation, skill loading, MCP config, cron scheduling, gateway
#     management (WhatsApp, Telegram), inference provider, .env management.
#
# We still handle:
#   - Customer business vault (Obsidian-style markdown, /opt/<slug>/vault/)
#   - Customer dashboard (static HTML, /var/www/<slug>/)
#   - nginx + SSL
#   - The customer profile snapshot (customers/<slug>/profile.toml — audit trail)
#
# Usage:
#   bash deploy/setup_customer.sh \
#     --slug kapadokya-cave-otel \
#     --domain dashboard.kapadokyacaveotel.com.tr \
#     --modules core,general,hotel \
#     --languages tr,en,ru,de \
#     --beachhead kapadokya
#
# Predecessor: deploy/setup_customer.legacy.sh (pre-Hermes-native, deprecated)
# Architecture: docs/ARCHITECTURE.md §11
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"


# -----------------------------------------------------------------------------
# Argument parsing
# -----------------------------------------------------------------------------

usage() {
    cat <<EOF
Usage: $0 --slug <slug> --domain <domain> --modules <m1,m2,...> [options]

Required:
  --slug <slug>             Customer slug (lowercase-dashed)
  --domain <domain>         Customer dashboard domain
  --modules <list>          Must include core,general + exactly one vertical (hotel | acente)

Optional:
  --languages <list>        Comma-separated language codes (default: tr,en)
  --beachhead <region>      Hotel only: kapadokya | istanbul | bodrum
  --display-name <name>     Human-readable name (default: slug)
  --contact-email <email>   Operator contact email
  --vm-provider <provider>  hetzner | gcp-turkcell (default: hetzner)
  --skip-nginx              Skip nginx + SSL steps
  --skip-dashboard          Skip dashboard deploy
  --dry-run                 Show what would happen, change nothing
EOF
    exit 1
}

CUSTOMER_SLUG=""
DOMAIN=""
MODULES_RAW=""
LANGUAGES="tr,en"
BEACHHEAD=""
DISPLAY_NAME=""
CONTACT_EMAIL=""
VM_PROVIDER="hetzner"
SKIP_NGINX=false
SKIP_DASHBOARD=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --slug)           CUSTOMER_SLUG="$2"; shift 2 ;;
        --domain)         DOMAIN="$2"; shift 2 ;;
        --modules)        MODULES_RAW="$2"; shift 2 ;;
        --languages)      LANGUAGES="$2"; shift 2 ;;
        --beachhead)      BEACHHEAD="$2"; shift 2 ;;
        --display-name)   DISPLAY_NAME="$2"; shift 2 ;;
        --contact-email)  CONTACT_EMAIL="$2"; shift 2 ;;
        --vm-provider)    VM_PROVIDER="$2"; shift 2 ;;
        --skip-nginx)     SKIP_NGINX=true; shift ;;
        --skip-dashboard) SKIP_DASHBOARD=true; shift ;;
        --dry-run)        DRY_RUN=true; shift ;;
        -h|--help)        usage ;;
        *)                echo "Unknown arg: $1"; usage ;;
    esac
done

[[ -z "$CUSTOMER_SLUG" ]] && { echo "ERROR: --slug required"; usage; }
[[ -z "$DOMAIN" ]]        && { echo "ERROR: --domain required"; usage; }
[[ -z "$MODULES_RAW" ]]   && { echo "ERROR: --modules required"; usage; }
[[ -z "$DISPLAY_NAME" ]]  && DISPLAY_NAME="$CUSTOMER_SLUG"

IFS=',' read -ra MODULES <<< "$MODULES_RAW"

run() { if $DRY_RUN; then echo "  [dry-run] $*"; else eval "$@"; fi; }


# -----------------------------------------------------------------------------
# [1/5] Validate modules
# -----------------------------------------------------------------------------

echo "========================================================================="
echo " Hermes-native Customer Onboarding — $CUSTOMER_SLUG"
echo "========================================================================="

has_module() { local m="$1"; for a in "${MODULES[@]}"; do [[ "$a" == "$m" ]] && return 0; done; return 1; }

has_module core    || { echo "ERROR: 'core' required in --modules"; exit 2; }
has_module general || { echo "ERROR: 'general' required in --modules"; exit 2; }

VERTICAL=""
for m in "${MODULES[@]}"; do
    case "$m" in
        core|general) ;;
        *)
            [[ ! -d "$REPO_ROOT/modules/$m" ]] && { echo "ERROR: unknown module '$m'"; exit 2; }
            [[ -n "$VERTICAL" ]] && { echo "ERROR: one vertical only (got $VERTICAL + $m)"; exit 2; }
            VERTICAL="$m"
            ;;
    esac
done
[[ -z "$VERTICAL" ]] && { echo "ERROR: vertical module required (hotel | acente | ...)"; exit 2; }

# Hermes prerequisite
if ! command -v hermes &> /dev/null; then
    echo ""
    echo "ERROR: 'hermes' CLI not found. Install first:"
    echo "    bash deploy/install_hermes.sh"
    exit 4
fi

DIST_MANIFEST="$REPO_ROOT/modules/$VERTICAL/distribution.yaml"
DIST_NAME=$(grep '^name:' "$DIST_MANIFEST" | awk '{print $2}' | tr -d '"' | head -1)

echo ""
echo " Slug         : $CUSTOMER_SLUG"
echo " Display name : $DISPLAY_NAME"
echo " Domain       : $DOMAIN"
echo " Vertical     : $VERTICAL → $DIST_NAME distribution"
echo " Modules      : ${MODULES[*]}"
echo " Languages    : $LANGUAGES"
[[ -n "$BEACHHEAD" ]] && echo " Beachhead    : $BEACHHEAD"
echo " VM provider  : $VM_PROVIDER"
echo " Hermes       : $(hermes --version | head -1)"
echo " Dry run      : $DRY_RUN"
echo ""


# -----------------------------------------------------------------------------
# [2/5] Build Hermes profile distribution from source
# -----------------------------------------------------------------------------

echo "[2/5] Building Hermes profile distribution from source..."

BUILD_OUTPUT="$REPO_ROOT/distributions/$DIST_NAME"
run "bash '$REPO_ROOT/deploy/build_distribution.sh' '$VERTICAL' --force --quiet"

if [[ -d "$BUILD_OUTPUT" ]] && ! $DRY_RUN; then
    SKILL_COUNT=$(find "$BUILD_OUTPUT/skills" -name "SKILL.md" 2>/dev/null | wc -l)
    echo "  ✓ $DIST_NAME built ($SKILL_COUNT skills)"
fi


# -----------------------------------------------------------------------------
# [3/5] Install Hermes profile for this customer
# -----------------------------------------------------------------------------

echo ""
echo "[3/5] Installing Hermes profile..."

# Customer profile name in Hermes = customer slug
HERMES_PROFILE_DIR="$HOME/.hermes/profiles/$CUSTOMER_SLUG"

if [[ -d "$HERMES_PROFILE_DIR" ]] && ! $DRY_RUN; then
    echo "  ⚠ Hermes profile '$CUSTOMER_SLUG' already exists — using --force"
    FORCE_FLAG="--force"
else
    FORCE_FLAG=""
fi

run "hermes profile install '$BUILD_OUTPUT' --name '$CUSTOMER_SLUG' --alias $FORCE_FLAG -y"

if ! $DRY_RUN; then
    if [[ -f "$HERMES_PROFILE_DIR/.env.EXAMPLE" ]] && [[ ! -f "$HERMES_PROFILE_DIR/.env" ]]; then
        cp "$HERMES_PROFILE_DIR/.env.EXAMPLE" "$HERMES_PROFILE_DIR/.env"
        chmod 600 "$HERMES_PROFILE_DIR/.env"
        echo "  ✓ .env initialised from .env.EXAMPLE (operator must fill in API keys)"
    fi
fi


# -----------------------------------------------------------------------------
# [4/5] Initialize customer business vault from vault-schema
# -----------------------------------------------------------------------------

echo ""
echo "[4/5] Initialising customer business vault..."

OPT_DIR="/opt/$CUSTOMER_SLUG"
VAULT_PATH="$OPT_DIR/vault"

run "mkdir -p '$VAULT_PATH' '$OPT_DIR/credentials' '$OPT_DIR/logs'"
run "chmod 700 '$OPT_DIR/credentials'"

for module in "${MODULES[@]}"; do
    SCHEMA_DIR="$REPO_ROOT/modules/$module/vault-schema"
    [[ ! -d "$SCHEMA_DIR" ]] && continue

    TARGET="$VAULT_PATH/modules/$module"
    run "mkdir -p '$TARGET'"
    run "cp -rn '$SCHEMA_DIR/.' '$TARGET/' 2>/dev/null || true"
    echo "  ✓ modules/$module/ vault-schema → $TARGET"
done

# Snapshot per-customer profile (audit trail — see ARCHITECTURE.md §B2)
SNAPSHOT_FILE="$REPO_ROOT/customers/$CUSTOMER_SLUG/profile.toml"
if ! $DRY_RUN; then
    mkdir -p "$REPO_ROOT/customers/$CUSTOMER_SLUG"
    NOW="$(date -Iseconds)"
    cat > "$SNAPSHOT_FILE" <<EOF
# Snapshot — generated by setup_customer.sh on $NOW
# This is an audit record of what was provisioned. The RUNTIME config is
# managed by Hermes at ~/.hermes/profiles/$CUSTOMER_SLUG/.

[customer]
slug          = "$CUSTOMER_SLUG"
display_name  = "$DISPLAY_NAME"
domain        = "$DOMAIN"
contact_email = "${CONTACT_EMAIL:-REPLACE_ME}"

[provisioning]
modules       = ["$(IFS='","'; echo "${MODULES[*]}")"]
vertical      = "$VERTICAL"
distribution  = "$DIST_NAME"
languages     = ["$(echo "$LANGUAGES" | sed 's/,/","/g')"]
beachhead     = "${BEACHHEAD:-—}"

[hermes]
profile_path  = "$HERMES_PROFILE_DIR"
alias         = "$CUSTOMER_SLUG"
provisioned_at = "$NOW"

[deployment]
vm_provider   = "$VM_PROVIDER"
vault_path    = "$VAULT_PATH"
dashboard_path = "/var/www/$CUSTOMER_SLUG"
EOF
    echo "  ✓ snapshot: $SNAPSHOT_FILE"
fi


# -----------------------------------------------------------------------------
# [5/5] Dashboard + nginx + operator checklist
# -----------------------------------------------------------------------------

echo ""
echo "[5/5] Dashboard, nginx, operator checklist..."

DASHBOARD_PATH="/var/www/$CUSTOMER_SLUG"

if $SKIP_DASHBOARD; then
    echo "  ⊘ dashboard SKIPPED (--skip-dashboard)"
else
    run "mkdir -p '$DASHBOARD_PATH'"
    run "cp '$REPO_ROOT/dashboard/index.html' '$DASHBOARD_PATH/'"
    run "cp '$REPO_ROOT/dashboard/update_dashboard.py' '$DASHBOARD_PATH/'"
    echo "  ✓ dashboard at $DASHBOARD_PATH"
    echo "  ⚠ update_dashboard.py is monolithic — module widget composition still TODO"
fi

if $SKIP_NGINX; then
    echo "  ⊘ nginx + SSL SKIPPED (--skip-nginx)"
else
    NGINX_CONF="/etc/nginx/sites-available/$CUSTOMER_SLUG"
    if [[ -f "$REPO_ROOT/nginx/dashboard.conf" ]]; then
        run "sed 's/SIRKET_DOMAIN/$DOMAIN/g' '$REPO_ROOT/nginx/dashboard.conf' > '$NGINX_CONF'"
        run "ln -sf '$NGINX_CONF' '/etc/nginx/sites-enabled/$CUSTOMER_SLUG'"
        run "nginx -t && systemctl reload nginx"
        echo "  ✓ $NGINX_CONF"
        if command -v certbot &> /dev/null; then
            run "certbot --nginx -d '$DOMAIN' --non-interactive --agree-tos --email 'admin@${DOMAIN#dashboard.}' || true"
        else
            echo "  ⚠ certbot not installed — manual SSL setup needed"
        fi
    fi
fi


# -----------------------------------------------------------------------------
# Operator onboarding checklist
# -----------------------------------------------------------------------------

cat <<EOF

=========================================================================
 ✓ Provisioning complete — $CUSTOMER_SLUG
=========================================================================

 Hermes profile : $HERMES_PROFILE_DIR
 Alias          : run '$CUSTOMER_SLUG chat' to talk to the agent
 Business vault : $VAULT_PATH
 Dashboard      : https://$DOMAIN
 Snapshot       : $SNAPSHOT_FILE

Operator checklist (must complete before going live):

  [ ]  1. Sign KVKK DPA  (template: docs/legal/KVKK-DPA-template.md — TODO)
  [ ]  2. Fill API keys in $HERMES_PROFILE_DIR/.env
         (OPENROUTER_API_KEY for dev, ANTHROPIC_API_KEY for KVKK production)
  [ ]  3. Configure WhatsApp Business:  hermes -p $CUSTOMER_SLUG whatsapp setup
         (Meta approval: 2-4 weeks; sandbox number for testing meanwhile)
EOF

case "$VERTICAL" in
    hotel)
        cat <<EOF
  [ ]  4. Grant Google Business Profile manager access (14-day approval)
  [ ]  5. Provide Booking.com extranet credentials → $OPT_DIR/credentials/booking.json
  [ ]  6. PMS daily CSV export to designated path (Elektraweb / Protel)
  [ ]  7. Fill otel.md (company profile) in $VAULT_PATH/modules/hotel/
  [ ]  8. Fill otel-faq.md (check-in, kahvaltı, parking, ...)
  [ ]  9. Provide 50 historical review responses for brand voice tuning
EOF
        ;;
    acente)
        cat <<EOF
  [ ]  4. Grant Gmail/Outlook OAuth → $OPT_DIR/credentials/gmail.json
  [ ]  5. Provide tour catalog (Google Sheet preferred, PDF accepted)
         → upload to $VAULT_PATH/modules/acente/catalog.md
  [ ]  6. Provide supplier rate sheets → $VAULT_PATH/modules/acente/supplier-prices.md
  [ ]  7. Provide 20 historical inquiries + their actual responses
  [ ]  8. Fill operator.md (TÜRSAB no, team size, source markets, ...)
  [ ]  9. Define quote auto-send thresholds + escalation rules
EOF
        ;;
esac

# Map internal vertical name to PRD file suffix (turkish positioning)
case "$VERTICAL" in
    hotel)  PRD_SUFFIX="otel" ;;
    *)      PRD_SUFFIX="$VERTICAL" ;;
esac

cat <<EOF
  [ ] Final. Verify with 'hermes -p $CUSTOMER_SLUG status' before go-live.

Documentation:
  - Architecture : docs/ARCHITECTURE.md
  - Product PRD  : docs/PRD-${PRD_SUFFIX}-asistani.md
  - Hermes ref   : docs/HERMES-INTEGRATION.md
=========================================================================
EOF
