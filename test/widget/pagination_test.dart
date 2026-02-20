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

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('pagination — page count calculation', () {
    testWidgets('two pages: ToggleButtons appear when rows exceed pageSize',
        (tester) async {
      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(6, 2),
          visibleColumnCount: 2,
          pageSize: 5,
        ),
      ));

      expect(find.byType(ToggleButtons), findsOneWidget);
    });

    testWidgets('correct row count shown per page', (tester) async {
      // 5 rows, pageSize=3 → page 0 has 3 rows, page 1 has 2 rows
      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(5, 2),
          visibleColumnCount: 2,
          pageSize: 3,
        ),
      ));

      // Page 0: rows r0c0, r1c0, r2c0
      expect(find.text('r0c0'), findsOneWidget);
      expect(find.text('r1c0'), findsOneWidget);
      expect(find.text('r2c0'), findsOneWidget);
      // Row 3 belongs to page 1 and must not be visible
      expect(find.text('r3c0'), findsNothing);
    });

    testWidgets('next page shows correct rows', (tester) async {
      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(5, 2),
          visibleColumnCount: 2,
          pageSize: 3,
        ),
      ));

      await tester.tap(find.byIcon(Icons.keyboard_arrow_right).first);
      await tester.pumpAndSettle();

      // Page 1 has rows 3 and 4
      expect(find.text('r3c0'), findsOneWidget);
      expect(find.text('r4c0'), findsOneWidget);
      expect(find.text('r0c0'), findsNothing);
    });
  });

  group('pagination — boundary navigation', () {
    testWidgets('previous button on first page does not go below page 0',
        (tester) async {
      int? lastPage;

      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(4, 2),
          visibleColumnCount: 2,
          pageSize: 2,
          onPageChanged: (p) => lastPage = p,
        ),
      ));

      // Tap prev on page 0
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left).first);
      await tester.pumpAndSettle();

      // onPageChanged must not have fired (no navigation happened)
      expect(lastPage, isNull);
    });

    testWidgets('next button on last page does not advance further',
        (tester) async {
      final pages = <int>[];

      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(4, 2),
          visibleColumnCount: 2,
          pageSize: 2,
          onPageChanged: (p) => pages.add(p),
        ),
      ));

      // Advance to last page (page index 1)
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right).first);
      await tester.pumpAndSettle();

      // Try to go further
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right).first);
      await tester.pumpAndSettle();

      // onPageChanged fired exactly once (page 1), not twice
      expect(pages, [1]);
    });

    testWidgets('onPageChanged callback receives correct page index',
        (tester) async {
      int? reportedPage;

      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(6, 2),
          visibleColumnCount: 2,
          pageSize: 2,
          onPageChanged: (p) => reportedPage = p,
        ),
      ));

      await tester.tap(find.byIcon(Icons.keyboard_arrow_right).first);
      await tester.pumpAndSettle();

      expect(reportedPage, 1);
    });
  });
}
