import 'conditional_import.dart';
import 'used_file.dart';

void main() {
  final UsedClass used = UsedClass();
  print(used);

  final ConditionalImport conditionalImport = ConditionalImport();
  print(conditionalImport);
}
