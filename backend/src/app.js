import cors from "cors";
import express from "express";
import helmet from "helmet";
import morgan from "morgan";
import { apiRouter } from "./routes/index.js";

export function createApp() {
  const app = express();
  const adminOrigin = process.env.ADMIN_ORIGIN || "http://localhost:5173";
  const allowedOrigins = [
    adminOrigin,
    process.env.WEBSITE_ORIGIN || "https://marqueeflow.com",
    "https://marqueeflow.com",
    "https://www.marqueeflow.com",
    "http://localhost:5173",
    "http://127.0.0.1:5173",
    "http://localhost:5174",
    "http://127.0.0.1:5174",
    "http://localhost:4011",
    "http://127.0.0.1:4011",
    "http://localhost:4012",
    "http://127.0.0.1:4012"
  ];

  app.disable("x-powered-by");
  app.use(helmet());
  app.use(morgan(process.env.NODE_ENV === "production" ? "combined" : "dev"));
  app.use(
    cors({
      origin: allowedOrigins,
      credentials: true
    })
  );
  app.use(express.json({ limit: "1mb" }));

  app.get("/health", (_req, res) => {
    res.json({
      status: "ok",
      service: "marqueeflow-backend",
      timestamp: new Date().toISOString()
    });
  });

  app.use("/api", apiRouter);

  app.use((_req, res) => {
    res.status(404).json({ error: { code: "NOT_FOUND", message: "Route not found" } });
  });

  return app;
}
