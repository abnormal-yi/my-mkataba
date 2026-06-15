import { createContext, useContext, useState, useEffect } from 'react'
import { getUserByEmail, seedDatabase } from '../data/db'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [currentRole, setCurrentRole] = useState('rider')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    seedDatabase().then(() => setLoading(false))
  }, [])

  const login = async (email, password) => {
    const userData = await getUserByEmail(email)
    if (userData && (!password || password === '1234')) {
      setUser(userData)
      setCurrentRole(userData.role)
      return { success: true }
    }
    if (!userData) {
      const users = {
        rider: { email: 'john@mkataba.tz', name: 'John Msumi' },
        owner: { email: 'hassan@mkataba.tz', name: 'Hassan Mwangi' },
        admin: { email: 'admin@mkataba.tz', name: 'Super Creator' },
      }
      const u = users[currentRole]
      if (u) {
        const userData = await getUserByEmail(u.email)
        if (userData) {
          setUser(userData)
          setCurrentRole(userData.role)
          return { success: true }
        }
      }
    }
    return { success: false, error: 'Invalid email or password' }
  }

  const setRole = (role) => {
    setCurrentRole(role)
  }

  const logout = () => {
    setUser(null)
    setCurrentRole('rider')
  }

  return (
    <AuthContext.Provider value={{ user, currentRole, login, setRole, logout, loading }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
