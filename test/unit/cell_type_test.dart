import 'dart:typed_data';

import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class DateTimeCellType extends CellType<DateTime> {
  const DateTimeCellType();

  @override
  Widget buildTitleCell(
    BuildContext context,
    DateTime? value,
    TextStyle? textStyle,
  ) {
    return Text(
      toDisplayString(value, '-'),
      style: textStyle,
    );
  }

  @override
  Widget buildExpansionCell(
    BuildContext context,
    DateTime? value,
    TextStyle? textStyle,
  ) {
    return Text(
      toDisplayString(value, '-'),
      style: textStyle,
    );
  }

  @override
  int compare(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.compareTo(b);
  }

  @override
  String toDisplayString(DateTime? value, String placeholder) {
    if (value == null) return placeholder;
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
}

void main() {
  group('StringCellType unit tests', () {
    const type = StringCellType();

    test('compare performs case-insensitive comparison', () {
      expect(type.compare('apple', 'Banana'), isNegative);
      expect(type.compare('Banana', 'apple'), isPositive);
      expect(type.compare('Apple', 'apple'), equals(0));
      expect(type.compare(null, 'a'), isNegative);
      expect(type.compare('a', null), isPositive);
      expect(type.compare(null, null), equals(0));
    });

    test('toDisplayString returns value or placeholder', () {
      expect(type.toDisplayString('hello', 'empty'), 'hello');
      expect(type.toDisplayString(null, 'empty'), 'empty');
    });
  });

  group('NumericCellType unit tests', () {
    const intType = NumericCellType<int>();
    const doubleType = NumericCellType<double>();

    test('compare compares numbers with null safety', () {
      expect(intType.compare(5, 10), isNegative);
      expect(intType.compare(10, 5), isPositive);
      expect(intType.compare(5, 5), equals(0));
      expect(intType.compare(null, 5), isNegative);
      expect(intType.compare(5, null), isPositive);
      expect(intType.compare(null, null), equals(0));

      expect(doubleType.compare(2.5, 3.1), isNegative);
      expect(doubleType.compare(3.1, 2.5), isPositive);
    });

    test('toDisplayString converts numbers to string', () {
      expect(intType.toDisplayString(42, 'N/A'), '42');
      expect(intType.toDisplayString(null, 'N/A'), 'N/A');
    });
  });

  group('BoolCellType unit tests', () {
    const type = BoolCellType();

    test('compare orders false before true', () {
      expect(type.compare(false, true), isNegative);
      expect(type.compare(true, false), isPositive);
      expect(type.compare(true, true), equals(0));
      expect(type.compare(false, false), equals(0));
      expect(type.compare(null, false), isNegative);
      expect(type.compare(true, null), isPositive);
      expect(type.compare(null, null), equals(0));
    });

    test('toDisplayString outputs boolean string or placeholder', () {
      expect(type.toDisplayString(true, 'none'), 'true');
      expect(type.toDisplayString(false, 'none'), 'false');
      expect(type.toDisplayString(null, 'none'), 'none');
    });
  });

  group('ImageCellType unit tests', () {
    const type = ImageCellType(
      height: 80,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );

    test('compare always returns 0', () {
      final img = MemoryImage(Uint8List(0));
      expect(type.compare(img, img), equals(0));
      expect(type.compare(null, img), equals(0));
    });

    test('toDisplayString returns placeholder', () {
      expect(type.toDisplayString(null, '-'), '-');
    });

    test('properties are preserved', () {
      expect(type.height, 80);
      expect(type.fit, BoxFit.cover);
      expect(type.borderRadius, const BorderRadius.all(Radius.circular(10)));
    });
  });

  group('Custom DateTimeCellType unit tests', () {
    const type = DateTimeCellType();

    test('compare sorts dates chronologically', () {
      final d1 = DateTime(2025, 1, 1);
      final d2 = DateTime(2026, 8, 14);

      expect(type.compare(d1, d2), isNegative);
      expect(type.compare(d2, d1), isPositive);
      expect(type.compare(d1, d1), equals(0));
      expect(type.compare(null, d1), isNegative);
      expect(type.compare(d2, null), isPositive);
    });

    test('toDisplayString formats YYYY-MM-DD', () {
      expect(type.toDisplayString(DateTime(2026, 8, 14), '-'), '2026-08-14');
      expect(type.toDisplayString(DateTime(2026, 1, 5), '-'), '2026-01-05');
      expect(type.toDisplayString(null, '-'), '-');
    });
  });
}
