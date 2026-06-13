import { useEffect, useState } from "react";
import { api } from "../lib/api.js";
import { Badge, EmptyState, PageHeader } from "../components/PageHeader.jsx";

export default function PaymentsPage() {
  const [rows, setRows] = useState([]);
  const [note, setNote] = useState("");
  const [activePayment, setActivePayment] = useState(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");

  async function load() {
    const data = await api.subscriptionPayments();
    setRows(data.payments || []);
  }

  useEffect(() => {
    load().catch((e) => setError(e.message));
  }, []);

  function openReview(payment) {
    setNote("");
    setError("");
    setActivePayment(payment);
  }

  function closeReview() {
    if (busy) return;
    setActivePayment(null);
    setNote("");
    setError("");
  }

  async function confirm() {
    if (!activePayment) return;
    setBusy(true);
    setError("");
    try {
      await api.confirmPayment(activePayment.id, note);
      closeReview();
      await load();
    } catch (e) {
      setError(e.message);
    } finally {
      setBusy(false);
    }
  }

  async function reject() {
    if (!activePayment) return;
    setBusy(true);
    setError("");
    try {
      await api.rejectPayment(activePayment.id, note);
      closeReview();
      await load();
    } catch (e) {
      setError(e.message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <section>
      <PageHeader
        title="Subscription Payments"
        subtitle="Review and confirm marquee subscription payments (plan renewals). Booking advance payments are managed inside each marquee under Booking Payments."
      />
      <article className="card panel-card">
        {rows.length ? (
          <table className="table">
            <thead>
              <tr><th>Business</th><th>Plan</th><th>Amount</th><th>Method</th><th>Date</th><th>Proof</th><th>Status</th><th>Actions</th></tr>
            </thead>
            <tbody>
              {rows.map((p) => (
                <tr key={p.id}>
                  <td>{p.businessName || p.businessId}</td>
                  <td>{p.planId}</td>
                  <td>PKR {p.amount}</td>
                  <td>{p.paymentMethod || "—"}</td>
                  <td>{p.paymentDate}</td>
                  <td>{p.proofUrl ? <a href={p.proofUrl} target="_blank" rel="noreferrer">View proof</a> : "—"}</td>
                  <td><Badge>{p.status}</Badge></td>
                  <td className="actions">
                    {p.status === "pending" ? (
                      <button type="button" className="btn btn-ghost" onClick={() => openReview(p)}>Review</button>
                    ) : (
                      <span className="muted">{p.confirmedBy || p.reviewedBy || "—"}</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <EmptyState message="No subscription payments recorded. Run npm run seed:phase3 locally for a demo pending payment." />
        )}
      </article>

      {activePayment ? (
        <div className="modal-backdrop" role="presentation" onClick={closeReview}>
          <div className="modal card panel-card" role="dialog" aria-modal="true" onClick={(e) => e.stopPropagation()}>
            <h2>Review subscription payment</h2>
            <p className="muted">Confirm or reject this plan payment. An audit log entry is recorded for each action.</p>
            <dl className="detail-list">
              <div><dt>Business</dt><dd>{activePayment.businessName || activePayment.businessId}</dd></div>
              <div><dt>Plan</dt><dd>{activePayment.planId}</dd></div>
              <div><dt>Amount</dt><dd>PKR {activePayment.amount}</dd></div>
              <div><dt>Date</dt><dd>{activePayment.paymentDate}</dd></div>
              <div><dt>Proof</dt><dd>{activePayment.proofUrl ? <a href={activePayment.proofUrl} target="_blank" rel="noreferrer">View proof</a> : "—"}</dd></div>
            </dl>
            <label className="field">
              <span>Admin note (optional)</span>
              <textarea rows={3} placeholder="Reason for confirm/reject, reference number, etc." value={note} onChange={(e) => setNote(e.target.value)} />
            </label>
            {error ? <p className="error">{error}</p> : null}
            <div className="actions">
              <button type="button" className="btn btn-primary" disabled={busy} onClick={confirm}>Confirm payment</button>
              <button type="button" className="btn btn-ghost" disabled={busy} onClick={reject}>Reject payment</button>
              <button type="button" className="btn btn-ghost" disabled={busy} onClick={closeReview}>Cancel</button>
            </div>
          </div>
        </div>
      ) : null}
    </section>
  );
}
