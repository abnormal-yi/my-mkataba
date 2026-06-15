import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export default function LoginPage() {
  const { currentRole, login } = useAuth()
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const labels = { rider: 'Rider Login', owner: 'Boda Owner Login', admin: 'Admin Login' }
  const dashboards = { rider: '/rider', owner: '/owner', admin: '/admin' }
  const placeholders = {
    rider: 'john@mkataba.tz',
    owner: 'hassan@mkataba.tz',
    admin: 'admin@mkataba.tz',
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    const result = await login(email || placeholders[currentRole], password)
    setLoading(false)
    if (result.success) {
      navigate(dashboards[currentRole])
    } else {
      setError(result.error || 'Login failed. Try again.')
    }
  }

  return (
    <div className="login-screen">
      <div className="login-box">
        <div className="logo-mini">
          <div className="logo-mini-icon">M</div>
          <div className="name">My <span>Mkataba</span></div>
        </div>
        <div className="role-badge">{labels[currentRole]}</div>
        <h2>Welcome back</h2>
        <p>Sign in to your My Mkataba account</p>
        <form onSubmit={handleSubmit}>
          <label>Email or Username</label>
          <input type="text" value={email} onChange={e => setEmail(e.target.value)}
                 placeholder={placeholders[currentRole]} />
          <label>Password</label>
          <input type="password" value={password} onChange={e => setPassword(e.target.value)}
                 placeholder="Enter your password" />
          {error && <p style={{ color: 'var(--red)', fontSize: 13, marginBottom: 12 }}>{error}</p>}
          <button className="btn-primary" type="submit" disabled={loading}>
            {loading ? 'Signing in...' : 'Sign In'}
          </button>
        </form>
        <p style={{ textAlign: 'center', marginTop: 14, fontSize: 12, color: 'var(--muted)' }}>
          Forgot password? <a href="#" style={{ color: 'var(--purple)', fontWeight: 600 }}>Reset here</a>
        </p>
        <p style={{ textAlign: 'center', marginTop: 8, fontSize: 11, color: 'var(--muted)' }}>
          Demo: password is "1234" for all users
        </p>
      </div>
    </div>
  )
}
