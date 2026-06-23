import { useState, useEffect } from 'react'
import { useAuth } from '../context/AuthContext'
import { getContractsForOwner, getActivePaymentsForOwner, getNotificationsForUser, createContract, createUser, getUserById, getRidersForOwner, blockRider, unblockRider, deleteRider, ownerConfirmContract, getAllLastLocations, isPaidStatus, getPaymentsSummaryForOwner, getPaymentsForRider } from '../data/db'
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
  const [form, setForm] = useState({ riderId: '', dailyAmount: 1500, totalAmount: 135000, paymentType: 'Daily', motorcycle: 'Boxer 150', plateNumber: '', startDate: '', endDate: '' })
  const [showRegister, setShowRegister] = useState(false)
  const [showCredsModal, setShowCredsModal] = useState(false)
  const [lastCredentials, setLastCredentials] = useState({ name: '', email: '', password: '' })
  const [regForm, setRegForm] = useState({ name: '', phone: '', email: '', nationalId: '', region: 'Arusha', motorcycle: 'Boxer 150', plateNumber: '', paymentType: 'Daily', dailyAmount: 1500, totalAmount: 135000, startDate: '', endDate: '' })
  const [riderLocations, setRiderLocations] = useState([])
  const [mapRider, setMapRider] = useState(null)
  const [ownerSummary, setOwnerSummary] = useState({ totalPaid: 0, totalPending: 0, totalShort: 0, count: 0 })
  const [selectedRiderPayments, setSelectedRiderPayments] = useState([])
  const [selectedRiderForPayments, setSelectedRiderForPayments] = useState(null)

  const loadData = async () => {
    if (!user) return
    const c = await getContractsForOwner(user.id)
    setContracts(c)
    const p = await getActivePaymentsForOwner(user.id)
    setPayments(p)
    const n = await getNotificationsForUser(user.id)
    setNotifications(n)
    const r = await getRidersForOwner(user.id)
    setRiders(r)
    const locs = await getAllLastLocations()
    setRiderLocations(locs)
    const summary = await getPaymentsSummaryForOwner(user.id)
    setOwnerSummary(summary)
  }

  useEffect(() => { loadData() }, [user])

  useEffect(() => {
    if (!selectedRiderForPayments) {
      setSelectedRiderPayments([])
      return
    }
    getPaymentsForRider(selectedRiderForPayments.id).then(setSelectedRiderPayments)
  }, [selectedRiderForPayments])

  const handleCreateContract = async () => {
    if (!form.riderId || !form.startDate || !form.endDate || !form.plateNumber) {
      setToast({ show: true, msg: '⚠️ Please fill all fields' })
      setTimeout(() => setToast({ show: false, msg: '' }), 3000)
      return
    }
    const rider = await getUserById(Number(form.riderId))
    await createContract({
      ...form,
      motorcycle: `${form.motorcycle} - ${form.plateNumber}`,
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

  const handleUnblockRider = async (riderId) => {
    await unblockRider(riderId)
    setToast({ show: true, msg: `Rider is active again.` })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    loadData()
  }

  const handleDisableRider = async (riderId) => {
    await deleteRider(riderId)
    setToast({ show: true, msg: `Rider disabled. History has been kept.` })
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
    let result
    try {
      result = await createUser({ name: regForm.name, phone: regForm.phone, email: regForm.email, nationalId: regForm.nationalId, region: regForm.region, createdBy: user.id })
    } catch (error) {
      setToast({ show: true, msg: error.message || 'Could not register rider' })
      setTimeout(() => setToast({ show: false, msg: '' }), 3000)
      return
    }
    if (regForm.startDate && regForm.endDate) {
      const plate = regForm.plateNumber || `${regForm.motorcycle.toUpperCase().slice(0,3)} ${100 + result.id}`
      await createContract({
        riderId: result.id,
        ownerId: user.id,
        ownerName: user.name,
        riderName: regForm.name,
      motorcycle: `${regForm.motorcycle} - ${plate}`,
        paymentType: regForm.paymentType,
        dailyAmount: regForm.dailyAmount,
        totalAmount: regForm.totalAmount,
        startDate: regForm.startDate,
        endDate: regForm.endDate,
      })
    }
    setLastPwd(result.defaultPwd)
    setShowRegister(false)
    setRegForm({ name: '', phone: '', email: '', nationalId: '', region: 'Arusha', motorcycle: 'Boxer 150', plateNumber: '', paymentType: 'Daily', dailyAmount: 1500, totalAmount: 135000, startDate: '', endDate: '' })
    setLastCredentials({ name: regForm.name, email: regForm.email || `${regForm.name.toLowerCase().replace(/\s+/g, '.')}@mkataba.tz`, password: result.defaultPwd })
    setShowCredsModal(true)
    loadData()
  }

  const handleOwnerConfirm = async (contractId) => {
    await ownerConfirmContract(contractId)
    setToast({ show: true, msg: `✅ Contract #${contractId} confirmed & active!` })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    loadData()
  }

  const totalPaid = ownerSummary.totalPaid
  const pendingAmount = ownerSummary.totalPending
  const activeContracts = contracts.filter(c => String(c.status).toLowerCase() === 'active').length
  const paidByRider = riders.reduce((acc, rider) => {
    acc[rider.id] = payments
      .filter(p => p.riderId === rider.id && isPaidStatus(p.status))
      .reduce((sum, p) => sum + p.amount, 0)
    return acc
  }, {})

  const title = tab === 'overview' ? `Owner Dashboard` :
    tab === 'riders' ? 'My Riders' :
    tab === 'contracts' ? 'Contracts' :
    tab === 'payments' ? 'Payments' :
    tab === 'locations' ? 'Rider Locations' : 'Alerts'

  const tabContent = () => {
    switch (tab) {
      case 'overview':
        return (
          <>
            <div className="page-title">{title}</div>
            <div className="page-sub">Good {new Date().getHours() < 12 ? 'morning' : 'afternoon'}, {user?.name?.split(' ')[0]}</div>
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
              <button className="btn-primary btn-compact" onClick={() => setShowForm(!showForm)}>
                {showForm ? 'Cancel' : 'New Contract'}
              </button>
              <button className="btn-primary btn-compact btn-green" onClick={() => setShowRegister(!showRegister)}>
                {showRegister ? 'Cancel' : 'Register Rider + Boda'}
              </button>
            </div>
            {showRegister && (
              <div className="card" style={{ marginBottom: 20, border: '2px solid var(--green)' }}>
                <div className="card-title">Register Rider Account + Assign Boda</div>
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
                    <label>Motorcycle Model</label>
                    <select value={regForm.motorcycle} onChange={e => setRegForm({ ...regForm, motorcycle: e.target.value })}>
                      <option>Boxer 150</option>
                      <option>Hero Splendor</option>
                      <option>TVS HLX</option>
                      <option>Bajaj</option>
                    </select>
                  </div>
                  <div>
                    <label>Plate Number</label>
                    <input type="text" value={regForm.plateNumber} onChange={e => setRegForm({ ...regForm, plateNumber: e.target.value.toUpperCase() })} placeholder="e.g. T 245 ABZ" />
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
                <button className="btn-primary btn-green" style={{ marginTop: 16 }} onClick={handleRegisterRider}>
                  Create Account & Assign Boda
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
                    <label>Plate Number *</label>
                    <input type="text" value={form.plateNumber} onChange={e => setForm({ ...form, plateNumber: e.target.value.toUpperCase() })} placeholder="e.g. T 245 ABZ" />
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
                  Create Contract & Assign Boda
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
                        <p className="text-muted" style={{ fontSize: 12 }}>
                          {r.phone || 'No phone'} | {rc ? rc.motorcycle : 'No bike'} | Paid: TSh {(paidByRider[r.id] || 0).toLocaleString()}
                        </p>
                      </div>
                      <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                        <Badge status={r.status || rc?.status || 'inactive'} />
                        {String(r.status || '').toLowerCase() === 'blocked' || String(r.status || '').toLowerCase() === 'disabled' ? (
                          <button className="action-btn action-success"
                                  onClick={() => handleUnblockRider(r.id)}>Unblock</button>
                        ) : (
                          <div className="action-row">
                            <button className="action-btn action-warning"
                                    onClick={() => handleBlockRider(r.id)}>Block</button>
                            <button className="action-btn action-danger"
                                    onClick={() => handleDisableRider(r.id)}>Disable</button>
                          </div>
                        )}
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

            <div className="card" style={{ marginBottom: 16 }}>
              <div className="card-title">Select Rider</div>
              <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 12 }}>
                {riders.map(r => {
                  const rc = contracts.find(c => c.riderId === r.id)
                  const riderPaid = payments.filter(p => p.riderId === r.id && isPaidStatus(p.status)).reduce((s, p) => s + p.amount, 0)
                  return (
                    <button key={r.id}
                      className={`action-btn ${selectedRiderForPayments?.id === r.id ? 'action-success' : 'action-primary'}`}
                      onClick={() => setSelectedRiderForPayments(r)}>
                      {r.name} — TSh {riderPaid.toLocaleString()}
                    </button>
                  )
                })}
              </div>
              {riders.length === 0 && <p className="text-muted">No riders yet.</p>}
            </div>

            {selectedRiderForPayments && (() => {
              const rc = contracts.find(c => c.riderId === selectedRiderForPayments.id)
              const riderTotal = selectedRiderPayments.filter(p => isPaidStatus(p.status)).reduce((s, p) => s + p.amount, 0)
              const riderPending = selectedRiderPayments.filter(p => p.status === 'pending' || p.status === 'missed').reduce((s, p) => s + p.amount, 0)
              return (
                <>
                  <div className="card" style={{ marginBottom: 16 }}>
                    <div className="card-title">{selectedRiderForPayments.name} — Full Payment History</div>
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12, marginBottom: 12 }}>
                      <StatCard label="Contract" value={rc?.contractId || '—'} color="purple" />
                      <StatCard label="Total Paid" value={`TSh ${riderTotal.toLocaleString()}`} color="green" />
                      <StatCard label="Pending" value={`TSh ${riderPending.toLocaleString()}`} color="yellow" />
                    </div>
                    {rc && (
                      <p className="text-muted" style={{ fontSize: 12, marginBottom: 8 }}>
                        Contract: {rc.startDate} → {rc.endDate} | {rc.paymentType} TSh {rc.dailyAmount.toLocaleString()} | Total: TSh {rc.totalAmount.toLocaleString()}
                      </p>
                    )}
                  </div>
                  <div className="card">
                    <div className="card-title">Payment Transactions</div>
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
                      <p className="text-muted" style={{ textAlign: 'center', padding: 20 }}>No payments yet for this rider.</p>
                    )}
                  </div>
                </>
              )
            })()}
          </>
        )

      case 'locations':
        return (
          <>
            <div className="page-title">Rider Locations</div>
            <div className="page-sub">Last known GPS location of your riders</div>
            <div className="card">
              {riders.filter(r => r.id > 0).map(r => {
                const loc = riderLocations.find(l => l.riderId === r.id)
                return (
                  <div key={r.id} className="flex-between" style={{ padding: '12px 0', borderBottom: '1px solid var(--border)' }}>
                    <div>
                      <p className="fw700">{r.name}</p>
                      <p className="text-muted" style={{ fontSize: 12, marginTop: 2 }}>
                        {loc
                          ? `GPS: ${loc.lat.toFixed(4)}, ${loc.lng.toFixed(4)} | ${new Date(loc.timestamp).toLocaleString()}`
                           : 'No GPS found yet'}
                      </p>
                    </div>
                    <button className="action-btn action-primary"
                            disabled={!loc}
                            onClick={() => loc && setMapRider({ ...loc, name: r.name })}>
                      Track
                    </button>
                  </div>
                )
              })}
              {riders.filter(r => r.id > 0).length === 0 && (
                <p className="text-muted" style={{ textAlign: 'center', padding: 20 }}>No riders found.</p>
              )}
            </div>

            {mapRider && (
              <div className="modal-overlay" onClick={() => setMapRider(null)}>
                <div className="modal-card" onClick={e => e.stopPropagation()} style={{ maxWidth: 500, width: '90%' }}>
                  <div className="modal-title" style={{ fontSize: 16, textAlign: 'center', padding: '16px 16px 0' }}>
                    📍 {mapRider.name}
                  </div>
                  <div className="modal-body" style={{ padding: 0 }}>
                    <div style={{ height: 220, background: '#F3F4F6', display: 'flex', alignItems: 'center', justifyContent: 'center', textAlign: 'center', padding: 20 }}>
                      <div>
                        <div style={{ fontSize: 42, marginBottom: 8 }}>GPS</div>
                        <p className="fw700">{mapRider.lat.toFixed(6)}, {mapRider.lng.toFixed(6)}</p>
                      </div>
                    </div>
                    <div style={{ padding: '12px 16px 16px' }}>
                      <p className="text-muted" style={{ fontSize: 12, marginBottom: 2 }}>Latitude: {mapRider.lat}</p>
                      <p className="text-muted" style={{ fontSize: 12, marginBottom: 2 }}>Longitude: {mapRider.lng}</p>
                      <p className="text-muted" style={{ fontSize: 12, marginBottom: 8 }}>Time: {new Date(mapRider.timestamp).toLocaleString()}</p>
                      <a href={`https://www.openstreetmap.org/?mlat=${mapRider.lat}&mlon=${mapRider.lng}&zoom=15`}
                         target="_blank" rel="noopener noreferrer"
                         style={{ color: 'var(--purple)', fontWeight: 600, fontSize: 13 }}>
                        Open in OpenStreetMap →
                      </a>
                    </div>
                  </div>
                  <button className="btn-primary" style={{ margin: '0 16px 16px' }} onClick={() => setMapRider(null)}>
                    Close
                  </button>
                </div>
              </div>
            )}
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
      {showCredsModal && (
        <div className="modal-overlay" onClick={() => setShowCredsModal(false)}>
          <div className="modal-card" onClick={e => e.stopPropagation()}>
            <div className="modal-icon">🎉</div>
            <div className="modal-title">Rider Registered!</div>
            <div className="modal-body">
              <p style={{ margin: '0 0 12px' }}>Give these credentials to the rider:</p>
              <div className="creds-box">
                <div className="creds-row"><span className="creds-label">Name:</span><span className="creds-value">{lastCredentials.name}</span></div>
                <div className="creds-row"><span className="creds-label">Email:</span><span className="creds-value">{lastCredentials.email}</span></div>
                <div className="creds-row"><span className="creds-label">Password:</span><span className="creds-value creds-pwd">{lastCredentials.password}</span></div>
              </div>
              <button className="btn-primary" style={{ width: '100%', marginTop: 16 }} onClick={() => setShowCredsModal(false)}>
                ✓ Nimeona (Got it)
              </button>
            </div>
          </div>
        </div>
      )}
    </Layout>
  )
}
