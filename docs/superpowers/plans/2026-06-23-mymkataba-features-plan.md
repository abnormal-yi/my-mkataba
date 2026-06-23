# My Mkataba Feature Expansion — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add partial payments (custom amount + dual notifications), GPS tracking via browser geolocation, profile photo uploads, admin rider deletion, and per-rider payment history.

**Architecture:** All data stays in IndexedDB (Dexie.js) — offline-first. GPS uses browser Geolocation API with Leaflet/OpenStreetMap for map rendering. Photos use Capacitor Camera plugin with base64 storage. All changes are within existing React components, the Dexie db layer, and the Layout nav config.

**Tech Stack:** React 18, Vite 6, Capacitor 8, Dexie.js 4, Leaflet (CDN), @capacitor/camera

---

### Task 1: Database Schema + Helper Functions

**Files:**
- Modify: `src/data/db.js`

- [ ] **Step 1: Add `locations` table to Dexie schema and `photo` field to users**

```js
// In db.js, update the version 1 stores block to:
db.version(1).stores({
  users: '++id, name, email, role, phone, nationalId, status, region, createdBy',
  contracts: '++id, contractId, ownerId, riderId, ownerName, riderName, startDate, endDate, paymentType, dailyAmount, totalAmount, paidAmount, motorcycle, status, agreementText, signedDate, region, gracePeriod',
  payments: '++id, contractId, riderId, ownerId, date, amount, method, status',
  notifications: '++id, userId, type, title, desc, time, read',
  settings: '++id, key',
  locations: '++id, riderId, riderName, lat, lng, timestamp',
})
```

- [ ] **Step 2: Add `saveLocation()` and `getLastLocation()` functions**

```js
export async function saveLocation(riderId, riderName, lat, lng) {
  const location = {
    riderId, riderName, lat, lng,
    timestamp: new Date().toISOString(),
  }
  await db.locations.add(location)
  return location
}

export async function getLastLocation(riderId) {
  return db.locations.where('riderId').equals(riderId).reverse().first()
}

export async function getAllLastLocations() {
  const all = await db.locations.toArray()
  const seen = {}
  all.forEach(loc => {
    if (!seen[loc.riderId] || loc.timestamp > seen[loc.riderId].timestamp) {
      seen[loc.riderId] = loc
    }
  })
  return Object.values(seen)
}
```

- [ ] **Step 3: Add `deleteRider(riderId)` function**

```js
export async function deleteRider(riderId) {
  await db.users.where('id').equals(riderId).delete()
  await db.contracts.where('riderId').equals(riderId).delete()
  await db.payments.where('riderId').equals(riderId).delete()
  await db.notifications.where('userId').equals(riderId).delete()
  await db.locations.where('riderId').equals(riderId).delete()
}
```

- [ ] **Step 4: Update `makePayment()` to accept custom amount**

```js
export async function makePayment(riderId, customAmount) {
  const contract = await db.contracts.where('riderId').equals(riderId).first()
  if (!contract) return null
  const amount = customAmount || contract.dailyAmount
  const newPaid = contract.paidAmount + amount
  const today = new Date()
  const dateStr = today.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })

  const isShort = amount < contract.dailyAmount
  const status = isShort ? 'partial' : 'paid'

  await db.contracts.update(contract.id, {
    paidAmount: newPaid,
    status: newPaid >= contract.totalAmount ? 'Completed' : contract.status,
  })

  const payment = {
    contractId: contract.contractId,
    riderId, ownerId: contract.ownerId,
    riderName: contract.riderName,
    ownerName: contract.ownerName,
    date: dateStr,
    amount,
    method: 'M-Pesa',
    status,
  }
  await db.payments.add(payment)

  // Rider notification
  if (isShort) {
    const shortAmount = contract.dailyAmount - amount
    await db.notifications.add({
      userId: riderId, type: 'missed',
      title: `Partial Payment — ${dateStr}`,
      desc: `Umefaulu kulipa TSh ${amount.toLocaleString()} kwa siku ya leo. Kiasi pungufu TSh ${shortAmount.toLocaleString()}.`,
      time: 'Just now', read: false,
    })
    await db.notifications.add({
      userId: contract.ownerId, type: 'missed',
      title: `Partial Payment from ${contract.riderName}`,
      desc: `${contract.riderName} amelipa TSh ${amount.toLocaleString()} (pungufu). Anadaiwa TSh ${shortAmount.toLocaleString()}.`,
      time: 'Just now', read: false,
    })
  } else {
    await db.notifications.add({
      userId: riderId, type: 'paid',
      title: `Payment Confirmed – ${dateStr}`,
      desc: `Your payment of TSh ${amount.toLocaleString()} was received. Thank you!`,
      time: 'Just now', read: false,
    })
  }

  return payment
}
```

