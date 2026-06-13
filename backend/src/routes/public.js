import { Router } from "express";
import { db } from "../db/store.js";
import { isValidPkPhone, normalizePkPhone } from "../lib/phone.js";

export const publicRouter = Router();

publicRouter.post("/demo-request", (req, res) => {
  const { name, businessName, phone, city, teamSize, message } = req.body || {};
  if (!name || !businessName || !phone || !city) {
    return res.status(400).json({
      error: { code: "VALIDATION", message: "Name, business name, phone, and city are required." }
    });
  }
  if (!isValidPkPhone(phone)) {
    return res.status(400).json({
      error: { code: "VALIDATION", message: "Enter a valid Pakistani mobile number." }
    });
  }
  const request = db.createDemoRequest({
    name: String(name).trim(),
    businessName: String(businessName).trim(),
    phone: normalizePkPhone(phone),
    city: String(city).trim(),
    teamSize: teamSize ? Number(teamSize) : null,
    message: message ? String(message).trim() : ""
  });
  res.status(201).json({ ok: true, request: { id: request.id, createdAt: request.createdAt } });
});
