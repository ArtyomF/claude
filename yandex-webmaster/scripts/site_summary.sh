#!/usr/bin/env bash
# Общая сводка по сайту — проиндексированные страницы и ошибки.
source "$(dirname "$0")/common.sh"
require_var YANDEX_WEBMASTER_OAUTH_TOKEN
require_var YANDEX_WEBMASTER_USER_ID
require_var YANDEX_WEBMASTER_HOST_ID

log "Сводка по индексации:"
curl -s "https://api.webmaster.yandex.net/v4/user/$YANDEX_WEBMASTER_USER_ID/hosts/$YANDEX_WEBMASTER_HOST_ID/summary" \
  -H "Authorization: OAuth $YANDEX_WEBMASTER_OAUTH_TOKEN" | jq '.'
