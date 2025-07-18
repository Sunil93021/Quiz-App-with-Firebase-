# 📱 Quiz App with Firebase

This is a Flutter-based Quiz App using Firebase as its backend. It supports real-time quiz hosting, a leaderboard, timer-based questions, user authentication, result tracking, and more.

---

## 🚀 Features

* 🔐 Firebase Authentication (Email-based login)
* 📆 Firebase Firestore for quizzes, results, and leaderboard
* ⏱ Timer per question with auto-submit
* ✅ Instant feedback on correct/incorrect answers
* 📊 Final score and percentage display
* 🏆 Separate leaderboard for each quiz topic
* 📜 Past results history with timestamps
* ✨ Clean UI and responsive layout

---

## 📁 Project Structure

```
lib/
├── main.dart
├── LoginPage.dart
├── HomePage.dart
├── HostQuiz.dart
├── QuizPage.dart
├── result_page.dart
├── leaderboard_page.dart
└── PastResultsPage.dart
```

---

## 💪 Setup Instructions

### 1. 🔧 Prerequisites

* ✅ Flutter SDK
* ✅ Firebase account and project
* ✅ Java 11 or higher
* ✅ Android Studio or VS Code with Flutter plugin

---

### 2. 🧩 Clone the Repository

```bash
git clone https://github.com/Sunil93021/Quiz-App-with-Firebase-.git
cd Quiz-App-with-Firebase-
```

### 3. 🔥 Configure Firebase

1. Go to Firebase Console
2. Create a new project
3. Add an Android app and download `google-services.json`
4. Place `google-services.json` inside `android/app/`
5. Enable Email/Password in Firebase Authentication
6. Enable Cloud Firestore in Build > Firestore Database

---

### 4. 🧱 Firestore Structure

```
quizzes/
  └── <quizName>/
      └── questions/
          └── <auto-id>
              ├── question: string
              ├── options: list<string>
              └── correctIndex: int

results/
  └── <userId>/
      └── quizzes/
          └── <auto-id>
              ├── quizName: string
              ├── score: int
              ├── total: int
              └── timestamp: Timestamp

leaderboards/
  └── <quizName>/
      └── entries/
          └── <auto-id>
              ├── userId: string
              ├── score: int
              └── timestamp: Timestamp
```

---

### 5. ▶️ Run the App

```bash
flutter pub get
flutter run
```

---

### 🔐 Firestore Rules (For Testing Only)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

---
