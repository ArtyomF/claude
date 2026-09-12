#!/usr/bin/env bash
# Поставить URL в очередь на переобход.
# Использование: ./recheck_url.sh "https://konix.su/news/novaya-statya"
source "$(dirname "$0")/common.sh"
require_var YANDEX_WEBMASTER_OAUTH_TOKEN
require_var YANDEX_WEBMASTER_USER_ID
require_var YANDEX_WEBMASTER_HOST_ID

URL="${1:?Укажите полный URL страницы}"

PAYLOAD=$(jq -n --arg url "$URL" '{url: $url}')

curl -s -X PUT \
  "https://api.webmaster.yandex.net/v4/user/$YANDEX_WEBMASTER_USER_ID/hosts/$YANDEX_WEBMASTER_HOST_ID/recrawl/queue" \
  -H "Authorization: OAuth $YANDEX_WEBMASTER_OAUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" | jq '.'
