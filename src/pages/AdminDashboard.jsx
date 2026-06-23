import { useState, useEffect } from 'react'
import { useAuth } from '../context/AuthContext'
import { getAllUsers, getAllContracts, getAllPayments, getAllNotifications, updateContractStatus, resetDatabase, deleteRider } from '../data/db'
import Layout from '../components/Layout'
import StatCard from '../components/StatCard'
import Badge from '../components/Badge'
import DataTable from '../components/DataTable'
import Toast from '../components/Toast'

export default function AdminDashboard() {
  const { user, logout } = useAuth()
  const [tab, setTab] = useState('overview')
  const [users, setUsers] = useState([])
  const [contracts, setContracts] = useState([])
  const [payments, setPayments] = useState([])
  const [notifications, setNotifications] = useState([])
  const [toast, setToast] = useState({ show: false, msg: '' })
  const [confirmDelete, setConfirmDelete] = useState(null)

  const loadData = async () => {
    if (!user) return
    const u = await getAllUsers()
    setUsers(u)
    const c = await getAllContracts()
    setContracts(c)
    const p = await getAllPayments()
    setPayments(p)
    const n = await getAllNotifications()
    setNotifications(n)
  }

  useEffect(() => { loadData() }, [user])

  const handleBlockUser = async (userId) => {
    setToast({ show: true, msg: `⛔ User ${userId} blocked` })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
  }

  const handleResolve = async (contractId) => {
    await updateContractStatus(contractId, 'completed')
    setToast({ show: true, msg: `✅ Contract #${contractId} resolved` })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    loadData()
  }

  const handleDeleteRider = async (userId) => {
    await deleteRider(userId)
    setConfirmDelete(null)
    setToast({ show: true, msg: `🗑️ Rider deleted permanently!` })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    loadData()
  }

  const usersByRole = role => users.filter(u => u.role === role).length
  const activeContracts = contracts.filter(c => c.status === 'active').length
  const totalCollected = payments.filter(p => p.status === 'confirmed' || p.status === 'completed').reduce((s, p) => s + p.amount, 0)
  const pendingPayments = payments.filter(p => p.status === 'pending').length

  const title = tab === 'overview' ? 'Admin Overview' :
    tab === 'users' ? 'All Users' :
    tab === 'contracts' ? 'All Contracts' :
    tab === 'reports' ? 'Reports' : 'Settings'

  const tabContent = () => {
    switch (tab) {
      case 'overview':
        return (
          <>
            <div className="page-title">{title}</div>
            <div className="page-sub">System-wide summary • {new Date().toLocaleDateString()}</div>
            <div className="stats-grid">
              <StatCard label="Total Users" value={users.length} color="purple" />
              <StatCard label="Riders" value={usersByRole('rider')} color="blue" />
              <StatCard label="Owners" value={usersByRole('owner')} color="green" />
              <StatCard label="Active Contracts" value={activeContracts} color="green" />
              <StatCard label="Total Collected" value={`TSh ${totalCollected.toLocaleString()}`} color="green" />
              <StatCard label="Pending Payments" value={pendingPayments} color="yellow" />
            </div>
            <div className="card">
              <div className="card-title">Recent Contracts</div>
              <DataTable
                columns={['#', 'Rider', 'Owner', 'Amount', 'Status']}
                rows={contracts.slice(0, 5).map(c => [
                  `#${c.contractId}`, c.riderName, c.ownerName,
                  `TSh ${c.totalAmount.toLocaleString()}`,
                  <Badge status={c.status} />
                ])}
              />
            </div>
          </>
        )

      case 'users':
        return (
          <>
            <div className="page-title">{title}</div>
            <div className="page-sub">Manage all platform users</div>
            <div className="card">
              <DataTable
                columns={['Name', 'Email', 'Phone', 'Role', 'Status', 'Action']}
                rows={users.map(u => [
                  u.name,
                  u.email || '—',
                  u.phone || '—',
                  <Badge status={u.role === 'admin' ? 'danger' : u.role === 'owner' ? 'purple' : 'green'} label={u.role} />,
                  <Badge status={u.status || 'active'} />,
                  <div style={{ display: 'flex', gap: 4 }}>
                    <button className="nav-btn" style={{ background: 'var(--red-bg)', color: 'var(--red)' }} onClick={() => handleBlockUser(u.id)}>Block</button>
                    {u.role === 'rider' && (
                      <button className="nav-btn" style={{ background: '#FEE2E2', color: '#DC2626' }}
                              onClick={() => setConfirmDelete(u)}>Delete</button>
                    )}
                  </div>
                ])}
              />
              {users.length === 0 && <p className="text-muted" style={{ textAlign: 'center', padding: 20 }}>No users.</p>}
            </div>
          </>
        )

      case 'contracts':
        return (
          <>
            <div className="page-title">{title}</div>
            <div className="page-sub">All contracts on the platform</div>
            <div className="card">
              <DataTable
                columns={['#', 'Rider', 'Owner', 'Motorcycle', 'Amount', 'Status', 'Action']}
                rows={contracts.map(c => [
                  `#${c.contractId}`, c.riderName, c.ownerName, c.motorcycle,
                  `TSh ${c.totalAmount.toLocaleString()}`,
                  <Badge status={c.status} />,
                  c.status !== 'completed' ? (
                    <button className="nav-btn" style={{ background: 'var(--green-bg)', color: 'var(--green)' }} onClick={() => handleResolve(c.contractId)}>Resolve</button>
                  ) : '—'
                ])}
              />
              {contracts.length === 0 && <p className="text-muted" style={{ textAlign: 'center', padding: 20 }}>No contracts.</p>}
            </div>
          </>
        )

      case 'reports':
        return (
          <>
            <div className="page-title">{title}</div>
            <div className="page-sub">Platform analytics and summaries</div>
            <div className="stats-grid">
              <StatCard label="Total Revenue" value={`TSh ${totalCollected.toLocaleString()}`} color="green" />
              <StatCard label="Active Users" value={users.filter(u => u.status !== 'blocked').length} color="purple" />
              <StatCard label="Avg Contract Value" value={`TSh ${contracts.length ? Math.round(contracts.reduce((s, c) => s + c.totalAmount, 0) / contracts.length).toLocaleString() : 0}`} color="blue" />
              <StatCard label="Blocked Users" value={users.filter(u => u.status === 'blocked').length} color="red" />
            </div>
            <div className="card">
              <div className="card-title">Payment Summary</div>
              <DataTable
                columns={['Metric', 'Value']}
                rows={[
                  ['Total Confirmed Payments', `TSh ${totalCollected.toLocaleString()}`],
                  ['Pending Approvals', pendingPayments.toString()],
                  ['Total Transactions', payments.length.toString()],
                  ['Contracts Active', activeContracts.toString()],
                  ['Contracts Completed', contracts.filter(c => c.status === 'completed').length.toString()],
                ]}
              />
            </div>
            <div className="card">
              <div className="card-title">Export Data</div>
              <p className="text-muted" style={{ marginBottom: 16 }}>Download platform data for external analysis.</p>
              <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap' }}>
                <button className="btn-primary" onClick={() => { setToast({ show: true, msg: '📊 Users CSV exported!' }); setTimeout(() => setToast({ show: false, msg: '' }), 3000) }}>📄 Export Users</button>
                <button className="btn-primary" style={{ background: 'var(--green)' }} onClick={() => { setToast({ show: true, msg: '📊 Contracts CSV exported!' }); setTimeout(() => setToast({ show: false, msg: '' }), 3000) }}>📄 Export Contracts</button>
                <button className="btn-primary" style={{ background: 'var(--purple)' }} onClick={() => { setToast({ show: true, msg: '📊 Payments CSV exported!' }); setTimeout(() => setToast({ show: false, msg: '' }), 3000) }}>📄 Export Payments</button>
              </div>
            </div>
          </>
        )

      case 'settings':
        return (
          <>
            <div className="page-title">{title}</div>
            <div className="page-sub">System configuration</div>
            <div className="card" style={{ maxWidth: 500 }}>
              <div className="card-title">Platform Settings</div>
              <label>Default Daily Rate (TSh)</label>
              <input type="number" defaultValue={1500} />
              <label>Default Contract Duration (days)</label>
              <input type="number" defaultValue={90} />
              <label>Late Payment Grace Period (days)</label>
              <input type="number" defaultValue={3} />
              <label>Notification Reminder Interval (hours)</label>
              <input type="number" defaultValue={24} />
              <div style={{ display: 'flex', gap: 12, marginTop: 8 }}>
                <button className="btn-primary" onClick={() => { setToast({ show: true, msg: '⚙️ Settings saved!' }); setTimeout(() => setToast({ show: false, msg: '' }), 3000) }}>Save Settings</button>
                <button className="btn-primary" style={{ background: 'var(--red)' }} onClick={async () => {
                  await resetDatabase()
                  setToast({ show: true, msg: '🔄 Database reset to defaults!' })
                  setTimeout(() => setToast({ show: false, msg: '' }), 3000)
                  loadData()
                }}>Reset Database</button>
              </div>
            </div>
          </>
        )

      default:
        return null
    }
  }

  return (
    <Layout role="admin" activeTab={tab} onTabChange={setTab} onLogout={logout}>
      {tabContent()}
      <Toast visible={toast.show} message={toast.msg} />
      {confirmDelete && (
        <div className="modal-overlay" onClick={() => setConfirmDelete(null)}>
          <div className="modal-card" onClick={e => e.stopPropagation()} style={{ maxWidth: 380 }}>
            <div className="modal-icon">⚠️</div>
            <div className="modal-title">Delete Rider?</div>
            <div className="modal-body">
              <p style={{ marginBottom: 16 }}>
                Una uhakika unataka kumfuta <strong>{confirmDelete.name}</strong>?
                Hatua hii itafuta rider, mkataba wake, malipo yote, na data zake.
                Haiwezi kutenduliwa.
              </p>
              <div style={{ display: 'flex', gap: 12 }}>
                <button className="btn-primary" style={{ background: 'var(--red)', flex: 1 }}
                        onClick={() => handleDeleteRider(confirmDelete.id)}>
                  🗑️ Delete
                </button>
                <button className="btn-primary" style={{ background: 'transparent', color: 'var(--muted)', boxShadow: 'none', flex: 1 }}
                        onClick={() => setConfirmDelete(null)}>
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </Layout>
  )
}
