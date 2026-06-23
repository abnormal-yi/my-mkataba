import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { createUser } from '../data/db'
import Logo from '../components/Logo'

export default function LoginPage() {
  const { currentRole, login, setRole } = useAuth()
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [showSignup, setShowSignup] = useState(false)
  const [signupForm, setSignupForm] = useState({ name: '', phone: '', email: '', region: 'Arusha' })
  const [signupMsg, setSignupMsg] = useState('')

  const labels = { rider: 'Rider Login', owner: 'Boda Owner Login', admin: 'Admin Login' }
  const dashboards = { rider: '/rider', owner: '/owner', admin: '/admin' }
  const placeholders = {
    rider: 'john@mkataba.tz',
    owner: 'alinda@mkataba.tz',
    admin: 'admin@mkataba.tz',
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    const result = await login(email.trim(), password)
    setLoading(false)
    if (result.success) {
      navigate(dashboards[currentRole])
    } else {
      setError(result.error || 'Login failed. Try again.')
    }
  }

  const handleOwnerSignup = async (e) => {
    e.preventDefault()
    setSignupMsg('')
    if (!signupForm.name || !signupForm.phone) {
      setSignupMsg('Name and phone are required.')
      return
    }
    try {
      const result = await createUser({
        name: signupForm.name,
        phone: signupForm.phone,
        email: signupForm.email,
        role: 'owner',
        region: signupForm.region,
      })
      setSignupMsg(`Account created! Email: ${result.email} | Password: ${result.defaultPwd}`)
      setTimeout(() => {
        setShowSignup(false)
        setSignupMsg('')
        setEmail(result.email)
        setSignupForm({ name: '', phone: '', email: '', region: 'Arusha' })
      }, 3000)
    } catch (err) {
      setSignupMsg(err.message || 'Could not create account.')
    }
  }

  return (
    <div className="login-screen">
      <div className="login-box">
        <div className="logo-mini" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10 }}>
          <Logo size={42} />
          <div className="name">My <span>Mkataba</span></div>
        </div>
        <div className="role-badge">{labels[currentRole]}</div>
        <h2>{showSignup ? 'Create Owner Account' : 'Welcome back'}</h2>
        <p>{showSignup ? 'Register as a Boda Owner to manage your riders' : 'Sign in to your My Mkataba account'}</p>

        {!showSignup ? (
          <form onSubmit={handleSubmit}>
            <label>Email or Username</label>
            <input type="text" value={email} onChange={e => setEmail(e.target.value)}
                   placeholder={placeholders[currentRole]} required />
            <label>Password</label>
            <input type="password" value={password} onChange={e => setPassword(e.target.value)}
                   placeholder="Enter your password" />
            {error && <p style={{ color: 'var(--red)', fontSize: 13, marginBottom: 12 }}>{error}</p>}
            <button className="btn-primary" type="submit" disabled={loading}>
              {loading ? 'Signing in...' : 'Sign In'}
            </button>
            {currentRole === 'owner' && (
              <p style={{ textAlign: 'center', marginTop: 14, fontSize: 13, color: 'var(--muted)' }}>
                Don't have an account?{' '}
                <a href="#" onClick={e => { e.preventDefault(); setShowSignup(true) }}
                   style={{ color: 'var(--purple)', fontWeight: 600 }}>Register as Owner</a>
              </p>
            )}
          </form>
        ) : (
          <form onSubmit={handleOwnerSignup}>
            <label>Full Name *</label>
            <input type="text" value={signupForm.name} onChange={e => setSignupForm({ ...signupForm, name: e.target.value })}
                   placeholder="e.g. Juma Bakari" required />
            <label>Phone Number *</label>
            <input type="text" value={signupForm.phone} onChange={e => setSignupForm({ ...signupForm, phone: e.target.value })}
                   placeholder="+255 7XX XXX XXX" required />
            <label>Email</label>
            <input type="email" value={signupForm.email} onChange={e => setSignupForm({ ...signupForm, email: e.target.value })}
                   placeholder="juma@mkataba.tz (auto-generated if empty)" />
            <label>Region</label>
            <select value={signupForm.region} onChange={e => setSignupForm({ ...signupForm, region: e.target.value })}>
              <option>Arusha</option>
              <option>Dar es Salaam</option>
              <option>Moshi</option>
              <option>Mwanza</option>
              <option>Dodoma</option>
              <option>Mbeya</option>
              <option>Zanzibar</option>
            </select>
            {signupMsg && (
              <p style={{ color: signupMsg.includes('created') ? 'var(--green)' : 'var(--red)',
                         fontSize: 13, marginBottom: 12, background: signupMsg.includes('created') ? 'var(--green-bg)' : 'var(--red-bg)',
                         padding: 10, borderRadius: 8 }}>{signupMsg}</p>
            )}
            <button className="btn-primary" type="submit" style={{ background: 'var(--green)' }}>
              Create Account
            </button>
            <p style={{ textAlign: 'center', marginTop: 14, fontSize: 13, color: 'var(--muted)' }}>
              Already have an account?{' '}
              <a href="#" onClick={e => { e.preventDefault(); setShowSignup(false); setSignupMsg('') }}
                 style={{ color: 'var(--purple)', fontWeight: 600 }}>Sign In</a>
            </p>
          </form>
        )}

        {!showSignup && (
          <>
            <p style={{ textAlign: 'center', marginTop: 14, fontSize: 12, color: 'var(--muted)' }}>
              Forgot password? <a href="#" style={{ color: 'var(--purple)', fontWeight: 600 }}>Reset here</a>
            </p>
            <p style={{ textAlign: 'center', marginTop: 8, fontSize: 11, color: 'var(--muted)' }}>
              Demo accounts must use registered email and password.
            </p>
          </>
        )}
      </div>
    </div>
  )
}
