#!/usr/bin/env bash
set -euo pipefail

KIBANA_URL="${1:-http://localhost:5601}"
echo "Kibana provisioning starting... ($KIBANA_URL)"

wait_for_kibana() {
  for i in {1..60}; do
    if curl -s "$KIBANA_URL/api/status" | grep -E 'available|degraded' >/dev/null; then
      echo "Kibana is up"
      return 0
    fi
    sleep 3
  done
  echo "Kibana not ready at $KIBANA_URL" >&2
  exit 1
}

create_data_view() {
  local title="$1" name="$2" timefield="${3:-@timestamp}"
  local body
  body=$(jq -n --arg title "$title" --arg name "$name" --arg tf "$timefield" '{data_view:{title:$title,name:$name,timeFieldName:$tf}}')
  local res
  set +e
  res=$(curl -s -H 'kbn-xsrf:true' -H 'Content-Type: application/json' -X POST "$KIBANA_URL/api/data_views/data_view" -d "$body")
  local code=$?
  set -e
  if [[ $code -ne 0 || -z "$res" ]]; then
    echo "Failed to create data view $name" >&2
    exit 1
  fi
  local id
  id=$(echo "$res" | jq -r '.data_view.id // empty')
  if [[ -z "$id" ]]; then
    id=$(curl -s -H 'kbn-xsrf:true' "$KIBANA_URL/api/data_views/data_view" | jq -r --arg title "$title" '.data_views[] | select(.title==$title) | .id' | head -n1)
    echo "Data view exists: $name -> $id"
  else
    echo "Created data view: $name -> $id"
  fi
  echo "$id"
}

set_default_data_view() {
  local id="$1"
  curl -s -H 'kbn-xsrf:true' -H 'Content-Type: application/json' -X POST "$KIBANA_URL/api/data_views/default" -d "{\"data_view_id\":\"$id\"}" >/dev/null
  echo "Default data view set -> $id"
}

command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

wait_for_kibana

TRACES_ID=$(create_data_view 'traces-apm*' 'APM Traces')
METRICS_ID=$(create_data_view 'metrics-apm*' 'APM Metrics')
LOGS_ID=$(create_data_view 'logs-apm*' 'APM Logs')

set_default_data_view "$TRACES_ID"

echo "Kibana provisioning completed."

