import Dexie from 'dexie'

const db = new Dexie('MyMkatabaDB')

db.version(1).stores({
  users: '++id, name, email, role, phone, nationalId, status, region, createdBy',
  contracts: '++id, contractId, ownerId, riderId, ownerName, riderName, startDate, endDate, paymentType, dailyAmount, totalAmount, paidAmount, motorcycle, status, agreementText, signedDate, region, gracePeriod',
  payments: '++id, contractId, riderId, ownerId, date, amount, method, status',
  notifications: '++id, userId, type, title, desc, time, read',
  settings: '++id, key',
  locations: '++id, riderId, riderName, lat, lng, timestamp',
})

export async function seedDatabase() {
  const userCount = await db.users.count()
  if (userCount > 0) return

  await db.users.bulkAdd([
    { id: 1, name: 'John Msumi', email: 'john@mkataba.tz', password: '1234', role: 'rider', initials: 'JM', phone: '+255 712 345 678', nationalId: '19900123456789', status: 'Active', region: 'Arusha' },
    { id: 2, name: 'Alinda Rwegasila', email: 'alinda@mkataba.tz', password: '1234', role: 'owner', initials: 'AR', phone: '+255 754 111 222', nationalId: '19880123456789', status: 'Active', region: 'Arusha' },
    { id: 3, name: 'Super Creator', email: 'admin@mkataba.tz', password: '1234', role: 'admin', initials: 'SC', phone: '+255 800 000 000', nationalId: '19850123456789', status: 'Active', region: 'Arusha' },
    { id: 4, name: 'Peter Njau', email: 'peter@mkataba.tz', password: '1234', role: 'rider', initials: 'PJ', phone: '+255 765 432 100', nationalId: '19920123456789', status: 'Overdue', region: 'Arusha' },
    { id: 5, name: 'David Kesi', email: 'david@mkataba.tz', password: '1234', role: 'rider', initials: 'DK', phone: '+255 688 999 001', nationalId: '19930123456789', status: 'Pending', region: 'Arusha', firstLogin: true },
    { id: 6, name: 'Ali Rashid', email: 'ali@mkataba.tz', password: '1234', role: 'rider', initials: 'AR', phone: '+255 688 777 002', nationalId: '19940123456789', status: 'Active', region: 'Moshi' },
    { id: 7, name: 'Grace Mbeki', email: 'grace@mkataba.tz', password: '1234', role: 'owner', initials: 'GM', phone: '+255 700 202 303', nationalId: '19870123456789', status: 'Active', region: 'Dar es Salaam' },
  ])

  await db.contracts.bulkAdd([
    { contractId: 'MK-0847', ownerId: 2, riderId: 1, ownerName: 'Alinda Rwegasila', riderName: 'John Msumi', startDate: 'May 14, 2026', endDate: 'Aug 12, 2026', paymentType: 'Daily', dailyAmount: 1500, totalAmount: 135000, paidAmount: 87000, motorcycle: 'T 245 ABZ', status: 'Active', region: 'Arusha', gracePeriod: 3, agreementText: 'I, John Msumi, agree to make daily payments of TSh 1,500 to Alinda Rwegasila as per the contract terms. Failure to make payment within 3 days will result in account suspension. This agreement was accepted digitally.', signedDate: 'May 14, 2026 at 9:42 AM' },
    { contractId: 'MK-0831', ownerId: 2, riderId: 4, ownerName: 'Alinda Rwegasila', riderName: 'Peter Njau', startDate: 'Apr 1, 2026', endDate: 'Jul 29, 2026', paymentType: 'Daily', dailyAmount: 1500, totalAmount: 135000, paidAmount: 51000, motorcycle: 'T 246 BCY', status: 'Overdue', region: 'Arusha', gracePeriod: 3, agreementText: '', signedDate: 'Apr 1, 2026 at 8:00 AM' },
    { contractId: 'MK-0819', ownerId: 2, riderId: 5, ownerName: 'Alinda Rwegasila', riderName: 'David Kesi', startDate: 'Mar 20, 2026', endDate: 'Jul 17, 2026', paymentType: 'Weekly', dailyAmount: 10500, totalAmount: 120000, paidAmount: 66000, motorcycle: 'T 247 CDZ', status: 'Pending', region: 'Arusha', gracePeriod: 3, agreementText: '', signedDate: '' },
    { contractId: 'MK-0802', ownerId: 2, riderId: 6, ownerName: 'Alinda Rwegasila', riderName: 'Ali Rashid', startDate: 'Mar 1, 2026', endDate: 'Jun 28, 2026', paymentType: 'Daily', dailyAmount: 1500, totalAmount: 135000, paidAmount: 118000, motorcycle: 'T 248 DEF', status: 'Active', region: 'Moshi', gracePeriod: 3, agreementText: '', signedDate: 'Mar 1, 2026 at 7:30 AM' },
    { contractId: 'MK-0790', ownerId: 7, riderId: 0, ownerName: 'Grace Mbeki', riderName: 'Salim Omar', startDate: 'Feb 15, 2026', endDate: 'Jun 15, 2026', paymentType: 'Daily', dailyAmount: 1500, totalAmount: 150000, paidAmount: 120000, motorcycle: 'T 249 GHI', status: 'Active', region: 'Dar es Salaam', gracePeriod: 3, agreementText: '', signedDate: '' },
  ])

  await db.payments.bulkAdd([
    ...generatePayments('MK-0847', 2, 1, 'John Msumi', 'Alinda Rwegasila', 1500, 'Jun 12, 2026', 'paid', 'M-Pesa'),
    ...generatePayments('MK-0847', 2, 1, 'John Msumi', 'Alinda Rwegasila', 1500, 'Jun 11, 2026', 'paid', 'M-Pesa'),
    ...generatePayments('MK-0847', 2, 1, 'John Msumi', 'Alinda Rwegasila', 1500, 'Jun 10, 2026', 'missed', '—'),
    ...generatePayments('MK-0847', 2, 1, 'John Msumi', 'Alinda Rwegasila', 1500, 'Jun 9, 2026', 'paid', 'M-Pesa'),
    ...generatePayments('MK-0847', 2, 1, 'John Msumi', 'Alinda Rwegasila', 1500, 'Jun 8, 2026', 'paid', 'M-Pesa'),
    ...generatePayments('MK-0847', 2, 1, 'John Msumi', 'Alinda Rwegasila', 1500, 'Jun 7, 2026', 'paid', 'M-Pesa'),
    ...generatePayments('MK-0847', 2, 1, 'John Msumi', 'Alinda Rwegasila', 1500, 'Jun 6, 2026', 'pending', '—'),
    ...generatePayments('MK-0847', 2, 1, 'John Msumi', 'Alinda Rwegasila', 1500, 'Jun 5, 2026', 'paid', 'M-Pesa'),
    ...generatePayments('MK-0831', 2, 4, 'Peter Njau', 'Alinda Rwegasila', 1500, 'Jun 12, 2026', 'missed', '—'),
    ...generatePayments('MK-0819', 2, 5, 'David Kesi', 'Alinda Rwegasila', 10500, 'Jun 12, 2026', 'pending', '—'),
    ...generatePayments('MK-0790', 7, 0, 'Salim Omar', 'Grace Mbeki', 1500, 'Jun 12, 2026', 'paid', 'Tigo Pesa'),
  ])

  await db.notifications.bulkAdd([
    { userId: 1, type: 'missed', title: 'Missed Payment – June 10', desc: 'You missed your daily payment of TSh 1,500. Please pay immediately to avoid suspension.', time: '2 days ago', read: false },
    { userId: 1, type: 'paid', title: 'Payment Confirmed – June 11', desc: 'Your payment of TSh 1,500 was received. Thank you!', time: 'Yesterday', read: false },
    { userId: 1, type: 'reminder', title: 'Upcoming Reminder – Tomorrow', desc: "Don't forget your daily payment of TSh 1,500 due tomorrow, June 13.", time: 'Today', read: false },
    { userId: 1, type: 'expiry', title: 'Contract Expiry – 61 Days Left', desc: 'Your contract expires on August 12, 2026. Talk to your owner about renewal.', time: 'Today', read: false },
    { userId: 2, type: 'danger', title: 'Peter Njau – 4 Missed Payments', desc: "Peter has missed 4 consecutive payments. Consider suspending the account.", time: 'Today at 8:00 AM', read: false },
    { userId: 2, type: 'warning', title: 'Ali Rashid – Contract Expiring in 11 Days', desc: 'Contract #MK-0802 expires June 28, 2026.', time: 'Today at 7:30 AM', read: false },
    { userId: 2, type: 'warning', title: 'David Kesi – Weekly Payment Due', desc: "David's weekly payment of TSh 10,500 is due today.", time: 'Today at 6:00 AM', read: false },
  ])

  await db.settings.bulkAdd([
    { id: 1, key: 'reminderDays', value: '1' },
    { id: 2, key: 'missedBlockLimit', value: '3' },
    { id: 3, key: 'expiryAlertDays', value: '14' },
    { id: 4, key: 'defaultDailyRate', value: '1500' },
    { id: 5, key: 'paymentMethods', value: 'M-Pesa, Tigo Pesa, Airtel Money' },
  ])
}

