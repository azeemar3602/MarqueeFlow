import { useAuth } from "../context/AuthContext.jsx";

export default function SettingsPage() {
  const { business, user } = useAuth();

  return (
    <section>
      <header className="page-header"><h1>Settings</h1></header>
      <article className="card">
        <h2>Business profile</h2>
        <p><strong>Name:</strong> {business?.businessName}</p>
        <p><strong>Phone:</strong> {business?.phone}</p>
        <p><strong>Currency:</strong> {business?.currencyCode || "PKR"}</p>
        <p><strong>Address:</strong> {business?.address || "—"}</p>
      </article>
      <article className="card">
        <h2>Account</h2>
        <p><strong>Owner:</strong> {user?.name}</p>
        <p><strong>Role:</strong> {user?.role}</p>
      </article>
    </section>
  );
}
