# Как получить токен для yandex-metrika

1. https://oauth.yandex.ru/ → зарегистрировать приложение
2. Выбрать scope с доступом к Яндекс.Метрике (API Метрики)
3. Получить токен так же, как для Директа (см. yandex-wordstat/config/README.md)
4. Найти номер счётчика: зайдите на metrika.yandex.ru → выберите сайт →
   номер счётчика виден в URL (`metrika.yandex.ru/dashboard?id=XXXXXXX`) или в настройках счётчика
5. Заполните `config/.env`: `YANDEX_METRIKA_OAUTH_TOKEN` и `YANDEX_METRIKA_COUNTER_ID`

## Проверка токена

```bash
curl -s "https://api-metrika.yandex.net/management/v1/counters" \
  -H "Authorization: OAuth $YANDEX_METRIKA_OAUTH_TOKEN" | jq '.'
```

Должен вернуться список ваших счётчиков.
