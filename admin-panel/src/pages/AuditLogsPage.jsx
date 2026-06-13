import { useEffect, useState } from "react";
import { api } from "../lib/api.js";
import { EmptyState, PageHeader } from "../components/PageHeader.jsx";

export default function AuditLogsPage() {
  const [rows, setRows] = useState([]);

  useEffect(() => {
    api.auditLogs().then((d) => setRows(d.logs || [])).catch(() => {});
  }, []);

  return (
    <section>
      <PageHeader title="Audit Logs" subtitle="Sensitive Super Admin actions across the platform." />
      <article className="card panel-card">
        {rows.length ? (
          <table className="table">
            <thead><tr><th>When</th><th>Admin</th><th>Action</th><th>Module</th><th>Target</th></tr></thead>
            <tbody>
              {rows.map((log) => (
                <tr key={log.id}>
                  <td>{log.createdAt?.replace?.("T", " ").slice?.(0, 19)}</td>
                  <td>{log.adminName}</td>
                  <td>{log.action}</td>
                  <td>{log.module}</td>
                  <td>{log.targetId || "—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <EmptyState message="No audit logs yet." />
        )}
      </article>
    </section>
  );
}
