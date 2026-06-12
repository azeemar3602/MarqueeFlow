import { NavLink, Outlet } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

const nav = [
  { to: "/", label: "Dashboard", end: true },
  { to: "/businesses", label: "Businesses" },
  { to: "/plans", label: "Subscription Plans" },
  { to: "/custom-plans", label: "Custom Plan Requests" },
  { to: "/bookings", label: "Bookings" },
  { to: "/calendar", label: "Calendar & Slots" },
  { to: "/customers", label: "Customers" },
  { to: "/packages", label: "Packages" },
  { to: "/payments", label: "Payments" },
  { to: "/team", label: "Team Members" },
  { to: "/notifications", label: "Notifications" },
  { to: "/reports", label: "Reports" },
  { to: "/settings", label: "Settings" }
];

export default function Layout() {
  const { user, business, logout } = useAuth();

  return (
    <div className="shell">
      <aside className="sidebar">
        <div className="brand">
          <p className="eyebrow">MarqueeFlow</p>
          <h2>Control Panel</h2>
        </div>
        <nav className="nav">
          {nav.map((item) => (
            <NavLink key={item.to} to={item.to} end={item.end} className="nav-link">
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className="sidebar-footer">
          <p className="muted">{user?.name}</p>
          <p className="muted small">{business?.businessName}</p>
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
