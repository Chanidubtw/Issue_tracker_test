# Issue Tracker

A mobile issue tracker with offline persistence, built to production-quality standards.

---

## Tech Stack


| Layer | Technology |
|---|---|
| Framework | Flutter 3.38 / Dart 3.10 |
| State Management | Riverpod (StateNotifier) |
| Persistence | Hive (offline-first) |
| Networking | Dio + Mock Interceptor |
| Navigation | GoRouter |
| Theme | Material 3 (light + dark) |
| Export | share_plus (JSON + CSV) |


---

## Architecture

Clean Architecture with three layers:

```
domain/       → Pure Dart: entities, repository interfaces, use cases
data/         → Hive datasource, Dio API service, repository implementations
presentation/ → Riverpod providers, screens, reusable widgets
```

---

## Setup

### Prerequisites
- Flutter SDK ≥ 3.10.0
- Dart SDK ≥ 3.0.0

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/Chanidubtw/Issue_tracker_test.git
cd issue_tracker

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run

# 4. Run tests
flutter test
```

> **Note:** The generated Hive adapter (`issue_model.g.dart`) is pre-committed.
> If you make model changes, regenerate with: `dart run build_runner build --delete-conflicting-outputs`

---

## Login Credentials

No fixed credentials — any **valid email** and **password of 6+ characters** will work. Example:

```
Email:    any@example.com
Password: password123
```

---

## Features Completed

### Core (12/12)
- [x] Authentication screen with email/password validation
- [x] Issue list with title, status, priority, created date
- [x] Dashboard with counts by Open / In Progress / Resolved / Closed
- [x] Create issue form (title, description, priority, status, assignee)
- [x] Edit existing issues
- [x] Issue detail screen with full information
- [x] Mark as Resolved / Closed with confirmation dialog
- [x] Search by title + filter by status and priority (combined)
- [x] Loading, empty, and error states for all screens
- [x] Pull-to-refresh from mock API
- [x] Local persistence — data survives app restart (Hive)
- [x] Navigation: auth → dashboard → list → detail → form

### Bonus (6/7)
- [x] Offline-first with sync queue (`isSynced` flag, retry on refresh)
- [x] Reusable widget library (IssueCard, StatusChip, PriorityBadge, etc.)
- [x] Unit tests (validators, entity logic) + widget test (login screen flow)
- [x] Dark mode / light mode toggle, persisted across restarts
- [x] Export to JSON and CSV with native share sheet
- [x] Clean separation: UI / state / data layers (Clean Architecture)
- [ ] Image/attachment support — **skipped** (large scope vs. low evaluation weight)

---

## What Was Skipped

**Image/file attachments**: skipped because of time consuming and apk will get larger , I can implement that also if you want me to.

---

## Folder Structure

```
lib/
├── core/            # constants, errors, theme, utils
├── data/            # models, datasources (Hive + Dio), repositories
├── domain/          # entities, repository interfaces, use cases
└── presentation/    # providers, screens, widgets
```

---

## Offline Behavior

1. On first launch: fetches mock data from Dio (simulated network call) → stores in Hive
2. On subsequent launches: loads directly from Hive — no network needed
3. Created/edited issues are saved to Hive immediately with `isSynced = false`
4. Pull-to-refresh merges remote data, preserving unsynced local issues, then runs sync
5. Unsynced items are visible with a "Pending" badge in the issue card

---

## Mock API

No external service is needed. A `MockInterceptor` intercepts all Dio requests and returns data from `assets/mock/issues.json` after an 800ms simulated delay — making the network behavior realistic without a server.
