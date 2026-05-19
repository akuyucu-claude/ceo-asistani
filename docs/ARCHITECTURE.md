# Architecture — Hermes-based Vertical AI Junior Platform

**Status:** Planning · **Owner:** Platform · **Last updated:** 2026-05-19

This document describes the shared technical architecture behind two products:

- **Otel Asistanı** — AI Önbüro Juniorı for independent boutique hotels (`PRD-otel-asistani.md`)
- **Acente Asistanı** — AI Rezervasyon Juniorı for inbound DMCs / tour operators (`PRD-acente-asistani.md`)

Both products share one codebase, one runtime, and one operational model. They diverge at the **vertical module layer**.

---

## 1. Design goals

1. **One platform, multiple verticalised products** — no per-customer forks, no per-vertical rewrites.
2. **Skill-as-content** — most product logic lives in markdown skill files, not Python. New jobs-to-be-done are added by writing markdown, not by shipping releases.
3. **Sovereign by default** — Turkish customer data stays in Turkish-jurisdiction infrastructure (Hetzner FRA fallback, Google Cloud `europe-west10` Turkcell region preferred). KVKK-friendly stance is structural, not bolted on.
4. **No vendor lock-in on the agent runtime** — Hermes is our current choice; the architecture must allow swapping it (e.g., to Claude Agent SDK) without rewriting skills or modules.
5. **Connector-first, integration-light** — start with operator-granted OAuth and CSV uploads; defer deep PMS/ERP integration until customer signal demands it.

---

## 2. Stack overview

```
┌────────────────────────────────────────────────────────────────┐
│                       Customer Dashboard                       │
│              dashboard.<customer>.com.tr (static)              │
│   Refreshed by widget composition every 15 min / on-event      │
└──────────────────────────────┬─────────────────────────────────┘
                               │
┌──────────────────────────────▼─────────────────────────────────┐
│                      Hermes Agent Runtime                      │
│                       (per-customer VM)                        │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Skill Loader  (loads .md skills based on profile.toml)   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  ┌────────────┐  │
│  │  Core    │  │ General  │  │ modules/X    │  │  Gateway   │  │
│  │  skills  │  │ skills   │  │ (vertical)   │  │  adapters  │  │
│  └──────────┘  └──────────┘  └──────────────┘  └────────────┘  │
│         │             │             │                  │       │
│         └─────────────┴─────────────┘                  │       │
│                       │                                │       │
│         ┌─────────────▼─────────────┐                  │       │
│         │ Composio MCP Connector Hub│                  │       │
│         └─────────────┬─────────────┘                  │       │
│                       │                                │       │
│         ┌─────────────▼─────────────┐                  │       │
│         │   Obsidian Vault (memory) │◄─────────────────┘       │
│         └─────────────┬─────────────┘                          │
│                       │                                        │
│         ┌─────────────▼─────────────┐                          │
│         │ KV Router (inference)     │                          │
│         │ kv-router.avalancheai.tech│                          │
│         └───────────────────────────┘                          │
└────────────────────────────────────────────────────────────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
        ┌─────▼─────┐    ┌─────▼─────┐    ┌─────▼─────┐
        │ WhatsApp  │    │ Telegram  │    │   Email   │
        │  Business │    │   Bot     │    │   inbox   │
        └───────────┘    └───────────┘    └───────────┘
```

---

## 3. Three-layer skill model

All skills are markdown files with Hermes frontmatter. They are grouped into three layers, loaded selectively per customer based on `profile.toml`.

### L1 — Core (every customer, every vertical)

The "junior employee scaffolding." No customer goes live without these.

| Skill | Purpose |
|---|---|
| `email-yonetimi.md` | Triage, draft, summarize email threads (Gmail/Outlook OAuth) |
| `takvim-yonetimi.md` | Read calendar, schedule, send invites (Google Calendar) |
| `gorev-takibi.md` | Task / action tracking from email, meetings, vault |
| `whatsapp-iletisim.md` | Receive + draft WhatsApp messages (Business API) |
| `dokuman-arama.md` | Semantic search across vault + uploaded documents |
| `gunluk-rapor.md` | Daily briefing scaffold for the owner (07:00 cron) |
| `not-alma.md` | Meeting notes, transcript summarisation |

### L2 — General SME operations (every Turkish SME customer)

