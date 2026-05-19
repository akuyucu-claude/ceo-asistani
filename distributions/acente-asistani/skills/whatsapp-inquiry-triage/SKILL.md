---
name: whatsapp-inquiry-triage
module: acente
version: 0.1.0
status: skeleton
description: "WhatsApp gelen sorgu — sınıflandırma, eski quote referansı, draft"
platforms: [linux]
metadata:
  layer: L3-vertical
  prd: docs/PRD-acente-asistani.md
  uc: UC-D2
  phase: MVP
  rationale: "TR DMC inquiry'lerinin %30-50'si WhatsApp'tan gelir, v3 doc'ta eksikti"
requires:
  connectors:
    required: [whatsapp-business]
    optional: []
  vault:
    - modules/acente/catalog.md
    - modules/acente/quotes/
    - modules/acente/agents/
    - modules/acente/itinerary-templates/
  languages: [en, de, fr, ar, ru, tr]
triggers:
  - on-incoming-whatsapp
outputs:
  - vault: modules/acente/inquiries/<inquiry-id>.md (linked across channels)
  - send: acknowledgement auto-reply ("ekibimiz 1 saat içinde dönecek")
  - draft: response (review queue)
inference:
  default_model: claude-haiku-4-5
  sensitive_model: claude-sonnet-4-6
  pii_redaction: required
---

# WhatsApp Inquiry Triage (UC-D2, MVP)

> **Status:** Skeleton.
> **PRD:** [`docs/PRD-acente-asistani.md`](../../../docs/PRD-acente-asistani.md) UC-D2

## Tetikleyiciler

- Operatörün Business WhatsApp numarasına yeni mesaj
- Foreign agent → DMC B2B inquiry de buraya gelir

## Workflow (özet)

1. Mesaj sınıflandır:
   - Yeni inquiry → UC-D1 ile köprü (itinerary üret)
   - Mevcut quote'a follow-up → quote lookup + status draft
   - Operasyonel soru → muhasebe/operasyon ekibine route
   - Out-of-scope → human escalation
2. Çağıran kişi vault'taki `agents/` ile eşleşiyorsa (B2B) bilgi al
3. Auto-greeting: "teşekkürler, ekip arkadaşımız 1 saat içinde dönecek"
   (mesai dışı 30 saniye sonra; mesai içi agent 30 sn'de yanıt vermezse)
4. Cross-channel dedup: aynı müşterinin email + WhatsApp inquiry'si tek thread

## Vault yazımı

```
vault/modules/acente/inquiries/<inquiry-id>.md
```

Email + WhatsApp + telefon (varsa) **tek inquiry-id** altında bağlanır.

## Başarı metrikleri (PRD §8)

- WhatsApp ack latency < 1 dk (99. persentil)
- Reply draft latency < 5 dk mesai, < 30 dk gece
- Cross-channel dedup doğruluğu ≥%90

## Auto-send kuralı

Sadece **ack auto-greeting** otomatik gönderilir. Quote / fiyat / itinerary
ile ilgili hiçbir şey ASLA otomatik gönderilmez.

## Pitfalls

- Foreign agent'lar B2B language kullanır; B2C tonuyla yanıtlama
- Sesli mesaj (voice note) — transcribe + yanıtla
- Türk müşteri WhatsApp'tan, Alman müşteri email'den → cross-channel dedup
  başarısı önemli

## Referans

- `docs/PRD-acente-asistani.md` UC-D2
- `modules/acente/skills/inquiry-to-itinerary.md` (köprü)
- `core/skills/whatsapp-iletisim.md` (alt katman)
