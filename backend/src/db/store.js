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
    subscriptionPayments: [],
    notifications: [],
    auditLogs: [],
    adminUsers: [],
    demoRequests: [],
    settings: {
      appName: "MarqueeFlow",
      currencyCode: "PKR",
      trialDays: 14,
      manualApprovalEnabled: true,
      supportPhone: "",
      supportEmail: ""
    }
  };
}

function ensureStoreShape() {
  if (!store.adminUsers) store.adminUsers = [];
  if (!store.subscriptionPayments) store.subscriptionPayments = [];
  if (!store.auditLogs) store.auditLogs = [];
  if (!store.demoRequests) store.demoRequests = [];
  if (!store.settings) {
    store.settings = {
      appName: "MarqueeFlow",
      currencyCode: "PKR",
      trialDays: 14,
      manualApprovalEnabled: true,
      supportPhone: "",
      supportEmail: ""
    };
  }
  for (const biz of store.businesses) {
    if (!biz.approvalStatus) biz.approvalStatus = "approved";
  }
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
ensureStoreShape();

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

function getSubscriptionStatus(businessId) {
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
    trialStart: sub.trialStart,
    trialEnd: sub.trialEnd,
    currentPeriodStart: sub.currentPeriodStart,
    periodEnd: sub.currentPeriodEnd,
    memberLimit: plan?.userLimit ?? 0,
    membersUsed: teamUsage(businessId)
  };
}

