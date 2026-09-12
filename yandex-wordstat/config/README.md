# Как получить токен для yandex-wordstat

1. Зайдите на https://oauth.yandex.ru/
2. Нажмите "Зарегистрировать новое приложение"
3. В разделе доступов (Scopes) выберите права, связанные с Яндекс.Директ
   (`direct:api` — точное имя скоупа уточните в актуальном списке на странице создания приложения)
4. Получите Client ID приложения
5. Перейдите по ссылке вида:
   `https://oauth.yandex.ru/authorize?response_type=token&client_id=ВАШ_CLIENT_ID`
6. Разрешите доступ — вас перебросит на страницу с токеном в URL (`#access_token=...`)
7. Скопируйте токен в `config/.env` → `YANDEX_DIRECT_OAUTH_TOKEN`

## Доступ к Wordstat отдельно

Обычного OAuth-токена Директа может быть недостаточно — доступ к методам Wordstat
(`CreateNewWordstatReport` и др.) выдаётся модерацией Яндекса отдельно.
Подайте заявку в личном кабинете Яндекс.Директа или через поддержку — обычно рассматривают
за несколько рабочих дней.

## Проверка токена

```bash
curl -s -X POST https://api.direct.yandex.ru/live/v4/json/ \
  -d '{"method":"AccountManagers","token":"'"$YANDEX_DIRECT_OAUTH_TOKEN"'"}'
```

Если вернулся JSON без ошибки авторизации — токен рабочий.
