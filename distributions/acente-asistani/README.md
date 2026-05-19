# acente-asistani — Hermes Profile Distribution

Built by `deploy/build_distribution.sh acente` at 2026-05-19T17:49:14+00:00.

This is an **assembled, install-ready** Hermes profile distribution.
Do not edit files here directly — they will be regenerated on next build.
Source lives at:

- `core/` — L1 shared office skills
- `general/` — L2 shared SME skills
- `modules/acente/` — L3 vertical-specific skills + distribution metadata

## Install

```bash
hermes profile install /home/user/ceo-asistani/distributions/acente-asistani --alias
```

…or from a git remote (if this directory is committed and pushed):

```bash
hermes profile install github.com/<org>/<repo>/distributions/acente-asistani --alias
```

## Configure

After install, fill in API keys:

```bash
cp ~/.hermes/profiles/acente-asistani/.env.EXAMPLE ~/.hermes/profiles/acente-asistani/.env
# Edit .env to add OPENROUTER_API_KEY (or ANTHROPIC_API_KEY) + WhatsApp + ...
```

See `distribution.yaml` `env_requires:` for the full list.

## Update

When `build_distribution.sh` produces a new version (bump version in
`modules/acente/distribution.yaml`), reinstall:

```bash
hermes profile update acente-asistani
```

User-owned files (`memories/`, `sessions/`, `.env`, `auth.json`) are
preserved across updates.

## References

- Architecture: `docs/ARCHITECTURE.md`
- Product PRD: `docs/PRD-acente-asistani.md`
