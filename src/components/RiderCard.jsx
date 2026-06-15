import Badge from './Badge'
import ProgressBar from './ProgressBar'

export default function RiderCard({ rider }) {
  return (
    <div className="rider-card">
      <div className="rider-header">
        <div className="rider-avatar" style={rider.avatarBg ? { background: rider.avatarBg } : {}}>
          {rider.initials}
        </div>
        <div>
          <div className="rider-name">{rider.name}</div>
          <div className="rider-meta">Contract #{rider.contract} · {rider.type}</div>
        </div>
        <Badge status={rider.status === 'Active' ? 'active' : rider.status === 'Overdue' ? 'overdue' : 'pending'} style={{ marginLeft: 'auto' }} />
      </div>
      <ProgressBar value={rider.progress} color={rider.status === 'Overdue' ? 'red' : rider.status === 'Pending' ? 'yellow' : 'green'} />
      <div className="rider-stats">
        <div className="rs-item">
          <div className="rs-label">Paid</div>
          <div className="rs-value text-green">TSh {rider.paid/1000}K</div>
        </div>
        <div className="rs-item">
          <div className="rs-label">Balance</div>
          <div className="rs-value text-red">TSh {rider.balance/1000}K</div>
        </div>
        <div className="rs-item">
          <div className="rs-label">Days Left</div>
          <div className="rs-value">{rider.daysLeft}</div>
        </div>
        <div className="rs-item">
          <div className="rs-label">Missed</div>
          <div className="rs-value text-red">{rider.missed}</div>
        </div>
      </div>
    </div>
  )
}
