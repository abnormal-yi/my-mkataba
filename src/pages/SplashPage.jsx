import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import Logo from '../components/Logo'

export default function SplashPage() {
  const { setRole } = useAuth()
  const navigate = useNavigate()

  const handleRoleSelect = (role) => {
    setRole(role)
    navigate('/login')
  }

  return (
    <div id="screen-splash" className="screen active">
      <nav className="app-nav">
        <span className="brand" style={{ display: 'flex', alignItems: 'center', gap: 8 }}><Logo size={26} /> My <span>Mkataba</span></span>
      </nav>
      <div style={{ paddingTop: 'var(--nav-h)' }}>
        <div style={{
          background: 'linear-gradient(145deg, #4C1D95 0%, #6C3FC5 50%, #8B5CF6 100%)',
          display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
          textAlign: 'center', color: '#fff', padding: '60px 24px', minHeight: 'calc(100vh - var(--nav-h))'
        }}>
          <div className="splash-logo">
            <Logo size={100} />
          </div>
          <h1 className="splash-title">My <span>Mkataba</span></h1>
          <p className="splash-sub">Boda Boda Contracts &amp; Payments</p>
          <p style={{ color: '#C4B5FD', fontSize: 14, maxWidth: 420, lineHeight: 1.6, marginBottom: 32 }}>
            Digital contract management for Boda Boda owners &amp; riders across Tanzania. Fair, transparent, and always up-to-date.
          </p>
          <div className="splash-roles">
            <div className="role-card" onClick={() => handleRoleSelect('rider')}>
              <div className="icon">🏍️</div>
              <div className="label">Rider</div>
              <div className="desc">View contracts &amp; payments</div>
            </div>
            <div className="role-card" onClick={() => handleRoleSelect('owner')}>
              <div className="icon">👤</div>
              <div className="label">Boda Owner</div>
              <div className="desc">Manage riders &amp; contracts</div>
            </div>
            <div className="role-card" onClick={() => handleRoleSelect('admin')}>
              <div className="icon">⚙️</div>
              <div className="label">Admin</div>
              <div className="desc">System-wide oversight</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
