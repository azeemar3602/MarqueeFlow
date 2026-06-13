import { Router } from "express";
import { db } from "../db/store.js";
import { requireAuth, requireActiveBusiness } from "../middleware/auth.js";

export const dashboardRouter = Router();

dashboardRouter.use(requireAuth, requireActiveBusiness);

dashboardRouter.get("/summary", (req, res) => {
  res.json(db.getDashboardSummary(req.businessId));
});

dashboardRouter.get("/upcoming", (req, res) => {
  const summary = db.getDashboardSummary(req.businessId);
  res.json({ upcoming: summary.upcoming });
});
