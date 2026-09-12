#!/usr/bin/env bash
# Получить выдачу Яндекса по запросу.
# Использование: ./search.sh "денник для лошади купить"
source "$(dirname "$0")/common.sh"
require_var YANDEX_CLOUD_API_KEY
require_var YANDEX_CLOUD_FOLDER_ID

QUERY="${1:?Укажите поисковый запрос}"

# Пишем тело запроса во временный файл — так кириллица не ломается через
# консоль Windows/Git Bash, которая иногда некорректно кодирует прямой ввод.
TMP_PAYLOAD="$(mktemp)"
trap 'rm -f "$TMP_PAYLOAD"' EXIT

jq -n --arg q "$QUERY" --arg folder "$YANDEX_CLOUD_FOLDER_ID" \
  '{query:{searchType:"SEARCH_TYPE_RU", queryText:$q}, folderId:$folder}' > "$TMP_PAYLOAD"

log "Отправляем асинхронный запрос в Yandex Search API..."

RESPONSE=$(curl -s -X POST "https://searchapi.api.cloud.yandex.net/v2/web/searchAsync" \
  -H "Authorization: Api-Key $YANDEX_CLOUD_API_KEY" \
  -H "Content-Type: application/json" \
  --data @"$TMP_PAYLOAD")

OP_ID=$(echo "$RESPONSE" | jq -r '.id // empty')

if [ -z "$OP_ID" ]; then
  echo "[ERROR] Не удалось создать операцию поиска. Ответ Яндекса:" >&2
  echo "$RESPONSE" | jq '.' >&2
  exit 1
fi

log "Операция создана: $OP_ID. Ждём готовности результата..."

for i in $(seq 1 15); do
  sleep 2
  RESULT=$(curl -s "https://operation.api.cloud.yandex.net/operations/$OP_ID" \
    -H "Authorization: Api-Key $YANDEX_CLOUD_API_KEY")
  DONE=$(echo "$RESULT" | jq -r '.done // false')
  if [ "$DONE" = "true" ]; then
    log "Результат готов. Разбираем XML-выдачу..."

    RAW_DATA=$(echo "$RESULT" | jq -r '.response.rawData // empty')

    if [ -z "$RAW_DATA" ]; then
      echo "[ERROR] В ответе нет поля response.rawData. Полный ответ:" >&2
      echo "$RESULT" | jq '.' >&2
      exit 1
    fi

    if command -v python3 >/dev/null 2>&1; then
      echo "$RAW_DATA" | python3 "$(dirname "$0")/parse_results.py"
    else
      log "⚠️ python3 не найден — вывожу необработанный ответ. Установите Python 3, чтобы получать чистый список сайтов вместо base64."
      echo "$RESULT" | jq '.'
    fi
    exit 0
  fi
  log "Ещё не готово (попытка $i/15)..."
done

echo "[ERROR] Результат не собрался за отведённое время. Проверьте вручную:" >&2
echo "curl -s https://operation.api.cloud.yandex.net/operations/$OP_ID -H \"Authorization: Api-Key \$YANDEX_CLOUD_API_KEY\"" >&2
exit 1
