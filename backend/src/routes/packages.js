import { Router } from "express";
import { db } from "../db/store.js";
import { requireAuth, requireActiveBusiness } from "../middleware/auth.js";
import { attachUserPermissions, requirePackageManage } from "../middleware/permissions.js";

export const packagesRouter = Router();

packagesRouter.use(requireAuth, requireActiveBusiness, attachUserPermissions);

packagesRouter.get("/", (req, res) => {
  db.seedPackagesIfEmpty(req.businessId);
  const includeInactive = req.query.includeInactive === "true";
  res.json({ packages: db.listPackages(req.businessId, { includeInactive }) });
});

packagesRouter.post("/", requirePackageManage, (req, res) => {
  try {
    const pkg = db.createPackage(req.businessId, req.body || {});
    res.status(201).json({ package: pkg });
  } catch (err) {
    res.status(400).json({ error: { code: "VALIDATION", message: err.message } });
  }
});

packagesRouter.patch("/:id", requirePackageManage, (req, res) => {
  const pkg = db.updatePackage(req.params.id, req.businessId, req.body || {});
  if (!pkg) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Package not found" } });
  res.json({ package: pkg });
});

packagesRouter.delete("/:id", requirePackageManage, (req, res) => {
  try {
    const pkg = db.deactivatePackage(req.params.id, req.businessId);
    if (!pkg) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Package not found" } });
    res.json({ package: pkg });
  } catch (err) {
    res.status(400).json({ error: { code: err.code || "PACKAGE_IN_USE", message: err.message } });
  }
});
