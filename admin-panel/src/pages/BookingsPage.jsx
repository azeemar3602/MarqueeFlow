import { useEffect, useState } from "react";
import { api } from "../lib/api.js";

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
      <header className="page-header">
        <h1>Bookings</h1>
        <div className="toolbar">
          <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search bookings" />
          <button type="button" className="btn btn-primary" onClick={load}>Search</button>
        </div>
      </header>
      <article className="card">
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
                <td>{b.status}</td>
                <td>{b.paymentStatus}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </article>
    </section>
  );
}
