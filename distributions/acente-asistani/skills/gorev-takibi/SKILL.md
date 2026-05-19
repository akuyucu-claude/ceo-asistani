---
name: gorev-takibi
module: core
version: 0.1.0
status: skeleton
description: "Görev / aksiyon takibi — e-posta, toplantı ve vault'tan çıkarılan task'lar"
platforms: [linux]
metadata:
  layer: L1-core
requires:
  connectors:
    required: []
    optional: [gmail-or-outlook, google-calendar]
  vault: [core/tasks/]
  languages: [tr, en]
triggers:
  - on-email-action-items-detected
  - on-meeting-notes-saved
  - cron: "0 18 * * *"
  - on-demand
outputs:
  - vault: core/tasks/active.md
  - notify: gateway:owner (overdue summary)
inference:
  default_model: claude-haiku-4-5
  pii_redaction: optional
---

# Görev Takibi (L1 Core)

> **Status:** Skeleton. Implementation pending.

Mevcut `general/skills/delegasyon-yonetimi.md`'nin core karşılığı —
delegasyon "kime atanacak" sorusunu çözer, bu skill "ne yapılacak"
sorusunu çözer.

## Tetikleyiciler

- E-posta veya not-alma skill'i action item ürettiğinde
- Her gün 18:00 — gün sonu özeti
- Patron "bu hafta gecikenler"

## Workflow (özet)

1. Yeni task'ları kaynaktan al
2. Mevcut `vault/core/tasks/active.md` ile birleştir
3. Vade geçmişleri öne çıkar
4. Gün sonu özetinde patron'a yolla

## Vault yazımı

```
vault/core/tasks/active.md
vault/core/tasks/archive/<YYYY-MM>.md
```

## Pitfalls

- Aynı task'ın e-mail + toplantı + WhatsApp'tan 3 kez gelmesi → dedup
- Vade tarihi yoksa kullanıcıya sor, varsayma

## Referans

- `docs/ARCHITECTURE.md` §3 L1-Core
- `general/skills/delegasyon-yonetimi.md` (L2 — atama mantığı)
