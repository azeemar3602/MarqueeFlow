import { Router } from "express";
import { db } from "../db/store.js";
import { requireAuth } from "../middleware/auth.js";

export const packagesRouter = Router();

packagesRouter.get("/", requireAuth, (req, res) => {
  db.seedPackagesIfEmpty(req.businessId);
  res.json({ packages: db.listPackages(req.businessId) });
});
