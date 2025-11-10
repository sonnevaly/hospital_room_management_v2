# Hospital Room Management v2 (Dart + JSON)

## Run
```bash
dart pub get
dart run bin/main.dart
```

## Features
- Patient registration
- Bed allocation / release
- **New:** Patient history (assign/release timeline)

## Structure
- bin/ — entry point
- lib/src/models — data models
- lib/src/data/repositories — JSON persistence
- lib/src/services — business logic
- lib/ui/console — console UI
- data/ — JSON storage
