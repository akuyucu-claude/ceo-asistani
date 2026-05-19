---
name: dokuman-arama
module: core
version: 0.1.0
status: skeleton
description: "Vault + yüklenen belgelerde semantik arama"
platforms: [linux]
metadata:
  layer: L1-core
requires:
  connectors:
    required: []
    optional: [drive-or-onedrive]
  vault: ["*"]
  languages: [tr, en]
triggers:
  - on-demand (called by other skills)
outputs:
  - returned: list of (file, snippet, score)
inference:
  default_model: claude-haiku-4-5
  embedding_model: "voyage-3"
---

# Doküman Arama (L1 Core)

> **Status:** Skeleton. Implementation pending.

Diğer skill'lerin "şirket-spesifik bağlam" sorularına cevap veren altyapı.
Örn: UC-H3 "konuğa kahvaltı saat kaçta?" derken bu skill `otel-faq.md`'ye
bakar.

## Tetikleyiciler

- Diğer skill'lerden çağrı (semantik arama API'si)
- Patron "X hakkında ne yazmışız" sorusu

## Workflow (özet)

1. Sorguyu embedde
2. Vault dosyalarının embedding indeksinde ara
3. Top-k snippet döndür (kaynak path + skor)

## Vault yazımı

Bu skill yazmaz; sadece okur ve indeksini `core/.search-index/` altında tutar.

## Pitfalls

- Embedding modelinin Türkçe NLP kalitesi (voyage-3 baseline)
- Yeni dosya eklendiğinde reindex
- Çok büyük PDF'leri parçalama

## Referans

- `docs/ARCHITECTURE.md` §3 L1-Core, §7 Vault
