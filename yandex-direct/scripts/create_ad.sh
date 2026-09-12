#!/usr/bin/env bash
# Создать текстовое объявление (черновик). ТРЕБУЕТ ручной проверки перед запуском показов.
# Использование: ./create_ad.sh <ad_group_id> "<заголовок>" "<текст>" "<ссылка>"
source "$(dirname "$0")/common.sh"
require_var YANDEX_DIRECT_OAUTH_TOKEN

AD_GROUP_ID="${1:?Укажите ID группы объявлений}"
TITLE="${2:?Укажите заголовок}"
TEXT="${3:?Укажите текст объявления}"
HREF="${4:?Укажите ссылку}"

log "⚠️  Создаём ЧЕРНОВИК объявления. Проверьте параметры перед запуском показов вручную."

PAYLOAD=$(jq -n \
  --argjson agid "$AD_GROUP_ID" --arg title "$TITLE" --arg text "$TEXT" --arg href "$HREF" \
  '{method:"add", params:{Ads:[{AdGroupId:$agid, TextAd:{Title:$title, Text:$text, Href:$href}}]}}')

curl -s -X POST "https://api.direct.yandex.com/json/v5/ads" \
  -H "Authorization: Bearer $YANDEX_DIRECT_OAUTH_TOKEN" -H "Accept-Language: ru" \
  -d "$PAYLOAD" | jq '.'
