# otel-asistani — Hermes Profile Distribution

Built by `deploy/build_distribution.sh hotel` at 2026-05-19T17:51:30+00:00.

This is an **assembled, install-ready** Hermes profile distribution.
Do not edit files here directly — they will be regenerated on next build.
Source lives at:

- `core/` — L1 shared office skills
- `general/` — L2 shared SME skills
- `modules/hotel/` — L3 vertical-specific skills + distribution metadata

## Install

```bash
hermes profile install /home/user/ceo-asistani/distributions/otel-asistani --alias
```

…or from a git remote (if this directory is committed and pushed):

```bash
hermes profile install github.com/<org>/<repo>/distributions/otel-asistani --alias
```

## Configure

After install, fill in API keys:

```bash
cp ~/.hermes/profiles/otel-asistani/.env.EXAMPLE ~/.hermes/profiles/otel-asistani/.env
# Edit .env to add OPENROUTER_API_KEY (or ANTHROPIC_API_KEY) + WhatsApp + ...
```

See `distribution.yaml` `env_requires:` for the full list.

## Update

When `build_distribution.sh` produces a new version (bump version in
`modules/hotel/distribution.yaml`), reinstall:

```bash
hermes profile update otel-asistani
```

User-owned files (`memories/`, `sessions/`, `.env`, `auth.json`) are
preserved across updates.

## References

- Architecture: `docs/ARCHITECTURE.md`
- Product PRD: `docs/PRD-hotel-asistani.md`
