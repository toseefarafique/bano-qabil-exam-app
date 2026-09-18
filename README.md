# 📚 Bano Qabil Exam App

A Flutter and Firebase-based **Online Quiz and Examination System** designed to make the examination process easier, organized, and accessible for students, teachers, and controllers.

---

## 📱 About the Project

**Bano Qabil Exam App** is an academic project developed using **Flutter, Dart, and Firebase**.

The application provides different modules for different users. Students can practice and attempt quizzes, teachers can manage questions and create quizzes, while controllers can manage examinations and results.

The main goal of the application is to provide a digital platform for conducting and managing quizzes and examinations.

---

## 🎯 Project Objectives

* Digitize the traditional quiz and examination process.
* Provide students with an easy platform to attempt quizzes.
* Allow students to practice MCQs and review their performance.
* Provide teachers with a question management system.
* Allow teachers to create and manage quizzes.
* Store quiz, question, user, and attempt data securely.
* Provide organized examination and result management.

---

## ✨ Features

### 👨‍🎓 Student Module

* Student Registration
* Student Login
* Student Dashboard
* Profile Management
* Practice MCQs
* Official Quizzes
* Quiz Instructions
* Online Examination
* Submit Quiz
* View Results
* Review Incorrect Answers
* Notifications

---

### 👩‍🏫 Teacher Module

* Teacher Login
* Teacher Dashboard
* Question Bank
* Add Questions
* Edit Questions
* Delete Questions
* Filter Questions
* Subject Filtering
* Difficulty Filtering
* Create Quiz
* Select Questions
* Manage Quizzes
* View Student Attempts
* View Results

---

### 👨‍💼 Controller / Admin Module

* Controller Login
* Dashboard
* Manage Students
* Manage Teachers
* Manage Quizzes
* Manage Examinations
* Publish Results
* Lock / Close Exams
* View Reports

---

## 📸 Screenshots

---

## 👨‍🎓 Student Module

### 🔐 Student Login
![Student Login](screenshots/student_login.png)

### 🏠 Student Dashboard
![Student Dashboard](screenshots/student_dashboard.png)

### 📚 Practice Quiz
![Practice Quiz](screenshots/practice_quiz.png)



---

## 👩‍🏫 Teacher Module

### 🔐 Teacher Login
![Teacher Login](screenshots/teacher_login.png)

### 🏠 Teacher Dashboard
![Teacher Dashboard](screenshots/teacher_dashboard.png)

### 📚 Question Bank
![Question Bank](screenshots/question_bank.png)

### ➕ Add Question
![Add Question](screenshots/add_question.png)

### 📝 Create Quiz
![Create Quiz](screenshots/create_quiz.png)

### 📋 Manage Quizzes
![Manage Quizzes](screenshots/manage_quizzes.png)

### 📊 Attempts & Results
![Attempts and Results](screenshots/attempts_results.png)

---

## 👨‍💼 Controller / Admin Module


### 🏠 Controller Dashboard
![Controller Dashboard](screenshots/controller_dashboard.png)

### 👨‍🎓 Manage Students
![Manage Students](screenshots/manage_students.png)



### 📝 Manage Notifications
![Manage Notifications](screenshots/notfication_manage.png)
### 📊 Reports & Results
![Reports and Results](screenshots/controller_reports.png)

## 🛠️ Technologies Used

| Technology               | Purpose                 |
| ------------------------ | ----------------------- |
| Flutter                  | Application development |
| Dart                     | Programming language    |
| Firebase Authentication  | User authentication     |
| Cloud Firestore          | Database                |
| Firebase Storage         | File and image storage  |
| Firebase Cloud Messaging | Notifications           |
| Material UI              | User interface          |

---

## 🔐 Authentication

Firebase Authentication is used to handle user registration and login.

The application supports different user roles:

```text
Student
Teacher
Controller
```

User role information is stored in the Firestore `users` collection.

---

## ☁️ Firebase Firestore

The application uses **Cloud Firestore** to store and manage application data.

### Main Collections

```text
users
questions
quizzes
attempts
notifications
```

### `users`

Stores user information such as:

```text
name
email
role
class
batch
campus
profile information
```

---

### `questions`

Stores MCQ questions including:

```text
question
options
correctAnswer
subject
difficulty
```

---

### `quizzes`

Stores quiz information including:

```text
title
subject
questions
status
assigned students
quiz information
```

---

### `attempts`

Stores student examination attempts and results.

---

### `notifications`

Used for examination and quiz-related notifications.

Examples:

```text
New Quiz
Exam Reminder
Result Published
Quiz Closed
```

