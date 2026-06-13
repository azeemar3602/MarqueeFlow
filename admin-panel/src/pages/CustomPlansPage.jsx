import { useEffect, useState } from "react";
import { api } from "../lib/api.js";
import { Badge, EmptyState, PageHeader } from "../components/PageHeader.jsx";

export default function CustomPlansPage() {
  const [rows, setRows] = useState([]);

  async function load() {
    const data = await api.customPlanRequests();
    setRows(data.requests || []);
  }

  useEffect(() => {
    load().catch(() => {});
  }, []);

  async function setStatus(id, status) {
    await api.updateCustomPlanRequest(id, status);
    await load();
  }

  return (
    <section>
      <PageHeader
        title="Custom Plan Requests"
        subtitle="Review and approve custom team-size plans."
      />
      <article className="card panel-card">
        {rows.length ? (
          <table className="table">
            <thead>
              <tr><th>Team size</th><th>Contact</th><th>Phone</th><th>Note</th><th>Status</th><th>Actions</th></tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.id}>
                  <td>{r.requestedTeamSize}</td>
                  <td>{r.contactName}</td>
                  <td>{r.phone}</td>
                  <td>{r.note || "—"}</td>
                  <td><Badge>{r.status}</Badge></td>
                  <td className="actions">
                    <button type="button" className="btn btn-ghost" onClick={() => setStatus(r.id, "approved")}>Approve</button>
                    <button type="button" className="btn btn-ghost" onClick={() => setStatus(r.id, "rejected")}>Reject</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <EmptyState message="No custom plan requests." />
        )}
      </article>
    </section>
  );
}