Shared "office work" that's the same in any vertical, just calibrated to the customer.

| Skill | Purpose |
|---|---|
| `nakit-akis.md` | Cash position, receivables, projection |
| `gundem-yonetimi.md` | Meeting prep, action follow-up |
| `evrak-istihbarati.md` | Contract / e-fatura parsing, summarisation |
| `ik-rituelleri.md` | SGK / vergi deadline tracker, onboarding checklists |
| `delegasyon-yonetimi.md` | Task delegation, ownership, follow-up |
| `stratejik-radar.md` | Competitor / tender / sector news watch |

(These are the current `skills/*.md` files in the repo; they will be moved to `general/skills/` as part of the modularisation work.)

### L3 — Vertical modules (one customer = one vertical)

Each vertical is a self-contained directory with its own skills, connectors, vault schema, and dashboard widgets.

| Module | Status | Notes |
|---|---|---|
| `modules/hotel/` | **Active product** — see `PRD-otel-asistani.md` |
| `modules/acente/` | **Active product** — see `PRD-acente-asistani.md` |
| `modules/construction/` | Legacy seed data (`AK Yapı`) — keep as example, not productised |
| `modules/accounting/` | Future |
| `modules/law-firm/` | Future |

**Module directory contract:**

```
modules/<vertical>/
├── skills/                  # vertical-specific .md skills
├── connectors/              # which Composio MCP connectors are required/optional
│   └── manifest.yaml
├── vault-schema/            # markdown templates that initialise the customer vault
├── widgets/                 # HTML partials composed into the dashboard
│   └── manifest.yaml
└── README.md                # module-level docs
```

**Module loading is declared in `profile.toml`:**

```toml
[customer]
slug = "kapadokya-cave-otel"
domain = "dashboard.kapadokyacaveotel.com.tr"
display_name = "Kapadokya Cave Otel"

[modules]
core    = true
general = true
hotel   = true        # this is an Otel Asistanı customer
# acente = false

[modules.hotel]
beachhead_tier = "kapadokya"     # used by skills for region-specific defaults
languages = ["tr", "en", "ru", "de"]
```

---

## 4. Skill frontmatter contract

All skills declare their requirements explicitly so the loader can refuse to start a customer with missing dependencies.

```yaml
---
name: rate-parity-monitor
module: hotel
version: 1.0.0
description: "Hourly OTA rate parity check + anomaly alerting"
platforms: [linux]
requires:
  connectors:
    required: [booking-extranet]
    optional: [expedia-extranet, agoda-extranet]
  vault:
    - modules/hotel/rate-monitor.md
  languages: [tr, en]
triggers:
  - cron: "0 * * * *"          # every hour
  - event: "ota-rate-change"
outputs:
  - vault: modules/hotel/rate-monitor.md
  - notify: whatsapp:owner (if anomaly)
  - dashboard-widget: rate-parity
---
```

The loader validates `requires:` against the customer's `profile.toml` and the actual Composio MCP connector state. A missing connector means the skill is **disabled**, not silently broken.

---

## 5. Composio MCP — connector layer

All third-party I/O goes through Composio MCP. Skills never speak HTTP directly.

**Connector categories used across both products:**

| Category | Otel | Acente | Notes |
|---|---|---|---|
| Gmail / Outlook OAuth | ✓ | ✓ | L1 core dependency |
| Google Calendar | ✓ | ✓ | L1 core |
| WhatsApp Business API | ✓ | ✓ | L1 core (Türkiye for both) |
| Google Business Profile API | ✓ | ✓ | UC-H4 (hotel), UC-D3 (DMC) |
| Booking.com Extranet | ✓ | – | OAuth per property |
| Expedia Partner Central | ✓ | – | OAuth per property |
| HotelRunner | ✓ | – | If customer already uses it — read-only |
| PMS (Elektraweb / Protel) | ✓ later | – | CSV import in MVP, API in V2 |
| Travel Studio / TourPlan | – | ✓ later | Same pattern as PMS |
| Google Trends Official API | – | ✓ | UC-D4 |
| TGA Public Statistics | – | ✓ | UC-D4, scheduled scraper of public PDFs |

**KVKK note:** Composio MCP credentials are stored encrypted per customer at `/opt/<slug>/credentials/` and never leave the customer VM.

---

## 6. KV Router — inference layer

