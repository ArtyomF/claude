# Как получить токен для yandex-webmaster

1. https://oauth.yandex.ru/ → зарегистрировать приложение → scope с доступом к Вебмастеру
2. Получить токен так же, как для Директа/Метрики
3. Сайт должен быть добавлен и подтверждён в https://webmaster.yandex.ru заранее (вручную, один раз)
4. Заполните `config/.env` → `YANDEX_WEBMASTER_OAUTH_TOKEN`
5. Запустите `scripts/bootstrap.sh` — он определит `USER_ID` и `HOST_ID` автоматически и допишет их в `.env`

## Проверка токена

```bash
curl -s "https://api.webmaster.yandex.net/v4/user" \
  -H "Authorization: OAuth $YANDEX_WEBMASTER_OAUTH_TOKEN" | jq '.'
```
