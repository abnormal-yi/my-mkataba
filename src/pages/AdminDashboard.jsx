import { useState, useEffect } from 'react'
import { useAuth } from '../context/AuthContext'
import { getAllUsers, getAllContracts, getAllPayments, getAllNotifications, updateContractStatus, resetDatabase, deleteRider, getPaymentsForRider, blockRider, unblockRider, isPaidStatus } from '../data/db'
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
  const [selectedRider, setSelectedRider] = useState(null)
  const [selectedRiderPayments, setSelectedRiderPayments] = useState([])

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

  useEffect(() => {
    if (!selectedRider) {
      setSelectedRiderPayments([])
      return
    }
    getPaymentsForRider(selectedRider.id).then(setSelectedRiderPayments)
  }, [selectedRider])

  const handleBlockUser = async (userId) => {
    await blockRider(userId)
    setToast({ show: true, msg: `User blocked` })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    loadData()
  }

  const handleUnblockUser = async (userId) => {
    await unblockRider(userId)
    setToast({ show: true, msg: `User active again` })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    loadData()
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
    setToast({ show: true, msg: `Rider disabled. History has been kept.` })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    loadData()
  }

  const usersByRole = role => users.filter(u => u.role === role).length
  const activeContracts = contracts.filter(c => String(c.status).toLowerCase() === 'active').length
  const totalCollected = payments.filter(p => isPaidStatus(p.status)).reduce((s, p) => s + p.amount, 0)
  const pendingPayments = payments.filter(p => p.status === 'pending').length

  const title = tab === 'overview' ? 'Admin Overview' :
    tab === 'users' ? 'All Users' :
    tab === 'contracts' ? 'All Contracts' :
    tab === 'payments' ? 'Rider Payments' :
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
                    {String(u.status || '').toLowerCase() === 'blocked' || String(u.status || '').toLowerCase() === 'disabled' ? (
                      <button className="action-btn action-success" onClick={() => handleUnblockUser(u.id)}>Unblock</button>
                    ) : (
                      <button className="action-btn action-warning" onClick={() => handleBlockUser(u.id)}>Block</button>
                    )}
                    {u.role === 'rider' && (
                      <button className="action-btn action-danger"
                              onClick={() => setConfirmDelete(u)}>Disable</button>
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
                  String(c.status).toLowerCase() !== 'completed' ? (
                    <button className="action-btn action-success" onClick={() => handleResolve(c.contractId)}>Resolve</button>
                  ) : '—'
                ])}
              />
              {contracts.length === 0 && <p className="text-muted" style={{ textAlign: 'center', padding: 20 }}>No contracts.</p>}
            </div>
          </>
        )

      case 'payments': {
        const riderList = users.filter(u => u.role === 'rider')
        const currentRider = selectedRider || riderList[0] || null
        const riderContract = currentRider ? contracts.find(c => c.riderId === currentRider.id) : null
        const totalPaid = selectedRiderPayments
          .filter(p => isPaidStatus(p.status))
          .reduce((s, p) => s + p.amount, 0)

        return (
          <>
            <div className="page-title">Rider Payments</div>
            <div className="page-sub">View payment history per rider</div>

            <div className="card" style={{ marginBottom: 16 }}>
              <label>Select Rider</label>
              <select value={currentRider?.id || ''} onChange={e => {
                const r = users.find(u => u.id === Number(e.target.value))
                setSelectedRider(r || null)
              }}>
                {riderList.map(r => (
                  <option key={r.id} value={r.id}>{r.name} — {r.email}</option>
                ))}
              </select>
            </div>

            {currentRider && (
              <>
                <div className="card" style={{ marginBottom: 16 }}>
                  <div className="card-title">{currentRider.name}</div>
                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
                    <div><p className="text-muted" style={{ fontSize: 12 }}>Email</p><p className="fw700">{currentRider.email}</p></div>
                    <div><p className="text-muted" style={{ fontSize: 12 }}>Phone</p><p className="fw700">{currentRider.phone || '—'}</p></div>
                    <div><p className="text-muted" style={{ fontSize: 12 }}>Status</p><p><Badge status={currentRider.status} /></p></div>
                    <div><p className="text-muted" style={{ fontSize: 12 }}>Contract</p><p className="fw700">{riderContract?.contractId || '—'}</p></div>
                    <div><p className="text-muted" style={{ fontSize: 12 }}>Total Paid</p><p className="fw700" style={{ color: 'var(--green)' }}>TSh {totalPaid.toLocaleString()}</p></div>
                    <div><p className="text-muted" style={{ fontSize: 12 }}>Balance</p><p className="fw700" style={{ color: 'var(--red)' }}>
                      {riderContract ? `TSh ${(riderContract.totalAmount - totalPaid).toLocaleString()}` : '—'}
                    </p></div>
                  </div>
                </div>

                <div className="card">
                  <div className="card-title">Payment History</div>
                  <DataTable
                    columns={['Date', 'Amount', 'Method', 'Status']}
                    rows={selectedRiderPayments.map(p => [
                      p.date,
                      `TSh ${p.amount.toLocaleString()}`,
                      p.method || '—',
                      <Badge status={p.status} />
                    ])}
                  />
                  {selectedRiderPayments.length === 0 && (
                    <p className="text-muted" style={{ textAlign: 'center', padding: 20 }}>No payments found for this rider.</p>
                  )}
                </div>
              </>
            )}
          </>
        )
      }

      case 'reports':
        return (
          <>
            <div className="page-title">{title}</div>
            <div className="page-sub">Platform analytics and summaries</div>
            <div className="stats-grid">
              <StatCard label="Total Revenue" value={`TSh ${totalCollected.toLocaleString()}`} color="green" />
              <StatCard label="Active Users" value={users.filter(u => !['blocked', 'disabled'].includes(String(u.status || '').toLowerCase())).length} color="purple" />
              <StatCard label="Avg Contract Value" value={`TSh ${contracts.length ? Math.round(contracts.reduce((s, c) => s + c.totalAmount, 0) / contracts.length).toLocaleString() : 0}`} color="blue" />
              <StatCard label="Blocked Users" value={users.filter(u => ['blocked', 'disabled'].includes(String(u.status || '').toLowerCase())).length} color="red" />
            </div>
            <div className="card">
              <div className="card-title">Payment Summary</div>
              <DataTable
                columns={['Metric', 'Value']}
                rows={[
                  ['Total Paid Amount', `TSh ${totalCollected.toLocaleString()}`],
                  ['Pending Approvals', pendingPayments.toString()],
                  ['Total Transactions', payments.length.toString()],
                  ['Contracts Active', activeContracts.toString()],
                  ['Contracts Completed', contracts.filter(c => String(c.status).toLowerCase() === 'completed').length.toString()],
                ]}
              />
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
            <div className="modal-title">Disable Rider?</div>
            <div className="modal-body">
              <p style={{ marginBottom: 16 }}>
                Are you sure you want to remove <strong>{confirmDelete.name}</strong> from access?
                Details, contracts, payments, and location history will remain in the system.
              </p>
              <div style={{ display: 'flex', gap: 12 }}>
                <button className="btn-primary" style={{ background: 'var(--red)', flex: 1 }}
                        onClick={() => handleDeleteRider(confirmDelete.id)}>
                  Disable
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
