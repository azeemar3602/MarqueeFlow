/**
 * Capture Phase 3 + website review screenshots for MarqueeFlow docs.
 * Usage: node scripts/capture-review-screenshots.mjs
 */
import { chromium } from "playwright";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");

const ADMIN_BASE = process.env.ADMIN_URL || "http://127.0.0.1:4011";
const WEBSITE_BASE = process.env.WEBSITE_URL || "http://127.0.0.1:4013";
const DEMO_MARQUEE_ID = "cad1713a-5f13-4608-bff7-5b1fe89c0f5b";
const ADMIN_PHONE = "03009999999";
const ADMIN_PASSWORD = "MarqueeFlowAdmin123";

const PHASE3_DIR = path.join(ROOT, "docs", "phase3-screenshots");
const WEBSITE_DIR = path.join(ROOT, "docs", "website-screenshots");

async function loginAdmin(page) {
  await page.goto(`${ADMIN_BASE}/login`, { waitUntil: "networkidle" });
  await page.getByLabel("Phone").fill(ADMIN_PHONE);
  await page.getByLabel("Password").fill(ADMIN_PASSWORD);
  await page.getByRole("button", { name: "Sign In" }).click();
  await page.waitForURL((url) => !url.pathname.includes("/login"), { timeout: 15000 });
  await page.waitForTimeout(800);
}

async function capturePhase3(browser) {
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  await page.goto(`${ADMIN_BASE}/login`, { waitUntil: "networkidle" });
  await page.screenshot({ path: path.join(PHASE3_DIR, "01-admin-login.png"), fullPage: false });

  await loginAdmin(page);
  await page.waitForSelector("h1", { timeout: 10000 });
  await page.screenshot({ path: path.join(PHASE3_DIR, "02-admin-dashboard.png"), fullPage: true });

  const detailUrl = `${ADMIN_BASE}/marquees/${DEMO_MARQUEE_ID}`;
  await page.goto(detailUrl, { waitUntil: "networkidle" });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: path.join(PHASE3_DIR, "03-marquee-detail-overview.png"), fullPage: true });

  await page.getByRole("button", { name: "Subscription" }).click();
  await page.waitForTimeout(600);
  await page.screenshot({ path: path.join(PHASE3_DIR, "04-marquee-detail-subscription.png"), fullPage: true });

  await page.getByRole("button", { name: "Payments" }).click();
  await page.waitForTimeout(600);
  await page.screenshot({ path: path.join(PHASE3_DIR, "05-marquee-detail-payments.png"), fullPage: true });

  await page.getByRole("button", { name: "Issues / Support" }).click();
  await page.waitForTimeout(600);
  await page.screenshot({ path: path.join(PHASE3_DIR, "06-marquee-detail-issues.png"), fullPage: true });

  await page.goto(`${ADMIN_BASE}/payments`, { waitUntil: "networkidle" });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: path.join(PHASE3_DIR, "07-payments-review.png"), fullPage: true });

  await page.goto(`${ADMIN_BASE}/admin-users`, { waitUntil: "networkidle" });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: path.join(PHASE3_DIR, "08-admin-users.png"), fullPage: true });

  await context.close();
}

async function captureWebsite(browser) {
  const desktop = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await desktop.newPage();

  await page.goto(`${WEBSITE_BASE}/`, { waitUntil: "networkidle" });
  await page.waitForTimeout(500);
  await page.screenshot({ path: path.join(WEBSITE_DIR, "01-home-hero.png"), fullPage: false });

  await page.locator("#features").scrollIntoViewIfNeeded();
  await page.waitForTimeout(400);
  await page.locator("#pricing").scrollIntoViewIfNeeded();
  await page.waitForTimeout(400);
  await page.screenshot({ path: path.join(WEBSITE_DIR, "02-home-features-pricing.png"), fullPage: false });

  await page.locator("#how-it-works").scrollIntoViewIfNeeded();
  await page.waitForTimeout(400);
  await page.screenshot({ path: path.join(WEBSITE_DIR, "03-home-how-it-works.png"), fullPage: false });

  await page.locator("#demo").scrollIntoViewIfNeeded();
  await page.waitForTimeout(400);
  await page.screenshot({ path: path.join(WEBSITE_DIR, "04-home-demo-form.png"), fullPage: false });

  await desktop.close();

  const mobile = await browser.newContext({
    viewport: { width: 390, height: 844 },
    isMobile: true,
    hasTouch: true
  });
  const mobilePage = await mobile.newPage();
  await mobilePage.goto(`${WEBSITE_BASE}/`, { waitUntil: "networkidle" });
  await mobilePage.waitForTimeout(500);
  await mobilePage.screenshot({ path: path.join(WEBSITE_DIR, "05-home-mobile.png"), fullPage: false });
  await mobile.close();

  const legal = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const legalPage = await legal.newPage();

  await legalPage.goto(`${WEBSITE_BASE}/privacy.html`, { waitUntil: "networkidle" });
  await legalPage.waitForTimeout(400);
  await legalPage.screenshot({ path: path.join(WEBSITE_DIR, "06-privacy.png"), fullPage: true });

  await legalPage.goto(`${WEBSITE_BASE}/terms.html`, { waitUntil: "networkidle" });
  await legalPage.waitForTimeout(400);
  await legalPage.screenshot({ path: path.join(WEBSITE_DIR, "07-terms.png"), fullPage: true });

  await legalPage.goto(`${WEBSITE_BASE}/`, { waitUntil: "networkidle" });
  await legalPage.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
  await legalPage.waitForTimeout(600);
  await legalPage.screenshot({ path: path.join(WEBSITE_DIR, "08-footer-admin-link.png"), fullPage: false });

  await legal.close();
}

async function main() {
  const browser = await chromium.launch({ headless: true });
  try {
    console.log("Capturing Phase 3 admin screenshots...");
    await capturePhase3(browser);
    console.log("Capturing website screenshots...");
    await captureWebsite(browser);
    console.log("Done.");
  } finally {
    await browser.close();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
