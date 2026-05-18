#!/bin/bash
# setup_customer.sh — CEO Asistanı yeni müşteri onboarding
# Kullanım: bash setup_customer.sh <customer-slug> <domain>
# Örnek:   bash setup_customer.sh ak-yapi dashboard.akyapi.com.tr

set -euo pipefail

CUSTOMER_SLUG="${1:?Müşteri slug gerekli}"
DOMAIN="${2:?Domain gerekli}"
VAULT_PATH="/opt/${CUSTOMER_SLUG}/vault"
DASHBOARD_PATH="/var/www/${CUSTOMER_SLUG}"
NGINX_CONF="/etc/nginx/sites-available/${CUSTOMER_SLUG}"

echo "========================================"
echo " CEO Asistanı — Müşteri Onboarding"
echo " Müşteri: ${CUSTOMER_SLUG}"
echo " Domain:  ${DOMAIN}"
echo "========================================"

# 1. Vault dizini oluştur
echo "[1/6] Obsidian vault oluşturuluyor..."
mkdir -p "${VAULT_PATH}"/{finans,projeler,insanlar,tedarik,raporlar}
cp vault/template/sirket.md "${VAULT_PATH}/"
cp vault/template/finans/*.md "${VAULT_PATH}/finans/"
cp vault/template/projeler/*.md "${VAULT_PATH}/projeler/"
cp vault/template/raporlar/*.md "${VAULT_PATH}/raporlar/"
echo "  ✓ Vault: ${VAULT_PATH}"

# 2. Dashboard deploy
echo "[2/6] Dashboard deploy ediliyor..."
mkdir -p "${DASHBOARD_PATH}"
cp dashboard/index.html "${DASHBOARD_PATH}/"
cp dashboard/update_dashboard.py "${DASHBOARD_PATH}/"
chmod +x "${DASHBOARD_PATH}/update_dashboard.py"
echo "  ✓ Dashboard: ${DASHBOARD_PATH}"

# 3. Nginx yapılandırması
echo "[3/6] Nginx yapılandırılıyor..."
sed "s/SIRKET_DOMAIN/${DOMAIN}/g" nginx/dashboard.conf > "${NGINX_CONF}"
ln -sf "${NGINX_CONF}" "/etc/nginx/sites-enabled/${CUSTOMER_SLUG}"
nginx -t && systemctl reload nginx
echo "  ✓ Nginx: ${NGINX_CONF}"

# 4. SSL (Let's Encrypt)
echo "[4/6] SSL sertifikası alınıyor..."
if command -v certbot &> /dev/null; then
    certbot --nginx -d "${DOMAIN}" --non-interactive --agree-tos --email admin@${DOMAIN#dashboard.} || echo "  ⚠ certbot başarısız, manuel çalıştır: certbot --nginx -d ${DOMAIN}"
else
    echo "  ⚠ certbot yok, atlanıyor. Manuel: apt install certbot python3-certbot-nginx"
fi

# 5. İlk dashboard render
echo "[5/6] İlk dashboard oluşturuluyor..."
python3 "${DASHBOARD_PATH}/update_dashboard.py" \
    --vault "${VAULT_PATH}" \
    --output "${DASHBOARD_PATH}/index.html" \
    --template dashboard/index.html
echo "  ✓ Dashboard hazır"

# 6. Cron job (her saat dashboard yenileme)
echo "[6/6] Dashboard cron job kuruluyor..."
CRON_CMD="*/15 * * * * python3 ${DASHBOARD_PATH}/update_dashboard.py --vault ${VAULT_PATH} --output ${DASHBOARD_PATH}/index.html --template ${DASHBOARD_PATH}/index.html > /dev/null 2>&1"
(crontab -l 2>/dev/null | grep -v "update_dashboard.py.*${CUSTOMER_SLUG}"; echo "${CRON_CMD}") | crontab -
echo "  ✓ Cron: Her 15 dakikada bir dashboard yenilenir"

echo ""
echo "========================================"
echo " ✓ Onboarding tamam!"
echo ""
echo " Dashboard: https://${DOMAIN}"
echo " Vault:     ${VAULT_PATH}"
echo ""
echo " Sonraki adımlar:"
echo " 1. Hermes agent kur: hermes profile create ${CUSTOMER_SLUG}"
echo " 2. Gateway kur:    hermes -p ${CUSTOMER_SLUG} gateway setup"
echo " 3. Skill'leri yükle: hermes -p ${CUSTOMER_SLUG} skills install <skill-pack>"
echo "========================================"
