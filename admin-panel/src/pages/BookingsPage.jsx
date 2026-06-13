import { useEffect, useState } from "react";
import { api } from "../lib/api.js";
import { Badge, EmptyState, PageHeader } from "../components/PageHeader.jsx";

export default function BookingsPage() {
  const [rows, setRows] = useState([]);
  const [search, setSearch] = useState("");

  async function load() {
    const q = search ? `search=${encodeURIComponent(search)}` : "";
    const data = await api.bookings(q);
    setRows(data.bookings || []);
  }

  useEffect(() => {
    api.bookings().then((data) => setRows(data.bookings || [])).catch(() => {});
  }, []);

  return (
    <section>
      <PageHeader
        title="Bookings"
        subtitle="Search and review all venue bookings."
      >
        <div className="toolbar">
          <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search bookings" />
          <button type="button" className="btn btn-primary" onClick={load}>Search</button>
        </div>
      </PageHeader>
      <article className="card panel-card">
        {rows.length ? (
          <table className="table">
            <thead>
              <tr><th>Code</th><th>Customer</th><th>Date</th><th>Event</th><th>Status</th><th>Payment</th></tr>
            </thead>
            <tbody>
              {rows.map((b) => (
                <tr key={b.id}>
                  <td>{b.bookingCode}</td>
                  <td>{b.customerName}</td>
                  <td>{b.eventDate}</td>
                  <td>{b.eventType}</td>
                  <td><Badge>{b.status}</Badge></td>
                  <td><Badge>{b.paymentStatus}</Badge></td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <EmptyState message="No bookings found." />
        )}
      </article>
    </section>
  );
}
