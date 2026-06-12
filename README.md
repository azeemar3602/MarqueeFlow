# MarqueeFlow

Booking and restaurant/service flow platform with admin panel, backend API, and Flutter mobile app.

## Structure

- `backend/` — Node.js API (Express)
- `admin-panel/` — React admin SPA (Vite)
- `mobile-app/` — Flutter customer booking app
- `.github/workflows/` — CI/CD

## Branches

- `test` — staging
- `main` — production (deploy after CI)

## Local development

```bash
cd backend && npm install && npm run dev
cd admin-panel && npm install && npm run dev
cd mobile-app && flutter pub get && flutter run
```

## Production URLs

- API: https://api.marqueeflow.com
- Admin: https://admin.marqueeflow.com
- Site: https://marqueeflow.com

## VPS paths

- Deploy root: `/var/www/marqueeflow`
- PM2: `marqueeflow-backend`, `marqueeflow-admin`
- Logs: `/var/log/marqueeflow/`

## GitHub Secrets

- `VPS_SSH_HOST`, `VPS_SSH_USER`, `VPS_SSH_PRIVATE_KEY`, `VPS_SSH_PORT`
- `MARQUEEFLOW_JWT_SECRET`, `MARQUEEFLOW_DB_PASSWORD`
