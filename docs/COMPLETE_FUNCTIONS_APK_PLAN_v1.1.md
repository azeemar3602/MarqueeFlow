# MarqueeFlow — Complete Functions & APK Completion Plan v1.1

## Purpose
This file is the final working instruction for Cursor to complete MarqueeFlow. It includes the full function scope for the Flutter APK, Super Admin panel, public website, backend/API, testing, commit rules, and production approval rules.

Production deployment is blocked until the Flutter APK manual walkthrough passes and the mobile experience feels polished, smooth, and professional.

---

## 1. Final Product Structure

| Surface | URL / Build | Users | Purpose |
|---|---|---|---|
| Public Website | `https://marqueeflow.com` | Visitors / potential customers | Marketing site, pricing, demo request, contact, privacy, terms |
| Super Admin Panel | `https://admin.marqueeflow.com` | MarqueeFlow / Nexus Eclipse internal admins | Manage all marquees, approvals, subscriptions, payments, revenue, admin users, and audit logs |
| Backend API | `https://api.marqueeflow.com` | Website, Super Admin, APK | Shared API layer |
| Flutter APK | Android APK | Owner, Manager, Waiter Head | End-user app for running a marquee business |

The end-user app remains a **Flutter APK**. Do not convert it to PWA.

---

## 2. Current Code Status

| Commit | Purpose |
|---|---|
| `333e7d3` | Review screenshots and local QA handoff docs |
| `413c107` | Phase 3 platform, website, auth, and APK booking fixes |
| `b7dd58c` | Flutter release APK size optimization and build outputs |

Production deployment has **not** started.  
AluRate must remain untouched.

---

## 3. Current APK Issues Blocking Release

Manual APK testing shows the mobile app is not release quality yet.

Current blocker areas:

1. Home Dashboard appears empty or incomplete.
2. Booking List appears empty or incomplete.
3. Calendar & Slots has broken vertical text/layout.
4. Back navigation is unreliable.
5. Booking flow is not smooth.
6. Record Payment flow is unclear.
7. Booking cards/details do not clearly show total, paid, remaining, booking status, and payment status.
8. Current APK does not feel like a high-end MarqueeFlow app.

Production deploy is blocked until these are fixed and manually verified.

---

## 4. Complete Function Coverage Matrix

### 4.1 Public Website Functions

| Function | Required |
|---|---:|
| Public landing page | Yes |
| Hero section with CTA buttons | Yes |
| Features section | Yes |
| Pricing section with PKR plans | Yes |
| How It Works section | Yes |
| App/platform preview | Yes |
| Request Demo form | Yes |
| Contact section | Yes |
| Footer with Privacy, Terms, Admin Login | Yes |
| Privacy page | Yes |
| Terms page | Yes |
| Responsive mobile layout | Yes |
| Public demo request API only | Yes |

Website must not expose Super Admin APIs.

---

### 4.2 Super Admin Control Panel Functions

The Super Admin panel is for MarqueeFlow/Nexus Eclipse internal admins only.

| Module | Required Functions |
|---|---|
| Super Admin Login | Separate `/api/admin/auth/*`, reject business users, token `mf_super_admin_token` |
| Dashboard | Total marquees, active/expired/trial, pending approvals, custom plan requests, monthly revenue, suspended accounts |
| Marquees / Business Profiles | List, search, view profile, approve, reject, suspend, reactivate |
| Marquee Detail | Overview, Subscription, Payments, Bookings, Customers, Team, Packages, Activity Logs, Issues / Support |
| Approvals | Pending registrations, approve, reject, admin notes |
| Subscription Plans | Basic, Standard, Premium, Custom, PKR price, user limits, trial days |
| Subscriptions | Status, start/end dates, expiry, extend, change plan, suspend/reactivate |
| Custom Plan Requests | Requested team size, notes, contact info, approve/reject/contacted/in review |
| Payments / Revenue | Review proof, confirm payment, reject payment, admin note, audit log |
| Booking Data | View bookings by business |
| Customer Data | View customers by business |
| Team Members Data | View users/roles/permissions by business |
| Packages Data | View packages by business |
| Calendar & Slots Data | View slot usage by business/date |
| Notifications | Approval/payment/subscription templates and alerts |
| Reports | Revenue, businesses, subscriptions, payments, bookings |
| Admin Users | Add, edit, deactivate, roles and permissions |
| Settings | Logo, currency, trial duration, support info, maintenance mode |
| Audit Logs | Track all sensitive admin actions |

---

### 4.3 Flutter APK Functions

