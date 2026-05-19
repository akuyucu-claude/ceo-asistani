---
name: konuk-iletisim
module: hotel
version: 0.1.0
status: skeleton
description: "TR/EN/RU/DE konuk WhatsApp iletişimi — FAQ yanıt, pre-arrival, post-stay"
platforms: [linux]
metadata:
  layer: L3-vertical
  prd: docs/PRD-otel-asistani.md
  uc: UC-H3
  phase: MVP
requires:
  connectors:
    required: [whatsapp-business]
    optional: [elektraweb-pms, protel-pms]
  vault:
    - modules/hotel/otel-faq.md
    - modules/hotel/konuklar/
  languages: [tr, en, ru, de]
triggers:
  - on-incoming-whatsapp
  - cron: "0 12 * * *"     # pre-arrival 24h check
  - cron: "0 14 * * *"     # post-stay 24h check
outputs:
  - vault: modules/hotel/konuklar/<reservation-id>.md
  - draft: WhatsApp reply (review queue)
  - send: WhatsApp (only if auto_send_threshold allows + classification = faq)
inference:
  default_model: claude-haiku-4-5
  sensitive_model: claude-sonnet-4-6
  pii_redaction: required
---

# Konuk WhatsApp İletişimi (UC-H3, MVP)

> **Status:** Skeleton.
> **PRD:** [`docs/PRD-otel-asistani.md`](../../../docs/PRD-otel-asistani.md) UC-H3

## Tetikleyiciler

- Otel'in Business WhatsApp numarasına yeni mesaj
- Pre-arrival 24h hatırlatma
- Post-stay 24h follow-up

## Workflow (özet)

1. Dil tespit (TR/EN/RU/DE; bilinmeyen ise insanı çağır)
2. Telefon → PMS'te rezervasyon eşleştirme (varsa)
3. Mesajı kategorize et: FAQ / şikayet / istek / acil
4. FAQ ise vault'taki `otel-faq.md`'den cevap taslağı
5. Şikayet/istek/fiyat içeren → ASLA auto-send, insana yolla
6. Pre-arrival: dil + rezervasyon bağlamı ile karşılama
7. Vault'a etkileşim log'u

## Vault yazımı

```
vault/modules/hotel/konuklar/<reservation-id>.md
```

## Auto-send kuralı (kritik)

`profile.toml`'daki `auto_send_threshold`:
- `never` — hiçbir mesaj otomatik gönderilmez
- `faq-only` — sadece FAQ kategorisi yüksek confidence ile (varsayılan)
- `confident` — yüksek confidence olan her şey

**Asla auto-send olmayanlar:**
- Fiyat / iade / iptal içeren
- Şikayet
- Özel istek (allergy, late checkout vb.)

## Başarı metrikleri (PRD §6)

- %80 gelen mesaj 5 dk içinde draft
- 0 yanlış faktüel iddia (auto-send'de)
- Gece (22:00–08:00) gelen mesajların %95+ draft'ı sabaha hazır

## Pitfalls

- Telefondan rezervasyon eşleşmesi: aynı numara birden çok rezervasyon
- RU/DE Türkçe alfabe karışıklığı
- Pre-arrival mesajı kayboldu mu kontrol et (Meta delivery receipt)
- Tier-2 expansion: Kapadokya için ES/IT/JP/KR/ZH planla

## Referans

- `docs/PRD-otel-asistani.md` UC-H3
- `core/skills/whatsapp-iletisim.md` (alt katman)
