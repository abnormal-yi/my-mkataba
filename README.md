# My Mkataba

**Boda Boda Contract & Payment Management** – Digital contract management platform for Boda Boda owners and riders across Tanzania.

## Features

- **Multi-Role Access** – Rider, Boda Owner, and Admin dashboards
- **Contract Lifecycle** – Create, accept, reject, confirm contracts with digital signatures
- **First-Login Flow** – New riders accept terms and set password before accessing dashboard
- **Payment Tracking** – Daily/weekly payments via M-Pesa, Tigo Pesa, Airtel Money
- **Payment Calendar** – Color-coded calendar (green=paid, red=missed, yellow=pending)
- **Notifications** – Real-time alerts for contract actions, payments, and reminders
- **Offline-First** – All data stored locally with Dexie.js IndexedDB
- **Dark Purple Design** – Premium UI with Inter + Poppins typography

## Tech Stack

- **Frontend** – React 18 + Vite
- **Mobile** – Capacitor (Android APK)
- **Database** – Dexie.js (IndexedDB)
- **Icons** – Lucide React
- **Typography** – Inter (body), Poppins (headings)

## Getting Started

```bash
npm install
npm run dev
```

Open http://localhost:5173 in your browser.

### Demo Accounts

| Role   | Email                  | Password |
|--------|------------------------|----------|
| Rider  | john@mkataba.tz        | 1234     |
| Rider  | david@mkataba.tz       | 1234     |
| Owner  | hassan@mkataba.tz      | 1234     |
| Admin  | admin@mkataba.tz       | 1234     |

> David Kesi has `firstLogin: true` – login to experience the contract acceptance flow.

## Build APK

```bash
npm run build
npx cap sync
# Edit android/app/capacitor.build.gradle and
# android/capacitor-cordova-android-plugins/build.gradle
# Replace VERSION_21 with VERSION_17
cd android && ./gradlew assembleDebug
```

APK output: `android/app/build/outputs/apk/debug/app-debug.apk`

## Project Structure

```
src/
├── components/     # Reusable UI components
│   ├── Layout.jsx         # App shell with sidebar + bottom nav
│   ├── Logo.jsx           # Brand logo SVG
│   ├── StatCard.jsx       # Dashboard stat card
│   ├── Badge.jsx          # Status badge
│   ├── ProgressBar.jsx    # Payment progress bar
│   ├── DataTable.jsx      # Tabular data display
│   ├── CalendarGrid.jsx   # Monthly payment calendar
│   ├── NotificationItem.jsx
│   └── Toast.jsx
├── pages/          # Route pages
│   ├── SplashPage.jsx     # Role selection
│   ├── LoginPage.jsx      # Authentication
│   ├── RiderDashboard.jsx # First-login + rider portal
│   ├── OwnerDashboard.jsx # Owner portal
│   ├── AdminDashboard.jsx # Admin panel
│   ├── BlockedPage.jsx    # Blocked rider view
│   └── ContractFormPage.jsx
├── context/        # Auth state management
│   └── AuthContext.jsx
├── data/           # Database layer
│   └── db.js              # Dexie.js schema + CRUD + seeds
└── index.css       # Global styles
```

## License

MIT
