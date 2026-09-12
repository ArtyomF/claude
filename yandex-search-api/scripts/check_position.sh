#!/usr/bin/env bash
# Найти позицию домена в выдаче по запросу.
# Использование: ./check_position.sh "денник для лошади купить" "konix.su"
source "$(dirname "$0")/common.sh"
require_var YANDEX_CLOUD_API_KEY
require_var YANDEX_CLOUD_FOLDER_ID
require_bin python3

QUERY="${1:?Укажите запрос}"
DOMAIN="${2:?Укажите домен для поиска в выдаче, например konix.su}"

log "Получаем выдачу по запросу: $QUERY"

SEARCH_OUTPUT=$("$(dirname "$0")/search.sh" "$QUERY" 2>/dev/null)

if [ -z "$SEARCH_OUTPUT" ]; then
  echo "[ERROR] Не удалось получить выдачу. Запустите search.sh напрямую, чтобы увидеть полную ошибку." >&2
  exit 1
fi

echo "$SEARCH_OUTPUT" | DOMAIN_NEEDLE="$DOMAIN" python3 -c "
import json, sys, os

domain_needle = os.environ['DOMAIN_NEEDLE'].lower().replace('www.', '')

try:
    data = json.load(sys.stdin)
except json.JSONDecodeError:
    print(json.dumps({'error': 'Не удалось разобрать вывод search.sh как JSON'}, ensure_ascii=False))
    sys.exit(1)

results = data.get('results', [])
matches = [r for r in results if domain_needle in (r.get('domain') or '').lower()]

if matches:
    print(json.dumps({
        'domain': domain_needle,
        'found': True,
        'matches': matches,
        'total_results_checked': len(results),
    }, ensure_ascii=False, indent=2))
else:
    print(json.dumps({
        'domain': domain_needle,
        'found': False,
        'message': f'Домен не найден в первых {len(results)} результатах выдачи.',
        'total_results_checked': len(results),
    }, ensure_ascii=False, indent=2))
"
