---
name: email-yonetimi
module: core
version: 0.1.0
status: skeleton
description: "Gmail / Outlook üzerinden e-posta okuma, taslak yazma, thread özetleme"
platforms: [linux]
metadata:
  layer: L1-core
requires:
  connectors:
    required: [gmail-or-outlook]
    optional: []
  vault: [core/email/]
  languages: [tr, en]
triggers:
  - on-incoming-email
  - on-demand
outputs:
  - vault: core/email/<thread-id>.md
  - draft: returned to caller skill
inference:
  default_model: claude-haiku-4-5
  pii_redaction: optional
---

# Email Yönetimi (L1 Core)

> **Status:** Skeleton. Implementation pending.

Bütün modüllerin (Otel, Acente) "inbox" girişi bu skill'den geçer. Vertical
UC'ler bu skill'i çağırıp daha sonra kendi domain mantıklarını uygular
(örn: UC-D1 inquiry-to-itinerary).

## Tetikleyiciler

- Gmail/Outlook webhook'tan yeni mesaj
- Bir başka skill çağırırsa (composability)
- Patron WhatsApp'tan "şu konu hakkında ne yazılmış" sorusu

## Workflow (özet)

1. Gmail/Outlook'tan thread çek
2. Dil tespit, kısa özet, action items extraction
3. Vault'a yaz (`core/email/<thread-id>.md`)
4. Çağıran skill'e yapılandırılmış nesne döndür

## Vault yazımı

```
vault/core/email/<thread-id>.md
```

Schema TBD. Minimum alanlar: `from, to, subject, date, summary, language, action_items, sentiment`.

## Pitfalls

- Gmail label scoping (full inbox erişimi istenmemeli)
- KVKK: e-mail içeriği konuk PII içerebilir → KV Router redact path
- Outlook ile Gmail arasında thread modeli farklı

## Referans

- `docs/ARCHITECTURE.md` §3 L1-Core
