# CEO Asistanı

**Hermes tabanlı dikey-AI Asistan platformu.** Tek codebase, iki ürün:

| Ürün | Hedef | PRD |
|---|---|---|
| 🏨 **Otel Asistanı** | Bağımsız boutique otel (30–100 oda) | [`docs/PRD-otel-asistani.md`](docs/PRD-otel-asistani.md) |
| 🧳 **Acente Asistanı** | Inbound DMC / tour operatörü | [`docs/PRD-acente-asistani.md`](docs/PRD-acente-asistani.md) |

Her iki ürün de aynı Hermes runtime + Composio MCP connector katmanı + KV
Router inference (sovereign, KVKK uyumlu) üzerine kurulu. Dikey modüller
(`modules/hotel/`, `modules/acente/`) bağımsız ama platform değişmiyor.

> **Status (Mayıs 2026):** Planlama tamam. Mimari ve PRD'ler stabil.
> Skill implementation'ları skeleton — production-ready değil.

## Mimari özet

```
                    Customer Dashboard
                   (Statik HTML, 15 dk taze)
                            │
                            ▼
              Hermes Agent (per-customer VM)
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   core/skills/       general/skills/    modules/<vertical>/
   (L1 — her          (L2 — her SME      (L3 — Otel | Acente)
    customer)          customer)
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   Composio MCP        KV Router            Vault (Obsidian
   (connectors)        (inference)          markdown — bellek)
                            │
        ┌───────────────────┼───────────────────┐
        WhatsApp        Telegram             E-mail
        (Türkiye        (opsiyonel)          (varsayılan)
         birincil)
```

Tam mimari: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)

## Hızlı başlangıç

### Önce: Hermes'i VM'e kur

```bash
bash deploy/install_hermes.sh
# Sonra: OPENROUTER_API_KEY veya ANTHROPIC_API_KEY .env'ye ekle
echo 'OPENROUTER_API_KEY=sk-or-...' >> ~/.hermes/.env
```

### Yeni müşteri provision'la (Hermes-native, 5 adım)

```bash
# Otel müşterisi — Kapadokya boutique
bash deploy/setup_customer.sh \
  --slug kapadokya-cave-otel \
  --domain dashboard.kapadokyacaveotel.com.tr \
  --modules core,general,hotel \
  --languages tr,en,ru,de \
  --beachhead kapadokya

# DMC müşterisi — İstanbul inbound
bash deploy/setup_customer.sh \
  --slug istanbul-inbound-dmc \
  --domain panel.istanbulinbound.com.tr \
  --modules core,general,acente \
  --languages tr,en,de,ru,fr,ar
```

Script şunları yapar:
1. **Validate** — slug, domain, module list (core + general + vertical)
2. **Build distribution** — `build_distribution.sh` source'tan
   `distributions/<dist-name>/` üretir (skills wrapped, manifest hazır)
3. **Install** — `hermes profile install <built-dir> --name <slug> --alias`
   — Hermes auto-generates `.env.EXAMPLE`, skill'leri yükler, MCP'yi register'lar
4. **Customer vault initialize** — `modules/<x>/vault-schema/` →
   `/opt/<slug>/vault/modules/<x>/` + `customers/<slug>/profile.toml`
   audit snapshot yazılır
5. **Deploy dashboard** + nginx + SSL + operator checklist

`--dry-run` ile hiçbir şey değiştirmeden ne yapacağını gösterir.

### Customer üzerinden agent kullan

Install sonrası:

```bash
# Talk to the customer's agent
hermes -p kapadokya-cave-otel chat

# Or via alias (created by --alias flag)
kapadokya-cave-otel chat

# Configure WhatsApp Business
hermes -p kapadokya-cave-otel whatsapp setup

# Check status
hermes -p kapadokya-cave-otel status
```

### Distribution güncelleme

`modules/<vertical>/` source'unda değişiklik yapınca:

```bash
# Rebuild
bash deploy/build_distribution.sh hotel --force

# Re-install on customer VM
hermes profile update kapadokya-cave-otel

# Customer'ın .env, sessions, memories KORUNUR
```

## Repo yapısı

