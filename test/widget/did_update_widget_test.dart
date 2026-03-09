import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<ExpandableColumn<String>> _headers(int count) => List.generate(
      count,
      (i) => ExpandableColumn<String>(columnTitle: 'H$i', columnFlex: 1),
    );

List<ExpandableRow> _rows(int rowCount, int colCount, {String prefix = 'v'}) =>
    List.generate(
      rowCount,
      (r) => ExpandableRow(
        cells: List.generate(
          colCount,
          (c) => ExpandableCell<String>(
              columnTitle: 'H$c', value: '$prefix${r}c$c'),
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('rows prop update', () {
    testWidgets('replacing rows rebuilds table with new data', (tester) async {
      var rowData = _rows(2, 3, prefix: 'OLD');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() => rowData = _rows(2, 3, prefix: 'NEW'));
                      },
                      child: const Text('SWAP'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: _headers(3),
                        rows: rowData,
                        visibleColumnCount: 3,
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

      // Old data visible
      expect(find.text('OLD0c0'), findsOneWidget);

      // Swap rows
      await tester.tap(find.text('SWAP'));
      await tester.pumpAndSettle();

      // New data visible, old data gone
      expect(find.text('NEW0c0'), findsOneWidget);
      expect(find.text('OLD0c0'), findsNothing);
    });

    for (final multi in [true, false]) {
      testWidgets(
          'updating rows collapses expanded rows (multipleExpansion:$multi)',
          (tester) async {
        var rowData = _rows(2, 3);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() => rowData = _rows(2, 3, prefix: 'NEW'));
                        },
                        child: const Text('SWAP'),
                      ),
                      Expanded(
                        child: ExpandableDataTable(
                          headers: _headers(3),
                          rows: rowData,
                          visibleColumnCount: 1,
                          pageSize: 10,
                          multipleExpansion: multi,
                          renderExpansionContent: (row) =>
                              Text('EXPANDED:${row.cells[0].value}'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        // Expand first row
        await tester.tap(find.byIcon(Icons.expand_more).first);
        await tester.pumpAndSettle();
        expect(find.textContaining('EXPANDED:'), findsOneWidget);

        // Swap data → didUpdateWidget → _shrinkAllRows → epoch increments → tiles recreated
        await tester.tap(find.text('SWAP'));
        await tester.pumpAndSettle();

        expect(find.textContaining('EXPANDED:'), findsNothing);
      });
    }
  });

  group('pageSize prop update', () {
    testWidgets(
        'reducing pageSize recalculates page count: ToggleButtons gains children',
        (tester) async {
      var pageSize = 10;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => pageSize = 1),
                      child: const Text('REDUCE'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: _headers(3),
                        rows: _rows(3, 3),
                        visibleColumnCount: 3,
                        pageSize: pageSize,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // With pageSize=10 and 3 rows → 1 page → PaginationWidget returns SizedBox.shrink()
      expect(find.byType(ToggleButtons), findsNothing);

      // Reduce to pageSize=1 → 3 pages → pagination appears
      await tester.tap(find.text('REDUCE'));
      await tester.pumpAndSettle();

      expect(find.byType(ToggleButtons), findsOneWidget);
    });
  });

  group('isEditable prop update', () {
    testWidgets('toggling isEditable shows and hides edit icons',
        (tester) async {
      var editable = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => editable = !editable),
                      child: const Text('TOGGLE'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: _headers(3),
                        rows: _rows(2, 3),
                        visibleColumnCount: 3,
                        pageSize: 10,
                        isEditable: editable,
                        onRowChanged: (_, __) {},
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initially not editable — no edit icons
      expect(find.byIcon(Icons.edit), findsNothing);

      // Toggle on
      await tester.tap(find.text('TOGGLE'));
      await tester.pumpAndSettle();

      // One edit icon per visible row (2 rows)
      expect(find.byIcon(Icons.edit), findsNWidgets(2));

      // Toggle off again
      await tester.tap(find.text('TOGGLE'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsNothing);
    });
  });

  group('visibleColumnCount prop update', () {
    testWidgets('increasing visibleColumnCount shows previously hidden columns',
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
                      onPressed: () => setState(() => visibleCount = 2),
                      child: const Text('INCREASE'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: _headers(3),
                        rows: _rows(2, 3),
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

      // Only H0 visible; H1 is in expansion
      expect(find.text('H0'), findsOneWidget);
      expect(find.text('H1'), findsNothing);

      await tester.tap(find.text('INCREASE'));
      await tester.pumpAndSettle();

      // Both H0 and H1 now visible in the header
      expect(find.text('H0'), findsOneWidget);
      expect(find.text('H1'), findsOneWidget);
    });

    testWidgets(
        'visibleColumnCount exceeding headers.length shows all columns without crash',
        (tester) async {
      var visibleCount = 2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => visibleCount = 99),
                      child: const Text('EXCEED'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: _headers(3),
                        rows: _rows(2, 3),
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

      // Initially 2 of 3 headers visible
      expect(find.text('H0'), findsOneWidget);
      expect(find.text('H2'), findsNothing);

      // Set visibleColumnCount way beyond headers.length — should not crash
      await tester.tap(find.text('EXCEED'));
      await tester.pumpAndSettle();

      // All 3 headers now visible, clamped by headers.length
      expect(find.text('H0'), findsOneWidget);
      expect(find.text('H1'), findsOneWidget);
      expect(find.text('H2'), findsOneWidget);
    });
  });

  group('headers prop update', () {
    testWidgets('updating headers replaces visible column titles',
        (tester) async {
      var headers = [
        ExpandableColumn<String>(columnTitle: 'OldName', columnFlex: 1)
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => headers = [
                            ExpandableColumn<String>(
                                columnTitle: 'NewName', columnFlex: 1)
                          ]),
                      child: const Text('SWAP'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: headers,
                        rows: [
                          ExpandableRow(cells: [
                            ExpandableCell<String>(
                                columnTitle: 'OldName', value: 'x')
                          ])
                        ],
                        visibleColumnCount: 1,
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

      expect(find.text('OldName'), findsOneWidget);

      await tester.tap(find.text('SWAP'));
      await tester.pumpAndSettle();

      expect(find.text('NewName'), findsOneWidget);
      expect(find.text('OldName'), findsNothing);
    });

    testWidgets(
        'orphaned cell (header swapped, rows not yet updated) is silently '
        'dropped — not leaked into the expansion panel', (tester) async {
      // This test guards against the old accidental behaviour where a cell
      // whose columnTitle no longer existed in `headers` would fall through
      // to `expansionCells` and appear in the expansion panel as "OldName: x".
      //
      // New behaviour: the cell is skipped entirely for that transient frame.

      var headers = [
        ExpandableColumn<String>(columnTitle: 'OldName', columnFlex: 1),
      ];

      // Two columns so expansion panel is reachable (visibleColumnCount: 1).
      final rows = [
        ExpandableRow(cells: [
          ExpandableCell<String>(columnTitle: 'OldName', value: 'orphan'),
        ]),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TextButton(
                      // Only swap headers — rows intentionally keep "OldName".
                      onPressed: () => setState(() => headers = [
                            ExpandableColumn<String>(
                                columnTitle: 'NewName', columnFlex: 1),
                          ]),
                      child: const Text('SWAP HEADERS'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: headers,
                        rows: rows,
                        visibleColumnCount: 1,
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

      // Before swap: "OldName" header and "orphan" value visible.
      expect(find.text('OldName'), findsOneWidget);
      expect(find.text('orphan'), findsOneWidget);

      await tester.tap(find.text('SWAP HEADERS'));
      await tester.pumpAndSettle();

      // "NewName" header is shown; the orphaned cell value must not appear
      // anywhere — not in the title row, not leaked into the expansion panel.
      expect(find.text('NewName'), findsOneWidget);
      expect(find.text('orphan'), findsNothing);

      // Because the orphaned cell was dropped, expansionCells is empty and
      // the expansion arrow is not rendered — confirming nothing leaked.
      // (Old behaviour: the cell would fall through to expansionCells,
      // keeping the arrow visible and showing "OldName: orphan" inside.)
      expect(find.byIcon(Icons.expand_more), findsNothing);
      expect(find.text('OldName:'), findsNothing); // old label format
    });
  });
}
