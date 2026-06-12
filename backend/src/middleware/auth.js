import { verifyToken } from "../lib/jwt.js";
import { db } from "../db/store.js";

export function requireAuth(req, res, next) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) {
    return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Authentication required" } });
  }
  try {
    const payload = verifyToken(token);
    const user = db.findUserById(payload.sub);
    if (!user || user.status !== "active") {
      return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Invalid session" } });
    }
    req.user = user;
    req.businessId = user.businessId;
    next();
  } catch {
    return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Invalid or expired token" } });
  }
}

export function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ error: { code: "FORBIDDEN", message: "Insufficient permissions" } });
    }
    next();
  };
}
