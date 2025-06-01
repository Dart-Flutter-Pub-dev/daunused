import 'dart:io';
import './daunused.dart';

Future<List<File>> getUnusedFiles(
  List<File> files,
  List<String> excludedFiles,
) async {
  final List<File> result = <File>[];

  for (final File file in files) {
    if (!_isExcluded(file, excludedFiles) && await _isNotUsed(file, files)) {
      result.add(file);
    }
  }

  return result;
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

Future<bool> _isNotUsed(File file, List<File> files) async {
  final String fileName = basename(file);

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
