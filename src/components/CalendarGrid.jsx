export default function CalendarGrid({ status }) {
  const startDay = 1
  const days = 30
  const today = 12
  const cells = []

  for (let i = 0; i < startDay; i++) {
    cells.push(<div key={`empty-${i}`} className="cal-day empty" />)
  }
  for (let d = 1; d <= days; d++) {
    const cls = status ? (status[d] || 'empty') : 'empty'
    const isToday = d === today
    cells.push(
      <div key={d} className={`cal-day ${cls}${isToday ? ' today' : ''}`}>
        {d}
      </div>
    )
  }

  return (
    <div>
      <div className="cal-header">
        <span>Su</span><span>Mo</span><span>Tu</span><span>We</span><span>Th</span><span>Fr</span><span>Sa</span>
      </div>
      <div className="cal-grid">{cells}</div>
      <div className="flex-gap" style={{ marginTop: 14, flexWrap: 'wrap', gap: 12 }}>
        <span style={{ fontSize: 12 }}><span className="badge badge-green">■</span> Paid</span>
        <span style={{ fontSize: 12 }}><span style={{ color: 'var(--red)', fontWeight: 700 }}>■</span> Missed</span>
        <span style={{ fontSize: 12 }}><span style={{ color: 'var(--yellow)', fontWeight: 700 }}>■</span> Pending</span>
      </div>
    </div>
  )
}
