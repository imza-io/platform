#!/usr/bin/env bash
set -euo pipefail

# Installs OpenSSL on macOS via Homebrew.
# Usage: ./scripts/openssl-install-macos.sh

if ! command -v brew >/dev/null 2>&1; then
  echo "[ERR] Homebrew not found. Install from https://brew.sh first." >&2
  exit 1
fi

echo "[INFO] Installing openssl@3 via Homebrew..."
brew install openssl@3

OPENSSL_PREFIX=$(brew --prefix openssl@3)
echo "[OK] Installed. To use in PATH, add to your shell rc:"
echo "    echo 'export PATH=\"${OPENSSL_PREFIX}/bin:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"

