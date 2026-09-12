#!/usr/bin/env bash
# Остаток квоты на переобход за сутки.
source "$(dirname "$0")/common.sh"
require_var YANDEX_WEBMASTER_OAUTH_TOKEN
require_var YANDEX_WEBMASTER_USER_ID
require_var YANDEX_WEBMASTER_HOST_ID

curl -s "https://api.webmaster.yandex.net/v4/user/$YANDEX_WEBMASTER_USER_ID/hosts/$YANDEX_WEBMASTER_HOST_ID/recrawl/queue/quota" \
  -H "Authorization: OAuth $YANDEX_WEBMASTER_OAUTH_TOKEN" | jq '.'
