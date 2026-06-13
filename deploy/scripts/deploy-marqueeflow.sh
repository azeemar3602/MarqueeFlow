#!/usr/bin/env bash
# MarqueeFlow KVM deploy script (staging or production).
# Invoked by GitHub Actions "Deploy to KVM" via SSH. Touches MarqueeFlow paths/PM2 only.
set -euo pipefail

: "${DEPLOY_PATH:?DEPLOY_PATH required}"
: "${GIT_BRANCH:?GIT_BRANCH required}"
: "${PM2_APP_NAME:?PM2_APP_NAME required}"
: "${ECOSYSTEM_FILE:=ecosystem.config.cjs}"
: "${VITE_API_BASE_URL:?VITE_API_BASE_URL required}"
: "${HEALTH_PORT:?HEALTH_PORT required}"
: "${REPO_URL:?REPO_URL required}"

mkdir -p /var/log/marqueeflow

PREV_COMMIT="none"
if [ -d "${DEPLOY_PATH}/.git" ]; then
  cd "${DEPLOY_PATH}"
  PREV_COMMIT="$(git rev-parse HEAD)"
  git fetch origin "${GIT_BRANCH}"
  git checkout "${GIT_BRANCH}"
  git pull --ff-only origin "${GIT_BRANCH}"
else
  mkdir -p "$(dirname "${DEPLOY_PATH}")"
  git clone --branch "${GIT_BRANCH}" "${REPO_URL}" "${DEPLOY_PATH}"
  cd "${DEPLOY_PATH}"
fi

NEW_COMMIT="$(git rev-parse HEAD)"
echo "MarqueeFlow deploy: branch=${GIT_BRANCH} path=${DEPLOY_PATH}"
echo "Commit: ${PREV_COMMIT} -> ${NEW_COMMIT} (rollback: cd ${DEPLOY_PATH} && git checkout ${PREV_COMMIT})"

cd backend
npm ci
npm run build

cd ../admin-panel
npm ci
VITE_API_BASE_URL="${VITE_API_BASE_URL}" npm run build

cd ../website
npm ci
npm run build

cd ..

if pm2 describe "${PM2_APP_NAME}" >/dev/null 2>&1; then
  pm2 reload "${PM2_APP_NAME}" --update-env
else
  pm2 start "${ECOSYSTEM_FILE}" --only "${PM2_APP_NAME}"
fi
pm2 save

curl -fsS "http://127.0.0.1:${HEALTH_PORT}/health"
test -f admin-panel/dist/index.html
test -f website/dist/index.html

echo "Deploy OK: ${PM2_APP_NAME} @ ${DEPLOY_PATH} (port ${HEALTH_PORT})"
