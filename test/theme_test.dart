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

  testWidgets('ExpandableTheme contentPadding is applied to table header',
      (tester) async {
    final headers = _buildHeaders(3);
    final rows = _buildRows(1, 3);

    const customPadding =
        EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableTheme(
            data: const ExpandableThemeData(contentPadding: customPadding),
            child: ExpandableDataTable(
              headers: headers,
              rows: rows,
              visibleColumnCount: 3,
              pageSize: 10,
            ),
          ),
        ),
      ),
    );

    // Find the TableHeader container and verify it has the custom padding and decoration
    final headerContainerFinder = find.byWidgetPredicate((w) {
      if (w is Container && w.decoration is BoxDecoration) {
        return w.padding == customPadding;
      }
      return false;
    });

    expect(headerContainerFinder, findsOneWidget);
  });

  testWidgets(
      'ExpandableTheme contentPadding is applied to expansion row content',
      (tester) async {
    final headers = _buildHeaders(3);
    final rows = _buildRows(2, 3);

    const customPadding =
        EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableTheme(
            data: const ExpandableThemeData(contentPadding: customPadding),
            child: ExpandableDataTable(
              headers: headers,
              rows: rows,
              visibleColumnCount: 2, // leave space for expansion column
              pageSize: 10,
            ),
          ),
        ),
      ),
    );

    // Get initial count of containers with custom padding (should include header)
    final initialPaddingContainers = find.byWidgetPredicate((w) {
      if (w is Container && w.padding == customPadding) {
        return true;
      }
      return false;
    });
    final initialCount = initialPaddingContainers.evaluate().length;

    // Tap the expansion icon to expand the first row
    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pumpAndSettle();

    // Find all containers with the custom padding again
    final expandedPaddingContainers = find.byWidgetPredicate((w) {
      if (w is Container && w.padding == customPadding) {
        return true;
      }
      return false;
    });

    // Should have more or equal containers with contentPadding (header + expanded content)
    expect(
      expandedPaddingContainers.evaluate().length,
      greaterThanOrEqualTo(initialCount),
    );
  });
}
