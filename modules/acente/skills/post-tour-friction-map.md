---
name: post-tour-friction-map
module: acente
version: 0.1.0
status: skeleton
description: "Operatör'ün Google + survey yorumlarından aspect-bazlı Friction Map"
platforms: [linux]
metadata:
  layer: L3-vertical
  prd: docs/PRD-acente-asistani.md
  uc: UC-D3
  phase: V1
requires:
  connectors:
    required: [google-business-profile, gmail-or-outlook]
    optional: []
  vault:
    - modules/acente/tours/
    - modules/acente/suppliers/
    - modules/acente/friction-map.md
  languages: [en, de, fr, ar, ru, tr]
triggers:
  - cron-peak: "0 19 1 * *"      # Her ayın 1'i, sezonda
  - cron-offpeak: "0 19 1 */3 *" # Sezon dışında çeyreklik
  - on-demand:friction-map
outputs:
  - vault: modules/acente/friction-map.md
  - dashboard-widget: friction-map
  - notify: gateway:operasyon-muduru (digest)
inference:
  default_model: claude-sonnet-4-6
  pii_redaction: required
---

# Post-Tour Friction Map (UC-D3, V1)

> **Status:** Skeleton.
> **PRD:** [`docs/PRD-acente-asistani.md`](../../../docs/PRD-acente-asistani.md) UC-D3

## Tetikleyiciler

- Sezon (Nisan–Ekim): aylık 1'i 19:00
- Sezon dışı: çeyreklik
- Pre-season planning toplantısı öncesi (on-demand)

## Workflow (özet)

1. Son cycle'daki yorumlar + survey email'leri topla
2. Aspect-based sentiment: oda kategorisi yerine "Day-3 rehberi", "Selçuk
   hoteli", "Kapadokya restoranı X" gibi spesifik aspect
3. Her şikayet → tour product, tour day, supplier (otel, rehber, restaurant,
   transfer firması) eşleştir
4. ≥3 mention / 90 gün = pattern
5. Trend yönü (yükseliyor / düşüyor / sabit)
6. Supplier scorecard önerisi üret

## Vault yazımı

```
vault/modules/acente/friction-map.md
```

Yapı:
```markdown
## <YYYY-MM> Friction Map

### Recurring complaints
- **Selçuk Hotel X** — kahvaltı (8 mention, ↗ rising)
- **Day-3 guide Mehmet** — gecikme (5 mention, ↘ falling)

### Strengths
- **Kapadokya balloon supplier Y** — guvenlik + zamanında (12 mention)
```

## Başarı metrikleri (PRD §6)

- Cycle başına en az 1 actionable issue
- Operatör yanıt: çeyreklik en az 1 supplier konuşması
- Trend tahmini doğruluğu ≥%70 (yükseliyor flagged → sonraki cycle'da tekrarladı mı)

## V3 doc'tan değişiklik

Cadence quarterly idi → peak season'da monthly. Aynı engine, daha sık çalışır.

## Pitfalls

- Çok dilli aspect extraction — Almanca "Frühstück" + Türkçe "kahvaltı" aynı aspect
- Tek bir kötü yorum panik yaratmasın — minimum mention threshold
- Supplier isim normalizasyonu — "Selçuk Otel X" ve "Otel X / Selçuk" aynı

## Referans

- `docs/PRD-acente-asistani.md` UC-D3
- `usecasesv3cleandata.html` UC2 (v3 doc kaynak)
