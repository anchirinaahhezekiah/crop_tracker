--

Crop Tracker App

## Overview

The **Crop Tracker App** is a simple Flutter-based mobile application developed as part of the *Junior Flutter Developer Assignment*. It is designed to help farmers (or users) manage and track their crops by storing important details such as planting dates, harvest dates, and crop status.

This project demonstrates the use of **Flutter fundamentals**, **state management**, and **clean code organization** to build a functional prototype. The focus is on implementing the required features efficiently while maintaining readability and scalability.

---

## 🛠 Tech Stack

* **Flutter**: Latest stable version (3.x)
* **Dart**: Core programming language
* **State Management**: `Provider` (chosen for its simplicity and scalability for junior-level projects)
* **Local Storage**: `shared_preferences` (to persist data across app restarts)
* **UI Toolkit**: Material Design with basic theming (agriculture-inspired colors: green & brown)

---

## 📱 App Features

### 1. Home Screen (Crop List)

* Displays a list of crops with:

  * Name
  * Planting Date
  * Expected Harvest Date
  * Status (e.g., *Growing*, *Ready*, *Harvested*)
* Persists data using local storage.
* Includes a **Floating Action Button (FAB)** to add a new crop.

### 2. Add Crop Screen

* Form-based screen to input:

  * Crop Name
  * Planting Date (DatePicker)
  * Expected Harvest Date (DatePicker)
  * Notes (optional)
* Validates inputs (e.g., planting date must be before harvest date).

### 3. Crop Detail Screen

* Shows full details of a selected crop.
* Allows users to:

  * **Edit** crop details
  * **Delete** crop (with confirmation)
  * **Update Status** (e.g., mark as *Harvested*)

### 4. (Optional) Bonus Features

* Search/filter crops by name.
* Theming with agricultural color palette.
* Snackbar notifications for actions (add/edit/delete).

---

## 📂 Project Structure

```plaintext
lib/
│── main.dart                # App entry point
│
├── models/                  # Data models (Crop model)
├── providers/               # State management (CropProvider)
├── screens/                 # UI screens (Home, Add/Edit, Details)
├── widgets/                 # Reusable widgets (e.g., crop card)
├── utils/                   # Helpers (constants, themes)
```

---

## ⚙️ Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/your-username/crop-tracker.git
   cd crop-tracker
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the App**

   ```bash
   flutter run
   ```

> **Note**: You can run the app on either Android or iOS. This project was primarily tested on Android.

---

## 📌 State Management Choice

This project uses **Provider** because:

* It is simple to learn and implement (ideal for junior-level projects).
* It integrates well with Flutter’s widget tree.
* It allows separation of business logic from UI, making the codebase maintainable.

Alternatives like **Riverpod** or **Bloc** are more powerful but add complexity, which was avoided to keep the project lightweight.

---

## 🚧 Assumptions & Limitations

* No backend is used; all data is stored locally on the device.
* Mock data (5 crops) is used for demonstration.
* The app is a **prototype**, so advanced features like cloud sync or user accounts are not implemented.

---

## ✅ Testing

* A simple **unit test** is included to validate crop date logic (ensuring planting date is earlier than harvest date).

---

## 📸 Screenshots (Optional)

*(Include screenshots or a short demo video link here if available)*

---

## 📝 Evaluation Notes

This app demonstrates:

* **Flutter Mastery**: Navigation, forms, list views, state handling.
* **State Management**: Clear use of Provider for crop data updates.
* **Clean Code Structure**: Separation of models, providers, screens, and widgets.
* **Persistence**: Use of local storage for saving crops.

---

Would you like me to **make it shorter and recruiter-friendly** (like a portfolio-style README), or keep this **detailed version** (assignment-focused)?
