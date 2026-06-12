# MarqueeFlow App + Control Panel Plan

**Version:** v1.4  
**Date:** 12 June 2026  
**Project:** MarqueeFlow event booking and management platform  
**Prepared for:** Nexus Eclipse Pvt Ltd / MarqueeFlow review  
**Status:** Updated Subscription Plans screen to add a **Request Custom Plan** section for teams above 6 persons, align pricing in **PKR**, and replace the subscription mockup with a cleaner version without display issues.

---

## 1. Executive Recommendation

Do not start coding directly from screenshots. First approve this screen document, then build the reusable design system, backend database, APIs, Flutter app, and control panel.

Recommended approach:

- Use **Flutter** for the mobile app because the design is custom, visual-heavy, and should work consistently on Android and iOS.
- Build a **web control panel** for owners/admins to manage bookings, customers, slots, packages, payments, teams, subscriptions, and reports.
- Use **Hostinger Business hosting** for MVP backend/admin deployment if traffic remains moderate.
- Keep the backend upgrade-ready for Hostinger Cloud or VPS later.
- Use **MySQL** as the first database because it is suitable for bookings, payments, subscriptions, users, and reports.
- Build API-first so the Flutter app and control panel use the same backend data.

---

## 2. Cursor vs Claude Recommendation

| Area | Recommended Tool | Reason |
|---|---|---|
| Final requirement planning | Claude / ChatGPT | Best for reviewing business logic, edge cases, approval docs, and technical decisions. |
| Main development | Cursor | Best for coding Flutter, backend, database, admin panel, file structure, terminal commands, and Git workflow. |
| Code review and debugging | Claude / ChatGPT + Cursor | Use Claude/ChatGPT to review logic and Cursor to apply fixes directly. |
| QA test cases | ChatGPT | Best for generating structured QA scenarios, validations, and regression checklist. |

**Simple workflow:**  
Use Claude/ChatGPT for planning and review. Use Cursor as the main coding workspace. Do not ask Cursor to build the whole app in one prompt. Give it approved screens and modules phase by phase.

---

## 3. Recommended Technical Architecture

| Layer | Recommended Choice | Notes |
|---|---|---|
| Mobile App | Flutter | Android first, iOS-ready structure. Use reusable themed widgets for cards, buttons, status badges, fields, and forms. |
| Control Panel | React / Next.js or Laravel Blade | Choose based on backend stack. The control panel should be responsive and admin-friendly. |
| Backend API | Node.js Express/NestJS or Laravel API | Both are acceptable. Node.js may be easier for Hostinger Node deployment; Laravel is strong for admin CRUD. |
| Database | MySQL | Store businesses, users, plans, bookings, payments, slots, packages, notifications, and audit logs. |
| Authentication | JWT / secure session | Role-aware login for Owner, Manager, Waiter Head. |
| Hosting | Hostinger Business for MVP | Use Hostinger only if backend runtime and database limits are enough. Upgrade later if needed. |
| File Storage | Hostinger storage initially | Later move to S3-compatible storage if invoices/images grow. |
| Payments | Pakistan-ready manual/payment gateway flow | Must support PKR. Final provider to be approved. |

---

## 4. Proposed MarqueeFlow Modules

| Module | Mobile App | Control Panel |
|---|---|---|
| Authentication | Login, role selection, remember me, forgot password | Admin/owner login, password reset, session management |
| Subscription | PKR plan view, trial status, upgrade prompt, member limit notice, custom plan request | Plan creation, PKR pricing, monthly billing, user limits, active/expired accounts, invoices, custom plan requests |
| Dashboard | Today, upcoming events, available slots, payment pending | Business KPIs, booking trends, revenue, pending actions |
| Bookings | Create, view, edit, call/WhatsApp, share details | Full CRUD, search/filter/export, assign staff |
| Calendar & Slots | View availability and day slots | Create slot capacity, block dates, manage availability |
| Payments | Record advance/remaining payment, view payment list | Payment ledger, status updates, reports, refunds/adjustments |
| Customers | Stored through bookings | Customer profile, booking history, contact details |
| Packages | Select package during booking | Create/edit packages, pricing, inclusions |
| Notifications | Bell icon, reminders, booking alerts | Send announcements, manage templates/reminders |
| Reports | Basic summaries | Revenue, booking, event type, monthly reports, export |
| Team Members | Owner can view plan usage, invite Manager or Waiter Head, and manage access | Invite users, role permissions, member limits, deactivate access, audit trail |

