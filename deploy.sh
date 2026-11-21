#!/usr/bin/env bash
# Собрать чистую папку dist/ и задеплоить её на Cloudflare Pages.
# Проект создан через wrangler, поэтому git push НЕ запускает деплой.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf dist
mkdir -p dist/blog/posts

cp index.html styles.css 404.html _headers dist/
cp blog/index.html blog/post.html blog/posts.js blog/blog.css blog/feed.xml dist/blog/
cp blog/posts/*.md dist/blog/posts/

wrangler pages deploy dist --project-name trfnv-site --branch main
