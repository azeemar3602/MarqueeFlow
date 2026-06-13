import { useEffect, useState } from "react";
import { api } from "../lib/api.js";
import { Badge, EmptyState, PageHeader } from "../components/PageHeader.jsx";

export default function SubscriptionsAdminPage() {
  const [rows, setRows] = useState([]);

  useEffect(() => {
    api.subscriptions().then((d) => setRows(d.subscriptions || [])).catch(() => {});
  }, []);

  return (
    <section>
      <PageHeader title="Subscriptions" subtitle="Business-by-business subscription management." />
      <article className="card panel-card">
        {rows.length ? (
          <table className="table">
            <thead>
              <tr><th>Business</th><th>Plan</th><th>Price</th><th>Members</th><th>Expiry</th><th>Status</th></tr>
            </thead>
            <tbody>
              {rows.map((s) => (
                <tr key={s.businessId}>
                  <td>{s.businessName}</td>
                  <td>{s.planName}</td>
                  <td>PKR {s.pricePkr}</td>
                  <td>{s.usedMembers}/{s.userLimit}</td>
                  <td>{s.expiryDate?.slice?.(0, 10) || "—"}</td>
                  <td><Badge>{s.subscriptionStatus}</Badge></td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <EmptyState message="No subscriptions yet." />
        )}
      </article>
    </section>
  );
}