All inference calls route through KV Router (`kv-router.avalancheai.tech`).

Why this matters:
- **PII detection** — passport numbers, TC kimlik no, credit card data are detected before leaving the customer VM and either redacted or blocked.
- **Audit trail** — every prompt + response is logged in the customer's audit vault for KVKK compliance.
- **Sovereign inference fallback** — when a request involves sensitive data, KV Router can route to a Turkish-jurisdiction model endpoint instead of the default (frontier model).
- **Cost control** — model selection per skill (cheap model for triage, frontier for itinerary generation).

Skill authors declare inference profile in frontmatter:

```yaml
inference:
  default_model: claude-haiku-4-5
  sensitive_model: turkish-sovereign-llm
  pii_redaction: required
```

---

## 7. Vault — persistent memory

Each customer has one Obsidian-format markdown vault at `/opt/<slug>/vault/`. The vault is the **single source of truth** for the agent. Skills read it, update it, and the dashboard renders from it.

**Vault layout:**

```
vault/
├── sirket.md                       # company profile (any vertical)
├── core/
│   ├── email/                      # email summaries, threads
│   ├── calendar/
│   └── tasks/
├── general/
│   ├── finans/                     # nakit pozisyonu, tahsilat, projeksiyon
│   ├── gundem/                     # toplantı, aksiyon
│   ├── evrak/                      # sözleşme, e-fatura özetleri
│   ├── insanlar/                   # personel, müşteri kontakları
│   └── raporlar/                   # alert, sektör radarı
└── modules/
    ├── hotel/                      # only if module enabled
    │   ├── doluluk.md
    │   ├── konuklar/
    │   ├── yorumlar/
    │   ├── rate-monitor.md
    │   └── sezon-projeksiyon.md
    └── acente/
        ├── inquiries/
        ├── catalog.md
        ├── itineraries/
        ├── friction-map.md
        └── kur-takibi.md
```

**Vault namespacing rule:** modules must never write outside `vault/modules/<their-name>/`. This guarantees safe coexistence and clean uninstall.

**Why Obsidian markdown:** plain-text, human-readable, version-controllable, no schema migrations, customer can audit it. The vault is the customer's, not ours.

---

## 8. Dashboard — widget composition model

`dashboard/update_dashboard.py` currently renders one monolithic HTML. To support modular products it composes widgets from active modules.

```
core/widgets/             → daily-summary, calendar, tasks
general/widgets/          → nakit-pozisyonu, gundem, alertler
modules/hotel/widgets/    → occupancy, ota-revenue, review-sentiment, rate-parity
modules/acente/widgets/   → inquiry-queue, conversion-funnel, friction-map, currency-watch
```

Each widget is a self-contained HTML partial + CSS scope. `update_dashboard.py` reads `profile.toml`, loads widget manifests from active modules, and composes the dashboard. **Two customers in different verticals get visually different dashboards from the same renderer.**

---

## 9. Gateway adapters

Customer-facing channels are abstracted behind a router so skills don't know which channel they're talking to.

```
gateways/
├── router.py             # intent → skill mapping
├── whatsapp.py           # WhatsApp Business API adapter
├── telegram.py           # Telegram Bot adapter
├── email_inbox.py        # IMAP/Graph adapter for incoming email
└── dashboard_api.py      # JSON endpoint for dashboard interactivity
```

**WhatsApp is first-class** for Turkish customers. Both products assume WhatsApp delivers daily briefings and accepts owner / GM commands ("nakit durum?", "bugün gelen sorgular?").

---

## 10. Per-customer deployment topology

```
Hetzner Cloud (or GCP europe-west10)
└── customer-<slug> VM (CX22 baseline, scale up if needed)
    ├── /opt/<slug>/
    │   ├── hermes/                   # Hermes runtime + profile.toml
    │   ├── vault/                    # the customer's data
    │   ├── credentials/              # encrypted, per-connector
    │   ├── logs/                     # structured logs, audit trail
    │   └── skills/ -> symlink to platform repo per active modules
    ├── /var/www/<slug>/              # static dashboard
    └── nginx + systemd timers
```

**Why per-customer VM (not multi-tenant) for V1:**
- KVKK story is structurally airtight (no shared compute, no shared storage)
- Credential isolation by default
- Customer-specific cron schedules
- Simple to reason about, debug, and audit

