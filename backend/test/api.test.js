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
  assert.equal(res.body.plans[0].pricePkr, 999);
});
