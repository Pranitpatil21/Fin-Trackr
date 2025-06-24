💰 FinTrackr
FinTrackr is a smart, modern personal finance tracker built using **Flutter** and **BLoC architecture**. It allows users to manage their income and expenses, analyze their spending through charts, back up transaction history, and export data in both **PDF** and **Excel** formats — all in a beautifully designed, responsive UI.

![FinTrackr Banner](assets/fintrackr_banner.png)

---

✨ Features

 🔐 Onboarding & User Manual
  - Intro screen with skip support for first-time users.
  
 📊 Dashboard with Insights
  - View income vs expense balances.
  - Interactive pie chart visualization of transactions.

 ➕ Add Transactions
  - Record income or expenses with title, amount, date, and category.

 🧾 Transaction History
  - Smooth listing of all your transactions.
  - Swipe to delete functionality.

  🔍 Filter Transactions
  - Filter by date or category.
  - Refined filtering experience with persistent UI.

 📤 Export Data
  - Export filtered or full transaction data as PDF or Excel.
  - Permissions handled smoothly on Android.

 🗃 Automatic Backup
  - On reset, all data is backed up locally.
  - View or clear backup history.

 🌓 Theme Toggle
  - Switch between Light and Dark modes anytime.

---

 🧱 Tech Stack

| Layer       | Technology            |
|-------------|------------------------|
| Language    | Dart + Flutter         |
| State Mgmt  | BLoC                   |
| Local DB    | Hive                   |
| Charts      | `fl_chart`             |
| Export      | `syncfusion_flutter_pdf`, `syncfusion_flutter_xlsio` |
| Permissions | `permission_handler`   |

---

📦 Folder Structure

 lib/
├── blocs/
│ └── transaction/
├── models/
├── screens/
│ ├── home_screen.dart
│ ├── add_transaction_screen.dart
│ ├── filter_screen.dart
│ ├── export_screen.dart
│ └── backup_history_screen.dart
├── widgets/
│ ├── transaction_tile.dart
│ ├── balance_card.dart
│ └── expense_chart.dart
└── main.dart


---

 📸 Screenshots

| Home | Add Transaction | Chart | Export |
|------|------------------|-------|--------|
| ![home](assets/screens/home.png) | ![add](assets/screens/add.png) | ![chart](assets/screens/chart.png) | ![export](assets/screens/export.png) |

---

 🛠️ How to Run

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/fintrackr.git
   cd fintrackr

2. Get dependencies:
    flutter pub get

3. Run the app:
     flutter run

Make sure you have Flutter installed: Flutter Setup


📂 Hive Setup :
  Hive is used to store transaction data and backup locally. The TransactionModel is already registered and initialized inside main.dart.
  
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter());
  await Hive.openBox<TransactionModel>('transactions');

🔐 Permissions :
  On Android (especially Android 11+), the app will request proper storage permissions before exporting to PDF/Excel.

📬 Contact

📧 Email: pranit.appdev@gmail.com

📱 Phone: +91-8668451914

📄 License
  This project is open source and available under the MIT License.

🚀 Future Scope

 Add categories with icons
 Monthly reports & budgeting
 Cloud sync (Firebase)
 Notification reminders

🙌 Special Thanks
 
  Huge thanks to:
   - Syncfusion for PDF/Excel packages
   - Hive for blazing fast local storage
   - The Flutter community



  
