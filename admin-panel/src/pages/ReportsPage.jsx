import { useEffect, useState } from "react";
import { api } from "../lib/api.js";

export default function ReportsPage() {
  const [bookings, setBookings] = useState([]);
  const [payments, setPayments] = useState(null);

  useEffect(() => {
    Promise.all([api.reportsBookings(), api.reportsPayments()])
      .then(([b, p]) => {
        setBookings(b.bookings || []);
        setPayments(p);
      })
      .catch(() => {});
  }, []);

  return (
    <section>
      <header className="page-header"><h1>Reports</h1></header>
      <div className="grid">
        <article className="card">
          <h2>Bookings report</h2>
          <p className="muted">{bookings.length} bookings · export ready</p>
        </article>
        <article className="card">
          <h2>Payments report</h2>
          <p className="muted">Received PKR {payments?.summary?.totalReceived ?? 0}</p>
        </article>
      </div>
    </section>
  );
}