- [ ] **Step 5: Add `getPaymentsForRiderById(riderId)` for admin use**

```js
export async function getPaymentsForRiderById(riderId) {
  return db.payments.where('riderId').equals(riderId).reverse().sortBy('id')
}
```

- [ ] **Step 6: Commit**

```bash
git add src/data/db.js
git commit -m "feat(db): add locations table, partial payment support, deleteRider, photo field"
```

---

### Task 2: Rider — Partial Payment UI

**Files:**
- Modify: `src/pages/RiderDashboard.jsx`

- [ ] **Step 1: Add custom amount input state and modal**

Add after `const [newPwd, setNewPwd] = useState('')`:
```js
const [showPayModal, setShowPayModal] = useState(false)
const [payAmount, setPayAmount] = useState(contract?.dailyAmount || 1500)
```

- [ ] **Step 2: Replace the existing `handlePay` with custom amount version**

```js
const handlePay = async () => {
  if (!payAmount || payAmount < 100) {
    setToast({ show: true, msg: '⚠️ Kiasi lazima kiwe angalau TSh 100' })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    return
  }
  const maxAmount = contract?.dailyAmount || payAmount
  const actualAmount = Math.min(payAmount, maxAmount)
  await makePayment(user.id, actualAmount)
  const isShort = actualAmount < maxAmount
  setToast({
    show: true,
    msg: isShort
      ? `✅ Umelipa TSh ${actualAmount.toLocaleString()} (pungufu). Owner amejulishwa.`
      : `✅ Payment of TSh ${actualAmount.toLocaleString()} sent!`
  })
  setTimeout(() => setToast({ show: false, msg: '' }), 3000)
  setShowPayModal(false)
  setPayAmount(contract?.dailyAmount || 1500)
  loadData()
}
```

- [ ] **Step 3: Replace the "Pay Now" button with modal trigger**

Replace the existing pay button line:
```jsx
<button className="btn-primary" style={{ marginBottom: 20 }} onClick={() => { setPayAmount(contract?.dailyAmount || 1500); setShowPayModal(true) }}>
  💳 Pay Now via M-Pesa
</button>
```

- [ ] **Step 4: Add payment modal before closing `</>` of overview tab**

```jsx
{showPayModal && (
  <div className="modal-overlay" onClick={() => setShowPayModal(false)}>
    <div className="modal-card" onClick={e => e.stopPropagation()} style={{ maxWidth: 360 }}>
      <div className="modal-icon">💳</div>
      <div className="modal-title">Make Payment</div>
      <div className="modal-body">
        <p className="text-muted" style={{ marginBottom: 12 }}>
          Daily amount: <strong>TSh {contract?.dailyAmount?.toLocaleString()}</strong>
        </p>
        <label>Amount to Pay (TSh)</label>
        <input type="number" value={payAmount} onChange={e => setPayAmount(Number(e.target.value))}
               min={100} max={contract?.dailyAmount || 1500} />
        {payAmount < (contract?.dailyAmount || 1500) && (
          <p style={{ color: 'var(--red)', fontSize: 12, marginTop: 4 }}>
            ⚠️ Utalipa kiasi pungufu. Owner atajulishwa.
          </p>
        )}
        <button className="btn-primary" style={{ background: 'var(--green)', marginTop: 12 }} onClick={handlePay}>
          ✅ Pay TSh {payAmount.toLocaleString()}
        </button>
        <button className="btn-primary" style={{ background: 'transparent', color: 'var(--muted)', boxShadow: 'none', marginTop: 4 }}
                onClick={() => setShowPayModal(false)}>
          Cancel
        </button>
      </div>
    </div>
  </div>
)}
```

