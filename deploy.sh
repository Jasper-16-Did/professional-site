#!/usr/bin/env bash
# deploy.sh — build and push _site/ to the Codeberg Pages branch
set -euo pipefail

PAGES_BRANCH="pages"

echo "==> Building site..."
bundle exec jekyll build

echo "==> Deploying to branch: $PAGES_BRANCH"

CURRENT_BRANCH=$(git symbolic-ref --short HEAD)

TMPDIR=$(mktemp -d)
cp -r _site/. "$TMPDIR/"

if git show-ref --quiet refs/heads/$PAGES_BRANCH; then
  git checkout $PAGES_BRANCH
else
  git checkout --orphan $PAGES_BRANCH
  git rm -rf . --quiet
fi

git rm -rf . --quiet 2>/dev/null || true
cp -r "$TMPDIR/." .
rm -rf "$TMPDIR"

git add -A
git commit -m "Deploy $(date '+%Y-%m-%d %H:%M')"
git push origin $PAGES_BRANCH

git checkout "$CURRENT_BRANCH"

echo "==> Done. Site deployed to branch '$PAGES_BRANCH'."
echo "    It will be live at https://jaxond.pro once DNS is configured."
