# ManageHive Frontend

A **Flutter** application that serves as the frontend for the ManageHive system.  
This repo targets **web** and communicates with the Java/Spring Boot backend via REST APIs.

> Backend repo: **ManageHive Backend** → https://github.com/sdas204221/ManageHiveBackend

---

## Tech Stack

- **Flutter 3.x (stable channel)**
- **Dart**
- **Material Design**
- HTTP client for REST calls
- Supports **Web**

---

## Project Structure

```
lib/
  main.dart
  # (add your layers as you grow the app)
  # screens/       -> UI pages
  # widgets/       -> reusable UI components
  # services/      -> API clients
  # models/        -> data models
  # utils/         -> helpers, formatters

web/               # web runner (index.html, etc.)
```

---

## Prerequisites

- Flutter SDK installed (3.x, stable)  
  ```bash
  flutter --version
  flutter doctor
  ```
- **Chrome**.

---

## Run Locally

1) Get packages
```bash
flutter pub get
```

2) Start for **Web**
```bash
flutter run -d chrome
```

---

## Related Repositories

- **Backend (Java/Spring Boot):** https://github.com/sdas204221/ManageHiveBackend

---

## Author

**Subhra Das** — https://github.com/sdas204221