```
ceo-asistani/
├── docs/                                # PRD'ler + mimari + entegrasyon
│   ├── ARCHITECTURE.md
│   ├── HERMES-INTEGRATION.md
│   ├── PRD-otel-asistani.md
│   └── PRD-acente-asistani.md
│
├── core/                                # L1 SOURCE — her customer
│   ├── skills/  (email, takvim, görev, whatsapp, ...)
│   └── connectors/manifest.yaml
│
├── general/                             # L2 SOURCE — her SME
│   └── skills/  (nakit-akış, gündem, evrak, ik, delegasyon, radar)
│
├── modules/                             # L3 SOURCE — dikey ürünler
│   ├── hotel/                           # Otel Asistanı kaynak
│   │   ├── distribution.yaml            # Hermes manifest
│   │   ├── SOUL.md                      # agent personality
│   │   ├── config.yaml                  # model + tool defaults
│   │   ├── mcp.json                     # MCP server config
│   │   ├── skills/  (5 UC: UC-H1..H5)
│   │   ├── connectors/manifest.yaml     # connector katalogu (build kaynağı)
│   │   ├── vault-schema/                # customer vault iskeleti
│   │   ├── widgets/manifest.yaml        # dashboard widget'ları
│   │   └── cron/                        # Hermes cron tasks
│   └── acente/                          # Acente Asistanı (aynı yapı, 6 UC)
│
├── distributions/                       # BUILD TARGET — build_distribution.sh çıktısı
│   ├── README.md
│   ├── otel-asistani/                   # → hermes profile install <bu dir>
│   └── acente-asistani/
│
├── customers/                           # Per-customer SNAPSHOT (audit)
│   ├── README.md
│   ├── _template/profile.toml
│   └── <slug>/profile.toml              # setup_customer.sh tarafından yazılır
│
├── dashboard/                           # Statik HTML + Python renderer
├── deploy/
│   ├── install_hermes.sh                # Customer VM'e Hermes kur
│   ├── build_distribution.sh            # Source → distribution build
│   ├── setup_customer.sh                # Slim Hermes-native onboarding (5 adım)
│   └── setup_customer.legacy.sh         # Eski monolitik script (deprecated)
├── admin/                               # Operator admin paneli
├── nginx/                               # Nginx config şablonları
└── vault/                               # Legacy template (deprecated;
                                         #   modules/<x>/vault-schema/ aldı)
```

## Teknoloji

| Katman | Seçim |
|---|---|
| Agent runtime | [Hermes](https://github.com/NousResearch/hermes-agent) — değişebilir (bkz. `ARCHITECTURE.md §13`) |
| Connector hub | Composio MCP |
| Inference | KV Router (sovereign, KVKK uyumlu) |
| Bellek | Obsidian-format markdown vault, per-customer |
| Birincil kanal (TR) | WhatsApp Business API |
| Yedek kanal | Telegram + e-mail |
| Hosting | Hetzner Cloud (FRA) veya GCP `europe-west10` Turkcell region |
| Inference modelleri | Claude Haiku 4.5 (default), Claude Sonnet 4.6 (PII / kritik) |

## Fiyatlandırma

| Ürün | Aylık | Yıllık | Design partner (ilk 3-5) |
|---|---|---|---|
| Otel Asistanı | ₺50,000 | ₺600,000 | ₺25,000 |
| Acente Asistanı | ₺75,000 | ₺900,000 | ₺35,000 |
| Kurulum (tek seferlik) | ₺15–25K | – | Muaf |

Detay: PRD §9 / PRD §9.

## Hermes neden?

- **Skill = markdown**: yeni iş eklemek için release shipping yok
- **Composio MCP**: connector ekosistemi hazır
- **KV Router**: KVKK story yapısal, sales angle değil
- **Per-customer profile**: izole VM, izole credential, izole audit

Tek uyarı: Hermes runtime, ürün IP değil. Eğer projeyi NousResearch
bırakırsa Claude Agent SDK'ya 4 hafta içinde geçebilmeliyiz. Skill /
vault / modül formatları runtime'a bağlı değil. Test: çeyreklik
migration safety check (`ARCHITECTURE.md §13`).

## Geliştirme durumu

| Bileşen | Durum |
|---|---|
| PRD'ler (Otel + Acente) | ✓ Stabil |
| Mimari dokümanı | ✓ Stabil |
| Hermes entegrasyonu | ✓ **Build → install zinciri test edildi** (v0.14.0) |
| Distribution metadata (distribution.yaml + SOUL.md + config.yaml + mcp.json) | ✓ Her iki ürün için yazıldı |
| `build_distribution.sh` | ✓ Çalışır (hotel: 19 skill, acente: 20 skill) |
| `setup_customer.sh` (slim, Hermes-native) | ✓ End-to-end test edildi |
| `install_hermes.sh` | ✓ Customer VM için hazır |
| Skill implementation'ları | ⏳ Frontmatter + workflow özeti var, kod yok |
| MCP server kodları (Composio package isimleri) | ⏳ mcp.json stub — pilot'ta doldurulacak |
| Dashboard widget composition | ⏳ Manifestler var, renderer monolitik |
| KVKK DPA template | ⏳ Hukuk masrafı bekleniyor |
| Production runtime test (gerçek LLM çağrısı) | ⏳ Hetzner VM'de bekleniyor |

## Lisans

MIT
