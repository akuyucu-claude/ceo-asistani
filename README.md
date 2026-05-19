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

## Hızlı başlangıç (yeni müşteri)

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
1. `customers/<slug>/profile.toml` üretir
2. `/opt/<slug>/` runtime dizinleri açar (vault, credentials, hermes, logs)
3. Aktif modüllerin `vault-schema/`'larını customer vault'una kopyalar
4. Aktif modüllerin skill'lerini Hermes profile'ına symlink eder
5. Hermes profile create (CLI yoksa uyarı)
6. Dashboard deploy + nginx + SSL (opsiyonel)
7. Systemd timer kurar (yoksa cron'a düşer)
8. Operator için imzalı KVKK DPA + OAuth grants + WhatsApp Business
   approval gibi sonraki adımları yazdırır

`--dry-run` ile hiçbir şey değiştirmeden ne yapacağını gösterir.

## Repo yapısı

```
ceo-asistani/
├── docs/                                # PRD'ler + mimari
│   ├── ARCHITECTURE.md
│   ├── PRD-otel-asistani.md
│   └── PRD-acente-asistani.md
│
├── core/                                # L1 — her customer
│   ├── skills/  (email, takvim, görev, whatsapp, ...)
│   └── connectors/manifest.yaml
│
├── general/                             # L2 — her SME, her vertical
│   └── skills/  (nakit-akış, gündem, evrak, ik, delegasyon, radar)
│
├── modules/                             # L3 — dikey paketler
│   ├── hotel/                           # Otel Asistanı
│   │   ├── skills/  (5 UC: UC-H1..H5)
│   │   ├── connectors/manifest.yaml
│   │   ├── vault-schema/
│   │   └── widgets/manifest.yaml
│   └── acente/                          # Acente Asistanı
│       ├── skills/  (6 UC: UC-D1..D6)
│       ├── connectors/manifest.yaml
│       ├── vault-schema/
│       └── widgets/manifest.yaml
│
├── customers/                           # Per-customer profile.toml
│   ├── _template/profile.toml           # Kanonik şablon
│   └── _examples/  (Kapadokya otel + İstanbul DMC örnekleri)
│
├── dashboard/                           # Statik HTML + Python renderer
├── deploy/
│   ├── setup_customer.sh                # Modular onboarding
│   └── setup_customer.legacy.sh         # Eski tek-vertical script
├── admin/                               # Operator admin paneli
├── nginx/                               # Nginx config şablonları
└── vault/                               # Legacy template (deprecated;
                                         #   yerini modules/<x>/vault-schema/ aldı)
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
| Modül iskeletleri | ✓ Skeleton dosyalar var |
| `setup_customer.sh` (modular) | ✓ Çalışır (dry-run + happy path) |
| Skill implementation'ları | ⏳ Skeleton — implementation pending |
| Composio MCP connector kodları | ⏳ Manifestler hazır, kod yok |
| WhatsApp gateway adapter | ⏳ Tasarım var, kod yok |
| Dashboard widget composition | ⏳ Manifestler hazır, monolitik renderer henüz değişmedi |
| KVKK DPA template | ⏳ Hukuk masrafı bekleniyor |

## Lisans

MIT
