import { useEffect, useState } from "react";
import { api } from "../lib/api.js";

export default function PaymentsPage() {
  const [summary, setSummary] = useState(null);
  const [rows, setRows] = useState([]);

  useEffect(() => {
    Promise.all([api.paymentsSummary(), api.payments()])
      .then(([s, p]) => {
        setSummary(s);
        setRows(p.payments || []);
      })
      .catch(() => {});
  }, []);

  return (
    <section>
      <header className="page-header"><h1>Payments</h1></header>
      <div className="stat-grid">
        <article className="stat-card"><p className="muted">Received</p><h3>PKR {summary?.totalReceived ?? 0}</h3></article>
        <article className="stat-card"><p className="muted">Pending</p><h3>PKR {summary?.pendingAmount ?? 0}</h3></article>
      </div>
      <article className="card">
        <table className="table">
          <thead><tr><th>Booking</th><th>Amount</th><th>Type</th><th>Date</th></tr></thead>
          <tbody>
            {rows.map((p) => (
              <tr key={p.id}><td>{p.bookingId}</td><td>PKR {p.amount}</td><td>{p.paymentType}</td><td>{p.paymentDate}</td></tr>
            ))}
          </tbody>
        </table>
      </article>
    </section>
  );
}
