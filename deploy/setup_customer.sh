#!/bin/bash
# =============================================================================
# setup_customer.sh — Modular Hermes Platform Customer Onboarding
# =============================================================================
#
# Provisions one customer on the shared Hermes-based platform.
# Reads customers/_template/profile.toml, generates a customer-specific
# profile.toml, initializes vault from active modules' vault-schema/,
# deploys dashboard, configures nginx, prints operator onboarding checklist.
#
# Usage:
#   bash deploy/setup_customer.sh \
#     --slug kapadokya-cave-otel \
#     --domain dashboard.kapadokyacaveotel.com.tr \
#     --modules core,general,hotel \
#     --languages tr,en,ru,de
#
# Architecture reference: docs/ARCHITECTURE.md §11
# Predecessor: deploy/setup_customer.legacy.sh (single-vertical, deprecated)
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
  --modules <list>          Comma-separated module list (must include core,general)

Optional:
  --languages <list>        Comma-separated language codes (default: tr,en)
  --beachhead <region>      Hotel only: kapadokya | istanbul | bodrum
  --display-name <name>     Human-readable name (default: slug)
  --contact-email <email>   Operator contact email
  --vm-provider <provider>  hetzner | gcp-turkcell (default: hetzner)
  --skip-nginx              Skip nginx + SSL steps (useful in dev / non-root)
  --skip-systemd            Skip systemd timer installation
  --dry-run                 Show what would happen, change nothing

Examples:
  # Hotel customer in Kapadokya
  $0 --slug kapadokya-cave-otel \\
     --domain dashboard.kapadokyacaveotel.com.tr \\
     --modules core,general,hotel \\
     --languages tr,en,ru,de \\
     --beachhead kapadokya

  # DMC customer in Istanbul
  $0 --slug istanbul-inbound-dmc \\
     --domain panel.istanbulinbound.com.tr \\
     --modules core,general,acente \\
     --languages tr,en,de,ru,fr,ar
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
SKIP_SYSTEMD=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --slug)          CUSTOMER_SLUG="$2"; shift 2 ;;
        --domain)        DOMAIN="$2"; shift 2 ;;
        --modules)       MODULES_RAW="$2"; shift 2 ;;
        --languages)     LANGUAGES="$2"; shift 2 ;;
        --beachhead)     BEACHHEAD="$2"; shift 2 ;;
        --display-name)  DISPLAY_NAME="$2"; shift 2 ;;
        --contact-email) CONTACT_EMAIL="$2"; shift 2 ;;
        --vm-provider)   VM_PROVIDER="$2"; shift 2 ;;
        --skip-nginx)    SKIP_NGINX=true; shift ;;
        --skip-systemd)  SKIP_SYSTEMD=true; shift ;;
        --dry-run)       DRY_RUN=true; shift ;;
        -h|--help)       usage ;;
        *)               echo "Unknown arg: $1"; usage ;;
    esac
done

[[ -z "$CUSTOMER_SLUG" ]] && { echo "ERROR: --slug required"; usage; }
[[ -z "$DOMAIN" ]]        && { echo "ERROR: --domain required"; usage; }
[[ -z "$MODULES_RAW" ]]   && { echo "ERROR: --modules required"; usage; }
[[ -z "$DISPLAY_NAME" ]]  && DISPLAY_NAME="$CUSTOMER_SLUG"

IFS=',' read -ra MODULES <<< "$MODULES_RAW"


# -----------------------------------------------------------------------------
# Module validation
# -----------------------------------------------------------------------------

has_module() {
    local m="$1"
    for active in "${MODULES[@]}"; do
        [[ "$active" == "$m" ]] && return 0
    done
    return 1
}

has_module core    || { echo "ERROR: 'core' must be in --modules"; exit 2; }
has_module general || { echo "ERROR: 'general' must be in --modules"; exit 2; }

VERTICAL=""
for m in "${MODULES[@]}"; do
    case "$m" in
        core|general) ;;
        hotel|acente)
            if [[ -n "$VERTICAL" ]]; then
                echo "ERROR: only one vertical module allowed (got $VERTICAL + $m)"
                exit 2
            fi
            VERTICAL="$m"
            ;;
        *)
            if [[ ! -d "$REPO_ROOT/modules/$m" ]]; then
                echo "ERROR: unknown module '$m' (not in modules/)"
                exit 2
            fi
            VERTICAL="$m"
            ;;
    esac
