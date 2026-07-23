import 'package:expandable_datatable/src/exception/bool_exception.dart';
import 'package:expandable_datatable/src/exception/no_support_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoSupportException', () {
    test('toString reports the unsupported type', () {
      final exception = NoSupportException('DateTime');

      expect(
        exception.toString(),
        'This package does not support DateTime type.',
      );
    });

    test('is an Exception', () {
      expect(NoSupportException('Foo'), isA<Exception>());
    });
  });

  group('BoolParsingException', () {
    test('toString reports a fixed message', () {
      expect(
        BoolParsingException().toString(),
        'Could not parse string as boolean.',
      );
    });

    test('is an Exception', () {
      expect(BoolParsingException(), isA<Exception>());
    });
  });
}
