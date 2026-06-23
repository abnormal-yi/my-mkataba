import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { LayoutDashboard, FileText, CreditCard, Bell, User, LogOut, Users, MapPin, Settings } from 'lucide-react'
import Logo from './Logo'

const roleConfig = {
  rider: {
    role: 'Rider Portal',
    tabs: [
      { key: 'overview', label: 'Overview', icon: LayoutDashboard },
      { key: 'contract', label: 'My Contract', icon: FileText },
      { key: 'payments', label: 'Payments', icon: CreditCard },
      { key: 'location', label: 'Location', icon: MapPin },
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
      { key: 'locations', label: 'Locations', icon: MapPin },
      { key: 'alerts', label: 'Alerts', icon: Bell },
    ]
  },
  admin: {
    role: 'Admin Panel',
    tabs: [
      { key: 'overview', label: 'Overview', icon: LayoutDashboard },
      { key: 'users', label: 'All Users', icon: Users },
      { key: 'contracts', label: 'Contracts', icon: FileText },
      { key: 'payments', label: 'Payments', icon: CreditCard },
      { key: 'reports', label: 'Reports', icon: MapPin },
      { key: 'settings', label: 'Settings', icon: Settings },
    ]
  }
}

export default function Layout({ children, activeTab, onTabChange, role, onLogout }) {
  const { user } = useAuth()
  const navigate = useNavigate()
  const config = roleConfig[role]

  const handleLogout = () => {
    onLogout()
    navigate('/')
  }

  return (
    <>
      <nav className="app-nav">
        <span className="brand" style={{ cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8 }} onClick={() => navigate('/')}>
          <Logo size={26} /> My <span>Mkataba</span>
        </span>
        <button className="nav-btn" onClick={handleLogout} style={{ marginLeft: 'auto', fontSize: 0, gap: 0 }}>
          <LogOut size={18} />
        </button>
      </nav>
      <div className="dashboard-layout">
        <main className="main-content">
          {children}
        </main>

        <nav className="mobile-bottom-nav">
          {config.tabs.map(tab => (
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
