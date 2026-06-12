import { Router } from "express";
import { db } from "../db/store.js";
import { requireAuth } from "../middleware/auth.js";

export const paymentsRouter = Router();

paymentsRouter.get("/summary", requireAuth, (req, res) => {
  res.json(db.getPaymentsSummary(req.businessId));
});

paymentsRouter.get("/", requireAuth, (req, res) => {
  res.json({ payments: db.listPayments(req.businessId) });
});

paymentsRouter.post("/booking-payments", requireAuth, (req, res) => {
  const { bookingId, amount, paymentType, note } = req.body || {};
  try {
    const payment = db.recordPayment({
      businessId: req.businessId,
      bookingId,
      amount: Number(amount),
      paymentType: paymentType || "partial",
      note
    });
    if (!payment) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Booking not found" } });
    res.status(201).json({ payment });
  } catch (err) {
    res.status(400).json({ error: { code: err.code || "PAYMENT_ERROR", message: err.message } });
  }
});
