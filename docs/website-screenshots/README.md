# Website Screenshot Capture Guide

Save PNG screenshots here before production deploy approval.

## Recommended filenames

| File | Local URL | What to capture |
|------|-----------|-----------------|
| `01-home-hero.png` | http://127.0.0.1:4012/ | Hero + CTAs (desktop) |
| `02-home-features-pricing.png` | http://127.0.0.1:4012/#pricing | Features + PKR pricing |
| `03-home-how-it-works.png` | http://127.0.0.1:4012/#how-it-works | 5-step flow |
| `04-home-demo-form.png` | http://127.0.0.1:4012/#demo | Request demo form |
| `05-home-mobile.png` | http://127.0.0.1:4012/ | Mobile viewport (~390px) |
| `06-privacy.png` | http://127.0.0.1:4012/privacy.html | Privacy policy |
| `07-terms.png` | http://127.0.0.1:4012/terms.html | Terms & conditions |
| `08-footer-admin-link.png` | http://127.0.0.1:4012/ | Footer Admin Login link |

## Start local preview

```powershell
cd backend; node src/server.js
cd website; npm run preview -- --host 127.0.0.1 --port 4012
```
