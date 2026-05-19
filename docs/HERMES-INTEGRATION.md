# Hermes Integration — Findings & Decisions Pending

**Status:** Investigation complete, restructure decisions pending
**Date:** 2026-05-19
**Hermes version verified:** v0.14.0 (2026.5.16)

This document captures what we learned after actually installing
[NousResearch Hermes Agent](https://github.com/NousResearch/hermes-agent)
and exploring its surface. Several assumptions in our prior planning
(see `docs/ARCHITECTURE.md`, `docs/PRD-otel-asistani.md`,
`docs/PRD-acente-asistani.md`) need to be reconciled with what Hermes
actually does natively.

This is **not yet a refactor plan**. It's a fact-finding writeup. The
restructuring decisions at §6 require explicit owner input before code
changes.

---

## 1. What Hermes provides natively (and we duplicated)

We built our own version of several things Hermes already ships:

| Our planning artefact | Hermes equivalent | Action implied |
|---|---|---|
| `customers/_template/profile.toml` | `hermes profile create <name>` + per-profile `config.yaml`, `SOUL.md`, `.env` | Adopt Hermes's profile format; our `profile.toml` becomes either a thin overlay or is dropped |
| `setup_customer.sh` step 1 (profile gen) | `hermes profile install <git-url>` | Replace with single Hermes command per customer |
| `setup_customer.sh` step 4 (symlink skills) | Hermes profile distribution includes skills | Hermes handles this |
| `setup_customer.sh` step 5 (hermes profile create) | `hermes profile install` — does everything | Simpler |
| `setup_customer.sh` step 8 (systemd timer) | `hermes cron` + `~/.hermes/cron/` | Hermes manages scheduled tasks |
| `core/skills/whatsapp-iletisim.md` stub | `hermes whatsapp setup` + `hermes gateway` | Hermes ships WhatsApp gateway adapter |
| `core/skills/email-yonetimi.md` stub | Bundled `email/himalaya` skill | Hermes already has one |
| `core/skills/takvim-yonetimi.md` stub | (Search Hermes skill registry first) | Possibly already exists |
| `modules/hotel/connectors/manifest.yaml` | `mcp.json` in profile distribution | Format change |
| `modules/hotel/widgets/manifest.yaml` | (No native equivalent — our own dashboard concern) | Keep ours |

---

## 2. What Hermes does NOT do (still our job)

These are the genuinely product-specific things Hermes leaves to us:

- **Customer-specific business data store** — Hermes has `memories/` for
  procedural memory but our Obsidian-style structured "vault" (per-customer
  files like `otel-faq.md`, `catalog.md`, `friction-map.md`) is our
  concept. Lives outside `~/.hermes/`, e.g., at `/opt/<slug>/vault/`.
- **Dashboard** — `dashboard/index.html` + `update_dashboard.py`. Hermes
  has a `hermes dashboard` command but it's CLI-oriented; our customer-facing
  static HTML dashboard is separate.
- **nginx + SSL deployment** — pure infra.
- **Vault schema content** — `modules/hotel/vault-schema/otel.md` and
  similar — these are the templates that initialise per-customer business
  data. Hermes has no concept of this.
- **KVKK DPA template, contracts, legal artefacts**.
- **Customer dashboard widget composition** — our widget manifests, not
  Hermes's surface.
- **The actual product PRDs and positioning** — Hermes is a runtime;
  the product strategy is ours.

---

## 3. The Hermes profile distribution format

Each "product" (Otel Asistanı, Acente Asistanı) should ideally be a
**Hermes profile distribution** — a git repo with this layout:

```
<distribution-name>/
├── distribution.yaml      # required: name, version, env_requires, hermes_requires
├── SOUL.md                # agent personality / system prompt (strongly recommended)
├── config.yaml            # model, provider, tool defaults
├── mcp.json               # MCP server connections (Composio etc.)
├── skills/
│   ├── <skill-name>/
│   │   └── SKILL.md       # each skill is a directory with SKILL.md inside
│   └── ...
├── cron/
│   └── <task>.json        # scheduled tasks
└── README.md              # human-facing description (optional)
```

Customer onboarding becomes:

```bash
hermes profile install github.com/akuyucu-claude/ceo-asistani/<dist> --alias
```

…and the customer can then run `otel-asistani chat` or address it via
any configured gateway.

---

## 4. Skill format mismatch (minor)

**Ours:** `modules/hotel/skills/sabah-patron-brifingi.md` (single .md file)

**Hermes:** `modules/hotel/skills/sabah-patron-brifingi/SKILL.md` (directory with SKILL.md inside, plus optional reference files)

This is a trivial rename — wrap each `.md` in a directory and rename to
`SKILL.md`. Frontmatter format is compatible (we already used
agentskills.io conventions).

Bundled skills are organised by category (`apple/`, `email/`, `creative/`,
`github/`, etc.). For our case, we don't need to nest by category —
each distribution has its own flat `skills/` directory.

---

## 5. Inference provider — OpenRouter is a first-class option

Hermes natively supports OpenRouter (200+ models with one API key) in
addition to Anthropic direct, OpenAI direct, Nous Portal, Gemini, and
many others. From `config.yaml`:

```yaml
model:
  default: "anthropic/claude-opus-4.6"
  provider: "auto"  # auto-detect from credentials
  base_url: "https://openrouter.ai/api/v1"
```

**Implications for our planning:**

- **OpenRouter is excellent for dev / design partner stage.** Single
  key, easy model switching, transparent cost.
- **For KVKK production**, OpenRouter routes through US infra (Cloudflare
  network). This conflicts with our "sovereign inference" story.
  Options:
  - (a) Use Anthropic direct for production (still US, but single hop)
  - (b) Use KV Router (`kv-router.avalancheai.tech`) as we'd planned —
        layered between Hermes and the actual model endpoint
  - (c) Use a Turkish-jurisdiction LLM endpoint (Nous Portal? Local
        `lmstudio` / `ollama` for sensitive paths?)
- **Per-customer choice** — different customers can pick different
  providers via their `.env`. The platform stays neutral.

Recommendation: **dev + design partners on OpenRouter; production with
KVKK-sensitive customers on KV Router or Anthropic direct.** Per-customer
configurable via `.env`.

---

## 6. Restructuring decisions — owner input needed

The following decisions can't be made by the build agent alone. Each
needs an explicit owner call.

### Decision A — Adopt Hermes profile distribution format?

**Option A1: Full adoption.** Restructure `modules/hotel/` and
`modules/acente/` into Hermes-compatible profile distributions. Each
becomes a self-contained git subdirectory (or separate repo) with
`distribution.yaml` + `SOUL.md` + `config.yaml` + `mcp.json` + flat
`skills/`. Customer install = `hermes profile install <url>`.

- Pro: Customer onboarding becomes a one-liner. Updates via
  `hermes profile update`. Standard mechanism.
- Pro: We get cron scheduling, gateway management, MCP integration for free.
- Pro: Could ship to Nous community / Hermes skill registry → discoverability.
- Con: Restructure of 30+ files. Source layer (core/general) needs a
  build/assemble step OR duplication into each distribution.
- Con: Our "modular" mental model (core / general / modules) doesn't
  map 1:1 — Hermes distributions are flat.

**Option A2: Hybrid.** Keep our layered source layout (core/general/modules)
as the **development** structure. Add a build script that assembles a
Hermes distribution dir per product at deploy time.
`setup_customer.sh` calls `hermes profile install <assembled-local-dir>`.

- Pro: Source code stays organised by concern.
- Pro: Hermes still does the heavy lifting on the customer VM.
- Con: One more build step. Two source-of-truth concerns to keep in sync.

**Option A3: Reject Hermes distributions.** Keep our `setup_customer.sh`
as-is, treat Hermes as just "the agent runtime that runs skills" — manually
symlink, manually configure, never use `hermes profile install`.

- Pro: No restructuring.
- Con: We're swimming upstream against Hermes conventions. Every Hermes
  update risks breaking our custom flow.

**Recommendation: A2 (hybrid).** Best balance.

### Decision B — Where do customer profiles live?

Currently: `customers/<slug>/profile.toml` in our repo (committed).

If we adopt Hermes distributions, the equivalent is `~/.hermes/profiles/<slug>/`
on the customer VM — Hermes-managed, not in our repo.

**Option B1:** Drop `customers/` from the repo entirely; per-customer
state lives only on customer VMs.

- Pro: True per-customer isolation, no leakage across customers in source.
- Pro: Matches Hermes's model.
- Con: We lose central visibility / version control over customer configs.

**Option B2:** Keep `customers/<slug>/profile.toml` as a record of what
that customer is configured with — a snapshot, not the source of truth.
On deploy, we generate the real Hermes profile from it.

- Pro: Audit trail.
- Pro: We can re-provision a customer VM from repo state.
- Con: Two systems of record, sync risk.

**Recommendation: B2** for first 20 customers; revisit at scale.

### Decision C — Per-product distribution structure

Three structures possible:

```
# Option C1: distributions in subdir, source kept separate
ceo-asistani/
├── core/                   # development source
├── general/                # development source
├── modules/hotel/          # development source
├── modules/acente/         # development source
└── distributions/          # built at deploy time
    ├── otel-asistani/      # assembled Hermes distribution
    └── acente-asistani/

# Option C2: each product is a separate repo
ceo-asistani-platform/      # this repo: PRDs, architecture, source skills
ceo-asistani-otel/          # separate repo: Hermes distribution
ceo-asistani-acente/        # separate repo: Hermes distribution

# Option C3: each module IS the distribution (no source/build split)
ceo-asistani/
├── distributions/
│   ├── otel-asistani/
│   │   ├── distribution.yaml
│   │   ├── SOUL.md
│   │   ├── skills/   # all skills flat — core + general + hotel duplicated
│   │   └── ...
│   └── acente-asistani/
│       └── ... (skills/ duplicates core + general)
```

**Recommendation: C1.** Keep dev clean, build for production. C2 is
overhead for now; C3 makes skill changes painful (duplicated).

### Decision D — `setup_customer.sh` simplification

Current script does ~9 steps. After Hermes adoption, it should be ~4
steps:

1. Generate Hermes profile (call `hermes profile install` or similar)
2. Initialise customer vault (our concern — not Hermes's)
3. Deploy dashboard + nginx + SSL (our concern)
4. Print operator onboarding checklist

The current 9-step script should be simplified once A/B/C are decided.

### Decision E — Skill stubs: rewrite or wait?

The skill stubs we wrote in the last iteration are Hermes-frontmatter-
compatible markdown. They'll work in either single-file or directory form.

**Option E1:** Rewrite all 18 skill stubs into `SKILL.md` inside directories
now.

**Option E2:** Leave the single-file format; convert when actually
implementing each skill.

**Recommendation: E2.** Convert lazily.

---

## 7. What changes about the existing repo

If we adopt Recommendations A2 + B2 + C1 + D + E2:

| File | Change |
|---|---|
| `docs/ARCHITECTURE.md` | Update §3, §11, §13 to reflect actual Hermes mechanisms |
| `docs/PRD-*.md` | Update §11 (Data sources) to use `mcp.json` references; §12 (Onboarding) to reflect `hermes profile install` |
| `core/`, `general/`, `modules/` | Stay as source. New `distributions/` dir added with built assemblies |
| `customers/<slug>/profile.toml` | Stays. Becomes the input to the build step, not the runtime config |
| `deploy/setup_customer.sh` | Slim down to ~4 steps; new `deploy/build_distribution.sh` script created |
| `deploy/install_hermes.sh` | Already created (this iteration) |
| `README.md` | Update §"Hızlı başlangıç" — replace our flow with Hermes one |

Estimated work: 1–2 days of careful edits, all on this branch.

---

## 8. Immediate next steps (after owner approves direction)

If A2 + B2 + C1 + D + E2 approved:

1. Create `deploy/build_distribution.sh` — assembles
   `distributions/<product>/` from `core/` + `general/` + `modules/<vertical>/`
2. Write minimum `distribution.yaml` + `SOUL.md` for each product (Otel + Acente)
3. Slim `setup_customer.sh` to use `hermes profile install`
4. Convert one skill (`core/skills/whatsapp-iletisim.md`) to directory format
   as proof of concept
5. Update `docs/ARCHITECTURE.md` §3, §11, §13
6. Update `README.md` quickstart

If anything else: pause, discuss.

---

## 9. References

- Hermes v0.14.0 docs: `/usr/local/lib/hermes-agent/website/docs/`
- Profile distributions: `/usr/local/lib/hermes-agent/website/docs/user-guide/profile-distributions.md`
- Repo: https://github.com/NousResearch/hermes-agent
- Quickstart: https://hermes-agent.nousresearch.com/docs/getting-started/quickstart
