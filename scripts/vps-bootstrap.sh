#!/usr/bin/env bash
# MarqueeFlow VPS bootstrap — creates ONLY MarqueeFlow resources.
set -euo pipefail

DEPLOY_PATH="/var/www/marqueeflow"
REPO_URL="https://github.com/azeemar3602/MarqueeFlow.git"
BACKEND_PORT=4010
ADMIN_PORT=4011

echo "=== MarqueeFlow VPS bootstrap (read-only audit first) ==="
echo "Host: $(hostname)"
echo "Existing /var/www:"
ls -la /var/www/ || true
echo "Existing PM2:"
pm2 list || true
echo "Listening ports:"
ss -tlnp || true

mkdir -p "$DEPLOY_PATH" /var/log/marqueeflow
if [ ! -d "$DEPLOY_PATH/.git" ]; then
  git clone "$REPO_URL" "$DEPLOY_PATH"
fi

cd "$DEPLOY_PATH"
git fetch --all
git checkout test || git checkout -b test origin/test || git checkout main

cd "$DEPLOY_PATH/backend"
npm ci
cp -n .env.example .env || true

cd "$DEPLOY_PATH/admin-panel"
npm ci
npm run build
cp -n .env.example .env.production || true

cd "$DEPLOY_PATH"
pm2 start ecosystem.config.cjs || pm2 reload ecosystem.config.cjs
pm2 save

echo "MarqueeFlow bootstrap complete."
