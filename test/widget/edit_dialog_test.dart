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
  String? editDialogTitle,
  String? editSaveLabel,
  String? editCancelLabel,
  ExpandableThemeData themeData = const ExpandableThemeData(),
}) {
  return MaterialApp(
    home: Scaffold(
      body: ExpandableTheme(
        data: themeData,
        child: ExpandableDataTable(
          headers: headers,
          rows: rows,
          visibleColumnCount: visibleColumnCount,
          pageSize: 10,
          isEditable: true,
          onRowChanged: onRowChanged ?? (_, __) {},
          renderEditDialog: renderEditDialog,
          editDialogTitle: editDialogTitle,
          editSaveLabel: editSaveLabel,
          editCancelLabel: editCancelLabel,
        ),
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

  group('per-column editability', () {
    testWidgets('non-editable column field is disabled (String)',
        (tester) async {
      final headers = [
        ExpandableColumn<String>(
          columnTitle: 'ID',
          columnFlex: 1,
          isEditable: false,
        ),
        ExpandableColumn<String>(columnTitle: 'Name', columnFlex: 2),
      ];
      final rows = [
        ExpandableRow(
          cells: [
            ExpandableCell<String>(columnTitle: 'ID', value: '1'),
            ExpandableCell<String>(columnTitle: 'Name', value: 'Alice'),
          ],
        ),
      ];

      await tester.pumpWidget(
        _buildEditableTable(headers: headers, rows: rows),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      final textFields = tester
          .widgetList<TextFormField>(
            find.byType(TextFormField),
          )
          .toList();

      // First field is ID (isEditable: false) — should be disabled.
      expect(textFields[0].enabled, isFalse);
      // Second field is Name (isEditable: true) — should be enabled.
      expect(textFields[1].enabled, isTrue);
    });

    testWidgets('SAVE preserves original value for non-editable column',
        (tester) async {
      ExpandableRow? result;
      final headers = [
        ExpandableColumn<String>(
          columnTitle: 'ID',
          columnFlex: 1,
          isEditable: false,
        ),
        ExpandableColumn<String>(columnTitle: 'Name', columnFlex: 2),
      ];
      final rows = [
        ExpandableRow(
          cells: [
            ExpandableCell<String>(columnTitle: 'ID', value: 'original-id'),
            ExpandableCell<String>(columnTitle: 'Name', value: 'Alice'),
          ],
        ),
      ];

      await tester.pumpWidget(
        _buildEditableTable(
          headers: headers,
          rows: rows,
          onRowChanged: (row, _) => result = row,
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Change the editable Name field.
      final nameRow = find.ancestor(
        of: find.text('Name'),
        matching: find.byType(Row),
      );
      final nameField = find.descendant(
        of: nameRow,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(nameField, 'Bob');

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      // ID must retain its original value.
      final idCell = result!.cells.firstWhere((c) => c.columnTitle == 'ID');
      expect(idCell.value, 'original-id');
      // Name must reflect the new value.
      final nameCell = result!.cells.firstWhere((c) => c.columnTitle == 'Name');
      expect(nameCell.value, 'Bob');
    });
  });

  group('custom dialog labels', () {
    testWidgets('custom editDialogTitle is rendered', (tester) async {
      final rows = [
        _strRow(colNames, ['John', 'Doe', '30'])
      ];

      await tester.pumpWidget(
        _buildEditableTable(
          headers: _strHeaders(colNames),
          rows: rows,
          editDialogTitle: 'My Custom Title',
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      expect(find.text('My Custom Title'), findsOneWidget);
      expect(find.text('Edit Details'), findsNothing);
    });

    testWidgets('custom save and cancel labels are rendered', (tester) async {
      final rows = [
        _strRow(colNames, ['John', 'Doe', '30'])
      ];

      await tester.pumpWidget(
        _buildEditableTable(
          headers: _strHeaders(colNames),
          rows: rows,
          editSaveLabel: 'APPLY',
          editCancelLabel: 'DISMISS',
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      expect(find.text('APPLY'), findsOneWidget);
      expect(find.text('DISMISS'), findsOneWidget);
      expect(find.text('SAVE'), findsNothing);
      expect(find.text('CANCEL'), findsNothing);
    });

    testWidgets('default labels are used when not specified', (tester) async {
      final rows = [
        _strRow(colNames, ['John', 'Doe', '30'])
      ];

      await tester.pumpWidget(
        _buildEditableTable(headers: _strHeaders(colNames), rows: rows),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      expect(find.text('Edit Details'), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
    });
  });

  group('column hintText', () {
    testWidgets('hintText from column appears in the input field',
        (tester) async {
      final headers = [
        ExpandableColumn<String>(
          columnTitle: 'First',
          columnFlex: 1,
          hintText: 'Enter first name',
        ),
        ExpandableColumn<String>(columnTitle: 'Last', columnFlex: 1),
      ];
      final rows = [
        ExpandableRow(
          cells: [
            ExpandableCell<String>(columnTitle: 'First', value: ''),
            ExpandableCell<String>(columnTitle: 'Last', value: 'Doe'),
          ],
        ),
      ];

      await tester.pumpWidget(
        _buildEditableTable(headers: headers, rows: rows),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      expect(find.text('Enter first name'), findsOneWidget);
    });
  });

  group('edit dialog theme', () {
    testWidgets('editDialogBackgroundColor is applied', (tester) async {
      final rows = [
        _strRow(colNames, ['John', 'Doe', '30'])
      ];
      const bgColor = Color(0xFFFF5722);

      await tester.pumpWidget(
        _buildEditableTable(
          headers: _strHeaders(colNames),
          rows: rows,
          themeData: const ExpandableThemeData(
            editDialogBackgroundColor: bgColor,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(dialog.backgroundColor, bgColor);
    });

    testWidgets('editSaveButtonTextStyle color is applied to save button',
        (tester) async {
      final rows = [
        _strRow(colNames, ['John', 'Doe', '30'])
      ];
      const saveColor = Color(0xFF4CAF50);

      await tester.pumpWidget(
        _buildEditableTable(
          headers: _strHeaders(colNames),
          rows: rows,
          themeData: const ExpandableThemeData(
            editSaveButtonTextStyle: TextStyle(color: saveColor),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // The SAVE TextButton's child Text should carry the theme colour.
      final saveText = tester.widget<Text>(
        find.descendant(
          of: find.widgetWithText(TextButton, 'SAVE'),
          matching: find.byType(Text),
        ),
      );
      expect(saveText.style?.color, saveColor);
    });
  });
}
