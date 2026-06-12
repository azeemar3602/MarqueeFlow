import { Router } from "express";
import { db } from "../db/store.js";
import { requireAuth } from "../middleware/auth.js";

export const notificationsRouter = Router();

notificationsRouter.get("/", requireAuth, (req, res) => {
  res.json({ notifications: db.listNotifications(req.businessId, req.user.id) });
});

notificationsRouter.patch("/:id/read", requireAuth, (req, res) => {
  const n = db.markNotificationRead(req.params.id);
  res.json({ notification: n });
});
