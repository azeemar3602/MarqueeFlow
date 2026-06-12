import { Router } from "express";
import { db } from "../db/store.js";
import { requireAuth } from "../middleware/auth.js";
import { isValidPkPhone, normalizePkPhone } from "../lib/phone.js";

export const bookingsRouter = Router();

bookingsRouter.get("/", requireAuth, (req, res) => {
  const bookings = db.listBookings(req.businessId, req.query);
  res.json({ bookings });
});

bookingsRouter.get("/event-types", requireAuth, (_req, res) => {
  res.json({
    eventTypes: ["Mehndi", "Barat", "Walima", "Birthday", "Corporate", "Other"]
  });
});

bookingsRouter.get("/:id", requireAuth, (req, res) => {
  const booking = db.getBooking(req.params.id, req.businessId);
  if (!booking) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Booking not found" } });
  res.json({ booking });
});

bookingsRouter.post("/", requireAuth, (req, res) => {
  const body = req.body || {};
  if (!body.customerName || !body.customerPhone || !body.eventDate || !body.slotId) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "Missing required fields" } });
  }
  if (!isValidPkPhone(body.customerPhone)) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "Invalid phone" } });
  }
  if (!body.guestCount || Number(body.guestCount) < 1) {
    return res.status(400).json({ error: { code: "VALIDATION", message: "Guest count required" } });
  }
  try {
    const booking = db.createBooking({
      businessId: req.businessId,
      customerName: body.customerName,
      customerPhone: normalizePkPhone(body.customerPhone),
      eventDate: body.eventDate,
      slotId: body.slotId,
      eventType: body.eventType || "Other",
      guestCount: Number(body.guestCount),
      packageId: body.packageId,
      advancePayment: Number(body.advancePayment || 0),
      status: body.status || "pending",
      notes: body.notes || ""
    });
    res.status(201).json({ booking });
  } catch (err) {
    const code = err.code || "BOOKING_ERROR";
    res.status(400).json({ error: { code, message: err.message } });
  }
});

bookingsRouter.patch("/:id", requireAuth, (req, res) => {
  const booking = db.updateBooking(req.params.id, req.businessId, req.body || {});
  if (!booking) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Booking not found" } });
  res.json({ booking });
});

bookingsRouter.post("/:id/share", requireAuth, (req, res) => {
  const booking = db.getBooking(req.params.id, req.businessId);
  if (!booking) return res.status(404).json({ error: { code: "NOT_FOUND", message: "Booking not found" } });
  const text = `MarqueeFlow Booking ${booking.bookingCode}\nCustomer: ${booking.customerName}\nDate: ${booking.eventDate}\nGuests: ${booking.guestCount}\nPayment: ${booking.paymentStatus}`;
  res.json({ format: "whatsapp", text });
});
