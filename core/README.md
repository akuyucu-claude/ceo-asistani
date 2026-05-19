# core/ — Çekirdek Ofis Asistanı (L1)

Layer-1 skills + connectors. Every customer in every vertical loads these.

**Architecture reference:** [`docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md) §3 (L1 — Core)
**Status:** Skeleton

## Layout

```
core/
├── skills/                  # L1 skill markdown files
└── connectors/manifest.yaml # OAuth-based: Gmail/Outlook, Calendar, WhatsApp, ...
```

## Skills

| File | Purpose | Status |
|---|---|---|
| `email-yonetimi.md` | Triage, draft, summarise email threads | Skeleton |
| `takvim-yonetimi.md` | Calendar reading, scheduling | Skeleton |
| `gorev-takibi.md` | Task / action tracking | Skeleton |
| `whatsapp-iletisim.md` | WhatsApp Business gateway | Skeleton |
| `dokuman-arama.md` | Semantic search across vault + uploads | Skeleton |
| `gunluk-rapor.md` | Daily briefing scaffold (consumed by vertical UCs) | Skeleton |
| `not-alma.md` | Meeting notes, transcript summarisation | Skeleton |

## Loading

Loaded automatically for any customer where `profile.toml` has
`[modules] core = true` (which is required for all customers).