| Module | Required Functions |
|---|---|
| Splash | Centered logo/name/tagline, session check, route correctly |
| Login | Phone + password only, no role dropdown, backend resolves role |
| Pending Approval | Pending/rejected/suspended messaging, logout/back |
| Home Dashboard | Stats, quick actions, Add New Booking CTA, empty/loading/error states |
| Calendar & Slots | Month calendar, availability, slot cards, select date/slot |
| Add Booking | Prefilled date/slot, customer, phone, event type, guest count, package, total, advance, remaining, status, notes |
| Booking List | Search, filters, booking cards, empty state, refresh |
| Booking Details | Customer, event, package, total, paid, remaining, statuses, call/WhatsApp, edit, record payment, share |
| Payments | Booking-connected record payment, total/paid/remaining, method/note |
| Packages | Owner create/edit/deactivate packages, active package selectable in booking |
| Customers | Customer list created from bookings, history, phone |
| Team Members | Plan usage, invite, permissions, deactivate |
| Invite Team Member | Full name, role, Pakistani phone number, permissions; no email |
| Profile / Settings | Business profile, user profile, logout |
| Subscription | PKR plans, current plan/status, custom request, expired/trial copy |
| Notifications | Booking/payment/subscription alerts if implemented |
| Back Navigation | App back and Android system back on all inner screens |

---

## 5. Subscription & Plan Functions

| Plan | Price | Limit | Rule |
|---|---:|---:|---|
| Basic | PKR 999/month | 1 person | Owner only |
| Standard | PKR 1,799/month | Up to 3 persons | Owner + up to 2 members |
| Premium | PKR 2,500/month | Up to 6 persons | Owner + up to 5 members |
| Custom | Admin-defined | More than 6 persons | Super Admin reviews and assigns custom limit/price |

Rules:

- Owner is counted in the member limit.
- Prices come from backend.
- Currency is PKR.
- Backend enforces plan limits.
- Team invite is blocked when limit is reached.
- Custom plan requests are visible in Super Admin panel.

---

## 6. Role & Permission Functions

### Owner
Can access Dashboard, Calendar, Bookings, Payments, Customers, Packages, Team Members, Profile/Settings, Subscription.

### Manager
Access depends on permissions assigned by Owner, such as bookings, payments, packages, customers, reports, calendar.

### Waiter Head
Access depends on operational permissions, such as assigned bookings/events and limited event/customer details.

Required:

- Backend enforces permissions.
- APK hides unavailable modules.
- Restricted routes show permission denied.

---

## 7. APK Premium UI Requirements

Use the approved MarqueeFlow style:

- Ivory/cream background
- Burgundy primary color
- Gold accents
- Rounded cards
- Status chips
- Proper spacing
- Soft shadows
- Clean typography
- No blank screens
- No clipped text
- No vertical/broken text

Required shared components:

- `MFAppShell`
- `MFHeader`
- `MFBackButton`
- `MFPrimaryButton`
- `MFSecondaryButton`
- `MFCard`
- `MFStatusChip`
- `MFEmptyState`
- `MFErrorState`
- `MFLoadingState`
- `MFAmountSummary`
- `MFBookingCard`
- `MFFormField`
- `MFSectionTitle`

---

## 8. Required APK Screen Fixes

### 8.1 Home Dashboard

Must show:

- Greeting/business name
- Today’s bookings
- Upcoming events
- Available slots
- Total bookings
- Pending bookings
- Confirmed bookings
- Payment pending
- Add New Booking CTA
- Quick actions: Add Booking, View Bookings, Packages, Payments

If no data:

```text
No bookings yet
Start by creating your first booking.
[Add New Booking]
```

No blank dashboard is allowed.

---

### 8.2 Calendar & Slots

Must show:

- Month calendar
- Selected date
- Availability legend
- Slot cards
- Slot time
- Capacity
- Booked count
- Available count
- Select button

Must not show vertical/broken text.

---

### 8.3 Add New Booking

Required fields:

- Date, prefilled
- Slot, prefilled
- Customer name
- Phone number
- Event type
- Guest count
- Package dropdown
- Package total
- Advance paid
- Remaining amount
- Booking status
- Notes
- Save button

Must save successfully and open Booking Details.

---

### 8.4 Booking List

Each booking card must show:

- Customer name
- Phone
- Event date
- Slot
- Package
- Guests
- Total amount
- Paid amount
- Remaining amount
- Booking status
- Payment status

Must have search/filter and empty state.

---

### 8.5 Booking Details

Must show:

- Customer info
- Event info
- Package info
- Total amount
- Paid amount
- Remaining amount
- Payment status
- Booking status
- Record Payment
- Edit Booking
- Share Details

---

### 8.6 Record Payment

Must be connected to one booking.

Show:

- Booking/customer summary
- Total amount
- Already paid
- Remaining
- New payment amount
- Payment method
- Note
- Save payment

After save:

- Remaining updates
- Payment status updates
- Dashboard counts update

---

### 8.7 Packages

Owner can:

- Create package
- Edit package
- Deactivate package
- Select active package during Add Booking

Package fields:

- Name
- Price PKR
- Guest limit
- Description
- Included services
- Active/inactive

---

## 9. Amount & Payment Logic

