import { Router } from "express";
import { db } from "../db/store.js";
import { requireAuth, requireActiveBusiness, requireRole } from "../middleware/auth.js";
import { hashPassword } from "../lib/password.js";
import { isValidPkPhone, normalizePkPhone } from "../lib/phone.js";
import { DEFAULT_PERMISSIONS, INVITE_ROLES } from "../data/roles.js";

export const teamRouter = Router();

teamRouter.get("/members", requireAuth, requireActiveBusiness, (req, res) => {
  res.json({ members: db.getTeamMembers(req.businessId) });
});

teamRouter.get("/usage", requireAuth, requireActiveBusiness, (req, res) => {
  res.json(db.getTeamUsage(req.businessId));
});

teamRouter.get("/invites", requireAuth, requireActiveBusiness, requireRole("owner"), (req, res) => {
  res.json({ invites: db.listTeamInvites(req.businessId) });
});

teamRouter.post("/invite", requireAuth, requireActiveBusiness, requireRole("owner"), (req, res) => {
  const { name, phone, role, permissions } = req.body || {};
  if (!name || !phone || !role) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "name, role, phone required" } });
  }
  if (!INVITE_ROLES.includes(role)) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "Invalid invite role" } });
  }
  if (!isValidPkPhone(phone)) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "Invalid Pakistani phone" } });
  }
  try {
    const invite = db.createTeamInvite({
      businessId: req.businessId,
      name,
      phone: normalizePkPhone(phone),
      role,
      permissions: permissions || DEFAULT_PERMISSIONS[role],
      invitedBy: req.user.id
    });
    res.status(201).json({ invite });
  } catch (err) {
    const status = err.code === "MEMBER_LIMIT" ? 403 : 409;
    res.status(status).json({ error: { code: err.code, message: err.message } });
  }
});

teamRouter.get("/invites/:token", (req, res) => {
  const invite = db.getInviteByToken(req.params.token);
  if (!invite) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Invalid or expired invite" } });
  res.json({ invite: { name: invite.name, role: invite.role, phone: invite.phone, expiresAt: invite.expiresAt } });
});

teamRouter.post("/invites/:token/accept", async (req, res) => {
  const { password } = req.body || {};
  if (!password) return res.status(400).json({ error: { code: "VALIDATION", message: "Password required" } });
  const passwordHash = await hashPassword(password);
  const user = db.acceptInvite({ token: req.params.token, passwordHash });
  if (!user) return res.status(400).json({ error: { code: "INVALID_INVITE", message: "Invite invalid or expired" } });
  res.json({ user: { id: user.id, name: user.name, role: user.role } });
});

teamRouter.patch("/members/:id", requireAuth, requireActiveBusiness, requireRole("owner"), (req, res) => {
  const member = db.updateTeamMember(req.params.id, req.businessId, req.body || {});
  if (!member) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Member not found" } });
  res.json({ member });
});
