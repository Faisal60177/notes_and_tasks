# NoteFlow — Notes & Tasks App

An offline-first productivity app that combines rich-text note-taking and task
management in a single, clean Flutter application. Built with a repository
pattern, real-time Firebase sync, and a soft-delete + timed-undo pattern so
every action feels instant and every delete is safely reversible.

<!-- Add a screenshot strip here once available, e.g.: -->
<!-- ![screenshots](docs/screenshots/banner.png) -->

## ✨ Features

### Notes
- Rich-text editor powered by **flutter_quill** — bold, italic, underline,
  strikethrough, headers, bullet/numbered lists, checklists, block quotes,
  and inline code.
- Category-based toolbar that switches between Text / List / Insert /
  History tool groups to keep the writing area uncluttered.
- Color-coded notes (8 colors) with dark-mode–aware contrast.
- Pin important notes to the top of the list.
- Grid and list view toggle.
- Live word count and last-updated timestamp shown in the editor.
- One-line content preview on note cards for quick scanning.

### Tasks
- Priority levels (Low / Medium / High) with color-coded badges.
- Optional description, category, and due date per task.
- Checkbox-based completion with visual dimming for done tasks.
- Priority-accent stripe on each task card for at-a-glance scanning.

### Data & Sync
- **Offline-first**: every action (add/edit/delete) writes to a local
  SQLite database first, so the app is fully usable with no connection.
- **Two-way Firestore sync**: a background sync process pushes local
  changes and pulls remote changes, resolving conflicts with a
  last-write-wins strategy based on `updatedAt`.
- **Soft-delete + timed undo**: deleting a note or task marks it
  soft-deleted locally and shows an "Undo" snackbar. If undo isn't
  pressed within the grace period, the item is permanently removed from
  both SQLite and Firestore. Undoing at any point before that fully
  restores it.
- **Connectivity-aware**: sync attempts only run when the app detects an
  active connection, using `connectivity_plus`.

## 🏗️ Architecture

The app follows a **clean, layered architecture** per feature
(`notes/` and `todo/`):

```
lib/
├── core/
│   ├── database/          # Shared SQLite (sqflite) database helper
│   ├── providers/         # App-wide Riverpod providers (DB, connectivity)
│   └── services/          # ConnectivityService
├── features/
│   ├── notes/
│   │   ├── data/
│   │   │   ├── models/         # NoteModel + NoteColor enum
│   │   │   ├── datasources/    # NoteLocalDatasource, NoteRemoteDatasource
│   │   │   └── repository/     # NoteRepository (sync + undo logic)
│   │   └── presentation/
│   │       ├── pages/          # NotesPage, NoteEditorPage
│   │       ├── providers/      # notesProvider (Riverpod code-gen)
│   │       ├── widgets/        # NoteCard, NoteToolbar
│   │       └── utils/          # color mapping, Quill Delta helpers
│   └── todo/
│       └── (same structure as notes/)
└── main.dart
```

**Why this structure:**
- **Datasources** talk to exactly one storage backend (SQLite or
  Firestore) and know nothing about each other.
- **Repository** is the single source of truth the UI talks to — it
  decides *when* to hit local vs. remote storage, and owns the
  undo/sync/conflict-resolution logic.
- **Riverpod code-gen notifiers** expose repository data as UI state,
  keeping widgets free of business logic.

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Language | Dart |
| Framework | Flutter (Material 3) |
| State management | Riverpod (`flutter_riverpod`, `riverpod_generator`) |
| Local storage | SQLite via `sqflite` |
| Cloud backend | Firebase (Firestore, Auth) |
| Rich text editor | `flutter_quill` |
| Connectivity | `connectivity_plus` |
| ID generation | `uuid` |
| Date formatting | `intl` |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (channel stable)
- A Firebase project with Firestore and Authentication enabled
- `flutterfire configure` run against your Firebase project to generate
  `firebase_options.dart`

### Setup
```bash
git clone https://github.com/Faisal60177/notes_and_tasks.git
cd notes_and_tasks
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Firebase
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Firestore Database** and **Authentication** (Email/Google sign-in).
3. Run `flutterfire configure` in the project root to link the app.
4. Firestore documents are stored under `users/{userId}/notes/{noteId}` and
   `users/{userId}/todos/{todoId}`.

## 📦 Building a Release

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

## 🎨 App Icon

App icons are generated with [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons).

1. Place a 1024×1024 PNG source icon at `assets/icon/icon.png`.
2. Add this to `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icon/note.png"
     min_sdk_android: 21
     adaptive_icon_background: "#FFFFFF"
     adaptive_icon_foreground: "assets/icon/note.png"
   ```
3. Run:
   ```bash
   dart run flutter_launcher_icons
   ```

## 📄 License

This project is for personal/portfolio use. Add a license of your choice
(MIT recommended for open-source portfolio projects).

## 👤 Author

**Mohammad Faisal**
Flutter Mobile App Developer
[GitHub](https://github.com/Faisal60177) · [Play Store](https://play.google.com/store/apps/developer?id=Siratal+Mustaqeem)