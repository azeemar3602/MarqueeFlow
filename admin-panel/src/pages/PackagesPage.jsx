import { useEffect, useState } from "react";
import { api } from "../lib/api.js";

export default function PackagesPage() {
  const [rows, setRows] = useState([]);

  useEffect(() => {
    api.packages().then((d) => setRows(d.packages || [])).catch(() => {});
  }, []);

  return (
    <section>
      <header className="page-header"><h1>Packages</h1></header>
      <div className="grid">
        {rows.map((p) => (
          <article className="card" key={p.id}>
            <h2>{p.name}</h2>
            <p>PKR {p.price}</p>
            <p className="muted">{p.status}</p>
          </article>
        ))}
      </div>
    </section>
  );
}