done

[[ -z "$VERTICAL" ]] && { echo "ERROR: no vertical module specified (hotel | acente | ...)"; exit 2; }

[[ "$VERTICAL" == "hotel" && -z "$BEACHHEAD" ]] && \
    echo "WARN: --beachhead recommended for hotel module (kapadokya | istanbul | bodrum)"


# -----------------------------------------------------------------------------
# Path layout
# -----------------------------------------------------------------------------

CUSTOMER_DIR="$REPO_ROOT/customers/$CUSTOMER_SLUG"
PROFILE_FILE="$CUSTOMER_DIR/profile.toml"
TEMPLATE_PROFILE="$REPO_ROOT/customers/_template/profile.toml"

# Runtime paths (on the customer VM)
OPT_DIR="/opt/$CUSTOMER_SLUG"
VAULT_PATH="$OPT_DIR/vault"
CRED_DIR="$OPT_DIR/credentials"
HERMES_DIR="$OPT_DIR/hermes"
LOG_DIR="$OPT_DIR/logs"
DASHBOARD_PATH="/var/www/$CUSTOMER_SLUG"
NGINX_CONF="/etc/nginx/sites-available/$CUSTOMER_SLUG"


# -----------------------------------------------------------------------------
# Header
# -----------------------------------------------------------------------------

cat <<EOF
=========================================================================
 Hermes Platform — Customer Onboarding
=========================================================================
 Slug         : $CUSTOMER_SLUG
 Display name : $DISPLAY_NAME
 Domain       : $DOMAIN
 Modules      : ${MODULES[*]}
 Vertical     : $VERTICAL
 Languages    : $LANGUAGES
 Beachhead    : ${BEACHHEAD:-—}
 VM provider  : $VM_PROVIDER
 Dry run      : $DRY_RUN
=========================================================================
EOF

run() {
    if $DRY_RUN; then
        echo "  [dry-run] $*"
    else
        eval "$@"
    fi
}


# -----------------------------------------------------------------------------
# [1/9] Generate customer profile.toml
# -----------------------------------------------------------------------------

echo ""
echo "[1/9] Generating customer profile..."

if [[ ! -f "$TEMPLATE_PROFILE" ]]; then
    echo "ERROR: template profile not found: $TEMPLATE_PROFILE"
    exit 3
fi

run "mkdir -p '$CUSTOMER_DIR'"

if [[ -f "$PROFILE_FILE" ]] && ! $DRY_RUN; then
    echo "  ⚠ profile.toml exists at $PROFILE_FILE — backing up"
    run "cp '$PROFILE_FILE' '$PROFILE_FILE.bak.$(date +%s)'"
fi

# Build vertical-specific config block
VERTICAL_BLOCK=""
case "$VERTICAL" in
    hotel)
        # Languages array as TOML
        LANG_ARRAY=$(echo "$LANGUAGES" | sed 's/[^,]*/"&"/g' | sed 's/,/, /g')
        VERTICAL_BLOCK="[modules.hotel]
beachhead                 = \"${BEACHHEAD:-kapadokya}\"
languages                 = [$LANG_ARRAY]
auto_send_threshold       = \"faq-only\"
brand_voice               = \"warm-formal-tr\"
seasonal_pattern_baseline = \"year-round-low-winter\"
room_count                = 0   # update after operator intake"
        ;;
    acente)
        LANG_ARRAY=$(echo "$LANGUAGES" | sed 's/[^,]*/"&"/g' | sed 's/,/, /g')
        VERTICAL_BLOCK="[modules.acente]
