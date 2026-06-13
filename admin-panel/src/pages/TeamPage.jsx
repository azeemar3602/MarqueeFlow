import { useEffect, useState } from "react";
import { api } from "../lib/api.js";
import { Badge, EmptyState, PageHeader } from "../components/PageHeader.jsx";

export default function TeamPage() {
  const [usage, setUsage] = useState(null);
  const [members, setMembers] = useState([]);

  useEffect(() => {
    Promise.all([api.teamUsage(), api.teamMembers()])
      .then(([u, m]) => {
        setUsage(u);
        setMembers(m.members || []);
      })
      .catch(() => {});
  }, []);

  return (
    <section>
      <PageHeader
        title="Team Members"
        subtitle="Plan usage and invited staff roles."
      />
      <article className="card panel-card">
        <p>Plan: <strong>{usage?.planName || usage?.planId}</strong></p>
        <p className="muted">Usage: {usage?.used}/{usage?.limit}</p>
      </article>
      <article className="card panel-card">
        {members.length ? (
          <table className="table">
            <thead><tr><th>Name</th><th>Phone</th><th>Role</th><th>Status</th></tr></thead>
            <tbody>
              {members.map((m) => (
                <tr key={m.id}>
                  <td>{m.name}</td>
                  <td>{m.phone}</td>
                  <td><Badge>{m.role}</Badge></td>
                  <td><Badge>{m.status}</Badge></td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <EmptyState message="No team members yet." />
        )}
      </article>
    </section>
  );
}
