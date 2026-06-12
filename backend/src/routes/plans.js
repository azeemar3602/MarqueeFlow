import { Router } from "express";
import { db } from "../db/store.js";

export const plansRouter = Router();

plansRouter.get("/", (req, res) => {
  const currency = req.query.currency || "PKR";
  res.json({ plans: db.getPlans(currency) });
});
