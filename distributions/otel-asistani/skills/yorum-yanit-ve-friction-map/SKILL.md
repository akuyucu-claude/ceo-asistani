---
name: yorum-yanit-ve-friction-map
module: hotel
version: 0.1.0
status: skeleton
description: "Google/Booking yorum yanıt taslağı + haftalık Friction Map"
platforms: [linux]
metadata:
  layer: L3-vertical
  prd: docs/PRD-otel-asistani.md
  uc: UC-H4
  phase: V1
requires:
  connectors:
    required: [google-business-profile]
    optional: [booking-extranet]
  vault:
    - modules/hotel/yorumlar/
    - modules/hotel/otel-faq.md
  languages: [tr, en, ru, de]
triggers:
  - on-event:new-gbp-review
  - cron: "0 12 * * *"     # daily extranet poll
  - cron: "0 19 * * 0"     # Pazar 19:00 — haftalık Friction Map
outputs:
  - vault: modules/hotel/yorumlar/<review-id>.md
  - draft: review response (queue for owner approval)
  - dashboard-widget: review-sentiment
  - notify: gateway:owner (weekly digest)
inference:
  default_model: claude-haiku-4-5
  sensitive_model: claude-sonnet-4-6
  pii_redaction: optional
---

# Yorum Yanıtı + Friction Map (UC-H4, V1)

> **Status:** Skeleton.
> **PRD:** [`docs/PRD-otel-asistani.md`](../../../docs/PRD-otel-asistani.md) UC-H4

## Tetikleyiciler

- GBP webhook'tan yeni yorum
- Günlük 12:00 — Booking/Booking extranet poll
- Pazar 19:00 — haftalık Friction Map digest

## Workflow (özet)

### Per-review (anlık)

1. Aspect-based sentiment çıkar (oda, kahvaltı, personel, lokasyon, gürültü, vb.)
2. Yorum dilinde yanıt taslağı (otel brand voice'unda)
3. Review queue'ya yolla — **asla otomatik publish etme**

### Haftalık Friction Map

1. Son 7 gün yorum + son 90 gün rolling pattern
2. Tekrar eden şikayet ≥3 mention = pattern
3. Tekrar eden övgü = strength
4. Trend yönü (yükseliyor/düşüyor/sabit)
5. WhatsApp digest + dashboard widget güncelle

## Vault yazımı

```
vault/modules/hotel/yorumlar/<review-id>.md      # her yorum
vault/modules/hotel/friction-map.md              # haftalık özet
```

## Başarı metrikleri (PRD §6)

- %100 yorum 24h içinde draft
- %90 draft sahibi tarafından ≤1 edit ile kabul
- Friction Map ayda en az 1 aktif issue bulur

## Pitfalls

- TripAdvisor B2B API yok — manuel upload veya yok say
- Yorum dili tespiti her zaman doğru olmayabilir (Türk konuğun İngilizce yazması)
- Brand voice fine-tuning: ilk 50 historical yanıttan örnek topla

## Referans

- `docs/PRD-otel-asistani.md` UC-H4
- `docs/ARCHITECTURE.md` "Dropped from MVP" listesi (TripAdvisor)
