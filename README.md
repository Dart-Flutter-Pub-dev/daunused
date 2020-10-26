# Daunused

A *Flutter* package that checks for unused files in your project.

## Installation

Add the following dependency to your `pubspec.yaml`:

```yaml
dev_dependencies:
  daunused: ^1.1.0
```

#### Run the checker

```bash
flutter pub pub run daunused:daunused.dart ROOT_FOLDER [EXCEPTION1 EXCEPTION2 ...]
```

For example:

```bash
flutter pub pub run daunused:daunused.dart . lib/main.dart
```