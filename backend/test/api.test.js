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
