---
name: rate-parity-monitor
module: hotel
version: 0.1.0
status: skeleton
description: "OTA kanalları arası fiyat parity kontrolü + komisyon kayıp uyarısı"
platforms: [linux]
metadata:
  layer: L3-vertical
  prd: docs/PRD-otel-asistani.md
  uc: UC-H2
  phase: MVP
requires:
  connectors:
    required: [booking-extranet]
    optional: [expedia-partner-central, agoda-extranet, hotelrunner]
  vault:
    - modules/hotel/rate-monitor.md
  languages: [tr, en]
triggers:
  - cron: "0 * * * *"
  - on-demand:fiyat-kontrol
  - on-event:ota-rate-change
outputs:
  - vault: modules/hotel/rate-monitor.md
  - notify: gateway:owner (anomaly only)
  - dashboard-widget: rate-parity
inference:
  default_model: claude-haiku-4-5
  pii_redaction: optional
---

# Rate Parity Monitor (UC-H2, MVP)

> **Status:** Skeleton.
> **PRD:** [`docs/PRD-otel-asistani.md`](../../../docs/PRD-otel-asistani.md) UC-H2

## Tetikleyiciler

- Her saat başı (mesai aralığı configurable)
- Patron "fiyat kontrol"
- OTA rate change event (eğer webhook desteklenirse)

## Workflow (özet)

1. Her bağlı OTA'dan oda tipi × tarih grid'inde fiyatları al
2. Anchor channel'a göre %3+ sapma tespit et
3. 7 günden eski güncellenmemiş kanal flag
4. Etkilenen kalan envanter için tahmini ₺ kayıp hesapla
5. Anomali varsa patron WhatsApp + vault'a yaz

## Çıktı örneği

```
⚠ Expedia ₺2.100, Booking ₺2.400 — Türbükü Suite 14–17 Mayıs.
  Tahmini kayıp ₺18.000.
```

## Vault yazımı

```
vault/modules/hotel/rate-monitor.md
```

## Başarı metrikleri (PRD §8)

- Parity sapması tespiti: median < 60 dk
- False positive < %5
- ADR uplift (90 gün rolling): ≥ %3

## V1 sınırı

**Otomatik düzeltmez.** Sadece bildirir, insan harekete geçer. V2'de
"tek tıkla parity düzeltme" düşünülebilir.

## Pitfalls

- Booking Extranet rate-limit
- Aynı oda tipinin OTA'larda farklı isimde olması — mapping table gerekli
- Promosyon dönemlerinde "kasıtlı" sapmalar - allow-list

## Referans

- `docs/PRD-otel-asistani.md` UC-H2
- `modules/hotel/skills/sabah-patron-brifingi.md` (anomali bildirimi orada da görünür)
