import { useEffect, useState } from "react";
import { api } from "../lib/api.js";

export default function PlansPage() {
  const [plans, setPlans] = useState([]);
  const [status, setStatus] = useState(null);

  useEffect(() => {
    Promise.all([api.plans(), api.subscriptionStatus()])
      .then(([p, s]) => {
        setPlans(p.plans || []);
        setStatus(s);
      })
      .catch(() => {});
  }, []);

  return (
    <section>
      <header className="page-header">
        <h1>Subscription Plans</h1>
        <p className="muted">PKR pricing and member limits (v1.4).</p>
      </header>
      {status ? (
        <article className="card">
          <p>Current plan: <strong>{status.plan?.name || status.planId}</strong> · {status.status}</p>
          <p className="muted">Members: {status.usedMembers ?? "—"} / {status.userLimit ?? status.plan?.userLimit}</p>
        </article>
      ) : null}
      <div className="grid">
        {plans.map((plan) => (
          <article className="card" key={plan.id}>
            <h2>{plan.name}</h2>
            <p>{plan.requestCustom ? "Request custom plan" : `PKR ${plan.pricePkr}/month`}</p>
            <p className="muted">{plan.userLimit ? `${plan.userLimit} person(s) total` : plan.description}</p>
          </article>
        ))}
      </div>
    </section>
  );
}
