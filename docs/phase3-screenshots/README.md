# Phase 3 Screenshot Capture Guide

Save PNG screenshots here before production deploy approval.

## Recommended filenames

| File | Local URL | What to capture |
|------|-----------|-----------------|
| `01-admin-login.png` | http://127.0.0.1:4011/login | Super Admin login page |
| `02-admin-dashboard.png` | http://127.0.0.1:4011/ | Platform dashboard stats |
| `03-marquee-detail-overview.png` | http://127.0.0.1:4011/marquees/cad1713a-5f13-4608-bff7-5b1fe89c0f5b | Overview tab |
| `04-marquee-detail-subscription.png` | same URL → Subscription tab | Subscription tab |
| `05-marquee-detail-payments.png` | same URL → Payments tab | Booking/subscription payments |
| `06-marquee-detail-issues.png` | same URL → Issues / Support tab | Open issues list |
| `07-payments-review.png` | http://127.0.0.1:4011/payments | Confirm/reject subscription payment |
| `08-admin-users.png` | http://127.0.0.1:4011/admin-users | Admin Users CRUD |
| `09-apk-back-navigation.png` | Device/emulator | Back button on inner screen |
| `10-apk-packages-crud.png` | Device/emulator | Owner package create/edit |

## Local credentials (seed only — not for production)

- Super Admin: `03009999999` / `MarqueeFlowAdmin123`
- APK demo owner: `03001234567` / `MarqueeFlow123`

## Start local preview

```powershell
cd backend; node src/server.js
cd admin-panel; npm run preview -- --host 127.0.0.1 --port 4011
npm run seed:phase3   # pending subscription payment for Demo Marquee
```
