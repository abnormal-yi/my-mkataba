import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { LayoutDashboard, FileText, CreditCard, Bell, User, Menu, X, LogOut, Users, MapPin, Settings } from 'lucide-react'

const roleConfig = {
  rider: {
    role: 'Rider Portal',
    tabs: [
      { key: 'overview', label: 'Overview', icon: LayoutDashboard },
      { key: 'contract', label: 'My Contract', icon: FileText },
      { key: 'payments', label: 'Payments', icon: CreditCard },
      { key: 'notifications', label: 'Notifications', icon: Bell },
      { key: 'profile', label: 'Profile', icon: User },
    ]
  },
  owner: {
    role: 'Owner Portal',
    tabs: [
      { key: 'overview', label: 'Dashboard', icon: LayoutDashboard },
      { key: 'riders', label: 'My Riders', icon: Users },
      { key: 'contracts', label: 'Contracts', icon: FileText },
      { key: 'payments', label: 'Payments', icon: CreditCard },
      { key: 'alerts', label: 'Alerts', icon: Bell },
    ]
  },
  admin: {
    role: 'Admin Panel',
    tabs: [
      { key: 'overview', label: 'Overview', icon: LayoutDashboard },
      { key: 'users', label: 'All Users', icon: Users },
      { key: 'contracts', label: 'Contracts', icon: FileText },
      { key: 'reports', label: 'Reports', icon: MapPin },
      { key: 'settings', label: 'Settings', icon: Settings },
    ]
  }
}

export default function Layout({ children, activeTab, onTabChange, role, onLogout }) {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const { user } = useAuth()
  const navigate = useNavigate()
  const config = roleConfig[role]
  const bottomNavTabs = config.tabs.slice(0, 5)

  const handleLogout = () => {
    onLogout()
    navigate('/')
  }

  return (
    <>
      <nav className="app-nav">
        <button className="hamburger-btn" onClick={() => setSidebarOpen(!sidebarOpen)}>
          {sidebarOpen ? <X size={24} /> : <Menu size={24} />}
        </button>
        <span className="brand">My <span>Mkataba</span></span>
        <button className="nav-btn" onClick={handleLogout} style={{ marginLeft: 'auto' }}>
          <LogOut size={14} style={{ marginRight: 4 }} /> Sign Out
        </button>
      </nav>
      <div className="dashboard-layout">
        <div className={`sidebar-overlay${sidebarOpen ? ' open' : ''}`} onClick={() => setSidebarOpen(false)} />
        <aside className={`sidebar${sidebarOpen ? ' open' : ''}`}>
          <div className="sidebar-brand" style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{ width: 36, height: 36, background: '#fff', borderRadius: 10, display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--purple-dark)', fontWeight: 800, fontSize: 16 }}>M</div>
            <div>
              <div className="s-name">My <span>Mkataba</span></div>
              <div className="s-role">{config.role}</div>
            </div>
          </div>
          <div className="sidebar-user">
            <div className="s-avatar">{user?.initials}</div>
            <div>
              <div className="s-uname">{user?.name}</div>
              <div className="s-email">{user?.email}</div>
            </div>
          </div>
          <ul className="sidebar-nav">
            {config.tabs.map(tab => (
              <li key={tab.key}>
                <a className={activeTab === tab.key ? 'active' : ''}
                   onClick={() => { onTabChange(tab.key); setSidebarOpen(false) }}>
                  <tab.icon size={18} />
                  {tab.label}
                </a>
              </li>
            ))}
            <li style={{ marginTop: 'auto', borderTop: '1px solid rgba(255,255,255,.12)', paddingTop: 8 }}>
              <a onClick={handleLogout}>
                <LogOut size={18} />
                Sign Out
              </a>
            </li>
          </ul>
        </aside>

        <main className="main-content">
          {children}
        </main>

        <nav className="mobile-bottom-nav">
          {bottomNavTabs.map(tab => (
            <button key={tab.key} className={`mob-nav-btn${activeTab === tab.key ? ' active' : ''}`}
                    onClick={() => onTabChange(tab.key)}>
              <tab.icon size={22} />
              {tab.label}
            </button>
          ))}
        </nav>
      </div>
    </>
  )
}
