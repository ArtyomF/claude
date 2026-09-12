#!/usr/bin/env bash
# Статистика по кампании за период через Reports API.
# Использование: ./get_stats.sh <campaign_id> <YYYY-MM-DD> <YYYY-MM-DD>
source "$(dirname "$0")/common.sh"
require_var YANDEX_DIRECT_OAUTH_TOKEN

CAMPAIGN_ID="${1:?Укажите ID кампании}"
DATE_FROM="${2:?Укажите дату начала YYYY-MM-DD}"
DATE_TO="${3:?Укажите дату конца YYYY-MM-DD}"

PAYLOAD=$(jq -n \
  --argjson cid "$CAMPAIGN_ID" --arg df "$DATE_FROM" --arg dt "$DATE_TO" \
  '{params:{SelectionCriteria:{Filter:[{Field:"CampaignId",Operator:"EQUALS",Values:[$cid]}], DateFrom:$df, DateTo:$dt}, FieldNames:["Date","Impressions","Clicks","Cost"], ReportName:("stats_" + $df + "_" + $dt), ReportType:"CUSTOM_REPORT", DateRangeType:"CUSTOM_DATE", Format:"TSV", IncludeVAT:"YES"}}')

curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" \
  -H "Authorization: Bearer $YANDEX_DIRECT_OAUTH_TOKEN" \
  -H "Accept-Language: ru" -H "processingMode: auto" -H "returnMoneyInMicros: false" \
  -d "$PAYLOAD"
