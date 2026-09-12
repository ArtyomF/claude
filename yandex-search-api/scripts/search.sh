#!/usr/bin/env bash
# Получить выдачу Яндекса по запросу.
# Использование: ./search.sh "денник для лошади купить"
source "$(dirname "$0")/common.sh"
require_var YANDEX_CLOUD_API_KEY
require_var YANDEX_CLOUD_FOLDER_ID

QUERY="${1:?Укажите поисковый запрос}"

PAYLOAD=$(jq -n --arg q "$QUERY" --arg folder "$YANDEX_CLOUD_FOLDER_ID" \
  '{query:{searchType:"SEARCH_TYPE_RU", queryText:$q}, folderId:$folder}')

log "Отправляем запрос в Yandex Search API..."
log "⚠️ Ответ обычно приходит в виде base64-encoded XML — распаковка потребуется отдельно."

curl -s -X POST "https://searchapi.api.cloud.yandex.net/v2/web/searchAsync" \
  -H "Authorization: Api-Key $YANDEX_CLOUD_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" | jq '.'
