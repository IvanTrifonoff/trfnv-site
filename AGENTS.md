# AGENTS.md — ориентир по репозиторию

> This file is for AI agents and new contributors. Read it before making changes.
> TL;DR: zero-build static site for `trfnv.is-a.dev`, hosted on Cloudflare Pages,
> DNS via a PR to `is-a-dev/register`. Blog posts are Markdown + a JS registry.

---

## 1. Что это за проект

Статический сайт-визитка + блог для домена **`trfnv.is-a.dev`**.

| Параметр | Значение |
| --- | --- |
| GitHub-репозиторий | `IvanTrifonoff/trfnv-site` (ветка `main`) |
| GitHub-аккаунт владельца PR | `IvanTrifonoff` |
| Желаемый домен | `trfnv.is-a.dev` (ROOT, не вложенный!) |
| Хостинг | Cloudflare Pages, проект `trfnv-site` → `trfnv-site.pages.dev` (живой, HTTP 200) |
| DNS | is-a.dev, зона лежит на Cloudflare |
| Сборка | **отсутствует** — чистый HTML/CSS/JS; деплой вручную через `./deploy.sh` (wrangler) |
| PR на домен | https://github.com/is-a-dev/register/pull/62243 (открыт, ожидает ревью) |
| Форк для PR | `IvanTrifonoff/register`, ветка `trfnv-domain` |

Ключевое ограничение is-a.dev: **корневой домен должен быть связан с разработкой ПО** (см. ToS). Поэтому контент сделан dev-ориентированным. NS-записи новичкам не дают — не propose их.

### Важное несовпадение имён

Домен `trfnv.is-a.dev`, но GitHub-логин — `IvanTrifonoff`. В `is-a-dev/trfnv.json` поле `owner.username` обязано быть `IvanTrifonoff`, потому что PR открывает этот аккаунт. Если менять аккаунт на `trfnv`, нужно залогиниться под ним и переоткрыть PR.

---

## 2. Карта файлов

```
.
├── AGENTS.md              ← ты здесь
├── README.md              ← человекочитаемая инструкция по деплою
├── deploy.sh              ← собрать dist/ и задеплоить через wrangler
├── .gitignore             ← dist/ и .deploy/ не коммитим
├── index.html             ← главная (лендинг)
├── styles.css             ← общая тема, переменные, компоненты, адаптив
├── 404.html               ← страница 404 (стили подключены относительно)
├── _headers               ← Cloudflare Pages: security headers + cache CSS
├── is-a-dev/
│   └── trfnv.json         ← шаблон записи для PR в is-a-dev/register
└── blog/
    ├── index.html         ← список записей
    ├── post.html          ← шаблон одной статьи
    ├── posts.js           ← ЕДИНЫЙ реестр метаданных записей (window.POSTS)
    ├── blog.css           ← стили блога + оформление Markdown (.prose)
    ├── feed.xml           ← RSS 2.0, правится вручную
    └── posts/*.md         ← текст записей
```

---

## 3. Архитектура и решения

### Сайт
- Чистая статика, без фреймворков и зависимостей в `package.json` (его нет).
- Единая тема в `styles.css`: CSS-переменные `--bg`, `--accent`, `--card`, `--border`, `--radius`, `--max`.
- Шрифты: Google Fonts (Inter + JetBrains Mono), подключены через `<link>` в каждом HTML.
- Декоративный `<div class="glow">` — фиксированный радиальный градиент, `z-index: -1`.
- На главной всё на якорях (`#about`, `#projects`, `#stack`), ссылка на блог — **абсолютная** `/blog`.

### Блог (без сборщика!)
- `blog/posts.js` объявляет `window.POSTS = [{ slug, title, date, description, tags }]` — это единственный источник истины о записях.
- `blog/index.html`: sort по `date` по убыванию, рендер карточек в `#post-list`, escape HTML через `escapeHtml()`.
- `blog/post.html`: берёт `?slug=` из URL, ищет запись в `window.POSTS`, делает `fetch('posts/<slug>.md')`, рендерит через `marked` (подключён с CDN jsdelivr в `<head>`).
- Ссылка на статью: `/blog/post.html?slug=my-post` — **query-параметр, не pretty URL**. Так выбрано сознательно: на статике без rewrite-правил ЧПУ requiring per-post HTML не работают.
- `slug` валидируется регуляркой `/^[a-z0-9][a-z0-9-]{0,100}$/` — защита от path traversal.
- Заголовок статьи берётся из реестра, **НЕ из `# H1` внутри Markdown** — не дублируй H1 в `.md`.
- `blog/feed.xml` не генерируется автоматически — обновляется вручную.