function generatePayments(contractId, ownerId, riderId, riderName, ownerName, amount, date, status, method) {
  return [{
    contractId,
    riderId,
    ownerId,
    riderName,
    ownerName,
    date,
    amount,
    method,
    status,
  }]
}

export async function getUserByEmail(email) {
  return db.users.where('email').equals((email || '').trim().toLowerCase()).first()
}

export async function getUserById(id) {
  return db.users.where('id').equals(id).first()
}

export async function getUsersByRole(role) {
  return db.users.where('role').equals(role).toArray()
}

export async function getAllUsers() {
  return db.users.toArray()
}

export async function getContractForRider(riderId) {
  return db.contracts.where('riderId').equals(riderId).first()
}

export async function getContractsForOwner(ownerId) {
  return db.contracts.where('ownerId').equals(ownerId).toArray()
}

export async function getAllContracts() {
  return db.contracts.toArray()
}

export async function getPaymentsForRider(riderId) {
  return db.payments.where('riderId').equals(riderId).reverse().sortBy('id')
}

export async function getPaymentsForOwner(ownerId) {
  return db.payments.where('ownerId').equals(ownerId).reverse().sortBy('id')
}

export async function getAllPayments() {
  return db.payments.reverse().toArray()
}

export async function getNotificationsForUser(userId) {
  return db.notifications.where('userId').equals(userId).toArray()
}

