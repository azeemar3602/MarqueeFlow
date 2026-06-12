import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { SUBSCRIPTION_PLANS } from "../data/plans.js";
import { DEFAULT_PERMISSIONS } from "../data/roles.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DATA_DIR = process.env.MARQUEEFLOW_DATA_DIR || path.join(__dirname, "../../data/runtime");
const STORE_FILE = path.join(DATA_DIR, "store.json");

export function newId() {
  return crypto.randomUUID();
}

function bookingCode() {
  return `MF-${Date.now().toString(36).toUpperCase().slice(-6)}`;
}

function emptyStore() {
  return {
    users: [],
    businesses: [],
    businessSubscriptions: [],
    customPlanRequests: [],
    teamMembers: [],
    teamInvites: [],
    customers: [],
    slots: [],
    packages: [],
    bookings: [],
    payments: [],
    notifications: [],
    auditLogs: []
  };
}

function ensureDataDir() {
  if (!fs.existsSync(DATA_DIR)) {
    fs.mkdirSync(DATA_DIR, { recursive: true });
  }
}

function loadStore() {
  ensureDataDir();
  if (!fs.existsSync(STORE_FILE)) {
    const store = emptyStore();
    saveStore(store);
    return store;
  }
  return JSON.parse(fs.readFileSync(STORE_FILE, "utf8"));
}

function saveStore(store) {
  ensureDataDir();
  fs.writeFileSync(STORE_FILE, JSON.stringify(store, null, 2));
}

let store = loadStore();

function persist() {
  saveStore(store);
}

function resetStoreForTests() {
  store = emptyStore();
  persist();
}

function findUserByPhone(phone) {
  return store.users.find((u) => u.phone === phone);
}

function findUserById(id) {
  return store.users.find((u) => u.id === id);
}

function getBusiness(id) {
  return store.businesses.find((b) => b.id === id);
}

function getSubscription(businessId) {
  return store.businessSubscriptions.find((s) => s.businessId === businessId);
}

function getPlan(planId) {
  return SUBSCRIPTION_PLANS.find((p) => p.id === planId);
}

function teamUsage(businessId) {
  return store.teamMembers.filter((m) => m.businessId === businessId && m.status === "active").length;
}

function getUserLimit(businessId) {
  const sub = getSubscription(businessId);
  if (!sub) return 0;
  const plan = getPlan(sub.planId);
  return plan?.userLimit ?? 0;
}

function ensureSlotsForMonth(businessId, month) {
  const [year, mon] = month.split("-").map(Number);
  const daysInMonth = new Date(year, mon, 0).getDate();
  const slotNames = [
    { name: "morning", start: "09:00", end: "14:00" },
    { name: "evening", start: "17:00", end: "22:00" },
    { name: "night", start: "22:00", end: "02:00" }
  ];
  for (let day = 1; day <= daysInMonth; day += 1) {
    const date = `${year}-${String(mon).padStart(2, "0")}-${String(day).padStart(2, "0")}`;
    for (const slot of slotNames) {
      const exists = store.slots.some(
        (s) => s.businessId === businessId && s.date === date && s.slotName === slot.name
      );
      if (!exists) {
        store.slots.push({
          id: newId(),
          businessId,
          date,
          slotName: slot.name,
          startTime: slot.start,
          endTime: slot.end,
          capacity: 2,
          bookedCount: 0,
          status: "available"
        });
      }
    }
  }
  persist();
}

function refreshSlotStatus(slot) {
  if (slot.status === "blocked") return slot;
  if (slot.bookedCount >= slot.capacity) slot.status = "full";
  else if (slot.bookedCount > 0) slot.status = "partial";
  else slot.status = "available";
  return slot;
}

