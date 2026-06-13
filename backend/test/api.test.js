import test from "node:test";
import assert from "node:assert/strict";
import request from "supertest";
import { createApp } from "../src/app.js";

test("GET /health returns ok", async () => {
  const app = createApp();
  const res = await request(app).get("/health");
  assert.equal(res.status, 200);
  assert.equal(res.body.status, "ok");
});

test("GET /api/plans returns PKR pricing", async () => {
  const app = createApp();
  const res = await request(app).get("/api/plans");
  assert.equal(res.status, 200);
  assert.ok(Array.isArray(res.body.plans));
  assert.equal(res.body.plans[0].id, "basic");
  assert.equal(res.body.plans[0].pricePkr, 999);
});

test("POST /api/auth/register-owner creates account", async () => {
  const app = createApp();
  const phone = `03${Date.now().toString().slice(-9)}`;
  const res = await request(app).post("/api/auth/register-owner").send({
    name: "Test Owner",
    phone,
    password: "secret123",
    businessName: "Test Marquee"
  });
  assert.equal(res.status, 201);
  assert.ok(res.body.token);
  assert.equal(res.body.user.role, "owner");
});

test("GET /api/subscription/plans includes custom plan", async () => {
  const app = createApp();
  const res = await request(app).get("/api/subscription/plans?currency=PKR");
  assert.equal(res.status, 200);
  const custom = res.body.plans.find((p) => p.id === "custom");
  assert.ok(custom);
  assert.equal(custom.requestCustom, true);
});

test("admin token cannot access APK routes", async () => {
  const app = createApp();
  const { signToken } = await import("../src/lib/jwt.js");
  const token = signToken({ sub: "admin-id", kind: "admin", role: "super_admin" });
  const res = await request(app).get("/api/dashboard/summary").set("Authorization", `Bearer ${token}`);
  assert.equal(res.status, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("pending business cannot access dashboard API", async () => {
  const app = createApp();
  const phone = `03${Date.now().toString().slice(-9)}`;
  const register = await request(app).post("/api/auth/register-owner").send({
    name: "Pending Owner",
    phone,
    password: "secret123",
    businessName: "Pending Marquee"
  });
  assert.equal(register.status, 201);
  assert.equal(register.body.business.approvalStatus, "pending");
  const res = await request(app)
    .get("/api/dashboard/summary")
    .set("Authorization", `Bearer ${register.body.token}`);
  assert.equal(res.status, 403);
  assert.equal(res.body.error.code, "BUSINESS_PENDING");
});

test("pending business can still call /api/auth/me", async () => {
  const app = createApp();
  const phone = `03${Date.now().toString().slice(-9)}`;
  const register = await request(app).post("/api/auth/register-owner").send({
    name: "Pending Owner",
    phone,
    password: "secret123",
    businessName: "Pending Marquee"
  });
  const res = await request(app)
    .get("/api/auth/me")
    .set("Authorization", `Bearer ${register.body.token}`);
  assert.equal(res.status, 200);
  assert.equal(res.body.business.approvalStatus, "pending");
});

test("POST /api/public/demo-request stores website lead", async () => {
  const app = createApp();
  const phone = `03${Date.now().toString().slice(-9)}`;
  const res = await request(app).post("/api/public/demo-request").send({
    name: "Website Lead",
    businessName: "Royal Garden",
    phone,
    city: "Lahore",
    teamSize: 3,
    message: "Need a demo"
  });
  assert.equal(res.status, 201);
  assert.ok(res.body.request.id);
});

test("approved owner can create booking with package and slot", async () => {
  const app = createApp();
  const { db } = await import("../src/db/store.js");
  const phone = `03${Date.now().toString().slice(-9)}`;
  const register = await request(app).post("/api/auth/register-owner").send({
    name: "Booking Owner",
    phone,
    password: "secret123",
    businessName: "Booking Test Marquee"
  });
  assert.equal(register.status, 201);
  const token = register.body.token;
  const businessId = register.body.business.id;
  db.updateMarqueeApproval(businessId, "approved", { id: "test-admin", name: "Test Admin" });

  const today = new Date().toISOString().slice(0, 10);
  const dayRes = await request(app)
    .get(`/api/calendar/day?date=${today}`)
    .set("Authorization", `Bearer ${token}`);
  assert.equal(dayRes.status, 200);
  assert.ok(dayRes.body.slots?.length > 0);
  const slot = dayRes.body.slots[0];

  const packagesRes = await request(app).get("/api/packages").set("Authorization", `Bearer ${token}`);
  assert.equal(packagesRes.status, 200);
  assert.ok(packagesRes.body.packages?.length > 0);
  const pkg = packagesRes.body.packages[0];

  const createRes = await request(app)
    .post("/api/bookings")
    .set("Authorization", `Bearer ${token}`)
    .send({
      customerName: "Ali Khan",
      customerPhone: "03001234567",
      eventDate: today,
      slotId: slot.id,
      eventType: "Walima",
      guestCount: 100,
      packageId: pkg.id,
      advancePayment: 50000
    });
  assert.equal(createRes.status, 201);
  assert.equal(createRes.body.booking.customerName, "Ali Khan");
  assert.equal(createRes.body.booking.advancePaid, 50000);
  assert.ok(createRes.body.booking.remainingAmount > 0);

  const detail = await request(app)
    .get(`/api/bookings/${createRes.body.booking.id}`)
    .set("Authorization", `Bearer ${token}`);
  assert.equal(detail.status, 200);
  assert.equal(detail.body.booking.package?.id, pkg.id);
});