export async function getSettings() {
  const all = await db.settings.toArray()
  const map = {}
  all.forEach(s => { map[s.key] = s.value })
  return map
}

export async function createUser(data) {
  const lastUser = await db.users.orderBy('id').last()
  const defaultPwd = '1234'
  const email = (data.email || `${data.name.toLowerCase().replace(/\s+/g, '.')}@mkataba.tz`).trim().toLowerCase()
  const existing = await getUserByEmail(email)
  if (existing) {
    throw new Error('Email already exists')
  }
  const user = {
    id: (lastUser?.id || 0) + 1,
    name: data.name,
    email,
    password: defaultPwd,
    role: data.role || 'rider',
    initials: data.name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2),
    phone: data.phone || '',
    nationalId: data.nationalId || '',
    status: 'Active',
    region: data.region || 'Arusha',
    createdBy: data.createdBy || 0,
    firstLogin: data.role === 'owner' ? false : true,
  }
  await db.users.add(user)
  return { ...user, defaultPwd }
}

export async function createContract(data) {
  const count = await db.contracts.count() + 1
  const contractId = `MK-${String(2026000 + count).slice(-4)}`
  const contract = {
    contractId,
    ownerId: data.ownerId,
    riderId: Number(data.riderId) || 0,
    ownerName: data.ownerName,
    riderName: data.riderName,
    startDate: data.startDate,
    endDate: data.endDate,
    paymentType: data.paymentType,
    dailyAmount: Number(data.dailyAmount),
    totalAmount: Number(data.totalAmount),
    paidAmount: 0,
    motorcycle: data.motorcycle.toUpperCase(),
    status: 'Pending',
    region: data.region || 'Arusha',
    gracePeriod: Number(data.gracePeriod) || 3,
    agreementText: data.agreementText || '',
    signedDate: '',
  }
  await db.contracts.add(contract)
  return contract
}

export async function makePayment(riderId, customAmount) {
  const contract = await db.contracts.where('riderId').equals(riderId).first()
  if (!contract) return null
  const amount = Number(customAmount) || contract.dailyAmount
  const newPaid = contract.paidAmount + amount
  const today = new Date()
  const dateStr = today.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })

  const isShort = amount < contract.dailyAmount
  const status = isShort ? 'partial' : 'paid'

  await db.transaction('rw', db.contracts, db.payments, db.notifications, async () => {
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

    if (isShort) {
      const shortAmount = contract.dailyAmount - amount
      await db.notifications.add({
        userId: riderId, type: 'missed',
        title: `Partial Payment — ${dateStr}`,
        desc: `You paid TSh ${amount.toLocaleString()} today. Short by TSh ${shortAmount.toLocaleString()}.`,
        time: 'Just now', read: false,
      })
      await db.notifications.add({
        userId: contract.ownerId, type: 'missed',
        title: `Partial Payment from ${contract.riderName}`,
        desc: `${contract.riderName} paid TSh ${amount.toLocaleString()} (short). Owes TSh ${shortAmount.toLocaleString()}.`,
        time: 'Just now', read: false,
      })
    } else {
      await db.notifications.add({
        userId: riderId, type: 'paid',
        title: `Payment Confirmed – ${dateStr}`,
        desc: `Your payment of TSh ${amount.toLocaleString()} was received. Thank you!`,
        time: 'Just now', read: false,
      })
      await db.notifications.add({
        userId: contract.ownerId, type: 'paid',
        title: `Payment from ${contract.riderName}`,
        desc: `${contract.riderName} paid TSh ${amount.toLocaleString()} for ${contract.contractId}.`,
        time: 'Just now', read: false,
      })
    }
  })

  return { contractId: contract.contractId, amount, status, dateStr }
}

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