---

## 5. Development Milestones

| Phase | Scope | Output for Review |
|---|---|---|
| Phase 0 | Finalize approved screens, roles, data model, and APIs | Signed-off document and final task list |
| Phase 1 | Flutter project setup, theme, navigation, reusable widgets | App shell and design system |
| Phase 2 | Backend setup, MySQL schema, auth APIs | Working login/register/subscription APIs |
| Phase 3 | Core app screens: Splash, Login, Create Account, Subscription, Home | App foundation ready |
| Phase 4 | Calendar & Slots, Add Booking, Booking List, Booking Details | Booking workflow ready |
| Phase 5 | Payments, Team Members, Invite Team Member | Revenue and role management ready |
| Phase 6 | Control panel screens | Admin management ready |
| Phase 7 | QA, bug fixes, deployment | MVP release candidate |

---

## 6. Core Database Plan

| Table | Purpose | Important Fields |
|---|---|---|
| users | Stores owners, managers, waiter heads, and staff | id, name, phone, email_optional, password_hash, role, status, business_id, created_at |
| businesses | Stores each marquee/event business | id, owner_id, business_name, phone, address, currency_code, subscription_plan_id, status |
| subscription_plans | Stores plans and limits | id, name, price_monthly, currency_code, user_limit, features_json, is_active |
| business_subscriptions | Stores business subscription status | id, business_id, plan_id, status, trial_start, trial_end, current_period_start, current_period_end |
| custom_plan_requests | Stores requests for more than 6 persons | id, business_id, requested_team_size, contact_name, phone, note, status, created_at |
| team_members | Stores invited team users | id, business_id, user_id, role, permissions_json, invited_by, status |
| team_invites | Stores pending invites | id, business_id, name, phone, role, permissions_json, invite_token, expires_at, status |
| customers | Stores customer/contact data | id, business_id, name, phone, notes |
| bookings | Stores booking records | id, business_id, customer_id, booking_code, event_date, slot_id, event_type, guest_count, package_id, status |
| slots | Stores slot capacity | id, business_id, date, slot_name, start_time, end_time, capacity, booked_count, status |
| packages | Stores package options | id, business_id, name, price, inclusions_json, status |
| payments | Stores payment records | id, business_id, booking_id, amount, payment_type, payment_status, payment_date, note |
| notifications | Stores alerts and reminders | id, business_id, user_id, title, message, type, is_read |
| audit_logs | Tracks important actions | id, business_id, user_id, action, entity_type, entity_id, old_value_json, new_value_json |

---

## 7. Screen Approval Matrix

| Screen | Approval Status | Reviewer Notes |
|---|---|---|
| Splash Screen | Pending |  |
| Login Screen | Pending |  |
| Create Account / Role Selection | Pending |  |
| Subscription Plans | Pending | Updated with PKR pricing, member-limit logic, and Request Custom Plan CTA for teams above 6 persons. |
| Home Dashboard | Pending |  |
| Calendar & Slots | Pending | Moved after Home Dashboard. Add New Booking opens this screen first. |
| Add New Booking | Pending | Opens after date/slot selection. |
| Booking List / Search | Pending |  |
| Booking Details | Pending |  |
| Payments | Pending |  |
| Team Members | Pending | New screen added for Owner plan usage and member management. |
| Invite Team Member | Pending | New screen added for Manager / Waiter Head invitation flow. Email removed. |

**Approval rule:** A screen should only move to development after its fields, actions, validations, and backend data needs are approved.

---

# Mobile App Screen Plan

---

## Screen 01: Splash Screen

### Purpose
Brand introduction while the app checks saved login/session state and subscription status.

### Main user actions
- View logo, app name, and tagline.
- App auto-redirects to Login, Home, or Subscription/Expired screen depending on session and subscription state.

