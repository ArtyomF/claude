#!/usr/bin/env bash
# Объявления в кампании.
# Использование: ./get_ads.sh <campaign_id>
source "$(dirname "$0")/common.sh"
require_var YANDEX_DIRECT_OAUTH_TOKEN

CAMPAIGN_ID="${1:?Укажите ID кампании}"

PAYLOAD=$(jq -n --argjson cid "$CAMPAIGN_ID" \
  '{method:"get", params:{SelectionCriteria:{CampaignIds:[$cid]}, FieldNames:["Id","CampaignId","AdGroupId","Status"], TextAdFieldNames:["Title","Text","Href"]}}')

curl -s -X POST "https://api.direct.yandex.com/json/v5/ads" \
  -H "Authorization: Bearer $YANDEX_DIRECT_OAUTH_TOKEN" -H "Accept-Language: ru" \
  -d "$PAYLOAD" | jq '.'
