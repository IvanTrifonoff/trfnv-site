# trfnv.is-a.dev

Статический сайт для домена `trfnv.is-a.dev`. Хостинг — **Cloudflare Pages**, DNS — **is-a.dev** (зона тоже на Cloudflare).

## Что внутри

| Файл | Назначение |
| --- | --- |
| `index.html` | Главная страница |
| `styles.css` | Стили |
| `404.html` | Страница 404 |
| `_headers` | Заголовки безопасности и кэширования для Cloudflare Pages |
| `is-a-dev/trfnv.json` | Готовый JSON для PR в `is-a-dev/register` (подставь свой Pages-домен) |

Это чистая статика: никаких сборок и зависимостей. Можно открыть `index.html` напрямую или поднять локальный сервер:

```bash
python3 -m http.server 8080
# http://localhost:8080
```

## 1. Деплой на Cloudflare Pages

1. Зайди в [Cloudflare Dashboard](https://dash.cloudflare.com) → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**.
2. Выбери репозиторий `IvanTrifonoff/trfnv-site`.
3. Build settings:
   - **Framework preset:** `None`
   - **Build command:** оставь пустым
   - **Build output directory:** `/` (корень репозитория)
4. **Project name:** `trfnv-site` (тогда дефолтный адрес будет `trfnv-site.pages.dev`).
5. Нажми **Save and Deploy**.

### Добавить кастомный домен

1. В проекте открой вкладку **Custom domains** → **Set up a custom domain**.
2. Введи `trfnv.is-a.dev` → **Continue**. Cloudflare покажет запись вида:
   ```
   CNAME  trfnv  trfnv-site.pages.dev
   ```
3. Пока не нажимай «Deploy/Activate» — сначала добавь запись в is-a.dev (шаг 2), иначе верификация не пройдёт.

## 2. Зарегистрировать домен в is-a.dev

1. Отредактируй [`is-a-dev/trfnv.json`](is-a-dev/trfnv.json) — замени плейсхолдер на реальный адрес проекта:
   ```json
   {
     "owner": { "username": "IvanTrifonoff" },
     "records": { "CNAME": "trfnv-site.pages.dev" },
     "proxied": true
   }
   ```
   > `owner.username` — это аккаунт, который открывает PR. Домен `trfnv.is-a.dev`, а PR идёт от `IvanTrifonoff` — это нормально, но мейнтейнеры могут уточнить причину. Коротко объясни в описании PR, что `trfnv` — твой ник/бренд.

2. Сделай [fork](https://github.com/is-a-dev/register/fork) репозитория `is-a-dev/register`.
3. Скопируй содержимое файла в `domains/trfnv.json` в своём форке.
4. Commit → Push → открой **Pull Request** в `is-a-dev/register`.
5. Дождись мержа (волонтёры, обычно от нескольких часов до 2 дней). Следи за комментариями — если попросят правки, внеси их.
6. После мержа вернись в Cloudflare Pages → **Custom domains** и заверши добавление домена. DNS обновится за несколько минут.

## Полезное

- Документация is-a.dev: <https://docs.is-a.dev/domain-structure/>
- FAQ: <https://docs.is-a.dev/faq/>
- ToS: <https://is-a.dev/terms> — корневой домен должен относиться к разработке ПО (сайт именно такой).
- Если открывается заглушка is-a.dev вместо сайта — это кэш браузера, очисти его.
- CNAME нельзя совмещать с другими записями, **кроме** случая `proxied: true` (у нас именно он).
