export function PageHeader({ eyebrow = "MARQUEEFLOW", title, subtitle, children }) {
  return (
    <header className="page-header">
      <p className="eyebrow page-eyebrow">{eyebrow}</p>
      <h1>{title}</h1>
      {subtitle ? <p className="muted">{subtitle}</p> : null}
      {children}
    </header>
  );
}

export function EmptyState({ message = "No records found." }) {
  return (
    <article className="card panel-card empty-state">
      <p className="muted">{message}</p>
    </article>
  );
}

export function Badge({ children }) {
  return <span className="badge">{children}</span>;
}
