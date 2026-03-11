import 'package:expandable_datatable/src/exception/bool_exception.dart';
import 'package:expandable_datatable/src/extension/string_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoolParsingExtension.parseToBool', () {
    test('returns true for "true"', () {
      expect('true'.parseToBool, isTrue);
    });

    test('returns true for "TRUE" (case-insensitive)', () {
      expect('TRUE'.parseToBool, isTrue);
    });

    test('returns true for "True" (mixed case)', () {
      expect('True'.parseToBool, isTrue);
    });

    test('returns false for "false"', () {
      expect('false'.parseToBool, isFalse);
    });

    test('returns false for "FALSE" (case-insensitive)', () {
      expect('FALSE'.parseToBool, isFalse);
    });

    test('returns false for "False" (mixed case)', () {
      expect('False'.parseToBool, isFalse);
    });

    test('throws BoolParsingException for arbitrary string', () {
      expect(() => 'yes'.parseToBool, throwsA(isA<BoolParsingException>()));
    });

    test('throws BoolParsingException for empty string', () {
      expect(() => ''.parseToBool, throwsA(isA<BoolParsingException>()));
    });

    test('throws BoolParsingException for numeric string', () {
      expect(() => '1'.parseToBool, throwsA(isA<BoolParsingException>()));
    });
  });
}
