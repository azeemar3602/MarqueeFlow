# Production Deploy Readiness — MarqueeFlow

**Review date:** 2026-06-13  
**Status:** Ready for approval — **deploy NOT started**

---

## Summary

All four components build and test successfully locally. Deploy script, nginx configs, and PM2 ecosystem are in place for `/var/www/marqueeflow`. Production deployment has **not** been executed. **AluRate was not touched.**

---

## Architecture confirmation

| Domain | Serves | Root / proxy |
|--------|--------|--------------|
| **marqueeflow.com** | Public marketing website | `/var/www/marqueeflow/website/dist` |
| **admin.marqueeflow.com** | Super Admin control panel | `/var/www/marqueeflow/admin-panel/dist` |
| **api.marqueeflow.com** | Backend API | Proxy → `127.0.0.1:4010` |
| **Flutter APK** | Business users (Owner, Manager, Waiter Head) | Separate install; API → `api.marqueeflow.com` |

### Auth separation

| Surface | Auth endpoints | Token |
|---------|----------------|-------|
| Super Admin panel | `/api/admin/auth/*` | `mf_super_admin_token` |
| APK | `/api/auth/*` | `mf_token` (shared_preferences) |
| Public website | `/api/public/demo-request` only | None |

**Guards:**
- Admin panel rejects business accounts (403)
- APK rejects admin accounts (403)
- Admin JWT blocked on APK routes
- Pending businesses blocked from business APIs (`BUSINESS_PENDING`)

---

## Build / test status

| Component | Command | Result (2026-06-13) |
|-----------|---------|---------------------|
| Backend | `npm test` | ✅ 8/8 pass |
| Backend | `npm run build` | ✅ OK |
| Admin panel | `npm run build` | ✅ OK — `admin-panel/dist/` |
| Website | `npm run build` | ✅ OK — `website/dist/` |
| Flutter | `flutter analyze` | ✅ No issues |
| Flutter APK debug | `flutter build apk --debug` | ✅ `app-debug.apk` |
| Flutter APK release | prior build | ✅ `app-release.apk` exists |

---

## Required VPS environment variables

File: `/var/www/marqueeflow/backend/.env`

```env
NODE_ENV=production
PORT=4010
HOST=127.0.0.1
JWT_SECRET=<strong-random-32+chars>   # REQUIRED — server refuses weak/missing secret

ADMIN_ORIGIN=https://admin.marqueeflow.com
WEBSITE_ORIGIN=https://marqueeflow.com
API_BASE_URL=https://api.marqueeflow.com

# First Super Admin (run once, then remove from env)
ADMIN_SEED_PHONE=03XXXXXXXXX
ADMIN_SEED_PASSWORD=<strong-password>
ADMIN_SEED_NAME=Super Admin
ADMIN_SEED_ROLE=super_admin
```

Admin panel build-time:

```env
VITE_API_BASE_URL=https://api.marqueeflow.com
```

Website build-time (optional):

```env
VITE_API_BASE_URL=https://api.marqueeflow.com
VITE_WHATSAPP_NUMBER=92XXXXXXXXXX
VITE_SUPPORT_EMAIL=support@marqueeflow.com
```

**Do NOT use demo seed credentials in production:**
- `03001234567` / `MarqueeFlow123` (APK demo)
- `03009999999` / `MarqueeFlowAdmin123` (local Super Admin seed)

---

## Nginx routing (repo configs)

| Config file | server_name | root / proxy |
|-------------|-------------|--------------|
| `deploy/nginx/marqueeflow.com.conf` | marqueeflow.com, www | `website/dist` |
| `deploy/nginx/admin.marqueeflow.com.conf` | admin.marqueeflow.com | `admin-panel/dist` |
| `deploy/nginx/api.marqueeflow.com.conf` | api.marqueeflow.com | proxy `127.0.0.1:4010` |

SSL configs exist for admin (`admin.marqueeflow.com.ssl.conf`). Apply/update nginx on VPS after deploy; reload nginx only for MarqueeFlow vhosts.

---

## PM2 process

**File:** `ecosystem.config.cjs`

| Property | Value |
|----------|-------|
| Process name | `marqueeflow-backend` |
| Script | `backend/src/server.js` |
| Port | `4010` |
| Host | `127.0.0.1` |
| Logs | `/var/log/marqueeflow/backend-out.log`, `backend-error.log` |

Staging: `ecosystem.staging.config.cjs` → port `4012`, path `/var/www/marqueeflow-staging`

---

## Deploy script

**File:** `deploy/scripts/deploy-marqueeflow.sh`

Steps:
1. Git pull on target branch
2. `backend`: npm ci + build
3. `admin-panel`: npm ci + build (`VITE_API_BASE_URL`)
4. `website`: npm ci + build
5. PM2 reload `marqueeflow-backend`
6. Health check + verify `admin-panel/dist/index.html` + `website/dist/index.html`

**Deploy path:** `/var/www/marqueeflow`  
**Trigger:** GitHub Actions → Deploy to KVM (manual workflow_dispatch)

---

## Manual verification URLs (post-deploy)

| URL | Expected |
|-----|----------|
| https://marqueeflow.com | Marketing homepage |
| https://marqueeflow.com/privacy.html | Privacy policy |
| https://marqueeflow.com/terms.html | Terms |
| https://admin.marqueeflow.com/login | Super Admin login |
| https://api.marqueeflow.com/health | `{"status":"ok"}` |
| https://api.marqueeflow.com/api/public/demo-request | POST → 201 (from marqueeflow.com origin) |

**APK:** Install release APK; login with production owner account (not demo seed).

---

## Rollback notes

1. **Code rollback:**
   ```bash
   cd /var/www/marqueeflow
   git log -1   # note current commit
   git checkout <previous-commit>
   bash deploy/scripts/deploy-marqueeflow.sh
   ```

2. **PM2 rollback:** Same as above — redeploy previous commit; PM2 reloads automatically.

3. **Nginx rollback:** Restore previous vhost if `marqueeflow.com` root was changed:
   ```bash
   sudo nginx -t && sudo systemctl reload nginx
   ```

4. **Data:** JSON store at `backend/data/runtime/store.json` — back up before deploy:
   ```bash
   cp backend/data/runtime/store.json backend/data/runtime/store.json.bak.$(date +%F)
   ```

5. **AluRate:** Deploy script and paths are MarqueeFlow-only (`/var/www/marqueeflow`). Do not modify `/var/www/alurate` or other vhosts.

---

## Pre-deploy checklist

- [ ] Set strong `JWT_SECRET` on VPS
- [ ] Create production Super Admin via `ADMIN_SEED_*` env (once)
- [ ] Remove demo seeds from production data
- [ ] Build website + admin with production API URL
- [ ] Update nginx `marqueeflow.com` root → `website/dist`
- [ ] Verify SSL cert covers marqueeflow.com, admin, api
- [x] Capture screenshots per Phase 3 + Website QA docs (`docs/phase3-screenshots/`, `docs/website-screenshots/`)
- [ ] User approval received

---

## Current status

| Item | Status |
|------|--------|
| Production deployment | ❌ **Not started** |
| AluRate | ✅ **Untouched** |
| Local builds/tests | ✅ Pass |
| Review screenshots | ✅ Captured (16 PNGs in `docs/`) |
| Ready for user approval | ✅ Yes |
