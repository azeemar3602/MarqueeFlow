import { useEffect, useState } from "react";
import { api } from "../lib/api.js";
import { Badge, EmptyState, PageHeader } from "../components/PageHeader.jsx";

export default function PackagesPage() {
  const [rows, setRows] = useState([]);

  useEffect(() => {
    api.packages().then((d) => setRows(d.packages || [])).catch(() => {});
  }, []);

  return (
    <section>
      <PageHeader
        title="Packages"
        subtitle="Event packages and pricing."
      />
      {rows.length ? (
        <div className="grid">
          {rows.map((p) => (
            <article className="card panel-card" key={p.id}>
              <h2>{p.name}</h2>
              <p>PKR {p.price}</p>
              <Badge>{p.status}</Badge>
            </article>
          ))}
        </div>
      ) : (
        <EmptyState message="No packages configured." />
      )}
    </section>
  );
}
