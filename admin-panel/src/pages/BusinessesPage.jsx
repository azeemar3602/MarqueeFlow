import { useEffect, useState } from "react";
import { api } from "../lib/api.js";
import { Badge, EmptyState, PageHeader } from "../components/PageHeader.jsx";

export default function BusinessesPage() {
  const [rows, setRows] = useState([]);
  const [error, setError] = useState("");

  useEffect(() => {
    api.businesses().then((d) => setRows(d.businesses || [])).catch((e) => setError(e.message));
  }, []);

  return (
    <section>
      <PageHeader
        title="Businesses"
        subtitle="Registered venues and subscription status."
      />
      {error ? <p className="error">{error}</p> : null}
      <article className="card panel-card">
        {rows.length ? (
          <table className="table">
            <thead>
              <tr><th>Name</th><th>Phone</th><th>Plan</th><th>Status</th></tr>
            </thead>
            <tbody>
              {rows.map((b) => (
                <tr key={b.id}>
                  <td>{b.businessName}</td>
                  <td>{b.phone}</td>
                  <td>{b.subscription?.plan?.name || b.subscription?.planId}</td>
                  <td><Badge>{b.subscription?.status}</Badge></td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <EmptyState message="No businesses found." />
        )}
      </article>
    </section>
  );
}
