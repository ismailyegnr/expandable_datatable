import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<ExpandableColumn<String>> _buildHeaders(int count) {
  return List.generate(
    count,
    (i) => ExpandableColumn<String>(columnTitle: 'Col $i', columnFlex: 1),
  );
}

List<ExpandableRow> _buildRows(int rows, int columns) {
  return List.generate(rows, (r) {
    return ExpandableRow(
      cells: List.generate(columns, (c) {
        return ExpandableCell<String>(
            columnTitle: 'Col $c', value: 'r${r}c${c}');
      }),
    );
  });
}

void main() {
  testWidgets('renders header visible columns', (tester) async {
    final headers = _buildHeaders(5);
    final rows = _buildRows(2, 5);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableDataTable(
            headers: headers,
            rows: rows,
            visibleColumnCount: 3,
            pageSize: 10,
          ),
        ),
      ),
    );

    // Visible header columns (Col 0..Col 2) should be present.
    expect(find.text('Col 0'), findsWidgets);
    expect(find.text('Col 1'), findsWidgets);
    expect(find.text('Col 2'), findsWidgets);
  });

  testWidgets('expands and shows custom expansion content', (tester) async {
    final headers = _buildHeaders(3);
    final rows = _buildRows(1, 3);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableDataTable(
            headers: headers,
            rows: rows,
            visibleColumnCount: 2, // make last column expansion content
            pageSize: 10,
            renderExpansionContent: (row) {
              return Text('EXPAND:${row.cells[2].value}');
            },
          ),
        ),
      ),
    );

    // Initially expansion content not shown
    expect(find.textContaining('EXPAND:'), findsNothing);

    // Tap the expansion icon to expand the row
    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pumpAndSettle();

    expect(find.text('EXPAND:r0c2'), findsOneWidget);
  });

  testWidgets('shows edit dialog and calls onRowChanged', (tester) async {
    final headers = _buildHeaders(3);
    final rows = _buildRows(2, 3);

    ExpandableRow? changedRow;
    int? changedIndex;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableDataTable(
            headers: headers,
            rows: rows,
            visibleColumnCount: 3,
            pageSize: 10,
            isEditable: true,
            onRowChanged: (newRow, originalIndex) {
              changedRow = newRow;
              changedIndex = originalIndex;
            },
            renderEditDialog: (row, onSuccess) {
              return AlertDialog(
                title: const Text('Edit'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      row.cells[0].value = 'edited';
                      onSuccess(row);
                    },
                  )
                ],
              );
            },
          ),
        ),
      ),
    );

    // Tap edit icon for first row
    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();

    // Dialog appears, tap OK to trigger onSuccess -> onRowChanged
    expect(find.text('Edit'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(changedRow, isNotNull);
    expect(changedRow!.cells[0].value, 'edited');
    expect(changedIndex, isNotNull);
  });

  testWidgets('pagination callback triggers on page change', (tester) async {
    final headers = _buildHeaders(3);
    final rows = _buildRows(2, 3);

    int? pageChanged;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableDataTable(
            headers: headers,
            rows: rows,
            visibleColumnCount: 3,
            pageSize: 1, // enable pagination behavior
            onPageChanged: (p) => pageChanged = p,
          ),
        ),
      ),
    );

    // Invoke the ToggleButtons onPressed handler for page index 2.
    final toggleFinder = find.byType(ToggleButtons);
    expect(toggleFinder, findsOneWidget);
    final ToggleButtons toggle = tester.widget<ToggleButtons>(toggleFinder);

    // index 2 corresponds to the second page when page count == 2
    toggle.onPressed!(2);
    await tester.pumpAndSettle();

    expect(pageChanged, 1);
  });
}
