import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<ExpandableColumn<String>> _headers(int count) => List.generate(
      count,
      (i) => ExpandableColumn<String>(columnTitle: 'C$i', columnFlex: 1),
    );

List<ExpandableRow> _rows(int rowCount, int colCount) => List.generate(
      rowCount,
      (r) => ExpandableRow(
        cells: List.generate(
          colCount,
          (c) => ExpandableCell<String>(columnTitle: 'C$c', value: 'r${r}c$c'),
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('renderExpansionContent', () {
    testWidgets(
        'custom expansion widget is rendered instead of default label:value rows',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: _headers(3),
              rows: _rows(2, 3),
              visibleColumnCount: 1, // C1 and C2 go to expansion
              pageSize: 10,
              renderExpansionContent: (row) {
                return Text('CUSTOM:${row.cells[0].value}');
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      // Custom content visible
      expect(find.text('CUSTOM:r0c0'), findsOneWidget);

      // Default ExpansionContainer shows "C1:" / "C2:" labels — must be absent
      expect(find.text('C1:'), findsNothing);
      expect(find.text('C2:'), findsNothing);
    });

    testWidgets('each row receives its own row data in the callback',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: _headers(2),
              rows: _rows(3, 2),
              visibleColumnCount: 1,
              pageSize: 10,
              renderExpansionContent: (row) =>
                  Text('EXP:${row.cells[0].value}'),
            ),
          ),
        ),
      );

      // Expand row 1 (second row)
      await tester.tap(find.byIcon(Icons.expand_more).at(1));
      await tester.pumpAndSettle();

      expect(find.text('EXP:r1c0'), findsOneWidget);
      // Row 0 and row 2 must not be expanded
      expect(find.text('EXP:r0c0'), findsNothing);
      expect(find.text('EXP:r2c0'), findsNothing);
    });
  });

  group('renderCustomPagination', () {
    testWidgets('custom pagination widget replaces default ToggleButtons',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: _headers(3),
              rows: _rows(3, 3),
              visibleColumnCount: 3,
              pageSize: 1, // force 3 pages
              renderCustomPagination: (count, page, onChange) {
                return Text('PAGINATION:count=$count,page=$page');
              },
            ),
          ),
        ),
      );

      expect(find.text('PAGINATION:count=3,page=0'), findsOneWidget);
      expect(find.byType(ToggleButtons), findsNothing);
    });

    testWidgets('custom pagination receives updated page after onChange call',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: _headers(3),
              rows: _rows(4, 3),
              visibleColumnCount: 3,
              pageSize: 2, // 2 pages
              renderCustomPagination: (count, page, onChange) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('PAGE:$page'),
                    TextButton(
                      onPressed: () => onChange(1),
                      child: const Text('GO_PAGE_2'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('PAGE:0'), findsOneWidget);

      expect(find.text("r0c0"),
          findsOneWidget); // sanity check: page 0 content visible

      await tester.tap(find.text('GO_PAGE_2'));
      await tester.pumpAndSettle();

      expect(find.text("PAGE:0"), findsNothing);
      expect(find.text('PAGE:1'), findsOneWidget);

      expect(find.text("r0c0"),
          findsNothing); // page 0 content must not be visible
      expect(find.text("r2c0"), findsOneWidget); // page 1 content visible
    });

    testWidgets('page change via custom pagination collapses expanded rows',
        (tester) async {
      int currentPage = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: _headers(2),
              rows: _rows(4, 2),
              visibleColumnCount: 1,
              pageSize: 2,
              renderExpansionContent: (row) =>
                  Text('EXPANDED:${row.cells[0].value}'),
              onPageChanged: (page) => currentPage = page,
              renderCustomPagination: (count, page, onChange) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => onChange(0),
                      child: const Text('GO_PAGE_0'),
                    ),
                    TextButton(
                      onPressed: () => onChange(1),
                      child: const Text('GO_PAGE_1'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Expand first row on page 0
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();
      expect(find.text('EXPANDED:r0c0'), findsOneWidget);

      // Navigate to page 1 — expansion must collapse
      await tester.tap(find.text('GO_PAGE_1'));
      await tester.pumpAndSettle();
      expect(currentPage, 1);
      expect(find.text('EXPANDED:r0c0'), findsNothing);

      // Navigate back to page 0 — row must still be collapsed
      await tester.tap(find.text('GO_PAGE_0'));
      await tester.pumpAndSettle();
      expect(currentPage, 0);
      expect(find.text('EXPANDED:r0c0'), findsNothing);
    });
  });
}
