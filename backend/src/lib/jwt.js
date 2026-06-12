import jwt from "jsonwebtoken";

const secret = () => process.env.JWT_SECRET || "marqueeflow-dev-secret-change-in-production";

export function signToken(payload, expiresIn = "7d") {
  return jwt.sign(payload, secret(), { expiresIn });
}

export function verifyToken(token) {
  return jwt.verify(token, secret());
}
