# MarqueeFlow

Booking and restaurant/service flow platform with admin panel, backend API, and Flutter mobile app.

## Structure

- `backend/` — Node.js API (Express)
- `admin-panel/` — React Super Admin SPA (Vite) → admin.marqueeflow.com
- `website/` — Public marketing site (Vite) → marqueeflow.com
- `mobile-app/` — Flutter app for owners, managers, waiter heads
- `.github/workflows/` — CI/CD

## Branches

- `test` — staging (lowercase on GitHub)
- `main` — production (lowercase on GitHub; there is no `MAIN` branch)

## CI/CD

Three GitHub Actions workflows (see `docs/CICD.md`):

1. **CI** — lint/test/build on push to `test` and `main`
2. **Deploy to KVM** — manual deploy to staging or production (separate paths/PM2)
3. **Mobile APK Build** — Flutter APK artifact on push to `test` and `main`

## Local development

```bash
cd backend && npm install && npm run dev
cd admin-panel && npm install && npm run dev
cd website && npm install && npm run dev
cd mobile-app && flutter pub get && flutter run
```

## Production URLs

- Site: https://marqueeflow.com
- API: https://api.marqueeflow.com
- Admin: https://admin.marqueeflow.com

## VPS paths

| Environment | Path | PM2 | Port |
|-------------|------|-----|------|
| Production | `/var/www/marqueeflow` | `marqueeflow-backend` | 4010 |
| Staging | `/var/www/marqueeflow-staging` | `marqueeflow-backend-staging` | 4012 |

Logs: `/var/log/marqueeflow/`

## GitHub Secrets

- `VPS_SSH_HOST`, `VPS_SSH_USER`, `VPS_SSH_PRIVATE_KEY`, `VPS_SSH_PORT`
- Set `JWT_SECRET` in each environment's `backend/.env` on the VPS (not in GitHub unless you add a deploy secret step)
