---
name: origin-market-pulse
module: acente
version: 0.1.0
status: skeleton
description: "Google Trends + TGA istatistik sentezi — origin market heatmap"
platforms: [linux]
metadata:
  layer: L3-vertical
  prd: docs/PRD-acente-asistani.md
  uc: UC-D4
  phase: V2
  blockers: "Google Trends Official API quota + commercial ToS verification gerekli"
requires:
  connectors:
    required: []
    optional: [google-trends-official-api, tga-public-statistics]
  vault:
    - modules/acente/origin-markets.md
  languages: [tr, en]
triggers:
  - cron: "0 9 1 * *"          # Her ayın 1'i sabah
  - on-demand:pre-trade-fair
outputs:
  - vault: modules/acente/origin-markets.md
  - dashboard-widget: origin-market-heatmap
inference:
  default_model: claude-haiku-4-5
  pii_redaction: optional
---

# Origin Market Pulse (UC-D4, V2)

> **Status:** Skeleton — V2, Google Trends API gate'in arkasında.
> **PRD:** [`docs/PRD-acente-asistani.md`](../../../docs/PRD-acente-asistani.md) UC-D4

## Tetikleyiciler

- Aylık sentez (her ayın 1'i)
- Pre-trade-fair planning (on-demand)

## Workflow (özet)

1. Google Trends Official API'den (Temmuz 2025 launch) 20+ origin country için
   Türkiye-travel keyword interest çek
2. TGA / Kültür Bakanlığı aylık ziyaretçi PDF'ini parse et
3. Cross-reference: search interest yükseliyor ama arrival henüz yok = early signal
4. Heat map (origin × destination × month)
5. Önümüzdeki çeyrek için trade fair budget önerisi

## V2 Niye

V3 doc bu UC'yi MVP'den çıkardı — sebepleri:
1. Google Trends Official API commercial ToS verify edilmedi
2. Quota (1500 calls/day) yeterli mi belirsiz
3. TGA verisi 4-6 hafta gecikmeli — operatöre "geri kalmış" görünebilir

**Fallback:** SerpAPI Google Trends wrapper (~$100/ay) — eğer official API
quota yetersiz çıkarsa.

## Vault yazımı

```
vault/modules/acente/origin-markets.md
```

## Başarı metrikleri (PRD §6)

- Heat map çeyrekte en az 1 trade fair budget kararına etki etti

## Pitfalls

- Geçen yıl COVID dalgası gibi exogen şoklar baseline'ı bozar
- Bir keyword "Türkiye" ama bu "ülke" mi "kümes hayvanı" mı (İngilizce "turkey")
- Currency / political event korelasyonları gürültü yaratabilir

## Referans

- `docs/PRD-acente-asistani.md` UC-D4
- `usecasesv3cleandata.html` UC3 (v3 doc kaynak)
- `docs/ARCHITECTURE.md` "Dropped from MVP" / "Verify API Terms" listesi
