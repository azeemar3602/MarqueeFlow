import jwt from "jsonwebtoken";

export const DEV_SECRET = "marqueeflow-dev-secret-change-in-production";

const secret = () => process.env.JWT_SECRET || DEV_SECRET;

export function validateJwtConfig() {
  if (process.env.NODE_ENV !== "production") return;
  const value = process.env.JWT_SECRET;
  if (!value || value === DEV_SECRET || value.length < 32) {
    throw new Error(
      "[security] JWT_SECRET must be set to a strong value (32+ characters) before running in production."
    );
  }
}

export function signToken(payload, expiresIn = "7d") {
  return jwt.sign(payload, secret(), { expiresIn });
}

export function verifyToken(token) {
  return jwt.verify(token, secret());
}