**When we revisit:** when we have 30+ customers and operational overhead per VM is real. Then we move to a multi-tenant control plane with per-customer namespaces. Not before.

---

## 11. Onboarding script

`deploy/setup_customer.sh` is the one-shot onboarding entrypoint:

```bash
bash deploy/setup_customer.sh \
  --slug kapadokya-cave-otel \
  --domain dashboard.kapadokyacaveotel.com.tr \
  --modules core,general,hotel \
  --beachhead kapadokya \
  --languages tr,en,ru,de
```

Steps performed:

1. Provision `/opt/<slug>/` directory tree
2. Generate `profile.toml` from flags
3. Copy active modules' `vault-schema/` into the customer vault
4. Initialise Hermes profile (`hermes profile create <slug>`)
5. Symlink active skill paths into Hermes skill dir
6. Install required connectors (Composio MCP) — print OAuth URLs for operator
7. Deploy dashboard HTML + Python renderer
8. Configure nginx + Let's Encrypt
9. Install systemd timers for scheduled skills (`gunluk-rapor`, `rate-parity-monitor`, etc.)
10. Run initial render
11. Print operator next-step checklist (DPA signature, OAuth grants, Booking extranet credentials)

The current `setup_customer.sh` is monolithic and assumes one vertical. Refactoring it to honour `--modules` is part of the implementation work.

---

## 12. KVKK & data governance

- **DPA template** ships with the platform; signed before any connector OAuth grant.
- **Veri lokasyonu:** all customer data on infrastructure inside Türkiye (Hetzner FRA only if customer explicitly accepts; GCP `europe-west10` Turkcell region preferred for new customers).
- **PII redaction:** enforced at KV Router for sensitive skills (e.g., passport, TC kimlik).
- **Audit log:** every skill invocation logs prompt + tool calls + output to `vault/audit/`. Customer can read it.
- **Right to delete:** because data is per-VM and per-vault, customer offboarding is `rm -rf /opt/<slug>/` plus credential revocation. Documented as a one-page runbook.

Note: KVKK is structural here, not a sales lead. Both PRDs deliberately position the **value proposition** as revenue/efficiency, with KVKK compliance as a supporting comfort.

---

## 13. What Hermes is — and isn't

**Hermes is:**
- The agent runtime (skill loader, tool dispatcher, LLM client wrapper)
- The MCP host
- The gateway adapter framework
- Configurable per-profile

**Hermes is NOT:**
- Our product. The product is in `modules/`, `connectors/`, `vault-schema/`, `widgets/`, and the GTM around them.
- Our moat. If Hermes is abandoned, we re-target Claude Agent SDK or LangGraph and our skills + vault + modules survive intact.
- A fixed dependency. The skill markdown format is portable; the MCP standard is portable; the vault is plain markdown. The runtime is replaceable.

**Migration safety check (run quarterly):** can we rebuild the runtime layer in 4 weeks if Hermes is end-of-lifed tomorrow? If the answer drifts toward no, we have leaked IP into runtime configuration. Fix it.

---

## 14. Open architectural questions

1. **Multi-tenant control plane** — when do we move off per-customer VMs? Trigger: 30 customers or per-customer monthly ops cost > 10% of ACV.
2. **Skill versioning** — how do we ship breaking changes to a skill without breaking 50 live customers? Likely: skills pinned per customer in `profile.toml`, opt-in upgrade flow.
3. **Module marketplace** — can a partner (Komtaş SI, a Turkish hospitality consultant) ship a module to our customers? Long-term: yes. Out of scope for V1.
4. **Inference cost containment** — what's the per-customer monthly inference budget cap, and what skill demotes from frontier to cheap model when the cap is approached? Open.
5. **PMS abstraction** — is there a single internal "PMS contract" all hotel-vertical skills speak to, with adapters per real PMS? Yes, but only after 2 PMS integrations land (Elektraweb, Protel) — premature before.

---

## 15. References

- Product PRDs: `docs/PRD-otel-asistani.md`, `docs/PRD-acente-asistani.md`
- Current skill catalogue: `skills/*.md` (to be moved to `general/skills/`)
- Vault template: `vault/template/`
- Customer onboarding: `deploy/setup_customer.sh` (refactor pending)
- Hermes upstream: NousResearch/hermes-agent (subject to migration safety check)
