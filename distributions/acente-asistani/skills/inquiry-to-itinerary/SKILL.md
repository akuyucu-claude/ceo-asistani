---
name: inquiry-to-itinerary
module: acente
version: 0.1.0
status: skeleton
description: "E-mail group inquiry → çok günlük itinerary + fiyat taslağı, 5 dakikada"
platforms: [linux]
metadata:
  layer: L3-vertical
  prd: docs/PRD-acente-asistani.md
  uc: UC-D1
  phase: MVP
requires:
  connectors:
    required: [gmail-or-outlook]
    optional: []
  vault:
    - modules/acente/catalog.md
    - modules/acente/supplier-prices.md
    - modules/acente/itinerary-templates/
  languages: [en, de, fr, ar, ru, tr]
triggers:
  - on-incoming-email (inquiry label)
outputs:
  - vault: modules/acente/inquiries/<inquiry-id>.md
  - draft: itinerary + price + reply email (review queue)
  - dashboard-widget: inquiry-queue
inference:
  default_model: claude-sonnet-4-6   # itinerary quality matters
  sensitive_model: claude-sonnet-4-6
  pii_redaction: required
---

# Inquiry-to-Itinerary Automation (UC-D1, MVP)

> **Status:** Skeleton.
> **PRD:** [`docs/PRD-acente-asistani.md`](../../../docs/PRD-acente-asistani.md) UC-D1

## Tetikleyiciler

- Operatörün izlenen inbox'ına etiketlenmiş yeni inquiry maili gelince

## Workflow (özet)

1. Dil tespit (EN/DE/FR/AR/RU/TR)
2. Inquiry'den extract: tarihler, grup boyutu, origin market, ilgi alanları,
   konaklama tercihi, bütçe sinyalleri
3. Operatör katalogundan (`catalog.md`) en yakın ürünleri eşleştir
4. Custom adjustment'lar öner (örn: "müşteri vegan diyor → restoran X yerine Y")
5. Supplier price sheets'ten para hesabı; TRY tracking
6. Multi-day itinerary üret (operatörün house style'ında)
7. Email reply taslağını agent review queue'ya at

## **Asla auto-send yapmaz.** Quote correctness compound finansal sorumluluk taşır.

## Vault yazımı

```
vault/modules/acente/inquiries/<inquiry-id>.md      # raw + extracted
vault/modules/acente/quotes/<inquiry-id>.md         # draft itinerary + price
```

## Başarı metrikleri (PRD §8)

- Draft median latency < 5 dk
- Draft kabul oranı (≤3 edit ile) %70+ (Hafta 4'ten itibaren)
- Quote conversion uplift ≥%15 (ilk 90 gün)
- Off-hours coverage %100 — 09:00'a kadar draft hazır

## Catalog parsing gerçeği (PRD §15 risk)

Operatörler katalogu PDF/Excel/Word/Notion/Trello tutar. Onboarding'de:
- **Kanonik:** Google Sheet template (yapısal)
- **Best-effort:** PDF (OCR)
- **Best-effort:** Word

İlk customer onboarding'inde CS 1 saat manuel review eder.

## Pitfalls

- Arapça yön (RTL) email parsing
- Rus müşterilerin Telegram/WhatsApp ile takip etmesi → UC-D2 ile bağ
- Supplier price stale ise margin yanlış hesaplanır → freshness check
- "Junior agent" ürün konumlandırması bırakıldı (PRD §15) — bu skill prompt'unda
  da "asistan" terminolojisi kullanılır

## Referans

- `docs/PRD-acente-asistani.md` UC-D1
- `core/skills/email-yonetimi.md` (alt katman)
- `modules/acente/skills/whatsapp-inquiry-triage.md` (kanal eşi)
