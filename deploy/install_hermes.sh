#!/bin/bash
# =============================================================================
# install_hermes.sh — Install Hermes Agent on a customer VM
# =============================================================================
#
# Thin wrapper around the official NousResearch installer.
# Installs Python 3.11, Node.js, ripgrep, ffmpeg as side effects.
# Adds 'hermes' to /usr/local/bin.
#
# Usage:
#   bash deploy/install_hermes.sh [--non-interactive]
#
# Verified against: Hermes Agent v0.14.0 (2026.5.16)
# Source: https://github.com/NousResearch/hermes-agent
# =============================================================================

set -euo pipefail

INSTALLER_URL="https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh"

echo "========================================================================="
echo " Hermes Agent — Customer VM Install"
echo "========================================================================="
echo ""
echo " Source : $INSTALLER_URL"
echo " Side effects:"
echo "   - Python 3.11, Node.js, ripgrep, ffmpeg installed if missing"
echo "   - 'hermes' linked into /usr/local/bin"
echo "   - ~/.hermes/ created (config.yaml, skills/, .env, logs/, ...)"
echo ""

# Pre-check: hermes already installed?
if command -v hermes &> /dev/null; then
    INSTALLED_VERSION=$(hermes --version 2>&1 | head -1)
    echo " ⚠ Hermes already installed: $INSTALLED_VERSION"
    echo "   Run 'hermes update' to upgrade, or 'hermes uninstall' to remove first."
    exit 0
fi

# Confirmation (skip with --non-interactive)
if [[ "${1:-}" != "--non-interactive" ]]; then
    read -r -p "Proceed with install? [y/N] " ANSWER
    [[ "${ANSWER:-N}" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
fi

# Run installer
curl -fsSL "$INSTALLER_URL" | bash

# Post-install verification
echo ""
echo "========================================================================="
if command -v hermes &> /dev/null; then
    echo " ✓ Hermes installed: $(hermes --version 2>&1 | head -1)"
    echo ""
    echo " Next steps for this customer VM:"
    echo "   1. Configure API key (choose ONE provider):"
    echo "      • OpenRouter (200+ models, single key, dev-friendly):"
    echo "          echo 'OPENROUTER_API_KEY=sk-or-...' >> ~/.hermes/.env"
    echo "      • Anthropic direct (sovereign-friendly, single-model):"
    echo "          echo 'ANTHROPIC_API_KEY=sk-ant-...' >> ~/.hermes/.env"
    echo "      • Nous Portal OAuth: hermes login"
    echo "      • Interactive wizard: hermes setup"
    echo "   2. Install distribution: hermes profile install <git-url-or-path>"
    echo "                            (see docs/HERMES-INTEGRATION.md)"
    echo "   3. Verify status:        hermes status"
    echo "   4. Start gateway:        hermes whatsapp setup"
else
    echo " ✗ Install failed — 'hermes' not in PATH after install"
    exit 2
fi
echo "========================================================================="
