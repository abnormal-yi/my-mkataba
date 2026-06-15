import { useState, useEffect } from 'react'
import { useAuth } from '../context/AuthContext'
import { getContractForRider, getPaymentsForRider, getNotificationsForUser, makePayment, acceptContract, rejectContract, changePassword } from '../data/db'
import Layout from '../components/Layout'
import StatCard from '../components/StatCard'
import Badge from '../components/Badge'
import ProgressBar from '../components/ProgressBar'
import DataTable from '../components/DataTable'
import CalendarGrid from '../components/CalendarGrid'
import NotificationItem from '../components/NotificationItem'
import Toast from '../components/Toast'

export default function RiderDashboard() {
  const { user, logout } = useAuth()
  const [tab, setTab] = useState('overview')
  const [contract, setContract] = useState(null)
  const [payments, setPayments] = useState([])
  const [notifications, setNotifications] = useState([])
  const [toast, setToast] = useState({ show: false, msg: '' })
  const [step, setStep] = useState('') // '' | 'accept' | 'changepwd' | 'done'

  useEffect(() => { loadData() }, [user])

  const loadData = async () => {
    if (!user) return
    const c = await getContractForRider(user.id)
    setContract(c)
    const p = await getPaymentsForRider(user.id)
    setPayments(p)
    const n = await getNotificationsForUser(user.id)
    setNotifications(n)

    if (user.firstLogin && c && (c.status === 'Pending' || c.status === 'Accepted')) {
      setStep('accept')
    } else if (user.firstLogin && c && c.status === 'Accepted') {
      setStep('changepwd')
    } else {
      setStep('done')
    }
  }

  const handleAcceptContract = async () => {
    if (!contract) return
    await acceptContract(contract.contractId, user.id)
    setToast({ show: true, msg: '✅ Contract accepted! Now set your new password.' })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    setStep('changepwd')
  }

  const handleRejectContract = async () => {
    if (!contract) return
    await rejectContract(contract.contractId, user.id)
    setToast({ show: true, msg: '⛔ Contract rejected. Owner notified.' })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    setStep('done')
    logout()
  }

  const handleChangePassword = async () => {
    if (!newPwd || newPwd.length < 4) {
      setToast({ show: true, msg: '⚠️ Password must be at least 4 characters' })
      setTimeout(() => setToast({ show: false, msg: '' }), 3000)
      return
    }
    await changePassword(user.id, newPwd)
    setToast({ show: true, msg: '✅ Password changed! Welcome to My Mkataba 🎉' })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    setStep('done')
    setNewPwd('')
  }

  const [newPwd, setNewPwd] = useState('')

  const handlePay = async () => {
    await makePayment(user.id)
    setToast({ show: true, msg: '✅ Payment of TSh 1,500 sent via M-Pesa!' })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    loadData()
  }

  const progress = contract ? Math.round((contract.paidAmount / contract.totalAmount) * 100) : 0
  const balance = contract ? contract.totalAmount - contract.paidAmount : 0
  const daysLeft = contract ? Math.ceil((new Date(contract.endDate) - new Date()) / (1000 * 60 * 60 * 24)) : 0
  const totalDays = contract ? Math.ceil((new Date(contract.endDate) - new Date(contract.startDate)) / (1000 * 60 * 60 * 24)) : 90

  const title = tab === 'overview' ? `Good ${new Date().getHours() < 12 ? 'morning' : 'afternoon'}, ${user?.name?.split(' ')[0]} 👋` :
    tab === 'contract' ? 'My Contract' :
    tab === 'payments' ? 'Payment History' :
    tab === 'notifications' ? 'Notifications' : 'My Profile'

  if (step === 'accept') {
    return (
      <div className="app" style={{ padding: 24, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', minHeight: '100vh' }}>
        <div style={{ maxWidth: 500, width: '100%' }}>
          <div style={{ textAlign: 'center', marginBottom: 24 }}>
            <div style={{ fontSize: 56, marginBottom: 8 }}>📄</div>
            <h2 style={{ fontSize: 24 }}>New Contract Available</h2>
            <p className="text-muted">Review and accept your contract to start</p>
          </div>
          <div className="card" style={{ border: '2px solid var(--purple)' }}>
            <div className="card-title flex-between">
              Contract #{contract?.contractId}
              <Badge status="purple" label={contract?.paymentType} />
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, marginBottom: 16 }}>
              <div><p className="text-muted" style={{ fontSize: 12 }}>Owner</p><p className="fw700">{contract?.ownerName}</p></div>
              <div><p className="text-muted" style={{ fontSize: 12 }}>Rider</p><p className="fw700">{contract?.riderName}</p></div>
              <div><p className="text-muted" style={{ fontSize: 12 }}>Motorcycle</p><p className="fw700">{contract?.motorcycle}</p></div>
              <div><p className="text-muted" style={{ fontSize: 12 }}>Payment</p><p className="fw700">TSh {contract?.dailyAmount?.toLocaleString()}/{contract?.paymentType?.toLowerCase()}</p></div>
              <div><p className="text-muted" style={{ fontSize: 12 }}>Total Amount</p><p className="fw700">TSh {contract?.totalAmount?.toLocaleString()}</p></div>
              <div><p className="text-muted" style={{ fontSize: 12 }}>Duration</p><p className="fw700">{contract?.startDate} – {contract?.endDate}</p></div>
            </div>
            <div style={{ background: '#F8F7FF', borderRadius: 10, padding: 16, fontSize: 13, lineHeight: 1.7, color: 'var(--muted)', marginBottom: 16 }}>
              {contract?.agreementText || 'Standard Boda Boda contract agreement.'}
            </div>
            <div style={{ display: 'flex', gap: 12 }}>
              <button className="btn-primary" style={{ flex: 1, background: 'var(--green)' }} onClick={handleAcceptContract}>
                ✅ Accept Contract
              </button>
              <button className="btn-primary" style={{ flex: 1, background: 'var(--red)' }} onClick={handleRejectContract}>
                ✕ Reject
              </button>
            </div>
          </div>
        </div>
        <Toast visible={toast.show} message={toast.msg} />
      </div>
    )
  }

  if (step === 'changepwd') {
    return (
      <div className="app" style={{ padding: 24, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', minHeight: '100vh' }}>
        <div style={{ maxWidth: 400, width: '100%' }}>
          <div style={{ textAlign: 'center', marginBottom: 24 }}>
            <div style={{ fontSize: 56, marginBottom: 8 }}>🔐</div>
            <h2 style={{ fontSize: 24 }}>Change Your Password</h2>
            <p className="text-muted">Set a new password to secure your account</p>
          </div>
          <div className="card">
            <label>Default Password</label>
            <input type="text" value="1234" disabled style={{ background: '#f5f5f5' }} />
            <label>New Password</label>
            <input type="password" value={newPwd} onChange={e => setNewPwd(e.target.value)} placeholder="Min 4 characters" />
            <button className="btn-primary" style={{ background: 'var(--green)' }} onClick={handleChangePassword}>
              ✅ Save & Continue
            </button>
          </div>
          <p className="text-muted" style={{ textAlign: 'center', fontSize: 12, marginTop: 12 }}>
            Owner has been notified to confirm the contract.
          </p>
        </div>
        <Toast visible={toast.show} message={toast.msg} />
      </div>
    )
  }

  const tabContent = () => {
    switch (tab) {
      case 'overview':
        return (
          <>
            <div className="page-title">{title}</div>
            <div className="page-sub">Here's your contract summary for today</div>
            <div className="stats-grid">
              <StatCard label="Contract Status" value={<Badge status={contract?.status?.toLowerCase() || 'pending'} />}
                        note={contract ? `Expires ${contract.endDate}` : 'No contract'} color="green" />
              <StatCard label="Days Remaining" value={Math.max(0, daysLeft)} note={`Out of ${totalDays} days`} />
              <StatCard label="Amount Paid" value={`TSh ${(contract?.paidAmount || 0).toLocaleString()}`}
                        note={contract ? `of TSh ${contract.totalAmount.toLocaleString()} total` : ''} color="green" />
              <StatCard label="Balance Due" value={`TSh ${balance.toLocaleString()}`} note={balance > 0 ? 'Pending' : 'All paid!'} color="yellow" />
            </div>
            {contract && (
              <>
                <div className="card">
                  <div className="card-title">Payment Progress <Badge status="purple">{contract.paymentType} – TSh {contract.dailyAmount.toLocaleString()}/{contract.paymentType?.toLowerCase()}</Badge></div>
                  <div className="flex-between mb16">
                    <span className="text-muted">Paid: <strong className="text-green">TSh {contract.paidAmount.toLocaleString()}</strong></span>
                    <span className="text-muted">Remaining: <strong className="text-red">TSh {balance.toLocaleString()}</strong></span>
                  </div>
                  <ProgressBar value={progress} />
                  <p style={{ fontSize: 11, color: 'var(--muted)', marginTop: 6 }}>{progress}% complete</p>
                </div>
                <button className="btn-primary" style={{ marginBottom: 20 }} onClick={handlePay}>
                  💳 Pay TSh {contract.dailyAmount.toLocaleString()} Now via M-Pesa
                </button>
              </>
            )}
            <div className="card">
              <div className="card-title">June 2026 – Payment Tracker</div>
              <CalendarGrid status={null} />
            </div>
          </>
        )

      case 'contract':
        return (
          <>
            <div className="page-title">My Contract</div>
            <div className="page-sub">Current signed agreement details</div>
            {contract ? (
              <div className="card">
                <div className="card-title flex-between">
                  Contract #{contract.contractId}
                  <Badge status={contract.status?.toLowerCase()} />
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
                  <div><p className="text-muted" style={{ fontSize: 12 }}>Owner</p><p className="fw700">{contract.ownerName}</p></div>
                  <div><p className="text-muted" style={{ fontSize: 12 }}>Rider</p><p className="fw700">{contract.riderName}</p></div>
                  <div><p className="text-muted" style={{ fontSize: 12 }}>Start Date</p><p className="fw700">{contract.startDate}</p></div>
                  <div><p className="text-muted" style={{ fontSize: 12 }}>End Date</p><p className="fw700">{contract.endDate}</p></div>
                  <div><p className="text-muted" style={{ fontSize: 12 }}>Payment Type</p><p className="fw700">{contract.paymentType}</p></div>
                  <div><p className="text-muted" style={{ fontSize: 12 }}>{contract.paymentType === 'Weekly' ? 'Weekly' : 'Daily'} Amount</p>
                    <p className="fw700">TSh {contract.dailyAmount.toLocaleString()}</p></div>
                  <div><p className="text-muted" style={{ fontSize: 12 }}>Total Amount</p><p className="fw700">TSh {contract.totalAmount.toLocaleString()}</p></div>
                  <div><p className="text-muted" style={{ fontSize: 12 }}>Motorcycle</p><p className="fw700">{contract.motorcycle}</p></div>
                </div>
                <div className="divider" />
                <div className="card-title">Digital Agreement</div>
                <div style={{ background: '#F8F7FF', borderRadius: 10, padding: 16, fontSize: 13, lineHeight: 1.7, color: 'var(--muted)', marginBottom: 16 }}>
                  {contract.agreementText || 'No agreement text available.'}
                </div>
                {contract.signedDate ? (
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--green-bg)', padding: '12px 16px', borderRadius: 8 }}>
                    <span style={{ fontSize: 20 }}>✅</span>
                    <div>
                      <p style={{ fontSize: 13, fontWeight: 700, color: 'var(--green)' }}>Agreement Accepted</p>
                      <p style={{ fontSize: 11, color: 'var(--muted)' }}>Signed digitally on {contract.signedDate}</p>
                    </div>
                  </div>
                ) : (
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--yellow-bg)', padding: '12px 16px', borderRadius: 8 }}>
                    <span style={{ fontSize: 20 }}>⏳</span>
                    <div>
                      <p style={{ fontSize: 13, fontWeight: 700, color: 'var(--yellow)' }}>Awaiting Digital Signature</p>
                      <p style={{ fontSize: 11, color: 'var(--muted)' }}>Accept the agreement to activate your contract.</p>
                    </div>
                  </div>
                )}
              </div>
            ) : (
              <div className="card"><p className="text-muted">No contract found.</p></div>
            )}
          </>
        )

      case 'payments':
        return (
          <>
            <div className="page-title">Payment History</div>
            <div className="page-sub">All transactions on your contract</div>
            <div className="card">
              <DataTable
                columns={['Date', 'Amount', 'Method', 'Status']}
                rows={payments.map(p => [
                  p.date,
                  `TSh ${p.amount.toLocaleString()}`,
                  p.method || 'M-Pesa',
                  <Badge status={p.status} />
                ])}
              />
              {payments.length === 0 && <p className="text-muted" style={{ textAlign: 'center', padding: 20 }}>No payments yet.</p>}
            </div>
          </>
        )

      case 'notifications':
        return (
          <>
            <div className="page-title">Notifications</div>
            <div className="page-sub">Alerts and reminders from My Mkataba</div>
            <div className="card">
              <ul className="notif-list">
                {notifications.length === 0 && <p className="text-muted" style={{ textAlign: 'center', padding: 20 }}>No notifications.</p>}
                {notifications.map((n, i) => (
                  <NotificationItem key={n.id || i} item={n} />
                ))}
              </ul>
            </div>
          </>
        )

      case 'profile':
        return (
          <>
            <div className="page-title">My Profile</div>
            <div className="page-sub">Personal account information</div>
            <div className="card" style={{ maxWidth: 480 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginBottom: 24 }}>
                <div style={{ width: 64, height: 64, borderRadius: '50%', background: 'linear-gradient(135deg,#6C3FC5,#A78BFA)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontSize: 24, fontWeight: 800 }}>
                  {user?.initials}
                </div>
                <div>
                  <h3 style={{ fontSize: 18 }}>{user?.name}</h3>
                  <p className="text-muted">{user?.role}</p>
                </div>
              </div>
              <label>Full Name</label>
              <input type="text" defaultValue={user?.name} />
              <label>Phone Number</label>
              <input type="text" defaultValue={user?.phone || '+255 7XX XXX XXX'} />
              <label>Email</label>
              <input type="email" defaultValue={user?.email} />
              <label>National ID</label>
              <input type="text" defaultValue={user?.nationalId || '19XXXXXXXXXXXXXX'} />
              <button className="btn-primary" onClick={() => {
                setToast({ show: true, msg: '✅ Profile updated!' })
                setTimeout(() => setToast({ show: false, msg: '' }), 3000)
              }}>Save Changes</button>
            </div>
          </>
        )

      default:
        return null
    }
  }

  return (
    <Layout role="rider" activeTab={tab} onTabChange={setTab} onLogout={logout}>
      {tabContent()}
      <Toast visible={toast.show} message={toast.msg} />
    </Layout>
  )
}
