# Как получить токен для yandex-direct

1. https://oauth.yandex.ru/ → зарегистрировать приложение
2. Выбрать scope с доступом к Яндекс.Директ API
3. Получить токен тем же способом, что описан в `yandex-wordstat/config/README.md`
   (шаги идентичны, `access_token` из URL после авторизации)
4. Вписать в `config/.env` → `YANDEX_DIRECT_OAUTH_TOKEN`

## Проверка токена

```bash
curl -s -X POST https://api.direct.yandex.com/json/v5/campaigns \
  -H "Authorization: Bearer $YANDEX_DIRECT_OAUTH_TOKEN" \
  -H "Accept-Language: ru" \
  -d '{"method":"get","params":{"SelectionCriteria":{},"FieldNames":["Id","Name","Status"]}}'
```
