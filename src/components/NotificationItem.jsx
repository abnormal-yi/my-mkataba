const icons = {
  missed: { icon: '⚠️', cls: 'red' },
  paid: { icon: '✅', cls: 'green' },
  reminder: { icon: '🔔', cls: 'yellow' },
  expiry: { icon: '📅', cls: 'yellow' },
  danger: { icon: '🚨', cls: 'red' },
  warning: { icon: '⏰', cls: 'yellow' },
  payment: { icon: '💳', cls: 'yellow' },
}

export default function NotificationItem({ item, action }) {
  const ico = icons[item.type] || { icon: '🔔', cls: 'yellow' }
  return (
    <li className="notif-item">
      <div className={`notif-icon ${ico.cls}`}>{ico.icon}</div>
      <div style={{ flex: 1 }}>
        <div className="notif-title">{item.title}</div>
        <div className="notif-desc">{item.desc}</div>
        <div className="notif-time">{item.time}</div>
      </div>
      {action && (
        <button className={action === 'Block' ? 'btn-danger' : action === 'Renew' ? 'btn-success' : 'btn-outline'} style={{ flexShrink: 0 }}>
          {action}
        </button>
      )}
    </li>
  )
}
