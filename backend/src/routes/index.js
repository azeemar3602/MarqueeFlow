import { Router } from "express";
import { healthRouter } from "./health.js";
import { plansRouter } from "./plans.js";
import { rolesRouter } from "./roles.js";

export const apiRouter = Router();

apiRouter.use("/health", healthRouter);
apiRouter.use("/plans", plansRouter);
apiRouter.use("/roles", rolesRouter);
