# Как получить доступ для yandex-search-api

1. Зарегистрируйтесь в https://cloud.yandex.ru/ (понадобится привязать способ оплаты — сервис платный)
2. Создайте каталог (folder) в консоли — скопируйте `Folder ID`
3. Создайте сервисный аккаунт: IAM → Сервисные аккаунты → Создать
4. Выдайте сервисному аккаунту роль с доступом к Search API (уточните точное имя роли
   в актуальной документации Yandex Cloud на момент настройки)
5. Создайте API-ключ для сервисного аккаунта: раздел "API-ключи" → Создать
6. Заполните `config/.env`:
   - `YANDEX_CLOUD_API_KEY` — созданный API-ключ
   - `YANDEX_CLOUD_FOLDER_ID` — ID каталога

## Проверка ключа

```bash
curl -s -X POST "https://searchapi.api.cloud.yandex.net/v2/web/searchAsync" \
  -H "Authorization: Api-Key $YANDEX_CLOUD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":{"searchType":"SEARCH_TYPE_RU","queryText":"тест"},"folderId":"'"$YANDEX_CLOUD_FOLDER_ID"'"}'
```

Точный путь эндпоинта (`searchAsync` вместо синхронного `search`) и формат тела запроса
могут отличаться от актуальной версии API — сверьтесь с документацией Yandex Cloud
непосредственно перед использованием, так как Search API периодически меняет контракт.
