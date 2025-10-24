#!/usr/bin/env bash
set -euo pipefail

# Installs OpenSSL on common Linux distros.
# Usage: ./scripts/openssl-install-linux.sh

if command -v apt-get >/dev/null 2>&1; then
  echo "[INFO] Detected Debian/Ubuntu. Installing openssl..."
  sudo apt-get update -y
  sudo apt-get install -y openssl
elif command -v dnf >/dev/null 2>&1; then
  echo "[INFO] Detected Fedora/RHEL (dnf). Installing openssl..."
  sudo dnf install -y openssl
elif command -v yum >/dev/null 2>&1; then
  echo "[INFO] Detected CentOS/RHEL (yum). Installing openssl..."
  sudo yum install -y openssl
elif command -v zypper >/dev/null 2>&1; then
  echo "[INFO] Detected openSUSE. Installing openssl..."
  sudo zypper install -y openssl
else
  echo "[ERR] Could not detect package manager. Install 'openssl' package manually." >&2
  exit 2
fi

echo "[OK] Installation finished. Run 'openssl version' to verify."

