#!/usr/bin/env dart

library daunused;

import 'dart:io';
import 'package:path/path.dart';

Future<void> main(List<String> args) async {
  final Directory root = Directory(args[0]);
  final List<String> exceptions = _exceptions(args);
  final List<File> files = await _getFiles(root);

  for (final File file in files) {
    if (!_isException(file, exceptions) && await _isNotUsed(file, files)) {
      print(file.uri);
    }
  }
}

bool _isException(File file, List<String> exceptions) {
  final String uri = file.uri.toString();

  if (exceptions.contains(uri)) {
    return true;
  } else {
    for (final String exception in exceptions) {
      final RegExp exp = RegExp(exception);

      if (exp.hasMatch(uri)) {
        return true;
      }
    }

    return false;
  }
}

List<String> _exceptions(List<String> args) {
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
      final String fileName = basename(file.path);

      if (fileName.endsWith('.dart')) {
        files.add(file);
      }
    }
  }

  return files;
}

Future<bool> _isNotUsed(File file, List<File> files) async {
  final String fileName = basename(file.path);

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

  for (final String line in lines) {
    if ((line.startsWith('import ') || line.startsWith('part ')) &&
        (line.endsWith('$fileName\';'))) {
      return true;
    }
  }

  return false;
}