### Fields / UI components
- MarqueeFlow logo
- App name
- Tagline: Manage. Book. Celebrate.
- Floral background accents
- Loading state if session check takes time

### Rules and validations
- If no token exists, go to Login.
- If token exists and subscription is active/trial, go to Home.
- If token exists but subscription expired, go to Subscription screen or expired access screen.
- Splash should not stay longer than required.

### Backend / API data needed
- `GET /auth/me`
- `GET /subscription/status`

### Control panel relation
No direct control panel relation, but the status logic depends on business subscription status managed from the control panel.

### Approval checklist
- [ ] Splash duration approved
- [ ] Redirect logic approved
- [ ] Logo and tagline approved

---

## Screen 02: Login Screen

### Purpose
Allows owner, manager, or waiter head to sign in and continue managing events.

### Main user actions
- Select role
- Enter email/phone and password
- Toggle password visibility
- Use remember me
- Open forgot password
- Open create account

### Fields / UI components
- Role dropdown
- Email or phone number
- Password
- Remember me checkbox
- Forgot Password link
- Sign In button
- Create New Account button

### Rules and validations
- Role is required.
- Email/phone is required.
- Password is required.
- Phone format should support Pakistani numbers and international format.
- Show clear invalid credential message.
- Disable Sign In while request is in progress.

### Backend / API data needed
- `POST /auth/login`
- `POST /auth/forgot-password`
- Store auth token securely.
- Return user role, business_id, and subscription status.

### Control panel relation
The control panel should use the same user accounts and permissions, but the web admin can have a separate login layout.

### Approval checklist
- [ ] Role flow approved
- [ ] Email/phone login approved
- [ ] Forgot password flow approved

---

## Screen 03: Create Account / Role Selection

### Purpose
Collects the intended account role before starting registration or invitation-based access.

### Main user actions
- Choose Owner
- Choose Manager
- Choose Staff / Waiter Head if applicable
- Continue to next step
- Open login if account already exists

### Fields / UI components
- Owner card
- Manager card
- Staff card
- Subscription-based access note
- Continue button
- Login link

### Rules and validations
- Public signup should create only Owner/business account by default.
- Manager and Waiter Head accounts should be created through owner invitation.
- If Manager or Staff is selected without invite token, show message: “Please ask your owner to invite you.”
- Role selection should not bypass subscription/member limit rules.

### Backend / API data needed
- `POST /auth/register-owner`
- `GET /team/invites/{token}` if invite-based registration is used
- `POST /team/invites/{token}/accept`

### Control panel relation
Super admin/owner can monitor new businesses and team invitations.

### Approval checklist
- [ ] Public owner signup approved
- [ ] Manager invitation rule approved
- [ ] Waiter Head invitation rule approved

---

## Screen 04: Subscription Plans

### Purpose
Shows Pakistan monthly subscription plans in PKR, lets the owner compare team limits, start a trial, select a paid plan, or submit a custom-plan request for bigger teams.

### Main user actions
- View Basic, Standard, and Premium plans
- Compare included team limits and features
- Start free trial
- Select or upgrade monthly plan
- Request custom plan for more than 6 persons

### Fields / UI components
- Plan cards with PKR monthly price
- User limit summary: 1 person, up to 3 persons, up to 6 persons
- Feature checklist
- Recommended badge on Standard plan
- Request Custom Plan section / CTA
- Start Free Trial button
- No credit card note if trial is enabled

### Approved Pakistan pricing

| Plan | Monthly Price | Person Limit | Suggested Description |
|---|---:|---:|---|
| Basic Plan | PKR 999/month | 1 person total | For single owner |
| Standard Plan | PKR 1,799/month | Up to 3 persons total | For owner + up to 2 team members |
| Premium Plan | PKR 2,500/month | Up to 6 persons total | For larger teams |
| Custom Plan | Custom | More than 6 persons | Request custom plan |

### Feature rules

#### Basic Plan
- 1 owner account
- Manage bookings
- Customer management
- Basic reports
- Email support
- No Manager or Waiter Head invitation

