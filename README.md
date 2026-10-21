# Flutter To-Do App

A simple and user-friendly To-do application built with Flutter and Dart as a Week 1 capstone project.

## Features

- Create, read, update, and delete tasks
- Mark tasks as completed
- Search tasks by name
- Filter tasks by status: All, Active, and Completed
- Organize tasks by category: Study, Work, Personal, Shopping, and Health
- View task completion progress on the dashboard
- Save tasks locally using SharedPreferences
- Navigate between the dashboard and task list using GoRouter

## Tech Stack

- **Flutter** — UI framework
- **Dart** — Programming language
- **GoRouter** — Navigation and routing
- **SharedPreferences** — Local data persistence

## Getting Started

### Prerequisites

Install Flutter and Dart, and configure an emulator or connected device.

### Run the project

1. Clone this repository:

   ```bash
   git clone https://github.com/Salima305/flutter-todo-app
   ```

2. Open the project directory:

   ```bash
   cd flutter-todo-app
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the app:

   ```bash
   flutter run
   ```

## Project Structure

```text
lib/
├── main.dart
├── category_dashboard.dart
└── task.dart
```

- `main.dart` — App entry point, routing, and task management UI
- `category_dashboard.dart` — Dashboard, category cards, and progress overview
- `task.dart` — Task data model and JSON conversion

## Learning Goals

This project demonstrates Flutter UI development, Dart fundamentals, navigation, local persistence, and basic state management.

## Future Improvements

- Introduce Riverpod for state management
- Add dark mode
- Improve automated testing

## Author

Salima
