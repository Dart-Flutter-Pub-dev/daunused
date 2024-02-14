# Daunused

A *Dart* package that checks for unused files in your project.

## Installation

Add the following dependency to your `pubspec.yaml`:

```yaml
dev_dependencies 1.6.1
```

#### Run the checker

```bash
flutter pub run daunused:daunused.dart ROOT_FOLDER [EXCEPTION1 EXCEPTION2 ...]
```

For example:

```bash
flutter pub run daunused:daunused.dart . lib/main.dart utils/*
```