- [ ] **Step 5: Commit**

```bash
git add src/pages/RiderDashboard.jsx
git commit -m "feat(rider): add partial payment modal with custom amount"
```

---

### Task 3: Rider — GPS Location Sharing

**Files:**
- Modify: `src/pages/RiderDashboard.jsx`
- Modify: `src/components/Layout.jsx`

- [ ] **Step 1: Add location tab case to RiderDashboard**

Add a new case in `tabContent()` switching:
```js
case 'location':
  return (
    <>
      <div className="page-title">Share Location</div>
      <div className="page-sub">Let your owner know where you are</div>
      <div className="card" style={{ textAlign: 'center', padding: 40 }}>
        <div style={{ fontSize: 48, marginBottom: 16 }}>📍</div>
        <p style={{ marginBottom: 20, color: 'var(--muted)' }}>
          Press the button below to share your current location with your owner.
        </p>
        <button className="btn-primary" style={{ background: 'var(--purple)' }} onClick={handleShareLocation}>
          📍 Share My Location
        </button>
        {lastShared && (
          <p style={{ color: 'var(--green)', fontSize: 12, marginTop: 12 }}>
            ✓ Last shared: {lastShared}
          </p>
        )}
      </div>
    </>
  )
```

- [ ] **Step 2: Add handler and state for location**

Add state:
```js
const [lastShared, setLastShared] = useState('')
```

Add handler:
```js
const handleShareLocation = () => {
  if (!navigator.geolocation) {
    setToast({ show: true, msg: '⚠️ GPS haipo kwenye kifaa hiki' })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    return
  }
  navigator.geolocation.getCurrentPosition(
    async (pos) => {
      await saveLocation(user.id, user.name, pos.coords.latitude, pos.coords.longitude)
      setLastShared(new Date().toLocaleTimeString())
      setToast({ show: true, msg: '✅ Location shared successfully!' })
      setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    },
    () => {
      setToast({ show: true, msg: '⚠️ Unable to get location. Check GPS settings.' })
      setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    },
    { enableHighAccuracy: true, timeout: 10000 }
  )
}
```

- [ ] **Step 3: Add "location" import for saveLocation and update exports reference**

Add to import line:
```js
import { ..., saveLocation, getLastLocation } from '../data/db'
```

Add after loadData to load last shared time:
```js
const loadLastLocation = async () => {
  const last = await getLastLocation(user?.id)
  if (last) setLastShared(new Date(last.timestamp).toLocaleTimeString())
}
useEffect(() => { loadLastLocation() }, [user])
```

- [ ] **Step 4: Add "location" tab to rider Layout config**

In `src/components/Layout.jsx`, add to rider tabs:
```js
{ key: 'location', label: 'Location', icon: MapPin },
```

Insert between `'payments'` and `'notifications'`:
```js
rider: {
  role: 'Rider Portal',
  tabs: [
    { key: 'overview', label: 'Overview', icon: LayoutDashboard },
    { key: 'contract', label: 'My Contract', icon: FileText },
    { key: 'payments', label: 'Payments', icon: CreditCard },
    { key: 'location', label: 'Location', icon: MapPin },
    { key: 'notifications', label: 'Notifications', icon: Bell },
    { key: 'profile', label: 'Profile', icon: User },
  ]
},
```

- [ ] **Step 5: Commit**

```bash
git add src/pages/RiderDashboard.jsx src/components/Layout.jsx
git commit -m "feat(rider): add GPS location sharing tab"
```

---

### Task 4: Owner — Rider GPS Location View (Leaflet Map)

**Files:**
- Modify: `src/pages/OwnerDashboard.jsx`
- Modify: `src/components/Layout.jsx`

- [ ] **Step 1: Add state and data loading for locations**

Add to existing loadData:
```js
const [riderLocations, setRiderLocations] = useState([])
const [mapRider, setMapRider] = useState(null)
```

Update loadData to include locations:
```js
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
  const locs = await getAllLastLocations()
  setRiderLocations(locs)
}
```

