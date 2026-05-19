---
name: whatsapp-iletisim
module: core
version: 0.1.0
status: skeleton
description: "WhatsApp Business API — gelen mesaj alma, taslak üretme, gönderme"
platforms: [linux]
metadata:
  layer: L1-core
  importance: critical-for-tr-market
requires:
  connectors:
    required: [whatsapp-business]
    optional: []
  vault: [core/whatsapp/]
  languages: [tr, en, ru, de, fr, ar]
triggers:
  - on-incoming-whatsapp
  - on-demand
outputs:
  - vault: core/whatsapp/<thread-id>.md
  - draft: returned to caller skill
  - send: WhatsApp gateway (if auto_send allowed)
inference:
  default_model: claude-haiku-4-5
  pii_redaction: required
---

# WhatsApp İletişim (L1 Core)

> **Status:** Skeleton. Implementation pending.

Türkiye pazarı için **birinci sınıf gateway**. Sabah brifing teslimat
kanalı (UC-H1, UC-D'lerde patron raporları), gelen müşteri sorgularının
yarısı (UC-H3, UC-D2) buradan gelir.

## Tetikleyiciler

- Meta webhook — yeni inbound mesaj
- Bir başka skill mesaj göndermek istiyor (`send_whatsapp(...)`)

## Workflow (özet)

1. Gelen mesajı dil + intent ile sınıflandır
2. Threading: aynı kişi/numara → vault thread'ine bağla
3. Çağıran skill'e structured object döndür (sender, language, message, intent_guess)
4. Giden mesajda otomatik gönderim kuralı vertical config'inden okunur

## Vault yazımı

```
vault/core/whatsapp/<phone-or-thread-id>.md
```

## Pitfalls

- Meta API onayı 2-4 hafta — sandbox numara ile başla, prod'a geç
- Otomatik gönderim kuralı modüle göre değişir (otel: faq-only; acente: never)
- PII redact: konuk telefonu vault'a yazılır ama LLM context'ine düşmemeli

## Referans

- `docs/ARCHITECTURE.md` §3 L1-Core, §9 Gateway adapters
- `docs/PRD-otel-asistani.md` UC-H3
- `docs/PRD-acente-asistani.md` UC-D2
