# APK Booking Regression Report

**Date:** 2026-06-13  
**Build:** `mobile-app/build/app/outputs/flutter-apk/app-debug.apk`  
**Backend:** `http://127.0.0.1:4010` (debug default via `ApiConfig.baseUrl`)  
**Production deploy:** **BLOCKED** until manual APK walkthrough passes on device/emulator.

## Summary

APK booking flow was broken primarily due to client-side issues (API base URL in debug, calendar day state field mismatch, package dropdown not binding after async load, missing validation/error UX). Backend booking API was verified end-to-end via automated test and live demo-owner curl.

| Area | Status |
|------|--------|
| Calendar date/slot selection | Fixed |
| Date/slot → Add Booking prefill | Fixed |
| Package list loading | Fixed |
| Owner packages selectable | Fixed |
| PK phone + name validation | Fixed |
| Guest count validation | Fixed |
| Advance / remaining calculation | Fixed |
| Save Booking API + backend validation | Fixed + tested |
| 401/403 guard error messages | Fixed |
| Booking List refresh | Fixed (pull-to-refresh + reload on open) |
| Booking Details route | Verified |
| Dashboard refresh after booking | Fixed (pull-to-refresh; counts update via API) |
| Loading states + errors | Fixed across calendar, booking form, list, details, home |

## Fixes Applied

### Flutter APK

- **`api_config.dart`** — Debug builds default to `http://127.0.0.1:4010` when `API_BASE_URL` is not set; release still uses production URL.
- **`calendar_slots_screen.dart`** — Uses backend `day.state` (not `status`); slot blocked/full handling; error banners + retry.
- **`add_booking_screen.dart`** — Package dropdown uses controlled `value`; loads packages with loading/error states; full client validation; navigates to `/bookings/:id` on success.
- **`booking_list_screen.dart`** — Pull-to-refresh; API error banner.
- **`booking_details_screen.dart`** — Error banner + retry.
- **`home_screen.dart`** — Pull-to-refresh; dashboard error handling.
- **`phone_validation.dart`**, **`api_errors.dart`** — PK phone normalization/validation; friendly 401/403/business guard messages.

### Backend

- **`createBooking`** — Requires active package; validates guest limit, advance bounds, slot ownership/capacity.
- **`getSubscriptionStatus`** — Exposes `trialStart`, `currentPeriodStart` for admin subscription tab.
- **Admin approval** — Starts trial when marquee is first approved.
- **New test** — `approved owner can create booking with package and slot` (9/9 tests pass).

### Website polish

- Get Started nav button: white text (`.nav-links a.btn-primary { color: #fff }`).
- `scroll-margin-top: 5.5rem` on sections/hero for sticky header anchor jumps.

### Super Admin polish

- Approve disabled when marquee already approved.
- Subscription tab: trial start/end or “not started” messaging.
- Booking Payments vs Subscription Payments clarified in marquee detail + global payments page.
- Subscription payment **Review** opens modal with confirm/reject; audit log on confirm/reject (backend).

## Automated Verification

```
backend:     npm test                          → 9/9 pass
admin-panel: npm run build                     → pass
website:     npm run build                     → pass
mobile-app:  flutter analyze                  → 0 errors (3 info: intentional DropdownButtonFormField value for async packages)
mobile-app:  flutter build apk --debug         → app-debug.apk built
API E2E:     demo owner login → calendar day → packages → POST /api/bookings → 201
```

## Manual APK Checklist (device/emulator)

Use demo owner: `03001234567` / `MarqueeFlow123` with backend on `4010`.

1. Login → Home Dashboard loads counts.
2. **Add New Booking** → Calendar & Slots → pick date → **Select** on available slot.
3. Add Booking form shows prefilled date/slot; packages listed; pick package.
4. Enter customer name, `03XXXXXXXXX` phone, guest count, advance → **Save Booking**.
5. Booking Details opens; back to Booking List shows new row (pull to refresh if needed).
6. Home Dashboard pull-to-refresh shows updated booking/payment counts.
7. Back navigation from calendar, add booking, details, list still works.
8. Packages CRUD still works (owner).
9. Pending owner account → Pending Approval only (no business APIs).
10. Super Admin phone cannot log into APK.

## Remaining / Known Items

- **Manual APK device test** — Required before production deploy; automated tests cover API, not Flutter UI gestures on physical device.
- **Flutter analyze info** — `DropdownButtonFormField.value` deprecation warnings; kept intentionally so package list updates after async fetch (`initialValue` does not).
- **APK screen recording** — Not captured in CI; recommend recording one successful booking flow on emulator for release notes.
- **Website footer screenshot** — Re-run `node scripts/capture-review-screenshots.mjs` with website preview on `:4013` to refresh `08-footer-admin-link.png` after CSS fix.

## Screenshots

Existing review assets: `docs/phase3-screenshots/`, `docs/website-screenshots/`.  
Re-capture after starting local preview servers:

```powershell
cd backend; npm start
cd admin-panel; npm run preview -- --port 4011
cd website; npm run preview -- --port 4013
node scripts/capture-review-screenshots.mjs
```
