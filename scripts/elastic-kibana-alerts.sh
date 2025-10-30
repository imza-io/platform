#!/usr/bin/env bash
set -euo pipefail

KIBANA_URL="${1:-http://localhost:5601}"
SERVICE_NAME="${2:-}"
WEBHOOK_URL="${3:-}"
ERROR_THRESHOLD_COUNT="${4:-10}"
LATENCY_MS="${5:-1000}"
WINDOW="${6:-5m}"
INTERVAL="${7:-1m}"

echo "Kibana alerts provisioning... ($KIBANA_URL)"

wait_for_kibana() {
  for i in {1..60}; do
    if curl -s "$KIBANA_URL/api/status" | grep -E 'available|degraded' >/dev/null; then
      return 0
    fi
    sleep 3
  done
  echo "Kibana not ready at $KIBANA_URL" >&2
  exit 1
}

create_webhook_connector() {
  local url="$1"
  if [[ -z "$url" ]]; then echo ""; return 0; fi
  local body
  body=$(jq -n --arg url "$url" '{name:"Generic Webhook",connector_type_id:".webhook",config:{url:$url,method:"post",hasAuth:false},secrets:{}}')
  local id
  id=$(curl -s -H 'kbn-xsrf:true' -H 'Content-Type: application/json' -X POST "$KIBANA_URL/api/actions/connector" -d "$body" | jq -r '.id // empty')
  echo "$id"
}

create_es_query_rule() {
  local name="$1" index="$2" kql="$3" window="$4" interval="$5" threshold="$6" connector_id="$7" body_tpl="$8"
  local params rule
  params=$(jq -n --arg idx "$index" --arg kql "$kql" '{index:[$idx],timeField:"@timestamp",esQuery:{query:$kql,language:"kuery"},size:100,threshold:[0],thresholdComparator:">"}')
  params=$(echo "$params" | jq --argjson thr "$threshold" '.threshold=[ $thr ]')
  rule=$(jq -n --arg name "$name" --arg interval "$interval" '{name:$name,rule_type_id:".es-query",consumer:"alerts",tags:["apm","otel","auto"],notify_when:"onActionGroupChange",schedule:{interval:$interval}}')
  rule=$(echo "$rule" | jq --argjson params "$params" '.params=$params')
  rule=$(echo "$rule" | jq --arg window "$window" '.throttle=$window')
  if [[ -n "$connector_id" ]]; then
    local action
    action=$(jq -n --arg id "$connector_id" --arg body "$body_tpl" '{group:"query matched",id:$id,params:{body:$body}}')
    rule=$(echo "$rule" | jq --argjson acts "[$action]" '.actions=$acts')
  else
    rule=$(echo "$rule" | jq '.actions=[]')
  fi
  curl -s -H 'kbn-xsrf:true' -H 'Content-Type: application/json' -X POST "$KIBANA_URL/api/alerting/rule" -d "$rule" >/dev/null
  echo "Created rule: $name"
}

command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

wait_for_kibana

CONNECTOR_ID=""
if [[ -n "$WEBHOOK_URL" ]]; then
  CONNECTOR_ID=$(create_webhook_connector "$WEBHOOK_URL")
fi

SVC_FILTER=""
[[ -n "$SERVICE_NAME" ]] && SVC_FILTER=" and service.name : \"$SERVICE_NAME\""

# Error count rule
ERROR_KQL="event.outcome : failure${SVC_FILTER}"
ERROR_BODY="APM Error count exceeded. Rule: {{context.rule.name}}"
create_es_query_rule "APM Error Count${SERVICE_NAME:+ ($SERVICE_NAME)}" "traces-apm*" "$ERROR_KQL" "$WINDOW" "$INTERVAL" "$ERROR_THRESHOLD_COUNT" "$CONNECTOR_ID" "$ERROR_BODY"

# Latency rule (transactions over threshold)
DURATION_US=$(( LATENCY_MS * 1000 ))
LATENCY_KQL="transaction.duration.us >= $DURATION_US${SVC_FILTER}"
LATENCY_BODY="APM Latency exceeded ${LATENCY_MS}ms. Rule: {{context.rule.name}}"
create_es_query_rule "APM Latency >= ${LATENCY_MS}ms${SERVICE_NAME:+ ($SERVICE_NAME)}" "traces-apm*" "$LATENCY_KQL" "$WINDOW" "$INTERVAL" 0 "$CONNECTOR_ID" "$LATENCY_BODY"

echo "Kibana alerts provisioning completed."

