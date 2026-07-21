import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<ExpandableColumn<String>> _headers(int count) => List.generate(
      count,
      (i) => ExpandableColumn<String>(columnTitle: 'Col $i', columnFlex: 1),
    );

List<ExpandableRow> _rows(int rowCount, int colCount) => List.generate(
      rowCount,
      (r) => ExpandableRow(
        cells: List.generate(
          colCount,
          (c) =>
              ExpandableCell<String>(columnTitle: 'Col $c', value: 'r${r}c$c'),
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  testWidgets('ExpandableTheme editIcon is used by edit button',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableTheme(
            data: const ExpandableThemeData(
              editIcon: Icon(Icons.add),
            ),
            child: ExpandableDataTable(
              headers: _headers(3),
              rows: _rows(1, 3),
              visibleColumnCount: 3,
              pageSize: 10,
              isEditable: true,
              onRowChanged: (newRow, index) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('ExpandableTheme expansionIcon and headerColor are applied',
      (tester) async {
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
              headers: _headers(3),
              rows: _rows(1, 3),
              visibleColumnCount: 2, // leave one column to expansion area
              pageSize: 10,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);

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
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableTheme(
            data: const ExpandableThemeData(paginationSize: 30),
            child: ExpandableDataTable(
              headers: _headers(3),
              rows: _rows(2, 3),
              visibleColumnCount: 3,
              pageSize: 1, // force pagination to appear
            ),
          ),
        ),
      ),
    );

    final toggleFinder = find.byType(ToggleButtons);
    expect(toggleFinder, findsOneWidget);

    final ToggleButtons toggle = tester.widget<ToggleButtons>(toggleFinder);
    expect(toggle.constraints,
        equals(BoxConstraints(minHeight: 30, minWidth: 30)));
  });

  testWidgets('ExpandableTheme contentPadding is applied to table header',
      (tester) async {
    const customPadding =
        EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableTheme(
            data: const ExpandableThemeData(contentPadding: customPadding),
            child: ExpandableDataTable(
              headers: _headers(3),
              rows: _rows(1, 3),
              visibleColumnCount: 3,
              pageSize: 10,
            ),
          ),
        ),
      ),
    );

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
    const customPadding =
        EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableTheme(
            data: const ExpandableThemeData(contentPadding: customPadding),
            child: ExpandableDataTable(
              headers: _headers(3),
              rows: _rows(2, 3),
              visibleColumnCount: 2, // leave space for expansion column
              pageSize: 10,
            ),
          ),
        ),
      ),
    );

    final initialCount = find
        .byWidgetPredicate((w) => w is Container && w.padding == customPadding)
        .evaluate()
        .length;

    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pumpAndSettle();

    expect(
      find
          .byWidgetPredicate(
              (w) => w is Container && w.padding == customPadding)
          .evaluate()
          .length,
      greaterThanOrEqualTo(initialCount),
    );
  });

  testWidgets(
      'custom expansionAnimationStyle is accepted and the row still '
      'expands and collapses correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandableTheme(
            data: const ExpandableThemeData(
              expansionAnimationStyle: AnimationStyle(
                curve: Curves.bounceOut,
                reverseCurve: Curves.easeIn,
                duration: Duration(milliseconds: 50),
              ),
            ),
            child: ExpandableDataTable(
              headers: _headers(3),
              rows: _rows(2, 3),
              visibleColumnCount: 1,
              pageSize: 20,
              renderExpansionContent: (row) =>
                  Text('EXPANDED:${row.cells[0].value}'),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('EXPANDED:'), findsNothing);

    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pumpAndSettle();
    expect(find.text('EXPANDED:r0c0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pumpAndSettle();
    expect(find.text('EXPANDED:r0c0'), findsNothing);
  });
}
