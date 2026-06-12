import { Router } from "express";
import { db } from "../db/store.js";
import { requireAuth, requireRole } from "../middleware/auth.js";
import { isValidPkPhone, normalizePkPhone } from "../lib/phone.js";

export const subscriptionRouter = Router();

subscriptionRouter.get("/plans", (req, res) => {
  const currency = req.query.currency || "PKR";
  res.json({ plans: db.getPlans(currency) });
});

subscriptionRouter.get("/status", requireAuth, (req, res) => {
  res.json(db.getSubscriptionStatus(req.businessId));
});

subscriptionRouter.post("/start-trial", requireAuth, requireRole("owner"), (req, res) => {
  const planId = req.body?.planId || "basic";
  const sub = db.startTrial(req.businessId, planId);
  res.json({ subscription: sub, status: db.getSubscriptionStatus(req.businessId) });
});

subscriptionRouter.post("/checkout", requireAuth, requireRole("owner"), (req, res) => {
  const { planId } = req.body || {};
  if (!planId || planId === "custom") {
    return res.status(400).json({ error: { code: "VALIDATION", message: "Valid planId required" } });
  }
  const sub = db.activatePlan(req.businessId, planId);
  res.json({ subscription: sub, status: db.getSubscriptionStatus(req.businessId), manualPayment: true });
});

subscriptionRouter.post("/custom-plan-request", requireAuth, requireRole("owner"), (req, res) => {
  const { requestedTeamSize, contactName, phone, note } = req.body || {};
  if (!requestedTeamSize || !contactName || !phone) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "Missing required fields" } });
  }
  if (!isValidPkPhone(phone)) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "Invalid phone" } });
  }
  const request = db.createCustomPlanRequest({
    businessId: req.businessId,
    requestedTeamSize: Number(requestedTeamSize),
    contactName,
    phone: normalizePkPhone(phone),
    note
  });
  res.status(201).json({ request });
});

/** Admin: list all custom plan requests */
subscriptionRouter.get("/custom-plan-requests", requireAuth, (req, res) => {
  const all = req.user.role === "owner";
  const list = db.listCustomPlanRequests(all ? null : req.businessId);
  res.json({ requests: list });
});

subscriptionRouter.patch("/custom-plan-requests/:id", requireAuth, requireRole("owner"), (req, res) => {
  const updated = db.updateCustomPlanRequest(req.params.id, req.body?.status);
  if (!updated) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Request not found" } });
  res.json({ request: updated });
});
