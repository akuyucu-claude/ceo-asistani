---
name: quote-followup-conversion
module: acente
version: 0.1.0
status: skeleton
description: "Yanıt almayan quote'lara takip + conversion funnel takibi"
platforms: [linux]
metadata:
  layer: L3-vertical
  prd: docs/PRD-acente-asistani.md
  uc: UC-D5
  phase: V1
requires:
  connectors:
    required: [gmail-or-outlook, whatsapp-business]
    optional: []
  vault:
    - modules/acente/quotes/
    - modules/acente/booked/
  languages: [en, de, fr, ar, ru, tr]
triggers:
  - cron: "0 10 * * *"          # daily 10:00 — quote staleness scan
  - on-event:quote-no-response-48h
  - on-demand:convert-rate
outputs:
  - vault: modules/acente/quotes/<quote-id>.md
  - draft: follow-up message (review queue)
  - dashboard-widget: conversion-funnel
  - notify: gateway:owner (monthly summary)
inference:
  default_model: claude-haiku-4-5
  pii_redaction: optional
---

# Quote Follow-up & Conversion Tracking (UC-D5, V1)

> **Status:** Skeleton.
> **PRD:** [`docs/PRD-acente-asistani.md`](../../../docs/PRD-acente-asistani.md) UC-D5

## Tetikleyiciler

- Quote gönderildikten 48 saat sonra müşteri yanıt vermediyse
- Günlük 10:00 — bayatlamış (>7 gün) quote tarama
- Patron "convert rate son 30 gün"

## Workflow (özet)

1. Açık quote'ları + thread state'leri tara
2. Yanıt almayan quote'ları işaretle
3. Müşteri dilinde nazik takip taslağı çıkar
4. Funnel state'i güncelle: inquiry → quote → revised quote → booked → cancelled
5. Çeyreklik: source market / dil / tour product / agent bazında conversion oranı

## Vault yazımı

```
vault/modules/acente/quotes/<quote-id>.md
```

State alanı: `quoted | revised | booked | cancelled | no-response | stale`.

## Başarı metrikleri (PRD §6)

- Follow-up draft kabul ≥%80
- Bayat quote'larda conversion uplift ≥%10

## Pitfalls

- Aşırı takip → spam algısı; max 2 takip kuralı
- Müşteri tatildeyse takip mesajı uygunsuz olabilir — tarihler arası ayır
- Funnel'a "lost reason" eklemek istersek operatörden manual input — V2

## Referans

- `docs/PRD-acente-asistani.md` UC-D5
- `modules/acente/skills/inquiry-to-itinerary.md`