#### Standard Plan
- Up to 3 persons total
- Add Manager or Waiter Head
- Team collaboration
- Advanced reports
- Priority support

#### Premium Plan
- Up to 6 persons total
- Add Manager and Waiter Head roles
- Multiple team members
- Role permissions
- Advanced analytics
- Dedicated support

#### Custom Plan
- For more than 6 team members
- Owner submits request
- Admin reviews request from control panel
- Admin can contact owner and create custom pricing manually

### Rules and validations
- Currency must be PKR for Pakistan launch.
- Prices must come from backend, not hard-coded in Flutter.
- Owner is counted inside the plan member limit.
- Basic plan allows owner only; no Manager/Waiter Head invitations.
- Standard plan allows owner + up to 2 additional members.
- Premium plan allows owner + up to 5 additional members.
- If member limit is reached, Team Members screen must show upgrade message.
- If subscription expires, lock paid features but keep login/profile accessible.
- Request Custom Plan should open a form or contact flow for businesses needing more than 6 persons.

### Backend / API data needed
- `GET /subscription/plans?currency=PKR`
- `POST /subscription/start-trial`
- `POST /subscription/checkout` or manual payment confirmation
- `GET /subscription/status`
- `GET /team/usage`
- `POST /subscription/custom-plan-request`

### Suggested custom-plan request payload

```json
{
  "business_id": "uuid",
  "requested_team_size": 10,
  "contact_name": "Ali Raza",
  "phone": "+923001234567",
  "note": "Need access for multiple managers and waiter heads."
}
```

### Control panel relation
Super admin can manage PKR prices, trial duration, features, user limits, active/inactive plans, and subscribed businesses. The control panel should also list custom plan requests, requested team size, contact information, notes, and request status.

### UI / UX quality note
This screen mockup has been refined to remove visible layout/display issues. During development, QA should verify:

- Text does not overflow.
- Plan cards remain aligned on small Android and iPhone screens.
- The custom-plan section remains fully visible without clipping.
- The Start Free Trial button remains reachable.
- Long feature text wraps cleanly.

### Approval checklist
- [ ] PKR pricing approved
- [ ] User limits approved
- [ ] Custom plan flow approved
- [ ] Trial duration approved
- [ ] Payment/manual confirmation flow approved

---

## Screen 05: Home Dashboard

### Purpose
Gives the user a quick overview of today’s bookings, upcoming events, available slots, and pending work.

### Main user actions
- View daily summary
- Tap Add New Booking
- View total bookings
- View pending bookings
- View confirmed bookings
- View payment pending
- Open notifications/menu

### Fields / UI components
- Greeting with user name
- Date chip
- Today’s bookings card
- Upcoming events card
- Available slots card
- Total bookings row
- Pending bookings row
- Confirmed bookings row
- Payment pending row
- Add New Booking button

### Rules and validations
- Dashboard numbers should come from backend.
- Add New Booking should open **Calendar & Slots first**, not the booking information form.
- Counts should update after booking/payment/status changes without requiring app restart.
- Role permissions should control visible actions.

### Backend / API data needed
- `GET /dashboard/summary`
- `GET /dashboard/upcoming`
- `GET /notifications`
- `GET /subscription/status`

### Control panel relation
Dashboard metrics should match control panel reports and booking/payment status.

### Approval checklist
- [ ] Dashboard stats approved
- [ ] Add New Booking flow approved
- [ ] Role-based visibility approved

---

## Screen 06: Calendar & Slots

### Purpose
Shows monthly availability and slot capacity, and acts as the first step after tapping Add New Booking from the Home Dashboard.

### Main user actions
- Change month
- Select date
- View morning/evening/night slot availability
- Tap View Day Bookings
- Select available slot before entering booking information

### Fields / UI components
- Month calendar
- Day color states: Available, Partially Booked, Fully Booked
- Selected date
- Slot cards: Morning, Evening, Night
- Slot status badge
- Available slot count
- View Day Bookings button

