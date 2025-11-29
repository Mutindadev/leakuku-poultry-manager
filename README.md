# LeaKuku Poultry Manager  
Smart Poultry Management for Modern Farmers

🔗 **Demo:** [Link](https://drive.google.com/drive/folders/1WiMP5VcU7LZiBW6nSxtbb2Vy1YuLl6En?usp=drive_link)  
🔗 **Pitch Deck:** [Link](https://gamma.app/docs/Lea-Kuku-Smart-Poultry-Management-for-Modern-Farmers-18fiibevsmgkggf)  
🔗 **Repository:** [Link](https://github.com/Mutindadev/leakuku-poultry-manager)
🔗 **Repository:** adapted from older repo  
[Leakuku Repository](https://github.com/Mutindadev/leakuku)

---

## 📌 Overview

This project is built with **clean architecture**, structured state management, a scalable data layer, and modern UI/UX patterns so even beginner farmers can navigate it easily.
# 🐓 Leakuku Poultry Management System

Leakuku is a modern, full-stack poultry management system designed to help farmers automate, track, and optimize daily poultry operations.  
The platform provides tools for flock management, vaccination schedules, breed data, weekly plans, farm analytics, user authentication, and more — all wrapped in a clean, responsive UI.

---

## 🚀 Features Overview

### 🔐 **1. User Authentication**
- Full email/password authentication flow  
- Secure password hashing  
- Login, logout, and session handling  
- Role-based access supported for future expansion  
- Persistent authentication with automatic token refresh  
- Error-handled user validation

---

### 📊 **2. Dashboard Overview**
A clean, responsive dashboard showing:
- Summary statistics (Total birds, vaccinated birds, deaths, feed usage, etc.)  
- Charts & graphs (growth trends, vaccination progress, weekly plan completion)  
- Quick shortcuts to major modules  
- Activity logs for recent operations  
- Uses state management to auto-refresh data in real time

---

### 🐤 **3. Breed Management**
Allows farmers to manage different poultry breeds with:
- Breed name  
- Growth rate  
- Maturity timelines  
- Feed consumption patterns  
- Eggs-per-cycle data  
- Automatic syncing to breed-related operations (like vaccination variations)

---

### 💉 **4. Vaccination Module (New Feature Added)**
This module enables precise health tracking with:
- Vaccination name  
- Type of vaccine  
- Age administered  
- Repeat frequency  
- Next due date  
- Manufacturer or batch (optional)  
- Auto-reminders based on schedule  
- Dashboard integration showing vaccination completion percentage

Each vaccine record includes:

```bash
{
  "id": String,
  "name": String,
  "interval": int,
  "age": int
}
```
---

🗓️ 5. Weekly Plan System

Plan and track weekly farm routines:

Feeding schedule

Cleaning routines

Vaccination reminders

Weight monitoring

Health check tasks

Automatic completion status

Weekly analytics report

Each weekly task includes:

```bash
{
  "id": String,
  "weekNumber": int,
  "plan": List<String>,
  "isComplete": bool
}
```

---🧠 State Management

The system uses a clean and predictable state architecture:

✔️ Controllers / Notifiers

AuthController

BreedController

VaccinationController

WeeklyPlanController

DashboardController

✔️ Responsibilities

Handle logic outside UI

Fetch & sync data from server

Manage loading states

Provide global reactive updates

Prevent duplicated API calls

Maintain clean separation of concerns

---

## ⚙️ Architecture

This project follows **Clean Architecture**:

```
lib/
│
├── core/
│   ├── di.dart               # Dependency Injection
│   ├── error/                # Failure, exceptions
│   └── utils/                # Helpers, constants
│
├── data/
│   ├── models/               # Data models
│   ├── sources/              # Remote & local data sources
│   └── repositories/         # Repository implementations
│
├── domain/
│   ├── entities/             # Core business entities
│   ├── repositories/         # Abstract repos
│   └── usecases/             # Business logic
│
└── features/
    ├── auth/
    ├── dashboard/
    ├── flock/
    ├── feeding/
    ├── eggs/
    ├── expenses/
    └── common_widgets/       # Shared UI elements
```
---
🎯 API Service Highlights

Centralized request handling

Error-handled fetch, post, update, delete

Token-injected headers

Reusable endpoints

---

🎯 Model Handling

Each model includes:

JSON serialization

Validations

Conversion helpers

.g.dart generated files (via build_runner)

---

🎨 UI/UX Design Standards

Clean responsive layout

Consistent spacing, typography, and color theme

User-friendly forms with validation

High-contrast dashboard for readability

Icons + intuitive navigation

Lists, cards, modals, and structured pages

Pages include:

Login / Register

Dashboard

Breed Management

Vaccination Management

Weekly Plan Page

Settings

User Profile

---

## 🧭 Navigation Structure

- Splash → Auth → Dashboard  
- Dashboard → Flock → Records → Details  
- Bottom navigation for core workflows  
- Consistent route names

---

## 🧪 Testing Steps

1. Create account → Login  
2. Add flock → Check dashboard updates  
3. Add feeding log  
4. Add expense  
5. Track eggs  
6. Navigate through all pages  
7. Refresh app → Ensure state persists

---

Testing

Unit tests for controllers

JSON serialization tests

API integration tests

UI widget tests (optional)

---

🛠️ Installation & Setup

1. Clone Repository
```
git clone <your-repo-url>
cd leakuku
```

3. Install Dependencies
```
flutter pub get
```
5. Generate Model Files
Must run whenever models change.
```
dart run build_runner build --delete-conflicting-outputs
```

Or auto-watch:
```
dart run build_runner watch --delete-conflicting-outputs
```
4. Run App
```
flutter run
```

---

## 🚀 Future Enhancements

- Biometric authentication (FaceID/Fingerprint)  
- Farmer-to-farmer marketplace  
- Vaccination schedule automation  
- AI-based poultry health alerts  
- Export reports to Excel/PDF  
- Cloud sync for multi-device farms  

---

## 🧑‍💻 Author  
**Regina Mutinda (Mutindadev)**  
Passionate about building digital tools that empower African farmers with modern technology.
## 🙏 Acknowledgements

Special thanks to **Elton Mwangi** for assisting with independent software testing during development.  
His feedback helped refine user flows, identify bugs, and improve the overall stability of the application.

All design, architecture, and implementation decisions were completed independently by the project owner.


---

## 📜 License  
MIT License.










