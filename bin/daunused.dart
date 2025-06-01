#!/usr/bin/env dart

library daunused;

import 'dart:io';

Future<void> main(List<String> args) async {
  final Directory root = Directory(args[0]);
  final List<String> excludedFiles = _excludedFiles(args);
  final List<File> files = await _getFiles(root);

  for (final File file in files) {
    if (!_isExcluded(file, excludedFiles) && await _isNotUsed(file, files)) {
      stderr.writeln('\x1B[31m${file.uri}\x1B[0m');
    }
  }
}

bool _isExcluded(File file, List<String> excludedFiles) {
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

List<String> _excludedFiles(List<String> args) {
  final List<String> result = <String>[];

  for (int i = 1; i < args.length; i++) {
    result.add(args[i]);
  }

  return result;
}

Future<List<File>> _getFiles(Directory root) async {
  final List<FileSystemEntity> list = await root.list(recursive: true).toList();
  final List<File> files = <File>[];

  for (final FileSystemEntity entity in list) {
    if (entity is File) {
      final File file = File(entity.path);
      final String fileName = _basename(file);

      if (fileName.endsWith('.dart')) {
        files.add(file);
      }
    }
  }

  return files;
}

Future<bool> _isNotUsed(File file, List<File> files) async {
  final String fileName = _basename(file);

  for (final File currentFile in files) {
    if (await _isUsed(fileName, currentFile)) {
      return false;
    }
  }

  return true;
}

Future<bool> _isUsed(String fileName, File file) async {
  final String content = await file.readAsString();
  final List<String> lines = content.split('\n');
  final List<String> imports = _filesImported(lines);

  for (final String fileImported in imports) {
    if (fileImported.contains(fileName)) {
      return true;
    }
  }

  return false;
}

List<String> _filesImported(List<String> lines) {
  final List<String> result = <String>[];

  for (final String line in lines) {
    if (_isImportLine(line.trim())) {
      result.add(line.trim());
    }
  }

  return result;
}

bool _isImportLine(String line) {
  if (line.startsWith('import ') || line.startsWith('part ')) {
    return true;
  } else if (line.startsWith('if (') &&
      (line.endsWith(".dart'") || line.endsWith(".dart';"))) {
    return true;
  } else {
    return false;
  }
}

String _basename(File file) =>
    Uri.parse(file.path).path.split(Platform.pathSeparator).last;
