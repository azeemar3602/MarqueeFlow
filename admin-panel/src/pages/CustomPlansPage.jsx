import { useEffect, useState } from "react";
import { api } from "../lib/api.js";

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
      <header className="page-header"><h1>Custom Plan Requests</h1></header>
      <article className="card">
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
                <td>{r.status}</td>
                <td className="actions">
                  <button type="button" className="btn btn-ghost" onClick={() => setStatus(r.id, "approved")}>Approve</button>
                  <button type="button" className="btn btn-ghost" onClick={() => setStatus(r.id, "rejected")}>Reject</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </article>
    </section>
  );
}