export const db = {
  resetStoreForTests,
  getPlans(currency = "PKR") {
    return SUBSCRIPTION_PLANS.filter((p) => p.currencyCode === currency || currency === "PKR");
  },

  createOwner({ name, phone, passwordHash, businessName, address }) {
    const businessId = newId();
    const userId = newId();
    const user = {
      id: userId,
      name,
      phone,
      email: null,
      passwordHash,
      role: "owner",
      status: "active",
      businessId,
      createdAt: new Date().toISOString()
    };
    const business = {
      id: businessId,
      ownerId: userId,
      businessName,
      phone,
      address: address || "",
      currencyCode: "PKR",
      subscriptionPlanId: null,
      status: "active",
      createdAt: new Date().toISOString()
    };
    store.users.push(user);
    store.businesses.push(business);
    store.teamMembers.push({
      id: newId(),
      businessId,
      userId,
      role: "owner",
      permissionsJson: { fullAccess: true },
      invitedBy: null,
      status: "active"
    });
    persist();
    return { user, business };
  },

  findUserByPhone,
  findUserById,

  startTrial(businessId, planId = "basic", trialDays = 14) {
    const now = new Date();
    const trialEnd = new Date(now);
    trialEnd.setDate(trialEnd.getDate() + trialDays);
    const existing = getSubscription(businessId);
    const record = {
      id: existing?.id || newId(),
      businessId,
      planId,
      status: "trial",
      trialStart: now.toISOString(),
      trialEnd: trialEnd.toISOString(),
      currentPeriodStart: now.toISOString(),
      currentPeriodEnd: trialEnd.toISOString()
    };
    if (existing) {
      Object.assign(existing, record);
    } else {
      store.businessSubscriptions.push(record);
    }
    const biz = getBusiness(businessId);
    if (biz) biz.subscriptionPlanId = planId;
    persist();
    return record;
  },

  activatePlan(businessId, planId) {
    const now = new Date();
    const periodEnd = new Date(now);
    periodEnd.setMonth(periodEnd.getMonth() + 1);
    const sub = getSubscription(businessId) || { id: newId(), businessId };
    Object.assign(sub, {
      planId,
      status: "active",
      currentPeriodStart: now.toISOString(),
      currentPeriodEnd: periodEnd.toISOString()
    });
    if (!store.businessSubscriptions.includes(sub)) {
      store.businessSubscriptions.push(sub);
    }
    const biz = getBusiness(businessId);
    if (biz) biz.subscriptionPlanId = planId;
    persist();
    return sub;
  },

  getSubscriptionStatus(businessId) {
    const sub = getSubscription(businessId);
    if (!sub) {
      return { status: "none", planId: null, plan: null, trialEnd: null, memberLimit: 0, membersUsed: teamUsage(businessId) };
    }
    const plan = getPlan(sub.planId);
    const now = Date.now();
    let status = sub.status;
    if (sub.trialEnd && new Date(sub.trialEnd).getTime() < now && status === "trial") {
      status = "expired";
    }
    if (sub.currentPeriodEnd && new Date(sub.currentPeriodEnd).getTime() < now && status === "active") {
      status = "expired";
    }
    return {
      status,
      planId: sub.planId,
      plan,
      trialEnd: sub.trialEnd,
      periodEnd: sub.currentPeriodEnd,
      memberLimit: plan?.userLimit ?? 0,
      membersUsed: teamUsage(businessId)
    };
  },

  createCustomPlanRequest({ businessId, requestedTeamSize, contactName, phone, note }) {
    const req = {
      id: newId(),
      businessId,
      requestedTeamSize,
      contactName,
      phone,
      note: note || "",
      status: "pending",
      createdAt: new Date().toISOString()
    };
    store.customPlanRequests.push(req);
    persist();
    return req;
  },

  listCustomPlanRequests(businessId = null) {
    if (businessId) {
      return store.customPlanRequests.filter((r) => r.businessId === businessId);
    }
    return store.customPlanRequests;
  },

  updateCustomPlanRequest(id, status) {
    const req = store.customPlanRequests.find((r) => r.id === id);
    if (!req) return null;
    req.status = status;
    persist();
    return req;
  },

  getTeamMembers(businessId) {
    return store.teamMembers
      .filter((m) => m.businessId === businessId)
      .map((m) => {
        const user = findUserById(m.userId);
        return { ...m, name: user?.name, phone: user?.phone };
      });
  },

  getTeamUsage(businessId) {
    const limit = getUserLimit(businessId);
    const used = teamUsage(businessId);
    const sub = getSubscriptionStatus(businessId);
    return {
      planId: sub.planId,
      planName: sub.plan?.name,
      used,
      limit,
      canInvite: used < limit
    };
  },

  createTeamInvite({ businessId, name, phone, role, permissions, invitedBy }) {
    const usage = teamUsage(businessId);
    const limit = getUserLimit(businessId);
    if (usage >= limit) {
      const err = new Error("Member limit reached for current plan");
      err.code = "MEMBER_LIMIT";
      throw err;
    }
    const duplicate = store.teamMembers.some(
      (m) => m.businessId === businessId && findUserById(m.userId)?.phone === phone
    );
    if (duplicate || findUserByPhone(phone)) {
      const inBiz = store.teamMembers.some(
        (m) => m.businessId === businessId && findUserById(m.userId)?.phone === phone
      );
      if (inBiz) {
        const err = new Error("Phone number already used in this business");
        err.code = "DUPLICATE_PHONE";
        throw err;
      }
    }
    const expires = new Date();
    expires.setDate(expires.getDate() + 7);
    const invite = {
      id: newId(),
      businessId,
      name,
      phone,
      role,
      permissionsJson: permissions || DEFAULT_PERMISSIONS[role] || {},
      inviteToken: crypto.randomBytes(24).toString("hex"),
      expiresAt: expires.toISOString(),
      status: "pending",
      invitedBy
    };
    store.teamInvites.push(invite);
    persist();
    return invite;
  },

  getInviteByToken(token) {
    return store.teamInvites.find((i) => i.inviteToken === token && i.status === "pending");
  },

  listTeamInvites(businessId) {
    return store.teamInvites.filter((i) => i.businessId === businessId && i.status === "pending");
  },

  acceptInvite({ token, passwordHash }) {
    const invite = store.teamInvites.find((i) => i.inviteToken === token);
    if (!invite) return null;
    if (new Date(invite.expiresAt) < new Date()) {
      invite.status = "expired";
      persist();
      return null;
    }
    let user = findUserByPhone(invite.phone);
    if (!user) {
      user = {
        id: newId(),
        name: invite.name,
        phone: invite.phone,
        email: null,
        passwordHash,
        role: invite.role,
        status: "active",
        businessId: invite.businessId,
        createdAt: new Date().toISOString()
      };
      store.users.push(user);
    }
    store.teamMembers.push({
      id: newId(),
      businessId: invite.businessId,
      userId: user.id,
      role: invite.role,
      permissionsJson: invite.permissionsJson,
      invitedBy: invite.invitedBy,
      status: "active"
    });
    invite.status = "accepted";
    persist();
    return user;
  },

  listPackages(businessId) {
    return store.packages.filter((p) => p.businessId === businessId && p.status === "active");
  },

  seedPackagesIfEmpty(businessId) {
    if (store.packages.some((p) => p.businessId === businessId)) return;
    const defaults = [
      { name: "Silver Package", price: 150000, inclusions: ["Hall", "Basic decor", "Tea"] },
      { name: "Gold Package", price: 250000, inclusions: ["Hall", "Premium decor", "Dinner"] },
      { name: "Platinum Package", price: 400000, inclusions: ["Full venue", "Luxury decor", "Full catering"] }
    ];
    for (const pkg of defaults) {
      store.packages.push({
        id: newId(),
        businessId,
        name: pkg.name,
        price: pkg.price,
        inclusionsJson: pkg.inclusions,
        status: "active"
      });
    }
    persist();
  },

  getCalendarMonth(businessId, month) {
    ensureSlotsForMonth(businessId, month);
    const days = store.slots.filter((s) => s.businessId === businessId && s.date.startsWith(month));
    const byDate = {};
    for (const slot of days) {
      refreshSlotStatus(slot);
      if (!byDate[slot.date]) byDate[slot.date] = { date: slot.date, slots: [], state: "available" };
      byDate[slot.date].slots.push(slot);
    }
    for (const day of Object.values(byDate)) {
      const full = day.slots.every((s) => s.status === "full" || s.status === "blocked");
      const partial = day.slots.some((s) => s.status === "partial" || s.status === "full");
      day.state = full ? "fully_booked" : partial ? "partially_booked" : "available";
    }
    persist();
    return { month, days: Object.values(byDate) };
  },

  getCalendarDay(businessId, date) {
    const month = date.slice(0, 7);
    ensureSlotsForMonth(businessId, month);
    const slots = store.slots
      .filter((s) => s.businessId === businessId && s.date === date)
      .map(refreshSlotStatus);
    persist();
    return { date, slots };
  },

  getDayBookings(businessId, date) {
    return store.bookings.filter((b) => b.businessId === businessId && b.eventDate === date);
  },

  createBooking(payload) {
    const {
      businessId,
      customerName,
      customerPhone,
      eventDate,
      slotId,
      eventType,
      guestCount,
      packageId,
      advancePayment = 0,
      status = "pending",
      notes = ""
    } = payload;
    let customer = store.customers.find(
      (c) => c.businessId === businessId && c.phone === customerPhone
    );
    if (!customer) {
      customer = { id: newId(), businessId, name: customerName, phone: customerPhone, notes: "" };
      store.customers.push(customer);
    }
    const pkg = store.packages.find((p) => p.id === packageId);
    const total = pkg?.price || 0;
    const advance = Math.min(advancePayment, total);
    const remaining = Math.max(total - advance, 0);
    let paymentStatus = "unpaid";
    if (advance > 0 && remaining > 0) paymentStatus = "advance_paid";
    if (advance > 0 && remaining === 0) paymentStatus = "fully_paid";

    const slot = store.slots.find((s) => s.id === slotId);
    if (slot) {
      if (slot.bookedCount >= slot.capacity && slot.status !== "blocked") {
        const err = new Error("Slot is fully booked");
        err.code = "SLOT_FULL";
        throw err;
      }
      slot.bookedCount += 1;
      refreshSlotStatus(slot);
    }

    const booking = {
      id: newId(),
      businessId,
      customerId: customer.id,
      bookingCode: bookingCode(),
      eventDate,
      slotId,
      eventType,
      guestCount,
      packageId: packageId || null,
      status,
      notes,
      advancePaid: advance,
      remainingAmount: remaining,
      paymentStatus,
      customerName,
      customerPhone,
      createdAt: new Date().toISOString()
    };
    store.bookings.push(booking);
    if (advance > 0) {
      store.payments.push({
        id: newId(),
        businessId,
        bookingId: booking.id,
        amount: advance,
        paymentType: "advance",
        paymentStatus: "recorded",
        paymentDate: new Date().toISOString().slice(0, 10),
        note: "Initial advance"
      });
    }
    persist();
    return booking;
  },

  listBookings(businessId, filters = {}) {
    let list = store.bookings.filter((b) => b.businessId === businessId);
    const { search, bookingStatus, paymentStatus, eventType, sort = "latest" } = filters;
    if (search) {
      const q = search.toLowerCase();
      list = list.filter(
        (b) =>
          b.customerName?.toLowerCase().includes(q) ||
          b.customerPhone?.includes(q) ||
          b.bookingCode?.toLowerCase().includes(q)
      );
    }
    if (bookingStatus) list = list.filter((b) => b.status === bookingStatus);
    if (paymentStatus) list = list.filter((b) => b.paymentStatus === paymentStatus);
    if (eventType) list = list.filter((b) => b.eventType === eventType);
    list.sort((a, b) => {
      if (sort === "oldest") return new Date(a.createdAt) - new Date(b.createdAt);
      if (sort === "date") return a.eventDate.localeCompare(b.eventDate);
      return new Date(b.createdAt) - new Date(a.createdAt);
    });
    return list;
  },

  getBooking(id, businessId) {
    const b = store.bookings.find((x) => x.id === id && x.businessId === businessId);
    if (!b) return null;
    const slot = store.slots.find((s) => s.id === b.slotId);
    const pkg = store.packages.find((p) => p.id === b.packageId);
    return { ...b, slot, package: pkg };
  },

  updateBooking(id, businessId, patch) {
    const b = store.bookings.find((x) => x.id === id && x.businessId === businessId);
    if (!b) return null;
    Object.assign(b, patch);
    persist();
    return b;
  },

  getPaymentsSummary(businessId) {
    const payments = store.payments.filter((p) => p.businessId === businessId && p.paymentStatus === "recorded");
    const bookings = store.bookings.filter((b) => b.businessId === businessId);
    const totalReceived = payments.reduce((s, p) => s + p.amount, 0);
    const pending = bookings.filter((b) => b.paymentStatus === "unpaid" || b.paymentStatus === "advance_paid").length;
    const partial = bookings.filter((b) => b.paymentStatus === "partially_paid" || b.paymentStatus === "advance_paid").length;
    return { totalReceived, pendingCount: pending, partialCount: partial, currencyCode: "PKR" };
  },

  listPayments(businessId) {
    return store.payments
      .filter((p) => p.businessId === businessId)
      .map((p) => {
        const booking = store.bookings.find((b) => b.id === p.bookingId);
        return { ...p, bookingCode: booking?.bookingCode, customerName: booking?.customerName };
      });
  },

  recordPayment({ businessId, bookingId, amount, paymentType = "partial", note = "" }) {
    const booking = store.bookings.find((b) => b.id === bookingId && b.businessId === businessId);
    if (!booking) return null;
    if (amount <= 0) {
      const err = new Error("Payment amount must be positive");
      err.code = "INVALID_AMOUNT";
      throw err;
    }
    const maxAllowed = booking.remainingAmount;
    if (amount > maxAllowed) {
      const err = new Error("Payment exceeds remaining amount");
      err.code = "OVERPAYMENT";
      throw err;
    }
    const payment = {
      id: newId(),
      businessId,
      bookingId,
      amount,
      paymentType,
      paymentStatus: "recorded",
      paymentDate: new Date().toISOString().slice(0, 10),
      note
    };
    store.payments.push(payment);
    booking.advancePaid += amount;
    booking.remainingAmount -= amount;
    if (booking.remainingAmount === 0) booking.paymentStatus = "fully_paid";
    else booking.paymentStatus = "partially_paid";
    persist();
    return payment;
  },

  getDashboardSummary(businessId) {
    const today = new Date().toISOString().slice(0, 10);
    const bookings = store.bookings.filter((b) => b.businessId === businessId);
    const todayBookings = bookings.filter((b) => b.eventDate === today);
    const upcoming = bookings.filter((b) => b.eventDate >= today && b.status !== "cancelled").slice(0, 5);
    const month = today.slice(0, 7);
    ensureSlotsForMonth(businessId, month);
    const availableSlots = store.slots.filter(
      (s) => s.businessId === businessId && s.date >= today && s.status === "available"
    ).length;
    return {
      greetingName: getBusiness(businessId)?.businessName || "MarqueeFlow",
      date: today,
      todayBookings: todayBookings.length,
      upcomingEvents: upcoming.length,
      availableSlots,
      totalBookings: bookings.length,
      pendingBookings: bookings.filter((b) => b.status === "pending").length,
      confirmedBookings: bookings.filter((b) => b.status === "confirmed").length,
      paymentPending: bookings.filter((b) => b.paymentStatus !== "fully_paid").length,
      upcoming
    };
  },

  listNotifications(businessId, userId) {
    return store.notifications.filter(
      (n) => n.businessId === businessId && (!n.userId || n.userId === userId)
    );
  },

  markNotificationRead(id) {
    const n = store.notifications.find((x) => x.id === id);
    if (n) n.isRead = true;
    persist();
    return n;
  },

  getBusiness,
  listBusinesses() {
    return store.businesses;
  }
};
