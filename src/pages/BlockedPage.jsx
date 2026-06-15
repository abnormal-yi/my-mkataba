import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { getContractForRider, getPaymentsForRider } from '../data/db'

export default function BlockedPage() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const [contract, setContract] = useState(null)
  const [payments, setPayments] = useState([])

  useEffect(() => {
    if (!user) return
    getContractForRider(user.id).then(setContract)
    getPaymentsForRider(user.id).then(setPayments)
  }, [user])

  const balance = contract ? contract.totalAmount - contract.paidAmount : 0
  const missedPayments = payments.filter(p => p.status === 'overdue').length

  const handlePay = () => {
    // Placeholder - in real app this would trigger M-Pesa
    alert('💰 M-Pesa payment initiated for TSh ' + (contract?.dailyAmount || 1500).toLocaleString())
  }

  return (
    <div className="app" style={{ padding: 24, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', minHeight: '100vh', textAlign: 'center' }}>
      <div style={{ fontSize: 72, marginBottom: 16 }}>⛔</div>
      <h1 style={{ fontSize: 28, color: 'var(--red)', marginBottom: 8 }}>Access Blocked</h1>
      <p style={{ color: 'var(--muted)', maxWidth: 360, lineHeight: 1.7, marginBottom: 24 }}>
        Your account has been temporarily suspended due to unpaid dues.
        Please clear your balance to regain access.
      </p>

      <div className="card" style={{ width: '100%', maxWidth: 400, marginBottom: 24 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
          <span className="text-muted">Outstanding Balance</span>
          <span style={{ fontSize: 24, fontWeight: 800, color: 'var(--red)' }}>TSh {balance.toLocaleString()}</span>
        </div>
        <ProgressBar value={contract ? Math.round((contract.paidAmount / contract.totalAmount) * 100) : 0} />
        <p className="text-muted" style={{ fontSize: 12, marginTop: 8 }}>
          {contract ? `${Math.round((contract.paidAmount / contract.totalAmount) * 100)}% paid` : 'No contract data'}
        </p>
      </div>

      <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap', justifyContent: 'center' }}>
        <button className="btn-primary" style={{ background: 'var(--green)', padding: '14px 32px', fontSize: 16 }}
                onClick={handlePay}>
          💳 Pay Now via M-Pesa
        </button>
        <button className="btn-primary" style={{ background: 'var(--muted)', padding: '14px 32px', fontSize: 16 }}
                onClick={() => navigate('/')}>
          ← Go Home
        </button>
      </div>

      <div className="card" style={{ width: '100%', maxWidth: 400, marginTop: 24 }}>
        <div className="card-title">Missed Payments</div>
        {payments.filter(p => p.status === 'overdue').length === 0 ? (
          <p className="text-muted">No missed payments recorded.</p>
        ) : (
          payments.filter(p => p.status === 'overdue').map((p, i) => (
            <div key={i} style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 0', borderBottom: '1px solid var(--border)', fontSize: 13 }}>
              <span>{p.date}</span>
              <span>TSh {p.amount.toLocaleString()}</span>
              <span style={{ color: 'var(--red)' }}>Overdue</span>
            </div>
          ))
        )}
      </div>
    </div>
  )
}

function ProgressBar({ value }) {
  return (
    <div style={{ width: '100%', height: 8, background: 'var(--border)', borderRadius: 4, overflow: 'hidden' }}>
      <div style={{ width: `${Math.min(100, value)}%`, height: '100%', background: 'linear-gradient(90deg, var(--green), var(--purple))', borderRadius: 4, transition: 'width .5s' }} />
    </div>
  )
}
