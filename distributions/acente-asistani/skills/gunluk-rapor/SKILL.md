---
name: gunluk-rapor
module: core
version: 0.1.0
status: skeleton
description: "Sabah/akşam patron brifingi iskeleti — vertical modüller bunun üstüne kurar"
platforms: [linux]
metadata:
  layer: L1-core
requires:
  connectors:
    required: [whatsapp-business]
    optional: []
  vault: [core/calendar/, core/tasks/]
  languages: [tr, en]
triggers:
  - cron: "0 7 * * *"
  - cron: "0 19 * * *"
  - on-demand
outputs:
  - notify: gateway:owner (WhatsApp)
  - vault: core/reports/<date>.md
inference:
  default_model: claude-haiku-4-5
  sensitive_model: claude-sonnet-4-6
  pii_redaction: required
---

# Günlük Rapor (L1 Core)

> **Status:** Skeleton. Implementation pending.

L1 iskeletini sunar; vertical UC'ler (UC-H1, gelecek UC-D varyantı) bu
skill'i çağırıp kendi domain widget'larını ekler.

## Tetikleyiciler

- 07:00 — sabah brifingi
- 19:00 — gün sonu özeti
- Patron "günaydın", "günsonu"

## Workflow (özet)

1. Aktif modülleri profile.toml'dan oku
2. Her aktif modülden günlük widget'ı topla (her widget bir block)
3. Önem sırasına dizmek için LLM'e ver
4. Tek WhatsApp mesajı haline getir, patron'a yolla
5. Vault'a aynı içeriği yaz (tarih + zaman damgalı)

## Çıktı formatı

Sabah örnek (otel için):
```
☀ Günaydın. <tarih>.
🏨 <occupancy block — UC-H1>
📥 <arrivals block — UC-H1>
⭐ <reviews block — UC-H4>
📊 <projection block — UC-H1>
⚠ <anomaly alert — UC-H2>
```

Vertical modüller bu widget bloklarını sağlar.

## Vault yazımı

```
vault/core/reports/<YYYY-MM-DD>-morning.md
vault/core/reports/<YYYY-MM-DD>-evening.md
```

## Pitfalls

- Aşırı uzun mesaj kaçınılmalı (WhatsApp deneyimi bozulur) — 1000 karakter sınırı önerisi
- Aynı bilginin farklı widget'lardan çift gösterimi → dedup gerekli
- Patron tatildeyken (takvimdeki "izin" bloğu) yine de gönder ama sessiz mod

## Referans

- `docs/ARCHITECTURE.md` §3 L1-Core
- `docs/PRD-otel-asistani.md` UC-H1
