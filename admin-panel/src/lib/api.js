const API_BASE = import.meta.env.VITE_API_BASE_URL || "http://localhost:4010";
const TOKEN_KEY = "mf_admin_token";

export function getToken() {
  return localStorage.getItem(TOKEN_KEY);
}

export function setToken(token) {
  if (token) localStorage.setItem(TOKEN_KEY, token);
  else localStorage.removeItem(TOKEN_KEY);
}

async function request(path, options = {}) {
  const headers = { "Content-Type": "application/json", ...(options.headers || {}) };
  const token = getToken();
  if (token) headers.Authorization = `Bearer ${token}`;

  const res = await fetch(`${API_BASE}${path}`, { ...options, headers });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) {
    const err = new Error(body?.error?.message || `Request failed (${res.status})`);
    err.code = body?.error?.code;
    throw err;
  }
  return body;
}

export const api = {
  login: (phone, password) =>
    request("/api/auth/login", { method: "POST", body: JSON.stringify({ phone, password }) }),
  me: () => request("/api/auth/me"),
  logout: () => request("/api/auth/logout", { method: "POST" }),
  plans: () => request("/api/subscription/plans?currency=PKR"),
  subscriptionStatus: () => request("/api/subscription/status"),
  dashboard: () => request("/api/dashboard/summary"),
  bookings: (query = "") => request(`/api/bookings${query ? `?${query}` : ""}`),
  booking: (id) => request(`/api/bookings/${id}`),
  calendarMonth: (month) => request(`/api/calendar/month?month=${month}`),
  calendarDay: (date) => request(`/api/calendar/day?date=${date}`),
  paymentsSummary: () => request("/api/payments/summary"),
  payments: () => request("/api/payments"),
  packages: () => request("/api/packages"),
  teamMembers: () => request("/api/team/members"),
  teamUsage: () => request("/api/team/usage"),
  customPlanRequests: () => request("/api/subscription/custom-plan-requests"),
  updateCustomPlanRequest: (id, status) =>
    request(`/api/subscription/custom-plan-requests/${id}`, {
      method: "PATCH",
      body: JSON.stringify({ status })
    }),
  businesses: () => request("/api/admin/businesses"),
  reportsBookings: () => request("/api/admin/reports/bookings"),
  reportsPayments: () => request("/api/admin/reports/payments"),
  notifications: () => request("/api/notifications")
};
