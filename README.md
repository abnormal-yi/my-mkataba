<div align="center">

# 🏍️ My Mkataba

### **Boda Boda Contract Management App**

![License](https://img.shields.io/badge/License-Private-red?style=flat)
![Version](https://img.shields.io/badge/Version-1.0.0-green?style=flat)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat&logo=android)
![PRs](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat)

---

**Track contracts, payments, GPS routes, and rider compliance for motorcycle taxi businesses.**

[![Download APK](https://img.shields.io/badge/📥_Download_APK-MyMkataba.apk-6C3FC5?style=for-the-badge&logo=android)](https://github.com/abnormal-yi/my-mkataba/releases/download/v1.0.0/MyMkataba.apk)

</div>

---

## 📱 App Preview

<div align="center">

<img src="screenshots/screen1.jpeg" width="45%" />
&nbsp;&nbsp;
<img src="screenshots/screen2.jpeg" width="45%" />

</div>

---

## ✨ Features

<div align="center">

| 📋 **Contract Management** | 💰 **Payment Tracking** | 📍 **GPS Monitoring** |
|:--------------------------:|:-----------------------:|:---------------------:|
| Create and track daily rental contracts between boda owners and riders | Log daily payments (full/partial/short), auto-calculate balances | Track rider routes during work hours via device GPS |

| 👤 **Role-Based Dashboards** | 🔔 **Real-time Notifications** | 📄 **PDF Export** |
|:----------------------------:|:------------------------------:|:-----------------:|
| Separate views for Admin, Owner, and Rider | Payment alerts and contract status updates | Download payment receipts directly from mobile |

</div>

---

## 🛠️ Tech Stack

<div align="center">

![React](https://img.shields.io/badge/React-19-61DAFB?style=for-the-badge&logo=react&logoColor=black)
![Vite](https://img.shields.io/badge/Vite-6-646CFF?style=for-the-badge&logo=vite)
![Capacitor](https://img.shields.io/badge/Capacitor-8-119EFF?style=for-the-badge&logo=capacitor)
![Dexie.js](https://img.shields.io/badge/Dexie.js-IndexedDB-FF6B6B?style=for-the-badge)
![JavaScript](https://img.shields.io/badge/JavaScript-ES6-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)
![CSS3](https://img.shields.io/badge/CSS3-Custom-1572B6?style=for-the-badge&logo=css3&logoColor=black)

</div>

| Layer | Technology | Description |
|-------|-----------|-------------|
| **Frontend** | React 19 + Vite | Modern UI with fast HMR |
| **Mobile** | Capacitor 8 | Cross-platform native builds |
| **Database** | Dexie.js (IndexedDB) | Client-side database, works offline |
| **Styling** | Custom CSS | Hand-crafted, no framework bloat |
| **State** | React Context | Lightweight state management |
| **Routing** | React Router | SPA navigation |
| **Android** | Gradle + JDK 17+ | Native Android build |

---

## 👥 Roles

<div align="center">

| Role | Access Level | Icon |
|------|-------------|:----:|
| **Admin** | Full system control — manage owners, riders, view all data | 🔑 |
| **Owner** | Manage their riders, track payments, view GPS history | 🏢 |
| **Rider** | View assigned contract, submit daily payments, see history | 🏍️ |

</div>

---

## 🚀 Getting Started

### Prerequisites

```bash
# Install Node.js (v18+)
# Install npm
# Install Android Studio (for APK build)
```

### Web (Development)

```bash
# Clone the repository
git clone https://github.com/abnormal-yi/my-mkataba.git

# Navigate to project
cd my-mkataba

# Install dependencies
npm install

# Start development server
npm run dev
```

### Android Build

```bash
# Build for production
npm run build

# Sync with Capacitor
npx cap sync android

# Build Android APK
cd android
./gradlew assembleDebug
```

### Default Login

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@mymkataba.com | 1234 |
| Owner | Create your own account | — |

---

## 📁 Project Structure

```
my-mkataba/
├── src/
│   ├── components/     # Reusable UI (Badge, Layout)
│   ├── context/        # Auth context (AuthContext)
│   ├── data/           # Database layer (Dexie.js)
│   ├── pages/          # Route pages (Login, Dashboards)
│   ├── App.jsx         # Router setup
│   ├── main.jsx        # Entry point + back button handler
│   └── index.css       # Global styles
├── android/            # Capacitor Android project
├── screenshots/        # App screenshots
├── package.json        # Dependencies
└── README.md           # This file
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

**Private** — Abnormal Tech Solutions

---

## 📥 Download APK

<div align="center">

[![Download APK](https://img.shields.io/badge/📥_Download_MyMkataba.apk-6C3FC5?style=for-the-badge&logo=android)](https://github.com/abnormal-yi/my-mkataba/releases/download/v1.0.0/MyMkataba.apk)

> **Note:** You may need to enable "Install from unknown sources" in your Android settings.

</div>

---

<div align="center">

**Built with ❤️ for Boda Boda businesses in Tanzania**

![GitHub stars](https://img.shields.io/github/stars/abnormal-yi/my-mkataba?style=social)
![GitHub forks](https://img.shields.io/github/forks/abnormal-yi/my-mkataba?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/abnormal-yi/my-mkataba?style=social)

</div>
