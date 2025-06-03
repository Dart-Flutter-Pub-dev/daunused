#!/usr/bin/env dart

library daunused;

import 'dart:io';
import './unused_files.dart';
import './unused_functions.dart';

Future<void> main(List<String> args) async {
  final List<File> files = await _files(args);
  final List<String> excludedFiles = _excludedFiles(args);
  final List<String> excludedFunctions = _excludedFunctions(args);

  final List<File> unusedFiles = await getUnusedFiles(files, excludedFiles);

  print('');

  if (unusedFiles.isEmpty) {
    printError('🎉 No unused files found!');
  } else {
    printError('🧹 ${unusedFiles.length} possibly unused files:');
  }

  for (final File file in unusedFiles) {
    printError('- ${file.uri.toString()}');
  }

  final Map<String, String> unusedFunctions = await getUnusedFunctions(
    files,
    excludedFiles,
    excludedFunctions,
  );

  print('');

  if (unusedFunctions.isEmpty) {
    printError('🎉 No unused functions found!');
  } else {
    printError('🧹 ${unusedFunctions.length} possibly unused functions:');
    for (final MapEntry<String, String> entry in unusedFunctions.entries) {
      printError('- ${entry.key}: ${entry.value}');
    }
  }
}

Future<List<File>> _files(List<String> args) async {
  final Directory root = Directory(args[0]);
  final List<FileSystemEntity> list = await root.list(recursive: true).toList();
  final List<File> result = <File>[];

  for (final FileSystemEntity entity in list) {
    if (entity is File) {
      final File file = File(entity.path);
      final String fileName = basename(file);

      if (fileName.endsWith('.dart')) {
        result.add(file);
      }
    }
  }

  return result;
}

List<String> _excludedFiles(List<String> args) =>
    args.length > 1
        ? args[1].split(',').map((String e) => e.trim()).toList()
        : <String>[];

List<String> _excludedFunctions(List<String> args) =>
    args.length > 2
        ? args[2].split(',').map((String e) => e.trim()).toList()
        : <String>[];

String basename(File file) =>
    Uri.parse(file.path).path.split(Platform.pathSeparator).last;

bool isExcluded(File file, List<String> excludedFiles) {
  final String uri = file.uri.toString();

  if (excludedFiles.contains(uri)) {
    return true;
  } else {
    for (final String excludedFile in excludedFiles) {
      final RegExp exp = RegExp(excludedFile);

      if (exp.hasMatch(uri)) {
        return true;
      }
    }

    return false;
  }
}

void printError(String message) {
  stderr.writeln('\x1B[31m$message\x1B[0m');
}
