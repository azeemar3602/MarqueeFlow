import { requireAuth } from "./auth.js";

export function requireAdminWrite(req, res, next) {
  if (req.admin?.role === "read_only_admin") {
    return res.status(403).json({ error: { code: "FORBIDDEN", message: "Read-only admin cannot modify data" } });
  }
  next();
}

export function requirePackageManage(req, res, next) {
  if (req.user.role === "owner") return next();
  const perms = req.permissions || {};
  if (perms.fullAccess || perms.managePackages) return next();
  return res.status(403).json({ error: { code: "FORBIDDEN", message: "Package management not permitted" } });
}

export function attachUserPermissions(req, _res, next) {
  if (!req.user) return next();
  if (req.user.role === "owner") {
    req.permissions = { fullAccess: true, managePackages: true };
    return next();
  }
  const member = req.teamMember;
  req.permissions = member?.permissionsJson || member?.permissions || {};
  next();
}
