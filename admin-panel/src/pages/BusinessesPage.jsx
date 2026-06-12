import { useEffect, useState } from "react";
import { api } from "../lib/api.js";

export default function BusinessesPage() {
  const [rows, setRows] = useState([]);
  const [error, setError] = useState("");

  useEffect(() => {
    api.businesses().then((d) => setRows(d.businesses || [])).catch((e) => setError(e.message));
  }, []);

  return (
    <section>
      <header className="page-header"><h1>Businesses</h1></header>
      {error ? <p className="error">{error}</p> : null}
      <article className="card">
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
                <td>{b.subscription?.status}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </article>
    </section>
  );
}
