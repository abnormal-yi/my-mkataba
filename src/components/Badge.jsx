const variants = {
  paid: 'badge-green',
  active: 'badge-green',
  missed: 'badge-red',
  overdue: 'badge-red',
  blocked: 'badge-red',
  disabled: 'badge-red',
  partial: 'badge-yellow',
  archived: 'badge-purple',
  inactive: 'badge-purple',
  danger: 'badge-red',
  pending: 'badge-yellow',
  expiring: 'badge-yellow',
  expired: 'badge-red',
  green: 'badge-green',
  red: 'badge-red',
  yellow: 'badge-yellow',
  purple: 'badge-purple',
}

const labels = {
  paid: 'Paid',
  missed: 'Missed',
  pending: 'Pending',
  active: 'Active',
  overdue: 'Overdue',
  blocked: 'Blocked',
  disabled: 'Disabled',
  partial: 'Partial',
  archived: 'Archived',
  inactive: 'Inactive',
  expiring: 'Expiring',
  expired: 'Expired',
}

export default function Badge({ status, children }) {
  const cls = variants[status] || 'badge-purple'
  const text = children || labels[status] || status
  return <span className={`badge ${cls}`}>{text}</span>
}