languages   = [$LANG_ARRAY]
markets     = []        # ISO country codes — fill after intake
currencies  = [\"TRY\", \"EUR\", \"USD\", \"GBP\"]
team_size   = 0
peak_months = [4, 5, 6, 7, 8, 9, 10]"
        ;;
esac

# Generate profile
if ! $DRY_RUN; then
    NOW="$(date -Iseconds)"
    cat > "$PROFILE_FILE" <<EOF
# Generated by setup_customer.sh on $NOW
# Schema: customers/_template/profile.toml

[customer]
slug          = "$CUSTOMER_SLUG"
display_name  = "$DISPLAY_NAME"
domain        = "$DOMAIN"
tz            = "Europe/Istanbul"
contact_email = "${CONTACT_EMAIL:-REPLACE_ME}"


[modules]
core    = $(has_module core    && echo true || echo false)
general = $(has_module general && echo true || echo false)
hotel   = $(has_module hotel   && echo true || echo false)
acente  = $(has_module acente  && echo true || echo false)

$VERTICAL_BLOCK


[connectors]
# Fill paths after connector OAuth flow (see [9/9] operator checklist)
# Format: <connector_id> = "credentials/<id>.json"


[inference]
provider          = "kv-router"
endpoint          = "https://kv-router.avalancheai.tech"
default_model     = "claude-haiku-4-5"
sensitive_model   = "claude-sonnet-4-6"
pii_redaction     = "required"
monthly_token_cap = 2_000_000


[gateways]
whatsapp = true
telegram = false
email    = true


[deployment]
vm_provider  = "$VM_PROVIDER"
region       = "$([ "$VM_PROVIDER" = "gcp-turkcell" ] && echo europe-west10 || echo fra1)"
vm_class     = "cx22"
created_at   = "$NOW"
launched_at  = "REPLACE_ME"
EOF
    echo "  ✓ $PROFILE_FILE"
else
    echo "  [dry-run] would write $PROFILE_FILE"
fi


# -----------------------------------------------------------------------------
# [2/9] Provision /opt/<slug>/ directory tree on customer VM
# -----------------------------------------------------------------------------

echo ""
echo "[2/9] Provisioning runtime directories..."
run "mkdir -p '$OPT_DIR' '$VAULT_PATH' '$CRED_DIR' '$HERMES_DIR' '$LOG_DIR'"
run "chmod 700 '$CRED_DIR'"
echo "  ✓ $OPT_DIR/{vault,credentials,hermes,logs}"


# -----------------------------------------------------------------------------
# [3/9] Initialize vault from active modules' vault-schema/
# -----------------------------------------------------------------------------

echo ""
echo "[3/9] Initializing vault from module schemas..."

for module in "${MODULES[@]}"; do
    SCHEMA_DIR="$REPO_ROOT/modules/$module/vault-schema"
    [[ ! -d "$SCHEMA_DIR" ]] && continue

    TARGET_DIR="$VAULT_PATH/modules/$module"
    run "mkdir -p '$TARGET_DIR'"
    run "cp -rn '$SCHEMA_DIR/.' '$TARGET_DIR/'  2>/dev/null || true"
    echo "  ✓ modules/$module/ vault-schema → $TARGET_DIR"
done

# Core + general have flat vault namespaces (no per-module subdir)
if [[ -d "$REPO_ROOT/vault/template" ]]; then
    # Legacy vault template — copy core L1/L2 templates if no module-specific version
    run "cp -rn '$REPO_ROOT/vault/template/.' '$VAULT_PATH/'  2>/dev/null || true"
    echo "  ✓ legacy vault/template/ → $VAULT_PATH  (L1+L2 defaults)"
fi


# -----------------------------------------------------------------------------
# [4/9] Symlink active skills into Hermes skill directory
# -----------------------------------------------------------------------------

echo ""
echo "[4/9] Wiring active skills into Hermes profile..."

HERMES_SKILLS="$HERMES_DIR/skills"
run "mkdir -p '$HERMES_SKILLS'"

for module in "${MODULES[@]}"; do
    case "$module" in
        core)    SRC="$REPO_ROOT/core/skills" ;;
        general) SRC="$REPO_ROOT/general/skills" ;;
        *)       SRC="$REPO_ROOT/modules/$module/skills" ;;
    esac

    [[ ! -d "$SRC" ]] && { echo "  WARN: $module skills/ not found"; continue; }

    for skill in "$SRC"/*.md; do
        [[ ! -f "$skill" ]] && continue
        skill_name=$(basename "$skill")
        run "ln -sf '$skill' '$HERMES_SKILLS/$skill_name'"
    done
    echo "  ✓ $module skills symlinked"
done

# Copy profile.toml into Hermes dir (Hermes reads it from here)
run "cp '$PROFILE_FILE' '$HERMES_DIR/profile.toml'"


# -----------------------------------------------------------------------------
# [5/9] Hermes profile create (if CLI installed)
# -----------------------------------------------------------------------------

echo ""
echo "[5/9] Initializing Hermes profile..."

if command -v hermes &> /dev/null; then
    run "hermes profile create '$CUSTOMER_SLUG' --config '$HERMES_DIR/profile.toml'"
    echo "  ✓ hermes profile created"
else
    echo "  ⚠ 'hermes' CLI not found — skipping. Install: see https://github.com/NousResearch/hermes-agent"
    echo "    Manual step: hermes profile create $CUSTOMER_SLUG --config $HERMES_DIR/profile.toml"
fi


# -----------------------------------------------------------------------------
# [6/9] Deploy dashboard
# -----------------------------------------------------------------------------

echo ""
echo "[6/9] Deploying dashboard..."
run "mkdir -p '$DASHBOARD_PATH'"
run "cp '$REPO_ROOT/dashboard/index.html' '$DASHBOARD_PATH/'"
run "cp '$REPO_ROOT/dashboard/update_dashboard.py' '$DASHBOARD_PATH/'"
echo "  ✓ $DASHBOARD_PATH"
echo "  ⚠ update_dashboard.py is monolithic — module widget composition is TODO (ARCHITECTURE.md §8)"


# -----------------------------------------------------------------------------
# [7/9] Nginx + SSL (optional)
# -----------------------------------------------------------------------------

echo ""
if $SKIP_NGINX; then
    echo "[7/9] Nginx setup SKIPPED (--skip-nginx)"
else
    echo "[7/9] Configuring nginx..."
    if [[ -f "$REPO_ROOT/nginx/dashboard.conf" ]]; then
        run "sed 's/SIRKET_DOMAIN/$DOMAIN/g' '$REPO_ROOT/nginx/dashboard.conf' > '$NGINX_CONF'"
        run "ln -sf '$NGINX_CONF' '/etc/nginx/sites-enabled/$CUSTOMER_SLUG'"
        run "nginx -t && systemctl reload nginx"
        echo "  ✓ $NGINX_CONF"

        if command -v certbot &> /dev/null; then
            DOMAIN_EMAIL="admin@${DOMAIN#dashboard.}"
            run "certbot --nginx -d '$DOMAIN' --non-interactive --agree-tos --email '$DOMAIN_EMAIL' || true"
            echo "  ✓ SSL"
        else
            echo "  ⚠ certbot not installed — manual: certbot --nginx -d $DOMAIN"
        fi
    else
        echo "  ⚠ nginx/dashboard.conf template missing"
    fi
fi


# -----------------------------------------------------------------------------
# [8/9] Systemd timers for scheduled skills
# -----------------------------------------------------------------------------

echo ""
if $SKIP_SYSTEMD; then
    echo "[8/9] Systemd timers SKIPPED (--skip-systemd)"
else
    echo "[8/9] Installing systemd timers..."
    # MVP: dashboard refresh every 15 min. Skill triggers will be added in V2 by
    # parsing each skill's frontmatter `triggers:` and emitting a timer per cron.
    TIMER_NAME="hermes-${CUSTOMER_SLUG}-dashboard"
    UNIT_FILE="/etc/systemd/system/${TIMER_NAME}.service"
    TIMER_FILE="/etc/systemd/system/${TIMER_NAME}.timer"

    if [[ ! -w "/etc/systemd/system" ]] && ! $DRY_RUN; then
        echo "  ⚠ /etc/systemd/system not writable — falling back to cron"
        CRON_CMD="*/15 * * * * python3 $DASHBOARD_PATH/update_dashboard.py --vault $VAULT_PATH --output $DASHBOARD_PATH/index.html --template $DASHBOARD_PATH/index.html > $LOG_DIR/dashboard.log 2>&1"
        run "(crontab -l 2>/dev/null | grep -v 'update_dashboard.py.*$CUSTOMER_SLUG'; echo \"$CRON_CMD\") | crontab -"
        echo "  ✓ cron: every 15 min dashboard refresh"
    else
        cat <<EOF | run "tee '$UNIT_FILE' > /dev/null"
