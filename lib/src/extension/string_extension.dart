import '../exception/bool_exception.dart';

extension BoolParsingExtension on String {
  bool? get parseToBool {
    if (toLowerCase() == "true") {
      return true;
    } else if (toLowerCase() == 'false') {
      return false;
    }

    throw BoolParsingException();
  }
}
