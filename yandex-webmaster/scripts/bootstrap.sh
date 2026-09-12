#!/usr/bin/env bash
# Определяет USER_ID и HOST_ID и дописывает их в config/.env (один раз при настройке).
source "$(dirname "$0")/common.sh"
require_var YANDEX_WEBMASTER_OAUTH_TOKEN

USER_ID=$(curl -s "https://api.webmaster.yandex.net/v4/user" \
  -H "Authorization: OAuth $YANDEX_WEBMASTER_OAUTH_TOKEN" | jq -r '.user_id')

if [ -z "$USER_ID" ] || [ "$USER_ID" = "null" ]; then
  echo "[ERROR] Не удалось получить user_id. Проверьте токен." >&2
  exit 1
fi

log "USER_ID=$USER_ID"

echo "Доступные сайты (host_id):" >&2
curl -s "https://api.webmaster.yandex.net/v4/user/$USER_ID/hosts" \
  -H "Authorization: OAuth $YANDEX_WEBMASTER_OAUTH_TOKEN" | jq '.hosts[] | {host_id: .host_id, unicode_host_url: .unicode_host_url}'

echo "" >&2
echo "Допишите вручную в config/.env:" >&2
echo "YANDEX_WEBMASTER_USER_ID=$USER_ID" >&2
echo "YANDEX_WEBMASTER_HOST_ID=<выберите host_id из списка выше>" >&2