export async function deleteRider(riderId) {
  await db.transaction('rw', db.users, db.contracts, db.notifications, async () => {
    await db.users.update(riderId, { status: 'Disabled' })
    await db.contracts.where('riderId').equals(riderId).modify({ status: 'Disabled' })
    await db.notifications.add({
      userId: riderId,
      type: 'danger',
      title: 'Account Disabled',
      desc: 'Your access has been disabled after contract termination. Payment history remains saved.',
      time: 'Just now',
      read: false,
    })
  })
}

export async function blockRider(riderId) {
  await db.users.update(riderId, { status: 'Blocked' })
  await db.contracts.where('riderId').equals(riderId).modify({ status: 'Blocked' })
  await db.notifications.add({
    userId: riderId, type: 'missed',
    title: 'Account Suspended',
    desc: 'Your account has been blocked due to missed payments.',
    time: 'Just now', read: false,
  })
}

export async function unblockRider(riderId) {
  await db.users.update(riderId, { status: 'Active' })
  await db.contracts.where('riderId').equals(riderId).modify({ status: 'Active' })
  await db.notifications.add({
    userId: riderId,
    type: 'paid',
    title: 'Account Active',
    desc: 'Your account has been reactivated.',
    time: 'Just now',
    read: false,
  })
}

export async function renewContract(contractId) {
  const contract = await db.contracts.where('contractId').equals(contractId).first()
  if (!contract) return
  const start = new Date()
  const end = new Date(start)
  end.setDate(end.getDate() + 90)
  await db.transaction('rw', db.contracts, db.payments, async () => {
    await db.contracts.update(contract.id, {
      status: 'Active',
      startDate: start.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }),
      endDate: end.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }),
      paidAmount: 0,
    })
    await db.payments.where('contractId').equals(contractId).modify({ status: 'archived' })
  })
}

export async function updateUser(id, data) {
  return db.users.update(id, data)
}

export async function getRidersForOwner(ownerId) {
  const contracts = await db.contracts.where('ownerId').equals(ownerId).toArray()
  const riderIds = [...new Set(contracts.map(c => c.riderId).filter(id => id > 0))]
  const createdRiders = await db.users.where('createdBy').equals(ownerId).toArray()
  const riders = []
  const seen = new Set()
  for (const id of riderIds) {
    const rider = await db.users.where('id').equals(id).first()
    if (rider && !seen.has(rider.id)) {
      riders.push(rider)
      seen.add(rider.id)
    }
  }
  for (const rider of createdRiders) {
    if (!seen.has(rider.id)) {
      riders.push(rider)
      seen.add(rider.id)
    }
  }
  return riders
}

export async function updateContractStatus(contractId, status) {
  const contract = await db.contracts.where('contractId').equals(contractId).first()
  if (contract) {
    await db.contracts.update(contract.id, { status })
  }
}

export async function getAllNotifications() {
  return db.notifications.toArray()
}

export async function resetDatabase() {
  await db.delete()
  db.version(1).stores({
  users: '++id, name, email, role, phone, nationalId, status, region, createdBy',
    contracts: '++id, contractId, ownerId, riderId, ownerName, riderName, startDate, endDate, paymentType, dailyAmount, totalAmount, paidAmount, motorcycle, status, agreementText, signedDate, region, gracePeriod',
    payments: '++id, contractId, riderId, ownerId, date, amount, method, status',
    notifications: '++id, userId, type, title, desc, time, read',
    settings: '++id, key',
    locations: '++id, riderId, riderName, lat, lng, timestamp',
  })
  await seedDatabase()
}

