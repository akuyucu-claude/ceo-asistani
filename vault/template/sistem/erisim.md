# Sistem Erişim Konfigürasyonu

toplam_sistem: 9
aktif: 7
kurulumda: 1
kapali: 1

## Google Calendar
- durum: aktif
- amac: Toplantı takvimi ve hatırlatmalar
- kimlik: akuYucu@gmail.com
- yetenekler: etkinlik_okuma, etkinlik_olusturma

## WhatsApp Gateway  
- durum: aktif
- amac: CEO iletişim ve delegasyon bildirimleri
- kimlik: Hermes Gateway WhatsApp adapter

## Telegram Gateway
- durum: aktif
- amac: Sekonder iletişim kanalı
- kimlik: @hermes_ceo_bot

## GitHub
- durum: aktif
- amac: Kod repoları, issue takibi, PR yönetimi
- kimlik: akuYucu-claude
- repolar: ceo-asistani, komtas-brain-platform, kv-router, sgk-revenue-shield, uaol

## Hetzner Cloud
- durum: aktif
- amac: Sunucu yönetimi, VM provisioning
- sunucu: 91.98.171.251 (uaol-prod)

## KV Router
- durum: aktif
- amac: Sovereign inference, PII detection, audit trail
- endpoint: kv-router.avalancheai.tech

## Composio MCP
- durum: kurulumda
- amac: Gmail, banka API, WhatsApp Business connector
- not: API key mevcut, Hermes entegrasyonu yapılacak

## Banka API (Garanti BBVA)
- durum: kapali
- amac: Nakit pozisyon ve hesap hareketleri
- not: API erişimi için banka onayı gerek

## E-Fatura (GİB)
- durum: kapali
- amac: E-fatura/e-arşiv otomatik parse
- not: GİB entegratör API veya manuel XML upload
