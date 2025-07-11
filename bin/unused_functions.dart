import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import './daunused.dart';

Future<Map<String, String>> getUnusedFunctions(
  List<File> files,
  List<String> excludedFiles,
  List<String> excludedFunctions,
) async {
  final Map<String, String> declaredElements = <String, String>{};
  final Set<String> usedElements = <String>{};

  for (final File file in files) {
    if (!isExcluded(file, excludedFiles)) {
      final String content = await file.readAsString();
      final CompilationUnit unit =
          parseString(content: content, path: file.path).unit;
      unit.visitChildren(
        _MethodVisitor(
          filePath: file.path,
          declaredElements: declaredElements,
          usedElements: usedElements,
          excludedFunctions: excludedFunctions,
        ),
      );
    }
  }

  final Map<String, String> result = <String, String>{};

  for (final MapEntry<String, String> entry in declaredElements.entries) {
    final String name = entry.key;
    final String filePath = entry.value;

    if (!usedElements.contains(name)) {
      result[name] = filePath;
    }
  }

  return result;
}

class _MethodVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final Map<String, String> declaredElements;
  final Set<String> usedElements;
  final List<String> excludedFunctions;

  _MethodVisitor({
    required this.filePath,
    required this.declaredElements,
    required this.usedElements,
    required this.excludedFunctions,
  });

  void _addDeclaredElement(String name) {
    if (!name.startsWith('_') && !excludedFunctions.contains(name)) {
      declaredElements[name] = filePath;
    }
  }

  void _addUsedElement(String name) {
    usedElements.add(name);
  }

  bool _isOverriden(AnnotatedNode node) =>
      node.metadata.any((Annotation m) => m.name.name == 'override');

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (!_isOverriden(node)) {
      final String name = node.name.lexeme;
      _addDeclaredElement(name);
    }

    super.visitMethodDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (!_isOverriden(node)) {
      final String name = node.name.lexeme;
      _addDeclaredElement(name);
    }

    super.visitFunctionDeclaration(node);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    for (final VariableDeclaration varDecl in node.fields.variables) {
      if (!_isOverriden(varDecl)) {
        final String name = varDecl.name.lexeme;
        _addDeclaredElement(name);
      }
    }
    super.visitFieldDeclaration(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _addUsedElement(node.methodName.name);
    super.visitMethodInvocation(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (node.function is Identifier) {
      _addUsedElement((node.function as Identifier).name);
    }
    super.visitFunctionExpressionInvocation(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    _addUsedElement(node.propertyName.name);
    super.visitPropertyAccess(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    _addUsedElement(node.identifier.name);
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    _addUsedElement(node.name);
    super.visitSimpleIdentifier(node);
  }
}