### Rules and validations
- Fully booked slots cannot be selected for new booking unless owner override is approved.
- Selected date and slot must be passed into the Add New Booking screen.
- Calendar should show real capacity from backend.
- Past dates should be blocked or require explicit approval.
- Slot status should update after booking creation/cancellation.

### Backend / API data needed
- `GET /calendar/month?month=YYYY-MM`
- `GET /calendar/day?date=YYYY-MM-DD`
- `GET /calendar/day-bookings?date=YYYY-MM-DD`

### Control panel relation
Control panel should allow owner/admin to configure slot names, time ranges, capacity, blocked dates, and special availability.

### Approval checklist
- [ ] Slot names approved
- [ ] Capacity rules approved
- [ ] Date-first booking flow approved

---

## Screen 07: Add New Booking

### Purpose
Creates the booking information after the user has already selected the event date and slot from Calendar & Slots.

### Main user actions
- Enter customer details
- Confirm selected date/slot
- Select event type
- Enter guest count
- Select package
- Enter advance payment
- View remaining payment auto-calculation
- Select booking status
- Add notes
- Save booking

### Fields / UI components
- Customer name
- Phone number
- Event date, prefilled from Calendar & Slots
- Slot, prefilled from Calendar & Slots
- Event type dropdown
- Guest count
- Package dropdown
- Advance payment
- Remaining payment, auto-calculated
- Booking status
- Notes
- Save Booking button

### Rules and validations
- Customer name is required.
- Pakistani phone number is required and must be valid.
- Event date and slot are required and should come from selected calendar slot.
- Guest count must be numeric and greater than zero.
- Advance payment cannot exceed package/total amount.
- Remaining payment should auto-calculate.
- Save button should be disabled while request is in progress.
- Booking code should be generated automatically.

### Backend / API data needed
- `GET /packages`
- `GET /event-types`
- `POST /bookings`
- `POST /customers` or create customer inside booking API
- `POST /booking-payments` if advance payment is entered

### Control panel relation
Control panel should show newly created booking immediately and allow edit/status/payment updates.

### Approval checklist
- [ ] Required fields approved
- [ ] Payment calculation approved
- [ ] Booking status default approved

---

## Screen 08: Booking List / Search

### Purpose
Allows users to search, filter, sort, and open bookings quickly.

### Main user actions
- Search by name, phone, or booking ID
- Filter by booking status
- Filter by payment status
- Filter by event type
- Sort by latest/oldest/date
- Call customer
- Open booking details

### Fields / UI components
- Search bar
- Filter icon
- Booking Status filter
- Payment Status filter
- Event Type filter
- Clear All
- Sort dropdown
- Booking result cards
- Call button

### Rules and validations
- Search should work across all pages, not only currently loaded results.
- Filters should combine correctly.
- Clear All should reset all filters.
- Long names should wrap or truncate safely with tooltip/details screen.
- Cancelled/refunded statuses should display correctly.

### Backend / API data needed
- `GET /bookings?search=&booking_status=&payment_status=&event_type=&sort=&page=`

### Control panel relation
Control panel booking list should use same statuses and filters, with additional export option.

### Approval checklist
- [ ] Filter fields approved
- [ ] Status badge colors approved
- [ ] Search behavior approved

---

## Screen 09: Booking Details

### Purpose
Displays complete booking information and gives quick actions for contact, edit, and share.

### Main user actions
- View customer and event details
- Call customer
- Open WhatsApp
- Edit booking
- Share details
- View payment status

### Fields / UI components
- Customer name
- Phone number
- WhatsApp button
- Call button
- Event date
- Slot
- Guest count
- Event type
- Package
- Payment status
- Advance paid
- Remaining amount
- Notes
- Booking status
- Edit Booking button
- Share Details button

### Rules and validations
- Amounts must show PKR when Pakistan currency is used.
- Payment status should match recorded payment amounts.
- Share Details should use approved format.
- Edit button visibility should depend on role permission.
- Notes should wrap cleanly.

### Backend / API data needed
- `GET /bookings/{id}`
- `PATCH /bookings/{id}`
- `GET /payments?booking_id=`
- `POST /share/booking-details` if share generation is backend-based

### Control panel relation
Same booking details should be available from control panel with audit log and admin actions.