export async function acceptContract(contractId, riderId) {
  const contract = await db.contracts.where('contractId').equals(contractId).first()
  if (!contract) return
  const now = new Date().toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) + ` at ${new Date().toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })}`
  await db.contracts.update(contract.id, { status: 'Accepted', signedDate: now })

  await db.notifications.bulkAdd([
    { userId: riderId, type: 'paid', title: 'Contract Accepted', desc: `You accepted contract #${contractId}. Change your password to continue.`, time: 'Just now', read: false },
    { userId: contract.ownerId, type: 'warning', title: `Rider Accepted – #${contractId}`, desc: `${contract.riderName} accepted the contract. Confirm to activate.`, time: 'Just now', read: false },
  ])
}

export async function rejectContract(contractId, riderId) {
  const contract = await db.contracts.where('contractId').equals(contractId).first()
  if (!contract) return
  await db.contracts.update(contract.id, { status: 'Rejected' })

  await db.notifications.bulkAdd([
    { userId: riderId, type: 'missed', title: 'Contract Rejected', desc: `You rejected contract #${contractId}.`, time: 'Just now', read: false },
    { userId: contract.ownerId, type: 'danger', title: `Rider Rejected – #${contractId}`, desc: `${contract.riderName} rejected the contract.`, time: 'Just now', read: false },
  ])
}

export async function ownerConfirmContract(contractId) {
  const contract = await db.contracts.where('contractId').equals(contractId).first()
  if (!contract) return
  await db.contracts.update(contract.id, { status: 'Active' })

  await db.notifications.bulkAdd([
    { userId: contract.riderId, type: 'paid', title: 'Contract Active!', desc: `Your contract #${contractId} is now active. Start making payments.`, time: 'Just now', read: false },
    { userId: contract.ownerId, type: 'paid', title: 'Contract Confirmed', desc: `Contract #${contractId} with ${contract.riderName} is now active.`, time: 'Just now', read: false },
  ])
}

export async function changePassword(userId, newPassword) {
  await db.users.update(userId, { password: newPassword, firstLogin: false })
}

export async function saveSettings(settings) {
  for (const [key, value] of Object.entries(settings)) {
    const existing = await db.settings.where('key').equals(key).first()
    if (existing) {
      await db.settings.update(existing.id, { value })
    } else {
      await db.settings.add({ key, value })
    }
  }
}

export function isPaidStatus(status) {
  return ['paid', 'partial', 'completed', 'confirmed'].includes(String(status || '').toLowerCase())
}

export async function getPaymentsForContract(contractId) {
  return db.payments.where('contractId').equals(contractId).reverse().sortBy('id')
}

export async function getActivePaymentsForRider(riderId) {
  const contract = await getContractForRider(riderId)
  if (!contract) return []
  const payments = await getPaymentsForContract(contract.contractId)
  return payments.filter(p => p.status !== 'archived')
}

export async function getActivePaymentsForOwner(ownerId) {
  const contracts = await getContractsForOwner(ownerId)
  const payments = await getPaymentsForOwner(ownerId)
  return payments.filter(p => p.status !== 'archived')
}

export async function getPaymentsSummaryForOwner(ownerId) {
  const payments = await getPaymentsForOwner(ownerId)
  const active = payments.filter(p => p.status !== 'archived')
  const totalPaid = active.filter(p => isPaidStatus(p.status)).reduce((s, p) => s + p.amount, 0)
  const totalPending = active.filter(p => p.status === 'pending' || p.status === 'missed').reduce((s, p) => s + p.amount, 0)
  const totalShort = active.filter(p => p.status === 'partial').reduce((s, p) => s + p.amount, 0)
  return { totalPaid, totalPending, totalShort, count: active.length }
}

export async function refreshExistingDemoData() {
  const owner = await getUserById(2)
  if (owner && owner.name !== 'Alinda Rwegasila') {
    await db.users.update(2, {
      name: 'Alinda Rwegasila',
      email: 'alinda@mkataba.tz',
      initials: 'AR',
    })
    await db.contracts.where('ownerId').equals(2).modify({ ownerName: 'Alinda Rwegasila' })
    await db.payments.where('ownerId').equals(2).modify({ ownerName: 'Alinda Rwegasila' })
  }

  const contracts = await db.contracts.toArray()
  for (const contract of contracts) {
    await db.payments.where('riderId').equals(contract.riderId).modify(payment => {
      if (payment.ownerId === contract.ownerId) {
        payment.contractId = contract.contractId
        payment.riderName = contract.riderName
        payment.ownerName = contract.ownerName
      }
    })
  }
}

export default db