function getMarqueeIssues(businessId) {
  const issues = [];
  const business = getBusiness(businessId);
  const sub = getSubscription(businessId);
  if (!business) return issues;
  if (business.approvalStatus === "pending") {
    issues.push({ id: `${businessId}-approval`, type: "approval", message: "Business pending Super Admin approval", severity: "high", status: "open" });
  }
  if (business.approvalStatus === "rejected") {
    issues.push({ id: `${businessId}-rejected`, type: "approval", message: "Business registration rejected", severity: "high", status: "open" });
  }
  if (business.status === "suspended") {
    issues.push({ id: `${businessId}-suspended`, type: "account", message: "Business account suspended", severity: "high", status: "open" });
  }
  if (sub?.status === "expired") {
    issues.push({ id: `${businessId}-expired`, type: "subscription", message: "Subscription expired", severity: "medium", status: "open" });
  }
  const pendingSubPay = store.subscriptionPayments.filter(
    (p) => p.businessId === businessId && p.status === "pending"
  ).length;
  if (pendingSubPay > 0) {
    issues.push({ id: `${businessId}-subpay`, type: "payment", message: `${pendingSubPay} pending subscription payment(s)`, severity: "medium", status: "open" });
  }
  const pendingBookingPay = store.bookings.filter(
    (b) => b.businessId === businessId && b.paymentStatus !== "fully_paid"
  ).length;
  if (pendingBookingPay > 0) {
    issues.push({ id: `${businessId}-bookingpay`, type: "payment", message: `${pendingBookingPay} booking(s) with pending payment`, severity: "low", status: "open" });
  }
  return issues;
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
      approvalStatus: store.settings?.manualApprovalEnabled ? "pending" : "approved",
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
    return getSubscriptionStatus(businessId);
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
        return { ...m, name: user?.name, phone: user?.phone, permissions: m.permissionsJson };
      });
  },

  updateTeamMember(id, businessId, patch = {}) {
    const member = store.teamMembers.find((m) => m.id === id && m.businessId === businessId);
    if (!member) return null;
    if (patch.role) member.role = patch.role;
    if (patch.permissions) member.permissionsJson = patch.permissions;
    if (patch.status) {
      member.status = patch.status;
      const user = findUserById(member.userId);
      if (user && patch.status === "inactive") user.status = "inactive";
    }
    persist();
    const user = findUserById(member.userId);
    return { ...member, name: user?.name, phone: user?.phone, permissions: member.permissionsJson };
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

  listPackages(businessId, { includeInactive = false } = {}) {
    let list = store.packages.filter((p) => p.businessId === businessId);
    if (!includeInactive) list = list.filter((p) => p.status === "active");
    return list;
  },

  createPackage(businessId, payload) {
    if (!payload.name || payload.price == null) {
      const err = new Error("Package name and price are required");
      err.code = "VALIDATION";
      throw err;
    }
    const services = payload.includedServices || payload.inclusionsJson || [];
    const pkg = {
      id: newId(),
      businessId,
      name: payload.name,
      price: Number(payload.price),
      guestLimit: Number(payload.guestLimit || 0),
      description: payload.description || "",
      includedServices: services,
      inclusionsJson: services,
      status: payload.status || "active",
      createdAt: new Date().toISOString()
    };
    store.packages.push(pkg);
    persist();
    return pkg;
  },

  updatePackage(id, businessId, patch) {
    const pkg = store.packages.find((p) => p.id === id && p.businessId === businessId);
    if (!pkg) return null;
    if (patch.name != null) pkg.name = patch.name;
    if (patch.price != null) pkg.price = Number(patch.price);
    if (patch.guestLimit != null) pkg.guestLimit = Number(patch.guestLimit);
    if (patch.description != null) pkg.description = patch.description;
    if (patch.includedServices != null) {
      pkg.includedServices = patch.includedServices;
      pkg.inclusionsJson = patch.includedServices;
    }
    if (patch.status != null) pkg.status = patch.status;
    persist();
    return pkg;
  },

  deactivatePackage(id, businessId) {
    const pkg = store.packages.find((p) => p.id === id && p.businessId === businessId);
    if (!pkg) return null;
    const activeBooking = store.bookings.some(
      (b) => b.packageId === id && b.businessId === businessId && b.status !== "cancelled"
    );
    if (activeBooking) {
      const err = new Error("Package is linked to active bookings. Deactivate instead of delete.");
      err.code = "PACKAGE_IN_USE";
      throw err;
    }
    pkg.status = "inactive";
    persist();
    return pkg;
  },

  getTeamMember(businessId, userId) {
    return store.teamMembers.find(
      (m) => m.businessId === businessId && m.userId === userId && m.status === "active"
    );
  },

  getMarqueeIssues(businessId) {
    return getMarqueeIssues(businessId);
  },

  seedPackagesIfEmpty(businessId) {
    if (store.packages.some((p) => p.businessId === businessId)) return;
    const defaults = [
      { name: "Silver Package", price: 150000, guestLimit: 150, description: "Hall with basic decor", inclusions: ["Hall", "Basic decor", "Tea"] },
      { name: "Gold Package", price: 250000, guestLimit: 300, description: "Premium hall experience", inclusions: ["Hall", "Premium decor", "Dinner"] },
      { name: "Platinum Package", price: 400000, guestLimit: 500, description: "Full venue package", inclusions: ["Full venue", "Luxury decor", "Full catering"] }
    ];
    for (const pkg of defaults) {
      store.packages.push({
        id: newId(),
        businessId,
        name: pkg.name,
        price: pkg.price,
        guestLimit: pkg.guestLimit,
        description: pkg.description,
        includedServices: pkg.inclusions,
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

    if (!packageId) {
      const err = new Error("Package is required");
      err.code = "VALIDATION";
      throw err;
    }
    const pkg = store.packages.find((p) => p.id === packageId && p.businessId === businessId);
    if (!pkg) {
      const err = new Error("Package not found");
      err.code = "VALIDATION";
      throw err;
    }
    if (pkg.status === "inactive") {
      const err = new Error("Selected package is inactive");
      err.code = "VALIDATION";
      throw err;
    }
    const guests = Number(guestCount);
    if (!guests || guests < 1) {
      const err = new Error("Guest count must be at least 1");
      err.code = "VALIDATION";
      throw err;
    }
    if (pkg.guestLimit && guests > pkg.guestLimit) {
      const err = new Error(`Guest count exceeds package limit of ${pkg.guestLimit}`);
      err.code = "VALIDATION";
      throw err;
    }
    const total = pkg.price || 0;
    const advance = Math.max(0, Math.min(Number(advancePayment) || 0, total));
    if (Number(advancePayment) < 0) {
      const err = new Error("Advance payment cannot be negative");
      err.code = "VALIDATION";
      throw err;
    }
    if (Number(advancePayment) > total) {
      const err = new Error("Advance payment cannot exceed package total");
      err.code = "VALIDATION";
      throw err;
    }

    let customer = store.customers.find(
      (c) => c.businessId === businessId && c.phone === customerPhone
    );
    if (!customer) {
      customer = { id: newId(), businessId, name: customerName, phone: customerPhone, notes: "" };
      store.customers.push(customer);
    }
    const remaining = Math.max(total - advance, 0);
    let paymentStatus = "unpaid";
    if (advance > 0 && remaining > 0) paymentStatus = "advance_paid";
    if (advance > 0 && remaining === 0) paymentStatus = "fully_paid";

    const slot = store.slots.find((s) => s.id === slotId && s.businessId === businessId);
    if (!slot) {
      const err = new Error("Slot not found");
      err.code = "VALIDATION";
      throw err;
    }
    refreshSlotStatus(slot);
    if (slot.status === "blocked") {
      const err = new Error("Slot is blocked");
      err.code = "SLOT_FULL";
      throw err;
    }
    if (slot.bookedCount >= slot.capacity) {
      const err = new Error("Slot is fully booked");
      err.code = "SLOT_FULL";
      throw err;
    }
    slot.bookedCount += 1;
    refreshSlotStatus(slot);

    const booking = {
      id: newId(),
      businessId,
      customerId: customer.id,
      bookingCode: bookingCode(),
      eventDate,
      slotId,
      eventType,
      guestCount: guests,
      packageId,
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
    return list.map((b) => {
      const slot = store.slots.find((s) => s.id === b.slotId);
      const pkg = store.packages.find((p) => p.id === b.packageId);
      const totalAmount = (b.advancePaid || 0) + (b.remainingAmount || 0);
      return {
        ...b,
        slotName: slot?.slotName,
        packageName: pkg?.name,
        totalAmount
      };
    });
  },

  getBooking(id, businessId) {
    const b = store.bookings.find((x) => x.id === id && x.businessId === businessId);
    if (!b) return null;
    const slot = store.slots.find((s) => s.id === b.slotId);
    const pkg = store.packages.find((p) => p.id === b.packageId);
    const totalAmount = (b.advancePaid || 0) + (b.remainingAmount || 0);
    return { ...b, slot, package: pkg, slotName: slot?.slotName, packageName: pkg?.name, totalAmount };
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
    const pendingAmount = bookings
      .filter((b) => b.paymentStatus !== "fully_paid")
      .reduce((s, b) => s + (b.remainingAmount || 0), 0);
    const partialCount = bookings.filter((b) => b.paymentStatus === "partially_paid" || b.paymentStatus === "advance_paid").length;
    const fullyPaidCount = bookings.filter((b) => b.paymentStatus === "fully_paid").length;
    return {
      totalReceived,
      pendingAmount,
      pendingCount: bookings.filter((b) => b.paymentStatus !== "fully_paid").length,
      partialCount,
      fullyPaidCount,
      currencyCode: "PKR"
    };
  },

  listPayments(businessId, filters = {}) {
    let list = store.payments.filter((p) => p.businessId === businessId);
    if (filters.date) {
      list = list.filter((p) => p.paymentDate === filters.date);
    }
    return list
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
      (s) => s.businessId === businessId && s.date === today && s.bookedCount < s.capacity
    ).length;
    const business = getBusiness(businessId);
    const owner = findUserById(business?.ownerId);
    return {
      greetingName: owner?.name || business?.businessName || "MarqueeFlow",
      date: today,
      todayCount: todayBookings.length,
      upcomingCount: upcoming.length,
      availableSlotsToday: availableSlots,
      totalBookings: bookings.length,
      pendingBookings: bookings.filter((b) => b.status === "pending").length,
      confirmedBookings: bookings.filter((b) => b.status === "confirmed").length,
      pendingPayments: bookings.filter((b) => b.paymentStatus !== "fully_paid").length,
      todayBookings: todayBookings.length,
      upcomingEvents: upcoming.length,
      availableSlots,
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
  },

  findAdminByPhone(phone) {
    return store.adminUsers.find((a) => a.phone === phone);
  },

  findAdminById(id) {
    return store.adminUsers.find((a) => a.id === id);
  },

  createAdminUser({ name, phone, passwordHash, role = "super_admin" }) {
    const admin = {
      id: newId(),
      name,
      phone,
      passwordHash,
      role,
      status: "active",
      lastLoginAt: null,
      createdAt: new Date().toISOString()
    };
    store.adminUsers.push(admin);
    persist();
    return admin;
  },

  listAdminUsers() {
    return store.adminUsers.map(({ passwordHash, ...a }) => a);
  },

  addAuditLog({ adminId, adminName, action, module, targetId, oldValue, newValue }) {
    const log = {
      id: newId(),
      adminId,
      adminName,
      action,
      module,
      targetId: targetId || null,
      oldValue: oldValue || null,
      newValue: newValue || null,
      createdAt: new Date().toISOString()
    };
    store.auditLogs.unshift(log);
    if (store.auditLogs.length > 500) store.auditLogs.length = 500;
    persist();
    return log;
  },

  listAuditLogs() {
    return store.auditLogs;
  },

  getPlatformDashboard() {
    const businesses = store.businesses;
    const subs = store.businessSubscriptions;
    const active = subs.filter((s) => s.status === "active").length;
    const expired = subs.filter((s) => s.status === "expired").length;
    const trial = subs.filter((s) => s.status === "trial").length;
    const pendingApprovals = businesses.filter((b) => b.approvalStatus === "pending").length;
    const suspended = businesses.filter((b) => b.approvalStatus === "suspended" || b.status === "suspended").length;
    const customRequests = store.customPlanRequests.filter((r) => r.status === "pending" || r.status === "new").length;
    const monthlyRevenue = store.subscriptionPayments
      .filter((p) => p.status === "confirmed" && p.paymentDate?.startsWith(new Date().toISOString().slice(0, 7)))
      .reduce((s, p) => s + p.amount, 0);
    const pendingPayments = store.subscriptionPayments.filter((p) => p.status === "pending").length;
    return {
      totalMarquees: businesses.length,
      activeSubscriptions: active,
      expiredSubscriptions: expired,
      trialBusinesses: trial,
      pendingApprovals,
      suspendedBusinesses: suspended,
      customPlanRequests: customRequests,
      monthlyRevenuePKR: monthlyRevenue,
      pendingSubscriptionPayments: pendingPayments,
      pendingActions: [
        { label: "Pending approvals", count: pendingApprovals },
        { label: "Pending subscription payments", count: pendingPayments },
        { label: "Custom plan requests", count: customRequests }
      ].filter((a) => a.count > 0),
      recentActivity: store.auditLogs.slice(0, 8),
      upcomingRenewals: subs
        .filter((s) => s.currentPeriodEnd)
        .slice(0, 5)
        .map((s) => {
          const biz = getBusiness(s.businessId);
          return { businessId: s.businessId, businessName: biz?.businessName, expiresAt: s.currentPeriodEnd, planId: s.planId };
        })
    };
  },

  listMarqueesAdmin() {
    return store.businesses.map((b) => {
      const owner = findUserById(b.ownerId);
      const sub = getSubscriptionStatus(b.id);
      const bookings = store.bookings.filter((x) => x.businessId === b.id);
      const revenue = store.payments
        .filter((p) => p.businessId === b.id && p.paymentStatus === "recorded")
        .reduce((s, p) => s + p.amount, 0);
      return {
        id: b.id,
        businessName: b.businessName,
        ownerName: owner?.name,
        ownerPhone: owner?.phone || b.phone,
        city: b.address,
        planName: sub.plan?.name || sub.planId,
        subscriptionStatus: sub.status,
        approvalStatus: b.approvalStatus || "approved",
        teamCount: teamUsage(b.id),
        totalBookings: bookings.length,
        totalRevenuePKR: revenue,
        lastLoginAt: owner?.lastLoginAt || null,
        status: b.status
      };
    });
  },

  getMarqueeAdminDetail(businessId) {
    const business = getBusiness(businessId);
    if (!business) return null;
    const owner = findUserById(business.ownerId);
    const sub = getSubscriptionStatus(businessId);
    const bookings = store.bookings.filter((b) => b.businessId === businessId);
    const revenue = store.payments
      .filter((p) => p.businessId === businessId && p.paymentStatus === "recorded")
      .reduce((s, p) => s + p.amount, 0);
    const pendingPayments = bookings.filter((b) => b.paymentStatus !== "fully_paid").length;
    return {
      business,
      owner,
      subscription: sub,
      teamUsage: { used: teamUsage(businessId), limit: getUserLimit(businessId) },
      stats: {
        totalBookings: bookings.length,
        totalRevenuePKR: revenue,
        pendingPayments,
        openIssues: pendingPayments > 0 ? 1 : 0
      },
      bookings: bookings.slice(0, 20),
      customers: store.customers.filter((c) => c.businessId === businessId),
      teamMembers: store.teamMembers
        .filter((m) => m.businessId === businessId)
        .map((m) => {
          const user = findUserById(m.userId);
          return { ...m, name: user?.name, phone: user?.phone, permissions: m.permissionsJson };
        }),
      packages: store.packages.filter((p) => p.businessId === businessId),
      payments: store.payments.filter((p) => p.businessId === businessId).slice(0, 20),
      subscriptionPayments: store.subscriptionPayments.filter((p) => p.businessId === businessId),
      activityLogs: store.auditLogs
        .filter((l) => l.targetId === businessId)
        .slice(0, 30),
      issues: getMarqueeIssues(businessId)
    };
  },

  updateMarqueeApproval(businessId, approvalStatus, admin) {
    const business = getBusiness(businessId);
    if (!business) return null;
    const old = business.approvalStatus;
    business.approvalStatus = approvalStatus;
    if (approvalStatus === "suspended") business.status = "suspended";
    if (approvalStatus === "approved") business.status = "active";
    persist();
    if (admin) {
      db.addAuditLog({
        adminId: admin.id,
        adminName: admin.name,
        action: `business_${approvalStatus}`,
        module: "approvals",
        targetId: businessId,
        oldValue: old,
        newValue: approvalStatus
      });
    }
    return business;
  },

  extendSubscription(businessId, days = 30, admin) {
    const sub = getSubscription(businessId);
    if (!sub) return null;
    const end = new Date(sub.currentPeriodEnd || new Date());
    end.setDate(end.getDate() + days);
    sub.currentPeriodEnd = end.toISOString();
    sub.status = "active";
    persist();
    if (admin) {
      db.addAuditLog({
        adminId: admin.id,
        adminName: admin.name,
        action: "subscription_extended",
        module: "subscriptions",
        targetId: businessId,
        newValue: `${days} days`
      });
    }
    return sub;
  },

  listSubscriptionsAdmin() {
    return store.businessSubscriptions.map((s) => {
      const biz = getBusiness(s.businessId);
      const owner = biz ? findUserById(biz.ownerId) : null;
      const plan = getPlan(s.planId);
      return {
        businessId: s.businessId,
        businessName: biz?.businessName,
        ownerPhone: owner?.phone,
        planId: s.planId,
        planName: plan?.name,
        pricePkr: plan?.pricePkr,
        userLimit: plan?.userLimit,
        usedMembers: teamUsage(s.businessId),
        startDate: s.currentPeriodStart,
        expiryDate: s.currentPeriodEnd,
        paymentStatus: s.paymentStatus || "pending",
        subscriptionStatus: s.status
      };
    });
  },

  listSubscriptionPaymentsAdmin(filters = {}) {
    let list = [...store.subscriptionPayments];
    if (filters.status) list = list.filter((p) => p.status === filters.status);
    if (filters.date) list = list.filter((p) => p.paymentDate === filters.date);
    return list.map((p) => {
      const biz = getBusiness(p.businessId);
      return { ...p, businessName: biz?.businessName };
    });
  },

  confirmSubscriptionPayment(id, admin, note) {
    const payment = store.subscriptionPayments.find((p) => p.id === id);
    if (!payment) return null;
    payment.status = "confirmed";
    payment.confirmedBy = admin.name;
    payment.adminNote = note || "";
    payment.reviewedAt = new Date().toISOString();
    activatePlan(payment.businessId, payment.planId);
    const sub = getSubscription(payment.businessId);
    if (sub) sub.paymentStatus = "confirmed";
    persist();
    db.addAuditLog({
      adminId: admin.id,
      adminName: admin.name,
      action: "payment_confirmed",
      module: "payments",
      targetId: id,
      newValue: note || "confirmed"
    });
    return payment;
  },

  rejectSubscriptionPayment(id, admin, note) {
    const payment = store.subscriptionPayments.find((p) => p.id === id);
    if (!payment) return null;
    payment.status = "rejected";
    payment.reviewedBy = admin.name;
    payment.adminNote = note || "";
    payment.reviewedAt = new Date().toISOString();
    persist();
    db.addAuditLog({
      adminId: admin.id,
      adminName: admin.name,
      action: "payment_rejected",
      module: "payments",
      targetId: id,
      newValue: note || "rejected"
    });
    return payment;
  },

  updateAdminUser(id, patch, actor) {
    const admin = store.adminUsers.find((a) => a.id === id);
    if (!admin) return null;
    if (patch.role) admin.role = patch.role;
    if (patch.status) admin.status = patch.status;
    if (patch.name) admin.name = patch.name;
    persist();
    if (actor) {
      db.addAuditLog({
        adminId: actor.id,
        adminName: actor.name,
        action: patch.status === "inactive" ? "admin_user_deactivated" : "admin_user_updated",
        module: "admin_users",
        targetId: id
      });
    }
    const { passwordHash, ...safe } = admin;
    return safe;
  },

  createSubscriptionPayment({ businessId, planId, amount, paymentMethod, proofUrl, note }) {
    const payment = {
      id: newId(),
      businessId,
      planId,
      amount: Number(amount),
      paymentMethod: paymentMethod || "manual",
      proofUrl: proofUrl || null,
      note: note || "",
      paymentDate: new Date().toISOString().slice(0, 10),
      status: "pending",
      confirmedBy: null,
      adminNote: "",
      createdAt: new Date().toISOString()
    };
    store.subscriptionPayments.push(payment);
    persist();
    return payment;
  },

  getSettings() {
    return store.settings;
  },

  updateSettings(patch, admin) {
    Object.assign(store.settings, patch);
    persist();
    if (admin) {
      db.addAuditLog({
        adminId: admin.id,
        adminName: admin.name,
        action: "settings_updated",
        module: "settings",
        targetId: "platform"
      });
    }
    return store.settings;
  },

  createDemoRequest({ name, businessName, phone, city, teamSize, message }) {
    const request = {
      id: newId(),
      name,
      businessName,
      phone,
      city,
      teamSize: Number.isFinite(teamSize) ? teamSize : null,
      message: message || "",
      status: "new",
      source: "website",
      createdAt: new Date().toISOString()
    };
    store.demoRequests.push(request);
    persist();
    return request;
  },

  listDemoRequests() {
    return [...store.demoRequests].sort(
      (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
    );
  }
};
