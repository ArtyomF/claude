#!/usr/bin/env bash
# Конверсии по конкретной цели за период.
# Использование: ./goals.sh <YYYY-MM-DD> <YYYY-MM-DD> <goal_id>
source "$(dirname "$0")/common.sh"
require_var YANDEX_METRIKA_OAUTH_TOKEN
require_var YANDEX_METRIKA_COUNTER_ID

DATE_FROM="${1:?Укажите дату начала YYYY-MM-DD}"
DATE_TO="${2:?Укажите дату конца YYYY-MM-DD}"
GOAL_ID="${3:?Укажите ID цели}"

curl -s -G "https://api-metrika.yandex.net/stat/v1/data" \
  -H "Authorization: OAuth $YANDEX_METRIKA_OAUTH_TOKEN" \
  --data-urlencode "ids=$YANDEX_METRIKA_COUNTER_ID" \
  --data-urlencode "date1=$DATE_FROM" \
  --data-urlencode "date2=$DATE_TO" \
  --data-urlencode "metrics=ym:s:goal${GOAL_ID}reaches,ym:s:goal${GOAL_ID}conversionRate" \
  --data-urlencode "dimensions=ym:s:UTMSource,ym:s:UTMCampaign" \
  | jq '.'
