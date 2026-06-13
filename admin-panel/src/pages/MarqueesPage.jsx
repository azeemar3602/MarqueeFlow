import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../lib/api.js";
import { Badge, EmptyState, PageHeader } from "../components/PageHeader.jsx";

export default function MarqueesPage() {
  const [rows, setRows] = useState([]);

  useEffect(() => {
    api.marquees().then((d) => setRows(d.marquees || [])).catch(() => {});
  }, []);

  return (
    <section>
      <PageHeader title="Marquees / Business Profiles" subtitle="All registered marquee businesses on the platform." />
      <article className="card panel-card">
        {rows.length ? (
          <table className="table">
            <thead>
              <tr>
                <th>Business</th><th>Owner</th><th>City</th><th>Plan</th><th>Approval</th><th>Bookings</th><th>Revenue</th><th></th>
              </tr>
            </thead>
            <tbody>
              {rows.map((m) => (
                <tr key={m.id}>
                  <td>{m.businessName}</td>
                  <td>{m.ownerName}<br /><span className="muted">{m.ownerPhone}</span></td>
                  <td>{m.city || "—"}</td>
                  <td>{m.planName || "—"}</td>
                  <td><Badge>{m.approvalStatus}</Badge></td>
                  <td>{m.totalBookings}</td>
                  <td>PKR {m.totalRevenuePKR ?? 0}</td>
                  <td><Link to={`/marquees/${m.id}`}>Open</Link></td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <EmptyState message="No marquees registered yet." />
        )}
      </article>
    </section>
  );
}
