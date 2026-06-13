# Phase 3 Local QA — MarqueeFlow Platform

**Review date:** 2026-06-13  
**Status:** Ready for local review — **production deploy not started**

---

## Summary

Phase 3 polish is complete for the Super Admin control panel and Flutter APK. All requested tabs, payment confirmation, admin user CRUD, owner package management, APK back navigation, and auth separation are implemented and verified locally via builds, automated tests, and browser functional checks.

---

## Screenshot folder

**Path:** `docs/phase3-screenshots/`  
**Status:** ✅ **Captured** (2026-06-13 via Playwright)

| File | Status |
|------|--------|
| `01-admin-login.png` | ✅ Captured |
| `02-admin-dashboard.png` | ✅ Captured |
| `03-marquee-detail-overview.png` | ✅ Captured |
| `04-marquee-detail-subscription.png` | ✅ Captured |
| `05-marquee-detail-payments.png` | ✅ Captured |
| `06-marquee-detail-issues.png` | ✅ Captured |
| `07-payments-review.png` | ✅ Captured |
| `08-admin-users.png` | ✅ Captured |

**Recapture:** `node scripts/capture-review-screenshots.mjs` (requires local admin preview on `:4011`, website on `:4013`, backend on `:4010`)

---

## Super Admin — verified items

### Marquee Detail (9 tabs)

| Tab | Status | Notes |
|-----|--------|-------|
| Overview | ✅ | Platform status, owner info, stats, quick actions |
| Subscription | ✅ | Plan, trial/active status, extend action |
| Payments | ✅ | Booking + subscription payments for marquee |
| Bookings | ✅ | Recent bookings list |
| Customers | ✅ | Customer records |
| Team | ✅ | Team members + usage |
| Packages | ✅ | Hall packages for marquee |
| Activity Logs | ✅ | Audit entries with matching `targetId` |
| Issues / Support | ✅ | Approval, subscription, payment issues |

**Demo marquee ID:** `cad1713a-5f13-4608-bff7-5b1fe89c0f5b`

### Subscription payment confirmation

- ✅ View payment proof URL
- ✅ Confirm payment → updates subscription + audit log
- ✅ Reject payment → audit log
- ✅ Admin note field
- ✅ Seed: `npm run seed:phase3` creates pending payment for Demo Marquee

### Admin Users CRUD

- ✅ Add admin user (Super Admin only)
- ✅ Deactivate admin user
- ✅ Roles: Super Admin, Support Admin, Finance Admin, Read-only Admin
- ✅ Write protection via `requireAdminWrite` / role middleware

### Auth separation (Super Admin)

- ✅ Panel uses `/api/admin/auth/*` only (`admin-panel/src/lib/api.js`)
- ✅ Token key: `mf_super_admin_token` (separate from APK)
- ✅ Rejects business accounts on admin login (403)
- ✅ Rejects non-admin JWT (`kind !== "admin"`)

---

## APK — verified items

### Back navigation (`onBack` + `mfGoBack`)

| Screen | Fallback route |
|--------|----------------|
| Calendar & Slots | `/home` |
| Add Booking | `/calendar` |
| Booking Details | `/bookings` |
| Edit Booking | `/bookings/:id` |
| Booking List | `/bookings` |
| Payments | `/home` |
| Customers | `/home` |
| Profile/Settings | `/home` |
| Team Members | `/home` |
| Invite Team | `/team` |
| Subscription | `/home` |
| Packages | `/home` |
| Pending Approval | Back → `/login` |

### Owner package management

- ✅ View / create / edit / deactivate packages
- ✅ Fields: name, PKR price, guest limit, description, inclusions, active status
- ✅ `managePackages` permission for Manager/Waiter Head via invite

### Auth & routing

- ✅ Owner register → pending approval screen (when manual approval enabled)
- ✅ Pending/rejected/suspended → `/pending-approval` only
- ✅ Manager/Waiter Head invite-only (no public self-register)
- ✅ APK rejects admin credentials (403)
- ✅ Backend blocks dashboard APIs for pending businesses (`BUSINESS_PENDING`)

---

## APIs added/updated (Phase 3)

### Super Admin (`/api/admin/*`)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/admin/marquees/:id` | Full marquee detail (all tabs) |
| PATCH | `/api/admin/payments/:id/confirm` | Confirm subscription payment |
| PATCH | `/api/admin/payments/:id/reject` | Reject subscription payment |
| POST | `/api/admin/admin-users` | Create admin user |
| PATCH | `/api/admin/admin-users/:id` | Update/deactivate admin |

### APK business (`/api/*`)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/packages?includeInactive=true` | List packages |
| POST | `/api/packages` | Create package (owner / permission) |
| PATCH | `/api/packages/:id` | Update package |
| DELETE | `/api/packages/:id` | Deactivate package |

### Auth guards

- `requireAuth` — rejects admin JWT on APK routes
- `requireActiveBusiness` — blocks pending/suspended/rejected from business APIs
- `/api/auth/me` — still accessible for pending users (routing only)

---

## Build / test status

| Component | Command | Result |
|-----------|---------|--------|
| Backend | `npm test` | 8/8 pass |
| Backend | `npm run build` | OK |
| Admin panel | `npm run build` | OK |
| Flutter | `flutter analyze` | No issues |
| Flutter APK | `flutter build apk --debug` | OK — `mobile-app/build/app/outputs/flutter-apk/app-debug.apk` |
| Flutter APK release | prior session | OK — `app-release.apk` exists |

---

## Local seed commands

```powershell
cd backend
npm run seed:demo      # APK demo owner
npm run seed:admin     # Super Admin (local only)
npm run seed:phase3    # Pending subscription payment QA
```

---

## Known limitations

1. **JSON file store** — MVP uses `backend/data/runtime/store.json`, not MySQL.
2. **Subscription payment proof** — URL string only; no file upload to storage.
3. **Marquee activity logs** — Only audit entries with matching `targetId`.
4. **APK drawer permissions** — Package management gated; other modules not fully hidden by permission yet.
5. **APK device screenshots** — Admin/website PNGs captured; APK back-nav and package flow still device-only if needed.
6. **Demo credentials** — Local seed only; must not ship to production VPS.
7. **Platform-wide Super Admin calendar** — Requires `businessId` query param; not a global calendar view.

---

## Production deploy

**Not started.** Awaiting approval after screenshot review and local testing.

**AluRate:** Untouched.