### Approval checklist
- [ ] Detail fields approved
- [ ] Share format approved
- [ ] Edit permission approved

---

## Screen 10: Payments

### Purpose
Shows payment overview and lets the user record new payments against bookings.

### Main user actions
- View total received
- View pending payments
- View partial payments
- Filter by status
- Open booking payment details
- Record payment

### Fields / UI components
- Date filter
- Total Received card
- Pending Payments card
- Partial Payments card
- Bookings list
- Payment amount
- Payment status badge
- Record Payment button

### Rules and validations
- Amounts should display in PKR.
- Payment totals should be calculated from backend records.
- Record payment should not allow negative or zero amount.
- Payment amount cannot exceed remaining amount unless overpayment rule is approved.
- Payment status should update booking details.

### Backend / API data needed
- `GET /payments/summary`
- `GET /payments`
- `POST /booking-payments`
- `PATCH /payments/{id}`

### Control panel relation
Control panel should include payment ledger, booking-wise payment history, manual adjustments, and reports.

### Approval checklist
- [ ] Payment statuses approved
- [ ] Record payment flow approved
- [ ] Overpayment rule approved

---

## Screen 11: Team Members

### Purpose
Allows the owner to see current plan usage and manage people under the business account.

### Main user actions
- View current plan and used member count
- Add Manager or Waiter Head
- Edit role/permissions
- Deactivate team member access
- Upgrade plan when member limit is reached

### Fields / UI components
- Current plan name
- Member usage counter: used / limit
- Member list cards
- Role badges: Owner, Manager, Waiter Head
- Invite Team Member button
- Upgrade CTA when limit is reached

### Role rules
- Owner has full access and cannot be removed by Manager/Waiter Head.
- Manager can manage bookings/events/payments only if permission is enabled.
- Waiter Head can view assigned events/tasks and update assigned operational status.
- Permissions should be stored in `permissions_json` for flexible future changes.

### Backend / API data needed
- `GET /team/members`
- `GET /team/usage`
- `PATCH /team/members/{id}`
- `DELETE /team/members/{id}` or `PATCH status=inactive`
- `GET /subscription/status`

### Approval checklist
- [ ] Team roles approved
- [ ] Permission list approved
- [ ] Member limit behavior approved

---

## Screen 12: Invite Team Member

### Purpose
Owner sends an invitation to add a Manager or Waiter Head under the business account.

### Main user actions
- Enter full name
- Select role
- Enter Pakistani mobile number
- Select permissions
- Send invite
- View validation or upgrade message

### Fields / UI components
- Full name
- Role dropdown
- Pakistani mobile number
- Permissions checklist
- Send Invite button
- Plan limit warning

### Important decision
Email field is removed. Team invite should use only:

- Full name
- Role
- Phone number
- Permissions

### Rules and validations
- Only Owner can invite new members by default.
- Do not allow duplicate Pakistani mobile number in the same business.
- Validate Pakistani mobile format before invite.
- Role is required.
- Block invite if active member count has reached subscription user_limit.
- Invite token should expire after configured time.
- Invited user should accept invite by phone number and create password securely.

### Backend / API data needed
- `POST /team/invite` with payload: `name`, `role`, `phone`, `permissions`
- `GET /team/invites`
- `POST /team/invites/{token}/accept`
- `POST /team/invites/{id}/resend`
- `DELETE /team/invites/{id}`

### Approval checklist
- [ ] Invite fields approved: name, role, Pakistani mobile number
- [ ] Manager permissions approved
- [ ] Waiter Head permissions approved
- [ ] Invite expiry rule approved

---

# Control Panel Screen Plan

