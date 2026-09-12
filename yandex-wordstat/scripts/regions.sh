#!/usr/bin/env bash
# Распределение спроса по регионам для фразы.
# Использование: ./regions.sh "денник для лошади купить"
source "$(dirname "$0")/common.sh"
require_var YANDEX_DIRECT_OAUTH_TOKEN

PHRASE="${1:?Укажите фразу первым аргументом}"

log "Региональная разбивка через тот же отчёт Wordstat (поле RegionsNames в ответе)"
log "Используйте popular_queries.sh — регионы приходят в составе того же отчёта."
echo '{"hint": "См. вывод popular_queries.sh — поле с региональной разбивкой включено в стандартный отчёт Wordstat."}' | jq '.'
