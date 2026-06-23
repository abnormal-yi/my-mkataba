import React, { useEffect } from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter, Routes, Route, Navigate, useNavigate } from 'react-router-dom'
import { AuthProvider, useAuth } from './context/AuthContext'
import { App } from '@capacitor/app'
import SplashPage from './pages/SplashPage'
import LoginPage from './pages/LoginPage'
import RiderDashboard from './pages/RiderDashboard'
import OwnerDashboard from './pages/OwnerDashboard'
import AdminDashboard from './pages/AdminDashboard'
import BlockedPage from './pages/BlockedPage'
import ContractFormPage from './pages/ContractFormPage'
import './index.css'

function BackButtonHandler() {
  const navigate = useNavigate()
  const { user } = useAuth()

  useEffect(() => {
    const handler = App.addListener('backButton', ({ canGoBack }) => {
      if (canGoBack) {
        navigate(-1)
      } else if (user) {
        const dashMap = { rider: '/rider', owner: '/owner', admin: '/admin' }
        navigate(dashMap[user.role] || '/')
      } else {
        App.exitApp()
      }
    })
    return () => { handler.then(h => h.remove()) }
  }, [navigate, user])

  return null
}

function AppRoutes() {
  const { user, loading } = useAuth()

  if (loading) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh', background: 'var(--bg)' }}>
        <div style={{ textAlign: 'center' }}>
          <div style={{ width: 48, height: 48, border: '4px solid var(--border)', borderTopColor: 'var(--purple)', borderRadius: '50%', animation: 'spin .8s linear infinite', margin: '0 auto 16px' }} />
          <p style={{ color: 'var(--muted)', fontSize: 14 }}>Loading...</p>
        </div>
        <style>{`@keyframes spin { to { transform: rotate(360deg) } }`}</style>
      </div>
    )
  }

  const dashMap = { rider: '/rider', owner: '/owner', admin: '/admin' }
  const isBlocked = ['blocked', 'disabled'].includes(String(user?.status || '').toLowerCase())

  return (
    <>
    <BackButtonHandler />
    <Routes>
      <Route path="/" element={!user ? <SplashPage /> : <Navigate to={dashMap[user.role] || '/login'} />} />
      <Route path="/login" element={!user ? <LoginPage /> : <Navigate to={dashMap[user.role] || '/rider'} />} />
      <Route path="/rider" element={user && !isBlocked && user.role === 'rider' ? <RiderDashboard /> : user ? <Navigate to={isBlocked ? '/blocked' : dashMap[user.role]} /> : <Navigate to="/login" />} />
      <Route path="/owner" element={user && user.role === 'owner' ? <OwnerDashboard /> : user ? <Navigate to={dashMap[user.role]} /> : <Navigate to="/login" />} />
      <Route path="/admin" element={user && user.role === 'admin' ? <AdminDashboard /> : user ? <Navigate to={dashMap[user.role]} /> : <Navigate to="/login" />} />
      <Route path="/blocked" element={user ? <BlockedPage /> : <Navigate to="/login" />} />
      <Route path="/new-contract" element={user ? <ContractFormPage /> : <Navigate to="/login" />} />
      <Route path="*" element={!user ? <SplashPage /> : <Navigate to={dashMap[user.role] || '/rider'} />} />
    </Routes>
    </>
  )
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <BrowserRouter>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </BrowserRouter>
  </React.StrictMode>
)
