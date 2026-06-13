const API_BASE = import.meta.env.VITE_API_BASE_URL || "http://localhost:4010";
const TOKEN_KEY = "mf_super_admin_token";

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
    request("/api/admin/auth/login", { method: "POST", body: JSON.stringify({ phone, password }) }),
  me: () => request("/api/admin/auth/me"),
  logout: () => request("/api/admin/auth/logout", { method: "POST" }),
  dashboard: () => request("/api/admin/dashboard"),
  marquees: () => request("/api/admin/marquees"),
  marquee: (id) => request(`/api/admin/marquees/${id}`),
  updateApproval: (id, approvalStatus) =>
    request(`/api/admin/marquees/${id}/approval`, {
      method: "PATCH",
      body: JSON.stringify({ approvalStatus })
    }),
  extendSubscription: (id, days = 30) =>
    request(`/api/admin/marquees/${id}/extend-subscription`, {
      method: "POST",
      body: JSON.stringify({ days })
    }),
  approvals: () => request("/api/admin/approvals"),
  plans: () => request("/api/admin/subscription-plans"),
  subscriptions: () => request("/api/admin/subscriptions"),
  customPlanRequests: () => request("/api/admin/custom-plan-requests"),
  updateCustomPlanRequest: (id, status) =>
    request(`/api/admin/custom-plan-requests/${id}`, {
      method: "PATCH",
      body: JSON.stringify({ status })
    }),
  subscriptionPayments: (query = "") => request(`/api/admin/payments${query ? `?${query}` : ""}`),
  confirmPayment: (id, note) =>
    request(`/api/admin/payments/${id}/confirm`, { method: "PATCH", body: JSON.stringify({ note }) }),
  rejectPayment: (id, note) =>
    request(`/api/admin/payments/${id}/reject`, { method: "PATCH", body: JSON.stringify({ note }) }),
  createAdminUser: (payload) =>
    request("/api/admin/admin-users", { method: "POST", body: JSON.stringify(payload) }),
  updateAdminUser: (id, patch) =>
    request(`/api/admin/admin-users/${id}`, { method: "PATCH", body: JSON.stringify(patch) }),
  bookings: (query = "") => request(`/api/admin/bookings${query ? `?${query}` : ""}`),
  customers: (query = "") => request(`/api/admin/customers${query ? `?${query}` : ""}`),
  teamMembers: (query = "") => request(`/api/admin/team-members${query ? `?${query}` : ""}`),
  packages: (query = "") => request(`/api/admin/packages${query ? `?${query}` : ""}`),
  calendarMonth: (businessId, month) =>
    request(`/api/admin/calendar-slots?businessId=${businessId}&month=${month}`),
  adminUsers: () => request("/api/admin/admin-users"),
  settings: () => request("/api/admin/settings"),
  updateSettings: (patch) =>
    request("/api/admin/settings", { method: "PATCH", body: JSON.stringify(patch) }),
  auditLogs: () => request("/api/admin/audit-logs")
};
