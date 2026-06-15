import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { createContract, getUsersByRole } from '../data/db'
import Toast from '../components/Toast'

export default function ContractFormPage() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const [toast, setToast] = useState({ show: false, msg: '' })
  const [submitting, setSubmitting] = useState(false)
  const [form, setForm] = useState({
    riderName: '',
    ownerName: '',
    motorcycle: 'Boxer 150',
    dailyAmount: '1500',
    totalAmount: '135000',
    paymentType: 'Daily',
    startDate: '',
    endDate: '',
    agreementText: 'I agree to pay TSh 1,500 per day for the use of the motorcycle. Payment shall be made via M-Pesa. Failure to pay for 3 consecutive days may result in contract termination.',
    riderId: '',
    ownerId: ''
  })

  const handleSubmit = async (e) => {
    e.preventDefault()
    setSubmitting(true)
    try {
      await createContract({
        ...form,
        dailyAmount: Number(form.dailyAmount),
        totalAmount: Number(form.totalAmount),
        riderId: form.riderId || user?.id,
        ownerId: form.ownerId || user?.id,
      })
      setToast({ show: true, msg: '✅ Contract created successfully!' })
      setTimeout(() => navigate('/rider'), 2000)
    } catch (err) {
      setToast({ show: true, msg: '❌ Error creating contract' })
      setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="app" style={{ padding: '24px', maxWidth: 600, margin: '0 auto' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
        <h2 style={{ fontSize: 22 }}>✍️ New Contract</h2>
        <button className="nav-btn" onClick={() => navigate(-1)}>← Back</button>
      </div>
      <form onSubmit={handleSubmit}>
        <div className="card" style={{ border: '1px solid var(--purple-light)', marginBottom: 20 }}>
          <div className="card-title" style={{ color: 'var(--purple-dark)' }}>Party Details</div>
          <div style={{ display: 'grid', gap: 12 }}>
            <div>
              <label>Rider Name</label>
              <input value={form.riderName} onChange={e => setForm({ ...form, riderName: e.target.value })} required placeholder="e.g. Juma Bakari" />
            </div>
            <div>
              <label>Owner Name</label>
              <input value={form.ownerName} onChange={e => setForm({ ...form, ownerName: e.target.value })} required placeholder="e.g. Hassan Mwinyi" />
            </div>
          </div>
        </div>
        <div className="card" style={{ border: '1px solid var(--purple-light)', marginBottom: 20 }}>
          <div className="card-title" style={{ color: 'var(--purple-dark)' }}>Motorcycle & Payment</div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div>
              <label>Motorcycle Model</label>
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
            <div>
              <label>{form.paymentType} Amount (TSh)</label>
              <input type="number" value={form.dailyAmount} onChange={e => setForm({ ...form, dailyAmount: e.target.value })} required />
            </div>
            <div>
              <label>Total Amount (TSh)</label>
              <input type="number" value={form.totalAmount} onChange={e => setForm({ ...form, totalAmount: e.target.value })} required />
            </div>
            <div>
              <label>Start Date</label>
              <input type="date" value={form.startDate} onChange={e => setForm({ ...form, startDate: e.target.value })} required />
            </div>
            <div>
              <label>End Date</label>
              <input type="date" value={form.endDate} onChange={e => setForm({ ...form, endDate: e.target.value })} required />
            </div>
          </div>
        </div>
        <div className="card" style={{ border: '1px solid var(--purple-light)', marginBottom: 20 }}>
          <div className="card-title" style={{ color: 'var(--purple-dark)' }}>Digital Agreement</div>
          <div>
            <label>Agreement Terms</label>
            <textarea rows={6} value={form.agreementText} onChange={e => setForm({ ...form, agreementText: e.target.value })} style={{ width: '100%', padding: 12, border: '1px solid var(--border)', borderRadius: 8, fontFamily: 'inherit', fontSize: 13 }} />
          </div>
        </div>
        <button className="btn-primary" type="submit" disabled={submitting} style={{ width: '100%', padding: 16, fontSize: 16 }}>
          {submitting ? 'Creating...' : '✅ Create Digital Contract'}
        </button>
        <p className="text-muted" style={{ textAlign: 'center', marginTop: 12, fontSize: 12 }}>
          By creating this contract, both parties agree to the terms above.
        </p>
      </form>
      <Toast visible={toast.show} message={toast.msg} />
    </div>
  )
}
