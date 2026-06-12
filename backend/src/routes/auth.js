import { Router } from "express";
import { db } from "../db/store.js";
import { hashPassword, verifyPassword } from "../lib/password.js";
import { signToken } from "../lib/jwt.js";
import { isValidPkPhone, normalizePkPhone } from "../lib/phone.js";
import { requireAuth } from "../middleware/auth.js";

export const authRouter = Router();

authRouter.post("/register-owner", async (req, res) => {
  const { name, phone, password, businessName, address } = req.body || {};
  if (!name || !phone || !password || !businessName) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "Missing required fields" } });
  }
  if (!isValidPkPhone(phone)) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "Invalid Pakistani phone number" } });
  }
  const normalized = normalizePkPhone(phone);
  if (db.findUserByPhone(normalized)) {
    return res.status(409).json({ error: { code: "DUPLICATE", message: "Phone already registered" } });
  }
  const passwordHash = await hashPassword(password);
  const { user, business } = db.createOwner({
    name,
    phone: normalized,
    passwordHash,
    businessName,
    address
  });
  db.seedPackagesIfEmpty(business.id);
  db.startTrial(business.id, "basic");
  const token = signToken({ sub: user.id, role: user.role, businessId: business.id });
  res.status(201).json({
    token,
    user: { id: user.id, name: user.name, phone: user.phone, role: user.role, businessId: business.id },
    business,
    subscription: db.getSubscriptionStatus(business.id)
  });
});

authRouter.post("/login", async (req, res) => {
  const { phone, password, role } = req.body || {};
  if (!phone || !password) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "Phone and password required" } });
  }
  const normalized = normalizePkPhone(phone);
  const user = db.findUserByPhone(normalized);
  if (!user || !(await verifyPassword(password, user.passwordHash))) {
    return res.status(401).json({ error: { code: "INVALID_CREDENTIALS", message: "Invalid credentials" } });
  }
  if (role && user.role !== role) {
    return res.status(403).json({ error: { code: "ROLE_MISMATCH", message: "Role does not match account" } });
  }
  const token = signToken({ sub: user.id, role: user.role, businessId: user.businessId });
  res.json({
    token,
    user: { id: user.id, name: user.name, phone: user.phone, role: user.role, businessId: user.businessId },
    subscription: db.getSubscriptionStatus(user.businessId)
  });
});

authRouter.get("/me", requireAuth, (req, res) => {
  const business = db.getBusiness(req.user.businessId);
  res.json({
    user: {
      id: req.user.id,
      name: req.user.name,
      phone: req.user.phone,
      role: req.user.role,
      businessId: req.user.businessId
    },
    business,
    subscription: db.getSubscriptionStatus(req.user.businessId)
  });
});

authRouter.post("/forgot-password", (_req, res) => {
  res.json({ ok: true, message: "If the account exists, reset instructions will be sent." });
});

authRouter.post("/logout", requireAuth, (_req, res) => {
  res.json({ ok: true });
});
