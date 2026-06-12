import { useEffect, useState } from "react";
import { api } from "../lib/api.js";

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
      <header className="page-header">
        <h1>Dashboard</h1>
        <p className="muted">Business KPIs, upcoming events, and pending actions.</p>
      </header>
      {error ? <p className="error">{error}</p> : null}
      <div className="stat-grid">
        <Stat label="Today's events" value={summary?.todayCount ?? "—"} />
        <Stat label="Upcoming" value={summary?.upcomingCount ?? "—"} />
        <Stat label="Pending payments" value={summary?.pendingPayments ?? "—"} />
        <Stat label="Available slots today" value={summary?.availableSlotsToday ?? "—"} />
      </div>
      <article className="card">
        <h2>Upcoming events</h2>
        <ul className="list">
          {(summary?.upcoming || []).map((b) => (
            <li key={b.id}>
              <strong>{b.customerName}</strong> — {b.eventDate} · {b.eventType}
            </li>
          ))}
          {!summary?.upcoming?.length ? <li>No upcoming events</li> : null}
        </ul>
      </article>
    </section>
  );
}
