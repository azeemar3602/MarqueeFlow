import { Router } from "express";
import { db } from "../db/store.js";
import { signToken } from "../lib/jwt.js";
import { hashPassword, verifyPassword } from "../lib/password.js";
import { normalizePkPhone } from "../lib/phone.js";
import { requireAdminAuth } from "../middleware/adminAuth.js";

export const adminAuthRouter = Router();

adminAuthRouter.post("/login", async (req, res) => {
  const { phone, password } = req.body || {};
  if (!phone || !password) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "Phone and password required" } });
  }
  const normalized = normalizePkPhone(phone);
  const admin = db.findAdminByPhone(normalized);
  if (!admin) {
    const businessUser = db.findUserByPhone(normalized);
    if (businessUser && (await verifyPassword(password, businessUser.passwordHash))) {
      return res.status(403).json({
        error: { code: "FORBIDDEN", message: "Business accounts must use the MarqueeFlow mobile app." }
      });
    }
    return res.status(401).json({ error: { code: "INVALID_CREDENTIALS", message: "Invalid admin credentials" } });
  }
  if (admin.status !== "active") {
    return res.status(401).json({ error: { code: "INVALID_CREDENTIALS", message: "Invalid admin credentials" } });
  }
  const ok = await verifyPassword(password, admin.passwordHash);
  if (!ok) {
    return res.status(401).json({ error: { code: "INVALID_CREDENTIALS", message: "Invalid admin credentials" } });
  }
  db.addAuditLog({
    adminId: admin.id,
    adminName: admin.name,
    action: "admin_login",
    module: "auth",
    targetId: admin.id
  });
  const token = signToken({ sub: admin.id, kind: "admin", role: admin.role });
  res.json({ token, admin: { id: admin.id, name: admin.name, role: admin.role } });
});

adminAuthRouter.get("/me", requireAdminAuth, (req, res) => {
  res.json({ admin: { id: req.admin.id, name: req.admin.name, role: req.admin.role } });
});

adminAuthRouter.post("/logout", requireAdminAuth, (req, res) => {
  db.addAuditLog({
    adminId: req.admin.id,
    adminName: req.admin.name,
    action: "admin_logout",
    module: "auth",
    targetId: req.admin.id
  });
  res.json({ ok: true });
});
