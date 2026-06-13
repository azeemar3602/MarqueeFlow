import { Router } from "express";
import { db } from "../db/store.js";
import { hashPassword } from "../lib/password.js";
import { isValidPkPhone, normalizePkPhone } from "../lib/phone.js";
import { requireAdminAuth, requireAdminRole } from "../middleware/adminAuth.js";
import { requireAdminWrite } from "../middleware/permissions.js";

export const adminRouter = Router();

adminRouter.get("/dashboard", requireAdminAuth, (_req, res) => {
  res.json(db.getPlatformDashboard());
});

adminRouter.get("/marquees", requireAdminAuth, (_req, res) => {
  res.json({ marquees: db.listMarqueesAdmin() });
});

adminRouter.get("/marquees/:id", requireAdminAuth, (req, res) => {
  const detail = db.getMarqueeAdminDetail(req.params.id);
  if (!detail) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Marquee not found" } });
  res.json(detail);
});

adminRouter.patch("/marquees/:id/approval", requireAdminAuth, requireAdminWrite, requireAdminRole("super_admin", "support_admin"), (req, res) => {
  const { approvalStatus } = req.body || {};
  const business = db.updateMarqueeApproval(req.params.id, approvalStatus, req.admin);
  if (!business) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Marquee not found" } });
  if (approvalStatus === "approved") {
    const status = db.getSubscriptionStatus(req.params.id);
    if (status.status === "none") {
      db.startTrial(req.params.id, "basic");
    }
  }
  res.json({ business });
});

adminRouter.post("/marquees/:id/extend-subscription", requireAdminAuth, requireAdminWrite, requireAdminRole("super_admin", "finance_admin"), (req, res) => {
  const days = Number(req.body?.days || 30);
  const sub = db.extendSubscription(req.params.id, days, req.admin);
  if (!sub) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Subscription not found" } });
  res.json({ subscription: sub });
});

adminRouter.get("/approvals", requireAdminAuth, (_req, res) => {
  const marquees = db.listMarqueesAdmin().filter((m) => m.approvalStatus === "pending");
  res.json({ approvals: marquees });
});

adminRouter.get("/subscription-plans", requireAdminAuth, (_req, res) => {
  res.json({ plans: db.getPlans("PKR") });
});

adminRouter.get("/subscriptions", requireAdminAuth, (_req, res) => {
  res.json({ subscriptions: db.listSubscriptionsAdmin() });
});

adminRouter.get("/custom-plan-requests", requireAdminAuth, (_req, res) => {
  res.json({ requests: db.listCustomPlanRequests() });
});

adminRouter.patch("/custom-plan-requests/:id", requireAdminAuth, requireAdminWrite, requireAdminRole("super_admin", "support_admin"), (req, res) => {
  const reqRow = db.updateCustomPlanRequest(req.params.id, req.body?.status || "approved");
  if (!reqRow) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Request not found" } });
  db.addAuditLog({
    adminId: req.admin.id,
    adminName: req.admin.name,
    action: `custom_plan_${req.body?.status || "updated"}`,
    module: "custom_plans",
    targetId: req.params.id
  });
  res.json({ request: reqRow });
});

adminRouter.get("/payments", requireAdminAuth, (req, res) => {
  res.json({ payments: db.listSubscriptionPaymentsAdmin(req.query) });
});

adminRouter.patch("/payments/:id/confirm", requireAdminAuth, requireAdminWrite, requireAdminRole("super_admin", "finance_admin"), (req, res) => {
  const payment = db.confirmSubscriptionPayment(req.params.id, req.admin, req.body?.note);
  if (!payment) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Payment not found" } });
  res.json({ payment });
});

adminRouter.patch("/payments/:id/reject", requireAdminAuth, requireAdminWrite, requireAdminRole("super_admin", "finance_admin"), (req, res) => {
  const payment = db.rejectSubscriptionPayment(req.params.id, req.admin, req.body?.note);
  if (!payment) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Payment not found" } });
  res.json({ payment });
});

