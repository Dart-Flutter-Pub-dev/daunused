import 'mobile_implementation.dart'
    if (dart.library.js) 'web_implementation.dart';

class ConditionalImport {
  final MobileImplementation mobileImplementation = MobileImplementation();
}