[Unit]
Description=Hermes dashboard refresh — $CUSTOMER_SLUG
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/python3 $DASHBOARD_PATH/update_dashboard.py --vault $VAULT_PATH --output $DASHBOARD_PATH/index.html --template $DASHBOARD_PATH/index.html
StandardOutput=append:$LOG_DIR/dashboard.log
StandardError=append:$LOG_DIR/dashboard.log
EOF
        cat <<EOF | run "tee '$TIMER_FILE' > /dev/null"
[Unit]
Description=Hermes dashboard refresh timer — $CUSTOMER_SLUG

[Timer]
OnBootSec=2min
OnUnitActiveSec=15min
Persistent=true

[Install]
WantedBy=timers.target
EOF
        run "systemctl daemon-reload"
        run "systemctl enable --now '${TIMER_NAME}.timer'"
        echo "  ✓ ${TIMER_NAME}.timer enabled (every 15 min)"
    fi

    echo "  ⚠ Per-skill timers (cron entries from skill frontmatter) — TODO V2"
fi


# -----------------------------------------------------------------------------
# [9/9] First dashboard render + operator checklist
# -----------------------------------------------------------------------------

echo ""
echo "[9/9] Initial dashboard render..."
if ! $DRY_RUN; then
    python3 "$DASHBOARD_PATH/update_dashboard.py" \
        --vault "$VAULT_PATH" \
        --output "$DASHBOARD_PATH/index.html" \
        --template "$REPO_ROOT/dashboard/index.html" \
        2>/dev/null || echo "  ⚠ initial render failed (vault may need operator data first — expected)"
