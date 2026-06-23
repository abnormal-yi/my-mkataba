# My Mkataba — Feature Expansion Design

## Overview

Add partial payments, GPS tracking, profile photo uploads, rider deletion, and per-rider payment history to the existing My Mkataba Capacitor/React mobile app for Boda Boda contract management.

## Architecture

The app uses:
- **React 18** with Vite
- **Capacitor 8** for Android native features
- **Dexie.js (IndexedDB)** for offline-first local storage
- **react-router-dom** for navigation

All new features operate locally within IndexedDB (no backend server).

---

## Feature 1: Rider Partial Payment

### Behavior
- Rider presses **"Pay Now"** button on the overview tab.
- Instead of paying the full daily amount (TSh 1,500), a modal/text input appears allowing the rider to enter any custom amount (≥ TSh 100, ≤ daily amount).
- On submit:
  - The entered amount is added to `paidAmount` in the contract.
  - A new payment record is created with `status: 'partial'` if amount < dailyAmount, or `'paid'` if amount === dailyAmount.
  - A notification is created for the rider: *"Umefaulu kulipa TSh X kwa siku ya leo. Kiasi pungufu TSh Y."*
  - A notification is created for the owner: *"Rider X amelipa TSh Y (pungufu). Anadaiwa TSh Z."*
- If amount >= dailyAmount, treat as full payment (existing `'paid'` flow).

### Payment status values
- `'paid'` — full amount paid
- `'partial'` — partial amount paid
- `'missed'` — missed day
- `'pending'` — not yet paid

### Data changes
- `contracts.paidAmount`: increments by partial amount
- `payments.amount`: stores the actual amount paid (not fixed at dailyAmount)
- `notifications`: new notification for both rider and owner

---

## Feature 2: GPS Tracking

### Behavior — Rider Side
- New tab in rider Layout: **"Share Location"**
- Rider presses **"Share My Location"** button.
- App uses browser Geolocation API (`navigator.geolocation.getCurrentPosition`) to get latitude, longitude, and timestamp.
- Data is stored in a new `locations` table in IndexedDB:
  - `++id, riderId, riderName, lat, lng, timestamp`

### Behavior — Owner Side
- New tab in owner Layout: **"Rider Locations"**
- Shows a list of all riders with their most recent location.
- Riders without any location data show *"Hakuna location"*.
- Tapping a rider opens a Leaflet/OpenStreetMap map showing the rider's last known position.
- The map is displayed inline using a simple `<div id="map">` with the Leaflet CDN.

### Data changes
- New IndexedDB table: `locations`
- New owner tab: "Rider Locations"

---

## Feature 3: Rider Profile Photo Upload

### Behavior
- On the rider's **Profile** tab, add a "Change Photo" button next to the avatar.
- Tapping opens a native action sheet: *"Take Photo"* or *"Choose from Gallery"*.
- Uses Capacitor Camera plugin (`@capacitor/camera`) to capture/select image.
- Image is resized to max 200x200px and converted to base64 data URL.
- Stored in a new field `users.photo` (base64 string).
- The avatar display component checks for `photo` first; if present, renders `<img>`, else falls back to initials.

### Data changes
- `users.photo`: base64 string (nullable)
- Layout avatar component updated to show photo if available

---

## Feature 4: Owner Register Rider

### Current Status
- Already implemented in OwnerDashboard with `handleRegisterRider` and `createUser`.
- Rider gets default password "1234" and can login with their generated email.
- No changes needed for this feature.

---

## Feature 5: Admin Delete Rider

### Behavior
- On the Admin **Users** tab, a "Block" button already exists per user.
- Add a **"Delete"** button next to Block for rider users.
- Tapping Delete shows a confirmation dialog: *"Una uhakika unataka kumfuta rider huyu? Hatua hii haiwezi kutenduliwa."*
- On confirm:
  - Rider is removed from `users` table.
  - All contracts where `riderId === rider.id` are deleted.
  - All payments where `riderId === rider.id` are deleted.
  - All notifications where `userId === rider.id` are deleted.
- Function added to `db.js`: `deleteRider(riderId)`

### Data changes
- No new tables/fields.
- New function: `deleteRider(riderId)` in db.js.

---

## Feature 6: Admin Per-Rider Payment History

### Behavior
- New tab in Admin Layout: **"Payments"** (between Contracts and Reports).
- Top section: dropdown selector listing all riders (users with role 'rider').
- Below: rider summary — name, email, phone, contract ID, total paid, balance, status.
- Below: full payment history table for that rider — Date, Amount, Method, Status.
- Default selection: first rider in the list.

### Data changes
- No new tables/fields.
- New admin tab component rendering.

---

## IndexedDB Schema Changes

### New table: `locations`
```
locations: '++id, riderId, riderName, lat, lng, timestamp'
```

### Modified table: `users`
- Add optional field: `photo` (string — base64 data URL)

### Modified table: `payments`
- No schema change; `amount` already exists and will now hold custom amounts.

---

## Component Changes Summary

| Component | Changes |
|-----------|---------|
| `RiderDashboard.jsx` | Add custom amount input to payment flow; add "Share Location" tab; add photo upload to profile tab |
| `OwnerDashboard.jsx` | Add "Rider Locations" tab with Leaflet map |
| `AdminDashboard.jsx` | Add "Delete" button on users; add "Payments" tab with rider dropdown + payment history |
| `Layout.jsx` | Update nav tabs for rider (add "Location"), owner (add "Locations"), admin (add "Payments") |
| `db.js` | Add `locations` table; add `users.photo` field; add `deleteRider()`, `getLastLocation()`, `saveLocation()` functions; update `makePayment()` to accept custom amount |
| `RiderCard.jsx` / avatars | Show photo instead of initials when available |