### Cloudflare Pages
- Проект создан через `wrangler pages project create trfnv-site --production-branch main`.
- Деплой: `wrangler pages deploy dist --project-name trfnv-site --branch main` (обёрнут в `./deploy.sh`).
- **Важно:** проект НЕ подключён к GitHub — `git push` НЕ деплоит. Только `./deploy.sh`.
- `dist/` — временная папка, создаётся скриптом, в `.gitignore`; в неё копируются только публичные файлы (без `AGENTS.md`, `README.md`, `is-a-dev/`).
- `_headers` выставляет `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy` и жёсткий кэш для `styles.css`.
- Кастомный домен добавляется **после** мержа PR: `wrangler pages domain add trfnv.is-a.dev --project-name trfnv-site`. CNAME `trfnv → trfnv-site.pages.dev` уже прописан в DNS через is-a.dev.

---

## 4. Чеклист: добавить запись в блог

1. Создать `blog/posts/<slug>.md` (только `a-z0-9-`, без H1 в начале).
2. Добавить объект в `blog/posts.js`:
   ```js
   { slug: 'my-post', title: '...', date: 'YYYY-MM-DD', description: '...', tags: ['...'] }
   ```
3. Добавить `<item>` в `blog/feed.xml` (datetime в формате RFC 822, напр. `Sat, 21 Nov 2026 00:00:00 GMT`).
4. Проверить синтаксис (см. §6).
5. `./deploy.sh` → соберёт `dist/` и задеплоит. `git push` сам по себе деплой **не** запускает.

---

## 5. Чеклист: изменить контент главной

- Тексты/карточки/теги — прямо в `index.html` (секции `#about`, `#projects`, `#stack`).
- Цвета и типографика — только через переменные в `:root` в `styles.css`.
- При добавлении новой секции обновить навигацию в `index.html`, `blog/index.html` и `blog/post.html` (она продублирована в трёх файлах).

---

## 6. Проверки перед коммитом

Проверка синтаксиса всех inline-скриптов (Node нужен только для проверки, в проде он не используется):

```bash
node -e '
const fs=require("fs");
for(const f of ["index.html","blog/index.html","blog/post.html"]){
  const html=fs.readFileSync(f,"utf8");
  [...html.matchAll(/<script(?:\s[^>]*)?>([\s\S]*?)<\/script>/g)]
    .map(m=>m[1]).filter(s=>s.trim()).forEach((s,i)=>{
      try{ new Function(s); console.log("OK",f,"#"+i); }
      catch(e){ console.log("FAIL",f,"#"+i,e.message); process.exitCode=1; }
    });
}'
```

Локальный просмотр:

```bash
python3 -m http.server 8080   # http://localhost:8080 и /blog
```

---

## 7. Известные грабли (не повторять!)

1. **НЕ пиши `return` на верхнем уровне обычного `<script>`** — это `SyntaxError` и весь скрипт падает. В `post.html` код обёрнут в `(function () { ... })();` именно поэтому.
2. **CNAME нельзя комбинировать с A/TXT/MX**, кроме случая `proxied: true`. В `trfnv.json` он как раз `true`.
3. **Плейсхолдер уже заменён** на `trfnv-site.pages.dev`. Если видишь `REPLACE-WITH-...` — значит, смотришь старую версию файла. PR уже отправлен, повторно его не создавать.
4. **Кэш браузера**: если вместо сайта открывается заглушка is-a.dev — чистить кэш, DNS уже распространился.
5. **Заглушка проектов** в `index.html` — это демо-контент. Заменить на реальные проекты.
6. **Внешняя зависимость**: `marked` грузится с CDN. Если CDN недоступен — статья покажет ошибку (есть `catch`).
7. **Не просить NS-записи** у is-a.dev в первом PR — отклонят (нужен стаж ≥30 дней).
8. `owner.username` в is-a.dev JSON — `IvanTrifonoff`, а не `trfnv` (см. §1).

---

## 8. История коммитов

- `b2d330b` — initial static site (лендинг, стили, 404, _headers, README, is-a-dev JSON)
- `7092134` — blog scaffolding (6 файлов блога)
- `ad401c9` — fix blog script scoping + убрал дубль H1 в посте
- `8825718` — добавил AGENTS.md (этот ориентир)
- `42ad142` — реальный CNAME `trfnv-site.pages.dev` + `.gitignore`
- PR в is-a.dev: https://github.com/is-a-dev/register/pull/62243 (ветка `trfnv-domain` в форке)

---

## 9. Что НЕ сделано (возможные улучшения)

- Подсветка синтаксиса в статьях (highlight.js / Prism).
- Автоматическая генерация `feed.xml` из `posts.js`.
- Pretty URLs `/blog/<slug>/` вместо `?slug=`.
- Страницы тегов.
- Реальные проекты и контактные данные вместо заглушек.
- Подключить Pages к GitHub для автодеплоя (сейчас только ручной `./deploy.sh`).
- Дождаться мержа PR #62243 и добавить кастомный домен `trfnv.is-a.dev`.
- Отдельный `.nojekyll` не нужен (Pages не использует Jekyll).