- [ ] **Step 2: Add "locations" tab case to OwnerDashboard**

```js
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
                <p className="text-muted" style={{ fontSize: 12 }}>
                  {loc
                    ? `📍 ${loc.lat.toFixed(4)}, ${loc.lng.toFixed(4)} • ${new Date(loc.timestamp).toLocaleString()}`
                    : '📍 Hakuna location iliyosharewa'}
                </p>
              </div>
              {loc && (
                <button className="nav-btn" style={{ background: 'var(--purple-bg)', color: 'var(--purple)' }}
                        onClick={() => setMapRider({ ...loc, name: r.name })}>
                  View Map
                </button>
              )}
            </div>
          )
        })}
      </div>

      {mapRider && (
        <div className="modal-overlay" onClick={() => setMapRider(null)}>
          <div className="modal-card" onClick={e => e.stopPropagation()} style={{ maxWidth: 500, width: '90%' }}>
            <div className="modal-title" style={{ fontSize: 16 }}>
              {mapRider.name} — Location
            </div>
            <div className="modal-body" style={{ padding: 0 }}>
              <div id="map" style={{ width: '100%', height: 300, borderRadius: 8 }} />
              <div style={{ padding: 16 }}>
                <p className="text-muted">Latitude: {mapRider.lat}</p>
                <p className="text-muted">Longitude: {mapRider.lng}</p>
                <p className="text-muted">Time: {new Date(mapRider.timestamp).toLocaleString()}</p>
                <a href={`https://www.openstreetmap.org/?mlat=${mapRider.lat}&mlon=${mapRider.lng}&zoom=15`}
                   target="_blank" rel="noopener noreferrer"
                   style={{ color: 'var(--purple)', fontWeight: 600, fontSize: 13 }}>
                  Open in OpenStreetMap →
                </a>
              </div>
            </div>
            <button className="btn-primary" style={{ margin: 16 }} onClick={() => setMapRider(null)}>
              Close
            </button>
          </div>
        </div>
      )}
    </>
  )