| Control Panel Screen | Purpose | Main Features |
|---|---|---|
| Admin Login | Secure access for owner/admin/manager | Email/phone login, forgot password, role-aware redirect |
| Dashboard | Business overview | Booking trends, revenue, pending payments, upcoming events |
| Businesses | Super admin business management | Active businesses, subscription status, owner info |
| Subscription Plans | Manage pricing and features | PKR prices, user limits, trial days, active/inactive plans |
| Custom Plan Requests | Manage requests above 6 persons | Requested team size, owner contact, notes, approve/reject/follow-up status |
| Bookings | Full booking management | CRUD, filters, status changes, assignment, export |
| Calendar & Slots | Availability control | Slot capacity, blocked dates, special days, overbooking control |
| Customers | Customer management | Contact details, booking history, notes |
| Packages | Package management | Package name, pricing, inclusions, active/inactive |
| Payments | Payment ledger | Amounts, status, manual payment confirmation, payment report |
| Team Members | Role management | Invite Manager/Waiter Head, permissions, deactivate users |
| Notifications | Communication | Booking reminders, payment reminders, subscription expiry alerts |
| Reports | Business reporting | Monthly revenue, bookings by status, payment status, export |
| Settings | Business settings | Profile, currency, tax/service charges, branding, terms |

---

# API Endpoints Draft

| Module | Example Endpoints |
|---|---|
| Auth | `POST /auth/register`, `POST /auth/login`, `POST /auth/logout`, `POST /auth/forgot-password`, `GET /auth/me` |
| Business | `GET /business/current`, `PATCH /business/current`, `GET /business/settings`, `PATCH /business/settings` |
| Subscriptions | `GET /subscription/plans?currency=PKR`, `POST /subscription/start-trial`, `GET /subscription/status`, `POST /subscription/checkout`, `GET /team/usage`, `POST /subscription/custom-plan-request` |
| Dashboard | `GET /dashboard/summary`, `GET /dashboard/revenue`, `GET /dashboard/upcoming` |
| Bookings | `GET /bookings`, `POST /bookings`, `GET /bookings/{id}`, `PATCH /bookings/{id}`, `DELETE /bookings/{id}` |
| Customers | `GET /customers`, `POST /customers`, `GET /customers/{id}`, `PATCH /customers/{id}` |
| Calendar | `GET /calendar/month`, `GET /calendar/day`, `POST /calendar/slots`, `PATCH /calendar/slots/{id}` |
| Payments | `GET /payments/summary`, `GET /payments`, `POST /booking-payments`, `PATCH /payments/{id}` |
| Packages | `GET /packages`, `POST /packages`, `PATCH /packages/{id}`, `DELETE /packages/{id}` |
| Team | `GET /team/members`, `GET /team/usage`, `POST /team/invite`, `PATCH /team/members/{id}`, `GET /team/invites` |
| Notifications | `GET /notifications`, `PATCH /notifications/{id}/read`, `POST /notifications/send` |
| Reports | `GET /reports/bookings`, `GET /reports/payments`, `GET /reports/export` |

---

# Validation and Business Rules to Finalize

1. Final currency for Pakistan launch is **PKR**. All app, control panel, invoice, subscription, and payment screens should show PKR consistently.
2. Approved monthly subscription prices:
   - PKR 999 for 1 person
   - PKR 1,799 for up to 3 persons
   - PKR 2,500 for up to 6 persons
   - Request Custom Plan for more than 6 persons
3. Trial duration still needs approval.
4. Manager and Waiter Head registration must require owner invitation.
5. Direct public signup should create only an Owner/business account unless admin-approved.
6. Booking statuses should be standardized: Pending, Confirmed, Cancelled, Completed, Refunded if needed.
7. Payment statuses should be standardized: Unpaid, Advance Paid, Partially Paid, Fully Paid, Refunded.
8. Slot capacity must be configurable and must prevent overbooking unless owner override is approved.
9. Share Details output must be finalized: WhatsApp text, PDF, image, or system share sheet.
10. Notification logic must be finalized: booking created, booking reminder, payment due, subscription expiry, staff assignment.

---

# QA Plan Before Release

