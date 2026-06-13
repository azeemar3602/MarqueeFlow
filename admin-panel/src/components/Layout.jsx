import { NavLink, Outlet } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

const nav = [
  { to: "/", label: "Dashboard", end: true },
  { to: "/marquees", label: "Marquees" },
  { to: "/approvals", label: "Approvals" },
  { to: "/plans", label: "Subscription Plans" },
  { to: "/subscriptions", label: "Subscriptions" },
  { to: "/custom-plans", label: "Custom Plan Requests" },
  { to: "/payments", label: "Payments / Revenue" },
  { to: "/bookings", label: "Bookings Data" },
  { to: "/customers", label: "Customers Data" },
  { to: "/team", label: "Team Members Data" },
  { to: "/packages", label: "Packages Data" },
  { to: "/calendar", label: "Calendar & Slots Data" },
  { to: "/notifications", label: "Notifications" },
  { to: "/reports", label: "Reports" },
  { to: "/admin-users", label: "Admin Users" },
  { to: "/settings", label: "Settings" },
  { to: "/audit-logs", label: "Audit Logs" }
];

export default function Layout() {
  const { admin, logout } = useAuth();

  return (
    <div className="shell">
      <aside className="sidebar">
        <div className="brand">
          <img src="/marqueeflow-icon.png" alt="MarqueeFlow" className="brand-logo" />
          <div>
            <p className="eyebrow">MarqueeFlow</p>
            <h2 className="brand-title">Super Admin</h2>
          </div>
        </div>
        <nav className="nav">
          {nav.map((item) => (
            <NavLink key={item.to} to={item.to} end={item.end} className="nav-link">
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className="sidebar-footer">
          <p className="muted">{admin?.name}</p>
          <p className="muted small">{admin?.role?.replace("_", " ")}</p>
          <button type="button" className="btn btn-ghost" onClick={logout}>
            Logout
          </button>
        </div>
      </aside>
      <main className="content">
        <Outlet />
      </main>
    </div>
  );
}
