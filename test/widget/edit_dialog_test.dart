import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildEditableTable({
  required List<ExpandableRow> rows,
  required List<ExpandableColumn> headers,
  void Function(ExpandableRow, int)? onRowChanged,
  Widget Function(ExpandableRow, void Function(ExpandableRow))?
      renderEditDialog,
  int visibleColumnCount = 3,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ExpandableDataTable(
        headers: headers,
        rows: rows,
        visibleColumnCount: visibleColumnCount,
        pageSize: 10,
        isEditable: true,
        onRowChanged: onRowChanged ?? (_, __) {},
        renderEditDialog: renderEditDialog,
      ),
    ),
  );
}

List<ExpandableColumn<String>> _strHeaders(List<String> names) => names
    .map((n) => ExpandableColumn<String>(columnTitle: n, columnFlex: 1))
    .toList();

ExpandableRow _strRow(List<String> colNames, List<String> values) =>
    ExpandableRow(
      cells: List.generate(
        colNames.length,
        (i) =>
            ExpandableCell<String>(columnTitle: colNames[i], value: values[i]),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const colNames = ['First', 'Last', 'Age'];

  group('default EditDialog', () {
    testWidgets('edit icon is present per row when isEditable=true',
        (tester) async {
      final rows = [
        _strRow(colNames, ['John', 'Doe', '30']),
        _strRow(colNames, ['Jane', 'Roe', '25']),
      ];

      await tester.pumpWidget(
        _buildEditableTable(headers: _strHeaders(colNames), rows: rows),
      );

      expect(find.byIcon(Icons.edit), findsNWidgets(2));
    });

    testWidgets('tapping edit icon opens the default dialog', (tester) async {
      final rows = [
        _strRow(colNames, ['John', 'Doe', '30'])
      ];

      await tester.pumpWidget(
        _buildEditableTable(headers: _strHeaders(colNames), rows: rows),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      expect(find.text('Edit Details'), findsOneWidget);
    });

    testWidgets('CANCEL does not invoke onRowChanged', (tester) async {
      bool called = false;
      final rows = [
        _strRow(colNames, ['John', 'Doe', '30'])
      ];

      await tester.pumpWidget(
        _buildEditableTable(
          headers: _strHeaders(colNames),
          rows: rows,
          onRowChanged: (_, __) => called = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(called, isFalse);
    });

    testWidgets('SAVE invokes onRowChanged with updated String cell',
        (tester) async {
      ExpandableRow? result;
      int? resultIndex;
      final rows = [
        _strRow(colNames, ['John', 'Doe', '30'])
      ];

      await tester.pumpWidget(
        _buildEditableTable(
          headers: _strHeaders(colNames),
          rows: rows,
          onRowChanged: (row, i) {
            result = row;
            resultIndex = i;
          },
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Clear the First field and type a new name
      final firstField = find.ancestor(
        of: find.text('First'),
        matching: find.byType(Row),
      );
      final textField = find.descendant(
        of: firstField,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(textField, 'UpdatedName');

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.cells.first.value, 'UpdatedName');
      expect(resultIndex, 0); // original index in the rows list
    });

    testWidgets(
        'originalIndex reflects position in original list, not sorted position',
        (tester) async {
      int? receivedIndex;

      // Three rows: sort descending by 'Name' → "Zara" floats to top.
      // Editing "Zara" should return originalIndex=2 (its position in the
      // original unsorted list).
      final rows = [
        ExpandableRow(cells: [
          ExpandableCell<String>(columnTitle: 'Name', value: 'Alpha')
        ]),
        ExpandableRow(cells: [
          ExpandableCell<String>(columnTitle: 'Name', value: 'Beta')
        ]),
        ExpandableRow(cells: [
          ExpandableCell<String>(columnTitle: 'Name', value: 'Zara')
        ]),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: [
                ExpandableColumn<String>(columnTitle: 'Name', columnFlex: 1)
              ],
              rows: rows,
              visibleColumnCount: 1,
              pageSize: 10,
              isEditable: true,
              onRowChanged: (_, i) => receivedIndex = i,
            ),
          ),
        ),
      );

      // Sort DESC: Zara (index=2) → Beta (index=1) → Alpha (index=0)
      await tester.tap(find.text('Name').first); // ASC
      await tester.pumpAndSettle();
      await tester.tap(find.text('Name').first); // DESC
      await tester.pumpAndSettle();

      // The first visible row after DESC sort should be "Zara"
      expect(find.text('Zara'), findsOneWidget);

      // Edit the first row (visually Zara, originally at index 2)
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(receivedIndex, 2);
    });
  });

  group('custom renderEditDialog', () {
    testWidgets('custom dialog is shown instead of default', (tester) async {
      final rows = [
        _strRow(colNames, ['John', 'Doe', '30'])
      ];

      await tester.pumpWidget(
        _buildEditableTable(
          headers: _strHeaders(colNames),
          rows: rows,
          renderEditDialog: (row, onSuccess) => AlertDialog(
            title: const Text('MY CUSTOM DIALOG'),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      expect(find.text('MY CUSTOM DIALOG'), findsOneWidget);
      expect(find.text('Edit Details'), findsNothing);
    });

    testWidgets('calling onSuccess in custom dialog triggers onRowChanged',
        (tester) async {
      ExpandableRow? result;
      final rows = [
        _strRow(colNames, ['John', 'Doe', '30'])
      ];

      await tester.pumpWidget(
        _buildEditableTable(
          headers: _strHeaders(colNames),
          rows: rows,
          onRowChanged: (row, _) => result = row,
          renderEditDialog: (row, onSuccess) => AlertDialog(
            actions: [
              TextButton(
                onPressed: () {
                  row.cells[0].value = 'CHANGED';
                  onSuccess(row);
                },
                child: const Text('APPLY'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('APPLY'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.cells[0].value, 'CHANGED');
    });
  });
}
