import { useEffect, useState } from "react";
import { api } from "../lib/api.js";
import { PageHeader } from "../components/PageHeader.jsx";

export default function SettingsPage() {
  const [settings, setSettings] = useState(null);

  useEffect(() => {
    api.settings().then((d) => setSettings(d.settings)).catch(() => {});
  }, []);

  return (
    <section>
      <PageHeader title="Platform Settings" subtitle="Global MarqueeFlow configuration." />
      <article className="card panel-card">
        <p><strong>App name:</strong> {settings?.appName}</p>
        <p><strong>Currency:</strong> {settings?.currencyCode || "PKR"}</p>
        <p><strong>Trial days:</strong> {settings?.trialDays}</p>
        <p><strong>Manual approval:</strong> {settings?.manualApprovalEnabled ? "Enabled" : "Disabled"}</p>
        <p><strong>Support phone:</strong> {settings?.supportPhone || "—"}</p>
        <p><strong>Support email:</strong> {settings?.supportEmail || "—"}</p>
      </article>
    </section>
  );
}
