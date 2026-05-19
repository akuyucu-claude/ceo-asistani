---
name: multi-currency-kur
module: acente
version: 0.1.0
status: skeleton
description: "TL volatilitesi karşısında supplier EUR + customer TRY paket marjı takibi"
platforms: [linux]
metadata:
  layer: L3-vertical
  prd: docs/PRD-acente-asistani.md
  uc: UC-D6
  phase: V1
  rationale: "Türkiye DMC'lerinin en büyük PnL ağrısı — sürekli ve günlük"
requires:
  connectors:
    required: [tcmb-rates]
    optional: []
  vault:
    - modules/acente/supplier-prices.md
    - modules/acente/quotes/
    - modules/acente/booked/
    - modules/acente/kur-takibi.md
  languages: [tr]
triggers:
  - cron: "0 9 * * *"          # Daily 09:00 (TCMB rate publish sonrası)
  - on-demand:kur-durum
outputs:
  - vault: modules/acente/kur-takibi.md
  - dashboard-widget: currency-exposure
  - notify: gateway:owner (margin-erosion alerts + daily summary)
inference:
  default_model: claude-haiku-4-5   # mostly calculation, model assists summary
  pii_redaction: optional
---

# Multi-currency Kur Yönetimi (UC-D6, V1)

> **Status:** Skeleton.
> **PRD:** [`docs/PRD-acente-asistani.md`](../../../docs/PRD-acente-asistani.md) UC-D6

## Tetikleyiciler

- Her gün 09:00 (TCMB sabah kuru yayın sonrası)
- Patron "kur durum"

## Workflow (özet)

1. TCMB güncel kurları çek (EUR, USD, GBP, RUB)
2. Açık quote'lar için TRY-margin yeniden hesapla:
   - Supplier cost (EUR) × güncel TRY karşılığı
   - Customer'a verilen TRY fiyat
   - Margin = (customer TRY − supplier TRY karşılığı) / customer TRY
3. Margin eşiği altına düşenleri (varsayılan: <%8) flag
4. Booked tour'lar için: supplier ödeme günü TRY tahmin vs. customer ödeme TRY
5. Büyük expozisyonlar için hedge önerisi (forward, opsiyon, erken ödeme)

## Vault yazımı

```
vault/modules/acente/kur-takibi.md
```

## Günlük çıktı örneği

```
💱 TCMB 19 May:  EUR 36.42  USD 33.18  GBP 41.95

📊 Açık quote expozisyonu: €184K
   ↘ 3 quote margin'i %8 altına düştü:
     • #Q1247 (Munich grubu, 12 Haz) — margin %4.2 ⚠
     • #Q1289 (Berlin family, 5 Tem) — margin %6.1
     • #Q1301 (Vienna couple, 22 Tem) — margin %7.3

📅 Önümüzdeki 30 gün supplier ödemeleri (TRY karşılığı): ₺7.2M
```

## Başarı metrikleri (PRD §6)

- Açık expozisyonun ≥%95'i dashboard'da günlük görünür
- Margin erosion alarmı, manuel tespitten ≥24h önce

## Pitfalls

- TCMB hafta sonu yayın yapmıyor → son iş günü kuru
- Forward kontratlar henüz dahil değil V1
- TL collapse senaryosunda alarm fırtınası — rate limit
- Acente bazen "fixed EUR" satış yapar (kur farkı müşteride) — quote'a flag gerekli

## Referans

- `docs/PRD-acente-asistani.md` UC-D6
