import { useEffect, useState } from "react";
import { api } from "../lib/api.js";
import { EmptyState, PageHeader } from "../components/PageHeader.jsx";

const roles = [
  { id: "super_admin", label: "Super Admin" },
  { id: "support_admin", label: "Support Admin" },
  { id: "finance_admin", label: "Finance Admin" },
  { id: "read_only_admin", label: "Read-only Admin" }
];

export default function AdminUsersPage() {
  const [rows, setRows] = useState([]);
  const [form, setForm] = useState({ name: "", phone: "", password: "", role: "support_admin" });
  const [error, setError] = useState("");

  async function load() {
    const data = await api.adminUsers();
    setRows(data.admins || []);
  }

  useEffect(() => {
    load().catch(() => {});
  }, []);

  async function createAdmin(e) {
    e.preventDefault();
    setError("");
    try {
      await api.createAdminUser(form);
      setForm({ name: "", phone: "", password: "", role: "support_admin" });
      await load();
    } catch (err) {
      setError(err.message);
    }
  }

  async function deactivate(id) {
    await api.updateAdminUser(id, { status: "inactive" });
    await load();
  }

  return (
    <section>
      <PageHeader title="Admin Users" subtitle="Super Admin can add and deactivate internal admin accounts." />
      <article className="card panel-card">
        <h2>Add admin user</h2>
        <form onSubmit={createAdmin}>
          <label>Name<input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} required /></label>
          <label>Phone<input value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} required /></label>
          <label>Password<input type="password" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} required /></label>
          <label>
            Role
            <select value={form.role} onChange={(e) => setForm({ ...form, role: e.target.value })}>
              {roles.map((r) => <option key={r.id} value={r.id}>{r.label}</option>)}
            </select>
          </label>
          {error ? <p className="error">{error}</p> : null}
          <button type="submit" className="btn btn-primary">Add Admin User</button>
        </form>
      </article>
      <article className="card panel-card">
        {rows.length ? (
          <table className="table">
            <thead><tr><th>Name</th><th>Phone</th><th>Role</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody>
              {rows.map((a) => (
                <tr key={a.id}>
                  <td>{a.name}</td>
                  <td>{a.phone}</td>
                  <td>{a.role}</td>
                  <td>{a.status}</td>
                  <td>
                    {a.status === "active" ? (
                      <button type="button" className="btn btn-ghost" onClick={() => deactivate(a.id)}>Deactivate</button>
                    ) : (
                      "—"
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <EmptyState message="No admin users found." />
        )}
      </article>
    </section>
  );
}
