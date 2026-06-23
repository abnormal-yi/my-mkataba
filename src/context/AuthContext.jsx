import { createContext, useContext, useState, useEffect } from 'react'
import { getUserByEmail, refreshExistingDemoData, seedDatabase } from '../data/db'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [currentRole, setCurrentRole] = useState('rider')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    seedDatabase()
      .then(refreshExistingDemoData)
      .then(() => setLoading(false))
  }, [])

  const login = async (email, password) => {
    const userData = await getUserByEmail(email)
    if (userData) {
      const status = String(userData.status || '').toLowerCase()
      if (status === 'blocked' || status === 'disabled') {
        return { success: false, error: 'Account is disabled. Contact owner/admin.' }
      }
      if (userData.password === password) {
        setUser(userData)
        setCurrentRole(userData.role)
        return { success: true }
      }
      return { success: false, error: 'Invalid email or password' }
    }
    return { success: false, error: 'Invalid email or password' }
  }

  const setRole = (role) => {
    setCurrentRole(role)
  }

  const updateUser = (updates) => {
    setUser(prev => prev ? { ...prev, ...updates } : null)
  }

  const logout = () => {
    setUser(null)
    setCurrentRole('rider')
  }

  return (
    <AuthContext.Provider value={{ user, currentRole, login, setRole, logout, loading, updateUser }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
