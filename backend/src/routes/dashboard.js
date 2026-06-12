import { Router } from "express";
import { db } from "../db/store.js";
import { requireAuth } from "../middleware/auth.js";

export const dashboardRouter = Router();

dashboardRouter.get("/summary", requireAuth, (req, res) => {
  res.json(db.getDashboardSummary(req.businessId));
});

dashboardRouter.get("/upcoming", requireAuth, (req, res) => {
  const summary = db.getDashboardSummary(req.businessId);
  res.json({ upcoming: summary.upcoming });
});
