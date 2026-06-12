import { useEffect, useState } from "react";
import { api } from "../lib/api.js";

export default function CustomersPage() {
  const [rows, setRows] = useState([]);

  useEffect(() => {
    api.bookings().then((d) => {
      const map = new Map();
      (d.bookings || []).forEach((b) => {
        const key = b.customerPhone || b.customerName;
        if (!map.has(key)) {
          map.set(key, { name: b.customerName, phone: b.customerPhone, bookings: 0 });
        }
        map.get(key).bookings += 1;
      });
      setRows([...map.values()]);
    }).catch(() => {});
  }, []);

  return (
    <section>
      <header className="page-header"><h1>Customers</h1></header>
      <article className="card">
        <table className="table">
          <thead><tr><th>Name</th><th>Phone</th><th>Bookings</th></tr></thead>
          <tbody>
            {rows.map((c) => (
              <tr key={c.phone}><td>{c.name}</td><td>{c.phone}</td><td>{c.bookings}</td></tr>
            ))}
          </tbody>
        </table>
      </article>
    </section>
  );
}
