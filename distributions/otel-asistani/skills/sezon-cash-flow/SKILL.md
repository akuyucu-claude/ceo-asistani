---
name: sezon-cash-flow
module: hotel
version: 0.1.0
status: skeleton
description: "13 haftalık nakit projeksiyonu — sezonsal pattern + PMS pipeline"
platforms: [linux]
metadata:
  layer: L3-vertical
  prd: docs/PRD-otel-asistani.md
  uc: UC-H5
  phase: V2
requires:
  connectors:
    required: [elektraweb-pms]
    optional: [protel-pms]
  vault:
    - general/finans/
    - modules/hotel/sezon-projeksiyon.md
    - modules/hotel/sezon-pattern.md
  languages: [tr]
triggers:
  - cron: "0 18 * * 6"     # Cumartesi 18:00 haftalık
  - on-demand:nakit-projeksiyon
outputs:
  - vault: modules/hotel/sezon-projeksiyon.md
  - dashboard-widget: cash-projection
  - notify: gateway:owner (cash crunch alert)
inference:
  default_model: claude-sonnet-4-6  # finansal projeksiyon — kaliteli model
  pii_redaction: required
---

# Sezon-Aware Cash Flow Projection (UC-H5, V2)

> **Status:** Skeleton. V2 — PMS entegrasyonu gerekiyor.
> **PRD:** [`docs/PRD-otel-asistani.md`](../../../docs/PRD-otel-asistani.md) UC-H5

## Tetikleyiciler

- Her Cumartesi 18:00 — haftalık projeksiyon
- Patron "nakit projeksiyon"

## Workflow (özet)

1. PMS'den önümüzdeki 13 hafta için confirmed rezervasyonlar + ödeme durumu
2. Açık tahsilatlar `vault/general/finans/tahsilat.md`'den
3. Sabit giderler `vault/general/finans/fixed-costs.md`'den
4. Sezon pattern'i (`vault/modules/hotel/sezon-pattern.md`) ile new booking
   tahmini ekle
5. Hafta bazlı giriş/çıkış matrisi → balance projection
6. Güvenlik eşiğinin altında geçen hafta varsa alarm

## Çıktı

- 13 haftalık chart dashboard'a
- Önümüzdeki 8 haftada eşik altına düşüş varsa WhatsApp alarm
- `vault/modules/hotel/sezon-projeksiyon.md` güncelle

## Başarı metrikleri (PRD §6)

- Cash crunch ≥ 4 hafta önceden tespit
- 4-hafta projeksiyon doğruluğu ±%10

## Niye V2

PMS API entegrasyonu gerekiyor; CSV daily export ile başlasa da güven
seviyesi düşük olacak. MVP/V1'de bu skill kapalı tutulur.

## Pitfalls

- Sezon pattern'inin learning periyodu — ilk 6 ay tarihi veri yeterli mi
- Yıl içi tek seferlik olaylar (deprem, kriz, festival) baseline'ı bozar
- TL volatilitesi giderlerin TL değerini değiştirir (kira, leasing) — kur takip
- Konuk iptal/no-show oranı modellenmeli

## Referans

- `docs/PRD-otel-asistani.md` UC-H5
- `general/skills/nakit-akis.md` (L2 — genel SME nakit akışı)
