#!/usr/bin/env bash
# Список кампаний аккаунта.
source "$(dirname "$0")/common.sh"
require_var YANDEX_DIRECT_OAUTH_TOKEN

HEADERS=(-H "Authorization: Bearer $YANDEX_DIRECT_OAUTH_TOKEN" -H "Accept-Language: ru")
if [ -n "${YANDEX_DIRECT_CLIENT_LOGIN:-}" ]; then
  HEADERS+=(-H "Client-Login: $YANDEX_DIRECT_CLIENT_LOGIN")
fi

PAYLOAD='{"method":"get","params":{"SelectionCriteria":{},"FieldNames":["Id","Name","Status","State","DailyBudget"]}}'

curl -s -X POST "https://api.direct.yandex.com/json/v5/campaigns" \
  "${HEADERS[@]}" -d "$PAYLOAD" | jq '.'
