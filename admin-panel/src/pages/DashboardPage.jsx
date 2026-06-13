import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../lib/api.js";
import { Badge, PageHeader } from "../components/PageHeader.jsx";

function Stat({ label, value }) {
  return (
    <article className="stat-card">
      <p className="muted">{label}</p>
      <h3>{value}</h3>
    </article>
  );
}

export default function DashboardPage() {
  const [summary, setSummary] = useState(null);
  const [error, setError] = useState("");

  useEffect(() => {
    api.dashboard().then(setSummary).catch((e) => setError(e.message));
  }, []);

  return (
    <section>
      <PageHeader title="Super Admin Dashboard" subtitle="Platform overview, pending actions, and recent activity." />
      {error ? <p className="error">{error}</p> : null}
      <div className="stat-grid">
        <Stat label="Total marquees" value={summary?.totalMarquees ?? "—"} />
        <Stat label="Active subscriptions" value={summary?.activeSubscriptions ?? "—"} />
        <Stat label="Expired" value={summary?.expiredSubscriptions ?? "—"} />
        <Stat label="Trial businesses" value={summary?.trialBusinesses ?? "—"} />
        <Stat label="Pending approvals" value={summary?.pendingApprovals ?? "—"} />
        <Stat label="Suspended" value={summary?.suspendedBusinesses ?? "—"} />
        <Stat label="Custom requests" value={summary?.customPlanRequests ?? "—"} />
        <Stat label="Monthly revenue (PKR)" value={summary?.monthlyRevenuePKR?.toLocaleString?.() ?? summary?.monthlyRevenuePKR ?? "—"} />
      </div>
      <div className="grid">
        <article className="card panel-card">
          <h2>Pending actions</h2>
          <ul className="list">
            {(summary?.pendingActions || []).map((a) => (
              <li key={a.label}><strong>{a.label}</strong> — {a.count}</li>
            ))}
            {!summary?.pendingActions?.length ? <li className="muted">No pending actions</li> : null}
          </ul>
          <p><Link to="/approvals">Review approvals →</Link></p>
        </article>
        <article className="card panel-card">
          <h2>Recent activity</h2>
          <ul className="list">
            {(summary?.recentActivity || []).map((log) => (
              <li key={log.id}>{log.adminName} — {log.action} · {log.module}</li>
            ))}
            {!summary?.recentActivity?.length ? <li className="muted">No activity yet</li> : null}
          </ul>
          <p><Link to="/audit-logs">View audit logs →</Link></p>
        </article>
      </div>
    </section>
  );
}
