import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../lib/api.js";
import { Badge, EmptyState, PageHeader } from "../components/PageHeader.jsx";

export default function ApprovalsPage() {
  const [rows, setRows] = useState([]);

  useEffect(() => {
    api.approvals().then((d) => setRows(d.approvals || [])).catch(() => {});
  }, []);

  async function approve(id) {
    await api.updateApproval(id, "approved");
    const data = await api.approvals();
    setRows(data.approvals || []);
  }

  async function reject(id) {
    await api.updateApproval(id, "rejected");
    const data = await api.approvals();
    setRows(data.approvals || []);
  }

  return (
    <section>
      <PageHeader title="Approvals" subtitle="Review new marquee registrations before full platform access." />
      <article className="card panel-card">
        {rows.length ? (
          <table className="table">
            <thead><tr><th>Business</th><th>Owner</th><th>Phone</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody>
              {rows.map((m) => (
                <tr key={m.id}>
                  <td><Link to={`/marquees/${m.id}`}>{m.businessName}</Link></td>
                  <td>{m.ownerName}</td>
                  <td>{m.ownerPhone}</td>
                  <td><Badge>{m.approvalStatus}</Badge></td>
                  <td className="actions">
                    <button type="button" className="btn btn-primary" onClick={() => approve(m.id)}>Approve</button>
                    <button type="button" className="btn btn-ghost" onClick={() => reject(m.id)}>Reject</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <EmptyState message="No pending approvals." />
        )}
      </article>
    </section>
  );
}
