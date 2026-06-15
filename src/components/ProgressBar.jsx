export default function ProgressBar({ value, color = 'green' }) {
  return (
    <div className="progress-bar">
      <div className={`progress-fill progress-${color}`} style={{ width: `${value}%` }} />
    </div>
  )
}