```

- [ ] **Step 3: Add Leaflet CSS and JS to index.html**

In `index.html`, add inside `<head>`:
```html
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
```

- [ ] **Step 4: Add map initialization effect when mapRider changes**

Add to OwnerDashboard after the other useEffect:
```js
useEffect(() => {
  if (!mapRider) return
  const timer = setTimeout(() => {
    const el = document.getElementById('map')
    if (!el || el._leaflet_map) return
    const map = L.map('map').setView([mapRider.lat, mapRider.lng], 15)
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map)
    L.marker([mapRider.lat, mapRider.lng]).addTo(map)
    el._leaflet_map = true
  }, 200)
  return () => clearTimeout(timer)
}, [mapRider])
```

Add import at top:
```js
import { ..., getAllLastLocations } from '../data/db'
```

- [ ] **Step 5: Add "locations" tab to owner Layout config**

In `src/components/Layout.jsx`, add to owner tabs:
```js
{ key: 'locations', label: 'Locations', icon: MapPin },
```

Insert between `'payments'` and `'alerts'`:
```js
owner: {
  role: 'Owner Portal',
  tabs: [
    { key: 'overview', label: 'Dashboard', icon: LayoutDashboard },
    { key: 'riders', label: 'My Riders', icon: Users },
    { key: 'contracts', label: 'Contracts', icon: FileText },
    { key: 'payments', label: 'Payments', icon: CreditCard },
    { key: 'locations', label: 'Locations', icon: MapPin },
    { key: 'alerts', label: 'Alerts', icon: Bell },
  ]
},
```

- [ ] **Step 6: Commit**

```bash
git add src/pages/OwnerDashboard.jsx src/components/Layout.jsx index.html
git commit -m "feat(owner): add rider GPS location view with Leaflet map"
```

---

### Task 5: Rider — Profile Photo Upload

**Files:**
- Modify: `src/pages/RiderDashboard.jsx`

- [ ] **Step 1: Add photo upload button and handler**

Update the profile photo section in the `'profile'` tab case:

Replace the avatar div:
```jsx
<div style={{ width: 64, height: 64, borderRadius: '50%', overflow: 'hidden', position: 'relative',
              background: 'linear-gradient(135deg,#6C3FC5,#A78BFA)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
  {user?.photo ? (
    <img src={user.photo} alt={user?.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
  ) : (
    <span style={{ color: '#fff', fontSize: 24, fontWeight: 800 }}>{user?.initials}</span>
  )}
</div>
```

After the avatar, add upload button:
```jsx
<button className="nav-btn" style={{ marginTop: 8, fontSize: 12 }} onClick={handleUploadPhoto}>
  📷 Change Photo
</button>
```

- [ ] **Step 2: Add photo upload handler**

```js
import { Camera } from '@capacitor/camera'

const handleUploadPhoto = async () => {
  try {
    const image = await Camera.pickImages({
      limit: 1,
      quality: 50,
      width: 300,
      height: 300,
    })
    if (image.photos.length > 0) {
      const photoData = image.photos[0].dataUrl || `data:image/jpeg;base64,${image.photos[0].base64String}`
      await updateUser(user.id, { photo: photoData })
      updateUser({ photo: photoData })
      setToast({ show: true, msg: '✅ Photo updated!' })
      setTimeout(() => setToast({ show: false, msg: '' }), 3000)
    }
  } catch (e) {
    setToast({ show: true, msg: '⚠️ Could not access camera/gallery' })
    setTimeout(() => setToast({ show: false, msg: '' }), 3000)
  }
}
```

Also update the sidebar avatar in `Layout.jsx` to show photo:
In `src/components/Layout.jsx`, find line 76:
```jsx
<div className="s-avatar">{user?.initials}</div>
```
Replace with:
```jsx
<div className="s-avatar" style={user?.photo ? { padding: 0, overflow: 'hidden' } : {}}>
  {user?.photo ? (
    <img src={user.photo} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
  ) : user?.initials}
</div>
```

- [ ] **Step 3: Install Capacitor Camera plugin**

```bash
npm install @capacitor/camera@latest
```

- [ ] **Step 4: Add Camera import to RiderDashboard**

Add to import at top:
```js
import { Camera } from '@capacitor/camera'
```

- [ ] **Step 5: Commit**

```bash
git add src/pages/RiderDashboard.jsx src/components/Layout.jsx package.json package-lock.json
git commit -m "feat(rider): add profile photo upload with Capacitor Camera"
```

---

### Task 6: Admin — Delete Rider

**Files:**
- Modify: `src/pages/AdminDashboard.jsx`
- Modify: `src/data/db.js` (already done in Task 1)

- [ ] **Step 1: Add delete handler with confirmation**

```js
const [confirmDelete, setConfirmDelete] = useState(null)
```

```js
const handleDeleteRider = async (userId) => {
  await deleteRider(userId)
  setConfirmDelete(null)
  setToast({ show: true, msg: `🗑️ Rider deleted permanently!` })
  setTimeout(() => setToast({ show: false, msg: '' }), 3000)
  loadData()
}
```

- [ ] **Step 2: Add Delete column to users table (only for riders)**

Update the users table rows to include a Delete button for riders:

Replace the Action column content:
```jsx
<Badge status={u.status || 'active'} />,
<div style={{ display: 'flex', gap: 4 }}>
  <button className="nav-btn" style={{ background: 'var(--red-bg)', color: 'var(--red)' }}
          onClick={() => handleBlockUser(u.id)}>Block</button>
  {u.role === 'rider' && (
    <button className="nav-btn" style={{ background: '#FEE2E2', color: '#DC2626' }}
            onClick={() => setConfirmDelete(u)}>Delete</button>
  )}
</div>
```

- [ ] **Step 3: Add confirmation modal**

```jsx
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
```

- [ ] **Step 4: Add import for deleteRider**

```js
import { ..., deleteRider } from '../data/db'
```

- [ ] **Step 5: Commit**

```bash
git add src/pages/AdminDashboard.jsx
git commit -m "feat(admin): add delete rider with confirmation modal and cascading cleanup"
```

---

### Task 7: Admin — Per-Rider Payment History

**Files:**
- Modify: `src/pages/AdminDashboard.jsx`
- Modify: `src/components/Layout.jsx`

- [ ] **Step 1: Add payment tab and tryLogin handler for any rider**

Add state:
```js
const [selectedRider, setSelectedRider] = useState(null)
const [selectedRiderPayments, setSelectedRiderPayments] = useState([])
```

Add effect to load payments when rider selected:
```js
useEffect(() => {
  if (!selectedRider) return
  getPaymentsForRiderById(selectedRider.id).then(setSelectedRiderPayments)
}, [selectedRider])
```

- [ ] **Step 2: Add "payments" tab case to AdminDashboard**

```js
case 'payments': {
  const riders = users.filter(u => u.role === 'rider')
  const rider = selectedRider || riders[0]
  const riderContract = contracts.find(c => c.riderId === rider?.id)
  const totalPaid = selectedRiderPayments.filter(p => p.status === 'paid' || p.status === 'partial').reduce((s, p) => s + p.amount, 0)

  return (
    <>
      <div className="page-title">Rider Payments</div>
      <div className="page-sub">View payment history per rider</div>

      <div className="card" style={{ marginBottom: 16 }}>
        <label>Select Rider</label>
        <select value={rider?.id || ''} onChange={e => {
          const r = users.find(u => u.id === Number(e.target.value))
          setSelectedRider(r || null)
        }}>
          {riders.map(r => (
            <option key={r.id} value={r.id}>{r.name} — {r.email}</option>
          ))}
        </select>
      </div>

      {rider && (
        <>
          <div className="card" style={{ marginBottom: 16 }}>
            <div className="card-title">{rider.name}</div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
              <div><p className="text-muted" style={{ fontSize: 12 }}>Email</p><p className="fw700">{rider.email}</p></div>
              <div><p className="text-muted" style={{ fontSize: 12 }}>Phone</p><p className="fw700">{rider.phone || '—'}</p></div>
              <div><p className="text-muted" style={{ fontSize: 12 }}>Status</p><p><Badge status={rider.status} /></p></div>
              <div><p className="text-muted" style={{ fontSize: 12 }}>Contract</p><p className="fw700">{riderContract?.contractId || '—'}</p></div>
              <div><p className="text-muted" style={{ fontSize: 12 }}>Total Paid</p><p className="fw700" style={{ color: 'var(--green)' }}>TSh {totalPaid.toLocaleString()}</p></div>
              <div><p className="text-muted" style={{ fontSize: 12 }}>Balance</p><p className="fw700" style={{ color: 'var(--red)' }}>
                TSh {riderContract ? (riderContract.totalAmount - totalPaid).toLocaleString() : '—'}
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
```

- [ ] **Step 3: Add import for getPaymentsForRiderById**

```js
import { ..., getPaymentsForRiderById } from '../data/db'
```

- [ ] **Step 4: Add "payments" tab to admin Layout config**

In `src/components/Layout.jsx`, add to admin tabs:
```js
{ key: 'payments', label: 'Payments', icon: CreditCard },
```

Insert between `'contracts'` and `'reports'`:
```js
admin: {
  role: 'Admin Panel',
  tabs: [
    { key: 'overview', label: 'Overview', icon: LayoutDashboard },
    { key: 'users', label: 'All Users', icon: Users },
    { key: 'contracts', label: 'Contracts', icon: FileText },
    { key: 'payments', label: 'Payments', icon: CreditCard },
    { key: 'reports', label: 'Reports', icon: MapPin },
    { key: 'settings', label: 'Settings', icon: Settings },
  ]
},
```

- [ ] **Step 5: Commit**

```bash
git add src/pages/AdminDashboard.jsx src/components/Layout.jsx
git commit -m "feat(admin): add per-rider payment history tab with dropdown selector"
```

---

### Task 8: Verify build succeeds

**Files:** None

- [ ] **Step 1: Install any new dependencies**

```bash
npm install
```

- [ ] **Step 2: Build the project**

```bash
npm run build
```

Expected: Build succeeds with no errors.

- [ ] **Step 3: Commit any remaining changes**

```bash
git add -A
git commit -m "chore: finalize feature implementation"
git push origin main
```
