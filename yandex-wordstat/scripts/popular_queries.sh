#!/usr/bin/env bash
# Получить частотность и похожие запросы по фразе.
# Использование: ./popular_queries.sh "денник для лошади" [regions_json_array]
# Пример regions: '[213]' (213 = Москва). Пусто = вся Россия.

source "$(dirname "$0")/common.sh"
require_var YANDEX_DIRECT_OAUTH_TOKEN

PHRASE="${1:?Укажите фразу первым аргументом}"
REGIONS="${2:-[]}"

API_URL="https://api.direct.yandex.ru/live/v4/json/"
if [ "${YANDEX_DIRECT_ENV:-production}" = "sandbox" ]; then
  API_URL="https://api-sandbox.direct.yandex.ru/live/v4/json/"
fi

log "Ставим отчёт в очередь для фразы: $PHRASE"

CREATE_PAYLOAD=$(jq -n \
  --arg method "CreateNewWordstatReport" \
  --arg token "$YANDEX_DIRECT_OAUTH_TOKEN" \
  --arg phrase "$PHRASE" \
  --argjson regions "$REGIONS" \
  '{method: $method, token: $token, param: {Phrases: [$phrase], GeoID: $regions}}')

REPORT_ID=$(curl -s -X POST "$API_URL" -d "$CREATE_PAYLOAD" | jq -r '.data // empty')

if [ -z "$REPORT_ID" ]; then
  echo "[ERROR] Не удалось создать отчёт. Проверьте токен и доступ к Wordstat API." >&2
  exit 1
fi

log "ReportID=$REPORT_ID, ждём готовности отчёта..."

RESULT=""
for i in $(seq 1 20); do
  sleep 3
  GET_PAYLOAD=$(jq -n --arg method "GetWordstatReport" --arg token "$YANDEX_DIRECT_OAUTH_TOKEN" --argjson id "$REPORT_ID" \
    '{method: $method, token: $token, param: [$id]}')
  RESPONSE=$(curl -s -X POST "$API_URL" -d "$GET_PAYLOAD")
  if echo "$RESPONSE" | jq -e '.data' >/dev/null 2>&1; then
    RESULT="$RESPONSE"
    break
  fi
  log "Отчёт ещё не готов (попытка $i/20)..."
done

# Чистим за собой
DELETE_PAYLOAD=$(jq -n --arg method "DeleteWordstatReport" --arg token "$YANDEX_DIRECT_OAUTH_TOKEN" --argjson id "$REPORT_ID" \
  '{method: $method, token: $token, param: $id}')
curl -s -X POST "$API_URL" -d "$DELETE_PAYLOAD" >/dev/null || true

if [ -z "$RESULT" ]; then
  echo "[ERROR] Отчёт не собрался за отведённое время. Попробуйте снова позже." >&2
  exit 1
fi

echo "$RESULT" | jq '.'
