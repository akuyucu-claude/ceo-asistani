# modules/hotel — Otel Asistanı

Vertical module for the **Otel Asistanı** product.

**PRD:** [`docs/PRD-otel-asistani.md`](../../docs/PRD-otel-asistani.md)
**Status:** Skeleton

## Layout

```
modules/hotel/
├── skills/                      # 5 skill markdown files (UC-H1 .. UC-H5)
├── connectors/manifest.yaml     # Required + optional Composio MCP connectors
├── vault-schema/                # Markdown templates initialised in customer vault
└── widgets/manifest.yaml        # Dashboard widget composition order
```

## Skills

| File | UC | Status |
|---|---|---|
| `sabah-patron-brifingi.md` | UC-H1 | Skeleton — MVP |
| `rate-parity-monitor.md` | UC-H2 | Skeleton — MVP |
| `konuk-iletisim.md` | UC-H3 | Skeleton — MVP |
| `yorum-yanit-ve-friction-map.md` | UC-H4 | Skeleton — V1 |
| `sezon-cash-flow.md` | UC-H5 | Skeleton — V2 |

## Activating for a customer

In the customer's `profile.toml`:

```toml
[modules]
hotel = true

[modules.hotel]
beachhead = "kapadokya"
languages = ["tr", "en", "ru", "de"]
auto_send_threshold = "faq-only"
brand_voice = "warm-formal-tr"
room_count = 42
```

See `customers/_examples/kapadokya-cave-otel.toml`.