For every booking:

```text
Total Amount = Package Price
Paid Amount = Sum of confirmed payments
Remaining Amount = Total Amount - Paid Amount
```

Payment status:

| Condition | Status |
|---|---|
| Paid = 0 | Unpaid |
| Paid > 0 and Paid < Total | Advance Paid / Partially Paid |
| Paid >= Total | Fully Paid |

Booking cards and details must always show total, paid, remaining, and payment status.

---

## 10. Navigation Acceptance

| Current Screen | Back Target |
|---|---|
| Home | Exit confirmation or stay on Home |
| Calendar & Slots | Home |
| Add Booking | Calendar & Slots |
| Booking Details | Booking List |
| Booking List | Home |
| Payments | Home |
| Record Payment | Booking Details or Payments |
| Packages | Home |
| Create/Edit Package | Packages |
| Customers | Home |
| Team Members | Home |
| Profile/Settings | Home |
| Pending Approval | Login |

Both app back and Android system back must work.

---

## 11. Backend/API Requirements

Keep this separation:

| Surface | Auth |
|---|---|
| APK | `/api/auth/*` |
| Super Admin | `/api/admin/auth/*` |
| Public Website | `/api/public/*` |

All APK business APIs must:

- Read business ID from JWT/session.
- Never trust business ID from request body.
- Enforce approved/active business status.
- Return friendly structured errors.

Required API areas:

- Dashboard summary
- Calendar month/day
- Packages
- Bookings
- Booking details
- Booking payments
- Customers
- Team permissions
- Subscription status

---

## 12. Testing Commands

Run before sending back:

```powershell
cd backend
npm test

cd admin-panel
npm run build

cd website
npm run build

cd mobile-app
flutter analyze
flutter build apk --release --split-per-abi --target-platform android-arm64 --dart-define=API_BASE_URL=http://192.168.18.133:4010
```

Expected:

- Backend tests pass.
- Admin build passes.
- Website build passes.
- Flutter analyze has no errors.
- arm64 release APK builds.

---

## 13. Manual APK Walkthrough

Use:

```text
Phone: 03001234567
Password: MarqueeFlow123
```

Required flow:

```text
1. Open APK
2. Splash centered
3. Login
4. Home Dashboard opens
5. Tap Add New Booking
6. Calendar & Slots opens
7. Select available date/slot
8. Add Booking opens with date/slot prefilled
9. Select package
10. Enter customer name
11. Enter phone
12. Enter guest count
13. Enter advance amount
14. Remaining amount auto-calculates
15. Save booking
16. Booking Details opens
17. Total/paid/remaining are visible
18. Record payment if remaining exists
19. Payment status updates
20. Go back to Booking List
21. New booking appears
22. Go Home
23. Refresh
24. Dashboard counts update
```

If any step fails, production remains blocked.

---

## 14. Required Evidence Before Approval

Provide screenshots or screen recording showing:

1. Login screen
2. Home Dashboard
3. Calendar & Slots fixed layout
4. Add Booking form
5. Package dropdown
6. Booking Details with total/paid/remaining
7. Booking List with created booking
8. Record Payment flow
9. Dashboard after refresh

---

## 15. Commit Rules

Commit only MarqueeFlow files.

Do not commit:

- `.env`
- `key.properties`
- signing keys
- APK/AAB build outputs
- `node_modules`
- runtime data
- AluRate files

Suggested commit message:

```text
Polish Flutter APK booking flow and premium mobile UX
```

---

## 16. Production Deployment Rules

Do not deploy until:

- APK manual walkthrough passes.
- All code is committed and pushed.
- Builds/tests pass.
- Strong production `JWT_SECRET` is set.
- Production Super Admin seed is ready.
- Website/admin/API routing is confirmed.
- User gives explicit deploy approval.

Production target:

```text
/var/www/marqueeflow
```

Must not touch:

```text
/var/www/alurate
```

---

## 17. Future Hardening After APK Stabilization

After APK is stable, move to:

- MySQL instead of JSON store
- Staging environment
- CI/CD test gates
- Manual production approval
- Nightly backups
- Rollback plan
- Tenant/business isolation on every query
- Proper operations runbook

Do not mix this future hardening with the current APK polish unless approved.

---

## 18. Final Cursor Response Required

After completing the APK polish pass, send:

- Summary of fixes
- Updated APK path
- Build/test results
- Screenshots or recording path
- Manual walkthrough result
- Known limitations
- Commit hash if committed
- Confirmation production deploy not started
- Confirmation AluRate untouched

---

## 19. Final Acceptance Statement

The APK is complete only when this is true:

```text
A marquee owner can log in, understand the dashboard, create a package, create a booking from calendar/slot, record payment, view booking details, see total/paid/remaining clearly, navigate back naturally, and see updated dashboard/list data without confusion or broken UI.
```

Until then, MarqueeFlow is not production ready.
