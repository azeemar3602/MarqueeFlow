import { useEffect, useState } from "react";

const API_BASE = import.meta.env.VITE_API_BASE_URL || "http://localhost:4010";

export default function App() {
  const [health, setHealth] = useState(null);
  const [plans, setPlans] = useState([]);
  const [roles, setRoles] = useState([]);
  const [error, setError] = useState("");

  useEffect(() => {
    async function load() {
      try {
        const [healthRes, plansRes, rolesRes] = await Promise.all([
          fetch(`${API_BASE}/api/health`),
          fetch(`${API_BASE}/api/plans`),
          fetch(`${API_BASE}/api/roles`)
        ]);
        setHealth(await healthRes.json());
        setPlans((await plansRes.json()).plans || []);
        setRoles((await rolesRes.json()).roles || []);
      } catch (err) {
        setError(err.message || "Failed to reach API");
      }
    }
    load();
  }, []);

  return (
    <div className="page">
      <header className="hero">
        <p className="eyebrow">MarqueeFlow</p>
        <h1>Admin Control Panel</h1>
        <p>Manage plans, users, managers, waiters, bookings, slots, pricing, and business settings.</p>
      </header>

      <section className="card">
        <h2>API Status</h2>
        {error ? <p className="error">{error}</p> : null}
        {health ? (
          <pre>{JSON.stringify(health, null, 2)}</pre>
        ) : (
          <p>Checking API...</p>
        )}
      </section>

      <section className="grid">
        <article className="card">
          <h2>Subscription Plans (PKR)</h2>
          <ul>
            {plans.map((plan) => (
              <li key={plan.id}>
                <strong>{plan.name}</strong>
                {plan.requestCustom
                  ? " — Request custom plan"
                  : ` — PKR ${plan.pricePkr}/month`}
              </li>
            ))}
          </ul>
        </article>

        <article className="card">
          <h2>Roles</h2>
          <ul>
            {roles.map((role) => (
              <li key={role.id}>{role.label}</li>
            ))}
          </ul>
        </article>
      </section>
    </div>
  );
}