adminRouter.post("/admin-users", requireAdminAuth, requireAdminWrite, requireAdminRole("super_admin"), async (req, res) => {
  const { name, phone, password, role = "support_admin" } = req.body || {};
  if (!name || !phone || !password) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "name, phone, password required" } });
  }
  if (!isValidPkPhone(phone)) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "Invalid phone" } });
  }
  if (db.findAdminByPhone(normalizePkPhone(phone))) {
    return res.status(409).json({ error: { code: "DUPLICATE", message: "Admin phone already exists" } });
  }
  const passwordHash = await hashPassword(password);
  const admin = db.createAdminUser({ name, phone: normalizePkPhone(phone), passwordHash, role });
  db.addAuditLog({
    adminId: req.admin.id,
    adminName: req.admin.name,
    action: "admin_user_created",
    module: "admin_users",
    targetId: admin.id
  });
  res.status(201).json({ admin: { id: admin.id, name: admin.name, phone: admin.phone, role: admin.role, status: admin.status } });
});

adminRouter.patch("/admin-users/:id", requireAdminAuth, requireAdminWrite, requireAdminRole("super_admin"), (req, res) => {
  const admin = db.updateAdminUser(req.params.id, req.body || {}, req.admin);
  if (!admin) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Admin user not found" } });
  res.json({ admin });
});

adminRouter.get("/bookings", requireAdminAuth, (req, res) => {
  const businessId = req.query.businessId;
  const bookings = businessId
    ? db.listBookings(businessId, req.query)
    : storeAllBookings();
  res.json({ bookings });
});

adminRouter.get("/customers", requireAdminAuth, (req, res) => {
  const businessId = req.query.businessId;
  const customers = businessId
    ? db.getMarqueeAdminDetail(businessId)?.customers || []
    : allCustomers();
  res.json({ customers });
});

adminRouter.get("/team-members", requireAdminAuth, (req, res) => {
  const businessId = req.query.businessId;
  if (!businessId) return res.json({ members: allTeamMembers() });
  res.json({ members: db.getTeamMembers(businessId) });
});

adminRouter.get("/packages", requireAdminAuth, (req, res) => {
  const businessId = req.query.businessId;
  if (!businessId) return res.json({ packages: allPackages() });
  res.json({ packages: db.getMarqueeAdminDetail(businessId)?.packages || [] });
});

adminRouter.get("/calendar-slots", requireAdminAuth, (req, res) => {
  const { businessId, month } = req.query;
  if (!businessId || !month) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "businessId and month required" } });
  }
  res.json(db.getCalendarMonth(businessId, month));
});

adminRouter.get("/admin-users", requireAdminAuth, requireAdminRole("super_admin"), (_req, res) => {
  res.json({ admins: db.listAdminUsers() });
});

adminRouter.get("/settings", requireAdminAuth, (_req, res) => {
  res.json({ settings: db.getSettings() });
});

adminRouter.patch("/settings", requireAdminAuth, requireAdminWrite, requireAdminRole("super_admin"), (req, res) => {
  res.json({ settings: db.updateSettings(req.body || {}, req.admin) });
});

adminRouter.get("/audit-logs", requireAdminAuth, (_req, res) => {
  res.json({ logs: db.listAuditLogs() });
});

function storeAllBookings() {
  return db.listBusinesses().flatMap((b) => db.listBookings(b.id, {}));
}

function allCustomers() {
  return db.listBusinesses().flatMap((b) => db.getMarqueeAdminDetail(b.id)?.customers || []);
}

function allTeamMembers() {
  return db.listBusinesses().flatMap((b) => db.getTeamMembers(b.id));
}

function allPackages() {
  return db.listBusinesses().flatMap((b) => db.getMarqueeAdminDetail(b.id)?.packages || []);
}
