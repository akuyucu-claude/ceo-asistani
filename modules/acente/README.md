# modules/acente — Acente Asistanı

Vertical module for the **Acente Asistanı** product (inbound DMCs / tour
operators).

**PRD:** [`docs/PRD-acente-asistani.md`](../../docs/PRD-acente-asistani.md)
**Status:** Skeleton

## Layout

```
modules/acente/
├── skills/                      # 6 skill markdown files (UC-D1 .. UC-D6)
├── connectors/manifest.yaml     # Required + optional Composio MCP connectors
├── vault-schema/                # Markdown templates initialised in customer vault
└── widgets/manifest.yaml        # Dashboard widget composition order
```

## Skills

| File | UC | Status |
|---|---|---|
| `inquiry-to-itinerary.md` | UC-D1 | Skeleton — MVP |
| `whatsapp-inquiry-triage.md` | UC-D2 | Skeleton — MVP |
| `post-tour-friction-map.md` | UC-D3 | Skeleton — V1 |
| `quote-followup-conversion.md` | UC-D5 | Skeleton — V1 |
| `multi-currency-kur.md` | UC-D6 | Skeleton — V1 |
| `origin-market-pulse.md` | UC-D4 | Skeleton — V2 (Google Trends API gate) |

## Activating for a customer

In the customer's `profile.toml`:

```toml
[modules]
acente = true

[modules.acente]
languages   = ["tr", "en", "de", "ru", "fr", "ar"]
markets     = ["DE", "RU", "GB", "FR", "SA", "AE", "ES"]
currencies  = ["TRY", "EUR", "USD", "GBP"]
team_size   = 12
peak_months = [4, 5, 6, 7, 8, 9, 10]
```

See `customers/_examples/istanbul-inbound-dmc.toml`.
