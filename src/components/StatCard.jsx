export default function StatCard({ label, value, note, color = '' }) {
  return (
    <div className={`stat-card${color ? ' ' + color : ''}`}>
      <div className="stat-label">{label}</div>
      <div className="stat-value">{value}</div>
      {note && <div className="stat-note">{note}</div>}
    </div>
  )
}
