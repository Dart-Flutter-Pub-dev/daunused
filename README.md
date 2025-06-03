# Daunused

A _Dart_ package that checks for unused files in your project.

## Installation

Add the following dependency to your `pubspec.yaml`:

```yaml
dev_dependencies 1.7.3
```

#### Run the checker

```bash
flutter pub run daunused:daunused.dart ROOT_FOLDER [EXCLUDED_FILE_1, EXCLUDED_FILE_2 ...] [EXCLUDED_FUNCTION_1, EXCLUDED_FUNCTION_2 ...]
```

For example:

```bash
flutter pub run daunused:daunused.dart lib lib/main.dart,utils/* ==,build
```
