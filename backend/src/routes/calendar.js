import { Router } from "express";
import { db } from "../db/store.js";
import { requireAuth, requireActiveBusiness } from "../middleware/auth.js";

export const calendarRouter = Router();

calendarRouter.use(requireAuth, requireActiveBusiness);

calendarRouter.get("/month", (req, res) => {
  const month = req.query.month || new Date().toISOString().slice(0, 7);
  res.json(db.getCalendarMonth(req.businessId, month));
});

calendarRouter.get("/day", (req, res) => {
  const date = req.query.date;
  if (!date) return res.status(400).json({ error: { code: "VALIDATION", message: "date required" } });
  res.json(db.getCalendarDay(req.businessId, date));
});

calendarRouter.get("/day-bookings", (req, res) => {
  const date = req.query.date;
  if (!date) return res.status(400).json({ error: { code: "VALIDATION", message: "date required" } });
  res.json({ bookings: db.getDayBookings(req.businessId, date) });
});
