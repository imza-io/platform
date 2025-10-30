#!/usr/bin/env bash
set -euo pipefail

KIBANA_URL="${1:-http://localhost:5601}"
NAME="${2:-SMTP Email}"
FROM_ADDR="${3:-}"
SMTP_HOST="${4:-}"
SMTP_PORT="${5:-587}"
SECURE="${6:-false}"
SMTP_USER="${7:-}"
SMTP_PASS="${8:-}"
TO_LIST="${9:-}"

if [[ -z "$FROM_ADDR" || -z "$SMTP_HOST" || -z "$SMTP_USER" || -z "$SMTP_PASS" || -z "$TO_LIST" ]]; then
  echo "Kullanım: $0 <kibanaUrl> <name> <from> <smtp-host> <smtp-port> <secure:true|false> <user> <pass> <to-comma-separated>" >&2
  exit 1
fi

wait_for_kibana() {
  for i in {1..60}; do
    if curl -s "$KIBANA_URL/api/status" | grep -E 'available|degraded' >/dev/null; then return 0; fi
    sleep 2
  done
  echo "Kibana not ready at $KIBANA_URL" >&2
  exit 1
}

command -v jq >/dev/null || { echo "jq gerekli" >&2; exit 1; }

wait_for_kibana

PAYLOAD=$(jq -n --arg name "$NAME" --arg from "$FROM_ADDR" --arg host "$SMTP_HOST" --argjson port "$SMTP_PORT" --argjson secure "$SECURE" --arg user "$SMTP_USER" --arg pass "$SMTP_PASS" '{name:$name,connector_type_id:".email",config:{from:$from,service:"other",host:$host,port:$port,secure:$secure},secrets:{user:$user,password:$pass}}')

RES=$(curl -s -H 'kbn-xsrf:true' -H 'Content-Type: application/json' -X POST "$KIBANA_URL/api/actions/connector" -d "$PAYLOAD")
ID=$(echo "$RES" | jq -r '.id // empty')
if [[ -z "$ID" ]]; then echo "Connector oluşturulamadı" >&2; echo "$RES"; exit 1; fi

echo "Email connector created: $ID"
echo "Use this connector id with alerts. To: $TO_LIST"

