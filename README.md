# CEO Asistanı

**Turkish SME CEO Office Agent** — Hermes-powered dijital çalışan.

CEO'ya 7/24 eşlik eden, işini bilen, Türkçe konuşan yapay zeka asistanı.

## Ne Yapar?

| Modül | Görev |
|-------|-------|
| 💰 Nakit Akış Komuta Merkezi | Banka API → anlık nakit pozisyonu, tahsilat radarı |
| 📋 Gündem Yönetimi | Toplantı hazırlık, aksiyon takibi, follow-up |
| 📄 Evrak İstihbaratı | E-fatura/e-arşiv parse, sözleşme özetleme |
| 👥 İK Ritüelleri | SGK/vergi deadline takibi, onboarding |
| 🏭 Tedarik Zinciri Radar | Tedarikçi iletişimi, sipariş takibi |
| 📡 Stratejik Radar | Sektör haberleri, rakip takibi, ihale izleme |

## Mimari

```
┌──────────────────────────────────┐
│         CEO Asistanı Dashboard    │
│    dashboard.sirket.com.tr        │
│    (Statik HTML, her saat taze)   │
└──────────────┬───────────────────┘
               │
┌──────────────▼───────────────────┐
│      Hermes Agent (Hetzner VM)    │
│  ┌─────────────────────────────┐ │
│  │ Skills (6 modül)            │ │
│  │ Obsidian Vault (veri)       │ │
│  │ KV Router (inference)       │ │
│  │ Composio MCP (connectors)   │ │
│  └─────────────────────────────┘ │
└──────────────┬───────────────────┘
               │
┌──────────────▼───────────────────┐
│         WhatsApp / Telegram       │
│    "Nakit durum?" → anlık cevap  │
└──────────────────────────────────┘
```

## Dosya Yapısı

```
ceo-asistani/
├── dashboard/
│   ├── index.html              # Statik komuta merkezi
│   └── update_dashboard.py     # Hermes agent dashboard yenileyici
├── skills/                     # 6 CEO modülü (Hermes skill formatı)
├── vault/template/             # Obsidian vault şablonu
│   ├── sirket.md
│   ├── finans/
│   ├── projeler/
│   ├── insanlar/
│   ├── tedarik/
│   └── raporlar/
├── deploy/
│   └── setup_customer.sh       # Yeni müşteri onboarding
└── nginx/
    └── dashboard.conf          # Nginx yapılandırması
```

## Hızlı Başlangıç

### 1. Dashboard'u gör

```bash
cd dashboard
python3 -m http.server 8080
# http://localhost:8080
```

### 2. Dashboard'u vault'tan güncelle

```bash
python3 dashboard/update_dashboard.py \
  --vault vault/template \
  --output dashboard/index.html
```

### 3. Yeni müşteri onboarding

```bash
bash deploy/setup_customer.sh ak-yapi dashboard.akyapi.com.tr
```

## Teknoloji

- **Agent:** [Hermes Agent](https://github.com/NousResearch/hermes-agent)
- **Inference:** KV Router (sovereign, KVKK uyumlu)
- **Memory:** Obsidian vault
- **Connectors:** Composio MCP
- **Hosting:** Hetzner Cloud (per-müşteri CX22 VM)
- **Delivery:** WhatsApp + Telegram + Web Dashboard

## Fiyatlandırma

| Paket | Aylık | İçerik |
|-------|-------|--------|
| Başlangıç | $2,500 | 1 agent, 2 modül, WhatsApp |
| Profesyonel | $5,000 | 3 agent, tüm modüller, email + dashboard |
| Kurumsal | Özel | Odoo/Logo entegrasyonu, özel modüller |

## Lisans

MIT
