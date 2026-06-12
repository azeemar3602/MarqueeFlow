import { useEffect, useState } from "react";
import { api } from "../lib/api.js";

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
      <header className="page-header"><h1>Team Members</h1></header>
      <article className="card">
        <p>Plan: <strong>{usage?.planName || usage?.planId}</strong></p>
        <p className="muted">Usage: {usage?.used}/{usage?.limit}</p>
      </article>
      <article className="card">
        <table className="table">
          <thead><tr><th>Name</th><th>Phone</th><th>Role</th><th>Status</th></tr></thead>
          <tbody>
            {members.map((m) => (
              <tr key={m.id}><td>{m.name}</td><td>{m.phone}</td><td>{m.role}</td><td>{m.status}</td></tr>
            ))}
          </tbody>
        </table>
      </article>
    </section>
  );
}
