import { useEffect, useState } from "react";
import { api } from "../lib/api.js";
import { EmptyState, PageHeader } from "../components/PageHeader.jsx";

export default function CalendarPage() {
  const [month, setMonth] = useState(new Date().toISOString().slice(0, 7));
  const [days, setDays] = useState([]);
  const [selected, setSelected] = useState("");
  const [slots, setSlots] = useState([]);

  useEffect(() => {
    api.calendarMonth(month).then((d) => setDays(d.days || [])).catch(() => {});
  }, [month]);

  useEffect(() => {
    if (!selected) return;
    api.calendarDay(selected).then((d) => setSlots(d.slots || [])).catch(() => {});
  }, [selected]);

  return (
    <section>
      <PageHeader
        title="Calendar & Slots"
        subtitle="Month overview and daily slot capacity."
      >
        <input type="month" value={month} onChange={(e) => setMonth(e.target.value)} />
      </PageHeader>
      <div className="grid">
        <article className="card panel-card">
          <h2>Month days</h2>
          <div className="chip-row">
            {days.map((d) => (
              <button key={d.date} type="button" className={`chip ${selected === d.date ? "active" : ""}`} onClick={() => setSelected(d.date)}>
                {d.date.slice(-2)}
              </button>
            ))}
          </div>
        </article>
        <article className="card panel-card">
          <h2>Slots {selected ? `for ${selected}` : ""}</h2>
          {slots.length ? (
            <ul className="list">
              {slots.map((s) => (
                <li key={s.id}>{s.slotName} · {s.startTime}-{s.endTime} · {s.bookedCount}/{s.capacity}</li>
              ))}
            </ul>
          ) : (
            <EmptyState message={selected ? "No slots for this date." : "Select a date to view slots."} />
          )}
        </article>
      </div>
    </section>
  );
}
