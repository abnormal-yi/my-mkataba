import { useState, useEffect } from 'react'
import { useAuth } from '../context/AuthContext'
import { getContractsForOwner, getPaymentsForOwner, getNotificationsForUser, createContract, createUser, getUserById, getRidersForOwner, blockRider, ownerConfirmContract } from '../data/db'
import Layout from '../components/Layout'
import StatCard from '../components/StatCard'
import Badge from '../components/Badge'
import ProgressBar from '../components/ProgressBar'
import DataTable from '../components/DataTable'
import NotificationItem from '../components/NotificationItem'
import Toast from '../components/Toast'

export default function OwnerDashboard() {
  const { user, logout } = useAuth()
  const [tab, setTab] = useState('overview')
  const [contracts, setContracts] = useState([])
  const [payments, setPayments] = useState([])
  const [notifications, setNotifications] = useState([])
  const [riders, setRiders] = useState([])
  const [toast, setToast] = useState({ show: false, msg: '' })
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ riderId: '', dailyAmount: 1500, totalAmount: 135000, paymentType: 'Daily', motorcycle: 'Boxer 150', startDate: '', endDate: '' })
  const [showRegister, setShowRegister] = useState(false)
  const [regForm, setRegForm] = useState({ name: '', phone: '', email: '', nationalId: '', region: 'Arusha', motorcycle: 'Boxer 150', paymentType: 'Daily', dailyAmount: 1500, totalAmount: 135000, startDate: '', endDate: '' })

  const loadData = async () => {
    if (!user) return
    const c = await getContractsForOwner(user.id)
    setContracts(c)
    const p = await getPaymentsForOwner(user.id)
    setPayments(p)
    const n = await getNotificationsForUser(user.id)
    setNotifications(n)
    const r = await getRidersForOwner(user.id)
    setRiders(r)
  }

  useEffect(() => { loadData() }, [user])

  const handleCreateContract = async () => {
    if (!form.riderId || !form.startDate || !form.endDate) {
      setToast({ show: true, msg: '⚠️ Please fill all fields' })
      setTimeout(() => setToast({ show: false, msg: '' }), 3000)
      return
    }
    const rider = await getUserById(Number(form.riderId))
    await createContract({
      ...form,
      ownerId: user.id,
      ownerName: user.name,
      riderName: rider?.name || 'Unknown',
    })
    setShowForm(false)
    setToast({ show: true, msg: '✅ Contract created successfully!' })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    loadData()
  }

  const handleBlockRider = async (riderId) => {
    await blockRider(riderId)
    setToast({ show: true, msg: `⛔ Rider blocked. Notifications sent.` })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    loadData()
  }

  const [lastPwd, setLastPwd] = useState('')

  const handleRegisterRider = async () => {
    if (!regForm.name) {
      setToast({ show: true, msg: '⚠️ Rider name is required' })
      setTimeout(() => setToast({ show: false, msg: '' }), 3000)
      return
    }
    const result = await createUser({ name: regForm.name, phone: regForm.phone, email: regForm.email, nationalId: regForm.nationalId, region: regForm.region, createdBy: user.id })
    if (regForm.startDate && regForm.endDate) {
      await createContract({
        riderId: result.id,
        ownerId: user.id,
        ownerName: user.name,
        riderName: regForm.name,
        motorcycle: regForm.motorcycle,
        paymentType: regForm.paymentType,
        dailyAmount: regForm.dailyAmount,
        totalAmount: regForm.totalAmount,
        startDate: regForm.startDate,
        endDate: regForm.endDate,
      })
    }
    setLastPwd(result.defaultPwd)
    setShowRegister(false)
    setRegForm({ name: '', phone: '', email: '', nationalId: '', region: 'Arusha', motorcycle: 'Boxer 150', paymentType: 'Daily', dailyAmount: 1500, totalAmount: 135000, startDate: '', endDate: '' })
    setToast({ show: true, msg: `✅ Rider ${regForm.name} registered with contract! Password: ${result.defaultPwd}` })
    setTimeout(() => setToast({ show: false, msg: '' }), 4000)
    loadData()
  }

  const handleOwnerConfirm = async (contractId) => {
    await ownerConfirmContract(contractId)
    setToast({ show: true, msg: `✅ Contract #${contractId} confirmed & active!` })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    loadData()
  }

  const totalPaid = payments.filter(p => p.status === 'paid').reduce((s, p) => s + p.amount, 0)
  const pendingAmount = payments.filter(p => p.status === 'pending' || p.status === 'missed').reduce((s, p) => s + p.amount, 0)
  const activeContracts = contracts.filter(c => c.status === 'Active').length

  const title = tab === 'overview' ? `Owner Dashboard` :
    tab === 'riders' ? 'My Riders' :
    tab === 'contracts' ? 'Contracts' :
    tab === 'payments' ? 'Payments' : 'Alerts'

  const tabContent = () => {
    switch (tab) {
      case 'overview':
        return (
          <>
            <div className="page-title">{title}</div>
            <div className="page-sub">Good {new Date().getHours() < 12 ? 'morning' : 'afternoon'}, {user?.name?.split(' ')[0]} 👋</div>
            <div className="stats-grid">
              <StatCard label="Total Riders" value={riders.length || 0} color="purple" />
              <StatCard label="Active Contracts" value={activeContracts} color="green" />
              <StatCard label="Total Collected" value={`TSh ${totalPaid.toLocaleString()}`} color="green" />
              <StatCard label="Pending" value={`TSh ${pendingAmount.toLocaleString()}`} color="yellow" />
            </div>
            <div className="card">
              <div className="card-title">Recent Contracts</div>
              <DataTable
                columns={['Rider', 'Motorcycle', 'Amount', 'Status']}
                rows={contracts.slice(0, 5).map(c => [
                  c.riderName, c.motorcycle,
                  `TSh ${c.totalAmount.toLocaleString()}`,
                  <Badge status={c.status} />
                ])}
              />
              {contracts.length === 0 && <p className="text-muted" style={{ textAlign: 'center', padding: 20 }}>No contracts yet.</p>}
            </div>
          </>
        )

      case 'riders':
        return (
          <>
            <div className="page-title">My Riders</div>
            <div className="page-sub">Manage riders under your motorcycles</div>
            <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap', marginBottom: 16 }}>
              <button className="btn-primary" onClick={() => setShowForm(!showForm)}>
                {showForm ? '✕ Cancel' : '➕ New Contract'}
              </button>
              <button className="btn-primary" style={{ background: 'var(--green)' }} onClick={() => setShowRegister(!showRegister)}>
                {showRegister ? '✕ Cancel' : '👤 Register New Rider'}
              </button>
            </div>
            {showRegister && (
              <div className="card" style={{ marginBottom: 20, border: '2px solid var(--green)' }}>
                <div className="card-title">Register New Rider + Create Contract</div>
                <div style={{ fontWeight: 500, fontSize: 13, color: 'var(--text)', marginBottom: 12 }}>Rider Details</div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
                  <div style={{ gridColumn: '1 / -1' }}>
                    <label>Full Name *</label>
                    <input type="text" value={regForm.name} onChange={e => setRegForm({ ...regForm, name: e.target.value })} placeholder="e.g. Juma Bakari" />
                  </div>
                  <div>
                    <label>Phone Number</label>
                    <input type="text" value={regForm.phone} onChange={e => setRegForm({ ...regForm, phone: e.target.value })} placeholder="+255 7XX XXX XXX" />
                  </div>
                  <div>
                    <label>Email</label>
                    <input type="email" value={regForm.email} onChange={e => setRegForm({ ...regForm, email: e.target.value })} placeholder="juma@mkataba.tz" />
                  </div>
                  <div>
                    <label>National ID</label>
                    <input type="text" value={regForm.nationalId} onChange={e => setRegForm({ ...regForm, nationalId: e.target.value })} placeholder="19900123456789" />
                  </div>
                  <div>
                    <label>Region</label>
                    <select value={regForm.region} onChange={e => setRegForm({ ...regForm, region: e.target.value })}>
                      <option>Arusha</option>
                      <option>Dar es Salaam</option>
                      <option>Moshi</option>
                      <option>Mwanza</option>
                      <option>Dodoma</option>
                      <option>Mbeya</option>
                      <option>Zanzibar</option>
                    </select>
                  </div>
                </div>
                <hr style={{ margin: '16px 0', borderColor: 'var(--border)' }} />
                <div style={{ fontWeight: 500, fontSize: 13, color: 'var(--text)', marginBottom: 12 }}>Contract Details</div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
                  <div>
                    <label>Motorcycle</label>
                    <select value={regForm.motorcycle} onChange={e => setRegForm({ ...regForm, motorcycle: e.target.value })}>
                      <option>Boxer 150</option>
                      <option>Hero Splendor</option>
                      <option>TVS HLX</option>
                      <option>Bajaj</option>
                    </select>
                  </div>
                  <div>
                    <label>Payment Type</label>
                    <select value={regForm.paymentType} onChange={e => setRegForm({ ...regForm, paymentType: e.target.value })}>
                      <option>Daily</option>
                      <option>Weekly</option>
                    </select>
                  </div>
                  <div>
                    <label>Daily/Weekly Amount (TSh)</label>
                    <input type="number" value={regForm.dailyAmount} onChange={e => setRegForm({ ...regForm, dailyAmount: +e.target.value })} />
                  </div>
                  <div>
                    <label>Total Amount (TSh)</label>
                    <input type="number" value={regForm.totalAmount} onChange={e => setRegForm({ ...regForm, totalAmount: +e.target.value })} />
                  </div>
                  <div>
                    <label>Start Date</label>
                    <input type="date" value={regForm.startDate} onChange={e => setRegForm({ ...regForm, startDate: e.target.value })} />
                  </div>
                  <div>
                    <label>End Date</label>
                    <input type="date" value={regForm.endDate} onChange={e => setRegForm({ ...regForm, endDate: e.target.value })} />
                  </div>
                </div>
                <button className="btn-primary" style={{ marginTop: 16, background: 'var(--green)' }} onClick={handleRegisterRider}>
                  ✅ Register & Create Contract
                </button>
              </div>
            )}
            {showForm && (
              <div className="card" style={{ marginBottom: 20, border: '2px solid var(--purple)' }}>
                <div className="card-title">Create New Contract</div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
                  <div style={{ gridColumn: '1 / -1' }}>
                    <label>Select Rider</label>
                    <select value={form.riderId} onChange={e => setForm({ ...form, riderId: e.target.value })}>
                      <option value="">-- Choose Rider --</option>
                      {riders.map(r => <option key={r.id} value={r.id}>{r.name} – {r.phone}</option>)}
                    </select>
                  </div>
                  <div>
                    <label>Motorcycle</label>
                    <select value={form.motorcycle} onChange={e => setForm({ ...form, motorcycle: e.target.value })}>
                      <option>Boxer 150</option>
                      <option>Hero Splendor</option>
                      <option>TVS HLX</option>
                      <option>Bajaj</option>
                    </select>
                  </div>
                  <div>
                    <label>Payment Type</label>
                    <select value={form.paymentType} onChange={e => setForm({ ...form, paymentType: e.target.value })}>
                      <option>Daily</option>
                      <option>Weekly</option>
                    </select>
                  </div>
                  <div><label>Daily/Weekly Amount (TSh)</label>
                    <input type="number" value={form.dailyAmount} onChange={e => setForm({ ...form, dailyAmount: +e.target.value })} />
                  </div>
                  <div><label>Total Amount (TSh)</label>
                    <input type="number" value={form.totalAmount} onChange={e => setForm({ ...form, totalAmount: +e.target.value })} />
                  </div>
                  <div><label>Start Date</label>
                    <input type="date" value={form.startDate} onChange={e => setForm({ ...form, startDate: e.target.value })} />
                  </div>
                  <div><label>End Date</label>
                    <input type="date" value={form.endDate} onChange={e => setForm({ ...form, endDate: e.target.value })} />
                  </div>
                </div>
                <button className="btn-primary" style={{ marginTop: 16 }} onClick={handleCreateContract}>
                  ✅ Create Contract
                </button>
              </div>
            )}
            <div className="card">
              <div className="card-title">All Riders</div>
              {riders.length === 0 ? (
                <p className="text-muted">No riders assigned yet. Create a contract to assign a rider.</p>
              ) : (
                riders.map(r => {
                  const rc = contracts.find(c => c.riderId === r.id)
                  return (
                    <div key={r.id} className="flex-between" style={{ padding: '12px 0', borderBottom: '1px solid var(--border)' }}>
                      <div>
                        <p className="fw700">{r.name}</p>
                        <p className="text-muted" style={{ fontSize: 12 }}>{r.phone} • {rc ? rc.motorcycle : 'No bike'}</p>
                      </div>
                      <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                        <Badge status={rc?.status || 'inactive'} />
                        <button className="nav-btn" style={{ background: 'var(--red-bg)', color: 'var(--red)' }}
                                onClick={() => handleBlockRider(r.id)}>⛔ Block</button>
                      </div>
                    </div>
                  )
                })
              )}
            </div>
          </>
        )

      case 'contracts':
        return (
          <>
            <div className="page-title">Contracts</div>
            <div className="page-sub">All agreements with your riders</div>
            <div className="card">
              <DataTable
                columns={['#', 'Rider', 'Motorcycle', 'Type', 'Total', 'Status', 'Action']}
                rows={contracts.map((c, i) => [
                  `#${c.contractId}`,
                  c.riderName,
                  c.motorcycle,
                  c.paymentType,
                  `TSh ${c.totalAmount.toLocaleString()}`,
                  <Badge status={c.status} />,
                  c.status === 'Accepted' ? (
                    <button className="nav-btn" style={{ background: 'var(--green-bg)', color: 'var(--green)' }}
                            onClick={() => handleOwnerConfirm(c.contractId)}>Confirm</button>
                  ) : c.status === 'Pending' ? (
                    <span className="text-muted" style={{ fontSize: 11 }}>Awaiting rider</span>
                  ) : '—'
                ])}
              />
              {contracts.length === 0 && <p className="text-muted" style={{ textAlign: 'center', padding: 20 }}>No contracts yet.</p>}
            </div>
          </>
        )

      case 'payments':
        return (
          <>
            <div className="page-title">Payments</div>
            <div className="page-sub">All payment transactions from your riders</div>
            <div className="stats-grid" style={{ marginBottom: 16 }}>
              <StatCard label="Total Collected" value={`TSh ${totalPaid.toLocaleString()}`} color="green" />
              <StatCard label="Pending" value={`TSh ${pendingAmount.toLocaleString()}`} color="yellow" />
            </div>
            <div className="card">
              <DataTable
                columns={['Date', 'Rider', 'Amount', 'Method', 'Status']}
                rows={payments.map(p => [
                  p.date,
                  p.riderName || '—',
                  `TSh ${p.amount.toLocaleString()}`,
                  p.method,
                  <Badge status={p.status} />
                ])}
              />
              {payments.length === 0 && <p className="text-muted" style={{ textAlign: 'center', padding: 20 }}>No payments yet.</p>}
            </div>
          </>
        )

      case 'alerts':
        return (
          <>
            <div className="page-title">Alerts</div>
            <div className="page-sub">Notifications and reminders</div>
            <div className="card">
              <ul className="notif-list">
                {notifications.length === 0 && <p className="text-muted" style={{ textAlign: 'center', padding: 20 }}>No alerts.</p>}
                {notifications.map(n => (
                  <NotificationItem key={n.id} item={n} />
                ))}
              </ul>
            </div>
          </>
        )

      default:
        return null
    }
  }

  return (
    <Layout role="owner" activeTab={tab} onTabChange={setTab} onLogout={logout}>
      {tabContent()}
      <Toast visible={toast.show} message={toast.msg} />
    </Layout>
  )
}
