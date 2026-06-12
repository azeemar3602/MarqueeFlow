# MarqueeFlow CI/CD

## Branch strategy (verified on GitHub remote)

| Branch | Casing on GitHub | Environment |
|--------|------------------|-------------|
| `test` | lowercase | Staging |
| `main` | lowercase | Production |

**Note:** There is no `MAIN` (uppercase) branch on the remote. Production uses **`main`** exactly as named on GitHub.

## GitHub Actions workflows

| Workflow name | File | Triggers |
|---------------|------|----------|
| **CI** | `.github/workflows/ci.yml` | Push to `test` / `main`, PRs, manual |
| **Deploy to KVM** | `.github/workflows/deploy-to-kvm.yml` | Manual only (`workflow_dispatch`) |
| **Mobile APK Build** | `.github/workflows/mobile-apk-build.yml` | Push to `test` / `main`, manual |

Legacy auto-deploy workflows (`Deploy Production`, `Deploy Staging`) were removed to prevent staging/production overwriting each other on the same VPS path.

## KVM separation (MarqueeFlow only)

| | Staging | Production |
|---|---------|------------|
| Git branch | `test` | `main` |
| Deploy path | `/var/www/marqueeflow-staging` | `/var/www/marqueeflow` |
| PM2 process | `marqueeflow-backend-staging` | `marqueeflow-backend` |
| Backend port | `4012` | `4010` |
| PM2 config | `ecosystem.staging.config.cjs` | `ecosystem.config.cjs` |
| API URL | `https://api-staging.marqueeflow.com` | `https://api.marqueeflow.com` |
| Admin URL | `https://admin-staging.marqueeflow.com` | `https://admin.marqueeflow.com` |

AluRate (`/var/www/alurate*`, `alurate-*` PM2) is never modified by these workflows.

## GitHub Secrets (required)

| Secret | Purpose |
|--------|---------|
| `VPS_SSH_HOST` | KVM/VPS IP or hostname |
| `VPS_SSH_USER` | SSH user (e.g. `root`) |
| `VPS_SSH_PRIVATE_KEY` | Private key for SSH |
| `VPS_SSH_PORT` | SSH port (optional, default 22) |

## GitHub Variables (optional overrides)

| Variable | Default |
|----------|---------|
| `MARQUEEFLOW_STAGING_DEPLOY_PATH` | `/var/www/marqueeflow-staging` |
| `MARQUEEFLOW_PRODUCTION_DEPLOY_PATH` | `/var/www/marqueeflow` |
| `MARQUEEFLOW_STAGING_PM2_NAME` | `marqueeflow-backend-staging` |
| `MARQUEEFLOW_PRODUCTION_PM2_NAME` | `marqueeflow-backend` |
| `MARQUEEFLOW_STAGING_PORT` | `4012` |
| `MARQUEEFLOW_PRODUCTION_PORT` | `4010` |
| `MARQUEEFLOW_STAGING_API_URL` | `https://api-staging.marqueeflow.com` |
| `MARQUEEFLOW_PRODUCTION_API_URL` | `https://api.marqueeflow.com` |

## VPS manual one-time staging setup

1. DNS A records: `api-staging.marqueeflow.com`, `admin-staging.marqueeflow.com`
2. Copy nginx templates from `deploy/nginx/*-staging*.conf` to `/etc/nginx/sites-available/`, enable, `certbot`, `nginx reload`
3. Create `backend/.env` under staging path with `PORT=4012`, `JWT_SECRET`, `ADMIN_ORIGIN=https://admin-staging.marqueeflow.com`
4. Run **Deploy to KVM** → staging (clones repo and starts PM2)

## Rollback

Deploy script logs previous commit. On VPS:

```bash
cd /var/www/marqueeflow   # or marqueeflow-staging
git checkout <previous-sha>
cd backend && npm ci && npm run build
cd ../admin-panel && npm ci && VITE_API_BASE_URL=<api-url> npm run build
pm2 reload <pm2-process-name>
```
