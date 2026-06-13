import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { api } from "../lib/api.js";
import { Badge, EmptyState, PageHeader } from "../components/PageHeader.jsx";

const tabs = [
  { id: "overview", label: "Overview" },
  { id: "subscription", label: "Subscription" },
  { id: "payments", label: "Payments" },
  { id: "bookings", label: "Bookings" },
  { id: "customers", label: "Customers" },
  { id: "team", label: "Team" },
  { id: "packages", label: "Packages" },
  { id: "activity", label: "Activity Logs" },
  { id: "issues", label: "Issues / Support" }
];

function TabPanel({ title, children }) {
  return (
    <article className="card panel-card">
      <h2>{title}</h2>
      {children}
    </article>
  );
}

export default function MarqueeDetailPage() {
  const { id } = useParams();
  const [detail, setDetail] = useState(null);
  const [tab, setTab] = useState("overview");
  const [error, setError] = useState("");

  async function load() {
    try {
      setDetail(await api.marquee(id));
    } catch (e) {
      setError(e.message);
    }
  }

  useEffect(() => {
    load();
  }, [id]);

  async function setApproval(status) {
    await api.updateApproval(id, status);
    await load();
  }

  if (!detail && !error) return <p>Loading...</p>;
  if (error) return <p className="error">{error}</p>;

  const b = detail.business;
  const sub = detail.subscription;
  const stats = detail.stats || {};
  const approval = b.approvalStatus || "approved";
  const isApproved = approval === "approved";
  const trialNotStarted = !sub?.trialStart && sub?.status !== "active" && sub?.status !== "trial";

  return (
    <section>
      <PageHeader
        title={b.businessName}
        subtitle={`${detail.owner?.name} · ${b.phone} · ${b.address || "—"}`}
      />
      <div className="chip-row" style={{ marginBottom: 16 }}>
        {tabs.map((t) => (
          <button key={t.id} type="button" className={`chip ${tab === t.id ? "active" : ""}`} onClick={() => setTab(t.id)}>
            {t.label}
          </button>
        ))}
      </div>

      {tab === "overview" ? (
        <div className="grid">
          <TabPanel title="Platform status">
            <p><Badge>{b.approvalStatus}</Badge> · Business status: <Badge>{b.status}</Badge> · Subscription: <Badge>{sub?.status}</Badge></p>
            <p>Total bookings: <strong>{stats.totalBookings}</strong></p>
            <p>Total revenue (bookings): <strong>PKR {stats.totalRevenuePKR ?? 0}</strong></p>
            <p>Team usage: <strong>{detail.teamUsage?.used}/{detail.teamUsage?.limit}</strong></p>
            <p>Pending booking payments: <strong>{stats.pendingPayments}</strong></p>
            <p>Open issues: <strong>{detail.issues?.length || 0}</strong></p>
          </TabPanel>
          <TabPanel title="Owner & business">
            <p>Owner: {detail.owner?.name}</p>
            <p>Phone: {detail.owner?.phone || b.phone}</p>
            <p>Location: {b.address || "—"}</p>
            <p>Joined: {b.createdAt?.slice?.(0, 10) || "—"}</p>
          </TabPanel>
          <TabPanel title="Quick actions">
            <div className="actions">
              {!isApproved ? (
                <button type="button" className="btn btn-primary" onClick={() => setApproval("approved")}>Approve</button>
              ) : (
                <button type="button" className="btn btn-primary" disabled title="Marquee is already approved">Approved</button>
              )}
              <button type="button" className="btn btn-ghost" onClick={() => setApproval("rejected")} disabled={approval === "rejected"}>Reject</button>
              <button type="button" className="btn btn-ghost" onClick={() => setApproval("suspended")} disabled={approval === "suspended"}>Suspend</button>
              <button type="button" className="btn btn-ghost" onClick={() => api.extendSubscription(id).then(load)}>Extend plan</button>
            </div>
          </TabPanel>
        </div>
      ) : null}

      {tab === "subscription" ? (
        <TabPanel title="Subscription summary">
          <p>Plan: <strong>{sub?.plan?.name || sub?.planId || "—"}</strong> · PKR {sub?.plan?.pricePkr ?? "—"}/month</p>
          <p>Status: <Badge>{sub?.status || "none"}</Badge> · Payment: <Badge>{sub?.paymentStatus || "pending"}</Badge></p>
          <p>Members: {detail.teamUsage?.used}/{detail.teamUsage?.limit}</p>
          {trialNotStarted ? (
            <p className="muted">Trial has not started yet. Trial begins when Super Admin approves this marquee.</p>
          ) : (
            <>
              <p>Trial start: {sub?.trialStart?.slice?.(0, 10) || "—"}</p>
              <p>Trial end: {sub?.trialEnd?.slice?.(0, 10) || "—"}</p>
              <p>Current period start: {sub?.currentPeriodStart?.slice?.(0, 10) || "—"}</p>
              <p>Current period end: {sub?.currentPeriodEnd?.slice?.(0, 10) || sub?.periodEnd?.slice?.(0, 10) || "—"}</p>
            </>
          )}
          <h3>Subscription payments (plan renewals)</h3>
          <p className="muted">These are marquee subscription fees. Customer booking advances appear under the Payments tab.</p>
          {(detail.subscriptionPayments || []).length ? (
            <table className="table">
              <thead><tr><th>Amount</th><th>Plan</th><th>Date</th><th>Status</th><th>Proof</th></tr></thead>
              <tbody>
                {detail.subscriptionPayments.map((p) => (
                  <tr key={p.id}>
                    <td>PKR {p.amount}</td>
                    <td>{p.planId}</td>
                    <td>{p.paymentDate}</td>
                    <td><Badge>{p.status}</Badge></td>
                    <td>{p.proofUrl ? <a href={p.proofUrl} target="_blank" rel="noreferrer">View proof</a> : "—"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <p className="muted">No subscription payments recorded.</p>
          )}
        </TabPanel>
      ) : null}

      {tab === "payments" ? (
        <TabPanel title="Booking payments (customer advances)">
          <p className="muted">Advance and balance payments recorded against individual bookings. For plan subscription fees, see the Subscription tab.</p>
          {(detail.payments || []).length ? (
            <table className="table">
              <thead><tr><th>Amount</th><th>Booking</th><th>Date</th><th>Type</th></tr></thead>
              <tbody>
                {detail.payments.map((p) => (
                  <tr key={p.id}><td>PKR {p.amount}</td><td>{p.bookingId}</td><td>{p.paymentDate}</td><td>{p.paymentType}</td></tr>
                ))}
              </tbody>
            </table>
          ) : (
            <EmptyState message="No booking payments for this marquee." />
          )}
        </TabPanel>
      ) : null}

      {tab === "bookings" ? (
        <TabPanel title="Bookings">
          {(detail.bookings || []).length ? (
            <table className="table">
              <thead><tr><th>Code</th><th>Customer</th><th>Date</th><th>Event</th><th>Status</th><th>Payment</th></tr></thead>
              <tbody>
                {detail.bookings.map((row) => (
                  <tr key={row.id}>
                    <td>{row.bookingCode}</td>
                    <td>{row.customerName}</td>
                    <td>{row.eventDate}</td>
                    <td>{row.eventType}</td>
                    <td><Badge>{row.status}</Badge></td>
                    <td><Badge>{row.paymentStatus}</Badge></td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <EmptyState message="No bookings yet." />
          )}
        </TabPanel>
      ) : null}

      {tab === "customers" ? (
        <TabPanel title="Customers">
          {(detail.customers || []).length ? (
            <table className="table">
              <thead><tr><th>Name</th><th>Phone</th><th>Notes</th></tr></thead>
              <tbody>
                {detail.customers.map((c) => (
                  <tr key={c.id}><td>{c.name}</td><td>{c.phone}</td><td>{c.notes || "—"}</td></tr>
                ))}
              </tbody>
            </table>
          ) : (
            <EmptyState message="No customers yet." />
          )}
        </TabPanel>
      ) : null}

      {tab === "team" ? (
        <TabPanel title="Team members">
          {(detail.teamMembers || []).length ? (
            <table className="table">
              <thead><tr><th>Name</th><th>Phone</th><th>Role</th><th>Status</th></tr></thead>
              <tbody>
                {detail.teamMembers.map((m) => (
                  <tr key={m.id}><td>{m.name}</td><td>{m.phone}</td><td><Badge>{m.role}</Badge></td><td><Badge>{m.status}</Badge></td></tr>
                ))}
              </tbody>
            </table>
          ) : (
            <EmptyState message="No team members." />
          )}
        </TabPanel>
      ) : null}

      {tab === "packages" ? (
        <TabPanel title="Packages">
          {(detail.packages || []).length ? (
            <div className="grid">
              {detail.packages.map((p) => (
                <article className="card" key={p.id}>
                  <h3>{p.name}</h3>
                  <p>PKR {p.price}</p>
                  <p className="muted">Guests: {p.guestLimit || "—"} · <Badge>{p.status}</Badge></p>
                  <p className="muted">{p.description || ""}</p>
                  {(p.includedServices || p.inclusionsJson || []).length ? (
                    <ul className="list">{(p.includedServices || p.inclusionsJson).map((s) => <li key={s}>{s}</li>)}</ul>
                  ) : null}
                </article>
              ))}
            </div>
          ) : (
            <EmptyState message="No packages configured." />
          )}
        </TabPanel>
      ) : null}

      {tab === "activity" ? (
        <TabPanel title="Activity logs">
          {(detail.activityLogs || []).length ? (
            <table className="table">
              <thead><tr><th>When</th><th>Admin</th><th>Action</th><th>Module</th></tr></thead>
              <tbody>
                {detail.activityLogs.map((log) => (
                  <tr key={log.id}>
                    <td>{log.createdAt?.replace?.("T", " ").slice?.(0, 19)}</td>
                    <td>{log.adminName}</td>
                    <td>{log.action}</td>
                    <td>{log.module}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <EmptyState message="No activity logged for this marquee yet." />
          )}
        </TabPanel>
      ) : null}

      {tab === "issues" ? (
        <TabPanel title="Issues / Support">
          {(detail.issues || []).length ? (
            <table className="table">
              <thead><tr><th>Type</th><th>Message</th><th>Severity</th><th>Status</th></tr></thead>
              <tbody>
                {detail.issues.map((issue) => (
                  <tr key={issue.id}>
                    <td><Badge>{issue.type}</Badge></td>
                    <td>{issue.message}</td>
                    <td>{issue.severity}</td>
                    <td>{issue.status}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <EmptyState message="No open issues for this marquee." />
          )}
        </TabPanel>
      ) : null}

      <p style={{ marginTop: 16 }}><Link to="/marquees">← Back to marquees</Link></p>
    </section>
  );
}
