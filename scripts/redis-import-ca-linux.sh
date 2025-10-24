#!/usr/bin/env bash
set -euo pipefail

# Imports CA cert into Linux trust store (Debian/Ubuntu or RHEL/CentOS/Fedora).
# Usage: ./scripts/redis-import-ca-linux.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CA_PATH="${SCRIPT_DIR}/../deploy/redis/tls/ca.crt"

if [[ ! -f "${CA_PATH}" ]]; then
  echo "[ERR] CA not found: ${CA_PATH}. Run ./scripts/redis-gencerts.ps1 first." >&2
  exit 1
fi

if command -v update-ca-certificates >/dev/null 2>&1; then
  DEST="/usr/local/share/ca-certificates/redis-ca.crt"
  echo "[INFO] Detected Debian/Ubuntu. Copying to ${DEST} (sudo)..."
  sudo cp "${CA_PATH}" "${DEST}"
  echo "[INFO] Updating CA certificates..."
  sudo update-ca-certificates
  echo "[OK] CA imported."
elif command -v update-ca-trust >/dev/null 2>&1; then
  DEST="/etc/pki/ca-trust/source/anchors/redis-ca.crt"
  echo "[INFO] Detected RHEL/CentOS/Fedora. Copying to ${DEST} (sudo)..."
  sudo cp "${CA_PATH}" "${DEST}"
  echo "[INFO] Updating CA trust..."
  sudo update-ca-trust
  echo "[OK] CA imported."
else
  echo "[ERR] Could not detect CA update tool. Please import CA manually for your distro." >&2
  exit 2
fi

