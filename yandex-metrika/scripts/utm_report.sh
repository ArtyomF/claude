#!/usr/bin/env bash
# Разбивка визитов по UTM-меткам за период.
# Использование: ./utm_report.sh <YYYY-MM-DD> <YYYY-MM-DD>
source "$(dirname "$0")/common.sh"
require_var YANDEX_METRIKA_OAUTH_TOKEN
require_var YANDEX_METRIKA_COUNTER_ID

DATE_FROM="${1:?Укажите дату начала YYYY-MM-DD}"
DATE_TO="${2:?Укажите дату конца YYYY-MM-DD}"

curl -s -G "https://api-metrika.yandex.net/stat/v1/data" \
  -H "Authorization: OAuth $YANDEX_METRIKA_OAUTH_TOKEN" \
  --data-urlencode "ids=$YANDEX_METRIKA_COUNTER_ID" \
  --data-urlencode "date1=$DATE_FROM" \
  --data-urlencode "date2=$DATE_TO" \
  --data-urlencode "metrics=ym:s:visits,ym:s:goalReachesAny" \
  --data-urlencode "dimensions=ym:s:UTMSource,ym:s:UTMMedium,ym:s:UTMCampaign" \
  --data-urlencode "sort=-ym:s:visits" \
  | jq '.'
