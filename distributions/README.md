# distributions/ — Built Hermes Profile Distributions

This directory is the **build target** for `deploy/build_distribution.sh`.
Each subdirectory here is an **assembled, install-ready** Hermes profile
distribution.

**These files are build artefacts.** Do not edit them directly — they get
regenerated every time `build_distribution.sh` runs. Edit the source instead:

- `core/skills/` — L1 shared office skills
- `general/skills/` — L2 shared SME skills
- `modules/<vertical>/` — L3 vertical metadata + skills

## Building

```bash
# Build the Otel Asistanı distribution
bash deploy/build_distribution.sh hotel

# Build the Acente Asistanı distribution
bash deploy/build_distribution.sh acente
```

Output:

```
distributions/
├── otel-asistani/
│   ├── distribution.yaml
│   ├── SOUL.md
│   ├── config.yaml
│   ├── mcp.json
│   ├── README.md
│   ├── cron/
│   └── skills/
│       ├── <skill-name>/SKILL.md  ← from core/general/modules
│       └── ...
└── acente-asistani/
    └── (same structure)
```

## Installing

```bash
hermes profile install /path/to/distributions/otel-asistani --name <customer-slug> --alias
```

Or directly from a git remote (after committing distributions/):

```bash
hermes profile install github.com/akuyucu-claude/ceo-asistani/distributions/otel-asistani --alias
```

## Why these are committed

We commit built distributions because:

1. **Git-installable** — `hermes profile install <git-url>` works only if
   the distribution is at a stable git path.
2. **Reproducibility** — a customer's deployed version is pinnable to a
   specific commit SHA.
3. **Audit trail** — easy to diff what shipped to a customer over time.

But because they're build artefacts, **all changes here should come from
running `build_distribution.sh`, not manual edits.** A pre-commit hook (TODO)
will eventually verify this.

## Architecture reference

See `docs/ARCHITECTURE.md` §3, §11.
See `docs/HERMES-INTEGRATION.md` for the full integration model.
