import cors from "cors";
import express from "express";
import helmet from "helmet";
import morgan from "morgan";
import { apiRouter } from "./routes/index.js";

export function createApp() {
  const app = express();
  const adminOrigin = process.env.ADMIN_ORIGIN || "http://localhost:5173";

  app.disable("x-powered-by");
  app.use(helmet());
  app.use(morgan(process.env.NODE_ENV === "production" ? "combined" : "dev"));
  app.use(
    cors({
      origin: [adminOrigin, "http://localhost:5173"],
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
