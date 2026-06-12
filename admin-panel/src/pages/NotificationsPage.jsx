import { useEffect, useState } from "react";
import { api } from "../lib/api.js";

export default function NotificationsPage() {
  const [rows, setRows] = useState([]);

  useEffect(() => {
    api.notifications().then((d) => setRows(d.notifications || [])).catch(() => {});
  }, []);

  return (
    <section>
      <header className="page-header"><h1>Notifications</h1></header>
      <article className="card">
        <ul className="list">
          {rows.map((n) => (
            <li key={n.id}><strong>{n.title}</strong> — {n.message}</li>
          ))}
          {!rows.length ? <li>No notifications</li> : null}
        </ul>
      </article>
    </section>
  );
}
