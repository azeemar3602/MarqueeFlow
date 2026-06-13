import { verifyToken } from "../lib/jwt.js";
import { db } from "../db/store.js";

export function requireAdminAuth(req, res, next) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) {
    return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Admin authentication required" } });
  }
  try {
    const payload = verifyToken(token);
    if (payload.kind !== "admin") {
      return res.status(403).json({ error: { code: "FORBIDDEN", message: "Super Admin access only" } });
    }
    const admin = db.findAdminById(payload.sub);
    if (!admin || admin.status !== "active") {
      return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Invalid admin session" } });
    }
    req.admin = admin;
    next();
  } catch {
    return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Invalid or expired token" } });
  }
}

export function requireAdminRole(...roles) {
  return (req, res, next) => {
    if (!req.admin || !roles.includes(req.admin.role)) {
      return res.status(403).json({ error: { code: "FORBIDDEN", message: "Insufficient admin permissions" } });
    }
    next();
  };
}
