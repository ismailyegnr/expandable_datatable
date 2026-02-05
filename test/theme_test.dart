import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<ExpandableColumn<String>> _buildHeaders(int count) => List.generate(
      count,
      (i) => ExpandableColumn<String>(columnTitle: 'Col $i', columnFlex: 1),
    );

List<ExpandableRow> _buildRows(int rows, int columns) => List.generate(
    rows,
    (r) => ExpandableRow(
        cells: List.generate(
            columns,
            (c) => ExpandableCell<String>(
                columnTitle: 'Col $c', value: 'r${r}c${c}'))));

void main() {
  testWidgets('ExpandableTheme editIcon is used by edit button',
      (tester) async {
    final headers = _buildHeaders(3);
    final rows = _buildRows(1, 3);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableTheme(
            data: const ExpandableThemeData(
              editIcon: Icon(Icons.add),
            ),
            child: ExpandableDataTable(
              headers: headers,
              rows: rows,
              visibleColumnCount: 3,
              pageSize: 10,
              isEditable: true,
              onRowChanged: (newRow, index) {},
            ),
          ),
        ),
      ),
    );

    // Edit icon should come from theme (Icons.add)
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('ExpandableTheme expansionIcon and headerColor are applied',
      (tester) async {
    final headers = _buildHeaders(3);
    final rows = _buildRows(1, 3);

    const headerColor = Colors.amber;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableTheme(
            data: const ExpandableThemeData(
              expansionIcon: Icon(Icons.arrow_downward),
              headerColor: headerColor,
            ),
            child: ExpandableDataTable(
              headers: headers,
              rows: rows,
              visibleColumnCount: 2, // leave one column to expansion area
              pageSize: 10,
            ),
          ),
        ),
      ),
    );

    // Expansion icon should be the themed one
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);

    // TableHeader should use headerColor in its root Container decoration
    final containerWithColor = find.byWidgetPredicate((w) {
      if (w is Container && w.decoration is BoxDecoration) {
        final BoxDecoration d = w.decoration as BoxDecoration;
        return d.color == headerColor;
      }
      return false;
    });

    expect(containerWithColor, findsWidgets);
  });

  testWidgets(
      'ExpandableTheme paginationSize affects PaginationWidget constraints',
      (tester) async {
    final headers = _buildHeaders(3);
    final rows = _buildRows(2, 3);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableTheme(
            data: const ExpandableThemeData(paginationSize: 30),
            child: ExpandableDataTable(
              headers: headers,
              rows: rows,
              visibleColumnCount: 3,
              pageSize: 1, // force pagination to appear
            ),
          ),
        ),
      ),
    );

    // Find ToggleButtons (used by PaginationWidget) and assert constraints
    final toggleFinder = find.byType(ToggleButtons);
    expect(toggleFinder, findsOneWidget);

    final ToggleButtons toggle = tester.widget<ToggleButtons>(toggleFinder);
    expect(toggle.constraints,
        equals(BoxConstraints(minHeight: 30, minWidth: 30)));
  });
}
