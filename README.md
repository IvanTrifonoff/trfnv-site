# trfnv.is-a.dev

Статический сайт для домена `trfnv.is-a.dev`. Хостинг — **Cloudflare Pages**, DNS — **is-a.dev** (зона тоже на Cloudflare).

> 🤖 Агентам и новым контрибьюторам: сначала прочитайте [`AGENTS.md`](AGENTS.md) — там архитектура, конвенции, чеклисты и известные грабли.

## Что внутри

| Файл | Назначение |
| --- | --- |
| `index.html` | Главная страница |
| `styles.css` | Стили |
| `404.html` | Страница 404 |
| `_headers` | Заголовки безопасности и кэширования для Cloudflare Pages |
| `blog/index.html` | Список записей блога |
| `blog/post.html` | Шаблон статьи (Markdown рендерится в браузере через `marked`) |
| `blog/posts.js` | Реестр метаданных записей |
| `blog/posts/*.md` | Сами записи в Markdown |
| `blog/blog.css` | Стили блога |
| `blog/feed.xml` | RSS-лента |
| `is-a-dev/trfnv.json` | Запись для `is-a-dev/register` (CNAME уже реальный) |
| `deploy.sh` | Сборка `dist/` и деплой на Cloudflare Pages через wrangler |
| `.gitignore` | Исключает `dist/` и `.deploy/` |

Это чистая статика: никаких сборок и зависимостей. Можно открыть `index.html` напрямую или поднять локальный сервер:

```bash
python3 -m http.server 8080
# http://localhost:8080
```

## Добавление записи в блог

1. Создай `blog/posts/my-new-post.md` (имя файла = `slug`, только латиница, цифры и дефисы).
2. Добавь объект в `blog/posts.js`:
   ```js
   {
     slug: 'my-new-post',
     title: 'Заголовок записи',
     date: '2026-11-22',
     description: 'Короткое описание для списка и RSS.',
     tags: ['разработка']
   }
   ```
3. Добавь `<item>` в `blog/feed.xml`.
4. Запустить `./deploy.sh` — он соберёт `dist/` и задеплоит на Pages. `git push` сам по себе **не** деплоит (проект не подключён к GitHub).

Ссылка на запись: `/blog/post.html?slug=my-new-post`.

## 1. Деплой на Cloudflare Pages (уже сделано)

Проект `trfnv-site` создан через wrangler, деплой идёт **вручную**, без привязки к GitHub:

```bash
wrangler login                    # один раз
./deploy.sh                       # собрать dist/ и задеплоить
```

- Дефолтный адрес: **https://trfnv-site.pages.dev** (301 по `/blog` → `/blog/` не требуется, оба отвечают 200).
- `dist/` — временная папка, не коммитится (в `.gitignore`).
- Prod-ветка: `main` (`--branch main`).

Если захочешь автодеплой при `git push`: Cloudflare Dashboard → проект `trfnv-site` → **Settings → Builds & deployments → Connect to Git** → репозиторий `IvanTrifonoff/trfnv-site`, output directory `/`. После этого `deploy.sh` можно будет не использовать.

### Добавить кастомный домен (после мержа PR)

```bash
wrangler pages domain add trfnv.is-a.dev --project-name trfnv-site
```

Или через UI: проект → **Custom domains** → **Set up a custom domain** → `trfnv.is-a.dev`.
Cloudflare покажет CNAME `trfnv → trfnv-site.pages.dev` — он уже добавлен в DNS через is-a.dev.

## 2. Домен в is-a.dev (PR уже открыт)

- **PR:** https://github.com/is-a-dev/register/pull/62243
- **Форк:** `IvanTrifonoff/register`, ветка `trfnv-domain`, файл `domains/trfnv.json`
- **Содержимое:**
  ```json
  {
    "owner": { "username": "IvanTrifonoff" },
    "records": { "CNAME": "trfnv-site.pages.dev" },
    "proxied": true
  }
  ```
  > `owner.username` — аккаунт, который открыл PR. Домен `trfnv.is-a.dev`, а PR от `IvanTrifonoff` — это нормально; в описании PR это объяснено (trfnv — ник/бренд).

Все автоматические проверки PR проходят (`Tests`, `Template`, `Label` — pass). В `owner.email` указан реальный адрес `greaf@ya.ru` — GitHub no-reply там запрещён тестами is-a.dev.

**Осталось:** дождаться мержа (волонтёры, обычно от нескольких часов до 3 дней), следить за комментариями, при просьбе правок — внести их в ветке `trfnv-domain` форка. После мержа DNS обновится за несколько минут, затем добавить кастомный домен (см. выше).

## Полезное

- Документация is-a.dev: <https://docs.is-a.dev/domain-structure/>
- FAQ: <https://docs.is-a.dev/faq/>
- ToS: <https://is-a.dev/terms> — корневой домен должен относиться к разработке ПО (сайт именно такой).
- Если открывается заглушка is-a.dev вместо сайта — это кэш браузера, очисти его.
- CNAME нельзя совмещать с другими записями, **кроме** случая `proxied: true` (у нас именно он).
