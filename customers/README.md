# Customers

Per-customer deployment profiles. Each customer has one directory under this
folder containing at minimum a `profile.toml` (see `_template/`).

## Layout

```
customers/
├── _template/
│   └── profile.toml          # Canonical template — copy when onboarding
├── _examples/
│   ├── kapadokya-cave-otel.toml      # Otel Asistanı example
│   └── istanbul-inbound-dmc.toml     # Acente Asistanı example
└── <customer-slug>/
    └── profile.toml          # Per-customer config (committed to repo)
```

Credential files (`credentials/*.json`) live on the customer VM at
`/opt/<slug>/credentials/`, **never** in this repo.

## Onboarding

```bash
bash deploy/setup_customer.sh \
  --slug kapadokya-cave-otel \
  --domain dashboard.kapadokyacaveotel.com.tr \
  --modules core,general,hotel \
  --languages tr,en,ru,de
```

See `docs/ARCHITECTURE.md` §11 for the full onboarding flow and
`docs/PRD-otel-asistani.md` §12 / `docs/PRD-acente-asistani.md` §12 for
product-specific steps.
