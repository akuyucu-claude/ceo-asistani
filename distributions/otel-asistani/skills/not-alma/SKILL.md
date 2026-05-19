---
name: not-alma
module: core
version: 0.1.0
status: skeleton
description: "Toplantı notu ve ses transkriptlerini özetleyip aksiyon çıkarma"
platforms: [linux]
metadata:
  layer: L1-core
requires:
  connectors:
    required: []
    optional: [google-calendar, drive-or-onedrive]
  vault: [core/notes/]
  languages: [tr, en]
triggers:
  - on-audio-upload
  - on-text-paste
  - post-meeting (calendar-based)
outputs:
  - vault: core/notes/<meeting-id>.md
  - calls: gorev-takibi (extracted action items)
inference:
  default_model: claude-haiku-4-5
  sensitive_model: claude-sonnet-4-6
  pii_redaction: optional
---

# Not Alma (L1 Core)

> **Status:** Skeleton. Implementation pending.

Sesli toplantı kayıtlarını (Google Meet, Zoom indirilebilir transcript)
veya elle yazılmış notları yapılandırılmış vault girdisine çevirir;
action item'ları `gorev-takibi`'ne yollar.

## Tetikleyiciler

- Patron WhatsApp'tan ses kaydı atınca
- Takvimdeki bir toplantı için "kayıt" dosyası yüklenince
- Elle yapıştırılan ham not

## Workflow (özet)

1. Audio ise transcribe et (Whisper veya KV Router endpoint)
2. Yapılandırılmış özet üret (katılımcılar, ana kararlar, action items, deadline'lar)
3. Vault'a yaz
4. Action item'ları `gorev-takibi` skill'ine forward et

## Vault yazımı

```
vault/core/notes/<YYYY-MM-DD>-<short-title>.md
```

## Pitfalls

- Türkçe Whisper kalitesi → KV Router üzerinden Turkish-sovereign endpoint tercih
- Konuşmacı ayrıştırma (diarization) zor — denemediği durumda "konuşmacı 1" / "konuşmacı 2"
- 60dk+ kayıtlar — parçalama gerekli

## Referans

- `docs/ARCHITECTURE.md` §3 L1-Core
