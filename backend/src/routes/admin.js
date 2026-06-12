import { Router } from "express";
import { db } from "../db/store.js";
import { requireAuth } from "../middleware/auth.js";

export const adminRouter = Router();

adminRouter.get("/businesses", requireAuth, (req, res) => {
  if (req.user.role !== "owner") {
    return res.status(403).json({ error: { code: "FORBIDDEN", message: "Owner only" } });
  }
  const businesses = db.listBusinesses().map((b) => ({
    ...b,
    subscription: db.getSubscriptionStatus(b.id)
  }));
  res.json({ businesses });
});

adminRouter.get("/reports/bookings", requireAuth, (req, res) => {
  const bookings = db.listBookings(req.businessId, req.query);
  res.json({ bookings, exportReady: true });
});

adminRouter.get("/reports/payments", requireAuth, (req, res) => {
  res.json({
    summary: db.getPaymentsSummary(req.businessId),
    payments: db.listPayments(req.businessId)
  });
});
