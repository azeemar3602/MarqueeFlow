# Website Local QA — marqueeflow.com

**Review date:** 2026-06-13  
**Status:** Ready for local review — **production deploy not started**

---

## Summary

The public marketing website is a **separate Vite app** in `website/`. It is not the Super Admin panel and not the APK. It uses the MarqueeFlow premium design (cream/burgundy/gold), is fully responsive, and includes all required sections plus Privacy/Terms pages.

---

## Screenshot folder

**Path:** `docs/website-screenshots/`  
**Status:** ✅ **Captured** (2026-06-13 via Playwright)

| File | Status |
|------|--------|
| `01-home-hero.png` | ✅ Captured |
| `02-home-features-pricing.png` | ✅ Captured |
| `03-home-how-it-works.png` | ✅ Captured |
| `04-home-demo-form.png` | ✅ Captured |
| `05-home-mobile.png` | ✅ Captured (390×844 mobile viewport) |
| `06-privacy.png` | ✅ Captured |
| `07-terms.png` | ✅ Captured |
| `08-footer-admin-link.png` | ✅ Captured |

**Recapture:** `node scripts/capture-review-screenshots.mjs`

---

## Sections implemented

| # | Section | Status |
|---|---------|--------|
| 1 | Home hero — logo, headline, subheadline, CTAs | ✅ |
| 2 | Features (7 cards) | ✅ |
| 3 | Pricing — Basic/Standard/Premium/Custom PKR | ✅ |
| 4 | How It Works (5 steps) | ✅ |
| 5 | App / platform preview mockups | ✅ CSS placeholders |
| 6 | Request Demo form | ✅ |
| 7 | Contact — WhatsApp, email, location | ✅ |
| 8 | Footer — Privacy, Terms, Admin Login | ✅ |

---

## Demo request form test

**Endpoint:** `POST /api/public/demo-request`

**Local test (after backend restart):**

```json
Request:  { "name":"QA Lead", "businessName":"Test Marquee Hall", "phone":"03005551234", "city":"Karachi", "teamSize":3, "message":"Local QA" }
Response: { "ok": true, "request": { "id": "...", "createdAt": "..." } }
Status:   201 Created
```

**Automated test:** `backend/test/api.test.js` — `POST /api/public/demo-request stores website lead` — **pass**

**Storage:** `demoRequests[]` in JSON store (`backend/src/db/store.js`)

**CORS:** Allows `marqueeflow.com`, `www.marqueeflow.com`, local dev origins.

**Website config:** `VITE_API_BASE_URL` (default `https://api.marqueeflow.com`) — see `website/.env.example`

---

## Separation confirmed

| Property | Value |
|----------|-------|
| App location | `website/` |
| Build output | `website/dist/` |
| Production domain | `marqueeflow.com` |
| Admin link in footer | `https://admin.marqueeflow.com` |
| Admin APIs exposed | **No** — only public demo endpoint |
| APK links | Informational only (no APK download wired yet) |

---

## Build status

| Command | Result |
|---------|--------|
| `cd website && npm run build` | ✅ Pass |
| Output | `website/dist/index.html`, `privacy.html`, `terms.html`, assets |

---

## Local preview

```powershell
cd backend; node src/server.js
cd website; npm run preview -- --host 127.0.0.1 --port 4012
# → http://127.0.0.1:4012/
```

---

## Known limitations

1. **App preview images** — CSS mockup placeholders; replace with real APK/admin screenshots when available.
2. **WhatsApp / email** — Configurable via `VITE_WHATSAPP_NUMBER`, `VITE_SUPPORT_EMAIL`; defaults are placeholders.
3. **Demo request admin UI** — Stored in backend; no Super Admin list page yet (data in `demoRequests`).
4. **APK download** — Not linked from website (distribution TBD).
5. **Screenshot recapture** — PNGs committed in `docs/website-screenshots/`; re-run Playwright script after UI changes.
6. **SSL nginx** — Only HTTP config in repo; production SSL uses existing cert path on VPS (see `docs/DEPLOYMENT.md`).

---

## Production deploy

**Not started.** Nginx config updated in repo to serve `website/dist` on `marqueeflow.com` (was incorrectly pointing to admin panel before).

**AluRate:** Untouched.
