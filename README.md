# 📝 Do ALL Notes — Flutter Notes & To-Do App

A full-featured **Notes + To-Do** mobile application built with Flutter, designed as a comprehensive foundation project covering core Flutter concepts including local database (SQLite), GetX state management, form validation, custom widgets, and clean folder architecture.

---

## 📱 Screenshots

> _Add your screenshots here after building the app_
> `![Home Screen](screenshots/home.png)`

---

## ✨ Features

### 📒 Notes
- ✅ Create, Read, Update, Delete (CRUD) notes
- ✅ Color-coded notes with 8 color options
- ✅ Full note detail view
- ✅ Real-time search by title or content
- ✅ Undo delete via Snackbar
- ✅ Sorted by newest first

### ✔️ To-Do Tasks
- ✅ Create, Read, Update, Delete tasks
- ✅ Mark tasks as done/undone with Checkbox
- ✅ Priority levels — High / Medium / Low (color-coded)
- ✅ Due date picker
- ✅ Swipe to delete (Dismissible)
- ✅ Task completion progress bar
- ✅ Undo delete via Snackbar
- ✅ Real-time search

### 🎨 UI/UX
- ✅ Material Design 3
- ✅ Bottom Navigation Bar (Notes ↔ Tasks)
- ✅ IndexedStack (preserves state on tab switch)
- ✅ Empty state illustrations
- ✅ Animated color picker
- ✅ Responsive card layout

---

## 🛠️ Tech Stack

| Technology | Usage |
|---|---|
| **Flutter** | UI Framework |
| **Dart** | Programming Language |
| **GetX** | State Management & Navigation |
| **SQLite (sqflite)** | Local Database |
| **intl** | Date Formatting |
| **path** | Database Path Resolution |

---

## 📦 Packages Used

```yaml
dependencies:
  get: ^4.6.6          # State management, navigation, snackbar
  sqflite: ^2.3.2      # Local SQLite database
  path: ^1.9.0         # Resolve database file path
  intl: ^0.19.0        # Date formatting
```

---

## 📁 Folder Structure

```
lib/
│
├── main.dart                          # App entry point, GetX binding setup
│
├── models/
│   ├── note_model.dart                # Note data class with toMap/fromMap
│   └── todo_model.dart                # Todo data class with toMap/fromMap
│
├── database/
│   └── db_helper.dart                 # SQLite Singleton — all CRUD operations
│
├── controllers/
│   ├── note_controller.dart           # GetX controller for notes logic
│   └── todo_controller.dart           # GetX controller for todos logic
│
├── screens/
│   ├── home_screen.dart               # BottomNavigationBar + IndexedStack
│   ├── notes/
│   │   ├── notes_list_screen.dart     # Display all notes, search
│   │   ├── add_edit_note_screen.dart  # Add or edit a note
│   │   └── note_detail_screen.dart    # Full note view
│   └── todos/
│       ├── todo_list_screen.dart      # Display all tasks, progress bar
│       └── add_edit_todo_screen.dart  # Add or edit a task
│
└── widgets/
    ├── note_card.dart                 # Reusable note card widget
    ├── todo_tile.dart                 # Reusable todo list tile
    ├── empty_state.dart               # Empty state UI component
    └── color_picker_widget.dart       # Horizontal animated color picker
```

---

## 🧠 Flutter Concepts Covered

