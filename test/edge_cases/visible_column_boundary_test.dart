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
  group('visibleColumnCount == headers.length (all visible)', () {
    testWidgets('no expansion icon is shown when all columns are visible',
        (tester) async {
      // visibleColumnCount equals total column count → no hidden columns
      // → showTrailingIcon: false → no expand_more icon
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: _headers(4),
              rows: _rows(2, 4),
              visibleColumnCount: 4,
              pageSize: 10,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.expand_more), findsNothing);
    });

    testWidgets('all header titles are visible in the header row',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: _headers(4),
              rows: _rows(1, 4),
              visibleColumnCount: 4,
              pageSize: 10,
            ),
          ),
        ),
      );

      for (int i = 0; i < 4; i++) {
        expect(find.text('Col $i'), findsWidgets);
      }
    });
  });

  group('visibleColumnCount == 1 (minimum visible)', () {
    testWidgets('only the first column title appears in the header',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: _headers(4),
              rows: _rows(1, 4),
              visibleColumnCount: 1,
              pageSize: 10,
            ),
          ),
        ),
      );

      // Only 'Col 0' is a header column; other colnames only appear inside tiles
      expect(find.text('Col 0'), findsWidgets); // header + row cell
      expect(find.text('Col 1'), findsNothing);
      expect(find.text('Col 2'), findsNothing);
      expect(find.text('Col 3'), findsNothing);
    });

    testWidgets(
        'expanding a row shows the remaining 3 columns as expansion cells',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: _headers(4),
              rows: _rows(1, 4),
              visibleColumnCount: 1,
              pageSize: 10,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      // Default ExpansionContainer shows "Col 1:", "Col 2:", "Col 3:" labels
      expect(find.text('Col 1:'), findsOneWidget);
      expect(find.text('Col 2:'), findsOneWidget);
      expect(find.text('Col 3:'), findsOneWidget);
    });
  });

  group('responsive: visibleColumnCount changes between builds', () {
    testWidgets(
        'reducing visibleColumnCount mid-session moves columns to expansion area',
        (tester) async {
      var visibleCount = 3;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => visibleCount = 1),
                      child: const Text('REDUCE'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: _headers(3),
                        rows: _rows(1, 3),
                        visibleColumnCount: visibleCount,
                        pageSize: 10,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // 3 visible → no expansion icon
      expect(find.byIcon(Icons.expand_more), findsNothing);

      // Reduce to 1 visible
      await tester.tap(find.text('REDUCE'));
      await tester.pumpAndSettle();

      // Now 2 columns are hidden → expansion icon appears
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets(
        'increasing visibleColumnCount removes expansion icon when all columns fit',
        (tester) async {
      var visibleCount = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => visibleCount = 3),
                      child: const Text('EXPAND_VISIBLE'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: _headers(3),
                        rows: _rows(1, 3),
                        visibleColumnCount: visibleCount,
                        pageSize: 10,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // 1 visible → expansion icon present
      expect(find.byIcon(Icons.expand_more), findsOneWidget);

      // Expand to show all 3
      await tester.tap(find.text('EXPAND_VISIBLE'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.expand_more), findsNothing);
    });
  });

  group('visibleColumnCount > headers.length (clamped to headers.length)', () {
    testWidgets(
        'no expansion icon when visibleColumnCount exceeds header count',
        (tester) async {
      // headers has 3 columns but visibleColumnCount is 99
      // → clamped to 3 → all columns are visible → no expansion icon
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: _headers(3),
              rows: _rows(2, 3),
              visibleColumnCount: 99,
              pageSize: 10,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.expand_more), findsNothing);
    });

    testWidgets(
        'all header titles are rendered when visibleColumnCount exceeds header count',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: _headers(3),
              rows: _rows(1, 3),
              visibleColumnCount: 99,
              pageSize: 10,
            ),
          ),
        ),
      );

      expect(find.text('Col 0'), findsWidgets);
      expect(find.text('Col 1'), findsWidgets);
      expect(find.text('Col 2'), findsWidgets);
    });
  });
}
