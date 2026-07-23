import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/table_test_utils.dart';

// ---------------------------------------------------------------------------
// Regression tests for editing rows that contain a null cell value.
//
// Bug: EditDialog._processCellUpdate dispatches on `oldCell.value.runtimeType`
// (`is String` / `is bool` / `is int` / `is double` / `is ImageProvider`).
// A null value matches none of these branches and falls through to
// `throw NoSupportException(...)`, so pressing SAVE on any row with a null
// cell currently crashes — even though the library explicitly supports null
// cells via `nullValuePlaceholder`.
// ---------------------------------------------------------------------------

void main() {
  const colNames = ['First', 'Last'];

  group('editing a row with a null cell', () {
    testWidgets('SAVE does not throw', (tester) async {
      final rows = [
        strRow(colNames, [null, 'Doe']),
      ];

      await tester.pumpWidget(
        buildEditableTable(headers: strHeaders(colNames), rows: rows),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('SAVE commits the edited value for the null cell',
        (tester) async {
      ExpandableRow? result;
      final rows = [
        strRow(colNames, [null, 'Doe']),
      ];

      await tester.pumpWidget(
        buildEditableTable(
          headers: strHeaders(colNames),
          rows: rows,
          onRowChanged: (row, _) => result = row,
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.enterText(editFieldFor('First'), 'NewFirstName');

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.cells.first.value, 'NewFirstName');
    });

    testWidgets('the edit field does not display the literal string "null"',
        (tester) async {
      final rows = [
        strRow(colNames, [null, 'Doe']),
      ];

      await tester.pumpWidget(
        buildEditableTable(headers: strHeaders(colNames), rows: rows),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      expect(find.text('null'), findsNothing);
    });
  });
}
