---
name: takvim-yonetimi
module: core
version: 0.1.0
status: skeleton
description: "Google Calendar entegrasyonu — okuma, etkinlik oluşturma, hatırlatma"
platforms: [linux]
metadata:
  layer: L1-core
requires:
  connectors:
    required: [google-calendar]
    optional: []
  vault: [core/calendar/]
  languages: [tr, en]
triggers:
  - cron: "0 6 * * *"
  - on-demand
outputs:
  - vault: core/calendar/<date>.md
  - notify: gateway:owner (if conflicts)
inference:
  default_model: claude-haiku-4-5
  pii_redaction: optional
---

# Takvim Yönetimi (L1 Core)

> **Status:** Skeleton. Implementation pending.

Vertical sabah brifing'i (UC-H1, UC-D2) bu skill'in günlük çıktısını okur.

## Tetikleyiciler

- Her sabah 06:00 — günlük takvim özeti
- Patron "bugün ne var", "yarın boş muyum"
- Çakışma tespiti: yeni etkinlik mevcut bir tanesi ile çakışırsa

## Workflow (özet)

1. Google Calendar'dan ilgili tarih aralığını çek
2. Etkinlikleri kategorize et (toplantı, kişisel, deadline, blok)
3. Vault'a yapılandırılmış halde yaz
4. Çakışma varsa gateway üzerinden patron'a alarm

## Vault yazımı

```
vault/core/calendar/<YYYY-MM-DD>.md
```

## Pitfalls

- Birden fazla takvim hesabı (kişisel + iş) ayrılmalı
- Tüm gün etkinlikler vs. saatli etkinlikler
- TZ — daima `Europe/Istanbul` olarak normalize et

## Referans

- `docs/ARCHITECTURE.md` §3 L1-Core