---

## 🏗️ Application Architecture

The application is divided into different modules:

```text
Bano Qabil Exam App
│
├── Student Module
│
├── Teacher Module
│
└── Controller/Admin Module
```

### Student

```text
Login
  ↓
Dashboard
  ↓
Practice / Exams
  ↓
Attempt Quiz
  ↓
Submit
  ↓
Result
```

### Teacher

```text
Login
  ↓
Teacher Dashboard
  ↓
Question Bank
  ↓
Add / Edit Questions
  ↓
Create Quiz
  ↓
Manage Quiz
  ↓
Attempts & Results
```

### Controller

```text
Login
  ↓
Controller Dashboard
  ↓
Manage Users
  ↓
Manage Exams
  ↓
Publish Results
  ↓
Reports
```

---

## 📂 Project Structure

```text
lib/
│
├── main.dart
├── logo_screen.dart
├── firebase_options.dart
│
├── student/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── student_dashboard.dart
│   └── ...
│
├── teacher/
│   ├── teacher_dashboard.dart
│   ├── question_bank.dart
│   ├── add_question.dart
│   ├── create_quiz.dart
│   ├── manage_quizzes.dart
│   ├── attempts_results.dart
│   └── ...
│
└── controller/
    ├── dashboard.dart
    └── ...
```

> The exact files may vary as the project continues to be developed.

---

## 🚀 Getting Started

Follow these steps to run the project locally.

### 1. Clone the Repository

```bash
git clone https://github.com/toseefarafique/bano-qabil-exam-app.git
```

### 2. Open the Project

```bash
cd bano-qabil-exam-app
```

Open the project in **Visual Studio Code** or another Flutter-supported IDE.

---

### 3. Install Dependencies

Run:

```bash
flutter pub get
```

---

### 4. Configure Firebase

Connect the Flutter application with your Firebase project.

The project uses:

* Firebase Authentication
* Cloud Firestore
* Firebase Storage
* Firebase Cloud Messaging

Make sure the required Firebase configuration files are available for your platform.

---

### 5. Run the Application

For Flutter Web:

```bash
flutter run -d edge
```

For Android:

```bash
flutter run
```

---

## 👥 User Roles

| Role             | Responsibilities                                |
| ---------------- | ----------------------------------------------- |
| 👨‍🎓 Student    | Practice quizzes, attempt exams, view results   |
| 👩‍🏫 Teacher    | Manage questions, create quizzes, view attempts |
| 👨‍💼 Controller | Manage exams, publish results, monitor reports  |

---

## 🔄 Basic Application Workflow

```text
User
 │
 ├── Student
 │     ├── Login
 │     ├── Dashboard
 │     ├── Practice
 │     ├── Attempt Exam
 │     └── View Result
 │
 ├── Teacher
 │     ├── Login
 │     ├── Question Bank
 │     ├── Create Quiz
 │     ├── Manage Quiz
 │     └── View Attempts
 │
 └── Controller
       ├── Dashboard
       ├── Manage Users
       ├── Manage Exams
       └── Publish Results
```

---

## 🎨 UI Design

The application uses a clean and elegant interface designed for an educational environment.

### Color Palette

```text
Primary:    #6D597A
Dark:       #44364D
Accent:     #DDBEA9
Background: #F8F4F0
Text:       #332D35
```

---

## 🔒 Security

Firebase Authentication is used to authenticate users.

Firestore security rules can be configured to control access according to user roles.

For example:

```text
Student → Student data and quizzes
Teacher → Questions and quizzes
Controller → Examination and result management
```

---

## 📈 Future Enhancements

Future versions of the application may include:

* ⏱️ Advanced examination timer
* 📊 Detailed performance analytics
* 🏆 Leaderboards
* 📄 PDF result generation
* 🔔 Improved push notifications
* 🖼️ More question image support
* 🎲 Randomized questions
* 📊 Student performance reports
* 📱 Improved mobile responsiveness
* 📤 Export examination reports

---

## 🎓 Project Type

**Academic / Final Year Project**

### Technologies

```text
Flutter
Dart
Firebase Authentication
Cloud Firestore
Firebase Storage
Firebase Cloud Messaging
```

---

## 👨‍💻 Development

This project was developed as a collaborative academic project using Flutter and Firebase.

The application is divided into multiple modules to allow different team members to work on Student, Teacher, and Controller functionality.

---

## 📌 Repository

GitHub Repository:

**Bano Qabil Exam App**

https://github.com/toseefarafique/bano-qabil-exam-app

---

## 📄 License

This project is developed for **educational and academic purposes**.
