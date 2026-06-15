import Dexie from 'dexie'

const db = new Dexie('MyMkatabaDB')

db.version(1).stores({
  users: '++id, name, email, role, phone, nationalId, status, region',
  contracts: '++id, contractId, ownerId, riderId, ownerName, riderName, startDate, endDate, paymentType, dailyAmount, totalAmount, paidAmount, motorcycle, status, agreementText, signedDate, region, gracePeriod',
  payments: '++id, contractId, riderId, ownerId, date, amount, method, status',
  notifications: '++id, userId, type, title, desc, time, read',
  settings: '++id, key',
})

export async function seedDatabase() {
  const userCount = await db.users.count()
  if (userCount > 0) return

  await db.users.bulkAdd([
    { id: 1, name: 'John Msumi', email: 'john@mkataba.tz', password: '1234', role: 'rider', initials: 'JM', phone: '+255 712 345 678', nationalId: '19900123456789', status: 'Active', region: 'Arusha' },
    { id: 2, name: 'Hassan Mwangi', email: 'hassan@mkataba.tz', password: '1234', role: 'owner', initials: 'HM', phone: '+255 754 111 222', nationalId: '19880123456789', status: 'Active', region: 'Arusha' },
    { id: 3, name: 'Super Creator', email: 'admin@mkataba.tz', password: '1234', role: 'admin', initials: 'SC', phone: '+255 800 000 000', nationalId: '19850123456789', status: 'Active', region: 'Arusha' },
    { id: 4, name: 'Peter Njau', email: 'peter@mkataba.tz', password: '1234', role: 'rider', initials: 'PJ', phone: '+255 765 432 100', nationalId: '19920123456789', status: 'Overdue', region: 'Arusha' },
    { id: 5, name: 'David Kesi', email: 'david@mkataba.tz', password: '1234', role: 'rider', initials: 'DK', phone: '+255 688 999 001', nationalId: '19930123456789', status: 'Pending', region: 'Arusha' },
    { id: 6, name: 'Ali Rashid', email: 'ali@mkataba.tz', password: '1234', role: 'rider', initials: 'AR', phone: '+255 688 777 002', nationalId: '19940123456789', status: 'Active', region: 'Moshi' },
    { id: 7, name: 'Grace Mbeki', email: 'grace@mkataba.tz', password: '1234', role: 'owner', initials: 'GM', phone: '+255 700 202 303', nationalId: '19870123456789', status: 'Active', region: 'Dar es Salaam' },
  ])

  await db.contracts.bulkAdd([
    { contractId: 'MK-0847', ownerId: 2, riderId: 1, ownerName: 'Hassan Mwangi', riderName: 'John Msumi', startDate: 'May 14, 2026', endDate: 'Aug 12, 2026', paymentType: 'Daily', dailyAmount: 1500, totalAmount: 135000, paidAmount: 87000, motorcycle: 'T 245 ABZ', status: 'Active', region: 'Arusha', gracePeriod: 3, agreementText: 'I, John Msumi, agree to make daily payments of TSh 1,500 to Hassan Mwangi as per the contract terms. Failure to make payment within 3 days will result in account suspension. This agreement was accepted digitally.', signedDate: 'May 14, 2026 at 9:42 AM' },
    { contractId: 'MK-0831', ownerId: 2, riderId: 4, ownerName: 'Hassan Mwangi', riderName: 'Peter Njau', startDate: 'Apr 1, 2026', endDate: 'Jul 29, 2026', paymentType: 'Daily', dailyAmount: 1500, totalAmount: 135000, paidAmount: 51000, motorcycle: 'T 246 BCY', status: 'Overdue', region: 'Arusha', gracePeriod: 3, agreementText: '', signedDate: 'Apr 1, 2026 at 8:00 AM' },
    { contractId: 'MK-0819', ownerId: 2, riderId: 5, ownerName: 'Hassan Mwangi', riderName: 'David Kesi', startDate: 'Mar 20, 2026', endDate: 'Jul 17, 2026', paymentType: 'Weekly', dailyAmount: 10500, totalAmount: 120000, paidAmount: 66000, motorcycle: 'T 247 CDZ', status: 'Pending', region: 'Arusha', gracePeriod: 3, agreementText: '', signedDate: '' },
    { contractId: 'MK-0802', ownerId: 2, riderId: 6, ownerName: 'Hassan Mwangi', riderName: 'Ali Rashid', startDate: 'Mar 1, 2026', endDate: 'Jun 28, 2026', paymentType: 'Daily', dailyAmount: 1500, totalAmount: 135000, paidAmount: 118000, motorcycle: 'T 248 DEF', status: 'Active', region: 'Moshi', gracePeriod: 3, agreementText: '', signedDate: 'Mar 1, 2026 at 7:30 AM' },
    { contractId: 'MK-0790', ownerId: 7, riderId: 0, ownerName: 'Grace Mbeki', riderName: 'Salim Omar', startDate: 'Feb 15, 2026', endDate: 'Jun 15, 2026', paymentType: 'Daily', dailyAmount: 1500, totalAmount: 150000, paidAmount: 120000, motorcycle: 'T 249 GHI', status: 'Active', region: 'Dar es Salaam', gracePeriod: 3, agreementText: '', signedDate: '' },
  ])

  await db.payments.bulkAdd([
    ...generatePayments(2, 1, 'John Msumi', 'Hassan Mwangi', 58, 'Jun 12, 2026', 'paid', 'M-Pesa'),
    ...generatePayments(2, 1, 'John Msumi', 'Hassan Mwangi', 57, 'Jun 11, 2026', 'paid', 'M-Pesa'),
    ...generatePayments(2, 1, 'John Msumi', 'Hassan Mwangi', 56, 'Jun 10, 2026', 'missed', '—'),
    ...generatePayments(2, 1, 'John Msumi', 'Hassan Mwangi', 55, 'Jun 9, 2026', 'paid', 'M-Pesa'),
    ...generatePayments(2, 1, 'John Msumi', 'Hassan Mwangi', 54, 'Jun 8, 2026', 'paid', 'M-Pesa'),
    ...generatePayments(2, 1, 'John Msumi', 'Hassan Mwangi', 53, 'Jun 7, 2026', 'paid', 'M-Pesa'),
    ...generatePayments(2, 1, 'John Msumi', 'Hassan Mwangi', 52, 'Jun 6, 2026', 'pending', '—'),
    ...generatePayments(2, 1, 'John Msumi', 'Hassan Mwangi', 51, 'Jun 5, 2026', 'paid', 'M-Pesa'),
    ...generatePayments(2, 4, 'Peter Njau', 'Hassan Mwangi', 0, 'Jun 12, 2026', 'missed', '—'),
    ...generatePayments(2, 5, 'David Kesi', 'Hassan Mwangi', 0, 'Jun 12, 2026', 'pending', '—'),
    ...generatePayments(7, 0, 'Salim Omar', 'Grace Mbeki', 0, 'Jun 12, 2026', 'paid', 'Tigo Pesa'),
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

function generatePayments(ownerId, riderId, riderName, ownerName, count, date, status, method) {
  const results = []
  const nums = typeof count === 'number' ? [count] : []
  const dates = typeof date === 'string' ? [date] : date
  const statuses = typeof status === 'string' ? [status] : status
  const methods = typeof method === 'string' ? [method] : method

  if (nums.length === 0 && dates.length === 0) return []

  const numPayments = nums.length || dates.length
  for (let i = 0; i < numPayments; i++) {
    results.push({
      contractId: 'MK-0847',
      riderId, ownerId,
      riderName, ownerName,
      date: dates[i % dates.length],
      amount: 1500,
      method: methods[i % methods.length],
      status: statuses[i % statuses.length],
    })
  }
  return results
}

export async function getUserByEmail(email) {
  return db.users.where('email').equals(email).first()
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
  const maxId = await db.users.count()
  const user = {
    id: maxId + 1,
    name: data.name,
    email: data.email || `${data.name.toLowerCase().replace(/\s+/g, '.')}@mkataba.tz`,
    password: '1234',
    role: 'rider',
    initials: data.name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2),
    phone: data.phone || '',
    nationalId: data.nationalId || '',
    status: 'Active',
    region: data.region || 'Arusha',
    createdBy: data.createdBy || 0,
  }
  await db.users.add(user)
  return user
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

export async function makePayment(riderId) {
  const contract = await db.contracts.where('riderId').equals(riderId).first()
  if (!contract) return null
  const newPaid = contract.paidAmount + contract.dailyAmount
  const today = new Date()
  const dateStr = today.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
  const status = newPaid >= contract.totalAmount ? 'paid' : 'paid'

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
    amount: contract.dailyAmount,
    method: 'M-Pesa',
    status: 'paid',
  }
  await db.payments.add(payment)

  await db.notifications.add({
    userId: riderId, type: 'paid',
    title: `Payment Confirmed – ${dateStr}`,
    desc: `Your payment of TSh ${contract.dailyAmount.toLocaleString()} was received. Thank you!`,
    time: 'Just now', read: false,
  })

  return payment
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

export async function renewContract(contractId) {
  const contract = await db.contracts.where('contractId').equals(contractId).first()
  if (!contract) return
  const start = new Date()
  const end = new Date(start)
  end.setDate(end.getDate() + 90)
  await db.contracts.update(contract.id, {
    status: 'Active',
    startDate: start.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }),
    endDate: end.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }),
    paidAmount: 0,
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
  })
  await seedDatabase()
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

export default db