| Concept | Where Applied |
|---|---|
| `StatefulWidget` & `StatelessWidget` | All screens and widgets |
| `setState` | Color picker, priority selector |
| **GetX** `RxList`, `RxBool`, `RxDouble` | Note & Todo controllers |
| **GetX** `Obx` | Reactive UI rebuilding in list screens |
| **GetX** `Get.to()`, `Get.back()`, `Get.find()` | Navigation throughout app |
| **GetX** `Get.snackbar()` | Success & undo notifications |
| `SQLite` CRUD | `db_helper.dart` |
| Singleton Pattern | `DbHelper` class |
| `toMap()` / `fromMap()` | Model serialization for SQLite |
| `TextEditingController` | All form fields |
| `GlobalKey<FormState>` | Form validation |
| `validator` callback | Required field checks |
| `initState()` / `dispose()` | Controller lifecycle management |
| `ListView.builder` | Efficient list rendering |
| `IndexedStack` | Tab state preservation |
| `Dismissible` | Swipe-to-delete on tasks |
| `AnimatedContainer` | Color picker animation |
| `LinearProgressIndicator` | Task completion progress |
| `showDatePicker` | Built-in Flutter date picker |
| `showDialog` / `AlertDialog` | Search & delete confirmation |
| `SegmentedButton` | Priority selector |
| `computeLuminance()` | Dynamic text color on colored cards |
| `BottomNavigationBar` | Main navigation |
| `FloatingActionButton` | Add note/task trigger |
| Custom Reusable Widgets | `NoteCard`, `TodoTile`, `EmptyState`, `ColorPickerWidget` |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/do-all-notes.git

# 2. Navigate into the project
cd do-all-notes

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

---

## 🗄️ Database Schema

### `notes` table

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK AUTOINCREMENT | Unique identifier |
| `title` | TEXT NOT NULL | Note title |
| `content` | TEXT NOT NULL | Note body |
| `color` | INTEGER NOT NULL | Color value (ARGB int) |
| `createdAt` | TEXT NOT NULL | Creation timestamp |
| `updatedAt` | TEXT NOT NULL | Last update timestamp |

### `todos` table

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK AUTOINCREMENT | Unique identifier |
| `title` | TEXT NOT NULL | Task title |
| `description` | TEXT NOT NULL | Task details |
| `isDone` | INTEGER NOT NULL (0/1) | Completion status |
| `priority` | INTEGER NOT NULL (1/2/3) | 1=High, 2=Medium, 3=Low |
| `dueDate` | TEXT | Optional deadline |
| `createdAt` | TEXT NOT NULL | Creation date |

---

## 🗺️ File Build Order

If you are building this project from scratch, follow this order to avoid dependency errors:

```
1. pubspec.yaml            → Add all packages first
2. models/                 → Define data structures
3. database/db_helper.dart → Set up database before controllers
4. controllers/            → Business logic depends on DB
5. widgets/                → UI components before screens
6. screens/                → Screens use widgets + controllers
7. main.dart               → Wire everything together last
```

---

## 🔮 What This Project Does NOT Cover (Yet)

This is a **foundation learning project**. The following are intentionally left out for future projects:

- 🌐 REST API / HTTP network calls
- ☁️ Cloud sync (Firebase Firestore)
- 🔔 Push notifications / reminders
- 🔐 Authentication (Firebase Auth / Biometric)
- 🖼️ Image picking / camera
- 🧪 Unit & widget testing
- 🏛️ Clean Architecture
- 💡 BLoC / Riverpod state management
- 📱 Responsive / tablet layout

---

## 📚 Learning Purpose

This project is **Part 1 of a 4-project Flutter portfolio roadmap**:

| # | Project | Key Skills |
|---|---|---|
| **1** | **Do ALL Notes** ← _You are here_ | SQLite, GetX, Forms, CRUD |
| 2 | Health & Fitness Tracker | Sensors, Charts, BLoC |
| 3 | Language Learning App | TTS Audio, Riverpod, Animations |
| 4 | Live Quiz Multiplayer | Firebase Realtime DB, Sockets |

---

## 👨‍💻 Author

**Mohammad Faisal**
Flutter Developer — Building for international remote opportunities.

- GitHub: [https://github.com/Faisal60177](https://github.com/Faisal60177)
- LinkedIn: [www.linkedin.com/in/mohammad-faisal-7b65ab3b6](www.linkedin.com/in/mohammad-faisal-7b65ab3b6)

---

## 📄 License

This project is licensed under the **MIT License** — feel free to use, modify, and distribute.

```
MIT License — Copyright (c) 2025 Mohammad Faisal
```

---

> ⭐ If this project helped you learn Flutter, consider giving it a star on GitHub!