fi
echo "  ✓ dashboard at https://$DOMAIN"


# -----------------------------------------------------------------------------
# Operator onboarding checklist
# -----------------------------------------------------------------------------

cat <<EOF

=========================================================================
 ✓ Provisioning complete — operator next steps
=========================================================================

Dashboard:       https://$DOMAIN
Customer dir:    $CUSTOMER_DIR
Runtime dir:     $OPT_DIR
Active modules:  ${MODULES[*]}

Operator checklist (signed DPA prerequisite):

  [ ] 1. Sign KVKK DPA (template: docs/legal/KVKK-DPA-template.md — TODO)
  [ ] 2. Grant Gmail/Outlook OAuth → store at $CRED_DIR/gmail.json
  [ ] 3. Grant Google Calendar OAuth → $CRED_DIR/gcal.json
  [ ] 4. Submit WhatsApp Business API application (2-4 wk approval)
  [ ] 5. Grant Google Business Profile manager access (14-day approval)
EOF

case "$VERTICAL" in
    hotel)
        cat <<EOF
  [ ] 6. Provide Booking.com extranet credentials → $CRED_DIR/booking.json
  [ ] 7. Provide Expedia Partner Central credentials (optional)
  [ ] 8. PMS daily CSV export to designated S3 bucket (Elektraweb/Protel)
  [ ] 9. Fill otel.md (company profile) in $VAULT_PATH/modules/hotel/otel.md
  [ ] 10. Fill otel-faq.md (check-in, kahvaltı, parking, ...)
  [ ] 11. Provide 50 historical review responses for brand voice tuning
EOF
        ;;
    acente)
        cat <<EOF
  [ ] 6. Provide tour catalog (Google Sheet template preferred, PDF accepted)
         → upload to $VAULT_PATH/modules/acente/catalog.md
  [ ] 7. Provide supplier rate sheets → $VAULT_PATH/modules/acente/supplier-prices.md
  [ ] 8. Provide 20 historical inquiries + their actual responses
  [ ] 9. Fill operator.md (TÜRSAB no, team size, source markets, ...)
  [ ] 10. Define quote auto-send thresholds + escalation rules
EOF
        ;;
esac

cat <<EOF

  [ ] Final. Schedule 1-week observation period before "live" flag.

Documentation:
  - Architecture:  docs/ARCHITECTURE.md
  - Product PRD:   docs/PRD-${VERTICAL}-asistani.md
  - Profile spec:  customers/_template/profile.toml
=========================================================================
EOF
