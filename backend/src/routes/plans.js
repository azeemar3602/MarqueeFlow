import { Router } from "express";
import { SUBSCRIPTION_PLANS } from "../data/plans.js";

export const plansRouter = Router();

plansRouter.get("/", (_req, res) => {
  res.json({ plans: SUBSCRIPTION_PLANS });
});
