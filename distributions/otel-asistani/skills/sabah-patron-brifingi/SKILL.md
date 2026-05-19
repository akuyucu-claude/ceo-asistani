---
name: sabah-patron-brifingi
module: hotel
version: 0.1.0
status: skeleton
description: "Otel sahibine 07:00'de dün özeti + bugünün öne çıkanları (WhatsApp)"
platforms: [linux]
metadata:
  layer: L3-vertical
  prd: docs/PRD-otel-asistani.md
  uc: UC-H1
  phase: MVP
requires:
  connectors:
    required: [whatsapp-business, booking-extranet, google-business-profile]
    optional: [expedia-partner-central, elektraweb-pms, protel-pms]
  vault:
    - modules/hotel/doluluk.md
    - modules/hotel/yorumlar/
    - modules/hotel/rate-monitor.md
    - modules/hotel/sezon-projeksiyon.md
  languages: [tr, en]
triggers:
  - cron: "0 7 * * *"
  - on-demand:gunaydin
  - on-demand:brifing
outputs:
  - notify: gateway:owner (WhatsApp)
  - vault: modules/hotel/brifing/<YYYY-MM-DD>.md
inference:
  default_model: claude-haiku-4-5
  sensitive_model: claude-sonnet-4-6
  pii_redaction: optional
---

# Sabah Patron Brifingi (UC-H1, MVP)

> **Status:** Skeleton.
> **PRD:** [`docs/PRD-otel-asistani.md`](../../../docs/PRD-otel-asistani.md) UC-H1

## Tetikleyiciler

- Her gün 07:00 (customer TZ'sinde)
- Patron WhatsApp'tan "günaydın" veya "brifing"

## Workflow (özet)

1. PMS'den dün doluluk, ADR, RevPAR (CSV ya da API)
2. Bugünkü check-in / check-out listesi
3. Bookings overnight (Booking + Expedia)
4. GBP yeni yorumlar (son 24 saat)
5. Rate parity sapması varsa flag
6. `gunluk-rapor` skill'inin widget kontratına uygun block döndür
7. Sonuçta tek WhatsApp mesajı patron'a

## Çıktı örneği (PRD'den)

```
☀ Günaydın. 19 Mayıs Salı.

🏨 Dün doluluk %78 (28/36 oda) — ADR ₺3.450, RevPAR ₺2.691
📥 Bugün 6 check-in (2'si havaalanı transfer talep etmiş)
📤 Bugün 4 check-out, 3'ü 11:00 öncesi
⭐ 2 yeni yorum — Google'da 9.4 (TR konuk: memnun · DE konuk: kahvaltı eleştirisi)
📊 Hafta projeksiyonu: doluluk %82 (geçen yıl bu hafta %71)
⚠ Türbükü Booking ₺2.400 — bizdeki ₺2.700, %11 sapma (UC-H2'de detay)
```

## Vault yazımı

```
vault/modules/hotel/brifing/<YYYY-MM-DD>.md
```

## Başarı metrikleri (PRD §8)

- Teslimat 07:15'ten önce: %95+
- Patron yanıt oranı: %30+ (engagement signal)
- Kritik anomali tespiti: %90+ (synthetic test set)

## Pitfalls

- PMS CSV gecikirse "veri eksik" diye sus, yanlış veriyle gönderme
- Mesaj uzunluğu — WhatsApp deneyimi bozulmasın
- Hafta sonu / tatilde patron izin verirse sessiz mod

## Referans

- `core/skills/gunluk-rapor.md`
- `modules/hotel/skills/rate-parity-monitor.md`
- `docs/PRD-otel-asistani.md` UC-H1