| Testing Area | What QA Should Verify |
|---|---|
| UI / Responsive | All screens fit small Android and iPhone devices; no text overflow; keyboard does not hide important fields; status badges align properly. |
| Authentication | Login, logout, session expiry, invalid credentials, forgot password, role-aware redirect. |
| Subscription | PKR prices, trial status, expired state, plan upgrade, member limit, custom plan request. |
| Team Members | Owner invite flow, duplicate phone validation, member limit enforcement, role permission behavior. |
| Calendar & Slots | Date selection, slot capacity, fully booked restriction, month navigation, past date behavior. |
| Booking Flow | Date-first flow, required fields, payment calculation, save booking, status update, edit booking. |
| Payments | Record payment, partial/full status update, invalid amount validation, PKR display. |
| Search / Filters | Search across all bookings, filters combined correctly, clear all, pagination. |
| Control Panel | Data sync with app, CRUD operations, reports, custom plan requests, subscription management. |
| Security | Role-based access, API authorization, secure password handling, token storage. |
| Performance | Dashboard loading, booking list loading, calendar loading, large booking records. |

---

# Ready-to-Use Cursor Build Instruction

Use this prompt in Cursor after approval:

```text
Create the MarqueeFlow project as an API-first platform with Flutter mobile app, web control panel, backend API, and MySQL database.

Use the approved screen plan v1.4 as the source of truth.

Core requirements:
1. Mobile app in Flutter with reusable MarqueeFlow design system.
2. Backend API using Node.js/Express or Laravel, connected to MySQL.
3. Web control panel for business/admin management.
4. Currency must be PKR for Pakistan launch.
5. Subscription plans:
   - Basic: PKR 999/month, 1 person total.
   - Standard: PKR 1,799/month, up to 3 persons total.
   - Premium: PKR 2,500/month, up to 6 persons total.
   - Request Custom Plan for more than 6 persons.
6. Owner is counted in the member limit.
7. Owner can invite Manager and Waiter Head only within plan user limit.
8. Invite Team Member screen must include only full name, role, phone number, and permissions. Do not include email field.
9. Add New Booking button must open Calendar & Slots first. After selecting date and slot, open Add New Booking form with selected date/slot prefilled.
10. Build backend validation for subscription member limits, duplicate phone number, required fields, and role permissions.
11. Keep code modular, clean, and ready for future Hostinger deployment.

Start with project structure, database schema, API route plan, Flutter theme, and reusable widgets. Do not implement all screens in one step. Build phase by phase.
```

---

# Final Pre-Development Checklist

- [ ] Approve all 12 mobile screens or mark changes required in the approval matrix.
- [ ] Finalize subscription member-limit behavior: owner counted in limit, invite blocked at limit, upgrade prompt shown.
- [ ] Finalize custom plan request flow and control panel handling.
- [ ] Finalize control panel modules, Manager permissions, and Waiter Head permissions.
- [ ] Finalize backend stack: Node.js + MySQL or Laravel + MySQL.
- [ ] Finalize Pakistan payment/subscription provider, manual payment fallback, and PKR invoice format.
- [ ] Finalize status names, package fields, slot capacity rules, and share format.
- [ ] Prepare brand assets: logo PNG/SVG, floral assets, icons, fonts, color codes.
- [ ] Create Git repository before coding and keep separate branches for backend, mobile, and control panel work.

---

# Pakistan Subscription and Team Access Technical Decision

| Item | Decision |
|---|---|
| Currency | PKR for Pakistan launch. Store `currency_code` on plans/businesses and render formatted PKR values everywhere. |
| Monthly plans | Basic: PKR 999 / 1 person. Standard: PKR 1,799 / up to 3 persons. Premium: PKR 2,500 / up to 6 persons. Add a Request Custom Plan option for businesses needing more than 6 persons. |
| Person limit rule | The owner is included in the count. Example: Standard plan allows owner + 2 invited users. |
| Allowed invited roles | Manager and Waiter Head. Future roles can be added through `permissions_json` without database redesign. |
| Enforcement point | Backend must enforce `user_limit` on `POST /team/invite` and subscription middleware. Invite payload must use name, role, Pakistani phone number, and permissions only. Email is not required for team invite. Custom-plan requests should be stored and manageable from the control panel. |

---

# Reference Notes

- Hostinger Business may be used for MVP backend/admin deployment if runtime limits are acceptable.
- MySQL is the recommended first database for the Hostinger MVP setup.
- Hosting limits and supported runtime details should be rechecked before final production deployment.
