import { Router } from "express";

export const healthRouter = Router();

healthRouter.get("/health", (_req, res) => {
  res.json({
    ok: true,
    service: "marqueeflow-api",
    version: "1.4.0",
    timestamp: new Date().toISOString()
  });
});
