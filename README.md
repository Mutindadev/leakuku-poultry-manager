# LeaKuku Poultry Manager  
Smart Poultry Management for Modern Farmers

🔗 **Demo:** https://drive.google.com/drive/folders/1WiMP5VcU7LZiBW6nSxtbb2Vy1YuLl6En?usp=drive_link  
🔗 **Pitch Deck:** https://gamma.app/docs/Lea-Kuku-Smart-Poultry-Management-for-Modern-Farmers-18fiibevsmgkggf  
🔗 **Repository:** https://github.com/Mutindadev/leakuku-poultry-manager

---

## 📌 Overview

LeaKuku Poultry Manager is a smart digital farm management system designed to help poultry farmers run modern, efficient, and data-driven operations.  
It automates record-keeping, flock management, expenses, feeding cycles, mortality tracking, and productivity analytics — all through a clean, friendly, mobile-ready interface.

This project is built with **clean architecture**, structured state management, a scalable data layer, and modern UI/UX patterns so even beginner farmers can navigate it easily.

---

## ✨ Key Features

### **1. Authentication**
- Secure email & password sign-in
- Token-based session management
- Error-handling for all edge cases
- Logged-in state persistence

---

### **2. Dashboard**
A snapshot of the entire farm:
- Current flock count  
- Total eggs collected  
- Feed usage  
- Expenses overview  
- Quick-action buttons  

Designed for fast decision-making.

---

### **3. Flock Management**
- Add new birds (breed, age, weight)  
- Track growth progress  
- Separate active, sold, and deceased birds  
- Auto-generated stats

---

### **4. Feeding & Production Records**
- Feeding logs (amount, cost, date)  
- Egg production logs  
- Automatic calculations  
- Visual summaries

---

### **5. Expenses & Revenue Tracking**
- Add expenses with category and cost  
- Track income from egg sales or sold birds  
- Financial summaries for decision-making

---

## 🖥️ UI / UX Principles

- Clean, minimal farmer-friendly interface  
- High contrast + readable typography  
- Intuitive page-to-page flow  
- Consistent card components  
- Mobile-first layout  
- Clear icons and labels  
- Zero-confusion navigation  

---

## ⚙️ Architecture

This project follows **Clean Architecture**:

```plaintext
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

---


---

## 🧠 State Management

- Provider / Riverpod style structure  
- Clear separation of `state`, `notifiers`, and `services`  
- Consistent async state handling  
- Error, loading, and success states implemented cleanly

---

## 🗃️ Data Layer

- Local storage for offline capability  
- Cloud-ready repo structure  
- Typed models  
- Safe JSON conversions  
- Centralized repositories  

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










