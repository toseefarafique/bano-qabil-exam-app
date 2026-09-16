# Bano Qabil Exam

### A Smart Flutter-Based Examination & Quiz Management Platform

Bano Qabil Exam is a Flutter-based examination and quiz management application designed to provide a complete digital platform for students, teachers, and exam controllers.

The application uses **Firebase Authentication, Cloud Firestore, and Firebase Storage** to provide role-based access and real-time data management.

## 👥 User Roles

### 🎓 Student

* Register and log in securely
* View available practice quizzes and official exams
* Attempt MCQs
* View results and scores
* Review answers
* View upcoming exams
* Manage profile information
* Receive notifications

### 👨‍🏫 Teacher

* Create and manage questions
* Build quizzes from the question bank
* Assign quizzes to students/classes
* View student attempts
* Manage quiz availability
* Control answer visibility
* Monitor student performance

### 🛡️ Exam Controller

* Create and publish official examinations
* Manage exam reports
* Publish examination results
* Control exam status
* Monitor examination activity
* Manage system-level examination information

## ✨ Main Features

* Role-based authentication
* Student, Teacher, and Exam Controller modules
* Practice quizzes
* Official examinations
* MCQ-based assessments
* Question bank management
* Quiz creation and publishing
* Attempt and result management
* Answer review
* Upcoming exam information
* Notifications
* User profiles
* Firebase-based data storage
* Real-time Firestore data management
* Firebase Storage for images

## 🛠️ Technologies Used

* **Flutter**
* **Dart**
* **Firebase Authentication**
* **Cloud Firestore**
* **Firebase Storage**
* **Material Design**

## 🗂️ Project Structure

```text
lib/
├── Student/
│   ├── History.dart
│   ├── Quiz_Screen.dart
│   ├── Result_screen.dart
│   ├── Review_Answer.dart
│   ├── Upcoming_Exam.dart
│   ├── home_screen.dart
│   ├── profile_user.dart
│   └── select_subject.dart
│
├── teacher/
│   └── teacher_dashboard.dart
│
├── controller/
│   ├── create_quiz_screen.dart
│   ├── controller_publish_report_screen.dart
│   └── ...
│
├── logo_screen.dart
└── main.dart
```

## 🔥 Firebase

The application uses Firebase for:

* User authentication
* Role management
* Questions and question banks
* Quiz and examination data
* Student attempts
* Results
* Notifications
* Profile and question images

## 🎨 Design

The application follows a clean and professional visual style using a **Dusty Plum and Cream** color theme.

* Primary: `#6D597A`
* Dark: `#44364D`
* Accent: `#DDBEA9`
* Background: `#F8F4F0`
* Text: `#332D35`

## 🚀 Getting Started

### Requirements

Make sure you have:

* Flutter SDK
* Dart SDK
* Android Studio
* Firebase project

### Installation

Clone the repository and open the project:

```text
git clone https://github.com/toseefarafique/bano-qabil-exam-app.git
cd bano_qabil_exam
```

Install dependencies:

```text
flutter pub get
```

Run the application:

```text
flutter run
```

## 📌 Project Purpose

The goal of Bano Qabil Exam is to replace traditional paper-based quiz and examination processes with a centralized digital platform where students can practice and attempt exams, teachers can manage questions and quizzes, and exam controllers can publish official examinations and results.

## 👩‍💻 Development Team

This project is developed collaboratively using Flutter, Firebase, and GitHub.

---

**Bano Qabil Exam — Learn, Practice, Attempt & Evaluate**
