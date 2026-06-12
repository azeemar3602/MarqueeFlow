import { Router } from "express";
import { db } from "../db/store.js";
import { SUBSCRIPTION_PLANS } from "../data/plans.js";
import { ROLES } from "../data/roles.js";
import { authRouter } from "./auth.js";
import { subscriptionRouter } from "./subscription.js";
import { dashboardRouter } from "./dashboard.js";
import { bookingsRouter } from "./bookings.js";
import { calendarRouter } from "./calendar.js";
import { paymentsRouter } from "./payments.js";
import { packagesRouter } from "./packages.js";
import { teamRouter } from "./team.js";
import { notificationsRouter } from "./notifications.js";
import { adminRouter } from "./admin.js";
import { healthRouter } from "./health.js";

export const apiRouter = Router();

apiRouter.use(healthRouter);
apiRouter.use("/auth", authRouter);
apiRouter.use("/subscription", subscriptionRouter);
apiRouter.use("/dashboard", dashboardRouter);
apiRouter.use("/bookings", bookingsRouter);
apiRouter.use("/calendar", calendarRouter);
apiRouter.use("/payments", paymentsRouter);
apiRouter.use("/packages", packagesRouter);
apiRouter.use("/team", teamRouter);
apiRouter.use("/notifications", notificationsRouter);
apiRouter.use("/admin", adminRouter);

/** Legacy + alias routes */
apiRouter.get("/plans", (req, res) => {
  const currency = req.query.currency || "PKR";
  res.json({ plans: db.getPlans(currency) });
});

apiRouter.get("/roles", (_req, res) => {
  res.json({ roles: ROLES });
});

apiRouter.get("/subscription/plans", (req, res) => {
  const currency = req.query.currency || "PKR";
  res.json({ plans: SUBSCRIPTION_PLANS.filter((p) => p.currencyCode === currency) });
});
