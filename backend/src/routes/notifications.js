import { Router } from "express";
import { db } from "../db/store.js";
import { requireAuth, requireActiveBusiness } from "../middleware/auth.js";

export const notificationsRouter = Router();

notificationsRouter.use(requireAuth, requireActiveBusiness);

notificationsRouter.get("/", (req, res) => {
  res.json({ notifications: db.listNotifications(req.businessId, req.user.id) });
});

notificationsRouter.patch("/:id/read", (req, res) => {
  const n = db.markNotificationRead(req.params.id);
  res.json({ notification: n });
});
