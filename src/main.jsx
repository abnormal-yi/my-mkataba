import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider, useAuth } from './context/AuthContext'
import SplashPage from './pages/SplashPage'
import LoginPage from './pages/LoginPage'
import RiderDashboard from './pages/RiderDashboard'
import OwnerDashboard from './pages/OwnerDashboard'
import AdminDashboard from './pages/AdminDashboard'
import BlockedPage from './pages/BlockedPage'
import ContractFormPage from './pages/ContractFormPage'
import './index.css'

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

  return (
    <Routes>
      <Route path="/" element={!user ? <SplashPage /> : <Navigate to={dashMap[user.role] || '/login'} />} />
      <Route path="/login" element={!user ? <LoginPage /> : <Navigate to={dashMap[user.role] || '/rider'} />} />
      <Route path="/rider" element={user ? <RiderDashboard /> : <Navigate to="/login" />} />
      <Route path="/owner" element={user ? <OwnerDashboard /> : <Navigate to="/login" />} />
      <Route path="/admin" element={user ? <AdminDashboard /> : <Navigate to="/login" />} />
      <Route path="/blocked" element={user ? <BlockedPage /> : <Navigate to="/login" />} />
      <Route path="/new-contract" element={user ? <ContractFormPage /> : <Navigate to="/login" />} />
      <Route path="*" element={!user ? <SplashPage /> : <Navigate to={dashMap[user.role] || '/rider'} />} />
    </Routes>
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
