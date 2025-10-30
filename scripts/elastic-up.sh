#!/usr/bin/env bash
set -euo pipefail

ASPIRE=false
PULL=false
for arg in "$@"; do
  case "$arg" in
    --aspire) ASPIRE=true ;;
    --pull) PULL=true ;;
  esac
done

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
COMPOSE_DIR="$ROOT_DIR/deploy/observability/elastic"
ENV_FILE="$ROOT_DIR/deploy/.env"

# Resolve project name
PROJECT="${COMPOSE_PROJECT_NAME:-}"
if [[ -z "$PROJECT" && -f "$ENV_FILE" ]]; then
  PROJECT=$(grep -E '^\s*COMPOSE_PROJECT_NAME\s*=\s*' "$ENV_FILE" | sed -E 's/.*=\s*(.+)\s*/\1/' | head -n1)
fi
[[ -z "$PROJECT" ]] && PROJECT="imzaio"

echo "Starting Elastic APM stack... (Aspire=${ASPIRE}, Pull=${PULL})"

pushd "$COMPOSE_DIR" >/dev/null

FILES=( -f docker-compose.yml )
if $ASPIRE; then FILES+=( -f docker-compose.override.aspire.yml ); fi

if $PULL; then docker compose "${FILES[@]}" --project-name "$PROJECT" --env-file ../../.env pull; fi
docker compose "${FILES[@]}" --project-name "$PROJECT" --env-file ../../.env up -d

popd >/dev/null

echo "Elastic APM stack is up."
