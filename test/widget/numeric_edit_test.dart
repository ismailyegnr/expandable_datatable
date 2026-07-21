import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/table_test_utils.dart';

// ---------------------------------------------------------------------------
// Regression tests for editing double-valued cells.
//
// Bug: GeneralConstants.DOUBLE_REGEXP is `^\d+\.?\d+`, which requires at
// least two digits (one before an optional dot, one after — the trailing
// `\d+` is non-optional). The FilteringTextInputFormatter built from this
// regex therefore strips a single-digit value like "5", leaving the field
// empty and blocking SAVE via the "must not be empty" validator.
// ---------------------------------------------------------------------------

void main() {
  List<ExpandableColumn> doubleHeaders() => [
        ExpandableColumn<String>(columnTitle: 'Name', columnFlex: 1),
        ExpandableColumn<double>(columnTitle: 'Score', columnFlex: 1),
      ];

  ExpandableRow doubleRow(String name, double score) => ExpandableRow(
        cells: [
          ExpandableCell<String>(columnTitle: 'Name', value: name),
          ExpandableCell<double>(columnTitle: 'Score', value: score),
        ],
      );

  group('editing a double cell', () {
    testWidgets('a single-digit value can be entered and saved',
        (tester) async {
      ExpandableRow? result;

      await tester.pumpWidget(
        buildEditableTable(
          headers: doubleHeaders(),
          rows: [doubleRow('Alice', 1.5)],
          onRowChanged: (row, _) => result = row,
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.enterText(editFieldFor('Score'), '5');

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(result, isNotNull);
      final scoreCell =
          result!.cells.firstWhere((c) => c.columnTitle == 'Score');
      expect(scoreCell.value, 5.0);
    });

    testWidgets('a decimal value round-trips', (tester) async {
      ExpandableRow? result;

      await tester.pumpWidget(
        buildEditableTable(
          headers: doubleHeaders(),
          rows: [doubleRow('Alice', 1.5)],
          onRowChanged: (row, _) => result = row,
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.enterText(editFieldFor('Score'), '3.14');

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      final scoreCell =
          result!.cells.firstWhere((c) => c.columnTitle == 'Score');
      expect(scoreCell.value, 3.14);
    });
  });
}
