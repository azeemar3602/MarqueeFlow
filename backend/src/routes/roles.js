import { Router } from "express";
import { ROLES } from "../data/roles.js";

export const rolesRouter = Router();

rolesRouter.get("/", (_req, res) => {
  res.json({ roles: ROLES });
});
