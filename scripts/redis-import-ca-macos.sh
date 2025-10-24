#!/usr/bin/env bash
set -euo pipefail

# Imports CA cert into macOS System keychain as trusted root.
# Usage: ./scripts/redis-import-ca-macos.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CA_PATH="${SCRIPT_DIR}/../deploy/redis/tls/ca.crt"

if [[ ! -f "${CA_PATH}" ]]; then
  echo "[ERR] CA not found: ${CA_PATH}. Run ./scripts/redis-gencerts.ps1 first." >&2
  exit 1
fi

echo "[INFO] Importing CA into System keychain (sudo required)..."
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "${CA_PATH}"
echo "[OK] CA imported. You may need to restart apps using TLS."

