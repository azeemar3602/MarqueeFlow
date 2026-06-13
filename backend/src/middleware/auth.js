import { verifyToken } from "../lib/jwt.js";
import { db } from "../db/store.js";

function businessAccessError(business) {
  const approval = business.approvalStatus || "approved";
  if (approval === "pending") {
    return {
      status: 403,
      error: {
        code: "BUSINESS_PENDING",
        message: "Business is pending Super Admin approval. Mobile app access is limited until approved."
      }
    };
  }
  if (approval === "rejected") {
    return {
      status: 403,
      error: {
        code: "BUSINESS_REJECTED",
        message: "Business registration was rejected. Contact MarqueeFlow support."
      }
    };
  }
  if (approval === "suspended" || business.status === "suspended") {
    return {
      status: 403,
      error: {
        code: "BUSINESS_SUSPENDED",
        message: "Business account is suspended. Contact MarqueeFlow support."
      }
    };
  }
  return null;
}

export function requireAuth(req, res, next) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) {
    return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Authentication required" } });
  }
  try {
    const payload = verifyToken(token);
    if (payload.kind === "admin") {
      return res.status(403).json({
        error: { code: "FORBIDDEN", message: "Admin accounts must use the Super Admin control panel." }
      });
    }
    const user = db.findUserById(payload.sub);
    if (!user || user.status !== "active") {
      return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Invalid session" } });
    }
    req.user = user;
    req.businessId = user.businessId;
    req.teamMember = db.getTeamMember(user.businessId, user.id);
    next();
  } catch {
    return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Invalid or expired token" } });
  }
}

export function requireActiveBusiness(req, res, next) {
  const business = db.getBusiness(req.businessId);
  if (!business) {
    return res.status(403).json({ error: { code: "FORBIDDEN", message: "Business not found" } });
  }
  const denied = businessAccessError(business);
  if (denied) {
    return res.status(denied.status).json({ error: denied.error });
  }
  req.business = business;
  next();
}

export function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ error: { code: "FORBIDDEN", message: "Insufficient permissions" } });
    }
    next();
  };
}
