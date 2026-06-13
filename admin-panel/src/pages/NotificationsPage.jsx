import { useEffect, useState } from "react";
import { api } from "../lib/api.js";
import { EmptyState, PageHeader } from "../components/PageHeader.jsx";

export default function NotificationsPage() {
  const [rows, setRows] = useState([]);

  useEffect(() => {
    api.notifications().then((d) => setRows(d.notifications || [])).catch(() => {});
  }, []);

  return (
    <section>
      <PageHeader
        title="Notifications"
        subtitle="System and booking alerts."
      />
      <article className="card panel-card">
        {rows.length ? (
          <ul className="list">
            {rows.map((n) => (
              <li key={n.id}><strong>{n.title}</strong> — {n.message}</li>
            ))}
          </ul>
        ) : (
          <EmptyState message="No notifications." />
        )}
      </article>
    </section>
  );
}
